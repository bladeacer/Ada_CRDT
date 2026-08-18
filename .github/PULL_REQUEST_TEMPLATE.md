## Summary

<!-- What does this pull request do, and why? Keep it short. -->

## Type of change

<!-- Delete the options that do not apply. -->
- Bug fix
- New feature
- Documentation
- Tooling / CI
- Breaking change (requires major version bump)

## Test plan

<!-- What did you run to verify this change? -->
- [ ] `make build`
- [ ] `make test`
- [ ] `make ascii-check`
- [ ] `make prove` (if SPARK-analyzable code changed; zero unproved checks)
- [ ] `make compliance` (HLR traceability + README links + verification report)

## Backward compatibility

<!--
The project guarantees that code compiling against CRDT 1.0.0 compiles against
any later 1.x release without source changes. Does this change touch the public
API or the wire protocol (V1/V2/V3)?
-->

## DO-178C traceability

<!--
New features must add HLR tags (`--  - HLR-XXXX: ...`) in the package header and
matching entries in `docs/compliance/HLR.md` and `docs/compliance/LLR.md`.
-->

## Changelog

<!--
User-visible changes belong in a `docs/changelogs/crdt-X.Y.Z.md` entry
(following the canonical `### C#:` / `### H#:` format enforced by
`make changelog-check`).
-->

## Checklist

- [ ] Follows existing code style (3-space indent, ASCII-only, no tabs)
- [ ] Doc comments (`--  @param`, `--  @return`, ...) on all new public entities
- [ ] No heap allocation introduced (bounded storage preserved)
- [ ] Tests added in `src/tests/` using `RunR.Check` for new behavior
- [ ] No unrelated changes