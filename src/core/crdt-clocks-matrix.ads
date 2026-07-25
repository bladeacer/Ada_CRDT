with Ada.Streams;

--  Matrix clock strategy.
--  2D array tracking per-replica knowledge propagation.
--  M[i][j] = node i's knowledge of node j's event count.
--
--  Requirements traceability:
--  - HLR-CORE-CLOCKS: Clock strategy interface
--  - HLR-CORE-CLOCKS-MATRIX: Matrix clock operations
generic
   Max_Replicas : Positive;
package CRDT.Clocks.Matrix with
  SPARK_Mode
is

   type Clock_Time is array (1 .. Max_Replicas, 1 .. Max_Replicas) of Natural
     with Default_Component_Value => 0;

   function "<" (Left, Right : Clock_Time) return Boolean;

   function "=" (Left, Right : Clock_Time) return Boolean;

   function ">" (Left, Right : Clock_Time) return Boolean;

   function Max (Left, Right : Clock_Time) return Clock_Time;

   procedure Increment (T    : in out Clock_Time;
                        Row  : Positive;
                        Col  : Positive);

   procedure Merge (Target : in out Clock_Time; Source : Clock_Time);

   procedure Write_Clock
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Clock_Time);

   procedure Read_Clock
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Clock_Time);

end CRDT.Clocks.Matrix;
