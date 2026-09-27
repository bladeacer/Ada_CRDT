--  LM-OTS and LMS hash-based signature verification (RFC 8554,
--  NIST SP 800-208 approved).  Post-quantum: security rests only on
--  the pre-image resistance of SHA-256, so a quantum computer does not
--  break it the way it breaks RSA and ECDSA.
--
--  Verify-only by design: signing requires stateful one-time private
--  keys that must never be reused, and this library never holds secret
--  key state.  Peers sign CRDT state offline (a hardware token, a
--  signing service) and replicas verify with the public key before a
--  Merge is accepted.
--
--  Supported parameter sets (RFC 8554 tables 1 and 2, SP 800-208
--  section 4):
--    LMOTS_SHA256_N32_W8  (p = 34, ls = 0, w = 8, n = 32)
--    LMS_SHA256_M32_H5    (h = 5, m = 32)
--
--  Requirements traceability:
--  - HLR-SEC-LMS: Post-quantum LMS signature verification

with Ada.Streams;
with CRDT.Security.SHA256;

package CRDT.Security.LMS
  with SPARK_Mode
is

   --  RFC 8554 typecodes (XDR enum values, network byte order).
   LMOTS_SHA256_N32_W8 : constant := 4;
   LMS_SHA256_M32_H5   : constant := 5;

   --  Fixed two-byte domain separators (RFC 8554 section 4/5).
   D_PBLC : constant := 16#8080#;
   D_MESG : constant := 16#8181#;
   D_LEAF : constant := 16#8282#;
   D_INTR : constant := 16#8383#;

   subtype Byte is Ada.Streams.Stream_Element;

   subtype Byte_Array is Ada.Streams.Stream_Element_Array;

   use type Byte;
   use type Ada.Streams.Stream_Element_Offset;
   use type Byte_Array;

   --  LM-OTS Winternitz parameter (W8).
   W  : constant := 8;
   P  : constant := 34;   --  number of chain elements
   LS : constant := 0;    --  checksum left shift

   --  LMS tree height (H5).
   H : constant := 5;

   --  Hash output length n = m = 32 bytes.
   N_Length : constant := 32;

   --  Total LMS signature length: q (4) + OTS signature + type (4)
   --  + H path nodes of 32 bytes each.
   LMS_Sig_Length : constant := 4 + (4 + N_Length * (P + 1)) + 4 + H * N_Length;

   subtype N_String is Byte_Array (1 .. N_Length);

   subtype OTS_Signature is Byte_Array (1 .. 4 + N_Length * (P + 1));
   --  u32str(type) || C || y[0] .. y[p-1]

   subtype LMS_Signature is Byte_Array (1 .. LMS_Sig_Length);
   --  u32str(q) || lmots_signature || u32str(type) || path[0..h-1]

   --  Private key elements for one leaf (34 chain seeds).
   --  Held only by the offline signer; verification never sees it.
   type OTS_Private_Key is array (0 .. P - 1) of N_String;

   --  LMS public key: u32str(type) || u32str(otstype) || I || T[1].
   type Public_Key is record
      OTS_Type : Natural;
      I        : Byte_Array (1 .. 16);
      T1       : N_String;
   end record;

   --  Reference primitives (RFC 8554 equations) for key provisioning
   --  tools and conformance tests.  A signing deployment keeps its
   --  private keys offline; these helpers let the verifying side derive
   --  and check public-key material without holding secrets.

   --  Winternitz chain step: H (I || u32str (r) || u16str (D) || Rest).
   --  @param I    16-byte tree identifier.
   --  @param R    Node or leaf number for the security string.
   --  @param D    Two-byte domain separator.
   --  @param Rest Chained value.
   --  @return The next chain element.
   function Hash_LMS_Node (I : Byte_Array; R : Natural; D : Natural; Rest : Byte_Array) return N_String
   with Pre => I'Length = 16;

   --  LM-OTS checksum of a message hash (RFC 8554 algorithm 2).
   --  @param Q_Hash  32-byte message hash.
   --  @return The 16-bit checksum, left-shifted by ls.
   function OTS_Checksum (Q_Hash : N_String) return Natural;

   --  LM-OTS public key from private key elements (RFC 8554
   --  algorithm 1): complete every chain, then hash the row.
   --  @param I  16-byte tree identifier.
   --  @param Q  Leaf number.
   --  @param X  Private key elements.
   --  @return The OTS public key K.
   function Compute_OTS_Public (I : Byte_Array; Q : Natural; X : OTS_Private_Key) return N_String
   with Pre => I'Length = 16 and then Q <= 2**31 - 1;

   --  LMS leaf hash T (2^h + q) = H (... || D_LEAF || OTS_K)
   --  (RFC 8554 section 5.3).
   --  @param I      16-byte tree identifier.
   --  @param Q      Leaf number.
   --  @param OTS_K  OTS public key for that leaf.
   --  @return The leaf node value.
   function Leaf_Hash (I : Byte_Array; Q : Natural; OTS_K : N_String) return N_String
   with Pre => I'Length = 16 and then Q < 2**H;

   --  LMS internal node hash
   --  T (r) = H (... || D_INTR || T (2r) || T (2r+1)) (RFC 8554 section 5.3).
   --  @param I         16-byte tree identifier.
   --  @param Node_Num  Internal node number (1 .. 2^h - 1).
   --  @param Left      Left child value.
   --  @param Right     Right child value.
   --  @return The internal node value.
   function Node_Hash (I : Byte_Array; Node_Num : Natural; Left : N_String; Right : N_String) return N_String
   with Pre => I'Length = 16 and then Node_Num in 1 .. 2**H - 1;

   --  Verify an LM-OTS one-time signature against the expected OTS
   --  public key (RFC 8554 algorithm 4a).
   --  @param Pub_Type    Expected LM-OTS typecode.
   --  @param I           16-byte tree identifier.
   --  @param Q           Leaf number.
   --  @param Message     Signed message bytes.
   --  @param Sig         LM-OTS signature.
   --  @param Expected_K  Expected OTS public key K for this leaf.
   --  @return True when the signature completes to Expected_K.
   function Verify_OTS (Pub_Type : Natural; I : Byte_Array; Q : Natural; Message : Byte_Array; Sig : OTS_Signature; Expected_K : N_String) return Boolean
   with Pre => I'Length = 16 and then Q <= 2**31 - 1;

   --  Verify an LMS signature over a message with a public key
   --  (RFC 8554 algorithms 4b + 6).
   --  @param Pub      LMS public key.
   --  @param Message  Signed message bytes.
   --  @param Sig      LMS signature.
   --  @return True when the signature is valid for this key.
   function Verify (Pub : Public_Key; Message : Byte_Array; Sig : LMS_Signature) return Boolean;

end CRDT.Security.LMS;
