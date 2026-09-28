# Containers, wrappers, and the hybrid logical clock

Every container in this library already stores its data in pre-allocated
storage, so no container needs a wrapper to avoid the heap. This page covers
the packages that wrap the containers for two further reasons: fixed sizes at
instantiation time, and thread-safe access. It also covers the multi-RGA
container and the HLC.

All three wrapper packages sit on top of the packages documented on the
[containers and engines](engines.md) and [clock
strategies](clock-strategies.md) pages. Read those pages first if you have not
chosen a container yet.

## Zero heap by default

You do not need `CRDT.Bounded` to keep the heap empty. `CRDT.Pn_Counters`,
`CRDT.Lww_Sets`, `CRDT.Rga`, and `CRDT.Rgas` all size their storage at
instantiation time, and no subprogram in those packages allocates at run time.

`CRDT.Bounded` adds a shorter name and a documented capacity contract for the
size of each container. Use it when you want the intent in the source:

| Package | What it gives you |
|---------|-------------------|
| `CRDT.Bounded.Bounded_PN_Counter` | A subtype renaming of `CRDT.Pn_Counters.PN_Counter` |
| `CRDT.Bounded.Bounded_LWW_Set` | A generic package that fixes `Max_Set_Size` at instantiation |
| `CRDT.Bounded.Bounded_RGA` | A generic package that fixes `Max_Items`, `Max_Stride`, and `Max_Replicas` |
| `CRDT.Protected.Shared_PN_Counter` | A protected type for tasks that share one counter |
| `CRDT.Protected.Shared_LWW.Shared_Set` | A protected type for tasks that share one set |
| `CRDT.Protected.Shared_RGA.Shared_RGA_Obj` | A protected type for tasks that share one sequence |
| `CRDT.Rgas` | A bounded collection of several RGA instances |

`Bounded_LWW_Set` and `Shared_LWW` wrap `CRDT.Lww_Element_Sets`, which uses a
Lamport time. New code must use `CRDT.Lww_Sets`, which accepts any clock
strategy, and wrap that package yourself when you need a protected type.

## Bounded wrappers

`CRDT.Bounded.Bounded_LWW_Set` takes an element type and a maximum set size.
`CRDT.Bounded.Bounded_RGA` takes an element type, a maximum item count, a
maximum stride, and a maximum replica count. The last two have defaults, so a
small instantiation needs only the element type and the item count:

```ada
with CRDT.Bounded;

package Seq is new CRDT.Bounded.Bounded_RGA (Character, 100);

R : Seq.Sequence;
```

Choose `Max_Items` for the largest number of live elements, plus the tombstones
that deletes leave behind. Choose `Max_Stride` for the largest contiguous run of
elements that the engine can hold in one block. Choose `Max_Replicas` for the
largest number of replicas that exchange deltas, because it fixes the length of
the per-replica state vector that `Sync_Delta` takes. Set each value once and
keep it for the life of the program.

## Thread-safe wrappers

`CRDT.Protected` provides Ada protected types. A protected type takes its lock
for the length of one call, so two tasks can call the same container without
any lock in your code.

```ada
with CRDT.Protected;

package Test is
   package Shared is new CRDT.Protected.Shared_LWW (Integer, 100);
   Counter : Shared.Shared_PN_Counter (Max_Actors => 4);
end Test;

--  From any task:
Test.Counter.Increment (By => 1, Actor => 1);
Value : Integer := Test.Counter.Value;
```

The protected types expose the same operations as the plain containers, plus
`Snapshot`. `Snapshot` returns a copy of the whole state, which is what you
hand to `Merge` on the wire, and it takes the lock only for the copy.

`Shared_PN_Counter` is a plain protected type, so you declare an object of it
directly. `Shared_LWW.Shared_Set` and `Shared_RGA.Shared_RGA_Obj` are protected
types inside generic packages, so you declare an object after you instantiate
the package with the element type, the capacity, and the stride.

Use the protected types when more than one task touches the same container. For
a single task, use the plain container, because the protected call costs more
than the container operation itself.

## The multi-RGA container

`CRDT.Rgas` holds several RGA instances in one bounded collection. It suits a
document with one sequence per row, a chat with one sequence per channel, or a
log with one sequence per stream.

```ada
with CRDT.Rgas;

package Rows is new CRDT.Rgas (Character, 100, 8);

Store : Rows.RGAs (8);
```

`Append` adds one entry and refuses the call when the collection is full.
`Get` returns the entry at a 1-based index. `Merge_All` merges every entry into
entry 1, which is the only way to join the sequences, because a merge needs a
destination and a source that share a common state.

Size `Max_RGA_Count` for the largest number of sequences you keep, and
`Max_RGA_Size` for the largest number of elements in one of them. The count
discriminant is part of the type, so a collection of a different size is a
different type and cannot be mixed up in one expression.

## The hybrid logical clock

`CRDT.HLC` stamps events with a wall-clock reading and a logical counter
together. Use it when events from different machines must keep their real-time
order, for example for audit logs or for a lease timeout.

```ada
with CRDT.HLC;

Clock : CRDT.HLC.Instance := CRDT.HLC.Create (Node => 1);

CRDT.HLC.Tick (Clock);                  --  Stamp a local event.
CRDT.HLC.Recv (Clock, Remote_Stamp);    --  Reconcile with a remote event.
Stamp : CRDT.HLC.HLC_Time := CRDT.HLC.Now (Clock);
```

Call `Tick` before you send or store a local event. Call `Recv` when an event
from another replica arrives, before you store it. `Create` reads the wall clock
once for the initial stamp, and every later call moves the clock forward past
both the wall clock and any received stamp. A backwards or stalled system clock
therefore cannot make two events share a stamp.

The [sync layers page](sync.md) uses the same clock for the state-based layer.
The [API reference](../api-docs/crdt-hlc.md) holds the exact contracts.

## See also

- [Sequence engines](engines.md) -- pick the engine under a bounded sequence.
- [Clock strategies](clock-strategies.md) -- Lamport, Vector, and Matrix
  clocks for the LWW containers.
- [Sync layers](sync.md) -- move a `Snapshot` between replicas.
- [Serialisation](serialization.md) -- write a state or a delta to a stream.
