# Documentation Site Transparency

This page states what the deployed CRDT manual records when you read it. The
deployed manual is at <https://ada-crdt.readthedocs.io/en/latest/>. The project
runs no web server and no account system, so the project itself records
nothing about a reader.

The manual is a static site. Every page, style, script, and image file is built
from the repository and served as a file. The page you read now was generated
once, when the hosting provider built the documentation.

## The short answers

| Question | Answer |
|----------|--------|
| Does the project run analytics on a reader? | No. |
| Does the manual set a cookie? | No. |
| Does the manual load a script from another domain? | No. |
| Does the search box send a search word to a server? | No. |
| Does the hosting provider count page views? | Yes, in aggregate and without a cookie. |
| Does the manual show a paid advertisement? | No. |
| Does the manual show the hosting provider's flyout menu? | No. |
| Does the library make a network call? | No. |

## Search

The search box in the sidebar comes from the search index that the Sphinx HTML
builder writes. The build writes one static **search index** file that holds the
words and page names of the whole manual. Your browser loads that file and
matches your search word against it, in your own browser.

A search word never leaves your computer, and the hosting provider never
receives it. The manual keeps no list of search words, and it sets no cookie to
remember a past search.

## Traffic analytics

The hosting provider counts **page views** with its own **analytics**. It does
this for every manual it serves, and this project cannot switch it off. The
provider states that the counting is aggregate, that it uses no cookie, and
that it does not follow readers between sites. The provider also states that it
deletes its web server logs, including the IP address and the browser type,
after 10 days.

The provider obeys **Do Not Track**. If your browser sends `DNT: 1`, the
provider does not count the page view. The provider publishes its own
[privacy policy](https://docs.readthedocs.io/page/privacy-policy.html) and its
[analytics section](https://docs.readthedocs.io/page/privacy-policy.html#plausible).

The project does not add any analytics of its own. The build configuration
carries no tracking tag, so the generated pages contain no code that reports a
reader to the project or to any other company.

## Advertising and the flyout menu

This project serves no **paid advertisement**. The project owner turned that
option off in the dashboard of the hosting provider, under `Admin` >
`Advertising`. The provider also offers free **community advertisements** for
open source projects. Those messages are not paid, and the project cannot
remove them through the dashboard.

The manual does not show the **flyout menu** of the hosting provider either. The
project owner turned the flyout off under `Settings` > `Addons` > `Flyout
Menu`. The flyout holds the version selector, so the manual now serves one
version, the latest build.

## Third-party content

The manual loads no external resource. The Furo theme uses no web font, and the
build adds no video, no social button, no map, and no image from another
domain. The provider can add a link-preview popup to each page. The project
only restyles that popup for dark mode, and adds no code of its own.

## The library and the demo

The library makes no network call. The Game of Life demo simulates three
replicas in one process, and it talks to no other process.

The build tool `alr` and the proof tool `gnatprove` run on your machine. Alire
downloads a GNAT toolchain on the first build, and that download is the only
network activity of the build.

## How to examine the manual

You can check every statement on this page. Open the network panel of your
browser, then load any page of the manual. The panel shows a request for each
file of the page, and every request goes to `ada-crdt.readthedocs.io`.

You can also view the page source. You find no third-party script, and no
cookie is set.

## Changes to this page

This page describes the build configuration in `docs/conf.py` and the settings
of the hosting provider. The project changes this page in the same change that
alters either one. If the two ever disagree, treat this page as the defect and
report it on the
[GitHub repository](https://github.com/bladeacer/Ada_CRDT/issues).

## See also

- [Third-party notices](THIRD_PARTY_NOTICES.md) -- the documentation toolchain
  and the hosting service, with their licences.
- [Credits](CREDITS.md) -- the attributions behind the manual.
- [CI/CD](ci-cd.md) -- the workflows that build the deployed manual.
