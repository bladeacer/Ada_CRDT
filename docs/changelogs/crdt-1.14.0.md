### CRDT 1.14.0

Date: _2026-09-26_

This release adds a post-quantum security layer, reclaims memory in two places,
and reorganises the user documentation. The security layer gives SHA-256
integrity, HMAC-SHA-256 authentication with a shared key, and verify-only LMS
signatures. The Fugue engine can now reclaim deleted nodes, and the op-based
sync layer can purge the acknowledged causal history, so long-running replicas
no longer grow without limit. The docs gain a `docs/usage/` section and a
robustness comparison against Yjs and Automerge, and the SPARK proof reaches
Platinum with 0 unproved checks over 972 verification conditions.

## Changes

### C1: Post-Quantum Security Layer

New package `CRDT.Security` with three child packages. All three use no heap
allocation and are fully SPARK-proved.

- `CRDT.Security.SHA256`: the FIPS 180-4 hash with one-shot (`Digest`) and
  streaming (`Init`/`Update`/`Final`) forms. The streaming byte counter is a
  64-bit modular value, so it wraps exactly like the 64-bit bit-length field
  of the padding rule and can never overflow.
- `CRDT.Security.HMAC`: HMAC-SHA-256 (RFC 2104) with constant-time tag
  comparison. It authenticates replica state between peers that share a
  symmetric key.
- `CRDT.Security.LMS`: LM-OTS and LMS hash-based signature verification
  (RFC 8554, NIST SP 800-208). Security rests only on the pre-image
  resistance of SHA-256, so a quantum computer does not break it the way it
  breaks RSA and ECDSA. Verify-only by design: the library never holds
  signing key state. Peers sign offline and replicas verify with the public
  key before a merge is accepted.

New test category Security adds 15 tests with RFC 4231 HMAC vectors and
RFC 8554/SP 800-208 LMS vectors.

### C2: Fugue Tombstone Reclamation

The Fugue engine (`CRDT.Sequences.Fugue`) gains `Compact`, which unlinks
deleted nodes from the binary search tree and returns them to the free list
for reuse by later inserts and merges. In-order sequence order and Node_Id
order stay intact. Call `Compact` only when no peer can still deliver a
delete or merge for a removed Node_Id: a later merge for a reclaimed node
re-inserts the item as alive, which breaks convergence until all peers
compact in the same causal round.

### C3: Causal History Purge for Op-Based Sync

The op-based sync layer (`CRDT.Sync.Op_Based`) gains per-peer acknowledgement
watermarks and a purge frontier. `Acknowledge_From` records the highest
confirmed sequence number for one peer. `Purge_Acknowledged` removes every
operation acknowledged by all registered peers, and `Min_Unacked_Seq` reports
the smallest still-unacknowledged sequence number. A peer registers on its
first `Acknowledge_From` call. Retiring a peer means the application keeps
acknowledging on its behalf or rebuilds the log.

### C4: Documentation Reorganisation

New user guide under `docs/usage/` with self-contained pages for getting
started, sequence engines, clock strategies, sync layers, serialisation,
security, and an engine robustness comparison against Yjs and Automerge
(`engine-comparison.md`). The README links to the new pages. Third-party
notices and credits now list the normative spec references: FIPS 180-4,
RFC 2104, RFC 4231, RFC 8554, NIST SP 800-208, and RFC 8708. The compliance
artifacts add the security requirements: HLR-SEC-SHA256, HLR-SEC-HMAC, and
HLR-SEC-LMS, with derived LLRs and traceability rows (24 HLR tags become 27).

## Fixes

### H1: SPARK Proof Reaches Platinum With 0 Unproved Checks

The last unproved checks were arithmetic on unconstrained
`Stream_Element_Array` formals in the SHA-256 and LMS bodies, where gnatprove
cannot bound `'Length` or `'Last - 'First` against the base range. The fix
uses statically constrained subtypes and modular 32-bit folding, the same
idiom as `CRDT.Core.LEB128` and the SHA-256 compression schedule. The proof
now covers 972 verification conditions with 0 justified and 0 unproved.

### H2: SBOM Component Scopes Corrected

`make prove` misreported component scopes in `sbom.json`. The dev dependencies
(`gnatprove`, `sphinx`, and related doc tools) now carry the `dev` scope, the
vendored dependency carries `vendored`, and the system toolchain carries
`system`. The adacovex proof level property stays Platinum.

## Test Suite

10332 tests passing across 10 categories. New tests since 1.13.0: the
Security category adds 15, the Fugue reclamation tests add 16, and the causal
purge tests add 11.

| Category | Tests | Status |
|----------|-------|--------|
| Basic: PN+LWW+RGA+RGAs | 34 | PASS |
| Clocks: Lamport+Vector+Matrix+Lww_Sets | 40 | PASS |
| Lattice Properties: law check | 8 | PASS |
| RGA Features: interleave+split+delta+GC | 56 | PASS |
| Serialization: V1+V2+byte-boundary | 62 | PASS |
| Engines: Yjs+Naive+Sync | 34 | PASS |
| Convergence: merge+skew+saturation | 21 | PASS |
| Fuzz: chaos+10k+partitions | 10038 | PASS |
| Game of Life: neighbors+blinker+sync+conv+mode | 24 | PASS |
| Security: sha256+hmac+lms | 15 | PASS |

## Proof Results

The proof reaches **Platinum** with 0 justified and 0 unproved checks across
all SPARK-analyzable units. The check count grew from 589 to 972 because the
security packages add a proof surface.

| Metric | 1.13.0 | 1.14.0 |
|--------|--------|--------|
| Total checks | 589 | 972 |
| Proved | 479 (81%) | 972 (100%) |
| Justified | 0 | 0 |
| Unproved | 0 | 0 |
| Run-time Checks | 322 | 570 |
| Assertions | 62 | 86 |
| Functional Contracts | 88 | 103 |
| Termination | 73 | 99 |
| Analyzed + skipped units | 34 analyzed | 189 analyzed, 102 skipped |

## Traceability

The release adds HLR-SEC-SHA256, HLR-SEC-HMAC, and HLR-SEC-LMS with derived
LLRs (LLR-SEC-SHA256, LLR-SEC-HMAC, LLR-SEC-LMS) and traceability rows. The
27 HLR tags are unchanged since the compliance artifacts were updated for the
security packages. `SYNC-ACK` and the Fugue reclamation fold into the existing
sequence and sync HLRs.

## Breaking Changes

None. All new packages are additive (`CRDT.Security.*`), and the new
subprograms extend `CRDT.Sequences.Fugue` and `CRDT.Sync.Op_Based` without
signature changes. Every public generic signature (`Lww_Element_Sets`, `Rga`,
`Rgas`, `Protected`, `Bounded`, `Sequences.*`, `Lww_Sets`), the clock strategy
defaults, and the V1, V2, and V3 wire formats are unchanged.

## Version

Bumped from 1.13.0 to 1.14.0.
