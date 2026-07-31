# Plan for Software Aspects of Certification (PSAC)

## 1. Introduction

### 1.1 Purpose

This document is the Plan for Software Aspects of Certification (PSAC) for
the Ada_CRDT library, a Conflict-Free Replicated Data Types (CRDT) library
written in Ada/SPARK.  It defines the software life cycle, the standards,
the development and verification environment, the configuration management
practices, and the certification evidence produced for development
assurance at Level C (DAL-C) per RTCA DO-178C / EUROCAE ED-12C.

### 1.2 Applicable Documents

| Document | Reference |
|----------|-----------|
| RTCA DO-178C / EUROCAE ED-12C | Software Considerations in Airborne Systems and Equipment Certification |
| RTCA DO-248C | Supporting Information for DO-178C and DO-278A |
| Ada Reference Manual | ISO/IEC 8652:2012 (Ada 2012) |
| SPARK Reference Manual | SPARK 2014 (AdaCore) |
| Project high-level requirements | `docs/compliance/HLR.md` |
| Project low-level requirements | `docs/compliance/LLR.md` |
| Traceability matrix | `docs/compliance/TRACE.md` |
| Verification results | `docs/compliance/VERIFICATION.md` |
| Codebase guide | `AGENTS.md` |

### 1.3 Software Level

The software is targeted at **DAL-C** (Development Assurance Level C).  At
this level a software failure may cause passenger inconvenience but NOT
injury or loss of life.  DAL-A and DAL-B are explicitly out of scope; no
separate verification team, MC/DC coverage, or object code analysis is
performed.

## 2. System Overview

Ada_CRDT is a library of Conflict-Free Replicated Data Types, including:

- PN-Counters (`CRDT.Pn_Counters`)
- LWW element sets (`CRDT.Lww_Element_Sets`, `CRDT.Lww_Sets`)
- RGA sequences (`CRDT.Rga`, `CRDT.Rgas`)
- Sequence engines (Yjs, Naive, Fugue)
- Clock strategies (Lamport, Vector, Matrix)
- State-based and operation-based synchronization layers
- Thread-safe protected wrappers and heap-free bounded wrappers

The library is designed for replicas that exchange state or operations
over a network and must converge to the same value without a central
coordinator.  All containers use pre-allocated bounded storage sized at
instantiation time; there is no heap allocation for CRDT data.

## 3. Software Life Cycle

The project follows a V-style life cycle tailored for a library crate:

1.  **Planning**: This PSAC, `HLR.md`, and `LLR.md` define requirements
    and verification strategy.
2.  **Requirements**: High-level requirements are stated in `HLR.md` and
    tagged in source `.ads` files (`--  - HLR-XXXX`).  Low-level
    requirements in `LLR.md` map each HLR to Ada subprograms.
3.  **Design and implementation**: Ada 2012 with SPARK contracts
    (pre/post, depends, type invariants) written in the package specs.
4.  **Verification**: Formal proof with GNATprove (primary evidence) plus
    a runtime test harness (10290 test cases across 9 categories).
5.  **Release**: Versioned changelogs, tag-based releases, and automated
    compliance checks via the Makefile.

## 4. Software Life Cycle Environment

| Item | Selection |
|------|-----------|
| Programming language | Ada 2012 (`-gnat12`), pure ASCII source |
| Formal methods | SPARK 2014 |
| Toolchain | FSF GNAT 15.2.1 managed by Alire (`alr`) |
| Build tool | Alire (`alr build`), GNAT project files (`crdt.gpr`) |
| Prover | GNATprove (`alr gnatprove`) |
| Doc generator | GNATdoc |
| Formatter | GNATformat |
| Build/verification automation | `Makefile` |
| Version control | git |

All project tools are listed in the project manifest (`alire.toml`,
`alire-dev.toml` for development-only dependencies) and pinned by Alire
where the toolchain allows.

## 5. Software Standards

### 5.1 Requirements Standards

- High-level requirements use the form `HLR-XXXX` and appear in both
  `HLR.md` and as tags in `.ads` file headers.
- Low-level requirements use the form `LLR-XXXX`, trace to a parent HLR,
  and identify the implementing Ada subprograms.
- Every source HLR tag must have a matching entry in `HLR.md`, and every
  `HLR.md` entry must have a matching source tag.  This is verified
  automatically by `make compliance`.

### 5.2 Design Standards

