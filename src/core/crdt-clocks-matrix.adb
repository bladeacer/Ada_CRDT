with Ada.Streams;
with CRDT.Core.LEB128;

package body CRDT.Clocks.Matrix with
  SPARK_Mode
is

   function "<" (Left, Right : Clock_Time) return Boolean is
   begin
      if Left = Right then
         return False;
      end if;
      for R in Clock_Time'Range (1) loop
         for C in Clock_Time'Range (2) loop
            if Left (R, C) > Right (R, C) then
               return False;
            end if;
         end loop;
      end loop;
      return True;
   end "<";

   function "=" (Left, Right : Clock_Time) return Boolean is
   begin
      for R in Clock_Time'Range (1) loop
         for C in Clock_Time'Range (2) loop
            if Left (R, C) /= Right (R, C) then
               return False;
            end if;
         end loop;
      end loop;
      return True;
   end "=";

   function ">" (Left, Right : Clock_Time) return Boolean is
   begin
      return not (Left < Right or else Left = Right);
   end ">";

   function Max (Left, Right : Clock_Time) return Clock_Time is
      Result : Clock_Time := Left;
   begin
      for R in Clock_Time'Range (1) loop
         for C in Clock_Time'Range (2) loop
            if Right (R, C) > Result (R, C) then
               Result (R, C) := Right (R, C);
            end if;
         end loop;
      end loop;
      return Result;
   end Max;

   procedure Increment (T    : in out Clock_Time;
                        Row  : Positive;
                        Col  : Positive) is
   begin
      T (Row, Col) := T (Row, Col) + 1;
   end Increment;

   procedure Merge (Target : in out Clock_Time; Source : Clock_Time) is
   begin
      for R in Clock_Time'Range (1) loop
         for C in Clock_Time'Range (2) loop
            if Source (R, C) > Target (R, C) then
               Target (R, C) := Source (R, C);
            end if;
         end loop;
      end loop;
   end Merge;

   procedure Write_Clock
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Clock_Time) with SPARK_Mode => Off
   is
   begin
      for R in Clock_Time'Range (1) loop
         for C in Clock_Time'Range (2) loop
            CRDT.Core.LEB128.Encode (Stream, Item (R, C));
         end loop;
      end loop;
   end Write_Clock;

   procedure Read_Clock
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Clock_Time) with SPARK_Mode => Off
   is
   begin
      for R in Clock_Time'Range (1) loop
         for C in Clock_Time'Range (2) loop
            CRDT.Core.LEB128.Decode (Stream, Item (R, C));
         end loop;
      end loop;
   end Read_Clock;

end CRDT.Clocks.Matrix;
