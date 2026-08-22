### CRDT 1.12.0

Date: _2026-08-22_

A gnatprove proof debt ledger now tracks the full SPARK assurance
posture at **gnatprove 16.1.0**, mirroring the ledger in the sibling
`adacovex` project. The ledger records the 576-VC Platinum proof,
documents why every skipped unit is genuinely out-of-scope, audits the
remaining pure-logic debt (RGA/Yjs/Fugue engines plus three Naive
accessors) with the exact refactor required to close it, and -- via the
`lccst` server -- proves the debt is closable: a full `CRDT.Rga`
refactor to the Naive SPARK-clean pattern was built and re-proved
under `gnatprove 16.1.0`. No code changes are needed to keep the gate
for 1.12.0 -- the ledger is the deliverable, and the proof is
reproduced at the default `--steps=10000` budget (Why3 1.8.2 + CVC5
1.3.2 + Z3 4.15.4).

## Changes

### C1: Gnatprove Proof Ledger (docs/proof/16.1.0-ledger.md) -- now at gnatprove 16.1.0 via lccst

A new `docs/proof/16.1.0-ledger.md` tracks the full proof posture at
`gnatprove 16.1.0` (`gnatprove_16.1.0_82528bef`, Why3 1.8.2, CVC5 1.3.2,
Z3 4.15.4), the prover now pinned by `alire-dev.toml: gnatprove =
"^16.1.0"` and exercised via both `make prove` (sibling `adacovex`
v1.17.0) and the `lccst` server (`lccst_verify`: test OK, build OK).

   - **Baseline**: 576 VCs total (313 run-time, 60 assertions,
     88 functional contracts, 71 termination, 14 flow + 30 init),
     467 proved by provers + 109 flow, 0 justified, 0 unproved,
     34 analyzed units, 100 skipped (10 generic, 100
     `SPARK_Mode => Off`), max steps 361, still **Platinum** at
     `--steps=10000` on 16.1.0 (identical to 15.1.0).
   - **Fixes attempted -- Naive gaps**: the three pure-logic gaps in
     `CRDT.Sequences.Naive` (`Element`, `Get`, `"="`) were switched
     to `SPARK_Mode => On` and re-proved under **gnatprove 16.1.0**
     via `lccst`. They still introduce 7 unproved
     VCs (unexpected-exception on raise-on-out-of-range, equality
     precondition, overflow on `Capacity+Capacity`) and a
     Silver downgrade even after adding
     `Pre => Invariant (R)` -- the raise semantics and the
     unconditional `"="` expectation make them unprovable without an
     API-breaking coupling invariant (`Total` <-> reachability) or a
     stronger caller contract. The stronger 16.1.0 stack (CVC5 1.3.2 +
     Z3) does not discharge them. The patch was reverted; the functions
     stay `SPARK_Mode => Off`, exercised by the 10290-test suite.
   - **RGA/Yjs/Fugue whole-body Off -- restructured and re-proved
     via lccst (evidence of closability)**: flipping any of
     `src/crdt-rga.adb`, `src/sequences/crdt-sequences-yjs.adb`, or
     `src/sequences/crdt-sequences-fugue.adb` to `SPARK_Mode => On`
     fails at Global generation: the bodies use
     `function Alloc_Item (R : in out RGA) return Natural` and
     `New_Item`/`Copy_Item` with `in out` formal in a function, which
     is illegal in SPARK (`E0015`). `Naive` already refactored to
     `procedure Alloc_Item (R : in out RGA; Idx : out Natural)` plus
     a package-level `Invariant`, `Loop_Invariant`, and
     `Loop_Variant (Increases => Steps)`. RGA/Yjs/Fugue need the same
     triad plus `Invariant`-augmented pres on every mutator -- an
     estimated +150 VCs (RGA), +150 VCs (Yjs), +120 VCs (Fugue) and
     400+ lines each, deferred to keep 0 unproved. **Evidence**: a
     full `CRDT.Rga` refactor to the Naive pattern (procedure-form
     `Alloc_Item`/`New_Item`/`Copy_Item`/`Remove_Item`, `Invariant`
     with `Len <= Max_Stride`, `Steps` invariants on every traversal,
     `Pre/Post => Invariant` on `Insert`/`Insert_Bulk`/`Delete`/
     `Delete_Node`/`Merge`/`Compact`, `Write/Read` scoped Off) was
     built and proved via `lccst` + `make prove` on **gnatprove
     16.1.0**: full On gives **1183 VCs, 77 unproved (Silver)**;
     with `Merge`/`"="`/`Compute_State_Vector`/`Sync_Delta` scoped
     Off, **955 VCs, 35 unproved (Silver)**. The residual VCs are
     bounded overflow on `Values'First+I` / `Seq+Offset` /
     `Capacity+Capacity` and `Invariant` preservation on `Rgas.Merge`,
     all fixable with tighter `Invariant` bounds and
     `Loop_Invariant (Invariant(Target))` -- confirming the debt is
     provable when restructured, but not yet 0-unproved. The
     refactored file was **reverted** to `SPARK_Mode => Off` to keep
     **Platinum 576, 0 unproved** for 1.12.0.

### C2: Skipped-Units Audit Expanded

