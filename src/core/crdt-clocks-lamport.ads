with Ada.Streams;
with CRDT.Core;

--  Lamport clock strategy.
--  Wraps Core.Lamport_Time with uniform comparison, max, and I/O.
--
--  Requirements traceability:
--  - HLR-CORE-CLOCKS: Clock strategy interface
package CRDT.Clocks.Lamport with
  SPARK_Mode
is

   type Clock_Time is new CRDT.Core.Lamport_Time;

   function "<" (Left, Right : Clock_Time) return Boolean;
   function "=" (Left, Right : Clock_Time) return Boolean;
   function ">" (Left, Right : Clock_Time) return Boolean;

   function Max (Left, Right : Clock_Time) return Clock_Time;

   procedure Write_Clock
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Clock_Time);

   procedure Read_Clock
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Clock_Time);

end CRDT.Clocks.Lamport;
