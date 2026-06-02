package body Ardt.Pn_Counters with
  SPARK_Mode
is

   function Value (C : PN_Counter) return Integer is
   begin
      return Integer (C.P) - Integer (C.N);
   end Value;

   procedure Increment (C  : in out PN_Counter;
                        By : Counter_Range := 1) is
   begin
      C.P := C.P + By;
   end Increment;

   procedure Decrement (C  : in out PN_Counter;
                        By : Counter_Range := 1) is
   begin
      C.N := C.N + By;
   end Decrement;

   procedure Merge (Target : in out PN_Counter;
                    Source : PN_Counter) is
   begin
      if Source.P > Target.P then
         Target.P := Source.P;
      end if;
      if Source.N > Target.N then
         Target.N := Source.N;
      end if;
   end Merge;

end Ardt.Pn_Counters;
