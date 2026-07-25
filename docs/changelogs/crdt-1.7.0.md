### CRDT 1.7.0

Date: _2026-07-25_

Clock strategy selection, Matrix clock support, and generic LWW sets.

## New Features

### Clock Strategy Selection

Three interchangeable clock strategies under a new `CRDT.Clocks` package hierarchy:

- **`CRDT.Clocks.Lamport`** — wraps `Core.Lamport_Time` (Stamp + Node). Minimal overhead, no concurrency detection.
- **`CRDT.Clocks.Vector`** — wraps `Core.VTime` per-replica counters. Full causal history, concurrent update detection. **Recommended default for production**.
- **`CRDT.Clocks.Matrix`** — new 2D matrix clock ([N×N] array). Tracks knowledge propagation across replicas: `M[i][j]` = node i's knowledge of node j's events. Enables distributed GC and richer causality queries.

Each strategy provides a uniform interface: `Clock_Time` type, comparison operators (`<`, `=`, `>`), `Max`, `Increment`, `Merge`, and `Write_Clock`/`Read_Clock` for serialization.

### CRDT.Lww_Sets — Generic LWW over Clock Strategy

New generic package that works with any clock strategy:

```ada
with CRDT.Clocks.Vector;
package VC is new CRDT.Clocks.Vector (Max_Replicas => 32);
package My_Set is new CRDT.Lww_Sets
  (Integer, 100, VC.Clock_Time, VC."<", VC."=", VC.">",
   VC.Max, VC.Write_Clock, VC.Read_Clock);
```

The original `CRDT.Lww_Element_Sets` (Lamport-based) remains fully supported and unchanged for backward compatibility.

### New Tests

40 new tests covering Lamport, Vector, and Matrix clock operations, and `Lww_Sets` instantiated with all three strategies.

## Changes

### Version

Bumped from 1.6.0 to 1.7.0. Wire protocol remains V2 (V3 with clock-type discriminator planned for a future release).

## Test Results

| Metric | Before (1.6.0) | After (1.7.0) |
|--------|----------------|----------------|
| Tests | 10250 | 10290 |
| New tests | | Clock strategies (40) |

## Breaking Changes

None. All existing APIs are fully backward-compatible.
