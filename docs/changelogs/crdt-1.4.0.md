### CRDT 1.4.0

Date: _2026-06-04_

Protocol migration, SPARK proof hardening, and fuzz testing. `Read_Header`
now transparently detects V1 (fixed-width) vs V2 (LEB128) wire formats by
inspecting the first 4 header bytes, so existing V1 data upgrades without any
migration steps. 10,000+ chaos iterations cover clock skew, out-of-order
delivery, partition merges, and bit-flip injection, and unproved checks drop
from 36 to 0.

## Changes

### C1: Protocol Migration -- V1 to V2 Auto-Detection

`Read_Header` now transparently detects V1 (fixed 4-byte `Natural'Read`) vs
V2 (LEB128) wire formats by inspecting the first 4 header bytes. Users with
existing V1-format serialized data can upgrade without any migration steps.

### C2: Fuzz Testing

10,000+ chaos iterations covering clock skew, out-of-order delivery,
partition merges, and bit-flip injection.

### C3: SPARK Proof Hardening

All package bodies now have `SPARK_Mode => On`. Function preconditions, type
invariants, loop invariants, and postconditions added throughout. Unproved
checks reduced from 36 to 0.

### C4: Modularised Unit Tests

Test runner split from a monolithic 2728-line file into `CRDT.Test_Support`
and 8 group packages with an auto-counted summary table.

### C5: Source Reorganization

Flat `src/` restructured into `core/`, `sequences/`, `sync/`,
`serialization/`, and `tests/` subdirectories.

### C6: Test Docs Excluded

`make api-docs` strips test package documentation and corresponding index
links.

### C7: SPARK_Mode Restructuring

Removed factored `SPARK_Mode => Off` from all non-test body packages;
remaining Off annotations are scoped to individual subprograms using RNG or
wall-clock time.

### C8: Wire-Format Migration Guide

Reading V1 data is automatic: `Read_Header` detects V1 vs V2 and dispatches
`Read_Natural` accordingly, so existing reader code requires zero changes.
The library always writes V2 (LEB128); use
`CRDT.Serialization.Legacy.Read_Natural_V1` to write V1 for legacy peers (not
recommended). See `docs/changelogs/crdt-1.4.0-migration.md` for a worked
example.

## Test Suite

10,000+ fuzz iterations added on top of the existing suite; tests reorganized
into 8 group packages with an auto-counted summary table.

## Proof Results

| Metric | Value |
|--------|-------|
| Total checks | 112 |
| Unproved | 0 |
| Functional Contracts | 0 |
| Assertions | 8 |
| Loop Invariants | 4 |

## Traceability

No HLR tags yet -- DO-178C traceability was introduced in 1.5.0.

## Breaking Changes

None. V1 protocol data is read transparently; no source-code changes needed.
All V2 data continues to work unchanged. Rebuild your project with
`alr update crdt`.

## Version

Bumped from 1.3.0 to 1.4.0.
