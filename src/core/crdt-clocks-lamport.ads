with Ada.Streams;
with CRDT.Core;

--  Lamport clock strategy.
--  Wraps CRDT.Core.Lamport_Time with uniform comparison, max, and I/O.
--  Lamport clocks capture causality through a logical counter + replica ID,
--  producing a total order without requiring wall-clock synchronisation.
--  Suitable when full causal history is not required.
--
--  Usage:
--     package L is new CRDT.Clocks.Lamport;
--     T1, T2 : L.Clock_Time;
--     --  result := L.Max (T1, T2);
--
--  Requirements traceability:
--  - HLR-CORE-CLOCKS: Clock strategy interface
package CRDT.Clocks.Lamport with
  SPARK_Mode
is

   --  Clock timestamp: logical counter + replica ID.
   --  Inherits from CRDT.Core.Lamport_Time.
   type Clock_Time is new CRDT.Core.Lamport_Time;

   --  Strict ordering: compares Stamp first, then Node.
   --  @param Left   Left operand.
   --  @param Right  Right operand.
   --  @return True if Left causally precedes Right.
   function "<" (Left, Right : Clock_Time) return Boolean;

   --  Equality: both Stamp and Node must match.
   --  @param Left   Left operand.
   --  @param Right  Right operand.
   --  @return True if timestamps are identical.
   function "=" (Left, Right : Clock_Time) return Boolean;

   --  Inverse of "<".
   --  @param Left   Left operand.
   --  @param Right  Right operand.
   --  @return True if Left causally follows Right.
   function ">" (Left, Right : Clock_Time) return Boolean;

   --  Return the causally later of two timestamps.
   --  @param Left   First timestamp.
   --  @param Right  Second timestamp.
   --  @return The timestamp that causally follows the other.
   function Max (Left, Right : Clock_Time) return Clock_Time;

   --  Serialise a clock timestamp to a stream (LEB128-encoded Stamp + Node).
   --  @param Stream  Output stream.
   --  @param Item    Clock timestamp to write.
   procedure Write_Clock
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Clock_Time);

   --  Deserialise a clock timestamp from a stream.
   --  @param Stream  Input stream.
   --  @param Item    Decoded clock timestamp.
   procedure Read_Clock
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Clock_Time);

end CRDT.Clocks.Lamport;
