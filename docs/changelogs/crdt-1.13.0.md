### CRDT 1.13.0

Date: _2026-08-29_

This release restyles all user documentation, changelogs, and Ada source
docstrings in ASD-STE100 Simplified Technical English with British English
spelling. A vendored SimpleEnglish skill and a CRDT technical-names list now set
the writing standard, and each paragraph is capped at four sentences. The changes
are documentation-only, so the test suite and SPARK proof posture are unchanged.

## Changes

### C1: ASD-STE100 Documentation Restyle -- British English, four-sentence paragraphs

The docstrings, hand-written docs, and changelogs now follow ASD-STE100
Simplified Technical English. All prose uses British English spelling and keeps
each paragraph to a maximum of four sentences. These are comment and document
changes only; no code, signatures, or wire format changed.

   - **Docstrings**: every descriptive comment in the `.ads` files was restyled
     for short active sentences, British spelling, and removed filler. Doc tags
     (`@param`, `@return`, `@field`, `@formal`) and HLR traceability tags stay
     exact.
   - **Docs and changelogs**: `README.md`, `CONTRIBUTING.md`, the compliance
     artefacts, `ci-cd.md`, the proof ledger, and all fifteen changelogs were
     restyled. Structure, tables, identifiers, and version numbers stay intact.
   - **ASCII gate**: the `skills/` directory is excluded from `make ascii-check`
     so the vendored upstream skill text does not break the scan.

### C2: Vendored SimpleEnglish Skill and Writing Policy

The SimpleEnglish skill is vendored locally at `skills/simple-english/` so CI
and dogfooding need no network access. `AGENTS.md` gains a Technical writing
section that names the British-English and four-sentence overrides and points to
the controlled technical-names list.

   - **Technical Names**: `docs/ste100-technical-names.md` defines the approved
     non-STE terms for this domain (for example `CRDT`, `Replica`, `Merge`,
     `RGA`, `Yjs`, `Fugue`, `SPARK`). Writers must add a new term to this list
     before they use it.

## Test Suite

10290 tests passing across 9 categories (unchanged from 1.12.0).

| Category | Tests | Status |
|----------|-------|--------|
| Basic: PN+LWW+RGA+RGAs | 34 | PASS |
| Clocks: Lamport+Vector+Matrix+Lww_Sets | 40 | PASS |
| Lattice Properties: law check | 8 | PASS |
| RGA Features: interleave+split+delta+GC | 40 | PASS |
| Serialization: V1+V2+byte-boundary | 62 | PASS |
| Engines: Yjs+Naive+Sync | 23 | PASS |
| Convergence: merge+skew+saturation | 21 | PASS |
| Fuzz: chaos+10k+partitions | 10038 | PASS |
| Game of Life: neighbors+blinker+sync+conv+mode | 24 | PASS |

## Proof Results

Unchanged from 1.12.0. The proof posture was not affected because the changes
are comment and document edits only. The assurance level stays **Platinum** with
0 unproved checks across all SPARK-analyzable units.

| Metric | 1.12.0 | 1.13.0 |
|--------|--------|--------|
| Total checks | 589 | 589 |
| Proved | 479 (81%) | 479 (81%) |
| Justified | 0 | 0 |
| Unproved | 0 | 0 |
| Flow Dependencies | 14 | 14 |
| Initialization | 30 | 30 |
| Run-time Checks | 322 | 322 |
| Assertions | 62 | 62 |
| Functional Contracts | 88 | 88 |
| Termination | 73 | 73 |
| Analyzed units | 34 | 34 |

## Traceability

No new HLRs are added. The 24 HLR tags are unchanged. The writing policy and
technical-names list are documentation artefacts only and do not alter the
requirements in `docs/compliance/HLR.md`. Compliance artefacts were not
regenerated because no requirement changed.

## Breaking Changes

None. The restyle changes comments, documentation, and the vendored skill only.
Every public generic signature (`Lww_Element_Sets`, `Rga`, `Rgas`, `Protected`,
`Bounded`, `Sequences.*`, `Lww_Sets`), the wire protocol (V1/V2/V3), and the
SPARK assurance level are unchanged. `alire.toml` stays at 1.12.0 until
`make bump-version` cuts this release.

## Version

Bumped from 1.12.0 to 1.13.0.
