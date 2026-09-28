### CRDT 1.15.0

Date: _2026-09-28_

This release repoints the README at the deployed Read the Docs manual and
states what that site records about a reader. A comparison with the sibling
adacovex manual then closed three coverage holes: the containers and wrappers
had no user page, the manual had no contributor section, and the proof and
badge sections had no landing page. The sibling's prose gate now runs here too,
and the CI workflows enforce the thresholds they previously only reported.

## Changes

<!-- no-crdt-docs-loc -->
<!-- Eleven changes across two work streams: the entry length is the record of
     the release, not prose that grew by accident. -->

### C1: README Links Point to the Deployed Manual

Every documentation link in `README.md` now uses the deployed URL shape
`https://ada-crdt.readthedocs.io/en/latest/<page>.html` instead of a relative
`docs/<page>.md` path. The five badges are clickable again, and each badge links
to the page that carries its data: `VERIFICATION.html` for SPARK and tests,
`compliance/index.html` for DO-178C, and the manual root for docs. A new
`## Badges` section names the source and the reported value of every badge.

The `### Quick Reference` table is generated, so the change lives in
`tools/gen-quickref.py`. The generator now writes the deployed URL for the API
Docs column, and its docstring records why the badge images keep the relative
path: the SVG files under `docs/badges/` are not part of the Sphinx build, so
the deployed site does not serve them.

### C2: Documentation Site Transparency Page

New page `docs/site-transparency.md`, linked from the manual index, the
documentation index, the usage guide, the README, `docs/CREDITS.md`, and
`docs/THIRD_PARTY_NOTICES.md`. The page states the full position in one place:

- The build adds no analytics tag, no tracker, and no consent banner, and the
  generated pages load no resource from another domain.
- Search runs in the reader's browser. The build writes one static search index
  file, so a search word never reaches a server.
- The hosting provider counts page views in aggregate with its own analytics,
  uses no cookie for the count, obeys Do Not Track, and deletes its web server
  logs after 10 days. The project cannot switch that counting off, and the page
  says so.
- Paid advertising is disabled and the flyout menu is disabled for both
  projects, through the provider dashboard. The page names the two dashboard
  paths, so a reader or a maintainer can check the claim, and it records the
  one limit: the provider still serves free community advertisements that the
  dashboard cannot remove.

`docs/conf.py` carries a comment block that ties the build to the page, so the
manual cannot drift from the promise. `docs/ste100-technical-names.md` gains a
`Web Site Terms` category with nine new Technical Names, because the page uses
non-STE words that the standard does not define.

### C3: Search Language Pinned in the Build Config

Sphinx builds search into the HTML builder, so the search box needs no
extension and no extra dependency. `docs/conf.py` now sets
`html_search_language` to `en`, which pins the stemmer to English instead of
letting it follow `language`. A future change to `language` therefore cannot
quietly break the matching of English words. The static `searchindex.js` and the
`search.html` page keep coming from the same build as every other page.

### C4: Documentation Style Follows the adacovex Manual

The user-guide page titles now follow the adacovex pattern of a sentence-case
descriptive title. The `Serialization` page becomes `Serialisation`, and every
page title now names its content, for example `Sync layers: state-based and
operation-based`. The manual index lists the deeper sub-pages inline, names the
deployed site, and adds a `This documentation site` section for the transparency
page. `tools/doc-links.map` follows, and `make doc-links` regenerates the
Documentation block of `AGENTS.md`.

### C5: Containers and Wrappers Get a User Page

New page `docs/usage/containers-and-wrappers.md` closes a coverage hole found
by comparing this manual with the adacovex one. `CRDT.Bounded`, `CRDT.Protected`,
and `CRDT.Rgas` appeared in the readme and in the generated API reference, but
no page on the deployed site explained them, so a reader of the site could not
learn that the protected types exist or that the containers already avoid the
heap without a wrapper. The page covers:

- why `CRDT.Bounded` is a naming and capacity contract rather than a heap guard,
  and the measured size that each generic formal bounds;
- the three protected types, the lock each call takes, and when to prefer a
  plain container;
- the multi-RGA collection, its `Count` discriminant, and why `Merge_All`
  merges into entry 1;
- the HLC contract, `Tick` before send and `Recv` before store.

