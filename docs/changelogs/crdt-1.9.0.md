### CRDT 1.9.0

Date: _2026-08-12_

Build-system tooling integration, a full SPARK proof restoration pass, and a
CI/consumability fix for adacovex. SPARK Platinum is restored across all
SPARK-analyzable units with 0 unproved verification conditions and justified
VCs trimmed to 42, and the project now drives the adacovex tool through the
standard `covex` dev dependency rather than a hard-coded sibling checkout.

## Build System

### Adacovex Tooling Integration

Replaced the ad-hoc `../adacovex/bin/adacovex` invocation in the `prove`,
`coverage-gate`, and `badges` Makefile targets with the standard adacovex dev
workflow:

- New `covex` target ensures the adacovex (covex) dev dependency is built on
  first use.
- New `swap-in-covex` / `swap-out-covex` helpers temporarily overlay
  `alire-dev.toml` over `alire.toml` for commands that need the dev toolchain
  (covex, gnatprove) and restore the clean publishing manifest afterwards --
  the same auto-swap pattern already used by `fmt`.
- `prove`, `coverage-gate`, `badges`, and (newly) the `covex` target resolve
  the adacovex binary through `alr exec -- adacovex` instead of a hard-coded
  path into the `../adacovex` working tree.

This decouples the project from a sibling adacovex checkout and aligns the
local dev flow with the published `covex` crate and the
`bladeacer/adacovex` GitHub Action.

### Adacovex CI Manifest Fix

- `alire.toml` is restored to the clean publishing manifest: it carried the full
  dev toolchain (`gnatprove`, `gnatdoc_bin`, `gnatformat_bin`, `covex`) plus a
  `[[pins]] covex = { path = "../adacovex" }`. In a fresh checkout or in CI
  that path does not exist, so Alire aborted loading the workspace and **every
  CI step that touched the manifest failed** (`alr build`, and the adacovex
  action's `Run GNATprove` -- which resolves `gnatprove` via the target
  manifest -- died with `Pin path is not a valid directory`).
- `alire-dev.toml` now declares `covex = "*"` (a normal index dependency)
  instead of pinning it to `../adacovex`. The path pin resolved only on a
  machine with the sibling checkout; removing it lets `alr exec` (and adacovex's
  `prove` dev-manifest swap) load the workspace in CI and in consumer checkouts.
- Hardened the Makefile's manifest-detection greps (`swap-in-covex` / `fmt`)
  to match a real dependency declaration (`^covex =` / `^gnatformat_bin =`)
  rather than the bare crate word, so documentation comments can never trip the
  swap detection.

## SPARK Proof

### Platinum Restoration

Restored SPARK Platinum (all SPARK-analyzable units fully proved, 0 unproved
verification conditions) after a regression, primarily in the Naive sequence
engine. This commit series touched: `src/sequences/crdt-sequences-naive.adb`,
`crdt-lww_sets.ads`, `src/core/crdt-hlc.adb`, `src/core/crdt-clocks-vector.ads`,
`src/core/crdt-clocks-matrix.ads`, `src/crdt-pn_counters.ads`,
`src/crdt-rgas.ads`, and `src/crdt-lww_sets.adb`.

### Contract Strengthening

Added and tightened contracts to discharge proof obligations:

- **LWW_Clocked_Set** (`crdt-lww_sets.ads`): `Add`/`Remove`/`Merge` post-
  conditions now also bound `Remove_Count (S) <= S.Capacity`; `Clear`'s
  `Depends` clause tightened to `(S => S)`.
- **RGA / Pn_Counters**: added `Pre => Index <= RS.Count`,
  `Pre => Size (RS) < RS.Count`, and `Type_Invariant => Sz <= Count` clauses
  to narrow the proof obligations on indexed access.
- **Vector clock / Matrix clock** (`crdt-clocks-vector`, `crdt-clocks-matrix`):
  added overflow justifications on clock-array read/assign preconditions.

