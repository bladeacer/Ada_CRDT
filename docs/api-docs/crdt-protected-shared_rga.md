# CRDT.Protected.Shared_RGA

Thread-safe RGA (chunk-based Yjs engine).

## Types

### type Shared_RGA_Obj

```ada
      protected type Shared_RGA_Obj (Capacity : Positive) is
```

> Thread-safe mutable RGA sequence.

**Public Operations:**

#### procedure Insert

```ada
         procedure Insert (Pos   : Positive;
                            Id    : RGA_Pkg.Node_Id;
                            Value : Element_Type);
```

Insert element at position.

| Parameter | Description |
|-----------|-------------|
| `Id` | Unique node identifier. |
| `Pos` | 1-based insertion position. |
| `Value` | Element to insert. |

#### procedure Insert_Bulk

```ada
         procedure Insert_Bulk (Pos    : Positive;
                                 Id     : RGA_Pkg.Node_Id;
                                 Values : RGA_Pkg.Element_Array);
```

Insert multiple contiguous elements.

| Parameter | Description |
|-----------|-------------|
| `Id` | Unique node identifier for first element. |
| `Pos` | 1-based insertion position. |
| `Values` | Array of elements to insert. |

#### procedure Delete

```ada
         procedure Delete (Pos : Positive);
```

Delete element at position.

| Parameter | Description |
|-----------|-------------|
| `Pos` | 1-based position to delete. |

#### procedure Merge

```ada
         procedure Merge (Source : RGA_Pkg.RGA);
```

Merge another sequence's state into this one.

| Parameter | Description |
|-----------|-------------|
| `Source` | Sequence to merge from. |

#### procedure Compact

```ada
         procedure Compact;
```

Compact tombstones.

#### function Get

```ada
         function Get (Pos : Positive) return Element_Type;
```

Get element at position.

| Parameter | Description |
|-----------|-------------|
| `Pos` | 1-based position. |

**Returns:** Element at that position.

#### function Size

```ada
         function Size return Natural;
```

Current visible element count.

**Returns:** Number of non-deleted elements.

#### function Snapshot

```ada
         function Snapshot return RGA_Pkg.RGA;
```

Take an atomic snapshot.

**Returns:** Copy of the current sequence state.

**Private State:**

- `R : RGA_Pkg.RGA (Capacity);`
```ada
end Shared_RGA_Obj;
```
