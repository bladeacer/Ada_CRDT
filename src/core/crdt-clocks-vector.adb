with Ada.Streams;
with CRDT.Core.LEB128;

package body CRDT.Clocks.Vector
  with SPARK_Mode
is

   function "<" (Left, Right : Clock_Time) return Boolean is
      Result : constant Boolean := CRDT.Core.VTime_Less (CRDT.Core.VTime (Left), CRDT.Core.VTime (Right));
   begin
      return Result;
   end "<";

   function "=" (Left, Right : Clock_Time) return Boolean is
      Result : constant Boolean := CRDT.Core.VTime_Eq (CRDT.Core.VTime (Left), CRDT.Core.VTime (Right));
   begin
      return Result;
   end "=";

   function ">" (Left, Right : Clock_Time) return Boolean is
   begin
      return not (Left < Right or else Left = Right);
   end ">";

   function Max (Left, Right : Clock_Time) return Clock_Time is
      Result : Clock_Time := Left;
   begin
      CRDT.Core.VTime_Merge (Result, CRDT.Core.VTime (Right));
      return Result;
   end Max;

   procedure Increment (T : in out Clock_Time; Idx : Positive) is
   begin
      CRDT.Core.VTime_Increment (T, Idx);
   end Increment;

   procedure Merge (Target : in out Clock_Time; Source : Clock_Time) is
   begin
      CRDT.Core.VTime_Merge (Target, CRDT.Core.VTime (Source));
   end Merge;

   procedure Write_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : Clock_Time) with SPARK_Mode => Off is
   begin
      for I in Clock_Time'Range loop
         CRDT.Core.LEB128.Encode (Stream, Item (I));
      end loop;
   end Write_Clock;

   procedure Read_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Clock_Time) with SPARK_Mode => Off is
   begin
      for I in Clock_Time'Range loop
         CRDT.Core.LEB128.Decode (Stream, Item (I));
      end loop;
   end Read_Clock;

end CRDT.Clocks.Vector;
