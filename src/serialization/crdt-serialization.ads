--  Protocol version router and canonical deserialization dispatcher.
--  Auto-detects V1 (fixed-width Natural), V2 (LEB128), and V3
--  (LEB128 + clock kind discriminator) wire formats by inspecting
--  the first header bytes, then routes subsequent field reads through
--  the correct decoder.
--
--  This allows users of old library versions to serialise data that
--  newer library versions can seamlessly read and auto-migrate.
--
--  Requirements traceability:
--  - HLR-PROTO-HEADER: Read wire-format protocol header
--  - HLR-PROTO-DISPATCH: Version-aware field reading
with Ada.Streams;
with CRDT.Clocks;

package CRDT.Serialization with
  SPARK_Mode
is

   type Protocol_Kind is (Proto_V1, Proto_V2, Proto_V3);

   --  Read the wire-format header (version + clock_kind (V3) + Total + Count).
   --  Auto-detects V1 vs V2 vs V3 by inspecting the first header bytes.
   --  For V3 streams, the clock kind byte is read and returned; for
   --  V1/V2 the Clock_Kind output is set to Lamport (backwards compat).
   --  After this call the stream is positioned just after the header,
   --  ready for item-by-item deserialization.
   --  Raises Constraint_Error for unsupported protocol versions.
   --  Raises End_Error on empty stream.
   --  @param Stream     Input stream positioned at start of a CRDT payload.
   --  @param Kind       Detected protocol version (V1, V2, or V3).
   --  @param Total      Total element count from header.
   --  @param Count      Entry/item count from header.
   --  @param Clock_Kind Clock strategy used for serialization (V3 only;
   --                    Lamport for V1/V2).
   procedure Read_Header
      (Stream    : not null access Ada.Streams.Root_Stream_Type'Class;
       Kind      : out Protocol_Kind;
       Total     : out Natural;
       Count     : out Natural;
       Clock_Kind : out CRDT.Clocks.Clock_Kind) with
     SPARK_Mode => Off;

   --  Read a single Natural from the stream using the detected
   --  protocol version's encoding (Natural'Read for V1, LEB128 for V2/V3).
   --  @param Kind   Protocol version to use for decoding.
   --  @param Stream Input stream to read from.
   --  @param Value  Decoded natural value.
   procedure Read_Natural
      (Kind   : Protocol_Kind;
       Stream : not null access Ada.Streams.Root_Stream_Type'Class;
       Value  : out Natural) with
     SPARK_Mode => Off;

   --  Write a V3-encoded header (protocol version 3 + clock kind byte +
   --  LEB128 Total + LEB128 Count).
   --  @param Stream     Output stream to write to.
   --  @param Total      Total element count.
   --  @param Count      Entry/item count.
   --  @param Clk_Kind   Clock strategy identifier for this payload.
   procedure Write_Header_V3
      (Stream   : not null access Ada.Streams.Root_Stream_Type'Class;
       Total    : Natural;
       Count    : Natural;
       Clk_Kind : CRDT.Clocks.Clock_Kind) with
     SPARK_Mode => Off;

   --  Migrate a header from any protocol version to V3.
   --  Reads the version-agnostic header from Source and writes a
   --  V3-encoded header (version 3 + clock kind + LEB128 Total +
   --  LEB128 Count) to Dest.  V1/V2 data is auto-detected and
   --  promoted to V3.  V3 data is passed through (clock kind is
   --  preserved from the source).
   --  After this call Source is positioned just after the original header
   --  and Dest has a fresh V3 header ready for field writes.
   --  @param Source     Input stream with V1, V2, or V3 payload.
   --  @param Dest       Output stream for V3-encoded header.
   --  @param Kind       Detected protocol version of source (V1, V2, or V3).
   --  @param Total      Total element count from source header.
   --  @param Count      Entry/item count from source header.
   --  @param Clock_Kind Clock kind written to Dest (from source for V3,
   --                    caller-specified clock kind for V1/V2).
   procedure Migrate_Header_To_V3
      (Source     : not null access Ada.Streams.Root_Stream_Type'Class;
       Dest       : not null access Ada.Streams.Root_Stream_Type'Class;
       Kind       : out Protocol_Kind;
       Total      : out Natural;
       Count      : out Natural;
       Clock_Kind : out CRDT.Clocks.Clock_Kind) with
     SPARK_Mode => Off;

   --  Migrate a header from any protocol version to V2.
   --  Reads the version-agnostic header from Source and writes a
   --  V2-encoded header (LEB128 Protocol_Version + LEB128 Total +
   --  LEB128 Count) to Dest.  After this call:
   --     * Source is positioned just after the original header
   --     * Dest has a fresh V2 header and is ready for field writes
   --  @param Source  Input stream with V1 or V2 payload.
   --  @param Dest    Output stream for V2-encoded header.
   --  @param Kind    Detected protocol version of source.
   --  @param Total   Total element count from source header.
   --  @param Count   Entry/item count from source header.
   procedure Migrate_Header
      (Source : not null access Ada.Streams.Root_Stream_Type'Class;
       Dest   : not null access Ada.Streams.Root_Stream_Type'Class;
       Kind   : out Protocol_Kind;
       Total  : out Natural;
       Count  : out Natural) with
     SPARK_Mode => Off;

end CRDT.Serialization;
