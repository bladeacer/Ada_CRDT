with Ada.Calendar;
with Ada_CRDT.Core;

package Ada_CRDT.HLC is

   -- Hybrid Logical Clock implementation.
   -- Combines physical wall-clock time with a logical counter
   -- to ensure causality is preserved even when physical clocks drift.
   --
   -- Usage:
   --    Clock : HLC.Instance := HLC.Create (Node_Id => 1);
   --    HLC.Tick (Clock);             -- before sending a message
   --    HLC.Recv (Clock, Remote);     -- upon receiving a remote timestamp
   --    TS : constant HLC_Time := HLC.Now (Clock);

   type HLC_Time is new Core.HLC_Time;

   type Instance is private;

   -- Create a new HLC for the given replica
   function Create (Node : Core.Replica_Id) return Instance;

   -- Tick the local clock (call before sending)
   procedure Tick (Clock : in out Instance);

   -- Merge with a received remote timestamp (call upon receiving)
   procedure Recv (Clock : in out Instance; Remote : HLC_Time);

   -- Get current HLC timestamp
   function Now (Clock : Instance) return HLC_Time;

   -- Ordering
   function "<" (Left, Right : HLC_Time) return Boolean;
   function "=" (Left, Right : HLC_Time) return Boolean;
   function ">" (Left, Right : HLC_Time) return Boolean;

private

   type Instance is record
      Wall : Ada.Calendar.Time;
      Node : Core.Replica_Id;
      Log  : Natural := 0;
   end record;

   function Now (Clock : Instance) return HLC_Time is
     (HLC_Time'(Wall => Clock.Wall,
                Node => Clock.Node,
                Log  => Clock.Log));

end Ada_CRDT.HLC;
