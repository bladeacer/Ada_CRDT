### CRDT 1.11.0

Date: _2026-08-19_

The vendored demo dependency now participates in the SPARK proof without
modifying its sources. A proof patch under `.adacovex/patches/` declares
`SPARK_Mode => On` on the vendored VT100 package and pins its
`Scroll_Screen` scroll-region contract. The `prove` pipeline runs through the
sibling adacovex binary (1.16.0) and preserves the core library proof exactly
at 576 checks, 467 proved, 0 justified, 0 unproved.

## Changes

### C1: Proof Patch for the Vendored VT100 Demo Dependency

The vendored `demo/deps/vt100` package (a third-party ANSI/VT100 wrapper
whose sources must not be modified) now carries a proof patch at
`.adacovex/patches/demo/deps/vt100/vt100.ads` declaring `SPARK_Mode => On`
on the package and pinning the scroll-region contract on the two-argument
overload: `procedure Scroll_Screen (From : in Natural; To : in Natural)
with Pre => From <= To;`. The patch file doubles as the docstring overlay
for strict-mode scanning, so the vendored dep stays fully documented
without touching the originals.

adacovex 1.16.0's `prove` subcommand detects the proof patch, copies the
target tree into `obj/adacovex-proof/` (excluding `.git`, `obj`, and
`.adacovex`), merges the patch into the copy, and runs gnatprove against
it. The target's own `make prove` invokes the sibling adacovex binary. It
therefore runs through the patched copy, with the resulting `gnatprove.out`
copied back for the assessment pipeline. The merge matches subprograms by
name and normalized parameter profile, so the two-argument `Scroll_Screen`
patches its exact signature and never the same-named parameterless
sibling.

VT100 is demo-only (not in the `test_crdt.adb` closure analysed by
`crdt.gpr`). Its bodies are `Ada.Text_IO`-bound. gnatprove skips them by
design. The patch exercises the proof-patch mechanism without changing the
library's proof numbers. The mechanism's full
SPARK-clean body path (where the vendored body opts into the proof and its
contracts are proved outright) is documented and verified in adacovex's
architecture guide.

## Test Suite

10290 tests passing across 9 categories (unchanged from 1.10.0).

## Proof Results

Unchanged from 1.10.0: 576 total checks, 467 proved, 0 justified, 0
unproved, 34 analysed units. SPARK assurance is Stone + Bronze + Silver +
Gold + Platinum across all SPARK-analyzable units. Generics (10 units)
and platform dependencies (100 `SPARK_Mode => Off` locations) remain excluded
by design. The proof patch is merged into the proof tree and the run is
exercised end to end. VT100 is out of the analysed closure. No VC counts move.

## Traceability

No new HLRs are added. The 24 HLR tags are unchanged. The patch covers a
vendored demo dependency through the proof pipeline (adacovex `HLR-PROVE`
machinery) and carries no HLR tags itself. Compliance artifacts were not
regenerated. The assessment output is unchanged (DAL-C, Platinum).

## Breaking Changes

None. The patch lives under `.adacovex/patches/` and only affects the
adacovex-driven proof/docstring pipeline. It is invisible to the library's
build and runtime. All public package names, generic signatures, and the
wire protocol (V1/V2/V3) are unchanged.

## Version

Bumped from 1.10.0 to 1.11.0.
