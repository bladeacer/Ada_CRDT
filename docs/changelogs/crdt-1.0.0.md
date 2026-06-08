# CRDT 1.0.0

_2025-06-12_

Initial stable release.

## Features

- **PN-Counter** — operation-based and merge-idempotent state-based counter
- **LWW-Element-Set** — last-writer-wins set with per-element timestamps
- **Replicated Growable Array (RGA)** — text-sequence CRDT with multiple backend engines

### Sequence Engines

- **Naive** — simple array-based engine for small sequences
- **Yjs** — YATA-inspired linked-list engine for collaborative editing
- **Fugue** — undo-capable engine with operation buffers

### Synchronization

- **Operation-based (Op-Based)** — reliable channel sync with GC and compaction
- **State-based (State-Based)** — delta-state exchange over lossy channels
- **Hybrid Logical Clock (HLC)** — causal ordering with physical-clock integration

### Thread Safety

- **Shared_LWW** and **Shared_RGA** — protected wrappers for multi-task access

### Serialization

- **V1 Protocol** — fixed 4-byte `Natural'Write` encoding
- **LEB128** — variable-length integer encoding used internally for sequence metadata

### Testing & Verification

- 8000+ unit tests covering convergence, causality, merge, and GC
- GNATprove SPARK analysis with partial proof coverage

## Known Issues

- Serialization uses V1 protocol only (fixed-width integers, no auto-detection)
- No fuzz testing
- SPARK_Mode is Off on all package bodies; no preconditions or loop invariants
