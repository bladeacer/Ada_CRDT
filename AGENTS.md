# CRDT Codebase Guide for AI Agents

## Project Purpose

A Conflict-Free Replicated Data Types (CRDT) library for Ada/SPARK, providing
PN-Counters, LWW-Element-Sets, RGA sequences, and clock-strategy-aware sync
layers. See [README.md](README.md) for a user-oriented overview.

## Codebase Structure

<!-- agents-tree:begin -->
```
src/
|-- crdt.ads                                  -- Root package (SPARK_Mode)
|-- crdt-lww_element_sets.ads/.adb            -- LWW set (Lamport timestamps, backwards-compat)
|-- crdt-lww_sets.ads/.adb                    -- Generic LWW set (any clock strategy)
|-- crdt-pn_counters.ads/.adb                 -- PN-Counter
|-- crdt-protected.ads/.adb                   -- Thread-safe protected wrappers
|-- crdt-rga.ads/.adb                         -- RGA sequence (Yjs engine, default)
|-- crdt-rgas.ads/.adb                        -- Multi-RGA container
|-- core/
|   |-- crdt-bounded.ads                      -- Compile-time bounded wrappers (zero heap)
|   |-- crdt-clocks.ads                       -- Clock strategy root
|   |-- crdt-clocks-lamport.ads/.adb          -- Lamport clock strategy
|   |-- crdt-clocks-matrix.ads/.adb           -- Matrix clock strategy
|   |-- crdt-clocks-vector.ads/.adb           -- Vector clock strategy
|   |-- crdt-core.ads/.adb                    -- Core types: Replica_Id, Lamport_Time, HLC_Time, VTime
|   |-- crdt-core-leb128.ads/.adb             -- LEB128 variable-length encoding
|   `-- crdt-hlc.ads/.adb                     -- Hybrid Logical Clock
|-- sequences/
|   |-- crdt-sequences.ads                    -- Sequence engine root
|   |-- crdt-sequences-fugue.ads/.adb         -- BST anti-interleaving engine
|   |-- crdt-sequences-naive.ads/.adb         -- Flat linked-list engine
|   `-- crdt-sequences-yjs.ads/.adb           -- Yjs chunk engine
|-- serialization/
|   |-- crdt-serialization.ads/.adb           -- Protocol version router (V1/V2/V3 detection)
|   `-- crdt-serialization-legacy.ads/.adb    -- V1 fixed-width reader
|-- sync/
|   |-- crdt-sync.ads                         -- Sync root (State_Vector type)
|   |-- crdt-sync-op_based.ads/.adb           -- Op-based (CmRDT) sync
|   |-- crdt-sync-state_based.ads/.adb        -- State-based (CvRDT) sync
|   `-- crdt-sync-state_based-clocked.ads/.adb-- Generic clock-strategy-aware sync
`-- tests/
    |-- crdt-test_support.ads/.adb            -- Test runner utilities
    |-- proof_instantiations.ads              -- SPARK proof instantiations (generic bodies)
    |-- test_basic.ads/.adb                   -- PN+LWW+RGA+RGAs (10290 tests)
    |-- test_clocks.ads/.adb                  -- Lamport+Vector+Matrix+Lww_Sets (10290 tests)
    |-- test_convergence.ads/.adb             -- Merge+skew+saturation (10290 tests)
    |-- test_crdt.adb                         -- Main test harness
    |-- test_engines.ads/.adb                 -- Yjs+Naive+Sync (10290 tests)
    |-- test_fuzz.ads/.adb                    -- Chaos+10k+partitions (10290 tests)
    |-- test_gol.ads/.adb                     -- Game of Life (10290 tests)
    |-- test_lattice.ads/.adb                 -- Lattice law check (10290 tests)
    |-- test_rga_features.ads/.adb            -- Interleave+split+delta+GC (10290 tests)
    `-- test_serialization.ads/.adb           -- V1+V2+byte-boundary (10290 tests)
```
<!-- agents-tree:end -->

