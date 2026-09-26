--  SHA-256 hash (FIPS 180-4), pure SPARK buffer interface.
--  One-shot and streaming (Init/Update/Final) forms.  No heap use.
--
--  Used by the post-quantum verification layer (CRDT.Security.*) as the
--  hash function H for LM-OTS/LMS (RFC 8554) and as the HMAC-SHA-256
--  compression core (RFC 2104).
--
--  Requirements traceability:
--  - HLR-SEC-SHA256: SHA-256 hash for integrity and signatures

with Ada.Streams;

package CRDT.Security.SHA256
  with SPARK_Mode
is

   --  SHA-256 output length in bytes.
   Hash_Length : constant := 32;

   --  SHA-256 block size in bytes (the HMAC pad length).
   Block_Length : constant := 64;

   subtype Byte is Ada.Streams.Stream_Element;

   subtype Byte_Array is Ada.Streams.Stream_Element_Array;

   --  32-byte SHA-256 digest.
   subtype Hash is Byte_Array (1 .. Hash_Length);

   --  Streaming state.  Internal block buffering included.
   type Context is private;

   --  Default (initial) chaining value of the context.
   function Initial_Context return Context;

   --  Initialise the streaming context.
   --  @param Ctx  Context to initialise.
   procedure Init (Ctx : out Context)
   with Post => Ctx = Initial_Context;

   --  Feed bytes into the streaming context.
   --  @param Ctx    Context to update.
   --  @param Bytes  Input bytes.
   procedure Update (Ctx : in out Context; Bytes : Byte_Array)
   with Depends => (Ctx =>+ Bytes);

   --  Finish the stream and write the 32-byte digest.
   --  @param Ctx    Context to finish.
   --  @param Out_D  32-byte digest.
   procedure Final (Ctx : in out Context; Out_D : out Hash);

   --  One-shot SHA-256 over a message.
   --  @param Bytes  Input bytes.
   --  @param Out_D  32-byte digest.
   procedure Digest (Bytes : Byte_Array; Out_D : out Hash);

private

   type Word32 is mod 2**32;

   type Word_Array_8 is array (1 .. 8) of Word32;

   type Byte_Array_64 is array (1 .. Block_Length) of Byte;

   type Context is record
      H    : Word_Array_8 := (16#6A09E667#, 16#BB67AE85#, 16#3C6EF372#,
                              16#A54FF53A#, 16#510E527F#, 16#9B05688C#,
                              16#1F83D9AB#, 16#5BE0CD19#);
      Len  : Long_Long_Integer := 0;
      Buf  : Byte_Array_64 := (others => 0);
      BufN : Natural := 0;
   end record;

end CRDT.Security.SHA256;