- Hierarchical Ada package structure rooted at `CRDT`.
- PascalCase types and subprograms; snake_case source files matching child
  package names.
- Private interface items carry docstring warnings that they are not part
  of the stable public API.

### 5.3 Code Standards

- Ada 2012 language standard (`-gnat12`), the DO-178C DAL-C baseline.
- SPARK_Mode applied at package level for all SPARK-analyzable units.
- 3-space indentation, no tabs, no trailing blanks, 200-char line limit
  (enforced by compiler style flags).
- Pure ASCII source enforced by `make ascii-check`.
- All warnings enabled (`-gnatwa`), assertions enabled (`-gnata`).

## 6. Software Verification

### 6.1 Formal Proof (Primary Evidence)

- **SPARK Gold is always targeted**: full absence-of-runtime-errors
  (AoRTE) proved for all SPARK-analyzable code, plus key functional
  contracts (pre/post, depends, type invariants) on core packages.
- **SPARK Platinum is a best-effort ideal** above Gold: full functional
  requirements across all SPARK-analyzable units, reflecting the current
  release's proof state rather than a permanent guarantee.
- Generics (8 units: `Rga`, `Lww_Element_Sets`, `Lww_Sets`,
  `Sequences.*`) and platform dependencies (wall clock, RNG, stream I/O)
  are excluded from formal proof by design; their `SPARK_Mode => Off`
  locations are documented in `docs/api-docs/crdt-spark-coverage.md`.
- Current proof statistics are maintained in
  `docs/compliance/VERIFICATION.md` (auto-generated by
  `make verify-report`).

### 6.2 Runtime Testing

- The test harness (`src/tests/`, driven by `src/tests/test_crdt.adb`) runs 10290
  test cases across 9 categories: basic, clocks, lattice properties, RGA
  features, serialization, engines, convergence, fuzz, and Game of Life.
- Test modules follow a common runner pattern (`RunR.Check`) with no
  external test framework; results are written to `test_result.md`.
- Fuzz and partition tests exercise convergence and serialization under
  adversarial scenarios.

### 6.3 SPARK vs. Testing at DAL-C

At DAL-C, SPARK proof is accepted as verification evidence and replaces
unit testing for proved subprograms.  Requirements-based test coverage
targets are less stringent than at DAL-A/B.  Test coverage targets for
SPARK-proved code are therefore defined by the proof campaign rather than
by runtime coverage measurement.

## 7. Configuration Management

- All artifacts (source, docs, tests, Makefile, manifests) are tracked in
  git.
- Releases are tagged (`vX.Y.Z`) and published via the Makefile
  `release` and `publish` targets.
- Per-version changelogs are maintained in `docs/changelogs/` and
  auto-indexed by `make doc`.
- The wire protocol is versioned (`Protocol_Version`); V2 readers can
  read V1 data, and V3 readers can read all V1, V2, and V3 data.  The
  V1 -> V2 migration is documented in
  `docs/changelogs/crdt-1.4.0-migration.md`.

## 8. Quality Assurance

- `make compliance` validates HLR/LLR/traceability consistency, checks
  that all compliance artifacts exist, and verifies that README Quick
  Reference links resolve.
- `make verify-report` regenerates verification results deterministically
  (content hashing instead of timestamps) so that repeated runs are
  reproducible.
- `make ascii-check` enforces the ASCII-only charset across all source
  and documentation files.
- CI-equivalent local gates: `make verify` runs the full quality gate
  (format, lint, test, build) before release.

## 9. Certification Liaison

Tool qualification at DAL-C is limited to TQL-4 (Development Tool level
per DO-330 where applicable) for GNAT/SPARK, which is generally satisfied
by the tools' track record.  No separate verification team is required at
DAL-C.  Questions about this PSAC or the certification evidence should be
directed to the project maintainers.

## 10. References

| Artifact | Location |
|----------|----------|
| High-Level Requirements | `docs/compliance/HLR.md` |
| Low-Level Requirements | `docs/compliance/LLR.md` |
| Traceability Matrix | `docs/compliance/TRACE.md` |
| Verification Results | `docs/compliance/VERIFICATION.md` |
| Compliance Index | `docs/compliance/index.md` |
| SPARK Coverage Report | `docs/api-docs/crdt-spark-coverage.md` |
| Codebase Guide | `AGENTS.md` |
| README | `README.md` |
