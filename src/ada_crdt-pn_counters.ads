with Ada_CRDT.Core;

package Ada_CRDT.Pn_Counters with
  SPARK_Mode
is

   subtype Counter_Range is Natural;

   type PN_Counter (Max_Actors : Positive) is private with
     Default_Initial_Condition;

   function Value (C : PN_Counter) return Integer;

   function Can_Increment (C : PN_Counter; By : Counter_Range := 1)
                            return Boolean;

   function Can_Decrement (C : PN_Counter; By : Counter_Range := 1)
                            return Boolean;

   procedure Increment (C     : in out PN_Counter;
                        By    : Counter_Range := 1;
                        Actor : Core.Replica_Id) with
     Pre => Can_Increment (C, By);

   procedure Decrement (C     : in out PN_Counter;
                        By    : Counter_Range := 1;
                        Actor : Core.Replica_Id) with
     Pre => Can_Decrement (C, By);

   procedure Merge (Target : in out PN_Counter;
                    Source : PN_Counter);

private

   type Actor_Entry is record
      Actor : Core.Replica_Id;
      P     : Counter_Range := 0;
      N     : Counter_Range := 0;
   end record;

   type Actor_Array is array (Positive range <>) of Actor_Entry;

   type PN_Counter (Max_Actors : Positive) is record
      Entries : Actor_Array (1 .. Max_Actors);
      Count   : Natural := 0;
   end record;

   function Can_Increment (C : PN_Counter; By : Counter_Range := 1)
                            return Boolean is (True);

   function Can_Decrement (C : PN_Counter; By : Counter_Range := 1)
                            return Boolean is (True);

end Ada_CRDT.Pn_Counters;
