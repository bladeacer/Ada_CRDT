package body CRDT.Core.LEB128 with
  SPARK_Mode
is

   use Ada.Streams;

   --------------------
   --  Encode (buffer) --
   --------------------

   procedure Encode
     (Buffer : in out Byte_Array;
      Index  : in out Stream_Element_Offset;
      Value  : Natural)
   is
      V : Natural := Value;
      T : Byte_Array (1 .. Max_LEB128_Bytes) := (others => 0);
      N : Stream_Element_Offset;
   begin
      N := 1;
      for I in 1 .. Max_LEB128_Bytes loop
         if V mod 128 = V then
            T (Stream_Element_Offset (I)) := Stream_Element (V);
            N := Stream_Element_Offset (I);
            exit;
         else
            T (Stream_Element_Offset (I)) := Stream_Element (V mod 128 + 128);
            V := V / 128;
         end if;
         pragma Loop_Invariant (N >= 1 and N <= Stream_Element_Offset (I));
      end loop;
      for J in Stream_Element_Offset range 1 .. N loop
         Buffer (Index + (J - 1)) := T (J);
      end loop;
      declare
         Last_Byte : constant Stream_Element_Offset := Index + (N - 1);
      begin
         if Last_Byte < Stream_Element_Offset'Last then
            Index := Stream_Element_Offset'Succ (Last_Byte);
         else
            Index := Stream_Element_Offset'Last;
         end if;
      end;
   end Encode;

   --------------------
   --  Decode (buffer) --
   --------------------

   procedure Decode
     (Buffer : Byte_Array;
      Index  : in out Stream_Element_Offset;
      Value  : out Natural)
   is
      V  : Long_Long_Integer;
      N  : Stream_Element_Offset;
      B  : Stream_Element;
      V7 : Long_Long_Integer;
   begin
      B := Buffer (Index);
      V7 := Long_Long_Integer (B) mod 128;
      V := V7;
      if B < 128 then
         N := 1;
      else
         B := Buffer (Index + 1);
         V7 := Long_Long_Integer (B) mod 128;
         V := V + V7 * 128;
         if B < 128 then
            N := 2;
         else
            B := Buffer (Index + 2);
            V7 := Long_Long_Integer (B) mod 128;
            V := V + V7 * 16_384;
            if B < 128 then
               N := 3;
            else
               B := Buffer (Index + 3);
               V7 := Long_Long_Integer (B) mod 128;
               V := V + V7 * 2_097_152;
               if B < 128 then
                  N := 4;
               else
                  B := Buffer (Index + 4);
                  V7 := Long_Long_Integer (B) mod 128;
                  V := V + V7 * 268_435_456;
                  N := 5;
               end if;
            end if;
         end if;
      end if;
      declare
         Last_Byte : constant Stream_Element_Offset := Index + (N - 1);
      begin
         if Last_Byte < Stream_Element_Offset'Last then
            Index := Stream_Element_Offset'Succ (Last_Byte);
         else
            Index := Stream_Element_Offset'Last;
         end if;
      end;
      if V <= Long_Long_Integer (Natural'Last) then
         Value := Natural (V);
      else
         Value := Natural'Last;
      end if;
   end Decode;

   --------------------
   --  Encode (stream) --
   --------------------

   procedure Encode
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Value  : Natural)
   with SPARK_Mode => Off
   is
      Buf    : Byte_Array (1 .. Max_LEB128_Bytes);
      Buf_Idx : Stream_Element_Offset := 1;
   begin
      Encode (Buf, Buf_Idx, Value);
      for I in 1 .. Buf_Idx - 1 loop
         Stream_Element'Write (Stream, Buf (I));
      end loop;
   end Encode;

   --------------------
   --  Decode (stream) --
   --------------------

   procedure Decode
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Value  : out Natural)
   with SPARK_Mode => Off
   is
      Buf    : Byte_Array (1 .. Max_LEB128_Bytes);
      Buf_Idx : Stream_Element_Offset := 1;
      B      : Stream_Element;
   begin
      loop
         Stream_Element'Read (Stream, B);
         Buf (Buf_Idx) := B;
         exit when (B and 128) = 0 or Buf_Idx = Max_LEB128_Bytes;
         Buf_Idx := Buf_Idx + 1;
      end loop;
      Buf_Idx := 1;
      Decode (Buf, Buf_Idx, Value);
   end Decode;

end CRDT.Core.LEB128;
