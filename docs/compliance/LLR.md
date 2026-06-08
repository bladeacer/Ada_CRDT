# Low-Level Requirements

Each LLR traces to its parent HLR and identifies the Ada subprogram(s)
that implement it.  SPARK contracts (pre/post/depends) serve as
object-code-level formal verification of these requirements.

## LLR-CORE-TS — Lamport Time Operations

**Parent HLR:** HLR-CORE-TS

| Subprogram | Contract Summary |
|---|---|
| `Core.Time_Less` | Returns `L < R` |
| `Core.Time_Leq` | Returns `L <= R` |
| `Core.Time_Eq` | Returns `L = R` |
| `Core.Time_Merge` | Sets result = max(L, R) |
| `Core.Time_Increment` | Sets result = (L + 1, max(L.Clock, wall)) |

Proof: Postcondition, Functional Contract

---

## LLR-HLC-CLOCK — HLC Instance Lifecycle

**Parent HLR:** HLR-HLC-CLOCK, HLR-CORE-TS

| Subprogram | Contract Summary |
|---|---|
| `HLC.Create` | Constructs HLC(physical=Clock, logical=0) |
| `HLC.Tick` | Advances on local event |
| `HLC.Recv` | Advances on received timestamp |

Proof: Postcondition (Tick/Recv ensure monotonicity)

---

## LLR-HLC-ORDER — HLC Ordering

**Parent HLR:** HLR-HLC-ORDER

| Subprogram | Contract Summary |
|---|---|
| `HLC."<"` | Returns True if L is causally before R |
| `HLC."="` | Returns True if L and R are equal |
| `HLC.">"` | Returns True if L is causally after R |

Proof: Postcondition, Functional Contract

---

## LLR-CORE-VC — Vector Clock Operations

**Parent HLR:** HLR-CORE-VC

| Subprogram | Contract Summary |
|---|---|
| `Core.VTime_Less` | Returns `L < R` (element-wise) |
| `Core.VTime_Leq` | Returns `L <= R` (element-wise) |
| `Core.VTime_Eq` | Returns `L = R` (element-wise) |
| `Core.VTime_Merge` | Sets result = element-wise max(L, R) |

Proof: Loop Invariant, Postcondition, Functional Contract

---

## LLR-CORE-PROTO — Protocol Version & LEB128

**Parent HLR:** HLR-CORE-PROTO

| Subprogram | Contract Summary |
|---|---|
| `Core.Protocol_Version` | Constant = 2 |
| `Core.LEB128.Encode` | Encodes Nat as LEB128 bytes |
| `Core.LEB128.Decode` | Decodes LEB128 bytes to Nat |

Proof: Run-time / assertion (LEB128 is tested)

---

## LLR-CNTR-VALUE — PN-Counter Value Query

**Parent HLR:** HLR-CNTR-VALUE

| Subprogram | Contract Summary |
|---|---|
| `Pn_Counters.Value` | Returns sum(P) - sum(N) |
| `Pn_Counters.Entry_Count` | Returns Count of C |

Proof: Postcondition, Expression Function

---

## LLR-CNTR-OP — PN-Counter Increment/Decrement

**Parent HLR:** HLR-CNTR-OP

| Subprogram | Contract Summary |
|---|---|
| `Pn_Counters.Increment` | Adds `Amount` to P entries under `TS` |
| `Pn_Counters.Decrement` | Adds `Amount` to N entries under `TS` |

Proof: Postcondition (entry count <= capacity), Depends

---

## LLR-CNTR-MERGE — PN-Counter Merge

**Parent HLR:** HLR-CNTR-MERGE

| Subprogram | Contract Summary |
|---|---|
| `Pn_Counters.Merge` | Element-wise max of P and N |
| `Pn_Counters."<"`, `"="`, `">"` | Counter comparison |

Proof: Postcondition, Loop Invariant, Depends

---

## LLR-CNTR-SERIAL — PN-Counter Round Trip

**Parent HLR:** HLR-CNTR-SERIAL

| Subprogram | Contract Summary |
|---|---|
| `Pn_Counters.Write_PN_Counter` | Writes header + per-replica entries |
| `Pn_Counters.Read_PN_Counter` | Reads header (auto-detect) + entries |