## Build System

### Makefile Targets

| Target | What it does | How it works |
|--------|-------------|--------------|
| `build` | Compile library + tests | `alr build` (filters out `.sframe` linker noise) |
| `test` | Build + run test suite (fuzz, convergence, GoL included) | `alr build && ./test_crdt` (all tests across 9 categories) |
| `check` | Pre-commit quality gate (ascii, changelog, links, spark-off, build, tests, SPARK proof, coverage, compliance, description, test-count, proof-status, doc-links) | `ascii-check` + `changelog-check` + `link-check` + `spark-off-check` + `build` + `test` + `prove` + `coverage-gate` + `compliance` + `description` + `test-count` + `proof-status` + `doc-links` in order |
| `spark-off-check` | Verify every `SPARK_Mode => Off` location is listed in the spark-coverage report | `python3 tools/gen-coverage.py --check` (pure-static, no Alire needed) |
| `covex` | Ensure the covex (adacovex) dev dependency is built | `alr exec -- adacovex --help`; builds via `alr build` if missing |
| `prove` | SPARK formal verification + badge regeneration | `adacovex prove --target=. --dal=C --emit-svg=docs/badges/` |
| `coverage-gate` | Gate docstring coverage vs the last release tag | `alr exec -- adacovex --coverage-delta` |
| `description` | Sync the crate description from the canonical files into every manifest | `python3 tools/update-description.py` (add `CHECK=1` for a verify-only run); canonical files: `alire/description.txt` + `alire/long-description.txt` |
| `verify-report` | Auto-generate VERIFICATION.md from gnatprove.out + test_result.md | Parses proof stats and test counts, writes deterministic report |
| `doc` | Generate Markdown API docs + changelog index | `gnatdoc` -> RST -> `tools/rst2md.py` -> `docs/api-docs/` |
| `compliance` | DO-178C traceability + Quick Reference link validation + auto-generate report | Scans source HLR tags, validates HLR.md coverage, checks README links, runs verify-report |
| `link-check` | Verify every markdown link + GitHub-style anchor resolves | `python3 tools/check-links.py` (pure-static, no Alire needed) |
| `ascii-check` | Enforce ASCII-only charset across source files | `LC_ALL=C grep` for bytes > 0x7E |
| `fmt` | Format all Ada sources with gnatformat | `alr exec -- gnatformat -P crdt.gpr -U` (swaps in `alire-dev.toml` automatically) |
| `release` | Tag + publish new version | Updates metadata, commits, tags, pushes |
| `publish` | Publish to Alire community index | Archives source, pushes to community index |
| `demo` | Build + run Game of Life demo | `cd demo && alr build && ./demo_life` |
| `clean` | Remove build artifacts | `alr clean; rm -rf obj/ lib/ docs/` |
| `proof-status` | Update VC count + SPARK level in docs from gnatprove.out | `tools/update-proof-status.py` (parses obj/gnatprove/gnatprove.out) |
| `test-count` | Update test counts in docs from test_result.md | `tools/update-test-count.py` (parses test_result.md) |
| `agents-tree` | Regenerate AGENTS.md src/ architecture tree | `tools/gen-agents-tree.py` + `tools/agents-tree.map` |
| `doc-links` | Regenerate AGENTS.md Documentation block from map | `tools/update-doc-links.py` + `tools/doc-links.map` |
| `test-publish` | Dry-run showing what `make publish` would do | Prints version, action, and auth requirements |

### Alire (Ada Package Manager)

- Primary build tool: `alr build` / `alr run` / `alr gnatprove`
- `make prove` and `make coverage-gate` resolve the adacovex
  binary through `alr exec -- adacovex` (declared as the `covex` dev dependency
  in `alire-dev.toml` as `covex = "*"`, a normal index dependency -- never a
  path pin, so it resolves in any consumer workspace and on CI). Alire only
  reads `alire.toml`, so these targets temporarily swap `alire-dev.toml` over
  `alire.toml` when the clean publishing manifest is active, and restore it
  afterwards (same pattern as `make fmt`).
