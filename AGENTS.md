# CRDT Codebase Guide for AI Agents

## Project Purpose

A Conflict-Free Replicated Data Types (CRDT) library for Ada/SPARK, providing
PN-Counters, LWW-Element-Sets, RGA sequences, and clock-strategy-aware sync
layers. See [README.md](README.md) for a user-oriented overview.

## Codebase Structure

```
Ada_CRDT/
|-- alire.toml                  # Alire crate config (version, deps, metadata)
|-- crdt.gpr                    # GNAT project file (source dirs, compiler flags)
|-- Makefile                    # Build/test/doc/release/compliance targets
|-- AGENTS.md                   # This file -- conventions and codebase guide
|-- README.md                   # User-facing docs
|-- src/
|   |-- crdt.ads                # Root package (SPARK_Mode)
|   |-- crdt-lww_element_sets.* # LWW set (Lamport timestamps, backwards-compat)
|   |-- crdt-lww_sets.*         # Generic LWW set (any clock strategy)
|   |-- crdt-pn_counters.*      # PN-Counter
|   |-- crdt-rga.*              # RGA sequence (Yjs engine, default)
|   |-- crdt-rgas.*             # Multi-RGA container
|   |-- crdt-protected.*        # Thread-safe protected wrappers
|   |-- core/
|   |   |-- crdt-core.*         # Core types: Replica_Id, Lamport_Time, HLC_Time, VTime
|   |   |-- crdt-core-leb128.*  # LEB128 variable-length encoding
|   |   |-- crdt-hlc.*          # Hybrid Logical Clock
|   |   |-- crdt-clocks.*       # Clock strategy root
|   |   |-- crdt-clocks-lamport.*  # Lamport clock strategy
|   |   |-- crdt-clocks-vector.*   # Vector clock strategy
|   |   +-- crdt-clocks-matrix.*   # Matrix clock strategy
|   |-- sequences/
|   |   |-- crdt-sequences.*       # Sequence engine root
|   |   |-- crdt-sequences-yjs.*   # Yjs chunk engine
|   |   |-- crdt-sequences-naive.* # Flat linked-list engine
|   |   +-- crdt-sequences-fugue.* # BST anti-interleaving engine
|   |-- serialization/
|   |   |-- crdt-serialization.*      # Protocol version router (V1/V2/V3 detection)
|   |   +-- crdt-serialization-legacy.* # V1 fixed-width reader
|   |-- sync/
|   |   |-- crdt-sync.*                # Sync root (State_Vector type)
|   |   |-- crdt-sync-op_based.*       # Op-based (CmRDT) sync
|   |   |-- crdt-sync-state_based.*     # State-based (CvRDT) sync
|   |   +-- crdt-sync-state_based-clocked.* # Generic clock-strategy-aware sync
|   +-- tests/
|       |-- crdt-test_support.*    # Test runner utilities
|       |-- test_crdt.adb          # Main test harness
|       +-- test_*.ad[sb]          # Per-category test modules
|-- demo/
|   |-- alire.toml             # Demo Alire config (pins parent)
|   |-- crdt_demo.gpr          # Demo project file
|   |-- demo_life.adb          # Conway's Game of Life demo
|   +-- deps/vt100/            # Terminal VT100 library
|-- docs/
|   |-- compliance/            # DO-178C artifacts
|   |   |-- index.md           # Overview, DAL-C scope
|   |   |-- HLR.md             # High-Level Requirements (hand-written)
|   |   |-- LLR.md             # Low-Level Requirements (hand-written)
|   |   |-- TRACE.md           # Bidirectional traceability (auto-populated, manually verified)
|   |   +-- VERIFICATION.md    # SPARK + test results (hand-updated per release)
|   |-- api-docs/              # Generated Markdown API docs (via `make doc`)
|   +-- changelogs/            # Version-specific changelogs
|       |-- index.md           # Auto-generated index of changelogs
|       +-- crdt-*.md          # Per-version changelogs (hand-written)
|-- config/                    # Alire-generated Ada/GPR config (do not hand-edit)
|-- index/                     # Local Alire crate index (release metadata)
|-- alire/                     # Alire internal state (releases/, flags/, etc.)
+-- tools/
    +-- rst2md.py              # Converts gnatdoc RST output to Markdown
```

