# Credits

This project vendors and builds on third-party work. We credit each project
below. See `docs/THIRD_PARTY_NOTICES.md` for the licence notices.

## Documentation toolchain

The manual under `docs/` is built with [Sphinx](https://www.sphinx-doc.org/)
(using the [Furo](https://github.com/pradyunsg/furo) theme and the
[MyST](https://myst-parser.readthedocs.io/) Markdown parser) and hosted by
[Read the Docs](https://readthedocs.org/). The deployed copy is at
<https://ada-crdt.readthedocs.io/en/latest/>. Sphinx, Furo, and MyST are
credited in full in [Third-Party Notices](THIRD_PARTY_NOTICES.md), and the
pages are offered under the CRDT licence.

The manual states what the deployed site records about a reader in
[site transparency](site-transparency.md). Read the Docs counts page views in
aggregate with its own analytics, and the project adds no tracker of its own.

## SimpleEnglish skill

The ASD-STE100 Simplified Technical English guidance comes from the open-source
SimpleEnglish skill. The project vendors a local copy at `skills/simple-english/`
so that documentation work and CI need no network access. Upstream:
`https://github.com/AminBlg/SimpleEnglish`. Licence: MIT.

## Algorithm inspirations

The sequence engines build on published conflict-free replication algorithms.
The Yjs chunk engine follows the design of the Yjs project's sequence type. The
Fugue binary-search-tree engine follows the Fugue anti-interleaving algorithm.
Neither project's source code is vendored; only the algorithms inform the
design.

## Cryptographic specification references

The `CRDT.Security` layer implements published cryptographic specifications:
FIPS 180-4 for SHA-256, RFC 2104 for HMAC-SHA-256, and RFC 8554 with NIST
SP 800-208 for the LM-OTS/LMS signature verification. RFC 4231 supplies the
HMAC test vectors in the test suite. The project includes no code from these
documents; see `docs/THIRD_PARTY_NOTICES.md` for the full notice and the role
of each specification.
