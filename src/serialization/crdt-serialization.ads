--  Protocol version router and canonical deserialization dispatcher.
--  Auto-detects V1 (fixed-width Natural) vs V2 (LEB128) wire formats
--  by inspecting the first 4 header bytes, then routes subsequent
--  field reads through the correct decoder.
--
--  This allows users of old library versions to serialise data that
--  newer library versions can seamlessly read and auto-migrate.
--
--  Requirements traceability:
--  - HLR-PROTO-HEADER: Read wire-format protocol header
--  - HLR-PROTO-DISPATCH: Version-aware field reading
with Ada.Streams;

package CRDT.Serialization with
  SPARK_Mode => Off
is

   type Protocol_Kind is (Proto_V1, Proto_V2);

   --  Read the wire-format header (version + Total + Count).
   --  Auto-detects V1 vs V2 by inspecting the first 4 bytes.
   --  After this call the stream is positioned just after the header,
   --  ready for item-by-item deserialization.
   --  Raises Constraint_Error for unsupported protocol versions.
   --  Raises End_Error on empty stream.
   --  @param Stream  Input stream positioned at start of a CRDT payload.
   --  @param Kind    Detected protocol version (V1 or V2).
   --  @param Total   Total element count from header.
   --  @param Count   Entry/item count from header.
   procedure Read_Header
     (Stream   : not null access Ada.Streams.Root_Stream_Type'Class;
      Kind     : out Protocol_Kind;
      Total    : out Natural;
      Count    : out Natural);

   --  Read a single Natural from the stream using the detected
   --  protocol version's encoding (Natural'Read for V1, LEB128 for V2).
   --  @param Kind   Protocol version to use for decoding.
   --  @param Stream Input stream to read from.
   --  @param Value  Decoded natural value.
   procedure Read_Natural
     (Kind   : Protocol_Kind;
      Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Value  : out Natural);

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
      Count  : out Natural);

end CRDT.Serialization;
