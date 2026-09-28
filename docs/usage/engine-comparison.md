# Engine comparison with Yjs and Automerge

This page compares the three sequence engines of this library with the
upstream designs that inspired them: the Yjs project and the Automerge
project. It summarises what the engines adopt, what they change, and which
robustness gaps remain. The [engines page](engines.md) explains how to use
each engine; this page explains why.

## Lineage

- The Yjs engine of this library follows the chunk-based sequence design of
  [Yjs / YATA](https://github.com/yjs/yjs) by Kevin Jahns.
- The Fugue engine follows the anti-interleaving algorithm of
  [Fugue](https://arxiv.org/abs/2305.00583) (Weidner and Kleppmann).
- The overall container model draws on
  [Automerge](https://github.com/automerge/automerge) by Martin Kleppmann
  and contributors.

No upstream source code is vendored. The algorithms inform the design, and
the implementation is original Ada/SPARK.

## Robustness of the three engines

| Property | Yjs (default) | Naive | Fugue |
|----------|---------------|-------|-------|
| Convergence on concurrent inserts | Yes | Yes | Yes |
| Anti-interleaving of concurrent runs | No (interleaves) | No (interleaves) | Yes |
| Tombstone cost | Per item inside chunks | Per item | Per item |
| Physical GC of tombstones | Yes (`Compact`) | Yes (`Compact`) | Yes, with a causal-round limit |
| Zero heap at run time | Bounded pre-allocation | Bounded pre-allocation | Bounded pre-allocation |
| Wire format | V2 via the shared sequence codec | V2 via the shared sequence codec | V2 via the shared sequence codec |

All three engines converge. The differences are the shape of concurrent
inserts, the memory behaviour, and the compaction limits.

## Against upstream Yjs

The chunk-based engine reproduces the upstream Yjs property that a run of
characters from one replica costs one chunk, not one node per character.
The structural split on insert keeps that property under interleaved edits.

Differences from upstream:

- The upstream library keeps item metadata in JavaScript objects on the
  heap. This library stores everything in pre-allocated bounded arrays, so
  a sequence never allocates at run time.
- The upstream engine integrates with a document model that holds many
  types. This engine exposes one sequence type; the containers of the
  library compose around it.
- The upstream engine carries an integration search optimisation over the
  chunk list. This engine keeps a simpler search, which costs lookup time
  on very long sequences.

## Against upstream Automerge and Fugue

Automerge moved from RGA to a columnar run-based encoding for text and uses
the Fugue-informed ordering in its newer list implementations. The Fugue
paper defines the depth-based identifier ordering that prevents
interleaving, and this library's Fugue engine implements that ordering.

Differences from the published Fugue design:

- The published design assumes unbounded tree storage. This engine stores
  the tree in bounded arrays and reuses freed slots after `Compact`.
- The slot reuse introduces the causal-round limit on compaction that the
  [engines page](engines.md) documents: a `Node_Id` released by `Compact`
  can be reused by a later insert, so all peers must compact in the same
  causal round.

## Remaining gaps

Know these limits before you deploy a sequence workload:

- No engine supports a peer that delivers a delete for a slot already
  released by a Fugue compaction. Schedule compaction in a quiescent causal
  round.
- The engines keep tombstones forever until you call `Compact`. A workload
  that deletes often and never compacts holds the deleted content's slots.
- The Naive engine has no structural sharing: memory is one node per
  element, and lookups are linear. It exists for clarity, not scale.
- The sequence wire format is V2. The generic clocked containers write V3;
  the sequence engines keep V2 for compatibility (see the
  [serialization page](serialization.md)).

## Choosing in practice

Interleaving is a user-visible defect in collaborative text. Choose Fugue
for text edit fields where two people type at the same position. Choose Yjs
for long documents and append-mostly logs, where its chunk compression
minimises memory. Keep Naive for tests and teaching.

All three pass the
same convergence tests in this repository, so you can switch engines as your
workload changes.

## See also

- [Sequence engines](engines.md) -- the engine contract and the selection
  guidance.
- [Containers, wrappers, and the hybrid logical clock](containers-and-wrappers.md)
  -- the bounded wrapper for a sequence.
- [API reference](../api-docs/crdt-rga.md) -- the engine generic parameters.
