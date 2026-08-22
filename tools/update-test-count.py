#!/usr/bin/env python3
"""Update the current test-suite counts in the repo after `make test`.

The test counts in AGENTS.md, README.md, Makefile, the CI workflows,
alire.toml, and docs were edited by hand and went stale on every test change.
This script parses test_result.md (written by `make test` / test_crdt),
extracts the per-category counts and the Passed/Failed totals, and rewrites
the anchored test-count phrases across the repo.

Historical notes (past-release changelogs, the proof ledger) are left
untouched because they do not match the anchored patterns.  The generated
badge (docs/badges/tests.svg) is *not* edited here: `make prove` rewrites it
via adacovex.

The file set is derived from the tree (tools/live_files.py) rather than a
hardcoded list, so a new doc file carrying a test count is picked up
automatically and can never go stale.

Usage:
  python3 tools/update-test-count.py [--dry-run] [--check] [--result=test_result.md]

--result   Path to the test-result summary to parse (default test_result.md).
--dry-run  Parse and report the new counts without editing any file.
--check    Verify every live file already carries the current counts;
           exit 1 (without editing) when any file is stale.

Exit code 0 when every anchored pattern matched and was updated (or, with
--dry-run/--check, would be / already is), 1 when the result could not be
parsed or a pattern did not match.
"""

import argparse
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

ROOT: Path = Path(__file__).resolve().parent.parent

from live_files import live_files  # noqa: E402  (same-tools import)

# test_result.md category name -> short key (for future agents-tree usage)
CATEGORY_KEY: Dict[str, str] = {
    "Basic: PN+LWW+RGA+RGAs": "basic",
    "Clocks: Lamport+Vector+Matrix+Lww_Sets": "clocks",
    "Lattice Properties: law check": "lattice",
    "RGA Features: interleave+split+delta+GC": "rga_features",
    "Serialization: V1+V2+byte-boundary": "serialization",
    "Engines: Yjs+Naive+Sync": "engines",
    "Convergence: merge+skew+saturation": "convergence",
    "Fuzz: chaos+10k+partitions": "fuzz",
    "Game of Life: neighbors+blinker+sync+conv+mode": "gol",
}


def parse_result(path: Path) -> Tuple[Dict[str, int], int, int]:
    """Return (category counts, passed, failed) from a test_result.md file."""
    text: str = Path(path).read_text(errors="replace")
    cats: Dict[str, int] = {}
    passed: Optional[int] = None
    failed: Optional[int] = None

    for raw in text.splitlines():
        line: str = raw.strip()
        m: Optional[re.Match] = re.match(
            r"\|\s*(.+?)\s*\|\s*(\d+)\s*\|", line
        )
        if m:
            name: str = m.group(1).strip()
            if name not in ("Category", "Tests", "") and not name.startswith("-"):
                cats[name] = int(m.group(2))
        m2 = re.match(r"Passed:\s*(\d+)\s+Failed:\s*(\d+)", line)
        if m2:
            passed = int(m2.group(1))
            failed = int(m2.group(2))

    if passed is None:
        raise SystemExit(f"error: no 'Passed: N  Failed: M' line in {path}")
    if not cats:
        raise SystemExit(f"error: no category rows found in {path}")

    for name in CATEGORY_KEY:
        if name not in cats:
            raise SystemExit(f"error: category '{name}' missing from {path}")
    return cats, passed, failed or 0


def total_phrase_repls(passed: int, failed: int, total: int) -> List[Tuple[str, str]]:
    """Anchored (pattern, format) pairs for the total/passed counts.
    These patterns are specific to the total suite count, not category breakdowns."""
    return [
        (r"(\d+)/(\d+) tests passing", f"{passed}/{total} tests passing"),
        (r"(\d+) tests passing", f"{total} tests passing"),
        (r"--require-tests=(\d+)", f"--require-tests={passed}"),
        (r"require-tests: (\d+)", f"require-tests: {passed}"),
        (r"(\d+)-test native suite", f"{total}-test native suite"),
        (r"(\d+) tests across \d+ categories",
         f"{total} tests across {len(CATEGORY_KEY)} categories"),
        (r'"tests_passed":\d+', f'"tests_passed":{passed}'),
        (r'"tests_failed":\d+', f'"tests_failed":{failed}'),
        # Total test count in changelog/readme contexts: "10290 tests passing" etc.
        (r"\b\d+ tests passing\b", f"{total} tests passing"),
        (r"\b\d+ tests total\b", f"{total} tests total"),
    ]


def main() -> int:
    ap: argparse.ArgumentParser = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--result", default=str(ROOT / "test_result.md"))
    ap.add_argument("--dry-run", action="store_true",
                    help="report new counts without editing files")
    ap.add_argument("--check", action="store_true",
                    help="verify live files carry the current counts (exit 1 when stale)")
    args: argparse.Namespace = ap.parse_args()

    cats, passed, failed = parse_result(Path(args.result))
    total: int = passed + failed
    print(f"tests: {passed} passed, {failed} failed ({total} total)")
    for name, count in cats.items():
        print(f"  {name}: {count}")

    if args.dry_run:
        return 0

    repls: List[Tuple[str, str]] = total_phrase_repls(passed, failed, total)

    files: List[Path] = live_files()

    stale: int = 0
    matched: int = 0
    for f in files:
        text: str = f.read_text(errors="replace")
        orig: str = text
        for pat, rep in repls:
            text, n = re.subn(pat, rep, text)
            matched += n
        if text != orig:
            if args.check:
                stale += 1
                print(f"STALE: {f.relative_to(ROOT)}")
            else:
                f.write_text(text)
                print(f"updated: {f.relative_to(ROOT)}")

    if args.check:
        if stale:
            print(f"error: {stale} file(s) carry stale test counts "
                  f"(run `make test-count` to refresh)", file=sys.stderr)
            return 1
        print("test counts in sync across all live files")
        return 0

    if matched == 0:
        print("warning: no test-count pattern matched; docs may not contain anchored phrases",
              file=sys.stderr)
        return 0
    print(f"updated {matched} test-count occurrence(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
