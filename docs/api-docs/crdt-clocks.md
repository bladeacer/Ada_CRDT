# CRDT.Clocks

Root package for clock strategy selection.
Provides interchangeable Lamport, Vector, and Matrix clock strategies.

Requirements traceability:
- HLR-CORE-CLOCKS: Clock strategy interface and selection

> **Note:** All items in this package are public.

## Types

### type Clock_Kind

```ada
type Clock_Kind is (Clock_Lamport, Clock_Vector, Clock_Matrix);
```
