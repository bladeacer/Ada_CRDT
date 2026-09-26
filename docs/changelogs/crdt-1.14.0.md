### CRDT 1.14.0

Date: _2026-09-26_

This release makes the Read the Docs link previews follow the active Furo
theme, because the Read the Docs addon paints its hover popup with hard-coded
light colours and the popup was unreadable in dark mode. The library code, the
wire protocol, and the public API are unchanged.

## Changes

### C1: Link Previews Follow The Active Theme

`docs/_static/rtd-linkpreviews.css` re-points the Read the Docs "link previews"
hover popup at Furo's own colour variables, and `docs/conf.py` loads the
stylesheet through `html_css_files`. The addon appends the popup to
`document.body` and paints it with hard-coded light colours, so on a Furo page
in dark mode the excerpt rendered dark-theme text on a white box and could not
be read.

The popup now uses `--color-background-primary` and
`--color-content-foreground`, so it follows the light, dark, and auto toggle
without a reload. Every selector carries a `body` prefix, because the addon
installs its stylesheet through `document.adoptedStyleSheets` and adopted
stylesheets apply after all author stylesheets. The colours inside the preview
need no rules of their own, because the injected markup is the target page's
own article element, so code blocks, tables, links, and admonitions resolve from
Furo's variables once the background is correct.

The defect is in the Read the Docs addon rather than in Furo or Sphinx, and the
same popup is affected on every theme that has a dark mode. The addon paints
its own background, so no theme can correct it from its own stylesheet. This
release therefore carries a small project stylesheet as a workaround, and the
defect is reported upstream to the addon.

## Test Suite

10290 tests passing across 9 categories, unchanged from 1.13.0. C1 changes only
a stylesheet and the Sphinx configuration, so it adds no tests and touches no
test code.

| Category | Tests | Status |
|----------|-------|--------|
| Basic: PN+LWW+RGA+RGAs | 34 | PASS |
| Clocks: Lamport+Vector+Matrix+Lww_Sets | 40 | PASS |
| Lattice Properties: law check | 8 | PASS |
| RGA Features: interleave+split+delta+GC | 40 | PASS |
| Serialization: V1+V2+byte-boundary | 62 | PASS |
| Engines: Yjs+Naive+Sync | 23 | PASS |
| Convergence: merge+skew+saturation | 21 | PASS |
| Fuzz: chaos+10k+partitions | 10038 | PASS |
| Game of Life: neighbors+blinker+sync+conv+mode | 24 | PASS |

## Proof Results

Unchanged from 1.13.0, because C1 changes no Ada source and therefore no proof
surface. The assurance level stays Platinum with 0 justified and 0 unproved
checks, and the proof cache is unaffected.

| Metric | 1.13.0 | 1.14.0 |
|--------|--------|--------|
| Total checks | 589 | 589 |
| Proved | 479 (81%) | 479 (81%) |
| Justified | 0 | 0 |
| Unproved | 0 | 0 |
| Run-time Checks | 322 | 322 |
| Assertions | 62 | 62 |
| Functional Contracts | 88 | 88 |
| Termination | 73 | 73 |
| Analyzed units | 34 | 34 |

## Traceability

No new HLRs are added. The 24 HLR tags are unchanged, because C1 changes only
the documentation build. The compliance artefacts were not regenerated, because
no requirement changed.

## Breaking Changes

None. C1 changes only a stylesheet and the Sphinx configuration. Every public
generic signature (`Lww_Element_Sets`, `Rga`, `Rgas`, `Protected`, `Bounded`,
`Sequences.*`, `Lww_Sets`) and the V1, V2, and V3 wire formats are unchanged.

## Version

Bumped from 1.13.0 to 1.14.0.
