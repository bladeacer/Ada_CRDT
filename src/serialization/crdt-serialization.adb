with Ada.Exceptions;
with Ada.IO_Exceptions;
with Ada.Streams;
with CRDT.Core;
with CRDT.Core.LEB128;

package body CRDT.Serialization is

   use Ada.Streams;

   --  Decode a LEB128 Natural given a starter byte, reading
   --  continuation bytes from the stream as needed.
   procedure Decode_LEB128_From
     (Stream : not null access Root_Stream_Type'Class;
      B0     : Stream_Element;
      Value  : out Natural)
   is
      V     : Natural := 0;
      Shift : Natural := 0;
      B     : Stream_Element := B0;
   begin
      loop
         V := V + Natural (B and 127) * (2 ** Shift);
         Shift := Shift + 7;
         exit when (B and 128) = 0;
         Stream_Element'Read (Stream, B);
      end loop;
      Value := V;
   end Decode_LEB128_From;

   --  Decode a LEB128 Natural from the stream (no starter byte).
   procedure Decode_LEB128_Stream
     (Stream : not null access Root_Stream_Type'Class;
      Value  : out Natural) is
      B : Stream_Element;
   begin
      Stream_Element'Read (Stream, B);
      Decode_LEB128_From (Stream, B, Value);
   end Decode_LEB128_Stream;

   --  Try to read one byte; return False on End_Error.
   function Try_Read (Stream : not null access Root_Stream_Type'Class;
                      B      : out Stream_Element) return Boolean is
   begin
      Stream_Element'Read (Stream, B);
      return True;
   exception
      when Ada.IO_Exceptions.End_Error =>
         return False;
   end Try_Read;

   -----------------
   --  Read_Header --
   -----------------

   procedure Read_Header
     (Stream    : not null access Ada.Streams.Root_Stream_Type'Class;
      Kind      : out Protocol_Kind;
      Total     : out Natural;
      Count     : out Natural;
      Clock_Kind : out CRDT.Clocks.Clock_Kind)
   is
      B1, B2, B3, B4 : Stream_Element;
      CK             : Stream_Element;
   begin
      --  First byte: protocol version.
      if not Try_Read (Stream, B1) then
         raise Ada.IO_Exceptions.End_Error;
      end if;

      if B1 = 3 then
         --  V3: protocol version 3, clock kind byte, then LEB128 Total/Count.
         Kind := Proto_V3;
         if not Try_Read (Stream, CK) then
            raise Constraint_Error with
              "Serialization.Read_Header: V3 header missing clock kind";
         end if;
         case CK is
            when 1 =>
               Clock_Kind := CRDT.Clocks.Clock_Lamport;
            when 2 =>
               Clock_Kind := CRDT.Clocks.Clock_Vector;
            when 3 =>
               Clock_Kind := CRDT.Clocks.Clock_Matrix;
            when others =>
               raise Constraint_Error with
                 "Serialization.Read_Header: unknown clock kind: "
                 & Natural'Image (Natural (CK));
         end case;
         Decode_LEB128_Stream (Stream, Total);
         Decode_LEB128_Stream (Stream, Count);
         return;
      end if;

      if B1 /= 2 then
         raise Constraint_Error with
           "Serialization.Read_Header: unsupported protocol version";
      end if;

      --  V2: backwards compatible, default to Lamport clock.
      Clock_Kind := CRDT.Clocks.Clock_Lamport;

      if not Try_Read (Stream, B2) then
         Kind := Proto_V2;
         Total := 0;
         Count := 0;
         return;
      end if;

      if B2 /= 0 then
         Kind := Proto_V2;
         Decode_LEB128_From (Stream, B2, Total);
         Decode_LEB128_Stream (Stream, Count);
         return;
      end if;

      if not Try_Read (Stream, B3) then
         Kind := Proto_V2;
         Total := 0;
         Count := 0;
         return;
      end if;

      if B3 /= 0 then
         Kind := Proto_V2;
         Total := 0;
         Decode_LEB128_From (Stream, B3, Count);
         return;
      end if;

      if not Try_Read (Stream, B4) then
         Kind := Proto_V2;
         Total := 0;
         Count := 0;
         return;
      end if;

      if B4 = 0 then
         Kind := Proto_V1;
         Natural'Read (Stream, Total);
         Natural'Read (Stream, Count);
      else
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
         when Proto_V2 | Proto_V3 =>
            Core.LEB128.Decode (Stream, Value);
      end case;
   end Read_Natural;

   --------------------
   -- Write_Header_V3 --
   --------------------

   procedure Write_Header_V3
     (Stream   : not null access Ada.Streams.Root_Stream_Type'Class;
      Total    : Natural;
      Count    : Natural;
      Clk_Kind : CRDT.Clocks.Clock_Kind)
   is
      CK_Byte : Stream_Element;
   begin
      case Clk_Kind is
         when CRDT.Clocks.Clock_Lamport =>
            CK_Byte := 1;
         when CRDT.Clocks.Clock_Vector =>
            CK_Byte := 2;
         when CRDT.Clocks.Clock_Matrix =>
            CK_Byte := 3;
      end case;
      Core.LEB128.Encode (Stream, 3);
      Stream_Element'Write (Stream, CK_Byte);
      Core.LEB128.Encode (Stream, Total);
      Core.LEB128.Encode (Stream, Count);
   end Write_Header_V3;

   -------------------------
   -- Migrate_Header_To_V3 --
   -------------------------

   procedure Migrate_Header_To_V3
     (Source     : not null access Ada.Streams.Root_Stream_Type'Class;
      Dest       : not null access Ada.Streams.Root_Stream_Type'Class;
      Kind       : out Protocol_Kind;
      Total      : out Natural;
      Count      : out Natural;
      Clock_Kind : out CRDT.Clocks.Clock_Kind)
   is
   begin
      Read_Header (Source, Kind, Total, Count, Clock_Kind);
      Write_Header_V3 (Dest, Total, Count, Clock_Kind);
   end Migrate_Header_To_V3;

   --------------------
   --  Migrate_Header --
   --------------------

   procedure Migrate_Header
     (Source : not null access Ada.Streams.Root_Stream_Type'Class;
      Dest   : not null access Ada.Streams.Root_Stream_Type'Class;
      Kind   : out Protocol_Kind;
      Total  : out Natural;
      Count  : out Natural)
   is
      Ignore_Clock : CRDT.Clocks.Clock_Kind;
   begin
      Read_Header (Source, Kind, Total, Count, Ignore_Clock);
      --  Migration always writes V2 output for maximum backwards compat.
      Core.LEB128.Encode (Dest, 2);
      Core.LEB128.Encode (Dest, Total);
      Core.LEB128.Encode (Dest, Count);
   end Migrate_Header;

end CRDT.Serialization;
