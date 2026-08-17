### CRDT 1.8.0

Date: _2026-07-30_

Correctness, consistency, and compliance fixes. Real `Compute_Delta`
implementation in both sync engines, documentation corrections for protocol
versioning, and build-system hardening.

## Changes

### C1: Compute_Delta Implementation

`Compute_Delta` in both `CRDT.Sync.State_Based` and
`CRDT.Sync.State_Based.Clocked` was a dead stub unconditionally returning `0`.
Both are now implemented:

- **State_Based**: Counts indices where the local vector-clock entry exceeds
  the remote's, giving a meaningful delta for partial state exchange.
- **State_Based.Clocked**: Counts entries in the local clock array that are
  ahead of the remote's single clock timestamp.

The `Post => Compute_Delta'Result = 0` contract is replaced with
`Post => Compute_Delta'Result <= Local.Max_Replicas`.

### C2: Backward Compatibility Documentation Fix

`AGENTS.md` stated that "V1 readers can read V2 data" -- this is physically
impossible since V1 only understands fixed-width `Natural'Read`. Corrected to
"V2 readers can read V1 data (backward compatible)", matching the actual
`Read_Header` auto-detection logic.

### C3: Protocol_Version in LLR.md

`docs/compliance/LLR.md` listed `Core.Protocol_Version` as `Constant = 2` but
the code has been `3` since 1.7.0. Updated to `Constant = 3`.

### C4: SPARK_Mode Annotation Consistency

`src/core/crdt-bounded.ads` used `pragma SPARK_Mode;` (bare pragma form)
while every other spec uses `with SPARK_Mode` (aspect form). Changed to the
aspect form for consistency.

### C5: Unused Import Removed

Removed `with Ada.Calendar;` from `src/sync/crdt-sync-state_based.ads` -- the
package does not directly reference any `Ada.Calendar` entity (HLC internals
are encapsulated).

### C6: Serialization HLRs Updated

`HLR-CNTR-SERIAL` and `HLR-LWW-SERIAL` in `docs/compliance/HLR.md` now
mention V3 wire format alongside V1 and V2.

### C7: SPARK Status Reconciliation

SPARK documentation clarified to distinguish two tiers:

- **Gold** (always targeted, minimum guarantee): AoRTE + key functional
  contracts on all SPARK-analyzable units.
- **Platinum** (best-effort ideal above Gold): full functional requirements
  across all analyzable units. Reflects the current release's proof state,
  not a permanent guarantee across compiler upgrades or feature changes.

The SPARK badge (`docs/badges/spark.svg`) already showed **Platinum** but the
documentation described it as "not targeted". `AGENTS.md`,
`docs/compliance/VERIFICATION.md`, and the `Makefile` `verify-report` template
now all confirm the Platinum best-effort level: all SPARK-analyzable units
fully proved (37/37 functional contracts, 0 unproved checks), with generics
and platform dependencies excluded by design.

### C8: gen-coverage.py Proof Numbers

`tools/gen-coverage.py` hardcoded SPARK proof stats (`273 total, 221
proved...`) that would become stale. Now parses `obj/gnatprove/gnatprove.out`
for live numbers, falling back to a placeholder if the file is absent.

### C9: Demo Target Robustness

The `demo` target in `Makefile` used raw `stty -isig`/`stty isig` outside a
TTY which would fail in CI or non-interactive shells. Wrapped with
`2>/dev/null` and `|| true` fallbacks to handle non-TTY environments
gracefully.

### C10: verify-report Atomicity

The `verify-report` target wrote generated content to `index_file.tmp` and
moved it over the original, but a `sed` failure mid-write would corrupt the
file. Now uses a PID-suffixed temp file (`index_file.$$.tmp`) and checks
`sed` exit status before proceeding, cleaning up on failure.

## Test Suite

10290 tests passing (unchanged from 1.7.1).

## Proof Results

273 checks, 221 proved, 5 justified, 0 unproved (unchanged from 1.7.1).

## Traceability

24 HLR tags (unchanged); serialization HLR wording updated for V3.

## Breaking Changes

None. All changes are additive, corrective, or internal.

## Version

Bumped from 1.7.1 to 1.8.0.
