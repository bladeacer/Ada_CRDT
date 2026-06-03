# CRDT.Lww_Element_Sets

Last-Writer-Wins Element Set using Lamport timestamps. Stores (element, Lamport_Time) pairs for add and remove sets. An element is present iff its add-timestamp exceeds its remove-timestamp. Uses logical Lamport timestamps instead of wall clocks, avoiding clock skew issues in distributed deployments.

## Types

### type LWW_Element_Set

```ada
type LWW_Element_Set (Capacity : Positive) is private;
```

### type Timestamp_Array

```ada
type Timestamp_Array is array (Positive range <>) of Timestamp_Entry;
```

### type Timestamp_Entry

```ada
type Timestamp_Entry is record
Element : Element_Type;
Time    : Core.Lamport_Time;
end record;
```

## Functions

### function Contains (S : CRDT.Lww_Element_Sets.LWW_Element_Set; E : CRDT.Lww_Element_Sets.Element_Type) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `E` | The element to look up. |
| `S` | The set to query. |

**Returns:** True if element is considered present.

## Procedures

### procedure Add (S : CRDT.Lww_Element_Sets.LWW_Element_Set; E : CRDT.Lww_Element_Sets.Element_Type; TS : CRDT.Core.Lamport_Time)

| Parameter | Description |
|-----------|-------------|
| `E` | Element to add. |
| `S` | The set to modify. |
| `TS` | Lamport timestamp for this add operation. |

### procedure Clear (S : CRDT.Lww_Element_Sets.LWW_Element_Set)

| Parameter | Description |
|-----------|-------------|
| `S` | The set to clear. |

### procedure Merge (Target : CRDT.Lww_Element_Sets.LWW_Element_Set; Source : CRDT.Lww_Element_Sets.LWW_Element_Set)

| Parameter | Description |
|-----------|-------------|
| `Source` | The set to merge from. |
| `Target` | The set to merge into. |

### procedure Remove (S : CRDT.Lww_Element_Sets.LWW_Element_Set; E : CRDT.Lww_Element_Sets.Element_Type; TS : CRDT.Core.Lamport_Time)

| Parameter | Description |
|-----------|-------------|
| `E` | Element to remove. |
| `S` | The set to modify. |
| `TS` | Lamport timestamp for this remove operation. |
