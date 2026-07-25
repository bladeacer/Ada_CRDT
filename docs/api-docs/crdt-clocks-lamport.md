# CRDT.Clocks.Lamport

Lamport clock strategy.
Wraps CRDT.Core.Lamport_Time with uniform comparison, max, and I/O.
Lamport clocks capture causality through a logical counter + replica ID,
producing a total order without requiring wall-clock synchronisation.
Suitable when full causal history is not required.

Usage:
package L is new CRDT.Clocks.Lamport;
T1, T2 : L.Clock_Time;
--  result := L.Max (T1, T2);

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
| `Left` | Left operand. |
| `Right` | Right operand. |

**Returns:** True if Left causally precedes Right.

### function "=" (Left : CRDT.Clocks.Lamport.Clock_Time; Right : CRDT.Clocks.Lamport.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` | Left operand. |
| `Right` | Right operand. |

**Returns:** True if timestamps are identical.

### function ">" (Left : CRDT.Clocks.Lamport.Clock_Time; Right : CRDT.Clocks.Lamport.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` | Left operand. |
| `Right` | Right operand. |

**Returns:** True if Left causally follows Right.

### function Max (Left : CRDT.Clocks.Lamport.Clock_Time; Right : CRDT.Clocks.Lamport.Clock_Time) return CRDT.Clocks.Lamport.Clock_Time

| Parameter | Description |
|-----------|-------------|
| `Left` | First timestamp. |
| `Right` | Second timestamp. |

**Returns:** The timestamp that causally follows the other.

## Procedures

### procedure Read_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Lamport.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` | Decoded clock timestamp. |
| `Stream` | Input stream. |

### procedure Write_Clock (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Clocks.Lamport.Clock_Time)

| Parameter | Description |
|-----------|-------------|
| `Item` | Clock timestamp to write. |
| `Stream` | Output stream. |
