# CRDT.Clocks.Vector

Vector clock strategy.
Wraps Core.VTime with uniform comparison, merge, increment, and I/O.
Recommended default for production use.

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
| `Left` |  |
| `Right` |  |

### function "=" (Left : CRDT.Clocks.Vector.Clock_Time; Right : CRDT.Clocks.Vector.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### function ">" (Left : CRDT.Clocks.Vector.Clock_Time; Right : CRDT.Clocks.Vector.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### function Max (Left : CRDT.Clocks.Vector.Clock_Time; Right : CRDT.Clocks.Vector.Clock_Time) return CRDT.Clocks.Vector.Clock_Time

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

## Procedures

### procedure Increment (T : CRDT.Clocks.Vector.Clock_Time; Idx : Standard.Positive)

| Parameter | Description |
|-----------|-------------|
| `Idx` |  |
| `T` |  |

### procedure Merge (Target : CRDT.Clocks.Vector.Clock_Time; Source : CRDT.Clocks.Vector.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Source` |  |
| `Target` |  |

### procedure Read_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Vector.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` |  |
| `Stream` |  |

### procedure Write_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Vector.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` |  |
| `Stream` |  |
