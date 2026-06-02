# CRDT.Sync.Op_Based

## Types

### Op_Kind

```ada
type Op_Kind is (Op_Insert, Op_Delete, Op_Increment, Op_Decrement);
```

### Op_Log

```ada
type Op_Log (Capacity : Positive) is private;
```

### Operation

```ada
type Operation (Kind : Op_Kind := Op_Insert) is record    Seq     : Natural;    Node    : Core.Replica_Id;    case Kind is       when Op_Insert =>          Position : Positive;       when Op_Delete =>          Del_Position : Positive;       when Op_Increment | Op_Decrement =>          Amount    : Natural;          Actor     : Core.Replica_Id;    end case; end record;
```

## Functions

### Get

```ada
function Get (Log : CRDT.Sync.Op_Based.Op_Log; Index : Standard.Positive) return CRDT.Sync.Op_Based.Operation
```

| Parameter | Description |
|-----------|-------------|
| `Log` |  |
| `Index` |  |

### Size

```ada
function Size (Log : CRDT.Sync.Op_Based.Op_Log) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `Log` |  |

## Procedures

### Acknowledge

```ada
procedure Acknowledge (Log : CRDT.Sync.Op_Based.Op_Log; Up_To_Seq : Standard.Natural)
```

| Parameter | Description |
|-----------|-------------|
| `Log` |  |
| `Up_To_Seq` |  |

### Append

```ada
procedure Append (Log : CRDT.Sync.Op_Based.Op_Log; Op : CRDT.Sync.Op_Based.Operation)
```

| Parameter | Description |
|-----------|-------------|
| `Log` |  |
| `Op` |  |

### Compact

```ada
procedure Compact (Log : CRDT.Sync.Op_Based.Op_Log)
```

| Parameter | Description |
|-----------|-------------|
| `Log` |  |
