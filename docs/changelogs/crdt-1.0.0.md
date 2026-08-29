### CRDT 1.0.0

Date: _2026-06-02_

This is the first stable release of the CRDT library for Ada/SPARK. It provides
PN-Counters, LWW-Element-Sets, and RGA sequences with three backend engines.
It provides operation- and state-based synchronisation, thread-safe protected
wrappers, and a V1 wire protocol. Over 8000 unit tests cover convergence,
causality, merge, and GC.

## Changes

### C1: PN-Counter

Operation-based and merge-idempotent state-based counter.

### C2: LWW-Element-Set

Last-writer-wins set with per-element timestamps.

### C3: Replicated Growable Array (RGA)

Text-sequence CRDT with multiple backend engines (Naive, Yjs, Fugue). Naive
provides a simple array-based engine for small sequences. Yjs implements a
YATA-inspired linked-list engine for collaborative editing. Fugue provides an
undo-capable engine with operation buffers.

### C4: Synchronization Engines

Operation-based (Op-Based) synchronisation provides reliable channel sync with
GC and compaction. State-based (State-Based) synchronisation enables
delta-state exchange over lossy channels. Hybrid Logical Clock (HLC) provides
causal ordering with physical-clock integration.

### C5: Thread Safety

`Shared_LWW` and `Shared_RGA` serve as protected wrappers for multi-task
access.

### C6: Serialization

V1 Protocol implements fixed 4-byte `Natural'Write` encoding for all integer
values (header fields, node IDs, lengths).

### C7: Testing and Verification

8000+ unit tests covering convergence, causality, merge, and GC. GNATprove
SPARK analysis is included with partial proof coverage.

## Test Suite

Over 8000 unit tests cover convergence, causality, merge, and GC. Known gaps
remain. The serialisation tests exercise V1 only and omit fuzz testing.
`SPARK_Mode` is Off on all package bodies.

## Proof Results

SPARK proof results were not tracked for this version. `SPARK_Mode` was Off on
all package bodies. Preconditions and loop invariants were absent.

## Traceability

No HLR tags -- DO-178C traceability was introduced in 1.5.0.

## Breaking Changes

None. This is the initial stable baseline.

## Version

Bumped from 0.0.0 to 1.0.0.