## Build System

### Makefile Targets

| Target | What it does | How it works |
|--------|-------------|--------------|
| `build` | Compile library + tests | `alr build` (filters out `.sframe` linker noise) |
| `run` / `test` | Build + run test suite | `alr run` (all 10290+ tests) |
| `prove` | SPARK formal verification | `alr gnatprove` |
| `doc` / `api-docs` | Generate Markdown API docs | `gnatdoc` -> RST -> `tools/rst2md.py` -> `docs/api-docs/` |
| `compliance` | Verify DO-178C traceability | Scans source HLR tags, validates HLR.md coverage |
| `ascii-check` | Enforce ASCII-only charset across source files | `LC_ALL=C grep` for bytes > 0x7E |
| `release` | Tag + publish new version | Updates metadata, commits, tags, pushes |
| `publish` | Publish to Alire community index | Archives source, pushes to community index |
| `demo` | Build + run Game of Life demo | `cd demo && alr build && ./demo_life` |
| `clean` | Remove build artifacts | `alr clean; rm -rf obj/ lib/ docs/` |

### Alire (Ada Package Manager)

- Primary build tool: `alr build` / `alr run` / `alr gnatprove`
- Dependencies managed in `alire.toml` (currently: `gnatprove`, `gnatdoc_bin`)
- GNAT toolchain managed automatically by Alire
- Version: defined in `alire.toml` (currently 1.7.0), mirrors in `index/ad/crdt/` and `alire/releases/`

### Compiler Flags (from `crdt.gpr`)

- `-gnat12` -- Ada 2012 language standard (DO-178C baseline; Ada 2022 features
  not yet required for DAL-C certification objectives)
- `-gnata` -- Assertions enabled (for SPARK contracts at runtime)
- `-gnatwa` -- All warnings
- `-gnatwF` -- Warnings on unreferenced formal parameters
- `-gnatwsh` -- Warnings on suspicious contract

## Safety and Memory Safety

- **No heap allocation** for CRDT data -- all containers (`PN_Counter`,
  `LWW_Element_Set`, `RGA`, `LWW_Clocked_Set`) use pre-allocated bounded storage
  sized at instantiation time. The `CRDT.Bounded` wrapper eliminates heap use
  entirely.
- **SPARK-proofed core**: `CRDT.Core`, `CRDT.Pn_Counters`, `CRDT.Lww_Element_Sets`,
  clock strategy packages, and `CRDT.HLC` run in `SPARK_Mode`. Proved absence of
  runtime errors (index checks, overflow, division by zero) within those
  boundaries. 269 SPARK checks proved as of 1.6.0.
- **Runtime error elimination** in generic bodies (RGA/Yjs/Naive/Fugue, Lww_Sets)
  depends on the instantiation's discriminant values; the `-gnata` flag enables
  assertion checking at runtime for defensive coverage.
- **Bounded storage everywhere**: generic `Max_Items`, `Max_Replicas`,
  `Max_Set_Size`, `Capacity` discriminants prevent unbounded growth.
- **No access-to-object aliasing**: access types are confined to sequence engine
  bodies (`SPARK_Mode => Off`), with explicit bounds checks at every dereference.

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
  - Every source HLR tag has a corresponding entry in `HLR.md`
  - Every HLR in `HLR.md` has a matching source tag (no orphans)
  - All compliance artifacts (`HLR.md`, `LLR.md`, `TRACE.md`, `index.md`) exist
- DAL-C implications for this codebase:
  - Requirements are stated (HLR.md) and refined (LLR.md) but DO NOT require
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
| `CRDT.Core.VTime_Less`, `VTime_Leq`, `VTime_Eq`, `VTime_Merge`, `VTime_Increment` | Used by `CRDT.Sync.State_Based` and `CRDT.Clocks.Vector` | Yes |
| `CRDT.Core.HLC_Less`, `HLC_Eq`, `HLC_Max` | Used by `CRDT.HLC` child package | Yes |
| `CRDT.Core.Lamport_Max` | Used by `CRDT.Clocks.Lamport` | Yes |
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
- Wire protocol is versioned (`Protocol_Version` constant). V1 readers can read V2 data.
  V2 readers can read V3 data (Lamport fields + clock type extension).
  V3 readers can read all V1, V2, and V3 data.
