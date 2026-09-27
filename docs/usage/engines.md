# Sequence Engines

The RGA sequence type ships with three interchangeable backend engines. All
three implement the same API surface: `Insert`, `Delete`, `Merge`,
`Compact`, cursor iteration, versioned serialization, and delta sync. You
switch engine by changing one package name. The generic patterns page in the
[API reference](../api-docs/crdt-sequences.md) lists the shared contracts.

## The engines at a glance

| Engine | Package | Design | Best for |
|--------|---------|--------|----------|
| Yjs (default) | `CRDT.Rga` or `CRDT.Sequences.Yjs` | Chunk-based blocks with structural splitting | Bulk edits and text workloads |
| Naive | `CRDT.Sequences.Naive` | Flat linked list, one node per element | Teaching, tracing, and small sequences |
| Fugue | `CRDT.Sequences.Fugue` | Binary search tree with depth-based ordering | Concurrent typing that must avoid interleaving |

```ada
--  Default engine.
with CRDT.Rga;
package Seq is new CRDT.Rga (Character, 100);

--  Explicit engine: change only the with line and the instantiation.
with CRDT.Sequences.Fugue;
package Seq is new CRDT.Sequences.Fugue (Character, 100);
```

## Yjs: chunks and splitting

The Yjs engine stores consecutive characters from one replica in one chunk
block. A delete marks items with a tombstone; an insert between items of a
chunk splits the chunk in place. Bulk edits cost one small allocation per
chunk, not one node per character, so the engine is fast on large text.
Tombstones stay until you call `Compact`.

## Naive: one node per element

The Naive engine keeps a linked list with one node per element. Lookups walk
the list from the start, which costs O(n) per access, and memory grows with
the element count. The simple structure makes it easy to follow every merge
step. Use it for small sequences or to learn the algorithm.

## Fugue: anti-interleaving

The Fugue engine orders identifiers with a binary search tree by depth. When
two replicas type at the same position at the same time, Fugue keeps each
replica's run contiguous. The other engines can interleave the two runs
character by character. Prefer Fugue when concurrent inserts at one position
are common and the interleaved result would confuse readers.

## Garbage collection of tombstones

Every engine keeps tombstones so that a concurrent delete and insert
converge. `Compact` physically removes tombstoned items and returns their
slots to the free list. The Yjs and Naive engines preserve the visible order
across a compaction.

The Fugue engine preserves both the in-order sequence and the `Node_Id`
ordering, but a compaction releases `Node_Id` slots for reuse. Follow this
limit:

- Call `Compact` only when no peer can still deliver a `Delete` or a `Merge`
  for a removed `Node_Id`.
- Compact all replicas in the same causal round. A later `Merge` that still
  carries a removed item re-inserts it as alive and breaks convergence until
  every peer has compacted.

The [sync page](sync.md) explains how to use the acknowledgement lifecycle to
find such a causal round.

## Choosing an engine

Start with the default Yjs engine. It handles most workloads well and has no
extra constraints. Choose Fugue when concurrent typing at one position is a
core scenario. Choose Naive when you need the simplest possible structure or
when sequences stay short. The
[engine comparison page](engine-comparison.md) compares the robustness of
each engine with the upstream Yjs and Automerge designs.
