# CRDT.HLC

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
function "<" (Left : CRDT.HLC.HLC_Time; Right : CRDT.HLC.HLC_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### "="

```ada
function "=" (Left : CRDT.HLC.HLC_Time; Right : CRDT.HLC.HLC_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### ">"

```ada
function ">" (Left : CRDT.HLC.HLC_Time; Right : CRDT.HLC.HLC_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `Left` |  |
| `Right` |  |

### Create

```ada
function Create (Node : CRDT.Core.Replica_Id) return CRDT.HLC.Instance
```

| Parameter | Description |
|-----------|-------------|
| `Node` |  |

### Now

```ada
function Now (Clock : CRDT.HLC.Instance) return CRDT.HLC.HLC_Time
```

| Parameter | Description |
|-----------|-------------|
| `Clock` |  |

## Procedures

### Recv

```ada
procedure Recv (Clock : CRDT.HLC.Instance; Remote : CRDT.HLC.HLC_Time)
```

| Parameter | Description |
|-----------|-------------|
| `Clock` |  |
| `Remote` |  |

### Tick

```ada
procedure Tick (Clock : CRDT.HLC.Instance)
```

| Parameter | Description |
|-----------|-------------|
| `Clock` |  |
