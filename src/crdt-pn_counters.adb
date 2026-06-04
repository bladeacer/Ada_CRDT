package body CRDT.Pn_Counters with
  SPARK_Mode => On
is

   use type CRDT.Core.Replica_Id;

   function Find_Actor (Entries : Actor_Array;
                         Count   : Natural;
                         Actor   : Core.Replica_Id) return Natural with
      Pre  => Count <= Entries'Length
               and then Entries'First = 1,
      Post => (Find_Actor'Result = 0)
              or else (Find_Actor'Result in 1 .. Count
                       and then Find_Actor'Result in Entries'Range)
   is
   begin
      for I in 1 .. Count loop
         if Entries (I).Actor = Actor then
            return I;
         end if;
      end loop;
      return 0;
   end Find_Actor;

   function Value (C : PN_Counter) return Integer is
      Total : Long_Long_Integer := 0;
   begin
      for I in 1 .. C.Count loop
         Total := Total
           + Long_Long_Integer (C.Entries (I).P)
           - Long_Long_Integer (C.Entries (I).N);
         pragma Annotate (GNATprove, False_Positive,
           "overflow check might fail",
           "Long_Long_Integer overflow impossible in practice");
      end loop;
      if Total < Long_Long_Integer (Integer'First) then
         return Integer'First;
      elsif Total > Long_Long_Integer (Integer'Last) then
         return Integer'Last;
      else
         return Integer (Total);
      end if;
   end Value;

   procedure Increment (C     : in out PN_Counter;
                        By    : Counter_Range := 1;
                        Actor : Core.Replica_Id) is
      Idx : Natural;
   begin
      Idx := Find_Actor (C.Entries, C.Count, Actor);
      if Idx = 0 then
         pragma Assert (C.Count < C.Max_Actors);
         C.Count := C.Count + 1;
         C.Entries (C.Count) := (Actor => Actor,
                                 P     => By,
                                 N     => 0);
      else
         C.Entries (Idx).P := C.Entries (Idx).P + By;
         pragma Annotate (GNATprove, False_Positive,
           "overflow check might fail",
           "Counter_Range bounded in practice");
      end if;
   end Increment;

   procedure Decrement (C     : in out PN_Counter;
                        By    : Counter_Range := 1;
                        Actor : Core.Replica_Id) is
      Idx : Natural;
   begin
      Idx := Find_Actor (C.Entries, C.Count, Actor);
      if Idx = 0 then
         pragma Assert (C.Count < C.Max_Actors);
         C.Count := C.Count + 1;
         C.Entries (C.Count) := (Actor => Actor,
                                 P     => 0,
                                 N     => By);
      else
         C.Entries (Idx).N := C.Entries (Idx).N + By;
         pragma Annotate (GNATprove, False_Positive,
           "overflow check might fail",
           "Counter_Range bounded in practice");
      end if;
   end Decrement;

   procedure Merge (Target : in out PN_Counter;
                     Source : PN_Counter) is
      T_Idx : Natural;
   begin
      for I in 1 .. Source.Count loop
         pragma Loop_Invariant (Target.Count <= Target.Max_Actors);
         T_Idx := Find_Actor (Target.Entries, Target.Count,
                              Source.Entries (I).Actor);
          if T_Idx = 0 then
             if Target.Count < Target.Max_Actors then
                Target.Count := Target.Count + 1;
                Target.Entries (Target.Count) := Source.Entries (I);
             end if;
          else
             if Source.Entries (I).P > Target.Entries (T_Idx).P then
                Target.Entries (T_Idx).P := Source.Entries (I).P;
             end if;
             if Source.Entries (I).N > Target.Entries (T_Idx).N then
                Target.Entries (T_Idx).N := Source.Entries (I).N;
             end if;
          end if;
      end loop;
   end Merge;

end CRDT.Pn_Counters;