- Breaking changes require a major version bump
- Internal interfaces (see table above) are excluded from the guarantee

Exception: wire format V1 -> V2 migration (1.4.0) was a one-time breaking change,
fully documented with a migration guide.

## Conventions

### Naming

- **Ada packages**: `CRDT.Sync.State_Based`, `CRDT.Clocks.Lamport` -- hierarchical, PascalCase
- **Source files**: snake_case matching the child package: `crdt-sync-state_based.ads`
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
- Main harness: `test_crdt.adb` orchestrates all test modules
- Test results written to both stdout and `test_result.md`
- **40 tests** for clock strategies (10 per strategy x 3 = Lamport/Vector/Matrix, plus Lww_Sets variants)

### Documentation

- **API docs**: Doc comments in `.ads` files using `--  @param`, `--  @return`, `--  @field`, `--  @formal` annotations. Generated via `make doc` which runs `gnatdoc` -> RST -> `tools/rst2md.py` -> `docs/api-docs/`
- **Changelogs**: Hand-written per-version in `docs/changelogs/crdt-X.Y.Z.md`. Auto-indexed via `make doc`.
- **README**: Hand-written, mirrors Codeberg repo page
- **Compliance**: DO-178C artifacts in `docs/compliance/`. HLRs/LLRs are hand-written and must stay in sync with source code. `make compliance` validates HLR tag consistency.

### SPARK Formal Verification

- **SPARK_Mode** applied at package level: `package Foo with SPARK_Mode is`
- Packages with impure operations (stream I/O, random, wall-clock) scope `SPARK_Mode => Off` to individual subprograms/bodies
- All 269 SPARK checks proved (fully proved codebase as of 1.6.0)
- `make prove` runs `alr gnatprove` to check
- Key `SPARK_Mode => Off` justifications:
  - `Ada.Numerics.Discrete_Random` (RNG) -- `New_Replica_Id`
  - `Ada.Calendar.Clock` (wall-clock) -- HLC `Create`/`Tick`/`Recv`
  - Stream I/O -- Write/Read serialization routines
  - Access types -- RGA/Naive/Fugue engine bodies

### DO-178C Artifacts

Artifacts in `docs/compliance/`:
- `HLR.md` -- High-Level Requirements with source file references
- `LLR.md` -- Low-Level Requirements mapped to Ada subprograms
- `TRACE.md` -- Bidirectional traceability matrix
- `VERIFICATION.md` -- SPARK proof stats + test results
- `index.md` -- Overview, DAL-C scope
- HLR tags in source: `--  - HLR-XXXX: description` (comments in `.ads` file headers)
- New features must add corresponding HLRs/LLRs and HLR tags
- `make compliance` must pass before release

### Changelog & Doc Generation

All generated by `make doc` / `make api-docs`:
1. `gnatdoc` reads `.ads` files, generates RST in `obj/gnatdoc-rst/`
2. `tools/rst2md.py` converts RST -> Markdown in `docs/api-docs/`
3. Test and internal packages are excluded from docs
4. `docs/changelogs/index.md` is regenerated from the `crdt-*.md` files

### Release Process

`make release VERSION=1.7.0`:
1. Updates `alire.toml` version
2. Creates/updates `index/ad/crdt/crdt-{version}.toml`
3. Creates/updates `alire/releases/crdt-{version}.toml`
4. Commits all changes, tags with `v{version}`, pushes

`make publish`:
1. Checks working tree is clean
2. Runs `alr publish` with archive URL
3. Cleans up and pushes to Alire community index

### ASCII Charset Enforcement

All source files (`.ads`, `.adb`, `.md`, `.py`, `.toml`, `.gpr`, `.yaml`, `.yml`)
MUST contain only ASCII characters (0x00-0x7F). Enforced by `make ascii-check`.
Non-ASCII characters (smart quotes, em-dashes, non-breaking spaces, UTF-8
multibyte sequences) are forbidden even in comments and documentation.

To check manually:
`LC_ALL=C grep -rn '[^ -~'$'\t'']' . --include='*.ads' --include='*.adb' ...`
