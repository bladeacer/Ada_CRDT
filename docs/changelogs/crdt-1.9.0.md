### CRDT 1.9.0

Date: _2026-08-12_

Build-system tooling integration, a full SPARK proof restoration pass, and a
CI/consumability fix for adacovex. SPARK Platinum is restored across all
SPARK-analyzable units with 0 unproved verification conditions, and the project
now drives the adacovex tool through the standard `covex` dev dependency rather
than a hard-coded sibling checkout.

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

## Documentation & Tooling

### gen-coverage.py Live Proof Numbers

`tools/gen-coverage.py` previously hardcoded SPARK proof statistics; it now
parses `obj/gnatprove/gnatprove.out` for live numbers (with a placeholder
fallback when the file is absent), so generated coverage reports stay accurate.

### RST-to-Markdown Pipeline

`tools/rst2md.py`: refactored to emit `docs/api-docs/` Markdown that now
documents both public and private entities, and improved robustness.

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

- **Makefile**: `demo` target hardened to no longer invoke `stty -isig`/
  `stty isig` outside a TTY (which failed in CI/non-interactive shells); wrapped
  with `2>/dev/null` and `|| true` fallbacks.
- **verify-report**: the `index.md` update now uses a PID-suffixed temp file
  with explicit `sed` exit-status checks before replacing the original, so a
  mid-write failure cannot corrupt the compliance index.
- **Broken links**: fixed stale documentation/Quick-Reference links.

## Breaking Changes

None. All changes are additive, corrective, or internal. The public API
signatures of all generic packages (`Rga`, `Lww_Element_Sets`, `Lww_Sets`,
`Pn_Counters`, `Protected`, `Bounded`) and the wire protocol (V1/V2/V3) are
unchanged.