### HLC Overflow Justifications

`src/core/crdt-hlc.adb`: added `GNATprove` `False_Positive` annotations for
"overflow check might fail", justified (the HLC Log is bounded in practice and
reset whenever the wall clock advances).

### Naive Engine Loop Fixes

`src/sequences/crdt-sequences-naive.adb`: corrected loop bounds and loop-exit
conditions that had regressed, restoring provability of the flat linked-list
RGA engine under SPARK.

### Justified-to-Proved Reduction

Non-deferred SPARK checks that were previously marked as false positives are
now proven outright:

- **`CRDT.Sync.Op_Based.Get`** (`crdt-sync-op_based.adb`): the bounds guard is
  rewritten as `Index <= Log.Capacity and then Log.GC <= Log.Capacity - Index`
  so the `GC + Index` overflow check (previously justified as "bounded by
  Capacity <= Positive'Last") is now discharged by SPARK.
- **`CRDT.Sequences.Naive`** (`crdt-sequences-naive.*`):
  - `Next` no longer carries the "Naive cursor Pos bounded by Total"
    false-positive annotation: its `Pos + 1` range check is proved directly
    from `Position.Pos < Container.Total`.
  - `Element` now requires `Pre => Has_Element (Container, Position)`, and its
    cursor-position range check is proved (the deliberate out-of-range raise
    remains a documented false positive). The `Has_Element` bodies moved to
    private-part expression functions so SPARK can unfold them inside the
    precondition.

Proof state: **584 VCs -- 435 proved, 42 justified, 0 unproved** (justified
down from 44). The 42 remaining justified VCs are documented false positives
that cannot be discharged without changing behaviour or public contracts: HLC
`Log` advancement against the wall clock (4), bounded PN-Counter arithmetic
(4), LWW set capacity bounds (4), Naive engine structural bounds and
linked-list traversal termination (17), deliberate accessor range checks (2),
and stream-attribute `not null`/invariant checks (11).

## Documentation & Tooling

### Python Tooling Typing Refactor

`tools/gen-coverage.py` and `tools/rst2md.py` now use typed helpers and
`TypedDict`-based structured data (SPARK_Mode => Off breakdowns, proof stats,
sub-item blocks), making the doc-generation tooling more maintainable and
robust.

### RST-to-Markdown Pipeline

`tools/rst2md.py`: refactored the Markdown generation with typed parsing
helpers for package descriptions, annotations, and private-item extraction,
improving robustness of the generated `docs/api-docs/` output.

### Patch File for Vendored Demo Dependency

Added `.adacovex/patches/demo/deps/vt100/vt100.ads` -- a docstring patch for the
vendored VT100 library used by the demo, applied in strict mode so adacovex can
assess its documentation.

### Compliance Index

`docs/compliance/index.md`: corrected stale verification summary entries and
removed obsolete/incorrect statements, keeping the compliance overview accurate.

## SBOM

`sbom.json`: regenerated as a proof-aware CycloneDX document reflecting the
current proof and test state (updated `make sbom` output).

## Badges

`docs/badges/*.svg`: regenerated with text-shadow removed from SVG badges for
crisper rendering; the adacovex badge step now produces clean SVG artifacts.

## Other

- **crdt-bounded.ads**: reverted `with CRDT.Rga with SPARK_Mode` back to a bare
  `pragma SPARK_Mode;` (plus a plain `with`), aligning with the remaining spec
  files in the tree.
- **Broken links**: fixed stale documentation/Quick-Reference links.

## Breaking Changes

None. All changes are additive, corrective, or internal. The public API
signatures of all generic packages (`Rga`, `Lww_Element_Sets`, `Lww_Sets`,
`Pn_Counters`, `Protected`, `Bounded`) and the wire protocol (V1/V2/V3) are
unchanged.

## Version

Bumped from 1.8.0 to 1.9.0.
