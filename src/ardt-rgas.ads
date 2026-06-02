with Ardt.Rga;

generic
   type Element_Type is private;
   Max_RGA_Size  : Positive;
   Max_RGA_Count : Positive;
package Ardt.Rgas with
  SPARK_Mode
is

   package RGA_Pkg is new Ardt.Rga (Element_Type, Max_RGA_Size);

   subtype RGA_Entry is RGA_Pkg.RGA (Max_RGA_Size);

   type RGA_Array is array (Positive range <>) of RGA_Entry;

   type RGAs (Count : Positive) is private;

   function Size (RS : RGAs) return Natural;

   function Get (RS : RGAs; Index : Positive) return RGA_Entry;

   procedure Append (RS : in out RGAs; R : RGA_Entry);

   procedure Merge_All (RS : in out RGAs);

private

   type RGAs (Count : Positive) is record
      A    : RGA_Array (1 .. Count);
      Sz   : Natural := 0;
   end record;

end Ardt.Rgas;
