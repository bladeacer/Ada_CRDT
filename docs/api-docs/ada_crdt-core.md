# Ada_CRDT.Core

## Types

### HLC_Time

```ada
type HLC_Time is record    Wall : Ada.Calendar.Time;    Node : Replica_Id;    Log  : Natural := 0; end record;
```

### Lamport_Time

```ada
type Lamport_Time is record    Stamp : Natural := 0;    Node  : Replica_Id := 1; end record;
```

### Replica_Id

```ada
type Replica_Id is new Positive;
```

### VTime

```ada
type VTime is array (Positive range <>) of Natural with   Default_Component_Value => 0;
```

## Functions

### "<"

```ada
function "<" (Left : Ada_CRDT.Core.Lamport_Time; Right : Ada_CRDT.Core.Lamport_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### "="

```ada
function "=" (Left : Ada_CRDT.Core.Lamport_Time; Right : Ada_CRDT.Core.Lamport_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### ">"

```ada
function ">" (Left : Ada_CRDT.Core.Lamport_Time; Right : Ada_CRDT.Core.Lamport_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### HLC_Eq

```ada
function HLC_Eq (Left : Ada_CRDT.Core.HLC_Time; Right : Ada_CRDT.Core.HLC_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### HLC_Less

```ada
function HLC_Less (Left : Ada_CRDT.Core.HLC_Time; Right : Ada_CRDT.Core.HLC_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### HLC_Max

```ada
function HLC_Max (Left : Ada_CRDT.Core.HLC_Time; Right : Ada_CRDT.Core.HLC_Time) return Ada_CRDT.Core.HLC_Time
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### Lamport_Max

```ada
function Lamport_Max (Left : Ada_CRDT.Core.Lamport_Time; Right : Ada_CRDT.Core.Lamport_Time) return Ada_CRDT.Core.Lamport_Time
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### New_Replica_Id

```ada
function New_Replica_Id return Ada_CRDT.Core.Replica_Id
```

### VTime_Eq

```ada
function VTime_Eq (Left : Ada_CRDT.Core.VTime; Right : Ada_CRDT.Core.VTime) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### VTime_Leq

```ada
function VTime_Leq (Left : Ada_CRDT.Core.VTime; Right : Ada_CRDT.Core.VTime) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### VTime_Less

```ada
function VTime_Less (Left : Ada_CRDT.Core.VTime; Right : Ada_CRDT.Core.VTime) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

## Procedures

### VTime_Increment

```ada
procedure VTime_Increment (VT : Ada_CRDT.Core.VTime; Idx : Standard.Positive)
```

| Parameter | Description |
|-----------|-------------|
| `VT` |  |
| `Idx` |  |

### VTime_Merge

```ada
procedure VTime_Merge (Target : Ada_CRDT.Core.VTime; Source : Ada_CRDT.Core.VTime)
```

| Parameter | Description |
|-----------|-------------|
| `Target` |  |
| `Source` |  |
