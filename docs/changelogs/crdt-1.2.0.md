### CRDT 1.2.0

Date: _2026-06-03_

LEB128 wire protocol, Conway Game of Life demo, and expanded test coverage.
Variable-length integer encoding replaces fixed 4-byte `Natural'Write`,
reducing serialized payload size for typical CRDT values by 50 to 75%. The
monolithic test file is split into per-category packages with per-category
Markdown reports and an aggregated `test_result.md`.

## Changes

### C1: LEB128 Wire Protocol

Variable-length integer encoding replaces fixed 4-byte `Natural'Write`,
reducing serialized payload size for typical CRDT values by 50 to 75%.
Reading V1-format data is NOT yet supported (V1 to V2 migration added in
1.4.0).

### C2: Conway Game of Life Demo

Interactive terminal demo (`make demo`) showing CRDT-based distributed
cellular automaton with state-based sync.

### C3: Unit Test Docs

Per-category Markdown reports generated alongside API docs.

### C4: Test Summary Table

Aggregated results table written to `test_result.md`.

### C5: Test Reorganization

Split monolithic test file into per-category test packages (`Test_Basic`,
`Test_Convergence`, `Test_Engines`, `Test_Fuzz`, `Test_GoL`, `Test_Lattice`,
`Test_RGA_Features`, `Test_Serialization`).

## Fixes

### H1: Concurrency Deadlock

Fixed Game of Life demo deadlock when switching between concurrent modes.

### H2: Wire-Format Validation

Added wire-format compatibility tests for LEB128 round-trips.

## Test Suite

Expanded with per-category test packages, wire-format compatibility tests,
and an aggregated summary table. Exact count not recorded in `test_result.md`
for this version.

## Proof Results

No SPARK proof changes from 1.1.0. Proof results not tracked.

## Traceability

No HLR tags -- DO-178C traceability was introduced in 1.5.0.

## Breaking Changes

None. New serialized data uses LEB128 (V2) format; old V1-format data cannot
be read by this version (upgrade to 1.4.0 for automatic V1 compatibility).
All APIs remain backward compatible at the Ada source level.

## Version

Bumped from 1.1.0 to 1.2.0.
