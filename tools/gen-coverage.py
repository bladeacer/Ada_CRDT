#!/usr/bin/env python3
"""
Generate SPARK coverage report page for docs/api-docs/.
Scans all .ads and .adb files for SPARK_Mode => Off annotations
and extracts their justification from surrounding comments.

Usage:
  python3 tools/gen-coverage.py          # regenerate docs/api-docs/crdt-spark-coverage.md
  python3 tools/gen-coverage.py --check  # verify the committed report is in sync
                                         # (used by `make spark-off-check`); exit 1 on drift
"""
import argparse
import os
import re
import sys
from typing import Dict, List, Tuple, TypedDict


class SparkOffEntry(TypedDict):
    file: str
    line: int
    text: str
    justification: str
    kind: str


class BreakdownCounts(TypedDict):
    public: int
    private: int


class BreakdownDetails(TypedDict):
    public: List[str]
    private: List[str]


class ProofStats(TypedDict):
    total: str
    proved: str
    justified: str
    unproved: str


SRC_DIR = "src"
OUTPUT = "docs/api-docs/crdt-spark-coverage.md"


def find_spark_off(dirpath: str) -> List[SparkOffEntry]:
    """Find all SPARK_Mode => Off occurrences with context."""
    results: List[SparkOffEntry] = []
    for root, dirs, files in os.walk(dirpath):
        dirs.sort()
        for f in sorted(files):
            if not f.endswith((".ads", ".adb")):
                continue
            path = os.path.join(root, f)
            rel = os.path.relpath(path, start=".")
            with open(path, "r", encoding="utf-8") as fp:
                lines = fp.readlines()
            for i, line in enumerate(lines):
                stripped = line.strip()
                if stripped.startswith("--"):
                    continue
                if re.search(r"SPARK_Mode\s*=>\s*Off", stripped):
                    # Gather preceding comments
                    comments: List[str] = []
                    for j in range(i - 1, max(i - 6, -1), -1):
                        cl = lines[j].strip()
                        if cl.startswith("--") and not cl.startswith("---"):
                            comments.insert(0, cl)
                        elif cl == "":
                            continue
                        else:
                            break
                    justification = ""
                    for cmt in comments:
                        justification += cmt.replace("--", "").strip() + " "
                    justification = justification.strip()
                    results.append({
                        "file": rel,
                        "line": i + 1,
                        "text": stripped,
                        "justification": justification or "(no comment)",
                        "kind": "body" if f.endswith(".adb") else "spec",
                    })
    return results


def public_private_breakdown(dirpath: str) -> Tuple[BreakdownCounts, BreakdownDetails]:
    """Count public vs private entities in .ads files."""
    counts: BreakdownCounts = {"public": 0, "private": 0}
    details: BreakdownDetails = {"public": [], "private": []}
    for root, dirs, files in os.walk(dirpath):
        dirs.sort()
        for f in sorted(files):
            if not f.endswith(".ads"):
                continue
            path = os.path.join(root, f)
            rel = os.path.relpath(path, start=".")
            with open(path, "r", encoding="utf-8") as fp:
                content = fp.read()
            # Simple heuristic: count subprogram declarations before/after "private"
            parts2 = content.split("\nprivate")
            if len(parts2) == 1:
                pub = content
                priv = ""
            else:
                pub = parts2[0]
                priv = parts2[-1].lstrip("\n")
            # Count function/procedure declarations (rough)
            pub_count = len(re.findall(r"\b(procedure|function)\s+\w+", pub))
            priv_count = len(re.findall(r"\b(procedure|function)\s+\w+", priv))
            # Exclude test files from breakdown
            if "test_" not in rel:
                counts["public"] += pub_count
                counts["private"] += priv_count
                details["public"].append(f"  - `{rel}`: {pub_count} subprograms")
                details["private"].append(f"  - `{rel}`: {priv_count} subprograms")
    return counts, details


def parse_gnatprove_stats(prove_out: str) -> ProofStats:
    """Parse SPARK proof stats from gnatprove.out if available."""
    stats: ProofStats = {"total": "?", "proved": "?", "justified": "?", "unproved": "?"}
    if not os.path.isfile(prove_out):
        return stats
    with open(prove_out, "r", encoding="utf-8") as fp:
        content = fp.read()
    m = re.search(r"^Total\s+(\d+)\s+.*?(\d+)\s+(\d+)\s+(\d+)", content, re.MULTILINE)
    if m:
        stats["total"] = m.group(1)
        stats["proved"] = m.group(2)
        stats["justified"] = m.group(3)
        stats["unproved"] = m.group(4)
    return stats


