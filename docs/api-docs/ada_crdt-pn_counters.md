# Ada_CRDT.Pn_Counters

## Types

### Counter_Range

```ada
subtype Counter_Range is Natural;
```

### PN_Counter

```ada
type PN_Counter (Max_Actors : Positive) is private with   Default_Initial_Condition;
```

## Functions

### Can_Decrement

```ada
function Can_Decrement (C : Ada_CRDT.Pn_Counters.PN_Counter; By : Ada_CRDT.Pn_Counters.Counter_Range) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `C` |  |
| `By` |  |

### Can_Increment

```ada
function Can_Increment (C : Ada_CRDT.Pn_Counters.PN_Counter; By : Ada_CRDT.Pn_Counters.Counter_Range) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `C` |  |
| `By` |  |

### Value

```ada
function Value (C : Ada_CRDT.Pn_Counters.PN_Counter) return Standard.Integer
```

| Parameter | Description |
|-----------|-------------|
| `C` |  |

## Procedures

### Decrement

```ada
procedure Decrement (C : Ada_CRDT.Pn_Counters.PN_Counter; By : Ada_CRDT.Pn_Counters.Counter_Range; Actor : Ada_CRDT.Core.Replica_Id)
```

| Parameter | Description |
|-----------|-------------|
| `C` |  |
| `By` |  |
| `Actor` |  |

### Increment

```ada
procedure Increment (C : Ada_CRDT.Pn_Counters.PN_Counter; By : Ada_CRDT.Pn_Counters.Counter_Range; Actor : Ada_CRDT.Core.Replica_Id)
```

| Parameter | Description |
|-----------|-------------|
| `C` |  |
| `By` |  |
| `Actor` |  |

### Merge

```ada
procedure Merge (Target : Ada_CRDT.Pn_Counters.PN_Counter; Source : Ada_CRDT.Pn_Counters.PN_Counter)
```

| Parameter | Description |
|-----------|-------------|
| `Target` |  |
| `Source` |  |
