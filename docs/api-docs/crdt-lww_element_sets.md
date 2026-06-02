# CRDT.Lww_Element_Sets

## Types

### LWW_Element_Set

```ada
type LWW_Element_Set (Capacity : Positive) is private;
```

### Timestamp_Array

```ada
type Timestamp_Array is array (Positive range <>) of Timestamp_Entry;
```

### Timestamp_Entry

```ada
type Timestamp_Entry is record    Element : Element_Type;    Time    : Core.Lamport_Time; end record;
```

## Functions

### Contains

```ada
function Contains (S : CRDT.Lww_Element_Sets.LWW_Element_Set; E : CRDT.Lww_Element_Sets.Element_Type) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `S` |  |
| `E` |  |

## Procedures

### Add

```ada
procedure Add (S : CRDT.Lww_Element_Sets.LWW_Element_Set; E : CRDT.Lww_Element_Sets.Element_Type; TS : CRDT.Core.Lamport_Time)
```

| Parameter | Description |
|-----------|-------------|
| `S` |  |
| `E` |  |
| `TS` |  |

### Merge

```ada
procedure Merge (Target : CRDT.Lww_Element_Sets.LWW_Element_Set; Source : CRDT.Lww_Element_Sets.LWW_Element_Set)
```

| Parameter | Description |
|-----------|-------------|
| `Target` |  |
| `Source` |  |

### Remove

```ada
procedure Remove (S : CRDT.Lww_Element_Sets.LWW_Element_Set; E : CRDT.Lww_Element_Sets.Element_Type; TS : CRDT.Core.Lamport_Time)
```

| Parameter | Description |
|-----------|-------------|
| `S` |  |
| `E` |  |
| `TS` |  |
