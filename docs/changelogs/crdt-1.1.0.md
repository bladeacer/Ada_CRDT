### CRDT 1.1.0

Date: _2026-06-02_

Alire release with packaging fixes and platform compatibility improvements.
The `alr publish` workflow now registers the crate correctly in the community
index, and the Makefile gains `release`, `publish`, and `test-publish`
targets. No API or wire-format changes from 1.0.0.

## Changes

### C1: Alire Deployment Fixes

Fixed `alr publish` workflow to correctly register the crate in the community
index.

### C2: Makefile Automation

Updated `Makefile` with `release`, `publish`, and `test-publish` targets.

### C3: Toolchain Validation

Verified build on `gnatprove >= 15.1.0` and `gnatdoc >= 26.0.0`.

### C4: Protocol Stability

No API or wire-format changes from 1.0.0. This is a drop-in replacement.

## Test Suite

No new tests added; suite unchanged from 1.0.0 (8000+ unit tests).

## Proof Results

No SPARK proof changes from 1.0.0. Proof results not tracked.

## Traceability

No HLR tags -- DO-178C traceability was introduced in 1.5.0.

## Breaking Changes

None. The public API is fully backward-compatible with CRDT >= 1.0.0.

## Version

Bumped from 1.0.0 to 1.1.0.
