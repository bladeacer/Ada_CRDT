# CRDT.Sync.State_Based.Clocked

Generic state-based sync engine parameterised over any clock strategy.
Mirrors the interface of CRDT.Sync.State_Based but uses the provided
clock strategy's Clock_Time for replica state tracking instead of a
hardcoded VTime + HLC.

The state vector is an array of Clock_Time values, one per replica slot.
Merge applies Max element-wise.  Comparison operations use the
strategy's "<", "=", ">" operators.

Requirements traceability:
- HLR-SYNC-STATE: State-based sync with vector clocks
- HLR-SYNC-DELTA: Delta computation for partial state exchange

> **Note:** 6 public item(s) shown below; 2 private internal item(s) are in the `private` section.

## Types

### type Replica_State

```ada
type Replica_State (Max_Replicas : Positive) is private;
```

### type Sync_Config

```ada
type Sync_Config is record
Max_Replicas : Positive := 32;
Delta_Sync   : Boolean := True;
end record;
```

## Functions

### function Compute_Delta (Local : CRDT.Sync.State_Based.Clocked.Replica_State; Remote_SV : CRDT.Sync.State_Based.Clocked.Clock_Time) return Standard.Natural

| Parameter | Description |
|-----------|-------------|
| `Local` | Local replica state. |
| `Remote_SV` | Remote state vector (Clock_Time per replica). |

**Returns:** Count of items the remote peer is behind (always 0 currently).

### function Create (Config : CRDT.Sync.State_Based.Clocked.Sync_Config) return CRDT.Sync.State_Based.Clocked.Replica_State

| Parameter | Description |
|-----------|-------------|
| `Config` | Sync configuration. |

**Returns:** Freshly initialized replica state.

### function Is_Ahead (SV : CRDT.Sync.State_Based.Clocked.Clock_Time; TS : CRDT.Sync.State_Based.Clocked.Clock_Time) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `SV` | State vector to check. |
| `TS` | Clock timestamp to compare against. |

**Returns:** True if any entry in the SV is at or past TS.

## Procedures

### procedure Merge (Local : CRDT.Sync.State_Based.Clocked.Replica_State; Remote : CRDT.Sync.State_Based.Clocked.Replica_State) `[Depends]`

| Parameter | Description |
|-----------|-------------|
| `Local` | Local state to update. |
| `Remote` | Remote state to merge from. |

---

## Private Section

- **type** `Clock_Array`
- **type** `Replica_State`
