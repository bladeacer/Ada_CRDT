package body Ada_CRDT.Rgas with
  SPARK_Mode
is

   function Size (RS : RGAs) return Natural is
   begin
      return RS.Sz;
   end Size;

   function Get (RS : RGAs; Index : Positive) return RGA_Entry is
   begin
      return RS.A (Index);
   end Get;

   procedure Append (RS : in out RGAs; R : RGA_Entry) is
   begin
      RS.Sz := RS.Sz + 1;
      RS.A (RS.Sz) := R;
   end Append;

   procedure Merge_All (RS : in out RGAs) is
   begin
      if RS.Sz <= 1 then
         return;
      end if;
      for I in 2 .. RS.Sz loop
         RGA_Pkg.Merge (RS.A (1), RS.A (I));
         pragma Loop_Invariant (I <= RS.Sz + 1);
      end loop;
   end Merge_All;

end Ada_CRDT.Rgas;
