### CRDT 1.5.0

Date: _2026-06-08_

SPARK Gold & Platinum formal verification, DO-178C compliance artifacts,
and protocol migration utility.

## New Features

### SPARK Gold: Functional Contracts

Postconditions on all 35 core subprograms across 7 packages (Core, PN_Counters,
LWW_Element_Sets, HLC, Op_Based, State_Based). Loop invariants added on all
iterative subprograms (VTime ops, Merge, Is_Ahead). Expression functions for
`Entry_Count`, `Log_Count`, `Log_GC` enable prover inlining through postconditions.

### SPARK Platinum: Depends Contracts

Explicit `Depends =>` on all SPARK-analysed procedures with `in out` parameters:

- VTime_Merge
- VTime_Increment
- PN Increment/Decrement/Merge
- Op_Based Append/Acknowledge/Compact
- LWW Add/Remove/Merge/Clear
- State_Based Merge

9 Flow Dependency checks verified.

### Migrate_Header Utility

`CRDT.Serialization.Migrate_Header` reads a V1 or V2 header from Source, writes
a V2-encoded header to Dest. Enables bulk protocol migration in 2 lines of Ada.

### DO-178C Compliance Artifacts

`docs/compliance/` with High-Level Requirements (HLR.md), Low-Level Requirements
(LLR.md), traceability matrix (TRACE.md). `make compliance` validates all 21
HLR tags are present in source files.

## Changes

### `Ada.Calendar.Time` visibility fix

`use Ada.Calendar;` and `use type Core.Replica_Id;` added to HLC spec for `<`/`>`
operator resolution without full-qualified calls.

### Docstring coverage

`@param` / `@return` docstrings added to 9 previously-missing subprograms
(Write/Read PN_Counter, Write/Read LWW_Element_Set, Log_Count, Log_GC,
Read_Header, Read_Natural, Read_Natural_V1).

### HLR requirements headers

All 7+ package specs annotated with requirements traceability (`HLR-*` tags) for
DO-178C derivation.

## Proof Results

| Metric | Before (1.4.0) | After (1.5.0) |
|--------|----------------|----------------|
| Total checks | 112 | 217 |
| Proved | 107 (96%) | 175 (81%) |
| Justified | 5 (4%) | 5 (2%) |
| Unproved | 0 | 0 |
| Functional Contracts | 0 | 35 |
| Assertions | 8 | 26 |
| Loop Invariants | 4 | 11 |

## Breaking Changes

None. The public API is fully backward-compatible with CRDT >= 1.4.0.