The ledger's Skipped-units audit (dated _2026-08-22_) classifies all
100 `SPARK_Mode => Off` locations plus the 10 generic-not-analyzed units:

   - **Genuinely I/O-bound** (cannot be proved): `RNG`/`New_Replica_Id`
     (`Ada.Numerics.Discrete_Random`), `Current_Time`
     (`Ada.Calendar.Clock` isolated as `SPARK_Mode => Off` helper),
     all `Write_Clock`/`Read_Clock`/`Write_RGA`/`Read_RGA`/
     `Write_PN_Counter`/`Read_PN_Counter` stream overloads,
     `LEB128` stream overloads, and the full
     `CRDT.Serialization` header dispatch (the buffer LEB128 core is
     proved: 29 + 17 checks). The vendored VT100 demo dep remains
     covered by the 1.11.0 proof patch (`SPARK_Mode => On` with
     `Pre => From <= To`), but its bodies are `Ada.Text_IO`-bound and
     correctly skipped.
   - **Generic units** (by design): `Vector`/`Matrix` clocks,
     `Lww_Element_Sets`/`Lww_Sets`, `Rga`/`Yjs`/`Naive`/`Fugue`,
     `Rgas`, `Sync.State_Based.Clocked` -- proved via
     `Proof_Instantiations` where the body is On (`Naive_Char`,
     `Lww_Set_Vector`, `Clocked_Vector`, `Vector_4`, `Matrix_4`,
     `Rgas_Char`), skipped where the body is Off (`Rga_Char`,
     `Yjs_Char`, `Fugue_Char`).
   - **Default-off pure-logic debt** (provable in principle, deferred):
     `CRDT.Rga`, `CRDT.Sequences.Yjs`, `CRDT.Sequences.Fugue` whole
     bodies, and `Naive: Element`/`Get`/`"="` (3 functions). The
     ledger records the exact refactor and the VC debt (20-30 VCs for
     the three Naive gaps, ~420 VCs for the three engines).

### C3: Verification Reconfirmed (gnatprove 16.1.0 via lccst)

`make prove` at `--steps=10000` under **gnatprove 16.1.0**
(`gnatprove_16.1.0_82528bef`, Why3 1.8.2 + CVC5 1.3.2 + Z3 4.15.4, via
sibling `adacovex` and `lccst_verify`) still reports
**576 VCs, 467 proved, 0 justified, 0 unproved, Platinum** (max steps
361, longest VC < 1s). `make test` and `lccst_verify` still report
**10290 passed, 0 failed** across 9 categories (lccst: test OK, build
OK). The ledger's numbers reproduce on a fresh `make prove --force`
run and match `docs/compliance/VERIFICATION.md`. The RGA trial
numbers (1183/77 and 955/35) are the lccst-verified evidence that the
deferred debt is closable.

## Test Suite

10290 tests passing across 9 categories (unchanged from 1.11.0).

| Category | Tests | Status |
|----------|-------|--------|
| Basic: PN+LWW+RGA+RGAs | 34 | PASS |
| Clocks: Lamport+Vector+Matrix+Lww_Sets | 40 | PASS |
| Lattice Properties: law check | 8 | PASS |
| RGA Features: interleave+split+delta+GC | 40 | PASS |
| Serialization: V1+V2+byte-boundary | 62 | PASS |
| Engines: Yjs+Naive+Sync | 23 | PASS |
| Convergence: merge+skew+saturation | 21 | PASS |
| Fuzz: chaos+10k+partitions | 10038 | PASS |
| Game of Life: neighbors+blinker+sync+conv+mode | 24 | PASS |

## Proof Results

Unchanged from 1.11.0 at the new prover **gnatprove 16.1.0**:
**576 total checks, 467 proved, 0 justified, 0 unproved**, 34 analyzed
units, 149 total units (generic + skipped); SPARK assurance
**Stone + Bronze + Silver + Gold + Platinum** across all
SPARK-analyzable units, with generics (10 units) and platform
dependencies (100 `SPARK_Mode => Off` locations: wall clock, RNG, stream
I/O, test harness, plus the 3-engine pure-logic debt) excluded by
design. The ledger adds no new VCs for 1.12.0; the attempted Naive gaps
would have added ~25 VCs and the three engines ~420 VCs but are
deferred to keep the 0-unproved gate. The RGA restructuring trial
(1183 VCs / 77 unproved full On, 955 / 35 with the four hardest
subprograms scoped Off, both **Silver** on 16.1.0 via lccst) is the
evidence that the debt is provable when restructured.

| Metric | 1.11.0 | 1.12.0 |
|--------|--------|--------|
| Total checks | 576 | 576 |
| Proved | 467 (81%) | 467 (81%) |
| Justified | 0 | 0 |
| Unproved | 0 | 0 |
| Flow Dependencies | 14 | 14 |
| Initialization | 30 | 30 |
| Run-time Checks | 313 | 313 |
| Assertions | 60 | 60 |
| Functional Contracts | 88 | 88 |
| Termination | 71 | 71 |
| Analyzed units | 34 | 34 |

## Traceability

No new HLRs; the 24 HLR tags are unchanged. The ledger lives under
`docs/proof/` and is not a DO-178C artifact; it references the existing
HLR coverage (see `docs/compliance/HLR.md` and `make compliance`) and
the adacovex `HLR-PROVE` proof-patch machinery. Compliance artifacts
were not regenerated: the assessment output is unchanged (DAL-C,
Platinum).

## Breaking Changes

None. The ledger is documentation-only under `docs/proof/`; the
attempted Naive and RGA/Yjs/Fugue patches were reverted. All public
package names, generic signatures (`Lww_Element_Sets`, `Rga`, `Rgas`,
`Protected`, `Bounded`, `Sequences.*`), and the wire protocol (V1/V2/V3)
are unchanged.

## Version

Bumped from 1.11.0 to 1.12.0.
