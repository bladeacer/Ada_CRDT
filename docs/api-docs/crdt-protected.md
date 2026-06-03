# CRDT.Protected

Thread-safe protected-object wrappers for CRDT types. Multiple tasks can concurrently mutate and query CRDT structures without external locking. Built on Ada's native protected objects.

## Types

### type Shared_PN_Counter

```ada
   protected type Shared_PN_Counter (Max_Actors : Positive) is
```

> Thread-safe PN-Counter.

**Public Operations:**

#### procedure Increment

```ada
      procedure Increment (By    : Natural := 1;
                            Actor : Core.Replica_Id);
```

Increment the counter for the given actor.

| Parameter | Description |
|-----------|-------------|
| `Actor` | Replica performing the increment. |
| `By` | Amount to increment. |

#### procedure Decrement

```ada
      procedure Decrement (By    : Natural := 1;
                            Actor : Core.Replica_Id);
```

Decrement the counter for the given actor.

| Parameter | Description |
|-----------|-------------|
| `Actor` | Replica performing the decrement. |
| `By` | Amount to decrement. |

#### procedure Merge

```ada
      procedure Merge (Source : Pn_Counters.PN_Counter);
```

Merge another counter's state into this one.

| Parameter | Description |
|-----------|-------------|
| `Source` | Counter to merge from. |

#### function Value

```ada
      function Value return Integer;
```

Read the current value.

**Returns:** Net counter value.

#### function Snapshot

```ada
      function Snapshot return Pn_Counters.PN_Counter;
```

Take an atomic snapshot of the internal state.

**Returns:** Copy of the current counter state.

**Private State:**

- `C : Pn_Counters.PN_Counter (Max_Actors);`
```ada
end Shared_PN_Counter;
```
