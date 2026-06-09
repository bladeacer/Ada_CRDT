# CRDT.Serialization.Legacy

Legacy V1 fixed-width deserialization mechanisms. Protocol V1 used 4-byte Natural'Read for all integer fields. These routines are kept isolated here so they do not clutter the main production code path. The version router in CRDT.Serialization.Read_Header auto-detects V1 vs V2 and dispatches field reads to the correct decoder, so callers never need to touch this package directly. Requirements traceability: - HLR-PROTO-LEGACY: V1 fixed-width integer reading

> **Note:** All items in this package are public.

## Procedures

### procedure Read_Natural_V1 (Stream : Ada.Streams.Root_Stream_Type; Value : Standard.Natural)

| Parameter | Description |
|-----------|-------------|
| `Stream` | Input stream to read from. |
| `Value` | Decoded 32-bit natural value. |
