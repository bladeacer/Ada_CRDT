with Ada.Calendar;

package Ada_CRDT.Core is

   type Replica_Id is new Positive;

   -- Lamport timestamp for causal ordering
   type Lamport_Time is record
      Stamp : Natural := 0;
      Node  : Replica_Id := 1;
   end record;

   function "<" (Left, Right : Lamport_Time) return Boolean;
   function "=" (Left, Right : Lamport_Time) return Boolean;
   function ">" (Left, Right : Lamport_Time) return Boolean;
   function Lamport_Max (Left, Right : Lamport_Time) return Lamport_Time;

   -- Hybrid Logical Clock
   type HLC_Time is record
      Wall : Ada.Calendar.Time;
      Node : Replica_Id;
      Log  : Natural := 0;
   end record;

   function HLC_Less (Left, Right : HLC_Time) return Boolean;
   function HLC_Eq   (Left, Right : HLC_Time) return Boolean;
   function HLC_Max  (Left, Right : HLC_Time) return HLC_Time;

   -- Vector clock
   type VTime is array (Positive range <>) of Natural with
     Default_Component_Value => 0;

   function VTime_Less (Left, Right : VTime) return Boolean;
   function VTime_Leq  (Left, Right : VTime) return Boolean;
   function VTime_Eq   (Left, Right : VTime) return Boolean;
   procedure VTime_Merge (Target : in out VTime; Source : VTime);
   procedure VTime_Increment (VT : in out VTime; Idx : Positive);

   function New_Replica_Id return Replica_Id;

   -- Protocol version for wire serialization
   Protocol_Version : constant Natural := 1;

private

   Generator_Init : Boolean := False;

end Ada_CRDT.Core;
