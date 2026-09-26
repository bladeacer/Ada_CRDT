--  HMAC-SHA-256 message authentication (RFC 2104).
--  Constant-time tag comparison.  No heap use.
--
--  HMAC authenticates replica state and sync payloads between peers
--  that share a symmetric key (psk-style deployment).  It authenticates
--  but does not prove origin to third parties; use the LMS package for
--  non-repudiable signatures.
--
--  Requirements traceability:
--  - HLR-SEC-HMAC: HMAC-SHA-256 tag computation and comparison

with Ada.Streams;
with CRDT.Security.SHA256;

package CRDT.Security.HMAC
  with SPARK_Mode
is

   --  HMAC tag length in bytes (full SHA-256 output).
   Tag_Length : constant := 32;

   subtype Byte is Ada.Streams.Stream_Element;

   subtype Byte_Array is Ada.Streams.Stream_Element_Array;

   subtype Tag is Byte_Array (1 .. Tag_Length);

   --  Compute the HMAC-SHA-256 tag of a message.
   --  @param Key      Symmetric key (any length; longer than the block
   --                  size is hashed first per RFC 2104).
   --  @param Message  Bytes to authenticate.
   --  @param Out_Tag  32-byte authentication tag.
   procedure Compute
     (Key     : Byte_Array;
      Message : Byte_Array;
      Out_Tag : out Tag)
   with Pre => Key'Length > 0;

   --  Constant-time tag comparison.
   --  Runs in time dependent only on Tag_Length, not on where the
   --  first difference is, so it does not leak the tag through timing.
   --  @param Left   Computed tag.
   --  @param Right  Expected tag.
   --  @return True when both tags are identical.
   function Equal (Left, Right : Tag) return Boolean
   with Post => Equal'Result = (for all I in Tag'Range => Left (I) = Right (I));

end CRDT.Security.HMAC;
