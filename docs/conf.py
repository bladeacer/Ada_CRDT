# Sphinx configuration for the CRDT manual.
#
# Read the Docs builds the Markdown project at `docs/` with this file
# (see .readthedocs.yaml, `sphinx.configuration`).  The pages stay
# Markdown: the MyST parser reads `docs/*.md` unchanged, so no page is
# ever converted to reStructuredText.
#
# Only the docs toolchain requires Python.  The CRDT library itself has
# no Python or docs dependency; sphinx + myst-parser + furo are dev
# dependencies (requirements.txt) used by Read the Docs and any local
# `sphinx-build` run.
#
# The Furo theme is used (https://github.com/pradyunsg/furo): a clean,
# modern Sphinx theme.  Furo pulls no web fonts and no images.
#
# The generated API reference (docs/api-docs/), the changelogs, the
# compliance artefacts, and the proof ledger are reached through their
# section index pages (and search), not the top-level sidebar.  Sphinx
# warns for every page not named in a toctree; those are expected, so
# the warning is silenced -- every such page still builds, is reachable
# via its index and the built-in search.

import os

# -- Project -----------------------------------------------------------------

project = "crdt"
author = "bladeacer"
copyright = "bladeacer"
release = "latest"

# -- General -----------------------------------------------------------------

# The manual index lives at docs/index.md (the landing page).  `root_doc`
# names the master document that hosts the toctree.
root_doc = "index"
source_suffix = {".md": "markdown"}

# MyST turns the .md pages into Sphinx documents without reStructuredText.
extensions = ["myst_parser"]

# Every heading gets a stable "#slug" anchor at depth 3 (matching the
# maximum heading depth the pages use), so section links stay permanent.
myst_heading_anchors = 3

# Build products and tool directories are never sources.
exclude_patterns = [
    "_build",
]

# The api-docs/, changelogs/, proof/, compliance/, and badges/ pages are
# reached through their section index pages (and search), not the
# top-level sidebar.  Sphinx warns for every page not named in a
# toctree; those are expected here, so the warning is silenced.
suppress_warnings = ["toc.not_included"]

# -- HTML output (Furo theme) ------------------------------------------------

# The Furo theme (https://github.com/pradyunsg/furo).  It is declared in
# requirements.txt alongside sphinx and myst-parser.
html_theme = "furo"

# Canonical URL for Read the Docs (no effect on the local build).
html_baseurl = os.environ.get("READTHEDOCS_CANONICAL_URL", "/")

# The manual builds purely from source with no network: Furo pulls no
# fonts or images, so nothing else needs bundling.

# ---------------------------------------------------------------------------
# Match the Read the Docs link previews to the active theme
# ---------------------------------------------------------------------------
#
# Read the Docs injects its "link previews" hover popup into document.body and
# paints it with hard-coded light colours.  Furo's dark palette is defined on
# body[data-theme], which the popup inherits, so in dark mode the popup shows
# dark-theme text on a white box and the excerpt cannot be read.
#
# rtd-linkpreviews.css re-points the popup at Furo's own variables, so it
# follows the light/dark/auto toggle.  html_static_path is required because
# Sphinx resolves html_css_files against the output _static directory but only
# copies the files listed in html_static_path.

html_static_path = ["_static"]
html_css_files = ["rtd-linkpreviews.css"]

# ---------------------------------------------------------------------------
# Show the manual index in the sidebar
# ---------------------------------------------------------------------------
#
# Furo's global navigation tree comes from the root document's toctrees, so the
# root document itself (the manual index) is never listed -- only the brand link
# in the sidebar header points back to it.  Sphinx forbids a toctree referencing
# its own master document, so the canonical index entry is injected here with a
# tiny, contained html-page-context hook that prepends a clearly-labelled
# "Documentation index" link to the top of the navigation tree on every page.
# The hook is the same pattern the sibling adacovex manual uses.


def _prepend_index_to_sidebar(app, pagename, templatename, context, doctree):
    tree = context.get("furo_navigation_tree")
    if tree is None:
        return
    root = app.config.root_doc or "index"
    href = context["pathto"](root)
    index_entry = (
        '<p class="caption" role="heading">'
        '<span class="caption-text">CRDT Documentation</span></p>'
        "<ul><li class=\"toctree-l1\">"
        f'<a class="reference internal" href="{href}">'
        "Documentation index</a></li></ul>"
    )
    context["furo_navigation_tree"] = index_entry + tree


def setup(app):
    app.connect("html-page-context", _prepend_index_to_sidebar, 800)
