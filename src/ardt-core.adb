with Ada.Numerics.Discrete_Random;

package body Ardt.Core is

   package Replica_Random is new Ada.Numerics.Discrete_Random (Replica_Id);
   use Replica_Random;

   Gen : Replica_Random.Generator;

   ---------------
   -- VTime ops --
   ---------------

   function VTime_Less (Left, Right : VTime) return Boolean is
   begin
      if Left'Length /= Right'Length then
         raise Constraint_Error with "VTime dimensions must match";
      end if;
      if VTime_Eq (Left, Right) then
         return False;
      end if;
      for I in Left'Range loop
         if Left (I) > Right (I) then
            return False;
         end if;
      end loop;
      return True;
   end VTime_Less;

   function VTime_Leq (Left, Right : VTime) return Boolean is
   begin
      if Left'Length /= Right'Length then
         raise Constraint_Error with "VTime dimensions must match";
      end if;
      for I in Left'Range loop
         if Left (I) > Right (I) then
            return False;
         end if;
      end loop;
      return True;
   end VTime_Leq;

   function VTime_Eq (Left, Right : VTime) return Boolean is
   begin
      if Left'Length /= Right'Length then
         raise Constraint_Error with "VTime dimensions must match";
      end if;
      for I in Left'Range loop
         if Left (I) /= Right (I) then
            return False;
         end if;
      end loop;
      return True;
   end VTime_Eq;

   procedure VTime_Merge (Target : in out VTime; Source : VTime) is
   begin
      if Target'Length /= Source'Length then
         raise Constraint_Error with "VTime dimensions must match";
      end if;
      for I in Target'Range loop
         if Source (I) > Target (I) then
            Target (I) := Source (I);
         end if;
      end loop;
   end VTime_Merge;

   procedure VTime_Increment (VT : in out VTime; Idx : Positive) is
   begin
      if Idx not in VT'Range then
         raise Constraint_Error with "Index out of VTime range";
      end if;
      VT (Idx) := VT (Idx) + 1;
   end VTime_Increment;

   function New_Replica_Id return Replica_Id is
   begin
      if not Generator_Init then
         Reset (Gen);
         Generator_Init := True;
      end if;
      return Random (Gen);
   end New_Replica_Id;

end Ardt.Core;
