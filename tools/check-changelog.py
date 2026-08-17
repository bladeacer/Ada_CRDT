#!/usr/bin/env python3
"""Validate CRDT changelog format.

Enforces the canonical changelog format (see AGENTS.md "Changelog
convention").  Every `docs/changelogs/crdt-X.Y.Z.md` must follow:

    ### CRDT X.Y.Z

    Date: _YYYY-MM-DD_

    <2-4 sentence summary>

    ## Changes          (optional; at least one of Changes/Fixes required)
    ### C1: <Title>
    ### C2: <Title>

    ## Fixes            (optional)
    ### H1: <Title>

    ## Test Suite       (mandatory)
    ## Proof Results    (mandatory)
    ## Traceability     (mandatory)
    ## Breaking Changes (mandatory, `None. ...` when nothing breaks)
    ## Version          (mandatory, last: `Bumped from A.B.C to X.Y.Z.`)

Exits 0 when every changelog is compliant, 1 otherwise.
"""

import re
import sys
from typing import List, Tuple

CHANGELOG_DIR = "docs/changelogs"
HEADER_RE = re.compile(r"^### CRDT (\d+\.\d+\.\d+)$")
DATE_RE = re.compile(r"^Date: _(\d{4}-\d{2}-\d{2})_$")
SECTION_RE = re.compile(r"^## (.+)$")
SUBSECTION_RE = re.compile(r"^### ([CH])(\d+): (.+)$")
VERSION_RE = re.compile(r"^Bumped from (\d+\.\d+\.\d+) to (\d+\.\d+\.\d+)\.$")

# Canonical top-level section order.  Changes/Fixes are optional (at least one
# must be present); everything from Test Suite onward is mandatory and must
# appear in this order at the end of the file.
CANONICAL_SECTIONS = [
    "Changes",
    "Fixes",
    "Test Suite",
    "Proof Results",
    "Traceability",
    "Breaking Changes",
    "Version",
]

MANDATORY_TAIL = ["Test Suite", "Proof Results", "Traceability",
                  "Breaking Changes", "Version"]


def collect_changelogs() -> List[str]:
    """Return the crdt-X.Y.Z.md files to check (excludes index and migration)."""
    import os
    files = []
    for name in sorted(os.listdir(CHANGELOG_DIR)):
        if not name.startswith("crdt-") or not name.endswith(".md"):
            continue
        if name == "index.md" or "-migration.md" in name:
            continue
        stem = name[len("crdt-"):-len(".md")]
        if re.match(r"^\d+\.\d+\.\d+$", stem):
            files.append(name)
    return files