Every signature and every capacity claim was read from the package
specifications. The page also records that `Bounded_LWW_Set` and
`Shared_LWW` wrap the deprecated `CRDT.Lww_Element_Sets`, and that new code must
instantiate `CRDT.Lww_Sets` instead. The page is linked from the manual index,
the usage guide, and the readme.

### C6: Contributor Documentation Moves Onto the Site

The manual had no contributor section, while the adacovex manual has fourteen
pages for people who change the code. Two new pages bring that audience on-site:

- `docs/contributing/quality-gates.md` lists the twelve gates of `make check` in
  their real order, the single-purpose targets, the five generated files and
  their sources of truth, and the two-manifest rule.
- `docs/contributing/llm-usage.md` expands the one-line readme disclosure into
  the disclosure, the evidence table, the five-point bar for a change, the
  machine-facing contract, and the limits of what a gate can check.

The index gains a `Contributing` section, and the readme links both pages from
its documentation table and its contributing section.

### C7: Proof Records and Badges Get Landing Pages

`docs/proof/index.md` and `docs/badges/index.md` are new landing pages, so both
sections have an entry point that a reader can navigate from. The proof page
reconciles the two skip counts that appear in the verification report, and it
lists the five reason groups for a skipped unit with an example of each. The
badges page states what each SVG reports, shows every badge inline, and gives
the regeneration command and the markdown snippet for a third-party readme.

The three standards badges carry values that the readme never showed:
`ISO 26262 ASIL B PASS` and `IEC 62304 Class A PASS`. Both are now documented,
and the readme badges link to the badges page instead of to a page that only
carries part of the data.

### C8: See Also Sections on Every User Page

Each of the seven user-guide pages ends with a `See also` section, matching the
adacovex convention. Before this change the pages cross-linked only in prose,
and `getting-started` linked to no sibling page at all, so a reader who finished
the quick start had no in-page route to the container or sync pages. The
cross-link count per user page rises from 2 to 4 or more.

### C9: The Demo Is on the Site, and the Agent Guide No Longer Overstates It

The demo was documented in the readme only, and the agent guide claimed that it
covers the Yjs, Naive, and Fugue engines. The source contradicts that: the
demo defines two grid modes, a matrix and a Yjs RGA, and it cycles the clock
strategy through Lamport, Vector, and Matrix. The Naive and Fugue engines are
covered by the test suite. The claim in `AGENTS.md` is corrected, because a
machine agent that trusted it would look for engine coverage that does not
exist.

`docs/usage/getting-started.md` gains a `Watch it converge` section with the
five keys, so a reader who finishes the quick start can see the library work
before writing any code.

### C10: The Prose Gate Arrives From the adacovex Sibling

`tools/check-docs.py` and `tools/para-split.py` are ported from the sibling
adacovex project, adapted to this crate. The new `make docs-check` target runs
in `make check` and enforces four rules on the hand-written Markdown, the
changelogs, `README.md`, and the comment text of every Ada source:

- no paragraph over four sentences;
- one space after a sentence-ending `.`, `!`, or `?`;
- no em dash and no Latin abbreviation;
- a soft 250-line cap, which a reference page opts out of with a
  `no-crdt-docs-loc` marker.

The port needed four adaptations. The line-cap marker is named for this crate
rather than for adacovex. The exclusion of adacovex's generated Ada units is
gone, because this crate generates no Ada unit, so every file under `src/` is
in scope, the test sources included. The `.adacovex/patches/` scan stays, since
this repository carries a VT100 patch for the demo.

The em-dash check is written
as an escape in the module docstring, because the charset gate forbids a literal
em dash in a source file.

Bringing the existing prose into compliance touched 33 files and changed no
meaning. The spacing fixer collapsed 52 double spaces: 11 in `HLR.md` and
`PSAC.md`, 40 in the comment text of 18 Ada sources, and 1 in the demo patch
file. The paragraph fixer inserted blank lines in 10 pages, including five
historical ones, because it never rewrites a sentence. The five files over the
line cap carry the marker with a written reason: the requirement register, the
requirement mapping, the proof ledger, the Technical Names dictionary, and the
readme.

The four regenerated API pages follow their docstrings, and the build, the full
10332-test suite, and the proof campaign were re-run after the change.

### C11: CI Enforces What It Only Reported