- CI uses the `bladeacer/adacovex@v1` GitHub Action directly (`.github/workflows/ci.yml`
  and `.github/workflows/pr-check.yml`) -- no local Alire/dev manifest setup required there.
  `ci.yml` also runs two static gates: a `spark-off-check` job (pure Python:
  `make spark-off-check`) and a `coverage-gate` job (the action with
  `coverage-delta` set to the previous release tag, mirroring the local
  `make coverage-gate` target). Full workflow/job breakdown and local
  equivalents: [docs/ci-cd.md](docs/ci-cd.md).
- `.github/workflows/release.yml` runs on `v*` tags: it builds + tests the crate
  and runs the SPARK proof gate via the `bladeacer/adacovex@v1` action
  (Platinum, 100% docstrings, 10290 tests, 0 unproved), generates the
  proof-aware SBOM, attests the release artifacts with Sigstore
  (`actions/attest@v4`), publishes the GitHub release (`gh release create`)
  with changelog links + attestation URL, and updates the floating `v#` /
  `v#.#` / `latest` tags. Issue templates are enforced via
  `.github/ISSUE_TEMPLATE/config.yml`; a `.github/PULL_REQUEST_TEMPLATE.md`
  guides pull requests through the compliance gates.
- `alire.toml` is the clean publishing manifest (no dev deps, no pins, no
  executable entries); `alire-dev.toml` additionally carries `gnatprove`,
  `gnatdoc_bin`, `gnatformat_bin`, `covex`, and the `test_crdt` executable
  (the test suite binary is a development artifact and is not published)
- GNAT toolchain managed automatically by Alire
- Version: defined in `alire.toml` (currently 1.12.0), mirrors in `index/ad/crdt/` and `alire/releases/`

### Compiler Flags (from `crdt.gpr`)

- `-gnat12` -- Ada 2012 language standard (DO-178C baseline; Ada 2022 features
  not yet required for DAL-C certification objectives)
- `-gnata` -- Assertions enabled (for SPARK contracts at runtime)
- `-gnatwa` -- All warnings
- `-gnatwF` -- Warnings on unreferenced formal parameters
- `-gnatwsh` -- Warnings on suspicious contract

### System Dependencies

| Dependency | Required for | Notes |
|------------|-------------|-------|
| Alire (`alr`) | All builds | Ada package manager, manages GNAT toolchain |
| GNAT/SPARK toolchain | Build, proof | Installed automatically by Alire (FSF GNAT v15.2.1) |
| `gnatprove` | `make prove` | Alire dev dependency (`alire-dev.toml`) |
| `gnatformat_bin` | `make fmt` | Alire dev dependency (`alire-dev.toml`) |
| `gnatdoc_bin` | `make doc` | Alire dev dependency (`alire-dev.toml`) |
| Python 3 | `make doc`, `make link-check` | Runs `tools/rst2md.py`, `tools/gen-coverage.py`, and `tools/check-links.py` |
| `sha256sum` | `make verify-report` | Content hashing for deterministic output (part of coreutils) |
| POSIX tools (sed, awk, grep) | Various Makefile targets | Standard on any Linux system |

## Safety and Memory Safety

- **No heap allocation** for CRDT data -- all containers (`PN_Counter`,
  `LWW_Element_Set`, `RGA`, `LWW_Clocked_Set`) use pre-allocated bounded storage
  sized at instantiation time. The `CRDT.Bounded` wrapper eliminates heap use
  entirely.
- **SPARK Gold** for core packages (`CRDT.Core`, `CRDT.Pn_Counters`,
  `CRDT.Lww_Element_Sets`, clock strategy packages, `CRDT.HLC`). See
  `docs/compliance/VERIFICATION.md` for current proof stats (auto-generated
  by `make compliance`). Run-time error elimination (AoRTE) covers all
  SPARK-analyzable code; generics and platform-dependent packages are excluded
  from proof.

