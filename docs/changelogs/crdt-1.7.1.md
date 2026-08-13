### CRDT 1.7.1

Date: _2026-07-26_

Deterministic verification reports, gnatformat integration, and build-system
cleanup.

## Tooling

### gnatformat Integration

`gnatformat_bin` added as an Alire development dependency (`alire-dev.toml`).
`package Format` block in `crdt.gpr` configures gnatformat with project
conventions (indent 3, spaces, width 200, keyword-lower).

`make fmt` formats all Ada sources via `alr exec -- gnatformat -P crdt.gpr -U`
with a transactional `alire.toml` swap -- `alire.toml` is backed up, replaced
with `alire-dev.toml` for the duration of the command, and restored on exit.

### Deterministic Verification Reports

`make verify-report` now uses `sha256sum` of input artifacts (`obj/gnatprove/gnatprove.out`
+ `test_result.md`) instead of `$(date)`, so repeated runs produce identical
output as long as the inputs haven't changed.

### Non-Deterministic index.md Fix

`sed '/^## Verification Summary/Q'` accumulated one blank line per run. Fixed
to `sed '/^## Verification Summary/,$$d'` (with proper Makefile `$$` escaping),
eliminating the growth.

### Quick Reference Validation

`make compliance` now parses the Quick Reference table in `README.md`,
extracts every `docs/api-docs/*.md` link, and verifies the file exists.

### Dead `test-fuzz` Target Removed

`test-fuzz` was a bare alias for `run` with misleading help text ("Run chaos
fuzzing"). Fuzz tests are part of the standard test suite; the alias has been
removed.

## Documentation

### System Dependencies

New table in `AGENTS.md` listing all system- and Alire-level dependencies
(Alire, GNAT, gnatprove, gnatdoc_bin, gnatformat_bin, Python 3, sha256sum,
POSIX tools). Brief summary added to `make help`.

### Development Workflow Clarified

`make dev-setup` is now informational only (no longer copies to `alire.toml`).
`make fmt` handles its own temporary manifest swap. `demo/alire.toml` now has
comments explaining the pin-to-local + version-pin-to-published pattern.

## Changes

### Makefile Targets

| Target | Before | After |
|--------|--------|-------|
| `test-fuzz` | Bare alias for `run` | Removed |
| `fmt` | -- | New: format all Ada sources |
| `verify-report` | Non-deterministic (timestamp) | Deterministic (content hash) |
| `compliance` | HLR + artifact checks | + Quick Reference link validation |

### Dependencies

| Dependency | Before | After |
|------------|--------|-------|
| `alire-dev.toml` | gnatprove, gnatdoc_bin | + gnatformat_bin |
| `alire.toml` | Unchanged | Unchanged (clean manifest) |

## Breaking Changes

None. All changes are additive or internal to the build system.

## Version

Bumped from 1.7.0 to 1.7.1.
