### CRDT 1.3.0

Date: _2026-06-03_

Documentation overhaul, improved docstrings, and Game of Life stability fixes.
Doc badges are generated inline, RST-to-Markdown conversion handles nested
package hierarchies, and the demo no longer enters an infinite loop when
switching between concurrent modes under state-based sync.

## Changes

### C1: Doc Badge Generation

Inline badges in generated docs for SPARK proof coverage and test status.

### C2: Docstring Improvements

Param/return annotations on all public subprograms, meaningful top-level
package descriptions, and consistent formatting.

### C3: Documentation Generation Fixes

RST-to-Markdown conversion now handles nested package hierarchies and
cross-references correctly.

### C4: Release Packaging

Fixed `alire.toml` release format for community index.

## Fixes

### H1: Game of Life Infinite Loop

Fixed demo entering infinite loop when switching between concurrent modes
under state-based sync.

## Test Suite

No new tests added; suite unchanged from 1.2.0.

## Proof Results

No SPARK proof changes from 1.2.0. Proof results not tracked.

## Traceability

No HLR tags -- DO-178C traceability was introduced in 1.5.0.

## Breaking Changes

None. The public API is fully backward-compatible with CRDT >= 1.2.0.

## Version

Bumped from 1.2.0 to 1.3.0.
