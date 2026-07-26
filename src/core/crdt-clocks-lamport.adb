with Ada.Streams;
with CRDT.Core.LEB128;

package body CRDT.Clocks.Lamport
  with SPARK_Mode
is

   function "<" (Left, Right : Clock_Time) return Boolean is
   begin
      return CRDT.Core."<" (CRDT.Core.Lamport_Time (Left), CRDT.Core.Lamport_Time (Right));
   end "<";

   function "=" (Left, Right : Clock_Time) return Boolean is
   begin
      return CRDT.Core."=" (CRDT.Core.Lamport_Time (Left), CRDT.Core.Lamport_Time (Right));
   end "=";

   function ">" (Left, Right : Clock_Time) return Boolean is
   begin
      return CRDT.Core.">" (CRDT.Core.Lamport_Time (Left), CRDT.Core.Lamport_Time (Right));
   end ">";

   function Max (Left, Right : Clock_Time) return Clock_Time is
   begin
      if Left > Right then
         return Left;
      end if;
      return Right;
   end Max;

   procedure Write_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : Clock_Time) with SPARK_Mode => Off is
   begin
      CRDT.Core.LEB128.Encode (Stream, Item.Stamp);
      CRDT.Core.LEB128.Encode (Stream, Natural (Item.Node));
   end Write_Clock;

   procedure Read_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Clock_Time) with SPARK_Mode => Off is
      Node : Natural;
   begin
      CRDT.Core.LEB128.Decode (Stream, Item.Stamp);
      CRDT.Core.LEB128.Decode (Stream, Node);
      Item.Node := CRDT.Core.Replica_Id (Node);
   end Read_Clock;

end CRDT.Clocks.Lamport;
