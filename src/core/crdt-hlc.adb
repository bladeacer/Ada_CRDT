with Ada.Calendar;

package body CRDT.HLC
  with SPARK_Mode => On
is

   use Ada.Calendar;
   use type Core.Replica_Id;

   --  Wall-clock access: Ada.Calendar.Clock is not SPARK-analyzable, so
   --  the read is isolated in an opaque-body helper (spec in SPARK, body
   --  SPARK_Mode => Off). The remaining HLC logic (ordering comparisons
   --  and logical-component updates) is in SPARK_Mode => On and proved.
   function Current_Time return Ada.Calendar.Time;

   ---------------
   --  Ordering --
   ---------------

   function "<" (Left, Right : HLC_Time) return Boolean is
   begin
      if Left.Wall < Right.Wall then
         return True;
      elsif Left.Wall > Right.Wall then
         return False;
      elsif Left.Log < Right.Log then
         return True;
      elsif Left.Log > Right.Log then
         return False;
      else
         return Left.Node < Right.Node;
      end if;
   end "<";

   function "=" (Left, Right : HLC_Time) return Boolean is
   begin
      return Left.Wall = Right.Wall and then Left.Log = Right.Log and then Left.Node = Right.Node;
   end "=";

   function ">" (Left, Right : HLC_Time) return Boolean is
   begin
      return not (Left < Right or else Left = Right);
   end ">";

   ---------------
   --  Create   --
   ---------------

   function Create (Node : Core.Replica_Id) return Instance is
   begin
      return Instance'(Wall => Current_Time, Node => Node, Log => 0);
   end Create;

   ---------------
   --  Tick     --
   ---------------

   procedure Tick (Clock : in out Instance) is
      Now_Time : constant Ada.Calendar.Time := Current_Time;
   begin
      if Now_Time > Clock.Wall then
         Clock.Wall := Now_Time;
         Clock.Log := 0;
      else
         Clock.Log := (if Clock.Log = Natural'Last then Natural'Last else Clock.Log + 1);
      end if;
   end Tick;

   ---------------
   --  Recv     --
   ---------------

   procedure Recv (Clock : in out Instance; Remote : HLC_Time) is
      Now_Time : constant Ada.Calendar.Time := Current_Time;
   begin
      if Now_Time > Clock.Wall and then Now_Time > Remote.Wall then
         Clock.Wall := Now_Time;
         Clock.Log := 0;
      elsif Clock.Wall > Remote.Wall then
         Clock.Log := (if Clock.Log = Natural'Last then Natural'Last else Clock.Log + 1);
      elsif Remote.Wall > Clock.Wall then
         Clock.Wall := Remote.Wall;
         Clock.Log := (if Remote.Log = Natural'Last then Natural'Last else Remote.Log + 1);
      else
         --  Equal wall times
         Clock.Log := (if Natural'Max (Clock.Log, Remote.Log) = Natural'Last then Natural'Last else Natural'Max (Clock.Log, Remote.Log) + 1);
      end if;
   end Recv;

   --------------
   --  Opaque  --
   --------------

   function Current_Time return Ada.Calendar.Time with SPARK_Mode => Off is
   begin
      return Ada.Calendar.Clock;
   end Current_Time;

end CRDT.HLC;
