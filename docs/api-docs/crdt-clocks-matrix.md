# CRDT.Clocks.Matrix

Matrix clock strategy.
2D array tracking per-replica knowledge propagation.
M[i][j] = node i's knowledge of node j's event count.

Requirements traceability:
- HLR-CORE-CLOCKS: Clock strategy interface
- HLR-CORE-CLOCKS-MATRIX: Matrix clock operations

> **Note:** All items in this package are public.

## Types

### type Clock_Time

```ada
type Clock_Time is array (1 .. Max_Replicas, 1 .. Max_Replicas) of Natural
with Default_Component_Value => 0;
```

## Functions

### function "<" (Left : CRDT.Clocks.Matrix.Clock_Time; Right : CRDT.Clocks.Matrix.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### function "=" (Left : CRDT.Clocks.Matrix.Clock_Time; Right : CRDT.Clocks.Matrix.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### function ">" (Left : CRDT.Clocks.Matrix.Clock_Time; Right : CRDT.Clocks.Matrix.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### function Max (Left : CRDT.Clocks.Matrix.Clock_Time; Right : CRDT.Clocks.Matrix.Clock_Time) return CRDT.Clocks.Matrix.Clock_Time

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

## Procedures

### procedure Increment (T : CRDT.Clocks.Matrix.Clock_Time; Row : Standard.Positive; Col : Standard.Positive)

| Parameter | Description |
|-----------|-------------|
| `Col` |  |
| `Row` |  |
| `T` |  |

### procedure Merge (Target : CRDT.Clocks.Matrix.Clock_Time; Source : CRDT.Clocks.Matrix.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Source` |  |
| `Target` |  |

### procedure Read_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Matrix.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` |  |
| `Stream` |  |

### procedure Write_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Matrix.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` |  |
| `Stream` |  |
