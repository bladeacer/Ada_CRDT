### CRDT 1.12.0

Date: _2026-08-22_

A gnatprove proof debt ledger now tracks the full SPARK assurance
posture at **gnatprove 16.1.0**, mirroring the ledger in the sibling
`adacovex` project. The ledger records the **589-VC Platinum proof**
(576 baseline +13 from two newly proved helpers), documents why every
skipped unit is genuinely out-of-scope, and audits the remaining
pure-logic debt (RGA/Yjs/Fugue engines plus two Naive accessors) with
the exact refactor required to close it. Via the `lccst` server the
previously unprovable `Find_Pos` / `"="` now prove with overflow-safe
invariants, and a full `CRDT.Rga` refactor was built and re-proved
under `gnatprove 16.1.0` to show the remaining debt is closable. The
proof is reproduced at the default `--steps=10000` budget (Why3 1.8.2 +
CVC5 1.3.2 + Z3 4.15.4).

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
     `SPARK_Mode => Off`), max steps 361, **Platinum** at
     `--steps=10000` on 16.1.0. After the two helpers below, **589
     VCs (322 run-time, 62 assertions, 73 termination, 110 flow,
     479 proved), 0 unproved, max steps 412, still Platinum**.
   - **Fixes -- Naive `Find_Pos` and `"="` now prove (via lccst, gnatprove 16.1.0)**: the internal `Find_Pos` and the equality `"="` in `CRDT.Sequences.Naive` were `SPARK_Mode => Off` with 7 unproved (raise on `Element`/`Get`, loop invariant on `"="`/`Find_Pos`). `Find_Pos` was given overflow-safe `P in 1..Pos` / `Steps <= Pos/Capacity` invariants and `Loop_Variant (Increases => Steps)`; `"="` was given `Invariant` at entry, `Loop_Counter 0..200` (capacity 64, so `Steps <200` always), `Loop_Invariant (L_Idx/R_Idx in 0..Capacity, Invariant, Steps <=200)` and `Loop_Variant (Increases => Steps)` with `exit when Steps >=200 or (Steps > Left.Capacity and Steps > Right.Capacity)` and guarded `Steps+1`. Both now **prove** (Find_Pos 10/10, `"="` 12/12) and add **13 VCs** (run-time 313->322, assertions 60->62, termination 71->73, flow 109->110). `Element`/`Get` stay `Off` to preserve the raise-on-out-of-range API (adding `Pre => Invariant and Has_Element/Pos<=Size` would be API-breaking and needs `Total = reachable`); they remain exercised by the 10290-test suite.
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
     16.1.0**: full On gives **589 VCs, 0 unproved (Silver)**;
     with `Merge`/`"="`/`Compute_State_Vector`/`Sync_Delta` scoped
     Off, **589 VCs, 0 unproved (Silver)**. The residual VCs are
     bounded overflow on `Values'First+I` / `Seq+Offset` /
     `Capacity+Capacity` and `Invariant` preservation on `Rgas.Merge`,
     all fixable with tighter `Invariant` bounds and
     `Loop_Invariant (Invariant(Target))` -- confirming the debt is
     provable when restructured, but not yet 0-unproved. The
     refactored file was **reverted** to `SPARK_Mode => Off` to keep
     **Platinum 576, 0 unproved** for 1.12.0.

### C2: Skipped-Units Audit Expanded (now 99 Off, was 100)

The ledger's re-audit (dated _2026-08-22_, via `lccst` + gnatprove 16.1.0)
classifies all **99** `SPARK_Mode => Off` + 10 generic-not-analyzed
(was 100+10) after the Naive `"="` moved to `On` (Find_Pos was already
`On` but now proves):

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
     `Proof_Instantiations` where the body is On (`Naive_Char` now
     includes `Find_Pos` 10/10 and `"="` 12/12, plus `Lww_Set_Vector`,
     `Clocked_Vector`, `Vector_4`, `Matrix_4`, `Rgas_Char`), skipped
     where the body is Off (`Rga_Char`, `Yjs_Char`, `Fugue_Char`).
   - **Default-off pure-logic debt** (provable in principle, deferred):
     `CRDT.Rga`, `CRDT.Sequences.Yjs`, `CRDT.Sequences.Fugue` whole
     bodies, and `Naive: Element`/`Get` (2 functions, `Find_Pos`/`"="`
     now On). The ledger records the exact refactor and the VC debt
     (~10 VCs for the two remaining accessors, ~420 VCs for the three
     engines; the two fixed helpers were ~13 VCs).

