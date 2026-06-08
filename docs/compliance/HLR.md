# High-Level Requirements

## HLR-CORE-TS — Timestamp Operations
Provide Lamport-timestamp and hybrid-logical-clock types with
causal ordering, wall-clock synchronisation, and serialisation support.

**Source:** `src/core/crdt-core.ads`, `src/core/crdt-hlc.ads`

**Derived LLRs:** LLR-CORE-TS, LLR-HLC-CLOCK, LLR-HLC-ORDER

---

## HLR-CORE-VC — Vector Clock Operations
Provide vector-clock (VTime) data type with element-wise comparison,
merge (element-wise max), and per-replica Lamport-counter tracking.

**Source:** `src/core/crdt-core.ads`

**Derived LLRs:** LLR-CORE-VC

---

## HLR-CORE-PROTO — Wire Protocol Version
Define the current wire-protocol version number and provide LEB128
encode/decode primitives used by V2 serialisation.

**Source:** `src/core/crdt-core.ads`, `src/core/crdt-core-leb128.ads`

**Derived LLRs:** LLR-CORE-PROTO

---

## HLR-HLC-CLOCK — HLC Instance Management
Create, tick (advance on local event), and recv (advance on remote event)
hybrid-logical-clock instances.

**Source:** `src/core/crdt-hlc.ads`

**Derived LLRs:** LLR-HLC-CLOCK

---

## HLR-HLC-ORDER — HLC Timestamp Ordering
Compare two HLC timestamps using less-than, equality, and greater-than
operators that respect both physical wall-clock time and logical counters.

**Source:** `src/core/crdt-hlc.ads`

**Derived LLRs:** LLR-HLC-ORDER

---

## HLR-CNTR-VALUE — PN-Counter Value
Return the net value (P − N) of a PN-Counter across all replicas.

**Source:** `src/crdt-pn_counters.ads`

**Derived LLRs:** LLR-CNTR-VALUE

---

## HLR-CNTR-OP — PN-Counter Increment/Decrement
Increment or decrement a PN-Counter by a given amount under a given
Lamport timestamp.  Track per-replica contributions.

**Source:** `src/crdt-pn_counters.ads`

**Derived LLRs:** LLR-CNTR-OP

---

## HLR-CNTR-MERGE — PN-Counter Merge
Merge two PN-Counter states by element-wise max of per-replica entries.

**Source:** `src/crdt-pn_counters.ads`

**Derived LLRs:** LLR-CNTR-MERGE

---

## HLR-CNTR-SERIAL — PN-Counter Serialisation
Round-trip PN-Counter through V1 (Natural'Read/Write) and V2 (LEB128)
wire formats with auto-detection on read.

**Source:** `src/crdt-pn_counters.ads`

**Derived LLRs:** LLR-CNTR-SERIAL

---

## HLR-LWW-CONTAINS — LWW Set Membership
Query whether an element is present in a Last-Writer-Wins element set
(by comparing add vs. remove timestamps).

**Source:** `src/crdt-lww_element_sets.ads`

**Derived LLRs:** LLR-LWW-CONTAINS

---

## HLR-LWW-ADD — LWW Set Add
Add an element with a Lamport timestamp.  Overwrites any previous
add or remove for the same element.

**Source:** `src/crdt-lww_element_sets.ads`

**Derived LLRs:** LLR-LWW-ADD

---

## HLR-LWW-REMOVE — LWW Set Remove
Remove an element with a Lamport timestamp.  Overwrites any previous
add or remove for the same element.

**Source:** `src/crdt-lww_element_sets.ads`

**Derived LLRs:** LLR-LWW-REMOVE

---

## HLR-LWW-MERGE — LWW Set Merge
Merge two LWW element sets by element-wise timestamp comparison.
For each entry keep the version with the highest Lamport timestamp.

**Source:** `src/crdt-lww_element_sets.ads`

**Derived LLRs:** LLR-LWW-MERGE

---

## HLR-LWW-SERIAL — LWW Set Serialisation
Round-trip LWW Element Set through V1 (Natural'Read/Write) and V2
(LEB128) wire formats with auto-detection on read.

**Source:** `src/crdt-lww_element_sets.ads`

**Derived LLRs:** LLR-LWW-SERIAL

---

## HLR-SYNC-OP — Operation-Based Sync
Maintain a bounded operation log with Append, Acknowledge, and Compact
operations.  Log entries carry Lamport timestamps and are garbage-collected
when acknowledged by all peers.

**Source:** `src/sync/crdt-sync-op_based.ads`

**Derived LLRs:** LLR-SYNC-OP

---

## HLR-SYNC-ACK — Operation Acknowledge
Mark all operations up to a given delivery index as acknowledged and
compact the log, removing acknowledged entries that are no longer needed.

**Source:** `src/sync/crdt-sync-op_based.ads`

**Derived LLRs:** LLR-SYNC-ACK

---

## HLR-SYNC-STATE — State-Based Sync
Compare replica states via vector-clock comparison and merge remote
state into local state.  Supports delta-based partial exchange.

**Source:** `src/sync/crdt-sync-state_based.ads`

**Derived LLRs:** LLR-SYNC-STATE

---

## HLR-SYNC-DELTA — Delta Computation
Determine how many items a remote peer is missing by comparing its
state vector against the current replica's log length.

**Source:** `src/sync/crdt-sync-state_based.ads`

**Derived LLRs:** LLR-SYNC-DELTA

---

## HLR-PROTO-HEADER — Protocol Header Read
Read and auto-detect V1 vs V2 wire format from the first 4 header bytes.
Extract Total and Count fields using the correct decoder.

**Source:** `src/serialization/crdt-serialization.ads`

**Derived LLRs:** LLR-PROTO-HEADER

---

## HLR-PROTO-DISPATCH — Version-Aware Field Reading
Dispatch per-field deserialization to the correct decoder (Natural'Read
for V1, LEB128 for V2) based on protocol version detected by the header.

**Source:** `src/serialization/crdt-serialization.ads`

**Derived LLRs:** LLR-PROTO-DISPATCH

---

## HLR-PROTO-LEGACY — V1 Legacy Reading
Provide V1 fixed-width (Natural'Read) fallback for reading individual
integer fields from legacy streams.

**Source:** `src/serialization/crdt-serialization-legacy.ads`

**Derived LLRs:** LLR-PROTO-LEGACY
