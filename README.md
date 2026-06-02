# Ada_CRDT

CRDT (Conflict-Free Replicated Data Types) library for Ada/SPARK.

## Install

```bash
alr index --add git+https://codeberg.org/bladeacer/Ada_CRDT.git --name ada_crdt
cd /path/to/your-project
alr with ada_crdt
```

Then `with "ada_crdt";` in your `.gpr` file.

## Development

Clone and build locally:

```bash
git clone https://codeberg.org/bladeacer/Ada_CRDT.git
cd Ada_CRDT
make build
make run
```

## Core Types

### PN-Counter (Actor Map)

Per-replica increments/decrements. Fixed memory (3 replicas = 3 slots), regardless of op count.

```ada
with Ada_CRDT.Pn_Counters;

A : Ada_CRDT.Pn_Counters.PN_Counter (Max_Actors => 5);
B : Ada_CRDT.Pn_Counters.PN_Counter (Max_Actors => 5);

Ada_CRDT.Pn_Counters.Increment (A, 5, Actor => 1);
Ada_CRDT.Pn_Counters.Increment (B, 10, Actor => 2);

Ada_CRDT.Pn_Counters.Merge (A, B);  -- value = 15
```

Package: `Ada_CRDT.Pn_Counters`

### LWW-Element-Set (Lamport Timestamps)

Last-Writer-Wins set using logical clocks (no wall-clock skew).

```ada
with Ada_CRDT.Lww_Element_Sets;
package Int_Set is new Ada_CRDT.Lww_Element_Sets (Integer, 100);

S1 : Int_Set.LWW_Element_Set (Capacity => 100);
S2 : Int_Set.LWW_Element_Set (Capacity => 100);

Int_Set.Add (S1, 42, (Stamp => 100, Node => 1));
Int_Set.Add (S2, 99, (Stamp => 50,  Node => 2));
Int_Set.Remove (S1, 42, (Stamp => 200, Node => 1));

Int_Set.Merge (S1, S2);
-- S1: contains 99 (added, never removed)
-- S1: contains 42 only if re-added with Stamp > 200
```

Package: `Ada_CRDT.Lww_Element_Sets` (generic over `Element_Type`, `Capacity`)

### RGA Sequence

Three backend engines, same API. See [API docs](docs/index.html) for full details.

```ada
with Ada_CRDT.Rga;
package Seq is new Ada_CRDT.Rga (Character, 100);
use Seq;

A : RGA (Capacity => 100);
B : RGA (Capacity => 100);

Insert (A, 1, (Replica => 1, Seq => 1), 'a');
Insert (A, 2, (Replica => 1, Seq => 2), 'b');
Insert (B, 1, (Replica => 2, Seq => 1), 'x');

Merge (A, B);  -- convergent state

-- Iterate
Pos : Cursor := First (A);
while Has_Element (Pos) loop
   Put (Element (A, Pos));
   Next (A, Pos);
end loop;
```

Package: `Ada_CRDT.Rga` (default engine) or `Ada_CRDT.Sequences.<Engine>`

### Engine Comparison

| Engine | Package | Design | Trade-off |
|--------|---------|--------|-----------|
| Yjs (default) | `Ada_CRDT.Rga` / `Ada_CRDT.Sequences.Yjs` | Chunk-based blocks, structural splitting | Fast bulk ops, larger tombstone overhead |
| Naive | `Ada_CRDT.Sequences.Naive` | Flat linked-list per element | Simple, O(n) lookups |
| Fugue | `Ada_CRDT.Sequences.Fugue` | BST tree with Depth ordering | Anti-interleaving, no GC rebalancing yet |

```ada
-- Switch engine by changing the with line
with Ada_CRDT.Sequences.Naive;
package S is new Ada_CRDT.Sequences.Naive (Character, 100);
```

### Sync Layer

State-based (CvRDT) with delta sync and HLC:

