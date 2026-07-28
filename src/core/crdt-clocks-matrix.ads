with Ada.Streams;

--  Matrix clock strategy.
--  2D array tracking per-replica knowledge propagation.
--  M[i][j] = node i's knowledge of node j's event count.
--  Provides full transitive causal visibility at O(N^2) storage cost.
--  Useful for advanced gossip protocols and group membership.
--
--  Usage:
--     package M is new CRDT.Clocks.Matrix (Max_Replicas => 4);
--     T1, T2 : M.Clock_Time;
--     M.Increment (T1, Row => 1, Col => 2);
--     M.Merge (T1, T2);
--
--  Requirements traceability:
--  - HLR-CORE-CLOCKS: Clock strategy interface
--  - HLR-CORE-CLOCKS-MATRIX: Matrix clock operations
--
--  @formal Max_Replicas  Number of replica slots in the matrix clock.

generic
   Max_Replicas : Positive;
package CRDT.Clocks.Matrix with SPARK_Mode is

   --  2D array: row = observer, column = observed replica.
   type Clock_Time is array (1 .. Max_Replicas, 1 .. Max_Replicas) of Natural with Default_Component_Value => 0;

   --  Matrix less-than: all entries <= and at least one <.
   --  @param Left   Left clock.
   --  @param Right  Right clock.
   --  @return True if Left is strictly behind Right.
   function "<" (Left, Right : Clock_Time) return Boolean;

   --  Equality: all entries match.
   --  @param Left   Left clock.
   --  @param Right  Right clock.
   --  @return True if matrices are identical.
   function "=" (Left, Right : Clock_Time) return Boolean;

   --  Inverse of "<".
   --  @param Left   Left clock.
   --  @param Right  Right clock.
   --  @return True if Left strictly follows Right.
   function ">" (Left, Right : Clock_Time) return Boolean;

   --  Element-wise maximum of two matrices.
   --  @param Left   First clock.
   --  @param Right  Second clock.
   --  @return Matrix where each (R,C) is max of the two inputs.
   function Max (Left, Right : Clock_Time) return Clock_Time;

   --  Increment cell (Row, Col) by one.
   --  @param T    Matrix to modify.
   --  @param Row  Observer replica slot.
   --  @param Col  Observed replica slot.
   procedure Increment (T : in out Clock_Time; Row : Positive; Col : Positive);

   --  Element-wise max merge of Source into Target.
   --  @param Target  Matrix to update.
   --  @param Source  Matrix to merge from.
   procedure Merge (Target : in out Clock_Time; Source : Clock_Time);

   --  Serialise a matrix clock (all rows/cols, LEB128-encoded).
   --  @param Stream  Output stream.
   --  @param Item    Matrix to write.
   procedure Write_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : Clock_Time);

   --  Deserialise a matrix clock from a stream.
   --  @param Stream  Input stream.
   --  @param Item    Decoded matrix.
   procedure Read_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Clock_Time);

end CRDT.Clocks.Matrix;
