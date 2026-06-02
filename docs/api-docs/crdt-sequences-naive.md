# CRDT.Sequences.Naive

## Types

### Cursor

```ada
type Cursor is private;
```

### Element_Array

```ada
type Element_Array is array (Positive range <>) of Element_Type;
```

### Node_Id

```ada
type Node_Id is record    Replica : Core.Replica_Id;    Seq     : Natural; end record;
```

### RGA

```ada
type RGA (Capacity : Positive) is private;
```

## Functions

### "="

```ada
function "=" (Left : CRDT.Sequences.Naive.RGA; Right : CRDT.Sequences.Naive.RGA) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### Count

```ada
function Count (R : CRDT.Sequences.Naive.RGA) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

### Element

```ada
function Element (Container : CRDT.Sequences.Naive.RGA; Position : CRDT.Sequences.Naive.Cursor) return CRDT.Sequences.Naive.Element_Type
```

| Parameter | Description |
|-----------|-------------|
| `Container` |  |
| `Position` |  |

### First

```ada
function First (Container : CRDT.Sequences.Naive.RGA) return CRDT.Sequences.Naive.Cursor
```

| Parameter | Description |
|-----------|-------------|
| `Container` |  |

### Get

```ada
function Get (R : CRDT.Sequences.Naive.RGA; Pos : Standard.Positive) return CRDT.Sequences.Naive.Element_Type
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |

### Has_Element

```ada
function Has_Element (Position : CRDT.Sequences.Naive.Cursor) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Position` |  |

### Has_Element

```ada
function Has_Element (Container : CRDT.Sequences.Naive.RGA; Position : CRDT.Sequences.Naive.Cursor) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Container` |  |
| `Position` |  |

### Length

```ada
function Length (R : CRDT.Sequences.Naive.RGA) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

### Size

```ada
function Size (R : CRDT.Sequences.Naive.RGA) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

## Procedures

### Compact

```ada
procedure Compact (R : CRDT.Sequences.Naive.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

### Delete

```ada
procedure Delete (R : CRDT.Sequences.Naive.RGA; Pos : Standard.Positive)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |

### Delete_Node

```ada
procedure Delete_Node (R : CRDT.Sequences.Naive.RGA; Id : CRDT.Sequences.Naive.Node_Id)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Id` |  |

### Insert

```ada
procedure Insert (R : CRDT.Sequences.Naive.RGA; Pos : Standard.Positive; Id : CRDT.Sequences.Naive.Node_Id; Value : CRDT.Sequences.Naive.Element_Type)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |
| `Id` |  |
| `Value` |  |

### Insert_Bulk

```ada
procedure Insert_Bulk (R : CRDT.Sequences.Naive.RGA; Pos : Standard.Positive; Id : CRDT.Sequences.Naive.Node_Id; Values : CRDT.Sequences.Naive.Element_Array)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |
| `Id` |  |
| `Values` |  |

### Merge

```ada
procedure Merge (Target : CRDT.Sequences.Naive.RGA; Source : CRDT.Sequences.Naive.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `Target` |  |
| `Source` |  |

### Next

```ada
procedure Next (Container : CRDT.Sequences.Naive.RGA; Position : CRDT.Sequences.Naive.Cursor)
```

| Parameter | Description |
|-----------|-------------|
| `Container` |  |
| `Position` |  |

### Read_RGA

```ada
procedure Read_RGA (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Sequences.Naive.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `Stream` |  |
| `Item` |  |

### Write_RGA

```ada
procedure Write_RGA (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Sequences.Naive.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `Stream` |  |
| `Item` |  |
