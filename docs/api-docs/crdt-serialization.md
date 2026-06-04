# CRDT.Serialization

Protocol version router and canonical deserialization dispatcher. Auto-detects V1 (fixed-width Natural) vs V2 (LEB128) wire formats by inspecting the first 4 header bytes, then routes subsequent field reads through the correct decoder. This allows users of old library versions to serialise data that newer library versions can seamlessly read and auto-migrate.

> **Note:** All items in this package are public.

## Types

### type Protocol_Kind

```ada
type Protocol_Kind is (Proto_V1, Proto_V2);
```

## Procedures

### procedure Read_Header (Stream : Ada.Streams.Root_Stream_Type; Kind : CRDT.Serialization.Protocol_Kind; Total : Standard.Natural; Count : Standard.Natural)

| Parameter | Description |
|-----------|-------------|
| `Count` |  |
| `Kind` |  |
| `Stream` |  |
| `Total` |  |

### procedure Read_Natural (Kind : CRDT.Serialization.Protocol_Kind; Stream : Ada.Streams.Root_Stream_Type; Value : Standard.Natural)

| Parameter | Description |
|-----------|-------------|
| `Kind` |  |
| `Stream` |  |
| `Value` |  |
