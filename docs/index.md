# CRDT Documentation

This page is the index for all CRDT documentation. Pick a section
relevant to you, or read the pages in the order below.

All documentation uses British English and ASD-STE100 Simplified Technical
English. The controlled Technical Names dictionary lives in
[STE100 Technical Names](ste100-technical-names.md). Use it before you use a
technical word in any doc, docstring, or changelog.

## Getting started

- [Readme](https://github.com/bladeacer/Ada_CRDT/blob/main/README.md) -- the library overview, install paths, and code
  examples.
- [Agent guide](https://github.com/bladeacer/Ada_CRDT/blob/main/AGENTS.md) -- the codebase map and conventions for AI
  agents and new contributors.

## Using CRDT

- [Usage guide](usage/index.md) -- the self-contained user guide. Start at
  [Getting started](usage/getting-started.md).
- [Sequence engines](usage/engines.md) -- how to pick and run the Yjs, Naive,
  and Fugue engines, and their garbage-collection behaviour.
- [Engine comparison](usage/engine-comparison.md) -- how the Yjs, Naive, and
  Fugue sequence engines compare with the upstream Yjs and Automerge
  designs, and which robustness gaps remain.
- [Clock strategies](usage/clock-strategies.md) -- Lamport, Vector, and
  Matrix clocks, the uniform interface, and how to pick a default.
- [Sync layers](usage/sync.md) -- state-based versus operation-based sync,
  and the acknowledgement and purge lifecycle for op logs.
- [Serialization](usage/serialization.md) -- the V1/V2/V3 wire formats and
  the migration helpers.
- [Security](usage/security.md) -- the SHA-256, HMAC, and LMS
  signature packages and how to verify signed replica state.
- [API reference](api-docs/index.md) -- the generated package
  documentation. It covers all public and private entities.

## Maintainer references

- [DO-178C compliance](compliance/index.md) -- the DAL-C scope, the PSAC,
  and the verification summary.
- [High-Level Requirements](compliance/HLR.md) and
  [Low-Level Requirements](compliance/LLR.md).
- [Traceability matrix](compliance/TRACE.md) and
  [Verification results](compliance/VERIFICATION.md).
- [Proof ledger](proof/16.1.0-ledger.md) -- the verified-VC history and the
  skipped-units audit.
- [Changelog](changelogs/index.md) -- release history.
- [CI/CD](ci-cd.md) -- the workflows and their local equivalents.

The docs live under `docs/` as a **Sphinx** project (`docs/conf.py` with
MyST, plus a root `docs/index.md` holding the toctree). Read the Docs builds
the manual from `.readthedocs.yaml` with the same toolchain. Build the
generated API reference with `make doc`.

```{toctree}
:caption: Getting started
:maxdepth: 1
:hidden:

usage/index
usage/getting-started
usage/engines
usage/clock-strategies
usage/sync
usage/serialization
usage/security
usage/engine-comparison
api-docs/index
```

```{toctree}
:caption: Maintainer references
:maxdepth: 1
:hidden:

compliance/index
compliance/HLR
compliance/LLR
compliance/TRACE
compliance/VERIFICATION
proof/16.1.0-ledger
changelogs/index
ci-cd
```
