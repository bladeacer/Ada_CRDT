# CRDT.Clocks.Vector

Vector clock strategy.
Wraps CRDT.Core.VTime with uniform comparison, merge, increment, and I/O.
Each replica tracks its own logical counter; causal ordering is determined
by element-wise comparison of all counters.
Recommended default for production use.

Usage:
package V is new CRDT.Clocks.Vector (Max_Replicas => 8);
T1, T2 : V.Clock_Time;
V.Increment (T1, Idx => 1);
V.Merge (T1, T2);

Requirements traceability:
- HLR-CORE-CLOCKS: Clock strategy interface

> **Note:** All items in this package are public.

## Types

### type Clock_Time

```ada
subtype Clock_Time is CRDT.Core.VTime (1 .. Max_Replicas);
```

## Functions

### function "<" (Left : CRDT.Clocks.Vector.Clock_Time; Right : CRDT.Clocks.Vector.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` | Left clock. |
| `Right` | Right clock. |

**Returns:** True if Left is strictly behind Right.

### function "=" (Left : CRDT.Clocks.Vector.Clock_Time; Right : CRDT.Clocks.Vector.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` | Left clock. |
| `Right` | Right clock. |

**Returns:** True if clocks are identical.

### function ">" (Left : CRDT.Clocks.Vector.Clock_Time; Right : CRDT.Clocks.Vector.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` | Left clock. |
| `Right` | Right clock. |

**Returns:** True if Left strictly follows Right.

### function Max (Left : CRDT.Clocks.Vector.Clock_Time; Right : CRDT.Clocks.Vector.Clock_Time) return CRDT.Clocks.Vector.Clock_Time

| Parameter | Description |
|-----------|-------------|
| `Left` | First clock. |
| `Right` | Second clock. |

**Returns:** Clock where each entry is max of the two inputs.

## Procedures

### procedure Increment (T : CRDT.Clocks.Vector.Clock_Time; Idx : Standard.Positive)

| Parameter | Description |
|-----------|-------------|
| `Idx` | Replica slot index to increment. |
| `T` | Clock to modify. |

### procedure Merge (Target : CRDT.Clocks.Vector.Clock_Time; Source : CRDT.Clocks.Vector.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Source` | Clock to merge from. |
| `Target` | Clock to update. |

### procedure Read_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Vector.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` | Decoded clock. |
| `Stream` | Input stream. |

### procedure Write_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Vector.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` | Clock to write. |
| `Stream` | Output stream. |
