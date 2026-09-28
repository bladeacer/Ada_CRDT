# CRDT usage guide

This section holds the user guide for the CRDT library. Each page stands on
its own. You can read one page without the others, and every page links to
the generated API reference for the exact signatures.

All pages use British English and ASD-STE100 Simplified Technical English.
Paragraphs hold at most four sentences.

## The pages

- [Getting started](getting-started.md) -- install the library, write a first
  PN-Counter and LWW set, and run a first sync loop.
- [Sequence engines](engines.md) -- pick between the Yjs, Naive, and Fugue
  engines, and learn the tombstone garbage-collection behaviour of each.
- [Clock strategies](clock-strategies.md) -- pick between the Lamport,
  Vector, and Matrix strategies, and learn the default for each package.
- [Security](security.md) -- add SHA-256 integrity, HMAC authentication, or
  LMS signature verification to replica state exchange.
- [Sync layers](sync.md) -- pick between state-based and operation-based
  sync, and manage the acknowledgement and purge lifecycle of an op log.
- [Serialisation](serialization.md) -- understand the V1, V2, and V3 wire
  formats and the migration tools.
- [Containers, wrappers, and the hybrid logical clock](containers-and-wrappers.md)
  -- the bounded wrappers, the thread-safe protected types, the multi-RGA
  container, and the HLC.
- [Engine comparison](engine-comparison.md) -- compare the robustness of the
  three engines with the upstream Yjs and Automerge designs.

## Where to look next

- The [API reference](../api-docs/index.md) lists every package, type, and
  subprogram with its SPARK contracts.
- The [quality gates page](../contributing/quality-gates.md) lists every
  `make` target and what each gate proves.
- The [site transparency page](../site-transparency.md) states what the
  deployed manual records when you read it.
- The [proof records](../proof/index.md) hold the verified-condition ledger and
  the current proof numbers.
- The [DO-178C compliance section](../compliance/index.md) holds the
  requirements traceability and the verification results.
- The [changelogs](../changelogs/index.md) hold the release history.