def generate_report() -> List[str]:
    """Return the SPARK coverage report lines without writing them."""
    items = find_spark_off(SRC_DIR)
    counts, details = public_private_breakdown(SRC_DIR)
    sp = parse_gnatprove_stats("obj/gnatprove/gnatprove.out")
    lines: List[str] = []
    lines.append("# CRDT SPARK Coverage Report")
    lines.append("")
    lines.append("Auto-generated by `tools/gen-coverage.py` via `make doc`.")
    lines.append("")
    lines.append("## SPARK_Mode => On (by package spec)")
    lines.append("")
    lines.append("All core specs use `SPARK_Mode` (On) at package level. "
                 "The following packages have scoped `SPARK_Mode => Off` "
                 "on individual subprograms or bodies:")
    lines.append("")

    # Group by file
    by_file: Dict[str, List[SparkOffEntry]] = {}
    for item in items:
        by_file.setdefault(item["file"], []).append(item)

    for fname in sorted(by_file.keys()):
        entries = by_file[fname]
        lines.append(f"### `{fname}`")
        lines.append("")
        for e in entries:
            just = e["justification"]
            lines.append(f"- Line {e['line']}: `{e['text']}`")
            if just and just != "(no comment)":
                lines.append(f"  - Justification: {just}")
            lines.append("")
        lines.append("")

    lines.append("## Public vs Private Interface Count")
    lines.append("")
    lines.append(f"- Public subprograms: **{counts['public']}**")
    lines.append(f"- Private subprograms: **{counts['private']}**")
    lines.append("")
    lines.append("### Per-package breakdown")
    lines.append("")
    lines.append("#### Public")
    for d in details["public"]:
        lines.append(d)
    lines.append("")
    lines.append("#### Private")
    for d in details["private"]:
        lines.append(d)
    lines.append("")

    lines.append("## Unproved Status")
    lines.append("")
    if sp["total"] != "?":
        lines.append(f"- **{sp['total']} total SPARK checks**: {sp['proved']} proved, {sp['justified']} justified, {sp['unproved']} unproved")
    else:
        lines.append("- **SPARK checks**: (run `make prove` to populate gnatprove.out)")
    lines.append("- Run `alr gnatprove` or `make prove` to regenerate.")
    lines.append("")

    return lines


def check() -> int:
    """Verify the committed report is in sync with the source.

    Exits 1 when a `SPARK_Mode => Off` location is missing from the committed
    report (i.e. `make doc` has not been re-run after a source change), so a
    new SPARK_Mode => Off can never land undocumented. Locations without an
    inline justification comment are reported as a non-failing warning: the
    policy (stream I/O, wall clock, RNG, access types, tests, demo) is
    documented in AGENTS.md, and the report itself is the review surface.
    """
    errors: List[str] = []
    warnings: List[str] = []

    items = find_spark_off(SRC_DIR)
    for item in items:
        if item["justification"] == "(no comment)":
            warnings.append(f"{item['file']}:{item['line']}: SPARK_Mode => Off "
                            f"without an inline justification comment "
                            f"(policy documented in AGENTS.md)")

    # The committed report must match a fresh generation exactly.
    fresh = "\n".join(generate_report()) + "\n"
    if not os.path.isfile(OUTPUT):
        errors.append(f"{OUTPUT} is missing -- run `make doc` to generate it")
    else:
        with open(OUTPUT, "r", encoding="utf-8") as fp:
            current = fp.read()
        if current != fresh:
            errors.append(f"{OUTPUT} is out of date -- run `make doc` to "
                          f"regenerate it (make spark-off-check compares "
                          f"source annotations against this report)")

    if warnings:
        print(f"  note: {len(warnings)} SPARK_Mode => Off location(s) lack an "
              f"inline justification comment (see AGENTS.md for the policy)")

    if errors:
        for e in errors:
            print(f"  ERROR: {e}")
        print(f"  SPARK coverage check FAILED ({len(errors)} issue(s))")
        return 1
    print(f"  SPARK coverage report is in sync ({len(items)} SPARK_Mode => Off "
          f"locations, all listed in {OUTPUT}).")
    return 0


def main(argv: List[str]) -> int:
    ap: argparse.ArgumentParser = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true",
                    help="verify the committed report is in sync instead of "
                         "regenerating it")
    args: argparse.Namespace = ap.parse_args(argv)

    if args.check:
        return check()

    with open(OUTPUT, "w", encoding="utf-8") as fp:
        fp.write("\n".join(generate_report()) + "\n")
    print(f"Wrote {OUTPUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
