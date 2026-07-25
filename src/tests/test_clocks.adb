with CRDT.Test_Support; use CRDT.Test_Support;
with CRDT.Core;
with CRDT.Clocks;
with CRDT.Clocks.Lamport;
with CRDT.Clocks.Vector;
with CRDT.Clocks.Matrix;
with CRDT.Lww_Sets;
with Ada.Text_IO; use Ada.Text_IO;

package body Test_Clocks is

   procedure Run (RunR : in out Runner) is

      ----------------
      --  Lamport   --
      ----------------

      procedure Test_Lamport_Clock is
         use CRDT.Clocks.Lamport;

         A : Clock_Time := (Stamp => 100, Node => 1);
         B : Clock_Time := (Stamp => 200, Node => 1);
         C : Clock_Time := (Stamp => 100, Node => 2);
      begin
         New_Line;
         Put_Line ("[Clocks.Lamport]");

         RunR.Check (A < B, "A.Stamp=100 < B.Stamp=200");
         RunR.Check (not (B < A), "B not < A");
         RunR.Check (A < C, "A.Stamp=100 <= C.Stamp=100 but Node 1 < 2");
         RunR.Check (not (C < A), "C not < A (Stamp tie, Node 2 > 1)");
         RunR.Check (A = A, "A = A");
         RunR.Check (B > A, "B > A");
         RunR.Check (Max (A, B) = B, "Max(A, B) = B");

         Put_Line ("[Clocks.Lamport] done.");
      end Test_Lamport_Clock;

      --------------------
      --  Vector Clock  --
      --------------------

      procedure Test_Vector_Clock is
         Max_R : constant Positive := 4;

         package VClock is new CRDT.Clocks.Vector (Max_R);
         use VClock;

         A : Clock_Time := (1, 0, 0, 0);
         B : Clock_Time := (1, 1, 0, 0);
         C : Clock_Time := (0, 1, 0, 0);
      begin
         New_Line;
         Put_Line ("[Clocks.Vector]");

         RunR.Check (A < B, "A (1,0,0,0) < B (1,1,0,0)");
         RunR.Check (not (B < A), "B not < A");
         RunR.Check (not (A < C), "A (1,0,0,0) concurrent with C (0,1,0,0): A not < C (A[1]=1 > C[1]=0)");
         RunR.Check (not (C < A), "C (0,1,0,0) concurrent with A: C not < A (C[2]=1 > A[2]=0)");

         RunR.Check (A = A, "A = A");
         RunR.Check (B > A, "B > A");

         declare
            M : Clock_Time := Max (A, B);
         begin
            RunR.Check (M = (1, 1, 0, 0), "Max(A,B) = (1,1,0,0)");
         end;

         declare
            T : Clock_Time := (0, 0, 0, 0);
         begin
            Increment (T, 1);
            RunR.Check (T = (1, 0, 0, 0), "Increment idx=1 -> (1,0,0,0)");
            Increment (T, 3);
            RunR.Check (T = (1, 0, 1, 0), "Increment idx=3 -> (1,0,1,0)");
         end;

         declare
            T1 : Clock_Time := (2, 1, 0, 0);
            T2 : Clock_Time := (1, 3, 0, 0);
         begin
            Merge (T1, T2);
            RunR.Check (T1 = (2, 3, 0, 0), "Merge (2,1,0,0) + (1,3,0,0) -> (2,3,0,0)");
         end;

         Put_Line ("[Clocks.Vector] done.");
      end Test_Vector_Clock;

      --------------------
      --  Matrix Clock  --
      --------------------

      procedure Test_Matrix_Clock is
         Max_R : constant Positive := 3;

         package MClock is new CRDT.Clocks.Matrix (Max_R);
         use MClock;

         A : Clock_Time := ((1, 0, 0), (0, 0, 0), (0, 0, 0));
         B : Clock_Time := ((1, 1, 0), (0, 0, 0), (0, 0, 0));
      begin
         New_Line;
         Put_Line ("[Clocks.Matrix]");

         RunR.Check (A < B, "A < B (A[1,2]=0 < B[1,2]=1)");
         RunR.Check (not (B < A), "B not < A");
         RunR.Check (A = A, "A = A");
         RunR.Check (B > A, "B > A");

         declare
            M : Clock_Time := Max (A, B);
         begin
            RunR.Check (M (1, 1) = 1 and then M (1, 2) = 1,
                       "Max(A,B)[1,1]=1 and [1,2]=1");
         end;

         declare
            T : Clock_Time := ((0, 0, 0), (0, 0, 0), (0, 0, 0));
         begin
            Increment (T, 1, 2);
            RunR.Check (T (1, 2) = 1, "Increment (1,2) -> T[1,2]=1");
            Increment (T, 2, 3);
            RunR.Check (T (2, 3) = 1, "Increment (2,3) -> T[2,3]=1");
            RunR.Check (T (1, 1) = 0, "T[1,1] still 0");
         end;

         declare
            T1 : Clock_Time := ((2, 0, 0), (0, 1, 0), (0, 0, 0));
            T2 : Clock_Time := ((1, 3, 0), (0, 0, 0), (0, 0, 0));
         begin
            Merge (T1, T2);
            RunR.Check (T1 (1, 1) = 2 and then T1 (1, 2) = 3,
                       "Merge: T1[1,1]=2 <-> T2[1,1]=1 => keep 2; T1[1,2]=0 <-> T2[1,2]=3 => keep 3");
         end;

         Put_Line ("[Clocks.Matrix] done.");
      end Test_Matrix_Clock;

      ----------------------------
      --  Lww_Sets with Vector  --
      ----------------------------

      procedure Test_Lww_Sets_Vector is
         Max_R  : constant Positive := 4;
         Max_Sz : constant Positive := 10;

         package VClock is new CRDT.Clocks.Vector (Max_R);
         use VClock;

          package LWW is new CRDT.Lww_Sets
            (Element_Type => Integer,
             Max_Set_Size => Max_Sz,
             Clock_Time   => Clock_Time,
             Clk_Kind     => CRDT.Clocks.Clock_Vector,
             "<"          => "<",
             "="          => "=",
             ">"          => ">",
             Max          => Max,
             Write_Clock  => Write_Clock,
             Read_Clock   => Read_Clock);

          S : LWW.LWW_Clocked_Set (Max_Sz);
       begin
          New_Line;
          RunR.Check (not LWW.Contains (S, 42), "Empty: Contains(42) = False");

         LWW.Add (S, 42, (1, 0, 0, 0));
         RunR.Check (LWW.Contains (S, 42), "Add(42, vec=(1,0,0,0)): Contains = True");

         LWW.Remove (S, 42, (2, 0, 0, 0));
         RunR.Check (not LWW.Contains (S, 42),
                    "Remove(42, vec=(2,0,0,0)) > add vec -> not Contains");

         LWW.Add (S, 42, (3, 0, 0, 0));
         RunR.Check (LWW.Contains (S, 42),
                    "Re-add(42, vec=(3,0,0,0)) > remove vec -> Contains = True");

         LWW.Add (S, 7, (1, 1, 0, 0));
         RunR.Check (LWW.Contains (S, 7), "Add(7, vec=(1,1,0,0)): Contains = True");

         declare
            S2 : LWW.LWW_Clocked_Set (Max_Sz);
         begin
            LWW.Add (S2, 42, (5, 0, 0, 0));
            LWW.Merge (S, S2);
            RunR.Check (LWW.Contains (S, 42),
                       "Merge: S2 has 42@vec=(5,0,0,0) > S's 42@(3,0,0,0) -> Contains");
         end;

         Put_Line ("[Lww_Sets.Vector] done.");
      end Test_Lww_Sets_Vector;

      ----------------------------
      --  Lww_Sets with Lamport --
      ----------------------------

      procedure Test_Lww_Sets_Lamport is
         Max_Sz : constant Positive := 10;

          package LWW is new CRDT.Lww_Sets
            (Element_Type => Integer,
             Max_Set_Size => Max_Sz,
             Clock_Time   => CRDT.Clocks.Lamport.Clock_Time,
             Clk_Kind     => CRDT.Clocks.Clock_Lamport,
             "<"          => CRDT.Clocks.Lamport."<",
             "="          => CRDT.Clocks.Lamport."=",
             ">"          => CRDT.Clocks.Lamport.">",
             Max          => CRDT.Clocks.Lamport.Max,
             Write_Clock  => CRDT.Clocks.Lamport.Write_Clock,
             Read_Clock   => CRDT.Clocks.Lamport.Read_Clock);

         S : LWW.LWW_Clocked_Set (Max_Sz);
      begin
         New_Line;
         Put_Line ("[Lww_Sets.Lamport]");

         RunR.Check (not LWW.Contains (S, 42), "Empty: Contains(42) = False");

         LWW.Add (S, 42, (100, 1));
         RunR.Check (LWW.Contains (S, 42), "Add(42, lam=(100,1)): Contains = True");

         LWW.Remove (S, 42, (200, 1));
         RunR.Check (not LWW.Contains (S, 42),
                    "Remove(42, lam=(200,1)) > add -> not Contains");

         LWW.Add (S, 42, (300, 1));
         RunR.Check (LWW.Contains (S, 42),
                    "Re-add(42, lam=(300,1)) > remove -> Contains");

         Put_Line ("[Lww_Sets.Lamport] done.");
      end Test_Lww_Sets_Lamport;

      ----------------------------
      --  Lww_Sets with Matrix  --
      ----------------------------

      procedure Test_Lww_Sets_Matrix is
         Max_R  : constant Positive := 3;
         Max_Sz : constant Positive := 10;

         package MClock is new CRDT.Clocks.Matrix (Max_R);
         use MClock;

          package LWW is new CRDT.Lww_Sets
            (Element_Type => Integer,
             Max_Set_Size => Max_Sz,
             Clock_Time   => Clock_Time,
             Clk_Kind     => CRDT.Clocks.Clock_Matrix,
             "<"          => "<",
             "="          => "=",
             ">"          => ">",
             Max          => Max,
             Write_Clock  => Write_Clock,
             Read_Clock   => Read_Clock);

         S : LWW.LWW_Clocked_Set (Max_Sz);
      begin
         New_Line;
         Put_Line ("[Lww_Sets.Matrix]");

         RunR.Check (not LWW.Contains (S, 42), "Empty: Contains(42) = False");

         LWW.Add (S, 42, ((1, 0, 0), (0, 0, 0), (0, 0, 0)));
         RunR.Check (LWW.Contains (S, 42), "Add(42, mat=...): Contains = True");

         LWW.Remove (S, 42, ((2, 0, 0), (0, 0, 0), (0, 0, 0)));
         RunR.Check (not LWW.Contains (S, 42),
                    "Remove with larger matrix -> not Contains");

         LWW.Add (S, 42, ((3, 0, 0), (0, 0, 0), (0, 0, 0)));
         RunR.Check (LWW.Contains (S, 42),
                    "Re-add with larger matrix -> Contains");

         Put_Line ("[Lww_Sets.Matrix] done.");
      end Test_Lww_Sets_Matrix;

   begin
      Test_Lamport_Clock;
      Test_Vector_Clock;
      Test_Matrix_Clock;
      Test_Lww_Sets_Lamport;
      Test_Lww_Sets_Vector;
      Test_Lww_Sets_Matrix;
   end Run;

end Test_Clocks;
