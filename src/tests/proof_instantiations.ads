--  SPARK proof instantiations.
--
--  GNATprove does not analyze generic units directly: each generic body is
--  only analyzed when instantiated.  This package instantiates every CRDT
--  generic with representative formals so that the bodies are proved under
--  SPARK_Mode => On.  It is a proof-only unit: it adds no public API and is
--  not used at run time.
with CRDT.Clocks;
with CRDT.Clocks.Vector;
with CRDT.Clocks.Matrix;
with CRDT.Lww_Sets;
with CRDT.Rga;
with CRDT.Rgas;
with CRDT.Sequences.Yjs;
with CRDT.Sequences.Naive;
with CRDT.Sequences.Fugue;
with CRDT.Sync.State_Based.Clocked;

package Proof_Instantiations
  with SPARK_Mode
is

   package Vector_4 is new CRDT.Clocks.Vector (Max_Replicas => 4);

   package Matrix_4 is new CRDT.Clocks.Matrix (Max_Replicas => 4);

   package Clocked_Vector is new
     CRDT.Sync.State_Based.Clocked
       (Clock_Time  => Vector_4.Clock_Time,
        "<"         => Vector_4."<",
        "="         => Vector_4."=",
        ">"         => Vector_4.">",
        Max         => Vector_4.Max,
        Write_Clock => Vector_4.Write_Clock,
        Read_Clock  => Vector_4.Read_Clock);

   package Lww_Set_Vector is new
     CRDT.Lww_Sets
       (Element_Type => Character,
        Max_Set_Size => 32,
        Clock_Time   => Vector_4.Clock_Time,
        Clk_Kind     => CRDT.Clocks.Clock_Vector,
        "<"          => Vector_4."<",
        "="          => Vector_4."=",
        ">"          => Vector_4.">",
        Max          => Vector_4.Max,
        Write_Clock  => Vector_4.Write_Clock,
        Read_Clock   => Vector_4.Read_Clock);

   package Yjs_Char is new CRDT.Sequences.Yjs (Character, 64);

   package Naive_Char is new CRDT.Sequences.Naive (Character, 64);

   package Fugue_Char is new CRDT.Sequences.Fugue (Character, 64);

   package Rga_Char is new CRDT.Rga (Character, Max_Items => 64, Max_Stride => 8, Max_Replicas => 4);

   package Rgas_Char is new CRDT.Rgas (Character, Max_RGA_Size => 64, Max_RGA_Count => 4, Max_Stride => 8, Max_Replicas => 4);

end Proof_Instantiations;
