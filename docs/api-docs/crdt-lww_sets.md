# CRDT.Lww_Sets

Generic Last-Writer-Wins Element Set over any clock strategy.
Stores (element, Clock_Time) pairs for add and remove sets.
An element is present if its add-timestamp exceeds its remove-timestamp.

> **Note:** 14 public item(s) shown below; 1 private internal item(s) are in the `private` section.

## Types

### type LWW_Clocked_Set

```ada
type LWW_Clocked_Set (Capacity : Positive) is record
Add_Array    : Timestamp_Array (1 .. Capacity);
Add_Size     : Natural := 0;
Remove_Array : Timestamp_Array (1 .. Capacity);
Remove_Size  : Natural := 0;
end record;
```

### type Timestamp_Array

```ada
type Timestamp_Array is array (Positive range <>) of Timestamp_Entry;
```

### type Timestamp_Entry

```ada
type Timestamp_Entry is record
Element : Element_Type;
Time    : Clock_Time;
end record;
```

## Functions

### function Add_Count (S : CRDT.Lww_Sets.LWW_Clocked_Set) return Standard.Natural `[Post]`

| Parameter | Description |
|-----------|-------------|
| `S` | The set to query. |

**Returns:** Add entry count, always <= Capacity.

### function Add_Count (S : CRDT.Lww_Sets.LWW_Clocked_Set) return Standard.Natural `[Post]`

| Parameter | Description |
|-----------|-------------|
| `S` | The set to query. |

**Returns:** Add entry count, always <= Capacity.

### function Contains (S : CRDT.Lww_Sets.LWW_Clocked_Set; E : CRDT.Lww_Sets.Element_Type) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `E` | Element to look up. |
| `S` | The set to query. |

**Returns:** True if element is considered present.

### function Remove_Count (S : CRDT.Lww_Sets.LWW_Clocked_Set) return Standard.Natural `[Post]`

| Parameter | Description |
|-----------|-------------|
| `S` | The set to query. |

**Returns:** Remove entry count, always <= Capacity.

### function Remove_Count (S : CRDT.Lww_Sets.LWW_Clocked_Set) return Standard.Natural `[Post]`

| Parameter | Description |
|-----------|-------------|
| `S` | The set to query. |

**Returns:** Remove entry count, always <= Capacity.

## Procedures

### procedure Add (S : CRDT.Lww_Sets.LWW_Clocked_Set; E : CRDT.Lww_Sets.Element_Type; TS : CRDT.Lww_Sets.Clock_Time) `[Post]` `[Depends]`

| Parameter | Description |
|-----------|-------------|
| `E` | Element to add. |
| `S` | The set to modify. |
| `TS` | Clock timestamp for this add operation. |

### procedure Clear (S : CRDT.Lww_Sets.LWW_Clocked_Set) `[Post]` `[Depends]`

| Parameter | Description |
|-----------|-------------|
| `S` | The set to clear. |

### procedure Merge (Target : CRDT.Lww_Sets.LWW_Clocked_Set; Source : CRDT.Lww_Sets.LWW_Clocked_Set) `[Post]` `[Depends]`

| Parameter | Description |
|-----------|-------------|
| `Source` | The set to merge from. |
| `Target` | The set to merge into. |

### procedure Read_LWW_Clocked_Set (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Lww_Sets.LWW_Clocked_Set)

| Parameter | Description |
|-----------|-------------|
| `Item` | Set to populate from stream data. |
| `Stream` | Input stream to read from. |

### procedure Remove (S : CRDT.Lww_Sets.LWW_Clocked_Set; E : CRDT.Lww_Sets.Element_Type; TS : CRDT.Lww_Sets.Clock_Time) `[Post]` `[Depends]`

| Parameter | Description |
|-----------|-------------|
| `E` | Element to remove. |
| `S` | The set to modify. |
| `TS` | Clock timestamp for this remove operation. |

### procedure Write_LWW_Clocked_Set (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Lww_Sets.LWW_Clocked_Set)

| Parameter | Description |
|-----------|-------------|
| `Item` | Set to serialize. |
| `Stream` | Output stream to write to. |

---

## Private Section

- **type** `LWW_Clocked_Set`
