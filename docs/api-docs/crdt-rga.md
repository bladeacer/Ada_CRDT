# CRDT.Rga

Replicated Growable Array (RGA) - default Yjs-style chunk-based engine. Contiguous elements written by the same replica are stored in sized blocks (Max_Stride), dramatically reducing allocation overhead vs. per-character nodes. Default sequence engine for CRDT. Industry equivalence: Yjs/YATA algorithm. Supports structural splitting, state vector delta sync, tombstone garbage collection, and protocol-versioned serialization.

> **Note:** 23 public item(s) shown below; 4 private internal item(s) are in the `private` section.

## Types

### type Element_Array

```ada
type Element_Array is array (Positive range <>) of Element_Type;
```

### type Element_Store

```ada
type Element_Store is array (1 .. Max_Stride) of Element_Type;
```

### type Item_Array

```ada
type Item_Array is array (Positive range <>) of RGA_Item;
```

### type Node_Id

```ada
type Node_Id is record
Replica : Core.Replica_Id;
Seq     : Natural;
end record;
```

### type Replica_Max_Seq

```ada
type Replica_Max_Seq is record
Replica : Core.Replica_Id;
Max_Seq : Natural;
end record;
```

### type Replica_Max_Seq_Array

```ada
type Replica_Max_Seq_Array is array (Positive range <>) of Replica_Max_Seq;
```

### type RGA

```ada
type RGA (Item_Capacity : Positive) is record
Items : Item_Array (1 .. Item_Capacity);
Head  : Natural := 0;
Count : Natural := 0;
Free  : Natural := 0;
Total : Natural := 0;
end record;
```

### type RGA_Item

```ada
type RGA_Item is record
Id      : Node_Id;
Content : Element_Store;
Len     : Natural := 0;
Deleted : Boolean := False;
Next    : Natural := 0;
end record;
```

## Functions

### function "=" (Left : CRDT.Rga.RGA; Right : CRDT.Rga.RGA) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Left` | Left sequence operand. |
| `Right` | Right sequence operand. |

**Returns:** True if both sequences are identical.

### function Count (R : CRDT.Rga.RGA) return Standard.Natural

| Parameter | Description |
|-----------|-------------|
| `R` | The sequence to examine. |

**Returns:** Count of allocated nodes (includes tombstones).

### function Get (R : CRDT.Rga.RGA; Pos : Standard.Positive) return CRDT.Rga.Element_Type

| Parameter | Description |
|-----------|-------------|
| `Pos` | 1-based position. |
| `R` | The sequence. |

**Returns:** Element at that position.

### function Length (R : CRDT.Rga.RGA) return Standard.Natural

| Parameter | Description |
|-----------|-------------|
| `R` | The sequence to examine. |

**Returns:** Number of non-deleted elements.

### function Size (R : CRDT.Rga.RGA) return Standard.Natural

| Parameter | Description |
|-----------|-------------|
| `R` | The sequence to examine. |

**Returns:** Number of non-deleted elements.

## Procedures

### procedure Compact (R : CRDT.Rga.RGA)

| Parameter | Description |
|-----------|-------------|
| `R` | The sequence to compact. |

### procedure Compute_State_Vector (R : CRDT.Rga.RGA; SV : CRDT.Rga.Replica_Max_Seq_Array; Count : Standard.Natural)

| Parameter | Description |
|-----------|-------------|
| `Count` | Number of entries written to SV. |
| `R` | The sequence to analyze. |
| `SV` | Output array of per-replica max seq values. |

### procedure Delete (R : CRDT.Rga.RGA; Pos : Standard.Positive)

| Parameter | Description |
|-----------|-------------|
| `Pos` | 1-based position of element to delete. |
| `R` | The sequence to modify. |

### procedure Delete_Node (R : CRDT.Rga.RGA; Id : CRDT.Rga.Node_Id)

| Parameter | Description |
|-----------|-------------|
| `Id` | Node identifier of the item to delete. |
| `R` | The sequence to modify. |

### procedure Insert (R : CRDT.Rga.RGA; Pos : Standard.Positive; Id : CRDT.Rga.Node_Id; Value : CRDT.Rga.Element_Type)

| Parameter | Description |
|-----------|-------------|
| `Id` | Unique node identifier for this element. |
| `Pos` | 1-based insertion position. |
| `R` | The sequence to modify. |
| `Value` | Element to insert. |

### procedure Insert_Bulk (R : CRDT.Rga.RGA; Pos : Standard.Positive; Id : CRDT.Rga.Node_Id; Values : CRDT.Rga.Element_Array)

| Parameter | Description |
|-----------|-------------|
| `Id` | Unique node identifier (used for the first element). |
| `Pos` | 1-based insertion position. |
| `R` | The sequence to modify. |
| `Values` | Array of elements to insert contiguously. |

### procedure Merge (Target : CRDT.Rga.RGA; Source : CRDT.Rga.RGA)

| Parameter | Description |
|-----------|-------------|
| `Source` | The sequence to merge from. |
| `Target` | The sequence to merge into. |

### procedure Read_RGA (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Rga.RGA)

| Parameter | Description |
|-----------|-------------|
| `Item` | Deserialized RGA. |
| `Stream` | Input stream. |

### procedure Sync_Delta (Target : CRDT.Rga.RGA; Source : CRDT.Rga.RGA; Remote_SV : CRDT.Rga.Replica_Max_Seq_Array; SV_Count : Standard.Natural)

| Parameter | Description |
|-----------|-------------|
| `Remote_SV` | State vector of the remote peer. |
| `SV_Count` | Number of entries in Remote_SV. |
| `Source` | The sequence to merge from. |
| `Target` | The sequence to merge into. |

### procedure Write_RGA (Stream : Ada.Streams.Root_Stream_Type; Item : CRDT.Rga.RGA)

| Parameter | Description |
|-----------|-------------|
| `Item` | RGA to serialize. |
| `Stream` | Output stream. |

---

## Private Section

- **type** `Element_Store`
- **type** `RGA_Item`
- **type** `Item_Array`
- **type** `RGA`