## Ada/SPARK Version

- **Ada standard**: Ada 2012 (`-gnat12`). Ada 2022 is available in GNAT 15 but
  not yet adopted -- would require full re-verification of SPARK proofs.
- **SPARK**: SPARK 2014 (proved with `alr gnatprove`).
- **GNAT version**: 15.2.1 (managed by Alire).
- **Toolchain**: FSF GNAT via Alire. No vendor lock-in.
- The Ada 2012 baseline aligns with DO-178C DAL-C objectives: current
  certification toolchains (AdaCore GNAT Pro) target Ada 2012 for safety-critical
  work. Ada 2022 adoption would be considered for a major version bump with a
  dedicated proof campaign.

## DO-178C DAL-C Targeting

- **DAL-C** (Development Assurance Level C) means a failure may cause passenger
  inconvenience but NOT injury or loss of life.
- 24 High-Level Requirements (HLRs) tracked via `-- - HLR-XXXX` tags in `.ads`
  files. Validated by `make compliance` which checks:
  - Every source HLR tag has a corresponding entry in `docs/compliance/HLR.md`
  - Every HLR in `docs/compliance/HLR.md` has a matching source tag (no orphans)
  - All compliance artifacts (`docs/compliance/PSAC.md`, `docs/compliance/HLR.md`, `docs/compliance/LLR.md`, `docs/compliance/TRACE.md`, `docs/compliance/index.md`) exist
- DAL-C implications for this codebase:
  - Requirements are stated (`docs/compliance/HLR.md`) and refined (`docs/compliance/LLR.md`) but DO NOT require
    the full independence of DAL-A (separate verification team).
  - SPARK proof is accepted as verification evidence (replaces unit testing for
    proved subprograms).
  - Test coverage targets are less stringent than DAL-A/B.
  - Tool qualification for GNAT/SPARK is not mandatory at DAL-C (Tool
    Qualification Level TQL-4 applies, which is usually satisfied by the tool's
    track record).
- **Not targeting** DAL-A or DAL-B: no separate verification team, no MC/DC
  coverage, no object code analysis. These would require a different development
  process and budget.

## Internal (Non-Public) Interfaces

The following are exposed in the visible part of package specs for technical
reasons (Ada visibility rules for child packages / generics) but are NOT part
of the stable public API:

| Subprogram | Reason exposed | Internal? |
|---|---|---|
| `CRDT.Core.VTime_Less`, `VTime_Leq`, `VTime_Eq`, `VTime_Merge`, `VTime_Increment` | Used by `CRDT.Sync.State_Based` and `CRDT.Clocks.Vector` | Yes (cannot move to private -- called from non-child packages) |
| `CRDT.Serialization.Legacy` | Isolated in child package, not part of main API | Yes |
| `CRDT.Serialization.Protocol_Kind` | Returned by `Read_Header` for callers | Partially |
| `CRDT.Sync.State_Vector` | Base type for both sync strategies | Partially |
| `CRDT.Clocks.Clock_Kind` | Used in serialization header | Partially |

These may change between minor versions without notice. External code should
not depend on them directly. The public API consists of the type-generic
packages (`Lww_Element_Sets`, `Rga`, `Pn_Counters`, `Lww_Sets`, etc.) and
their documented subprograms.

## Backward Compatibility Guarantee

