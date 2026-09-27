# Third-Party Notices

This file records the licence notices for third-party material that this project
vendors or builds upon. See `docs/CREDITS.md` for the high-level attributions.

## SimpleEnglish skill

The `skills/simple-english/` directory is a vendored copy of the open-source
SimpleEnglish skill. The project uses it to apply ASD-STE100 Simplified
Technical English to its documentation and docstrings.

- Upstream: `https://github.com/AminBlg/SimpleEnglish`
- Licence: MIT

The vendored copy is used under the terms of the MIT licence. The upstream
repository contains the full licence text.

## Algorithm inspirations

The Yjs and Fugue sequence engines are original implementations that follow the
published algorithms named above. They do not include vendored third-party
source code, so no additional licence notice applies beyond this acknowledgement.

## Normative specification references

The `CRDT.Security` packages implement the algorithms of the published
specifications below. The project includes no code from these documents; it
uses them as normative references for the algorithm definitions and the test
vectors. Each specification carries its own terms of use at the source listed
here.

| Specification | Used by | Role |
|---|---|---|
| FIPS 180-4 (Secure Hash Standard) | `CRDT.Security.SHA256` | Defines the SHA-256 hash: the round constants, the compression function, and the padding rule |
| RFC 2104 (HMAC: Keyed-Hashing for Message Authentication) | `CRDT.Security.HMAC` | Defines the HMAC construction over SHA-256: the pad sizes, the key handling, and the two-pass hash |
| RFC 4231 (Identifiers and Test Vectors for HMAC-SHA-256) | `src/tests/test_security.adb` | Supplies the published test vectors that verify the HMAC implementation |
| RFC 8554 (LMS Signature Scheme) | `CRDT.Security.LMS` | Defines the LM-OTS one-time signatures, the Merkle tree, and the signature formats for the verify path |
| NIST SP 800-208 (Recommendation for Stateful Hash-Based Signatures) | `CRDT.Security.LMS` | Approves the LMS parameter sets and the leaf/index bounds that the verifier follows |
| RFC 8708 (Use of the HMAC-SHA-256 in X.509) | Context for `CRDT.Security.HMAC` | Describes one deployment profile of HMAC-SHA-256; the package stays profile-neutral |

All pages above are stable public documents from NIST and the IETF. The
`CRDT.Security` packages follow the algorithms as published, and the tests
decode the vectors from the documents. No extract of any specification text
ships with this project.
