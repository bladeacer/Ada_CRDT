with Ada.Text_IO;
with Ardt.Pn_Counters;
with Ardt.Lww_Element_Sets;
with Ardt.Rga;
with Ardt.Rgas;

procedure Test_Crdt is

   use Ada.Text_IO;

   -----------------------
   --  PN-Counter Tests --
   -----------------------
   procedure Test_PN_Counter is
      C : Ardt.Pn_Counters.PN_Counter;
   begin
      Put_Line ("[PN-Counter] Initial value: "
                & Integer'Image (Ardt.Pn_Counters.Value (C)));
      pragma Assert (Ardt.Pn_Counters.Value (C) = 0);

      Ardt.Pn_Counters.Increment (C, 5);
      pragma Assert (Ardt.Pn_Counters.Value (C) = 5);
      Put_Line ("[PN-Counter] After +5: "
                & Integer'Image (Ardt.Pn_Counters.Value (C)));

      Ardt.Pn_Counters.Decrement (C, 3);
      pragma Assert (Ardt.Pn_Counters.Value (C) = 2);
      Put_Line ("[PN-Counter] After -3: "
                & Integer'Image (Ardt.Pn_Counters.Value (C)));

      declare
         D : Ardt.Pn_Counters.PN_Counter;
      begin
         Ardt.Pn_Counters.Increment (D, 10);
          Ardt.Pn_Counters.Merge (C, D);
         pragma Assert (Ardt.Pn_Counters.Value (C) = 7);
         Put_Line ("[PN-Counter] After merge with +10: "
                   & Integer'Image (Ardt.Pn_Counters.Value (C)));
      end;

      Put_Line ("[PN-Counter] PASS");
   end Test_PN_Counter;

   -----------------------------
   --  LWW-Element-Set Tests  --
   -----------------------------
   procedure Test_LWW_Set is
      Max_Size : constant Positive := 10;

      package LWW is new Ardt.Lww_Element_Sets (Integer, Max_Size);

      S : LWW.LWW_Element_Set (Max_Size);
   begin
      Put_Line ("[LWW-Set] Testing add/contains...");

      LWW.Add (S, 42, 100);
      LWW.Add (S, 7,  200);

      pragma Assert (LWW.Contains (S, 42));
      pragma Assert (LWW.Contains (S, 7));
      Put_Line ("[LWW-Set] Contains 42: "
                & Boolean'Image (LWW.Contains (S, 42)));
      Put_Line ("[LWW-Set] Contains 7:  "
                & Boolean'Image (LWW.Contains (S, 7)));

      LWW.Remove (S, 42, 150);
      pragma Assert (not LWW.Contains (S, 42));
      Put_Line ("[LWW-Set] Contains 42 after remove with TS>add: "
                & Boolean'Image (LWW.Contains (S, 42)));

      LWW.Add (S, 42, 200);
      pragma Assert (LWW.Contains (S, 42));
      Put_Line ("[LWW-Set] Contains 42 after re-add with newer TS: "
                & Boolean'Image (LWW.Contains (S, 42)));

      Put_Line ("[LWW-Set] PASS");
   end Test_LWW_Set;

   -----------------------
   --  RGA Tests        --
   -----------------------
   procedure Test_RGA is
      Max_Sz  : constant Positive := 10;
      Seq     : Natural := 0;

      package RGA_Str is new Ardt.Rga (Character, Max_Sz);

      R : RGA_Str.RGA (Max_Sz);

      function Next_Seq return RGA_Str.Node_Id is
      begin
         Seq := Seq + 1;
         return (Replica => 1, Seq => Seq);
      end Next_Seq;
   begin
      Put_Line ("[RGA] Testing insert/delete/merge...");

      RGA_Str.Insert (R, 1, Next_Seq, 'a');
      pragma Assert (RGA_Str.Size (R) = 1);
      pragma Assert (RGA_Str.Get (R, 1) = 'a');

      RGA_Str.Insert (R, 2, Next_Seq, 'b');
      RGA_Str.Insert (R, 3, Next_Seq, 'c');
      pragma Assert (RGA_Str.Size (R) = 3);
      pragma Assert (RGA_Str.Get (R, 1) = 'a');
      pragma Assert (RGA_Str.Get (R, 2) = 'b');
      pragma Assert (RGA_Str.Get (R, 3) = 'c');

      RGA_Str.Insert (R, 2, Next_Seq, 'x');
      pragma Assert (RGA_Str.Size (R) = 4);
      pragma Assert (RGA_Str.Get (R, 1) = 'a');
      pragma Assert (RGA_Str.Get (R, 2) = 'x');
      pragma Assert (RGA_Str.Get (R, 3) = 'b');
      pragma Assert (RGA_Str.Get (R, 4) = 'c');

      Put_Line ("[RGA] PASS");
   end Test_RGA;

   ------------------------
   --  RGAs Tests        --
   ------------------------
   procedure Test_RGAs is
      Max_Sz  : constant Positive := 10;
      Max_Cnt : constant Positive := 5;

      package RGAs_Pkg is new Ardt.Rgas (Character, Max_Sz, Max_Cnt);

      RS : RGAs_Pkg.RGAs (Max_Cnt);
      R1 : RGAs_Pkg.RGA_Entry;
      R2 : RGAs_Pkg.RGA_Entry;
   begin
      Put_Line ("[RGAs] Testing append/merge...");

      RGAs_Pkg.RGA_Pkg.Insert (R1, 1,
        (Replica => 1, Seq => 1), 'a');
      RGAs_Pkg.RGA_Pkg.Insert (R1, 2,
        (Replica => 1, Seq => 2), 'b');

      RGAs_Pkg.RGA_Pkg.Insert (R2, 1,
        (Replica => 2, Seq => 1), 'c');
      RGAs_Pkg.RGA_Pkg.Insert (R2, 2,
        (Replica => 2, Seq => 2), 'd');

      RGAs_Pkg.Append (RS, R1);
      RGAs_Pkg.Append (RS, R2);
      pragma Assert (RGAs_Pkg.Size (RS) = 2);

      Put_Line ("[RGAs] PASS");
   end Test_RGAs;

begin
   Put_Line ("=== ARDT CRDT Test Suite ===");
   New_Line;

   Test_PN_Counter;
   New_Line;

   Test_LWW_Set;
   New_Line;

   Test_RGA;
   New_Line;

   Test_RGAs;
   New_Line;

   Put_Line ("=== All Tests Passed ===");
end Test_Crdt;