```ada
with Ada_CRDT.Sync.State_Based;

Config : Sync_Config := (Max_Replicas => 4, Delta_Sync => True, HLC_Node => 1);
Local  : Replica_State := Create (Config);
Remote : Replica_State := Create (Config);

Merge (Local, Remote);
```

Operation-based (CmRDT) with bounded op log and ack/GC:

```ada
with Ada_CRDT.Sync.Op_Based;

Log : Op_Log (Capacity => 1000);

Append (Log, (Kind => Op_Insert, Seq => 1, Node => 1, Position => 1));
Append (Log, (Kind => Op_Delete, Seq => 2, Node => 1, Del_Position => 1));

Acknowledge (Log, Up_To_Seq => 1);  -- mark delivered
Compact (Log);                       -- purge acknowledged ops
```

---

## Wrappers

Safety/constraint layers on top of core types.

### Thread-Safe (`Ada_CRDT.Protected`)

Protected-object wrappers (no manual locking):

```ada
with Ada_CRDT.Protected;

C : Ada_CRDT.Protected.Shared_PN_Counter (Max_Actors => 3);
C.Increment (5, Actor => 1);
C.Decrement (2, Actor => 1);
```

Also: `Shared_LWW` and `Shared_RGA` generics.

### Bounded (`Ada_CRDT.Bounded`)

Compile-time bounded, zero heap allocation:

```ada
with Ada_CRDT.Bounded;
package Bnd_RGA is new Ada_CRDT.Bounded.Bounded_RGA (Character, 100);
R : Bnd_RGA.Sequence;  -- fully bounded, heap-free
```

---

## Supporting Types

| Package | Role |
|---------|------|
| `Ada_CRDT.Core` | `Replica_Id`, `Lamport_Time`, `Protocol_Version`, VTime types |
| `Ada_CRDT.HLC` | Hybrid Logical Clock (physical + logical timestamp) |
| `Ada_CRDT.Rgas` | Multi-RGA container |

### HLC Example

```ada
with Ada_CRDT.HLC;

Clock : Ada_CRDT.HLC.Instance := Ada_CRDT.HLC.Create (Node => 1);
Ada_CRDT.HLC.Tick (Clock);   -- before sending
Ada_CRDT.HLC.Recv (Clock, Remote);  -- on receive, reconcile with remote time
```

---

## Wire Protocol

All serialized CRDT state begins with `Core.Protocol_Version` (currently `1`):

```
[Protocol_Version : Natural]
[Payload]
```

`Read_RGA` rejects mismatched versions, enabling safe rolling upgrades.

---

## Building

| Command | Action |
|---------|--------|
| `make build` | Build library + tests |
| `make run` / `make test` | Run test suite (103 tests) |
| `make prove` | SPARK proofs via `alr gnatprove` |
| `make doc` | Generate HTML docs via `gnatdoc` (see `docs/`) |
| `make clean` | Remove build artifacts |

Prerequisites: [Alire](https://alire.ada.dev) (manages GNAT automatically).

---

## SPARK Proof

Core packages (`Ada_CRDT.Pn_Counters`) SPARK-proven for run-time check elimination. Generics (Sequences, LWW, RGA) are instantiation-dependent.

---

## Credits

Technology:
- [SPARK / Ada 2012](https://www.adacore.com/sparkpro) (AdaCore): formal verification
- [Alire](https://alire.ada.dev): Ada/SPARK package manager

Inspired by:
- PN-Counter: [Apache Cassandra](https://cassandra.apache.org) distributed counters, [Riak](https://riak.com) CRDTs
- LWW-Element-Set: [Redis Enterprise](https://redis.io), [SoundCloud Roshi](https://github.com/soundcloud/roshi); Lamport (1978)
- RGA: [Yjs / YATA](https://github.com/yjs/yjs) (Kevin Jahns): block CRDT text editing
- [Automerge](https://github.com/automerge/automerge) (Martin Kleppmann et al.): JSON CRDT
- Fugue: tree-based interleaving prevention

## License

MIT.
