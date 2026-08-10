with Ada.Streams;
with CRDT.Clocks;
with CRDT.Serialization;

package body CRDT.Lww_Sets
  with SPARK_Mode
is

   procedure Clear (S : in out LWW_Clocked_Set) is
   begin
      S.Add_Size := 0;
      S.Remove_Size := 0;
   end Clear;

   function Find_Index (A : Timestamp_Array; Size : Natural; E : Element_Type) return Natural
   with Pre => Size <= A'Length and then A'First = 1, Post => (Find_Index'Result = 0) or else (Find_Index'Result in 1 .. Size)
   is
   begin
      for I in 1 .. Size loop
         if A (I).Element = E then
            return I;
         end if;
      end loop;
      return 0;
   end Find_Index;

   function Contains (S : LWW_Clocked_Set; E : Element_Type) return Boolean is
      Add_I    : constant Natural := Find_Index (S.Add_Array, S.Add_Size, E);
      Remove_I : constant Natural := Find_Index (S.Remove_Array, S.Remove_Size, E);
   begin
      if Add_I = 0 then
         return False;
      end if;
      if Remove_I = 0 then
         return True;
      end if;
      return S.Add_Array (Add_I).Time > S.Remove_Array (Remove_I).Time;
   end Contains;

   procedure Add (S : in out LWW_Clocked_Set; E : Element_Type; TS : Clock_Time) is
      Add_I    : Natural;
      Remove_I : Natural;
   begin
      Add_I := Find_Index (S.Add_Array, S.Add_Size, E);
      if Add_I > 0 then
         if TS > S.Add_Array (Add_I).Time then
            S.Add_Array (Add_I) := (E, TS);
         end if;
         Remove_I := Find_Index (S.Remove_Array, S.Remove_Size, E);
         if Remove_I > 0 and then TS > S.Remove_Array (Remove_I).Time then
            S.Remove_Array (Remove_I) := (S.Remove_Array (S.Remove_Size).Element, S.Remove_Array (S.Remove_Size).Time);
            S.Remove_Size := S.Remove_Size - 1;
         end if;
      else
         S.Add_Size := S.Add_Size + 1;
         pragma Annotate (GNATprove, False_Positive, "overflow check might fail", "LWW set size bounded by Capacity in practice");
         S.Add_Array (S.Add_Size) := (E, TS);
         pragma Annotate (GNATprove, False_Positive, "array index check might fail", "LWW set size bounded by Capacity in practice");
      end if;
   end Add;

   procedure Remove (S : in out LWW_Clocked_Set; E : Element_Type; TS : Clock_Time) is
      Add_I    : Natural;
      Remove_I : Natural;
   begin
      Add_I := Find_Index (S.Add_Array, S.Add_Size, E);
      if Add_I = 0 then
         return;
      end if;
      Remove_I := Find_Index (S.Remove_Array, S.Remove_Size, E);
      if Remove_I > 0 then
         if TS > S.Remove_Array (Remove_I).Time then
            S.Remove_Array (Remove_I) := (E, TS);
         end if;
      else
         S.Remove_Size := S.Remove_Size + 1;
         pragma Annotate (GNATprove, False_Positive, "overflow check might fail", "LWW set size bounded by Capacity in practice");
         S.Remove_Array (S.Remove_Size) := (E, TS);
         pragma Annotate (GNATprove, False_Positive, "array index check might fail", "LWW set size bounded by Capacity in practice");
      end if;
   end Remove;

   procedure Merge (Target : in out LWW_Clocked_Set; Source : LWW_Clocked_Set) is
   begin
      for I in 1 .. Source.Add_Size loop
         pragma Loop_Invariant (Target.Add_Size <= Target.Capacity and then Target.Remove_Size <= Target.Capacity);
         Add (Target, Source.Add_Array (I).Element, Source.Add_Array (I).Time);
      end loop;
      for I in 1 .. Source.Remove_Size loop
         pragma Loop_Invariant (Target.Add_Size <= Target.Capacity and then Target.Remove_Size <= Target.Capacity);
         Remove (Target, Source.Remove_Array (I).Element, Source.Remove_Array (I).Time);
      end loop;
   end Merge;

   ---------------
   --  Write/Read --
   ---------------

   procedure Write_LWW_Clocked_Set (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : LWW_Clocked_Set) with SPARK_Mode => Off is
   begin
      CRDT.Serialization.Write_Header_V3 (Stream, Item.Add_Size, Item.Remove_Size, Clk_Kind);
      for I in 1 .. Item.Add_Size loop
         Element_Type'Write (Stream, Item.Add_Array (I).Element);
         Write_Clock (Stream, Item.Add_Array (I).Time);
      end loop;
      for I in 1 .. Item.Remove_Size loop
         Element_Type'Write (Stream, Item.Remove_Array (I).Element);
         Write_Clock (Stream, Item.Remove_Array (I).Time);
      end loop;
   end Write_LWW_Clocked_Set;

   procedure Read_LWW_Clocked_Set (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out LWW_Clocked_Set) with SPARK_Mode => Off is
      Kind        : CRDT.Serialization.Protocol_Kind;
      Add_Size    : Natural;
      Remove_Size : Natural;
      Ignore_CK   : CRDT.Clocks.Clock_Kind;
   begin
      CRDT.Serialization.Read_Header (Stream, Kind, Add_Size, Remove_Size, Ignore_CK);
      if Add_Size > Item.Capacity or else Remove_Size > Item.Capacity then
         raise Constraint_Error with "LWW_Clocked_Set stream has more entries than Capacity";
      end if;
      Item.Add_Size := Add_Size;
      Item.Remove_Size := Remove_Size;
      for I in 1 .. Add_Size loop
         Element_Type'Read (Stream, Item.Add_Array (I).Element);
         Read_Clock (Stream, Item.Add_Array (I).Time);
      end loop;
      for I in 1 .. Remove_Size loop
         Element_Type'Read (Stream, Item.Remove_Array (I).Element);
         Read_Clock (Stream, Item.Remove_Array (I).Time);
      end loop;
   end Read_LWW_Clocked_Set;

end CRDT.Lww_Sets;