Proof: Verified by round-trip tests (10218 test cases)

---

## LLR-LWW-CONTAINS — LWW Set Membership

**Parent HLR:** HLR-LWW-CONTAINS

| Subprogram | Contract Summary |
|---|---|
| `Lww_Element_Sets.Contains` | Add_Time > Remove_Time for element |
| `Lww_Element_Sets.Add_Count` | Returns number of add entries |
| `Lww_Element_Sets.Remove_Count` | Returns number of remove entries |

Proof: Postcondition, Expression Function

---

## LLR-LWW-ADD — LWW Set Add

**Parent HLR:** HLR-LWW-ADD

| Subprogram | Contract Summary |
|---|---|
| `Lww_Element_Sets.Add` | Inserts/overwrites element with TS |

Proof: Postcondition (add_count <= capacity), Depends

---

## LLR-LWW-REMOVE — LWW Set Remove

**Parent HLR:** HLR-LWW-REMOVE

| Subprogram | Contract Summary |
|---|---|
| `Lww_Element_Sets.Remove` | Inserts/overwrites remove entry with TS |

Proof: Postcondition (add_count <= capacity), Depends

---

## LLR-LWW-MERGE — LWW Set Merge

**Parent HLR:** HLR-LWW-MERGE

| Subprogram | Contract Summary |
|---|---|
| `Lww_Element_Sets.Merge` | Element-wise timestamp comparison |

Proof: Postcondition, Depends

---

## LLR-LWW-SERIAL — LWW Set Round Trip

**Parent HLR:** HLR-LWW-SERIAL

| Subprogram | Contract Summary |
|---|---|
| `Lww_Element_Sets.Write_LWW_Element_Set` | Writes header + entries |
| `Lww_Element_Sets.Read_LWW_Element_Set` | Reads header (auto-detect) + entries |

Proof: Verified by round-trip tests

---

## LLR-SYNC-OP — Operation Log

**Parent HLR:** HLR-SYNC-OP

| Subprogram | Contract Summary |
|---|---|
| `Op_Based.Append` | Appends operation to bounded log |
| `Op_Based.Compact` | Removes acknowledged entries |
| `Op_Based.Log_Count` | Returns Count of log |
| `Op_Based.Log_GC` | Returns GC index of log |

Proof: Postcondition (count <= capacity), Expression Function, Depends

---

## LLR-SYNC-ACK — Operation Acknowledge

**Parent HLR:** HLR-SYNC-ACK

| Subprogram | Contract Summary |
|---|---|
| `Op_Based.Acknowledge` | Marks entries up to index as delivered |

Proof: Postcondition, Depends

---

## LLR-SYNC-STATE — State Comparison & Merge

**Parent HLR:** HLR-SYNC-STATE

| Subprogram | Contract Summary |
|---|---|
| `State_Based.Is_Ahead` | Returns True if local SV > remote SV |
| `State_Based.Merge` | Merges remote replica state into local |

Proof: Loop Invariant (Is_Ahead), Postcondition, Depends

---

## LLR-SYNC-DELTA — Delta Computation

**Parent HLR:** HLR-SYNC-DELTA

| Subprogram | Contract Summary |
|---|---|
| `State_Based.Compute_Delta` | Returns number of missing items |

Proof: Postcondition

---

## LLR-PROTO-HEADER — Protocol Header Dispatch

**Parent HLR:** HLR-PROTO-HEADER

| Subprogram | Contract Summary |
|---|---|
| `Serialization.Read_Header` | Detects V1/V2 from first 4 bytes |
| `Serialization.Migrate_Header` | Reads source header, writes V2 header |

Proof: Verified by round-trip tests

---

## LLR-PROTO-DISPATCH — Field Dispatch

**Parent HLR:** HLR-PROTO-DISPATCH

| Subprogram | Contract Summary |
|---|---|
| `Serialization.Read_Natural` | Dispatches to Natural'Read or LEB128 |

Proof: Verified by round-trip tests

---

## LLR-PROTO-LEGACY — V1 Fallback

**Parent HLR:** HLR-PROTO-LEGACY

| Subprogram | Contract Summary |
|---|---|
| `Serialization.Legacy.Read_Natural_V1` | Reads fixed-width Natural via 'Read |

Proof: Verified by round-trip tests
