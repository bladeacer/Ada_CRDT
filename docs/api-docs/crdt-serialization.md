# CRDT.Serialization

Protocol version router and canonical deserialization dispatcher. Auto-detects V1 (fixed-width Natural), V2 (LEB128), and V3 (LEB128 + clock kind discriminator) wire formats by inspecting the first header bytes, then routes subsequent field reads through the correct decoder. This allows users of old library versions to serialise data that newer library versions can seamlessly read and auto-migrate. Requirements traceability: - HLR-PROTO-HEADER: Read wire-format protocol header - HLR-PROTO-DISPATCH: Version-aware field reading

> **Note:** All items in this package are public.

## Types

### type Protocol_Kind

```ada
type Protocol_Kind is (Proto_V1, Proto_V2, Proto_V3);
```

## Procedures

### procedure Migrate_Header (Source : Ada.Streams.Root_Stream_Type; Dest : Ada.Streams.Root_Stream_Type; Kind : CRDT.Serialization.Protocol_Kind; Total : Standard.Natural; Count : Standard.Natural)

| Parameter | Description |
|-----------|-------------|
| `Count` | Entry/item count from source header. |
| `Dest` | Output stream for V2-encoded header. |
| `Kind` | Detected protocol version of source. |
| `Source` | Input stream with V1 or V2 payload. |
| `Total` | Total element count from source header. |

### procedure Read_Header (Stream : Ada.Streams.Root_Stream_Type; Kind : CRDT.Serialization.Protocol_Kind; Total : Standard.Natural; Count : Standard.Natural; Clock_Kind : CRDT.Clocks.Clock_Kind)

| Parameter | Description |
|-----------|-------------|
| `Clock_Kind` | Clock strategy used for serialization (V3 only; |
| `Count` | Entry/item count from header. |
| `Kind` | Detected protocol version (V1, V2, or V3). |
| `Stream` | Input stream positioned at start of a CRDT payload. |
| `Total` | Total element count from header. |

### procedure Read_Natural (Kind : CRDT.Serialization.Protocol_Kind; Stream : Ada.Streams.Root_Stream_Type; Value : Standard.Natural)

| Parameter | Description |
|-----------|-------------|
| `Kind` | Protocol version to use for decoding. |
| `Stream` | Input stream to read from. |
| `Value` | Decoded natural value. |

### procedure Write_Header_V3 (Stream : Ada.Streams.Root_Stream_Type; Total : Standard.Natural; Count : Standard.Natural; Clk_Kind : CRDT.Clocks.Clock_Kind)

| Parameter | Description |
|-----------|-------------|
| `Clk_Kind` | Clock strategy identifier for this payload. |
| `Count` | Entry/item count. |
| `Stream` | Output stream to write to. |
| `Total` | Total element count. |
