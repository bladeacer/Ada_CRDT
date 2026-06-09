# CRDT.Serialization

Protocol version router and canonical deserialization dispatcher. Auto-detects V1 (fixed-width Natural) vs V2 (LEB128) wire formats by inspecting the first 4 header bytes, then routes subsequent field reads through the correct decoder. This allows users of old library versions to serialise data that newer library versions can seamlessly read and auto-migrate. Requirements traceability: - HLR-PROTO-HEADER: Read wire-format protocol header - HLR-PROTO-DISPATCH: Version-aware field reading

> **Note:** All items in this package are public.

## Types

### type Protocol_Kind

```ada
type Protocol_Kind is (Proto_V1, Proto_V2);
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

### procedure Read_Header (Stream : Ada.Streams.Root_Stream_Type; Kind : CRDT.Serialization.Protocol_Kind; Total : Standard.Natural; Count : Standard.Natural)

| Parameter | Description |
|-----------|-------------|
| `Count` | Entry/item count from header. |
| `Kind` | Detected protocol version (V1 or V2). |
| `Stream` | Input stream positioned at start of a CRDT payload. |
| `Total` | Total element count from header. |

### procedure Read_Natural (Kind : CRDT.Serialization.Protocol_Kind; Stream : Ada.Streams.Root_Stream_Type; Value : Standard.Natural)

| Parameter | Description |
|-----------|-------------|
| `Kind` | Protocol version to use for decoding. |
| `Stream` | Input stream to read from. |
| `Value` | Decoded natural value. |
