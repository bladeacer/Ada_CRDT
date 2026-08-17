### CRDT 1.7.1

Date: _2026-07-26_

Deterministic verification reports, gnatformat integration, and build-system
cleanup. `make verify-report` now hashes input artifacts for reproducible
output, `make fmt` formats all Ada sources via a transactional manifest swap,
and the dead `test-fuzz` alias is removed.

## Changes

### C1: gnatformat Integration

`gnatformat_bin` added as an Alire development dependency
(`alire-dev.toml`). `package Format` block in `crdt.gpr` configures
gnatformat with project conventions (indent 3, spaces, width 200,
keyword-lower).

`make fmt` formats all Ada sources via
`alr exec -- gnatformat -P crdt.gpr -U` with a transactional `alire.toml`
swap -- `alire.toml` is backed up, replaced with `alire-dev.toml` for the
duration of the command, and restored on exit.

### C2: Deterministic Verification Reports

`make verify-report` now uses `sha256sum` of input artifacts
(`obj/gnatprove/gnatprove.out` + `test_result.md`) instead of `$(date)`, so
repeated runs produce identical output as long as the inputs haven't changed.

### C3: Non-Deterministic index.md Fix

`sed '/^## Verification Summary/Q'` accumulated one blank line per run.
Fixed to `sed '/^## Verification Summary/,$$d'` (with proper Makefile `$$`
escaping), eliminating the growth.

### C4: Quick Reference Validation

`make compliance` now parses the Quick Reference table in `README.md`,
extracts every `docs/api-docs/*.md` link, and verifies the file exists.

### C5: System Dependencies

New table in `AGENTS.md` listing all system- and Alire-level dependencies
(Alire, GNAT, gnatprove, gnatdoc_bin, gnatformat_bin, Python 3, sha256sum,
POSIX tools). Brief summary added to `make help`.

### C6: Development Workflow Clarified

`make dev-setup` is now informational only (no longer copies to
`alire.toml`). `make fmt` handles its own temporary manifest swap.
`demo/alire.toml` now has comments explaining the pin-to-local +
version-pin-to-published pattern.

## Fixes

### H1: Dead `test-fuzz` Target Removed

`test-fuzz` was a bare alias for `run` with misleading help text ("Run chaos
fuzzing"). Fuzz tests are part of the standard test suite; the alias has been
removed.

## Test Suite

10290 tests passing (unchanged from 1.7.0).

## Proof Results

273 checks, 221 proved, 5 justified, 0 unproved (unchanged from 1.7.0).

## Traceability

24 HLR tags (unchanged from 1.7.0).

## Breaking Changes

None. All changes are additive or internal to the build system.

## Version

Bumped from 1.7.0 to 1.7.1.
