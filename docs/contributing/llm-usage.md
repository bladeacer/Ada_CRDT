# AI and LLM usage in this project

This page states how AI tools were used in the CRDT project, what a
contribution must meet because of that use, and where the limits are. The
short form is the same as the readme: AI assistance was used for this project.
Everything below is the long form.

## Disclosure

AI tools produced and edited parts of this codebase, its documentation, and its
changelogs. The use was not hidden, and it is not a reason to accept a patch
that the gates reject. A generated change is a draft until `make check` passes
it, exactly like a hand-written change.

The project targets DO-178C DAL-C and a Platinum SPARK proof. Those two facts
set the bar for every change, and no tool writes the proof for you.

## What the evidence is

The project does not ask you to trust the claim above. It asks you to read the
evidence that the tools produced:

| Evidence | Where it lives | What it shows |
|----------|----------------|---------------|
| Verification conditions | [VERIFICATION.md](../compliance/VERIFICATION.md) | 972 conditions, 972 proved, 0 justified, 0 unproved |
| Test results | [VERIFICATION.md](../compliance/VERIFICATION.md) | 10332 tests across 10 categories, all passing |
| Requirements | [HLR.md](../compliance/HLR.md) and [TRACE.md](../compliance/TRACE.md) | 27 high-level requirements traced to source |
| Docstring coverage | [the coverage report](../api-docs/index.md) | Every public entity documented |
| Proof ledger | [the proof ledger](../proof/16.1.0-ledger.md) | The verified-condition history and the skipped units |

SPARK proof is the strongest of these, because gnatprove checks the code
against contracts instead of against a test author's assumptions. A change that
a test cannot reach but a contract can reject still fails here.

## The bar for a change

A change is ready when all of the following are true. No item is optional, and
no item is satisfied by the fact that a tool wrote the code:

1. `make check` passes, including the build, the tests, the proof, and the
   compliance check.
2. Every new subprogram has a docstring with `@param` and `@return`
   annotations, and the docstring matches what the code does.
3. Every new public subprogram carries a SPARK contract where the proof needs
   one, and gnatprove proves it.
4. Every change to a wire format, a public signature, or a generic keeps the
   backward compatibility promise in the readme, or bumps the major version.
5. The changelog entry describes a change that is actually in the diff, and the
   proof and test numbers in it match the gate output.

## How machine agents work in this repository

[AGENTS.md](https://github.com/bladeacer/Ada_CRDT/blob/main/AGENTS.md) is the
machine-facing contract. It holds the codebase map, the naming rules, the
documentation style, the changelog format, and the safety rules, and it is the
first file to read before you change anything. The file is generated in part:
`make agents-tree` and `make doc-links` keep its structure and its
documentation block in step with the repository.

The generators under `tools/` are the guard rails. They regenerate the API
reference, the changelog index, the proof status, the test counts, the
description, the coverage report, and the badge set from their sources, so a
generated file that drifts from its source fails a gate. A generated file edited
by hand is a defect, and the gate says so.

## The limits

No tool in this repository reasons about your design. SPARK cannot tell you
that a merge order is wrong, a proof cannot tell you that a capacity is too
small, and a passing test suite cannot tell you that a tombstone policy breaks
convergence across a partition. The gates check the properties that can be
checked mechanically, and a reviewer reads the rest.

The units that the proof does not reach are listed in the [coverage
report](../api-docs/crdt-spark-coverage.md) with a justification for each. They
are the wall-clock, stream, random-number, and access-type code, and they are
excluded by design rather than by oversight. The generic packages are excluded
because SPARK analyses an instantiation, not a generic.

## See also

- [Quality gates and make targets](quality-gates.md) -- every target and what
  it proves.
- [Contributing guide](https://github.com/bladeacer/Ada_CRDT/blob/main/CONTRIBUTING.md)
  -- the process, the review rules, and the changelog format.
- [Agent guide](https://github.com/bladeacer/Ada_CRDT/blob/main/AGENTS.md) --
  the machine-facing contract.
- [DO-178C compliance](../compliance/index.md) -- the DAL-C scope and the
  verification evidence.
- [Proof records](../proof/index.md) -- the verified-condition ledger and the
  skipped units.
