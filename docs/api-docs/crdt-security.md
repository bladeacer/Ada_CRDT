# CRDT.Security

Root package for the post-quantum security layer.
Provides SHA-256 integrity, HMAC-SHA-256 authentication between
replicas that share a symmetric key, and LM-OTS/LMS signature
verification (RFC 8554, NIST SP 800-208) for non-repudiable origin
checks on replica state.

Requirements traceability:
- HLR-SEC-SHA256: SHA-256 hash for integrity and signatures
- HLR-SEC-HMAC: HMAC-SHA-256 tag computation and comparison
- HLR-SEC-LMS: Post-quantum LMS signature verification

> **Note:** All items in this package are public.
