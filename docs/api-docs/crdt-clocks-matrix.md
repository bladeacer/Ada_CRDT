# CRDT.Clocks.Matrix

Matrix clock strategy.
2D array tracking per-replica knowledge propagation.
M[i][j] = node i's knowledge of node j's event count.
Provides full transitive causal visibility at O(N^2) storage cost.
Useful for advanced gossip protocols and group membership.

Usage:
package M is new CRDT.Clocks.Matrix (Max_Replicas => 4);
T1, T2 : M.Clock_Time;
M.Increment (T1, Row => 1, Col => 2);
M.Merge (T1, T2);

Requirements traceability:
- HLR-CORE-CLOCKS: Clock strategy interface
- HLR-CORE-CLOCKS-MATRIX: Matrix clock operations

> **Note:** All items in this package are public.

## Types

### type Clock_Time

```ada
type Clock_Time is array (1 .. Max_Replicas, 1 .. Max_Replicas) of Natural with Default_Component_Value => 0;
```

## Functions

### function "<" (Left : CRDT.Clocks.Matrix.Clock_Time; Right : CRDT.Clocks.Matrix.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` | Left clock. |
| `Right` | Right clock. |

**Returns:** True if Left is strictly behind Right.

### function "=" (Left : CRDT.Clocks.Matrix.Clock_Time; Right : CRDT.Clocks.Matrix.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` | Left clock. |
| `Right` | Right clock. |

**Returns:** True if matrices are identical.

### function ">" (Left : CRDT.Clocks.Matrix.Clock_Time; Right : CRDT.Clocks.Matrix.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` | Left clock. |
| `Right` | Right clock. |

**Returns:** True if Left strictly follows Right.

### function Max (Left : CRDT.Clocks.Matrix.Clock_Time; Right : CRDT.Clocks.Matrix.Clock_Time) return CRDT.Clocks.Matrix.Clock_Time

| Parameter | Description |
|-----------|-------------|
| `Left` | First clock. |
| `Right` | Second clock. |

**Returns:** Matrix where each (R,C) is max of the two inputs.

## Procedures

### procedure Increment (T : CRDT.Clocks.Matrix.Clock_Time; Row : Standard.Positive; Col : Standard.Positive) `[Pre]`

| Parameter | Description |
|-----------|-------------|
| `Col` | Observed replica slot. |
| `Row` | Observer replica slot. |
| `T` | Matrix to modify. |

### procedure Merge (Target : CRDT.Clocks.Matrix.Clock_Time; Source : CRDT.Clocks.Matrix.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Source` | Matrix to merge from. |
| `Target` | Matrix to update. |

### procedure Read_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Matrix.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` | Decoded matrix. |
| `Stream` | Input stream. |

### procedure Write_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Matrix.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` | Matrix to write. |
| `Stream` | Output stream. |
