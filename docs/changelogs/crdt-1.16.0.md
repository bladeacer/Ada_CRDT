### CRDT 1.16.0

Date: _2026-10-03_

The manual is a page per section, so the sidebar tree is taller than the drawer
that holds it, and a reader who clicked a late entry landed on a page whose own
entry sat below the drawer's fold while the drawer stayed where it was. This
release moves the drawer to the entry for the page you are on, which closes a
coverage gap against the sibling adacovex manual and is the first behaviour
this manual gains from it since 1.15.0 brought the prose gate.

## Changes

### C1: The Sidebar Brings the Page You Are On Into View

Furo reveals its right-hand table of contents and nothing else, so no part of
the stock theme moves the left drawer. With a tree of 25 entries and a drawer
of 668 px the tree is 743 px tall, which puts the late entries out of reach.
Measured in Chromium at 1400x800 before this change: after clicking the
below-the-fold `CI/CD` entry, `.sidebar-scroll` stayed at `scrollTop` 0 with the
clicked entry at y=835, outside the visible drawer. The click looked like it
had gone nowhere.

New `docs/_static/sidebar-reveal.js`, registered through `html_js_files` in
`docs/conf.py`, moves the drawer. The rule is the same as the sibling adacovex
manual, so a reader moving between the two sites meets the same behaviour:

- only `.sidebar-scroll` takes a scroll offset; the page itself stays at its own
  top, and the script never scrolls the window or moves an element into view by
  API;
- the write is instant, because Furo sets `scroll-behavior: smooth` on the
  drawer and a smooth reveal from the drawer's top starts seconds late on a
  heavy page, which is the failure being fixed;
- the entry lands a quarter of the way down the drawer, so its caption and the
  entries after it stay on screen too;
- an entry already comfortably in view leaves the drawer where it is, so the
  drawer never jumps under a reader who has just scrolled it.

The entry is found two ways: Sphinx's `li.current-page > a` first, then by
resolved path, because the manual index is the root document and no toctree may
reference it. A page no toctree names, such as a changelog, an API-reference
package, `CREDITS`, or the search page, has no entry of its own, so the drawer
stays where it is rather than the script throwing on a null.

`docs/index.md` gains a paragraph stating the behaviour, so a reader learns it
from the manual rather than by noticing it. `docs/conf.py` carries a comment
block that ties the script to that statement.

## Test Suite

10332 tests passing across 10 categories, the same counts as 1.15.0, because
this release adds no Ada source and therefore no Ada test.

The verification is a browser sweep rather than a fixture, because the change
is a browser asset and this crate has no browser harness. Every page of the
built site was loaded in Chromium at 1400x800 and the drawer's scroll offset
and entry position were read: 83 pages, 0 script errors, and 13 pages whose
entry needed a reveal all ended with that entry inside the drawer, 0 left off
screen. Before the change those 13 pages were not revealed at all. The sweep
also confirms the null guard: the 60 pages that no toctree names load without a
script error.

## Proof Results

The proof result is unchanged at **Platinum**, with 0 justified and 0 unproved
checks over 972 verification conditions. The change set is one JavaScript file,
one line in `docs/conf.py`, and two paragraphs of documentation: no Ada source,
contract, pragma, or aspect changed, so the campaign was read from the existing
verification report rather than re-run.

| Metric | 1.15.0 | 1.16.0 |
|--------|--------|--------|
| Total checks | 972 | 972 |
| Proved | 972 (100%) | 972 (100%) |
| Justified | 0 | 0 |
| Unproved | 0 | 0 |
| Run-time Checks | 570 | 570 |
| Assertions | 86 | 86 |
| Functional Contracts | 103 | 103 |
| Termination | 99 | 99 |
| Analysed subprograms | 189 | 189 |
| Skipped | 10 generic units, 102 subprograms under `SPARK_Mode => Off` | 10 generic units, 102 subprograms under `SPARK_Mode => Off` |

## Traceability

The 27 HLR tags are unchanged. This release adds no requirement, because it
adds no library behaviour: a JavaScript file that moves a documentation drawer
is not a library function, and the manual is a documentation artifact. `make
compliance` still matches every source tag against `HLR.md`.

## Breaking Changes

None. The change set is documentation and one browser asset. No public
signature, generic signature, clock-strategy default, or wire format changes,
and no Ada line is touched, so the compiled library is byte-for-byte
equivalent.

## Version

Bumped from 1.15.0 to 1.16.0.