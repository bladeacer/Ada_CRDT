# Traceability Matrix

Auto-generated.  Run `make compliance` to verify.

Source: HLR tags in `.ads` files + LLR mapping in `LLR.md`.

## HLR -> Source Files

| HLR | Source |
|-----|--------|
| HLR-CORE-TS | `src/core/crdt-core.ads`, `src/core/crdt-hlc.ads` |
| HLR-CORE-VC | `src/core/crdt-core.ads` |
| HLR-CORE-CLOCKS | `src/core/crdt-clocks.ads`, `src/core/crdt-clocks-lamport.ads`, `src/core/crdt-clocks-vector.ads`, `src/core/crdt-clocks-matrix.ads` |
| HLR-CORE-CLOCKS-MATRIX | `src/core/crdt-clocks-matrix.ads` |
| HLR-CORE-PROTO | `src/core/crdt-core.ads`, `src/core/crdt-core-leb128.ads` |
| HLR-HLC-CLOCK | `src/core/crdt-hlc.ads` |
| HLR-HLC-ORDER | `src/core/crdt-hlc.ads` |
| HLR-CNTR-VALUE | `src/crdt-pn_counters.ads` |
| HLR-CNTR-OP | `src/crdt-pn_counters.ads` |
| HLR-CNTR-MERGE | `src/crdt-pn_counters.ads` |
| HLR-CNTR-SERIAL | `src/crdt-pn_counters.ads` |
| HLR-LWW-CONTAINS | `src/crdt-lww_element_sets.ads` |
| HLR-LWW-ADD | `src/crdt-lww_element_sets.ads` |
| HLR-LWW-REMOVE | `src/crdt-lww_element_sets.ads` |
| HLR-LWW-MERGE | `src/crdt-lww_element_sets.ads` |
| HLR-LWW-SERIAL | `src/crdt-lww_element_sets.ads` |
| HLR-SYNC-OP | `src/sync/crdt-sync-op_based.ads` |
| HLR-SYNC-ACK | `src/sync/crdt-sync-op_based.ads` |
| HLR-SYNC-STATE | `src/sync/crdt-sync-state_based.ads` |
| HLR-SYNC-DELTA | `src/sync/crdt-sync-state_based.ads` |
| HLR-PROTO-HEADER | `src/serialization/crdt-serialization.ads` |
| HLR-PROTO-DISPATCH | `src/serialization/crdt-serialization.ads` |
| HLR-PROTO-LEGACY | `src/serialization/crdt-serialization-legacy.ads` |
