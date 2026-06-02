package Ardt.Core is

   type Replica_Id is new Positive;

   type Timestamp is new Natural;

   type VTime is array (Positive range <>) of Timestamp with
    Default_Component_Value => 0;

   function VTime_Less (Left, Right : VTime) return Boolean;
   function VTime_Leq  (Left, Right : VTime) return Boolean;
   function VTime_Eq   (Left, Right : VTime) return Boolean;

   procedure VTime_Merge (Target : in out VTime; Source : VTime);
   procedure VTime_Increment (VT : in out VTime; Idx : Positive);

   function New_Replica_Id return Replica_Id;

private

   type Id_Storage is array (1 .. 1) of Boolean;

   Generator_Init : Boolean := False;

end Ardt.Core;