def check_file(path: str) -> List[str]:
    errors: List[str] = []
    with open(path, encoding="utf-8") as fp:
        lines = fp.read().splitlines()

    # Strip trailing empty lines; require a final newline structure.
    while lines and lines[-1] == "":
        lines.pop()
    if not lines:
        return [f"{path}: empty file"]

    # Header.
    m = HEADER_RE.match(lines[0])
    if not m:
        errors.append(f"{path}:1: expected `### CRDT X.Y.Z` header, got: {lines[0]!r}")
        return errors
    version = m.group(1)
    if lines[0] != f"### CRDT {version}":
        errors.append(f"{path}:1: header must be exactly `### CRDT {version}`")

    # Date line at line 3 (line index 2), after one blank line.
    if len(lines) < 3 or lines[1] != "":
        errors.append(f"{path}: expected blank line after header")
    elif not DATE_RE.match(lines[2]):
        errors.append(f"{path}:3: expected `Date: _YYYY-MM-DD_`, got: {lines[2]!r}")
    elif len(lines) < 5 or lines[3] != "":
        errors.append(f"{path}: expected blank line after Date")

    # Summary: non-empty paragraph before the first `## ` section.
    summary = []
    i = 4
    while i < len(lines) and not lines[i].startswith("## "):
        if lines[i].strip():
            summary.append(lines[i])
        i += 1
    if not summary:
        errors.append(f"{path}: missing summary paragraph after Date")
    else:
        summary_text = " ".join(summary).strip()
        sentences = [s for s in re.split(r"(?<=[.!?]) ", summary_text) if s.strip()]
        if not (2 <= len(sentences) <= 4):
            errors.append(
                f"{path}: summary must be 2-4 sentences, found {len(sentences)}")

    # Parse sections (top-level) and subsections.
    sections: List[Tuple[str, int]] = []      # (name, line number)
    subs: List[Tuple[str, str, int, int]] = []  # (kind C/H, number, title, line)
    for idx, line in enumerate(lines, start=1):
        m = SECTION_RE.match(line)
        if m:
            sections.append((m.group(1), idx))
        m = SUBSECTION_RE.match(line)
        if m:
            subs.append((m.group(1), m.group(2), m.group(3), idx))

    section_names = [s[0] for s in sections]

    # Mandatory tail sections present, in order, and Version last.
    tail_positions = [section_names.index(n) for n in MANDATORY_TAIL
                      if n in section_names]
    for n in MANDATORY_TAIL:
        if n not in section_names:
            errors.append(f"{path}: missing mandatory section `## {n}`")
    if tail_positions != sorted(tail_positions):
        errors.append(f"{path}: mandatory sections must appear in order: "
                      f"{', '.join(MANDATORY_TAIL)}")
    if section_names and section_names[-1] != "Version":
        errors.append(f"{path}: `## Version` must be the last section")

    # At least one of Changes/Fixes.
    if "Changes" not in section_names and "Fixes" not in section_names:
        errors.append(f"{path}: need at least one of `## Changes` / `## Fixes`")

    # No sections outside the canonical set (enforces a single format).
    for name, ln in sections:
        if name not in CANONICAL_SECTIONS:
            errors.append(f"{path}:{ln}: non-canonical section `## {name}` "
                          f"(allowed: {', '.join(CANONICAL_SECTIONS)})")

    # Subsections only under Changes (C#) / Fixes (H#), sequential numbering.
    if subs:
        # Determine which top-level section each subsection falls under.
        for kind, num, title, ln in subs:
            parent = None
            for name, pn in sections:
                if pn < ln:
                    parent = name
                else:
                    break
            if kind == "C" and parent != "Changes":
                errors.append(f"{path}:{ln}: `### C#:` subsection must be under "
                              f"`## Changes` (found under {parent})")
            if kind == "H" and parent != "Fixes":
                errors.append(f"{path}:{ln}: `### H#:` subsection must be under "
                              f"`## Fixes` (found under {parent})")

        for kind, label in (("C", "Changes"), ("H", "Fixes")):
            nums = [int(n) for k, n, _, _ in subs if k == kind]
            if not nums:
                continue
            if sorted(nums) != list(range(1, len(nums) + 1)):
                errors.append(f"{path}: `{label}` subsections must be numbered "
                              f"sequentially C1..C{len(nums)} / H1..H{len(nums)}, "
                              f"found: {sorted(nums)}")

    # Version section content.
    if "Version" in section_names:
        v_idx = sections[[s[0] for s in sections].index("Version")][1]
        # Find first non-empty line after the Version heading.
        body = [l for l in lines[v_idx:] if l.strip()]
        if body:
            if not VERSION_RE.match(body[0]):
                errors.append(f"{path}: `## Version` must contain exactly "
                              f"`Bumped from A.B.C to X.Y.Z.`, got: {body[0]!r}")
            elif body[0].split(" to ")[1][:-1] != version:
                errors.append(f"{path}: Version section target {body[0]!r} does "
                              f"not match header version {version}")
        else:
            errors.append(f"{path}: `## Version` section is empty")

    # ASCII-only.
    for idx, line in enumerate(lines, start=1):
        if any(ord(c) > 0x7E for c in line):
            errors.append(f"{path}:{idx}: non-ASCII character in line")

    # 3-space list indentation (lines starting with 3+ spaces under a subsection
    # that are list items should use exactly 3 spaces of indent for `- ` items).
    for idx, line in enumerate(lines, start=1):
        m = re.match(r"^ {4,}- ", line)
        if m:
            errors.append(f"{path}:{idx}: list item indented with 4+ spaces; "
                          f"use exactly 3 spaces")

    return errors


def main() -> None:
    files = collect_changelogs()
    if not files:
        print(f"  No changelog files found in {CHANGELOG_DIR}/")
        sys.exit(1)

    all_errors: List[str] = []
    for name in files:
        all_errors.extend(check_file(f"{CHANGELOG_DIR}/{name}"))

    if all_errors:
        for e in all_errors:
            print(f"  ERROR: {e}")
        print(f"  Changelog format check FAILED ({len(all_errors)} error(s))")
        sys.exit(1)

    print(f"  All {len(files)} changelogs conform to the canonical format.")
    sys.exit(0)


if __name__ == "__main__":
    main()
