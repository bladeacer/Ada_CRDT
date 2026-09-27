--  Root package for the post-quantum security layer.
--  Provides SHA-256 integrity, HMAC-SHA-256 authentication between
--  replicas that share a symmetric key, and LM-OTS/LMS signature
--  verification (RFC 8554, NIST SP 800-208) for non-repudiable origin
--  checks on replica state.
--
--  Requirements traceability:
--  - HLR-SEC-SHA256: SHA-256 hash for integrity and signatures
--  - HLR-SEC-HMAC: HMAC-SHA-256 tag computation and comparison
--  - HLR-SEC-LMS: Post-quantum LMS signature verification

package CRDT.Security
  with SPARK_Mode
is

   --  Security level note.  SHA-256 with n = 32 gives classical
   --  128-bit pre-image strength and post-quantum 64-bit (Grover).
   --  The LM-OTS/LMS verification layer rests only on pre-image
   --  resistance, so it stays secure against a quantum attacker.
   Security_Level_Note : constant String := "SHA-256 based; post-quantum under Grover with 64-bit strength";

end CRDT.Security;
