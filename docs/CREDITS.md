# Credits

This project vendors and builds on third-party work. We credit each project
below. See `docs/THIRD_PARTY_NOTICES.md` for the licence notices.

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
