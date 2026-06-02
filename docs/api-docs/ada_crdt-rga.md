# Ada_CRDT.Rga

## Types

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
function "=" (Left : Ada_CRDT.Rga.RGA; Right : Ada_CRDT.Rga.RGA) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### Count

```ada
function Count (R : Ada_CRDT.Rga.RGA) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

### Get

```ada
function Get (R : Ada_CRDT.Rga.RGA; Pos : Standard.Positive) return Ada_CRDT.Rga.Element_Type
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |

### Length

```ada
function Length (R : Ada_CRDT.Rga.RGA) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

### Size

```ada
function Size (R : Ada_CRDT.Rga.RGA) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

## Procedures

### Compact

```ada
procedure Compact (R : Ada_CRDT.Rga.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |

### Compute_State_Vector

```ada
procedure Compute_State_Vector (R : Ada_CRDT.Rga.RGA; SV : Ada_CRDT.Rga.Replica_Max_Seq_Array; Count : Standard.Natural)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `SV` |  |
| `Count` |  |

### Delete

```ada
procedure Delete (R : Ada_CRDT.Rga.RGA; Pos : Standard.Positive)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |

### Delete_Node

```ada
procedure Delete_Node (R : Ada_CRDT.Rga.RGA; Id : Ada_CRDT.Rga.Node_Id)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Id` |  |

### Insert

```ada
procedure Insert (R : Ada_CRDT.Rga.RGA; Pos : Standard.Positive; Id : Ada_CRDT.Rga.Node_Id; Value : Ada_CRDT.Rga.Element_Type)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |
| `Id` |  |
| `Value` |  |

### Insert_Bulk

```ada
procedure Insert_Bulk (R : Ada_CRDT.Rga.RGA; Pos : Standard.Positive; Id : Ada_CRDT.Rga.Node_Id; Values : Ada_CRDT.Rga.Element_Array)
```

| Parameter | Description |
|-----------|-------------|
| `R` |  |
| `Pos` |  |
| `Id` |  |
| `Values` |  |

### Merge

```ada
procedure Merge (Target : Ada_CRDT.Rga.RGA; Source : Ada_CRDT.Rga.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `Target` |  |
| `Source` |  |

### Read_RGA

```ada
procedure Read_RGA (Stream : Ada.Streams.Root_Stream_Type; Item : Ada_CRDT.Rga.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `Stream` |  |
| `Item` |  |

### Sync_Delta

```ada
procedure Sync_Delta (Target : Ada_CRDT.Rga.RGA; Source : Ada_CRDT.Rga.RGA; Remote_SV : Ada_CRDT.Rga.Replica_Max_Seq_Array; SV_Count : Standard.Natural)
```

| Parameter | Description |
|-----------|-------------|
| `Target` |  |
| `Source` |  |
| `Remote_SV` |  |
| `SV_Count` |  |

### Write_RGA

```ada
procedure Write_RGA (Stream : Ada.Streams.Root_Stream_Type; Item : Ada_CRDT.Rga.RGA)
```

| Parameter | Description |
|-----------|-------------|
| `Stream` |  |
| `Item` |  |
