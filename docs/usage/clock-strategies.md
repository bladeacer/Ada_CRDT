# Clock strategies: Lamport, Vector, and Matrix

A clock strategy is a generic parameter of `CRDT.Lww_Sets` and the clocked
sync layers. All strategies implement one uniform interface: a comparison
operator `" < "`, an equality operator, a `Max` function, an `Increment`
procedure, and `Write_Clock` / `Read_Clock` serialization. You can exchange
one strategy for another without changing the container code around it. The
[API reference](../api-docs/crdt-clocks.md) lists the shared contracts.

## The strategies

| Strategy | Package | State | Trade-off |
|----------|---------|-------|-----------|
| Lamport | `CRDT.Clocks.Lamport` | One scalar stamp plus node id | Smallest wire size; orders causally but cannot detect concurrency |
| Vector | `CRDT.Clocks.Vector` | One counter per replica | Detects concurrency; grows with the replica count |
| Matrix | `CRDT.Clocks.Matrix` | One counter per replica pair | Knows what each replica knows; grows with the square of the replica count |

```ada
--  Vector strategy (recommended).
with CRDT.Clocks.Vector;
package V is new CRDT.Clocks.Vector (Max_Replicas => 8);

--  Lamport strategy.
with CRDT.Clocks.Lamport;
package L is new CRDT.Clocks.Lamport (Max_Replicas => 8);

--  Matrix strategy.
with CRDT.Clocks.Matrix;
package M is new CRDT.Clocks.Matrix (Max_Replicas => 8);
```

Pass the strategy to a container:

```ada
package S is new CRDT.Lww_Sets
  (Element_Type => Integer,
   Max_Set_Size => 100,
   Clock        => V.Clock_Time,
   Clk_Kind     => CRDT.Clocks.Clock_Vector,
   ">"          => V.">",
   Max          => V.Max,
   Write_Clock  => V.Write_Clock,
   Read_Clock   => V.Read_Clock);
```

## Lamport: scalar stamps

The Lamport strategy keeps one scalar counter. It orders events that happen
in a causal chain, and it breaks ties with the node id. It cannot tell
whether two stamps are concurrent, so it resolves every conflict by the
total order. Choose it when the wire size must be minimal and a total order
is acceptable.

## Vector: per-replica counters

The Vector strategy keeps one counter per replica. It detects concurrency:
two states are concurrent when neither dominates the other entry by entry.
Choose it as the default. It gives merge and delta-sync layers the
information they need, at a wire cost that grows linearly with the replica
count.

## Matrix: per-pair counters

The Matrix strategy keeps one counter per ordered replica pair. Entry
`(I, J)` holds what replica `I` knows about replica `J`. A replica can
answer what another replica knows, which supports garbage-collection
coordination. Choose it when that knowledge is worth the quadratic state and
wire cost.

## Defaults

- `CRDT.Lww_Element_Sets` (deprecated) uses Lamport stamps. It is kept for
  backward compatibility.
- `CRDT.Lww_Sets` takes the strategy as a generic parameter and has no
  implicit default; pass the strategy you chose.
- The state-based sync layer uses `VTime` vector entries with an HLC stamp
  per replica.
- The V3 wire format records the strategy in its clock-kind byte, so a
  reader can decode any strategy the writer used.

## The Hybrid Logical Clock

The `CRDT.HLC` package complements the strategies. An HLC combines a
wall-clock reading with a logical counter, so timestamps stay close to real
time and still respect causality. Use it in the state-based sync layer and
anywhere you must order events from replicas with skewed physical clocks.
See [the API reference](../api-docs/crdt-hlc.md) for the contracts.

## See also

- [Containers, wrappers, and the hybrid logical clock](containers-and-wrappers.md)
  -- the HLC, which combines a wall-clock reading with a logical counter.
- [Sync layers](sync.md) -- the state-based layer that uses the HLC.
- [API reference](../api-docs/crdt-clocks.md) -- the clock strategy interface.
