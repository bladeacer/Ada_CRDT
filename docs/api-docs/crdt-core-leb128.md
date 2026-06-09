# CRDT.Core.LEB128

LEB128 variable-length integer encoding for compact wire protocol. Small values (0-127) encode as a single byte instead of 4 (Natural'Write), dramatically reducing bandwidth for the many single-digit fields in CRDT serialization (protocol version, counts, lengths).

> **Note:** All items in this package are public.

## Procedures

### procedure Decode (Stream : Ada.Streams.Root_Stream_Type; Value : Standard.Natural)

| Parameter | Description |
|-----------|-------------|
| `Stream` | Source input stream. |
| `Value` | Decoded integer. |

### procedure Encode (Stream : Ada.Streams.Root_Stream_Type; Value : Standard.Natural)

| Parameter | Description |
|-----------|-------------|
| `Stream` | Target output stream. |
| `Value` | Integer to encode (0 .. Natural'Last). |
