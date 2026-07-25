# CRDT.Lww_Sets

Generic Last-Writer-Wins Element Set over any clock strategy.
Stores (element, Clock_Time) pairs for add and remove sets.
An element is present iff its add-timestamp exceeds its remove-timestamp.

> **Note:** 12 public item(s) shown below; 1 private internal item(s) are in the `private` section.

## Types

### type LWW_Clocked_Set

```ada
type LWW_Clocked_Set (Capacity : Positive) is private;
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
| `S` |  |

### function Contains (S : CRDT.Lww_Sets.LWW_Clocked_Set; E : CRDT.Lww_Sets.Element_Type) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `E` |  |
| `S` |  |

### function Remove_Count (S : CRDT.Lww_Sets.LWW_Clocked_Set) return Standard.Natural `[Post]`

| Parameter | Description |
|-----------|-------------|
| `S` |  |

## Procedures

### procedure Add (S : CRDT.Lww_Sets.LWW_Clocked_Set; E : CRDT.Lww_Sets.Element_Type; TS : CRDT.Lww_Sets.Clock_Time) `[Post]` `[Depends]`

| Parameter | Description |
|-----------|-------------|
| `E` |  |
| `S` |  |
| `TS` |  |

### procedure Clear (S : CRDT.Lww_Sets.LWW_Clocked_Set) `[Post]` `[Depends]`

| Parameter | Description |
|-----------|-------------|
| `S` |  |

### procedure Merge (Target : CRDT.Lww_Sets.LWW_Clocked_Set; Source : CRDT.Lww_Sets.LWW_Clocked_Set) `[Post]` `[Depends]`

| Parameter | Description |
|-----------|-------------|
| `Source` |  |
| `Target` |  |

### procedure Read_LWW_Clocked_Set (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Lww_Sets.LWW_Clocked_Set)

| Parameter | Description |
|-----------|-------------|
| `Item` |  |
| `Stream` |  |

### procedure Remove (S : CRDT.Lww_Sets.LWW_Clocked_Set; E : CRDT.Lww_Sets.Element_Type; TS : CRDT.Lww_Sets.Clock_Time) `[Post]` `[Depends]`

| Parameter | Description |
|-----------|-------------|
| `E` |  |
| `S` |  |
| `TS` |  |

### procedure Write_LWW_Clocked_Set (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Lww_Sets.LWW_Clocked_Set)

| Parameter | Description |
|-----------|-------------|
| `Item` |  |
| `Stream` |  |

---

## Private Section

- **type** `LWW_Clocked_Set`