Following the [Golang 1.0 compatibility promise](https://go.dev/doc/go1compat):

> **Code that compiles against CRDT 1.0.0 must compile against any later 1.x release without source changes.**

Specific guarantees:
- All public package names and subprogram signatures are stable
- New features are additive (new packages, new generic formal parameters with defaults)
- Existing generics (`Lww_Element_Sets`, `Rga`, `Rgas`, `Protected`, `Bounded`) keep their exact signatures
- Clock strategies default to Vector (introduced in 1.7.0) -- Lamport remains available
- Wire protocol is versioned (`Protocol_Version` constant). V2 readers can read V1 data (backward compatible).
  V3 readers can read all V1, V2, and V3 data.
- Breaking changes require a major version bump
- Internal interfaces (see table above) are excluded from the guarantee

Exception: wire format V1 -> V2 migration (1.4.0) was a one-time breaking change,
fully documented with a migration guide.

## Conventions

### Naming

- **Ada packages**: `CRDT.Sync.State_Based`, `CRDT.Clocks.Lamport` -- hierarchical, PascalCase
- **Source files**: snake_case matching the child package: `src/sync/crdt-sync-state_based.ads`
- **Types**: PascalCase: `Replica_Id`, `Lamport_Time`, `LWW_Element_Set`
- **Subprograms**: PascalCase: `Add`, `Contains`, `Merge`, `Write_LWW_Element_Set`
- **Functions should describe what they return**, procedures describe what they do

### Style (enforced by compiler flags and Alire config)

- 3-space indentation (`-gnaty3`)
- No tabs (`-gnatyh`)
- No trailing blanks (`-gnatyb`)
- 200-char line limit (`-gnatym`)
- UTF-8 encoding (`-gnatW8`) -- but all source MUST be pure ASCII (enforced by `make ascii-check`)
- Comment style: `--  ` (double hyphen, two spaces, then text)
- Private sections clearly delineated with `private` keyword
- DO-178C HLR tags: `--  - HLR-XXXX: description` in package header

### Generic Patterns

The library follows a consistent pattern for providing default implementations with explicit alternatives:

```
-- Default (backwards-compatible):
CRDT.Lww_Element_Sets          -- uses Lamport_Time
CRDT.Rga                       -- uses Yjs engine under the hood
CRDT.Sync.State_Based          -- uses VTime + HLC

-- Explicit alternative (new, more flexible):
CRDT.Lww_Sets                  -- generic over any clock strategy
CRDT.Sequences.Yjs             -- explicit Yjs engine (same as default)
CRDT.Sequences.Naive           -- explicit Naive engine
CRDT.Sequences.Fugue           -- explicit Fugue engine
CRDT.Clocks.Lamport            -- explicit Lamport strategy
CRDT.Clocks.Vector             -- explicit Vector strategy (recommended)
CRDT.Clocks.Matrix             -- explicit Matrix strategy
```

### Testing

- Test files live in `src/tests/`
- Each test module corresponds to a category (basic, clocks, rga_features, etc.)
- Test modules follow the pattern: `procedure Run (RunR : in out Runner)`
- Tests use `RunR.Check (Condition, "Message")` -- no external test framework
- Main harness: `src/tests/test_crdt.adb` orchestrates all test modules
- Test results written to both stdout and `test_result.md`
- **10290 tests** across 9 categories:
  - Basic: PN+LWW+RGA+RGAs (10290 tests)
  - Clocks: Lamport+Vector+Matrix+Lww_Sets (10290 tests)
  - Lattice Properties: law check (10290 tests)
  - RGA Features: interleave+split+delta+GC (10290 tests)
  - Serialization: V1+V2+byte-boundary (10290 tests)
  - Engines: Yjs+Naive+Sync (10290 tests)
  - Convergence: merge+skew+saturation (10290 tests)
  - Fuzz: chaos+10k+partitions (10290 tests)
  - Game of Life: neighbors+blinker+sync+conv+mode (10290 tests)
- Test files are `SPARK_Mode => Off` (test infrastructure is not formally proved)
- Demo (`demo/demo_life.adb`) is also `SPARK_Mode => Off` by design -- it is
  a terminal application that instantiates generics, not a formal verification
  target. It covers 3-replica Game of Life synchronization using LWW sets and
  RGA sequences across all sequence engines (Yjs, Naive, Fugue) and clock
  strategies (Lamport, Vector, Matrix).

### Documentation

- **API docs**: Doc comments in `.ads` files using `--  @param`, `--  @return`, `--  @field`, `--  @formal` annotations. Generated via `make doc` which runs `gnatdoc` -> RST -> `tools/rst2md.py` -> `docs/api-docs/`. Now documents **both public and private** entities (`--generate private`). **This is the extended source of truth** for all subprograms, types, and interfaces.
- **Changelogs**: Hand-written per-version in `docs/changelogs/crdt-X.Y.Z.md`. Auto-indexed via `make doc`.

  **Changelog convention** -- one canonical format applies to every
  `crdt-X.Y.Z.md` (past, present, and future), machine-enforced by
  `make changelog-check` (`tools/check-changelog.py`) and run as part of
  `make compliance`. The format below is the single enforced format; the
  sibling `adacovex` project's changelogs use the same C#/H# style.

- **Architecture tree**: `make agents-tree` regenerates the ASCII source tree
  in this file from `tools/agents-tree.map` (add entries for new files).
- **Doc links**: `make doc-links` regenerates the Documentation block below
  from `tools/doc-links.map` (add entries for new docs).
- **Quick Reference**: `make doc` also regenerates the README Quick Reference
  table from `docs/api-docs/` via `tools/gen-quickref.py`.

<!-- doc-links:begin -->
- [API reference](docs/api-docs/index.md)
- [DO-178C compliance](docs/compliance/index.md)
- [PSAC (Plan for Software Aspects of Certification)](docs/compliance/PSAC.md)
- [High-Level Requirements](docs/compliance/HLR.md)
- [Low-Level Requirements](docs/compliance/LLR.md)
- [Traceability matrix](docs/compliance/TRACE.md)
- [Verification results](docs/compliance/VERIFICATION.md)
- [Changelogs](docs/changelogs/index.md)
- [V1->V2 Migration guide](docs/changelogs/crdt-1.4.0-migration.md)
- [Proof ledger (gnatprove 16.1.0)](docs/proof/16.1.0-ledger.md)
- [Readme](README.md)
- [Contributing](CONTRIBUTING.md)
- [Agent guide](AGENTS.md)
<!-- doc-links:end -->
  - **Naming**: one file per released version: `crdt-1.7.0.md`,
    `crdt-1.7.1.md`, `crdt-1.8.0.md`. A patch release file sorts between the
    surrounding minors. The file is written when a release is prepared; work
    toward the *next* version goes into the not-yet-cut changelog file only.
  - **Header**: `### CRDT X.Y.Z` as the first line, followed by a blank line,
    `Date: _YYYY-MM-DD_` (italic), a blank line, and a 2-4 sentence summary of
    the release's theme. No title above the `###` header; no other header
    lines.
  - **Sections**: exactly these `##` sections, in this order, using only those
    relevant to the release (omit, do not stub out, unused topical sections):
    `## Changes` (numbered `### C1:`... subsections), `## Fixes` (numbered
    `### H1:`... subsections; at least one of Changes/Fixes must be present),
    then the mandatory closers `## Test Suite`, `## Proof Results`,
    `## Traceability`, `## Breaking Changes`, and `## Version` (always
    present, in that order, at the end of the file). Sub-topics under
    Changes/Fixes use `### C#:` / `### H#:` numbered subsections with
    Title-Case headings, numbered sequentially from 1 within each section
    (C1..Cn, H1..Hn); lists and detail lines indent with 3 spaces; proof/test
    statistics are presented as Markdown tables.
  - **Test Suite**: mandatory; reports the passing test count for the release
    (e.g. `10290 tests passing`) and any new tests added.
  - **Proof Results**: mandatory; reports SPARK proof statistics for the
    release (total/proved/justified/unproved VCs), as a table where multiple
    numbers are reported.
  - **Traceability**: mandatory; lists the HLR tags relevant to the release
    and notes any HLRs added/removed (e.g. `24 HLR tags (unchanged)`),
    or states that no HLRs existed yet for early versions.
  - **Breaking Changes**: always present. Write `None.` followed by a short
    justification sentence when nothing breaks; otherwise a `-` bullet list.
  - **Version**: always present as the last section, containing exactly
    `Bumped from A.B.C to X.Y.Z.`.
  - **Accuracy**: every entry must describe a change that is actually present
    in that release and must not duplicate a change that already shipped in an
    earlier release (verify against git; a fix belongs in the changelog of the
    version that introduced it). Proof/test statistics must match `make prove`
    / `make verify-report` output.
  - **Style**: ASCII-only, `--` for dashes, no emoji, no smart quotes.
    Headings use Title Case; section text uses sentence case.
- **README**: Hand-written, mirrors Codeberg repo page. Provides a high-level overview; **consult generated API docs** (`docs/api-docs/index.md`) for complete interface reference. Code examples in README are illustrative; the generated API docs should be considered authoritative for exact signatures and usage. The `### Quick Reference` table is generated from `docs/api-docs/` by `tools/gen-quickref.py` (regenerated by `make doc`).
- **Compliance**: DO-178C artifacts in `docs/compliance/`. HLRs/LLRs are hand-written and must stay in sync with source code. `make compliance` validates HLR tag consistency.
- **Private interface warnings**: Private items in `.ads` files carry a docstring warning that they may change between minor versions and are not part of the stable public API.

### SPARK Formal Verification

**SPARK Gold** is always targeted: full absence-of-runtime-errors (AoRTE)
proved for all SPARK-analyzable code, plus key functional contracts (pre/post,
depends, type invariants) on core packages. Generics (`Rga`, `Lww_Element_Sets`,
`Lww_Sets`, sequence engines) are skipped by SPARK and platform dependencies
(wall clock, RNG, stream I/O) cannot be formally proved; these are excluded
by design from the proof target.

**SPARK Platinum** (full functional requirements across all SPARK-analyzable
units) is pursued on a best-effort basis above the Gold baseline. Platinum is
an ideal achievement reflecting the current state of proof. It is not a
permanent guarantee -- compiler upgrades, dependency changes, or new features
may introduce unproved checks in platform-dependent code that cannot be
resolved. The badge and documentation are updated per release to match
whatever level the proof campaign actually attains.

- **SPARK_Mode** applied at package level: `package Foo with SPARK_Mode is`
- Packages with impure operations (stream I/O, random, wall-clock) scope `SPARK_Mode => Off` to individual subprograms/bodies
- **Proof stats** auto-generated in `docs/compliance/VERIFICATION.md` by
  `make compliance` (reads `obj/gnatprove/gnatprove.out` and `test_result.md`).
- **SPARK levels achieved**: Stone (valid subset) OK, Bronze (flow analysis) OK,
  Silver (AoRTE) OK, **Gold (always targeted) OK**, Platinum (full functional
  requirements) OK on a best-effort basis -- all SPARK-analyzable units fully
  proved with 0 unproved checks in the current release.
- `make prove` runs `alr gnatprove` to check; `make compliance` regenerates
  the verification report from the proof output.
- **SPARK_Mode => On** (package-level) on all core specs. Per-subprogram Off only for:
  - Stream I/O (`Read_Clock`, `Write_Clock`, serialization routines)
  - Wall-clock access (`HLC.Create`, `HLC.Tick`, `HLC.Recv`)
  - Random number generation (`New_Replica_Id`, RNG child package)
  - Access type manipulation (RGA/Yjs/Naive/Fugue engine bodies)
- Key `SPARK_Mode => Off` justifications:
  - `Ada.Numerics.Discrete_Random` (RNG) -- `New_Replica_Id`
  - `Ada.Calendar.Clock` (wall-clock) -- HLC `Create`/`Tick`/`Recv`
  - Stream I/O -- Write/Read serialization routines
  - Access types -- RGA/Naive/Fugue engine bodies

### DO-178C Artifacts

Artifacts in `docs/compliance/`:
- `docs/compliance/PSAC.md` -- Plan for Software Aspects of Certification (DAL-C scope, lifecycle, verification strategy)
- `docs/compliance/HLR.md` -- High-Level Requirements with source file references
- `docs/compliance/LLR.md` -- Low-Level Requirements mapped to Ada subprograms
- `docs/compliance/TRACE.md` -- Bidirectional traceability matrix
- `docs/compliance/VERIFICATION.md` -- SPARK proof stats + test results
- `docs/compliance/index.md` -- Overview, DAL-C scope
- HLR tags in source: `--  - HLR-XXXX: description` (comments in `.ads` file headers)
- New features must add corresponding HLRs/LLRs and HLR tags
- `make compliance` must pass before release

### Changelog & Doc Generation

All generated by `make doc`:
1. `gnatdoc` reads `.ads` files, generates RST in `obj/gnatdoc-rst/`
2. `tools/rst2md.py` converts RST -> Markdown in `docs/api-docs/`
3. Test and internal packages are excluded from docs
4. `docs/changelogs/index.md` is regenerated from the `crdt-*.md` files

### Development vs Publishing Manifests

Two manifest files manage build tool dependencies:

- **`alire.toml`** -- clean publishing manifest. No dev-only dependencies. This
  is what gets published to the Alire community index.
- **`alire-dev.toml`** -- full development manifest with `gnatprove`, `gnatdoc_bin`, and
  `gnatformat_bin` dependencies. Used for local SPARK proof, doc generation, and formatting.

The dev targets (`make fmt`, `make doc`, `make prove`, `make coverage-gate`,
`make sbom`) swap `alire-dev.toml` over `alire.toml` for the duration of the
command and restore the clean publishing manifest afterwards, so no manual
switch is required. The `description` make target keeps both manifests'
`description` / `long-description` in sync with the canonical
`alire/description.txt` + `alire/long-description.txt`.

### Release Process

`make bump-version VERSION=1.7.0` prepares the release metadata without
committing:
1. Updates the version in `alire.toml`, `alire-dev.toml`, `demo/alire.toml`,
   and `AGENTS.md` (rejects non-semver, already-set, or older versions)
2. Creates/updates `alire/releases/crdt-{version}.toml` (copied from the most
   recent release manifest so `[origin]` carries forward)
3. Creates/updates `index/ad/crdt/crdt-{version}.toml`
4. Points the release manifest `[origin]` at the current commit and reminds
   you to write/validate `docs/changelogs/crdt-{version}.md`
   (`make changelog-check`)

`make release VERSION=1.7.0`:
1. Updates `alire.toml` and `alire-dev.toml` version
2. Creates/updates `index/ad/crdt/crdt-{version}.toml`
3. Creates/updates `alire/releases/crdt-{version}.toml`
4. Commits clean manifest, tags with `v{version}`, pushes
5. Prints reminder to run `make publish`
6. The pushed `v{version}` tag triggers `.github/workflows/release.yml`, which
   builds + tests, generates the SBOM, Sigstore-attests the release artifacts
   (`actions/attest@v4`), publishes the GitHub release with the source archive,
   and updates the floating `v#` / `v#.#` / `latest` tags

`make publish`:
1. Checks working tree is clean
2. Runs `alr publish` (auto-detects GitHub, publishes from clean `alire.toml`)

Dev-only dependencies (`gnatprove`, `gnatdoc_bin`, `gnatformat_bin`) are in `alire-dev.toml` only,
so they never appear in the published index.

### ASCII Charset Enforcement

All source files (`.ads`, `.adb`, `.md`, `.py`, `.toml`, `.gpr`, `.yaml`, `.yml`)
MUST contain only ASCII characters (0x00-0x7F). Enforced by `make ascii-check`.
Non-ASCII characters (smart quotes, em-dashes, non-breaking spaces, UTF-8
multibyte sequences) are forbidden even in comments and documentation.

To check manually:
`LC_ALL=C grep -rn '[^ -~'$'\t'']' . --include='*.ads' --include='*.adb' ...`