`ci.yml` ran the adacovex assessment and then trusted it. The four threshold
inputs the release workflow sets were absent, so a dropped docstring, a lower
SPARK level, an unproved check, or a lost test reached `main` and surfaced for
the first time on a release tag. The assessment job now sets the same
`require-spark: Platinum`, `require-docstrings: 100`, `require-tests: 10332`,
and `require-proof: 100` that `release.yml` enforces.

Three further changes close gaps against the adacovex workflows. A
`static-gates` job runs the pure-Python gates in CI, which no job did before:
ascii, changelog format, link resolution, the new prose gate, and the generated
doc-links block. The release-baseline coverage gate is now push-only, because
the per-pull-request delta in `pr-check.yml` already covers what a pull request
can regress, and running both assessed the same regression twice. The workflow
gained the `ci-${{ github.ref }}` concurrency group so a superseded proof run
is cancelled, and every job gained a `timeout-minutes` value.

The stale proof figure in a workflow comment is corrected from `589/589` to
`972/972`, which is the number the verification report and the re-run proof
both give. `docs/ci-cd.md` is rewritten to match the workflows, including the
compiler and prover split: the action pins the 15.2.1 compiler, while
`alire-dev.toml` declares `gnatprove = "^16.1.0"`.

## Fixes

### H1: The Proof Status Rewrite No Longer Overwrites A Historical Baseline

`tools/update-proof-status.py` promises to leave historical proof numbers
alone, and it did for every prose form it recognises. One rule broke that
promise: the pattern that refreshes the current-metrics table row matched the
first `Total checks | <n>` cell on any line. In a release-to-release
comparison row such as `| Total checks | 589 | 972 |` in the 1.14.0
changelog, that is the previous release's baseline, so the rewrite replaced
589 with 972 and destroyed the comparison.

The rule is now anchored to a row whose data cell is the last cell on the
line, so a comparison row keeps both numbers. The consequence of the defect
was that `make check` failed on a clean tree: the `proof-status --check` step
flagged the 1.14.0 changelog as carrying stale metrics, because the tool
expected it to hold only current numbers. The gate now passes with the
historical row intact.

## Test Suite

10332 tests passing across 10 categories, the same counts as 1.14.0. The
release re-ran the whole suite after the comment normalisation in C10: the
library builds and every category still passes, including the 10038 fuzz tests.

| Category | Tests | Status |
|----------|-------|--------|
| Basic: PN+LWW+RGA+RGAs | 34 | PASS |
| Clocks: Lamport+Vector+Matrix+Lww_Sets | 40 | PASS |
| Lattice Properties: law check | 8 | PASS |
| RGA Features: interleave+split+delta+GC | 56 | PASS |
| Serialization: V1+V2+byte-boundary | 62 | PASS |
| Engines: Yjs+Naive+Sync | 34 | PASS |
| Convergence: merge+skew+saturation | 21 | PASS |
| Fuzz: chaos+10k+partitions | 10038 | PASS |
| Game of Life: neighbors+blinker+sync+conv+mode | 24 | PASS |
| Security: sha256+hmac+lms | 15 | PASS |

## Proof Results

The proof result is unchanged at **Platinum**, with 0 justified and 0 unproved
checks over 972 verification conditions. C10 edits the comment text of 18 Ada
sources, so the campaign was re-run rather than assumed: `make prove` reports
972 total, 972 proved, 0 justified, 0 unproved, the same figures as 1.14.0.
No code, contract, pragma, or aspect changed.

| Metric | 1.14.0 | 1.15.0 |
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

The SBOM regenerated during the proof run was reverted. It carried a new
timestamp and a `dep_scope` field that the current covex build reports
differently, and neither belongs to a documentation release. The release
workflow regenerates the SBOM at tag time.

## Traceability

The 27 HLR tags are unchanged. This release adds no requirement, because it
adds no library behaviour. The new pages describe the documentation site, the
containers and wrappers, the gates, and the AI disclosure, and the Technical
Name dictionary is a documentation artifact. The comment normalisation touches
no requirement, no contract, and no HLR tag, and `make compliance` confirms
that every source tag still matches `HLR.md`.

## Breaking Changes

None. The change set is documentation, comment text, and CI configuration. The
comment normalisation touches no code line, so the compiled library is
byte-for-byte equivalent, and the README URLs resolve to the same pages as the
repository paths they replace. No public signature, generic signature,
clock-strategy default, or wire format changes.

## Version

Bumped from 1.14.0 to 1.15.0.
