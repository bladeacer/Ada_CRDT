# Plan for Software Aspects of Certification (PSAC)

## 1. Introduction

### 1.1 Purpose

This document is the Plan for Software Aspects of Certification (PSAC) for
the Ada_CRDT library. Ada_CRDT is a Conflict-Free Replicated Data Types
(CRDT) library written in Ada/SPARK. The PSAC defines the software life
cycle, the standards, and the development and verification environment. It
also defines the configuration management practices and the certification
evidence for development assurance at Level C (DAL-C) per RTCA DO-178C /
EUROCAE ED-12C.

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

The software targets **DAL-C** (Development Assurance Level C). At this
level, a software failure may cause passenger inconvenience but not injury
or loss of life. DAL-A and DAL-B are explicitly out of scope. No separate
verification team, MC/DC coverage, or object code analysis is performed.

## 2. System Overview

Ada_CRDT is a library of Conflict-Free Replicated Data Types, including:

- PN-Counters (`CRDT.Pn_Counters`)
- LWW element sets (`CRDT.Lww_Element_Sets`, `CRDT.Lww_Sets`)
- RGA sequences (`CRDT.Rga`, `CRDT.Rgas`)
- Sequence engines (Yjs, Naive, Fugue)
- Clock strategies (Lamport, Vector, Matrix)
- State-based and operation-based synchronization layers
- Thread-safe protected wrappers and heap-free bounded wrappers

The library supports replicas that exchange state or operations over a
network. The replicas converge to the same value without a central
coordinator. All containers use pre-allocated bounded storage sized at
instantiation time. There is no heap allocation for CRDT data.

## 3. Software Life Cycle

The project follows a V-style life cycle tailored for a library crate:

1.  **Planning**: This PSAC, `HLR.md`, and `LLR.md` define requirements
    and verification strategy.
2.  **Requirements**: `HLR.md` states the high-level requirements. Source
    `.ads` files tag them as `--  - HLR-XXXX`. `LLR.md` maps each HLR to Ada
    subprograms.
3.  **Design and implementation**: The package specs contain Ada 2012 code
    with SPARK contracts (pre/post, depends, type invariants).
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

All project tools are listed in the project manifest (`alire.toml`).
`alire-dev.toml` lists development-only dependencies. Alire pins the tools
where the toolchain allows.

## 5. Software Standards

### 5.1 Requirements Standards

- High-level requirements use the form `HLR-XXXX`. They appear in
  `HLR.md` and as tags in `.ads` file headers.
- Low-level requirements use the form `LLR-XXXX`. They trace to a parent
  HLR and identify the implementing Ada subprograms.
- Every source HLR tag must have a matching entry in `HLR.md`. Every
  `HLR.md` entry must have a matching source tag. `make compliance`
  verifies this automatically.

### 5.2 Design Standards

- Hierarchical Ada package structure rooted at `CRDT`.
- Types and subprograms use PascalCase. Source files use snake_case and
  match child package names.
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

- **SPARK Gold is always targeted**: SPARK proves full absence of runtime
  errors (AoRTE) for all SPARK-analyzable code. It also proves key
  functional contracts (pre/post, depends, type invariants) on core
  packages.
- **SPARK Platinum is a best-effort ideal** above Gold. It covers full
  functional requirements across all SPARK-analyzable units. It reflects the
  current release's proof state rather than a permanent guarantee.
- Generics (8 units: `Rga`, `Lww_Element_Sets`, `Lww_Sets`, `Sequences.*`)
  are excluded from formal proof by design. Platform dependencies (wall
  clock, RNG, stream I/O) are also excluded by design. Their
  `SPARK_Mode => Off` locations are documented in
  `docs/api-docs/crdt-spark-coverage.md`.
- Current proof statistics are maintained in
  `docs/compliance/VERIFICATION.md` (auto-generated by
  `make verify-report`).

### 6.2 Runtime Testing

- The test harness (`src/tests/`, driven by `src/tests/test_crdt.adb`) runs
  10290 test cases. The cases span 9 categories: basic, clocks, lattice
  properties, RGA features, serialization, engines, convergence, fuzz, and
  Game of Life.
- Test modules follow a common runner pattern (`RunR.Check`). They use no
  external test framework. The results are written to `test_result.md`.
- Fuzz and partition tests exercise convergence and serialization under
  adversarial scenarios.

### 6.3 SPARK vs. Testing at DAL-C

At DAL-C, SPARK proof is accepted as verification evidence. It replaces
unit testing for proved subprograms. Requirements-based test coverage
targets are less stringent than at DAL-A/B. Test coverage targets for
SPARK-proved code follow the proof campaign, not runtime coverage
measurement.

## 7. Configuration Management

- All artifacts (source, docs, tests, Makefile, manifests) are tracked in
  git.
- Releases are tagged (`vX.Y.Z`) and published via the Makefile
  `release` and `publish` targets.
- Per-version changelogs are maintained in `docs/changelogs/` and
  auto-indexed by `make doc`.
- The wire protocol is versioned (`Protocol_Version`). V2 readers can read
  V1 data. V3 readers can read all V1, V2, and V3 data. The V1 to V2
  migration is documented in
  `docs/changelogs/crdt-1.4.0-migration.md`.

## 8. Quality Assurance

- `make compliance` validates HLR/LLR/traceability consistency. It checks
  that all compliance artifacts exist. It verifies that README Quick
  Reference links resolve.
- `make verify-report` regenerates verification results deterministically.
  It uses content hashing instead of timestamps. Repeated runs are
  reproducible.
- CI-equivalent local gates: `make verify` runs the full quality gate. The
  gate covers format, lint, test, and build before release.

## 9. Certification Liaison

Tool qualification at DAL-C is limited to TQL-4 (Development Tool level
per DO-330 where applicable) for GNAT/SPARK. The tools' track record
generally satisfies this level. No separate verification team is required at
DAL-C. Direct questions about this PSAC or the certification evidence to the
project maintainers.

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
