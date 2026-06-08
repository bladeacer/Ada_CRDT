# CRDT 1.2.0

_2025-10-21_

LEB128 wire protocol, Conway Game of Life demo, and expanded test coverage.

## New Features

- **LEB128 Wire Protocol** — variable-length integer encoding replaces fixed 4-byte
  `Natural'Write`. Reduces serialized payload size for typical CRDT values by 50–75%.
  Reading V1-format data is NOT yet supported (V1→V2 migration added in 1.4.0).
- **Conway Game of Life Demo** — interactive terminal demo (`make demo`) showing
  CRDT-based distributed cellular automaton with state-based sync
- **Unit Test Docs** — per-category Markdown reports generated alongside API docs
- **Test Summary Table** — aggregated results table written to `test_result.md`

## Changes

- Split monolithic test file into per-category test packages (`Test_Basic`,
  `Test_Convergence`, `Test_Engines`, `Test_Fuzz`, `Test_GoL`, `Test_Lattice`,
  `Test_RGA_Features`, `Test_Serialization`)
- Fixed Game of Life demo deadlock when switching between concurrent modes
- Added wire-format compatibility tests for LEB128 round-trips

## Migration from 1.1.0

- New serialized data uses LEB128 (V2) format. Old V1-format data cannot be read
  by this version (upgrade to 1.4.0 for automatic V1 compatibility).
- All APIs remain backward compatible at the Ada source level.
