# CRDT Documentation

This page is the index for all CRDT documentation. Pick a section
relevant to you, or read the pages in the order below.

All documentation uses British English and ASD-STE100 Simplified Technical
English. The controlled Technical Names dictionary lives in
[STE100 Technical Names](ste100-technical-names.md). Use it before you use a
technical word in any doc, docstring, or changelog.

## Getting started

- [Usage guide](usage/index.md) -- the self-contained user guide, grouped by
  task. Start at
  [Getting started](usage/getting-started.md) for the install path and the
  first PN-Counter, LWW set, and sync loop.
- [Readme](https://github.com/bladeacer/Ada_CRDT/blob/main/README.md) -- the
  library overview, the feature list, and the quick reference on GitHub.
- [Agent guide](https://github.com/bladeacer/Ada_CRDT/blob/main/AGENTS.md) --
  the machine-facing contract: the codebase map and the conventions.

## Using CRDT

- [Sequence engines](usage/engines.md) -- how to pick and run the Yjs, Naive,
  and Fugue engines, and their garbage-collection behaviour.
- [Engine comparison](usage/engine-comparison.md) -- how the Yjs, Naive, and
  Fugue sequence engines compare with the upstream Yjs and Automerge
  designs, and which robustness gaps remain.
- [Clock strategies](usage/clock-strategies.md) -- Lamport, Vector, and
  Matrix clocks, the uniform interface, and how to pick a default.
- [Sync layers](usage/sync.md) -- state-based versus operation-based sync,
  and the acknowledgement and purge lifecycle for op logs.
- [Serialisation](usage/serialization.md) -- the V1/V2/V3 wire formats and
  the migration helpers.
- [Security](usage/security.md) -- the SHA-256, HMAC, and LMS
  signature packages and how to verify signed replica state.
- [Containers, wrappers, and the hybrid logical clock](usage/containers-and-wrappers.md)
  -- the bounded wrappers, the thread-safe protected types, the multi-RGA
  container, and the HLC.
- [API reference](api-docs/index.md) -- the generated package
  documentation. It covers all public and private entities.

## Contributing

- [Quality gates and make targets](contributing/quality-gates.md) -- every
  `make` target, what each gate proves, and which files are generated.
- [AI and LLM usage](contributing/llm-usage.md) -- the disclosure, the
  evidence behind it, and the bar a generated change must meet.
- [Contributing guide](https://github.com/bladeacer/Ada_CRDT/blob/main/CONTRIBUTING.md)
  -- the process, the review rules, and the changelog format.

## This documentation site

- [Site transparency](site-transparency.md) -- what the deployed manual
  records when you read it: search, traffic analytics, advertising, and the
  flyout menu. Read this page first if you care about tracking.

## Maintainer references

- [Proof records](proof/index.md) -- the verified-condition ledger, the current
  proof numbers, and why a unit is skipped.
- [Badges](badges/index.md) -- what each SVG badge reports and how to
  regenerate the set.
- [DO-178C compliance](compliance/index.md) -- the DAL-C scope, the PSAC,
  and the verification summary.
- [High-Level Requirements](compliance/HLR.md) and
  [Low-Level Requirements](compliance/LLR.md).
- [Traceability matrix](compliance/TRACE.md) and
  [Verification results](compliance/VERIFICATION.md).
- [Changelog](changelogs/index.md) -- release history.
- [CI/CD](ci-cd.md) -- the workflows and their local equivalents.

The docs live under `docs/` as a **Sphinx** project (`docs/conf.py` with
MyST, plus a root `docs/index.md` holding the toctree). Read the Docs builds
the manual from `.readthedocs.yaml` with the same toolchain and serves it at
<https://ada-crdt.readthedocs.io/en/latest/>. The pages are grouped by
audience: `docs/usage/` for people who use the library, `docs/contributing/`
for people who change it, and the compliance, proof, and changelog pages for
maintainers. Build the generated API reference with `make doc`, and read the
[site transparency page](site-transparency.md) for what the deployed manual
records about a reader.

```{toctree}
:caption: Using CRDT
:maxdepth: 1
:hidden:

usage/index
usage/getting-started
usage/engines
usage/clock-strategies
usage/sync
usage/serialization
usage/security
usage/containers-and-wrappers
usage/engine-comparison
api-docs/index
```

```{toctree}
:caption: Contributing
:maxdepth: 1
:hidden:

contributing/quality-gates
contributing/llm-usage
```

```{toctree}
:caption: This documentation site
:maxdepth: 1
:hidden:

site-transparency
```

```{toctree}
:caption: Maintainer references
:maxdepth: 1
:hidden:

proof/index
badges/index
compliance/index
compliance/HLR
compliance/LLR
compliance/TRACE
compliance/VERIFICATION
proof/16.1.0-ledger
changelogs/index
ci-cd
```
