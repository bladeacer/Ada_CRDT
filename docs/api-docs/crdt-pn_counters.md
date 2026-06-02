# CRDT.Pn_Counters

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
function Can_Decrement (C : CRDT.Pn_Counters.PN_Counter; By : CRDT.Pn_Counters.Counter_Range) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `C` |  |
| `By` |  |

### Can_Increment

```ada
function Can_Increment (C : CRDT.Pn_Counters.PN_Counter; By : CRDT.Pn_Counters.Counter_Range) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `C` |  |
| `By` |  |

### Value

```ada
function Value (C : CRDT.Pn_Counters.PN_Counter) return Standard.Integer
```

| Parameter | Description |
|-----------|-------------|
| `C` |  |

## Procedures

### Decrement

```ada
procedure Decrement (C : CRDT.Pn_Counters.PN_Counter; By : CRDT.Pn_Counters.Counter_Range; Actor : CRDT.Core.Replica_Id)
```

| Parameter | Description |
|-----------|-------------|
| `C` |  |
| `By` |  |
| `Actor` |  |

### Increment

```ada
procedure Increment (C : CRDT.Pn_Counters.PN_Counter; By : CRDT.Pn_Counters.Counter_Range; Actor : CRDT.Core.Replica_Id)
```

| Parameter | Description |
|-----------|-------------|
| `C` |  |
| `By` |  |
| `Actor` |  |

### Merge

```ada
procedure Merge (Target : CRDT.Pn_Counters.PN_Counter; Source : CRDT.Pn_Counters.PN_Counter)
```

| Parameter | Description |
|-----------|-------------|
| `Target` |  |
| `Source` |  |
