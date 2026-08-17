### CRDT 1.7.0

Date: _2026-07-25_

Clock strategy selection (Lamport, Vector, Matrix), V3 wire protocol with
clock-kind discriminator, clocked sync layer, generic LWW sets, SPARK proof
expansion, and documentation modernization. `CRDT.Clocks` introduces three
interchangeable clock strategies, `CRDT.Lww_Sets` is a new generic LWW set
over any strategy, and `CRDT.Sync.State_Based.Clocked` replaces the hardcoded
VTime + HLC sync path. Canonical repository moved from Codeberg to GitHub due
to TOS changes on AI-assisted code.

## Changes

### C1: Clock Strategy Selection

Three interchangeable clock strategies under a new `CRDT.Clocks` package
hierarchy:

- **`CRDT.Clocks.Lamport`** -- wraps `Core.Lamport_Time` (Stamp + Node).
  Minimal overhead, no concurrency detection.
- **`CRDT.Clocks.Vector`** -- wraps `Core.VTime` per-replica counters. Full
  causal history, concurrent update detection. **Recommended default for
  production**.
- **`CRDT.Clocks.Matrix`** -- new 2D matrix clock ([NxN] array). Tracks
  knowledge propagation across replicas: `M[i][j]` = node i's knowledge of
  node j's events. Enables distributed GC and richer causality queries.

Each strategy provides a uniform interface: `Clock_Time` type, comparison
operators (`<`, `=`, `>`), `Max`, `Increment`, `Merge`, and
`Write_Clock`/`Read_Clock` for serialization.

### C2: V3 Wire Protocol

`Protocol_Version` bumped to 3. New `CRDT.Clocks.Clock_Kind` enum embedded in
V3 headers for auto-detection of the clock strategy used during serialization.
`Read_Header` detects V1/V2/V3 transparently.

- Legacy types (`LWW_Element_Sets`, `RGA`, `PN_Counters`) continue writing V2
  for backward compatibility.
- New `Lww_Sets` writes V3 with the appropriate clock strategy identifier.
- `Migrate_Header_To_V3` promotes any version to V3.

### C3: CRDT.Lww_Sets -- Generic LWW over Clock Strategy

New generic package parameterised over any `CRDT.Clocks.*` strategy:

```ada
with CRDT.Clocks.Vector;
package V is new CRDT.Clocks.Vector (Max_Replicas => 8);
package S is new CRDT.Lww_Sets (Integer, 100, V.Clock_Time,
  Clk_Kind    => CRDT.Clocks.Clock_Vector,
  ">"         => V.">",
  Max         => V.Max,
  Write_Clock => V.Write_Clock,
  Read_Clock  => V.Read_Clock);
```

`CRDT.Lww_Element_Sets` (Lamport-only) is now **deprecated** -- retained for
backward compatibility but no new features will be added.

### C4: Clocked State-Based Sync

`CRDT.Sync.State_Based.Clocked` -- generic sync engine parameterised over any
clock strategy, replacing the hardcoded VTime + HLC in `State_Based`.

### C5: Demo Clock Toggle

Conway's Game of Life demo now supports cycling clock strategies at runtime
with the 'C' key. Status bar displays the active strategy.

### C6: SPARK Proof Expansion

- **273 checks** (up from 269): 221 proved, 5 justified, 0 unproved.
- `src/serialization/crdt-serialization.ads`,
  `src/serialization/crdt-serialization-legacy.ads`: package-level
  `SPARK_Mode => On` (was Off), per-subprogram Off for stream I/O.
- Private helpers (`Lamport_Max`, `HLC_Less`, `HLC_Eq`, `HLC_Max`) moved to
  private section of `CRDT.Core`.

### C7: Documentation and Tooling

- **AGENTS.md**: Comprehensive codebase guide for AI agents covering
  structure, conventions, SPARK status, DO-178C, internal interfaces.
- **API docs**: `make doc` now generates documentation for **both public and
  private** entities (`--generate private`), producing a per-package page for
  every CRDT package and type.
- **SPARK coverage report**: `docs/api-docs/crdt-spark-coverage.md` lists all
  SPARK_Mode Off locations with justifications.
- **ASCII enforcement**: `make ascii-check` now scans all source files
  including `docs/changelogs/` and `docs/compliance/` (excludes generated
  `docs/api-docs/` and vendored `vt100/`).
- **README**: Restructured with Quick Reference table, Roadmap section, wire
  protocol V3 documentation, API doc links above each code example, and
  deprecation notices. Examples are illustrative; generated API docs are
  authoritative.

### C8: Compliance

- `make compliance` now validates HLR.md coverage (no stale/missing HLRs).
- 24 HLRs tracked with full bidirectional traceability.
- `HLR-PROTO-LEB128` added for the LEB128 encoding requirement.

## Test Suite

10290 tests passing (up from 10250): 40 new tests covering Lamport, Vector,
and Matrix clock operations, and `Lww_Sets` instantiated with all three
strategies.

## Proof Results

| Metric | Before (1.6.0) | After (1.7.0) |
|--------|----------------|----------------|
| Checks | 269 | 273 |
| Proved | 191 | 221 |
| Justified | 10 | 5 |
| Unproved | 0 | 0 |

## Traceability

24 HLR tags (HLR-CORE-CLOCKS and HLR-CORE-CLOCKS-MATRIX added for clock
strategy selection, HLR-PROTO-LEB128 documented); all others unchanged from
1.6.0.

## Breaking Changes

None. All existing APIs are fully backward-compatible. `Lww_Element_Sets`,
`RGA`, `PN_Counters` continue to write V2 format. V3 readers can read all V1,
V2, and V3 data.

## Version

Bumped from 1.6.0 to 1.7.0.
