# CRDT.Sequences.Yjs

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

### Replica_Max_Seq

```ada
type Replica_Max_Seq is record    Replica : Core.Replica_Id;    Max_Seq : Natural; end record;
```

### Replica_Max_Seq_Array

```ada
type Replica_Max_Seq_Array is array (Positive range <>) of Replica_Max_Seq;
```

### RGA

```ada
type RGA (Item_Capacity : Positive) is private;
```

## Functions

### "="

```ada
function "=" (Left : CRDT.Sequences.Yjs.RGA; Right : CRDT.Sequences.Yjs.RGA) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### Count

```ada
function Count (R : CRDT.Sequences.Yjs.RGA) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

### Element

```ada
function Element (Container : CRDT.Sequences.Yjs.RGA; Position : CRDT.Sequences.Yjs.Cursor) return CRDT.Sequences.Yjs.Element_Type
```

| Parameter | Description |
|-----------|-------------|
| `Container` |  |
| `Position` |  |

### First

```ada
function First (Container : CRDT.Sequences.Yjs.RGA) return CRDT.Sequences.Yjs.Cursor
```

| Parameter | Description |
|-----------|-------------|
| `Container` |  |

### Get

```ada
function Get (R : CRDT.Sequences.Yjs.RGA; Pos : Standard.Positive) return CRDT.Sequences.Yjs.Element_Type
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |

### Has_Element

```ada
function Has_Element (Position : CRDT.Sequences.Yjs.Cursor) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Position` |  |

### Has_Element

```ada
function Has_Element (Container : CRDT.Sequences.Yjs.RGA; Position : CRDT.Sequences.Yjs.Cursor) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Container` |  |
| `Position` |  |

### Length

```ada
function Length (R : CRDT.Sequences.Yjs.RGA) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

### Size

```ada
function Size (R : CRDT.Sequences.Yjs.RGA) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

## Procedures

### Compact

```ada
procedure Compact (R : CRDT.Sequences.Yjs.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

### Compute_State_Vector

```ada
procedure Compute_State_Vector (R : CRDT.Sequences.Yjs.RGA; SV : CRDT.Sequences.Yjs.Replica_Max_Seq_Array; Count : Standard.Natural)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `SV` |  |
| `Count` |  |

### Delete

```ada
procedure Delete (R : CRDT.Sequences.Yjs.RGA; Pos : Standard.Positive)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |

### Delete_Node

```ada
procedure Delete_Node (R : CRDT.Sequences.Yjs.RGA; Id : CRDT.Sequences.Yjs.Node_Id)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Id` |  |

### Insert

```ada
procedure Insert (R : CRDT.Sequences.Yjs.RGA; Pos : Standard.Positive; Id : CRDT.Sequences.Yjs.Node_Id; Value : CRDT.Sequences.Yjs.Element_Type)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |
| `Id` |  |
| `Value` |  |

### Insert_Bulk

```ada
procedure Insert_Bulk (R : CRDT.Sequences.Yjs.RGA; Pos : Standard.Positive; Id : CRDT.Sequences.Yjs.Node_Id; Values : CRDT.Sequences.Yjs.Element_Array)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |
| `Id` |  |
| `Values` |  |

### Merge

```ada
procedure Merge (Target : CRDT.Sequences.Yjs.RGA; Source : CRDT.Sequences.Yjs.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `Target` |  |
| `Source` |  |

### Next

```ada
procedure Next (Container : CRDT.Sequences.Yjs.RGA; Position : CRDT.Sequences.Yjs.Cursor)
```

| Parameter | Description |
|-----------|-------------|
| `Container` |  |
| `Position` |  |

### Read_RGA

```ada
procedure Read_RGA (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Sequences.Yjs.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `Stream` |  |
| `Item` |  |

### Sync_Delta

```ada
procedure Sync_Delta (Target : CRDT.Sequences.Yjs.RGA; Source : CRDT.Sequences.Yjs.RGA; Remote_SV : CRDT.Sequences.Yjs.Replica_Max_Seq_Array; SV_Count : Standard.Natural)
```

| Parameter | Description |
|-----------|-------------|
| `Target` |  |
| `Source` |  |
| `Remote_SV` |  |
| `SV_Count` |  |

### Write_RGA

```ada
procedure Write_RGA (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Sequences.Yjs.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `Stream` |  |
| `Item` |  |
