# CRDT.Bounded

Bounded (pre-allocated) container wrappers. All dynamic structures use fixed-size arrays specified at compile time. Critical for mission-critical Ada/SPARK environments where heap allocation is restricted to prevent fragmentation and OOM. All types in CRDT natively use bounded storage; this package provides convenient renamings and documentation.

## Types

### type Bounded_PN_Counter

```ada
subtype Bounded_PN_Counter is Pn_Counters.PN_Counter;
```