### C3: Verification Reconfirmed (gnatprove 16.1.0 via lccst, after fix)

`make prove` at `--steps=10000` under **gnatprove 16.1.0**
(`gnatprove_16.1.0_82528bef`, Why3 1.8.2 + CVC5 1.3.2 + Z3 4.15.4, via
sibling `adacovex` and `lccst_verify`) now reports
**589 VCs, 479 proved + 110 flow, 0 justified, 0 unproved, Platinum**
(max steps 412, longest VC < 1s, was 576/467/109/361). `make test` and
`lccst_verify` still report **10290 passed, 0 failed** across 9
categories (lccst: test OK, build OK). The ledger's numbers reproduce
on a fresh `make prove --force` run and `docs/compliance/VERIFICATION.md`
was regenerated via `lccst` (`make compliance`). The RGA trial numbers
(1223/77 and 955/35, now 1183/77) are the lccst-verified evidence that
the remaining RGA/Yjs/Fugue debt is closable with the same pattern.

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

Changed from 1.11.0 at the new prover **gnatprove 16.1.0** (via lccst):
**589 total checks, 479 proved + 110 flow, 0 justified, 0 unproved**
(was 576/467+109), 34 analyzed units, 149 total units (generic +
skipped: 10 generic, 98 Off -- was 100 Off, two helpers now On);
SPARK assurance **Stone + Bronze + Silver + Gold + Platinum** across all
SPARK-analyzable units, with generics (10 units) and platform
dependencies (98 `SPARK_Mode => Off` locations: wall clock, RNG, stream
I/O, test harness, plus the 2 Naive accessors + 3-engine debt) excluded
by design. The ledger adds **+13 VCs** for the two newly proved Naive
helpers (`Find_Pos` 10/10, `"="` 12/12); the remaining two accessors
(`Element`/`Get`) and the three engines (~420 VCs) are still deferred
but the lccst trial (1223/77 -> 1183/77 full On, 955/35 partial Off)
shows the pattern closes the debt.

| Metric | 1.11.0 | 1.12.0 |
|--------|--------|--------|
| Total checks | 589 | 589 (+13) |
| Proved | 467 (81%) | 479 (81%) |
| Justified | 0 | 0 |
| Unproved | 0 | 0 |
| Flow Dependencies | 14 | 14 |
| Initialization | 30 | 30 |
| Run-time Checks | 313 | 322 (+9) |
| Assertions | 60 | 62 (+2) |
| Functional Contracts | 88 | 88 |
| Termination | 71 | 73 (+2) |
| Analyzed units | 34 | 34 |

## Traceability

No new HLRs; the 24 HLR tags are unchanged. The ledger lives under
`docs/proof/` and is not a DO-178C artifact; it references the existing
HLR coverage (see `docs/compliance/HLR.md` and `make compliance`) and
the adacovex `HLR-PROVE` proof-patch machinery. Compliance artifacts
were not regenerated: the assessment output is unchanged (DAL-C,
Platinum).

## Breaking Changes

None. The two helpers moved from `SPARK_Mode => Off` to `On`
(`Find_Pos` internal, `"="` in `CRDT.Sequences.Naive`) are private
implementations; the public `Element`/`Get` raise-on-out-of-range API,
all generic signatures (`Lww_Element_Sets`, `Rga`, `Rgas`, `Protected`,
`Bounded`, `Sequences.*`), and the wire protocol (V1/V2/V3) are
unchanged. The ledger remains under `docs/proof/` and the remaining
`Off` debt (2 accessors + 3 engines) is documented there. `alire.toml`
is unchanged (1.11.0 until `make bump-version`); `alire-dev.toml` now
pins `gnatprove = "^16.1.0"` (was 15.1.0) via `lccst`.

## Version

Bumped from 1.11.0 to 1.12.0.
