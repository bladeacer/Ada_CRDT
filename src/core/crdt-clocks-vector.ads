with Ada.Streams;
with CRDT.Core;

--  Vector clock strategy.
--  Wraps CRDT.Core.VTime with uniform comparison, merge, increment, and I/O.
--  Each replica tracks its own logical counter; causal ordering is determined
--  by element-wise comparison of all counters.
--  Recommended default for production use.
--
--  Usage:
--     package V is new CRDT.Clocks.Vector (Max_Replicas => 8);
--     T1, T2 : V.Clock_Time;
--     V.Increment (T1, Idx => 1);
--     V.Merge (T1, T2);
--
--  Requirements traceability:
--  - HLR-CORE-CLOCKS: Clock strategy interface

generic
   Max_Replicas : Positive;
package CRDT.Clocks.Vector with SPARK_Mode is

   --  Per-replica event count array. Index = replica slot.
   subtype Clock_Time is CRDT.Core.VTime (1 .. Max_Replicas);

   --  Strict vector-clock less-than: all entries <= and at least one <.
   --  @param Left   Left clock.
   --  @param Right  Right clock.
   --  @return True if Left is strictly behind Right.
   function "<" (Left, Right : Clock_Time) return Boolean;

   --  Equality: all replica counters match.
   --  @param Left   Left clock.
   --  @param Right  Right clock.
   --  @return True if clocks are identical.
   function "=" (Left, Right : Clock_Time) return Boolean;

   --  Inverse of "<".
   --  @param Left   Left clock.
   --  @param Right  Right clock.
   --  @return True if Left strictly follows Right.
   function ">" (Left, Right : Clock_Time) return Boolean;

   --  Element-wise maximum of two vector clocks.
   --  @param Left   First clock.
   --  @param Right  Second clock.
   --  @return Clock where each entry is max of the two inputs.
   function Max (Left, Right : Clock_Time) return Clock_Time;

   --  Increment the counter for a given replica slot.
   --  @param T    Clock to modify.
   --  @param Idx  Replica slot index to increment.
   procedure Increment (T : in out Clock_Time; Idx : Positive);

   --  Element-wise max merge of Source into Target.
   --  @param Target  Clock to update.
   --  @param Source  Clock to merge from.
   procedure Merge (Target : in out Clock_Time; Source : Clock_Time);

   --  Serialise a vector clock (all replica counters, LEB128-encoded).
   --  @param Stream  Output stream.
   --  @param Item    Clock to write.
   procedure Write_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : Clock_Time);

   --  Deserialise a vector clock from a stream.
   --  @param Stream  Input stream.
   --  @param Item    Decoded clock.
   procedure Read_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Clock_Time);

end CRDT.Clocks.Vector;
