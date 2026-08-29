# Contribution Guide

Welcome! We are glad that you wish to contribute.
Before you start, read and understand our
[Code of Conduct](./CODE_OF_CONDUCT.md).

By contributing, you **agree to abide by its terms.**

## Contribute

Code is not the only thing you can contribute. We truly appreciate
contributions in the form of:

- Fixing typos.
- Improving docs.
- Triaging issues.
- Reviewing pull requests.
- Sharing your opinion on issues.

## Issues

- Before you open a new issue, look for existing issues (even closed ones).
- Do not bump issues without reason.
- If you report a bug, include as much information as possible. Include a
  minimal reproducer when you can. State which CRDT type (PN-Counter, LWW set,
  RGA), clock strategy (Lamport, Vector, Matrix), sequence engine (Yjs, Naive,
  Fugue), and sync layer are involved. State whether the failure reproduces
  with `make test`. Submit a pull request with a failing test in `src/tests/`
  when possible.
- Use the issue templates in `.github/ISSUE_TEMPLATE/` (bug report, feature
  request, security report).

## Pull requests

Pull requests must follow these conventions.

- Follow the existing directory structure: `src/`, `src/core/`,
  `src/sequences/`, `src/serialization/`, `src/sync/`, `src/tests/`.
- Keep the public API stable. Per the [backward compatibility
  guarantee](./README.md), code that compiles against CRDT 1.0.0 must compile
  against any later 1.x release without source changes. New features are
  additive: new packages, new generic formal parameters with defaults.
- Do not introduce heap allocation. All containers use pre-allocated bounded
  storage sized at instantiation time.
- Adhere to the existing code style (enforced by `crdt.gpr` and
  `make ascii-check`):
  - 3-space indentation, no tabs, no trailing blanks, 200-char line limit
  - Pure ASCII everywhere, even in comments and docs
  - Doc comments on all public entities using `--  @param`, `--  @return`,
    `--  @field`, `--  @formal` annotations (they feed `make doc`)
  - `--  - HLR-XXXX: description` tags in package headers where a requirement
    applies
- Run the test suite: `make test` (all 10290 tests across 9 categories must
  pass). If relevant, add tests in `src/tests/` using the existing
  `RunR.Check (Condition, "Message")` pattern.
- If your change touches SPARK-analyzable code, run the proofs: `make prove`.
  SPARK Gold (absence of runtime errors) is always targeted. Keep unproved
  checks at zero.
- Run the compliance gate before opening the pull request:
  - `make changelog-check` -- document user-visible changes in the changelog
    for the next release (`docs/changelogs/`) following the canonical format
  - `make compliance` -- HLR traceability, README link check, and verification
    report regeneration
- Only edit parts of the source code where necessary.
- Test that the added features or fixes work as intended.
- Clear variable names.
- Do not add editor-specific metafiles. Those should be added to your own
  global `.gitignore`.

### Prerequisite

- If the changes are large or breaking, open an issue discussing it first.
- Do not open a pull request if you do not plan to finish it. Maintainers waste
  time giving feedback on pull requests that go stale.
- Do not make unrelated changes.
- Adhere to the existing code style.
- If relevant, add tests, examine your code for typos, and add docs (docstring
  annotations and a changelog entry).
- Do not be sloppy. We expect you to do your best.
- Examine the diff of your changes before you submit a pull request. This is a
  good way to catch bugs and typos and to improve the code.

## Submission

- Give the pull request a clear title and description. It is up to you to
  convince the maintainers that your changes should be merged.
- If the pull request fixes an issue, reference it in the pull request
  description using the syntax `Fixes #123`.
- Make sure that the "Allow edits from maintainers" checkbox is checked. That
  way we can make certain minor changes ourselves. This lets your pull request
  be merged sooner.

## Review

- Push new commits when you change the pull request. Do not squash commits.
  Squashing makes it hard to see what changed since the last review.
- Present solutions instead of only asking questions.
- Review the pull request diff after each new commit. Catch mistakes early.
  This is better than having maintainers point them out and force a
  back-and-forth.
- Be patient. Maintainers often have a lot of pull requests to review. Feel
  free to bump the pull request if you haven't received a reply in a couple of
  weeks.
- And most importantly, have fun!
