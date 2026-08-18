### CRDT 1.10.0

Date: _2026-08-17_

Full SPARK proof completion: every previously justified (false-positive
annotated) check is now proved outright, eliminating the last 42 justified
VCs. The core library reaches **576 checks -- 467 proved, 0 justified, 0
unproved**, with functional contracts grown to 88/88. This release also fixes
`make doc` (dev-manifest swap for gnatdoc), `make clean` (no longer deletes
the hand-maintained TRACE.md), and `make prove` (forces a fresh gnatprove run
when the proof output is missing).

## Changes

### C1: All Justified Checks Now Proved

Every `pragma Annotate (GNATprove, False_Positive, ...)` remaining after 1.9.0
has been eliminated -- the 42 justified VCs from 1.9.0 are all discharged as
real proofs, giving **576 total checks, 467 proved, 0 justified, 0 unproved**
(down from 584/435/42/0 in 1.9.0).

- **HLC** (`src/core/crdt-hlc.adb`): the four "HLC Log bounded in practice"
  overflow justifications are replaced with saturating arithmetic, e.g.
  `Clock.Log := (if Clock.Log = Natural'Last then Natural'Last else Clock.Log + 1)`
  in `Tick` and all three `Recv` branches.
- **PN-Counter** (`src/crdt-pn_counters.adb`): the four "Counter_Range /
  Long_Long_Integer bounded in practice" justifications are replaced with
  saturation guards in `Value`, `Increment`, and `Decrement`.
- **LWW_Clocked_Set** (`src/crdt-lww_sets.adb`): the four "LWW set size
  bounded by Capacity" overflow/index justifications are replaced with
  capacity guards (`if S.Add_Size < S.Capacity` / `if S.Remove_Size <
  S.Capacity`) in `Add` and `Remove`.
- **Naive engine** (`src/sequences/crdt-sequences-naive.*`): all
  `Always_Terminates` false positives are removed; the linked-list traversals
  (`Find_Last`, `Find_Node`, `Find_Insertion_Before`, `Find_Pos`) now carry a
  bounded `Steps` counter with `Loop_Variant (Increases => Steps)` and
  `exit when ... or else Steps >= R.Capacity` so SPARK proves termination
  directly.
- **Naive accessors**: `Element` and `Get` are scoped `SPARK_Mode => Off`
  (they deliberately raise `Constraint_Error` on out-of-range positions),
  removing the two "deliberate range check on accessor" unexpected-exception
  justifications.

### C2: Naive Engine Structural Invariant

`src/sequences/crdt-sequences-naive.ads` exposes a public
`function Invariant (R : RGA) return Boolean` describing the engine's
structural safety condition, and the mutators now carry
`Pre => Invariant (R), Post => Invariant (R)` contracts (`Insert`,
`Insert_Bulk`, `Delete`, `Delete_Node`, and friends). This lets SPARK track
the structural invariant across every entry/exit point instead of relying on
false-positive annotations.

### C3: Stream Access Parameter Relaxation

All serialization `Read_*` / `Write_*` stream parameters changed from
`not null access Ada.Streams.Root_Stream_Type'Class` to plain
`access Ada.Streams.Root_Stream_Type'Class` in `Rga`, `Lww_Sets`, and the Yjs,
Naive, and Fugue engines. The 11 "null exclusion check might fail" stream
justifications from 1.9.0 disappear: the plain access type carries no null
exclusion, so there is no check to justify. The Ada runtime always passes a
non-null stream to `'Read`/`'Write` attributes, so behavior is unchanged.

### C4: Release Metadata Completion

