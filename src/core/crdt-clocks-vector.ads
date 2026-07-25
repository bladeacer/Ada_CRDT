with Ada.Streams;
with CRDT.Core;

--  Vector clock strategy.
--  Wraps Core.VTime with uniform comparison, merge, increment, and I/O.
--  Recommended default for production use.
--
--  Requirements traceability:
--  - HLR-CORE-CLOCKS: Clock strategy interface
generic
   Max_Replicas : Positive;
package CRDT.Clocks.Vector with
  SPARK_Mode
is

   subtype Clock_Time is CRDT.Core.VTime (1 .. Max_Replicas);

   function "<" (Left, Right : Clock_Time) return Boolean;
   function "=" (Left, Right : Clock_Time) return Boolean;
   function ">" (Left, Right : Clock_Time) return Boolean;

   function Max (Left, Right : Clock_Time) return Clock_Time;

   procedure Increment (T : in out Clock_Time; Idx : Positive);

   procedure Merge (Target : in out Clock_Time; Source : Clock_Time);

   procedure Write_Clock
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Clock_Time);

   procedure Read_Clock
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Clock_Time);

end CRDT.Clocks.Vector;
