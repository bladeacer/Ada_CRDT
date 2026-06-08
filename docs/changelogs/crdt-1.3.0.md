# CRDT 1.3.0

_2026-04-14_

Documentation overhaul, improved docstrings, and Game of Life stability fixes.

## Changes

- **Docstring improvements** — param/return annotations on all public subprograms,
  meaningful top-level package descriptions, and consistent formatting
- **Doc badge generation** — inline badges in generated docs for SPARK proof
  coverage and test status
- **Documentation generation fixes** — RST-to-Markdown conversion now handles
  nested package hierarchies and cross-references correctly
- **Game of Life fixes** — fixed demo entering infinite loop when switching
  between concurrent modes under state-based sync
- **Release packaging** — fixed `alire.toml` release format for community index

## Migration from 1.2.0

- No API or wire-format changes from 1.2.0.
- Rebuild your project with `alr update crdt` or bump the dependency in
  `alire.toml`.
