# CRDT.Clocks.Lamport

Lamport clock strategy.
Wraps Core.Lamport_Time with uniform comparison, max, and I/O.

Requirements traceability:
- HLR-CORE-CLOCKS: Clock strategy interface

> **Note:** All items in this package are public.

## Types

### type Clock_Time

```ada
type Clock_Time is new CRDT.Core.Lamport_Time;
```

## Functions

### function "<" (Left : CRDT.Clocks.Lamport.Clock_Time; Right : CRDT.Clocks.Lamport.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### function "=" (Left : CRDT.Clocks.Lamport.Clock_Time; Right : CRDT.Clocks.Lamport.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### function ">" (Left : CRDT.Clocks.Lamport.Clock_Time; Right : CRDT.Clocks.Lamport.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### function Max (Left : CRDT.Clocks.Lamport.Clock_Time; Right : CRDT.Clocks.Lamport.Clock_Time) return CRDT.Clocks.Lamport.Clock_Time

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

## Procedures

### procedure Read_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Lamport.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` |  |
| `Stream` |  |

### procedure Write_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Lamport.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` |  |
| `Stream` |  |