`alire/releases/crdt-1.9.0.toml` gained an `[origin]` section (commit + URL),
completing the release metadata for downstream publishing. The published
manifest now carries **no** `executables` entry: the `test_crdt` test-suite
binary is a development artifact, so the executable declaration lives only in
`alire-dev.toml` (the GPR's `for Main` still builds it in CI).

### C5: Documentation Regeneration

`docs/api-docs/crdt-sequences-naive.md` and
`docs/api-docs/crdt-spark-coverage.md` were regenerated to reflect the new
`Invariant` function, the `Pre`/`Post` contracts on Naive mutators, the
`SPARK_Mode => Off` scoping on `Element`/`Get`, and the stream-parameter
relaxation. `docs/compliance/VERIFICATION.md` and
`docs/compliance/index.md` were regenerated with the new proof statistics
(0 justified checks).

### C7: Quick Reference Auto-Regeneration

The README `### Quick Reference` documentation table is now generated instead
of hand-maintained: `tools/gen-quickref.py` reads each component's package
name from `docs/api-docs/*.md` and rewrites the table (failing if a referenced
doc is missing), and the `make doc` / `api-docs` target runs it after gnatdoc
so the table cannot drift from the generated docs.

### C8: GitHub Release Attestation (SLSA)

A new `.github/workflows/release.yml` runs on `v*` tags: it builds and tests
the crate, runs the SPARK proof gate via the `bladeacer/adacovex@v1` action
(Platinum, 100% docstrings, 10290 tests, 0 unproved), and generates the
proof-aware SBOM. The release artifacts (source archive, SBOM, test results)
are attested with Sigstore `actions/attest@v4` and published via
`gh release create` with changelog links and the attestation URL; the release
also updates the floating `v#` / `v#.#` / `latest` tags. Issue templates are
now enforced via `.github/ISSUE_TEMPLATE/config.yml` (blank issues disabled),
and a `.github/PULL_REQUEST_TEMPLATE.md` guides PRs through the DO-178C and
backward-compatibility gates.

### C6: SBOM and Badges Regeneration

`sbom.json` regenerated (proof level Platinum, DAL-C) with the updated proof
statistics. `docs/badges/*.svg` regenerated via `make prove` (proof level
Platinum, DAL-C Achieved).

## Fixes

### H1: make doc Fixed

The `doc` / `api-docs` target ran `alr exec -- gnatdoc` against the clean
publishing manifest (`alire.toml`), which does not declare `gnatdoc_bin` --
`make doc` failed with "Executable not found in PATH when spawning: gnatdoc".
The target now swaps `alire-dev.toml` over `alire.toml` for the gnatdoc
invocation and restores the clean manifest afterwards, using the same
auto-swap pattern as `fmt`, `prove`, and the covex targets.

### H2: make clean No Longer Deletes TRACE.md

`make clean` deleted `docs/compliance/TRACE.md`, which is a committed,
hand-maintained artifact (no Makefile target or tool regenerates it). After
`make clean`, `make compliance` would fail with "MISSING: TRACE.md". The
target now removes only regenerable artifacts (`obj/`, `lib/`,
`docs/badges/`, `docs/api-docs/`, `docs/compliance/VERIFICATION.md`).

### H3: make prove Forces Fresh Proof When Output Missing

adacovex's result cache short-circuits to "reuse prior proof" whenever the
source inputs are unchanged. After `make clean` deletes
`obj/gnatprove/gnatprove.out`, the cache marker still exists but the proof
output does not, so `make prove` reported Stone (0 VCs) and failed. The
target now passes `--force` to adacovex when `obj/gnatprove/gnatprove.out`
is missing, forcing a real gnatprove run (the cache still serves unchanged
projects with proof output in place).

## Test Suite

10290 tests passing across 9 categories (unchanged from 1.9.0).

## Proof Results

| Metric | 1.9.0 | 1.10.0 |
|--------|-------|--------|
| Total checks | 584 | 576 |
| Proved | 435 (74%) | 467 (81%) |
| Justified | 42 (7%) | 0 (0%) |
| Unproved | 0 | 0 |
| Run-time checks | 331 (294 proved) | 313 (313 proved) |
| Assertions | 58 | 60 |
| Functional contracts | 83 (83 proved) | 88 (88 proved) |
| Termination | 68 (63 proved) | 71 (65 proved) |
| Analyzed units | 152 analyzed | 149 analyzed |

SPARK assurance remains **Stone + Bronze + Silver + Gold + Platinum** across
all SPARK-analyzable units; generics (10 units) and platform dependencies
(100 `SPARK_Mode => Off` locations: wall clock, RNG, stream I/O, test
harness) remain excluded by design.

## Traceability

24 HLR tags (unchanged); compliance artifacts regenerated with the new proof
statistics. All changes are covered by the existing HLR set -- no new HLRs
added in this release.

## Breaking Changes

None. The `not null access` to `access` relaxation on stream parameters is
source-compatible: callers passing a `not null access` value to a plain
`access` parameter remain valid (the null-exclusion subtype check simply no
longer applies), and the `'Read`/`'Write` stream attributes behave
identically. All public package names, generic signatures, and the wire
protocol (V1/V2/V3) are unchanged.

## Version

Bumped from 1.9.0 to 1.10.0.
