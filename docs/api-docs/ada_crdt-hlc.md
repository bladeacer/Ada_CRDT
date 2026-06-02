# Ada_CRDT.HLC

## Types

### HLC_Time

```ada
type HLC_Time is new Core.HLC_Time;
```

### Instance

```ada
type Instance is private;
```

## Functions

### "<"

```ada
function "<" (Left : Ada_CRDT.HLC.HLC_Time; Right : Ada_CRDT.HLC.HLC_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### "="

```ada
function "=" (Left : Ada_CRDT.HLC.HLC_Time; Right : Ada_CRDT.HLC.HLC_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### ">"

```ada
function ">" (Left : Ada_CRDT.HLC.HLC_Time; Right : Ada_CRDT.HLC.HLC_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### Create

```ada
function Create (Node : Ada_CRDT.Core.Replica_Id) return Ada_CRDT.HLC.Instance
```

| Parameter | Description |
|-----------|-------------|
| `Node` |  |

### Now

```ada
function Now (Clock : Ada_CRDT.HLC.Instance) return Ada_CRDT.HLC.HLC_Time
```

| Parameter | Description |
|-----------|-------------|
| `Clock` |  |

## Procedures

### Recv

```ada
procedure Recv (Clock : Ada_CRDT.HLC.Instance; Remote : Ada_CRDT.HLC.HLC_Time)
```

| Parameter | Description |
|-----------|-------------|
| `Clock` |  |
| `Remote` |  |

### Tick

```ada
procedure Tick (Clock : Ada_CRDT.HLC.Instance)
```

| Parameter | Description |
|-----------|-------------|
| `Clock` |  |
