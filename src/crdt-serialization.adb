with Ada.Exceptions;
with Ada.IO_Exceptions;
with Ada.Streams;
with CRDT.Core;
with CRDT.Core.LEB128;

package body CRDT.Serialization is

   use Ada.Streams;

   --  Read a single stream element from the underlying stream.
   procedure Read_B (Stream : not null access Root_Stream_Type'Class;
                     B      : out Stream_Element) is
   begin
      Stream_Element'Read (Stream, B);
   end Read_B;

   --  Decode one LEB128 Natural from a buffer of already-read bytes
   --  followed by stream reads.  Advances Idx past consumed bytes.
   procedure Decode_LEB128
     (Buf      : Stream_Element_Array;
      Idx      : in out Natural;
      Stream   : not null access Root_Stream_Type'Class;
      Value    : out Natural)
   is
      V        : Natural := 0;
      Shift    : Natural := 0;
      Byte_Val : Stream_Element;
   begin
      loop
         if Idx <= Buf'Last then
            Byte_Val := Buf (Idx);
            Idx := Idx + 1;
         else
            Stream_Element'Read (Stream, Byte_Val);
         end if;
         V := V + Natural (Byte_Val and 127) * (2 ** Shift);
         Shift := Shift + 7;
         exit when (Byte_Val and 128) = 0;
      end loop;
      Value := V;
   end Decode_LEB128;

   -----------------
   --  Read_Header --
   -----------------

   procedure Read_Header
     (Stream   : not null access Ada.Streams.Root_Stream_Type'Class;
      Kind     : out Protocol_Kind;
      Total    : out Natural;
      Count    : out Natural)
   is
      B1, B2, B3, B4 : Stream_Element;
      Buf  : Stream_Element_Array (1 .. 3);
      Idx  : Natural;
   begin
      --  First byte: protocol version.
      --  Both V1 (Natural'Write of 2) and V2 (LEB128 of 2) begin with byte 2.
      Read_B (Stream, B1);
      if B1 /= 2 then
         raise Constraint_Error with
           "Serialization.Read_Header: unsupported protocol version";
      end if;

      Read_B (Stream, B2);

      --  V2 Total can never be zero in V1's Natural'Write padding.
      --  If B2 /= 0 it is definitely V2.
      if B2 /= 0 then
         Kind := Proto_V2;
         Buf (1) := B2;
         Idx := 1;
         Decode_LEB128 (Buf, Idx, Stream, Total);
         Decode_LEB128 (Buf, Idx, Stream, Count);
         return;
      end if;

      --  B2 = 0: could be V1 padding or V2 with Total = 0.
      Read_B (Stream, B3);

      if B3 /= 0 then
         --  V2: Total = 0 (from B2), Count starts at B3
         Kind := Proto_V2;
         Total := 0;
         Buf (1) := B3;
         Idx := 1;
         Decode_LEB128 (Buf, Idx, Stream, Count);
         return;
      end if;

      --  B2 = 0, B3 = 0: V1 version padding or V2 with Total = 0, Count = 0.
      Read_B (Stream, B4);

      if B4 = 0 then
         --  V1: version is 4-byte Natural'Write [02, 00, 00, 00].
         --  Total and Count follow as fixed 4-byte fields.
         Kind := Proto_V1;
         Natural'Read (Stream, Total);
         Natural'Read (Stream, Count);
      else
         --  V2: Total = 0, Count = 0.
         --  B4 is the first byte of the first item, consumed from the stream.
         --  For an empty RGA (Total=0, Count=0) there are no items, so B4
         --  should not exist in a well-formed payload.  Discard it.
         Kind := Proto_V2;
         Total := 0;
         Count := 0;
      end if;
   end Read_Header;

   ------------------
   --  Read_Natural --
   ------------------

   procedure Read_Natural
     (Kind   : Protocol_Kind;
      Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Value  : out Natural)
   is
   begin
      case Kind is
         when Proto_V1 =>
            Natural'Read (Stream, Value);
         when Proto_V2 =>
            Core.LEB128.Decode (Stream, Value);
      end case;
   end Read_Natural;

end CRDT.Serialization;
