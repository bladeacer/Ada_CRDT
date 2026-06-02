# Ada_CRDT.Sync.State_Based

## Types

### Replica_State

```ada
type Replica_State (Max_Replicas : Positive) is private;
```

### Sync_Config

```ada
type Sync_Config is record    Max_Replicas : Positive := 32;    Delta_Sync   : Boolean := True;    HLC_Node     : Core.Replica_Id; end record;
```

## Functions

### Compute_Delta

```ada
function Compute_Delta (Local : Ada_CRDT.Sync.State_Based.Replica_State; Remote_SV : Ada_CRDT.Core.VTime) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `Local` |  |
| `Remote_SV` |  |

### Create

```ada
function Create (Config : Ada_CRDT.Sync.State_Based.Sync_Config) return Ada_CRDT.Sync.State_Based.Replica_State
```

| Parameter | Description |
|-----------|-------------|
| `Config` |  |

### Is_Ahead

```ada
function Is_Ahead (SV : Ada_CRDT.Core.VTime; TS : Ada_CRDT.Core.Lamport_Time) return Standard.Boolean
```

| Parameter | Description |
|-----------|-------------|
| `SV` |  |
| `TS` |  |

## Procedures

### Merge

```ada
procedure Merge (Local : Ada_CRDT.Sync.State_Based.Replica_State; Remote : Ada_CRDT.Sync.State_Based.Replica_State)
```

| Parameter | Description |
|-----------|-------------|
| `Local` |  |
| `Remote` |  |
