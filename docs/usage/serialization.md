# Serialisation: the V1, V2, and V3 wire formats

Every serialised CRDT payload starts with a header that names the wire
format version. A reader detects the version from the first bytes, so old
data stays readable as the library evolves. The
[API reference](../api-docs/crdt-serialization.md) holds the exact contracts.

## The three formats

| Version | Encoding | Header layout |
|---------|----------|---------------|
| V1 (legacy) | Fixed-width `Natural'Read` / `Natural'Write` | 4-byte version, 4-byte Total, 4-byte Count |
| V2 | LEB128 for every integer field | LEB128 version = 2, LEB128 Total, LEB128 Count |
| V3 | LEB128 plus a clock-kind byte | LEB128 version = 3, clock-kind byte, LEB128 Total, LEB128 Count |

LEB128 stores a `Natural` in one to five bytes. Small values, which dominate
clocks, positions, and counts, take one or two bytes instead of four. The
`CRDT.Core.LEB128` package provides the encode and decode primitives.

V3 adds one byte that names the clock strategy of the payload, because the
generic containers can carry any strategy (see
[the clock strategies page](clock-strategies.md)). V1 and V2 data read back
with the Lamport strategy, which matches their era.

## Version detection

`Read_Header` inspects the first header bytes, reports which version it
found, extracts `Total` and `Count`, and leaves the stream positioned for
the field reads:

```ada
Kind : CRDT.Serialization.Protocol_Kind;
Total, Count : Natural;
CK : CRDT.Clocks.Clock_Kind;

CRDT.Serialization.Read_Header (Stream, Kind, Total, Count, CK);
--  Then read each field with CRDT.Serialization.Read_Natural,
--  which picks the decoder for Kind automatically.
```

A payload with an unsupported version raises `Constraint_Error`. An empty
stream raises `End_Error`.

## Which version does the library write?

- The legacy containers (`CRDT.Pn_Counters`, `CRDT.Lww_Element_Sets`,
  `CRDT.Rga`) write V2. V2 is the compatibility baseline: every reader from
  the V2 era onward reads it.
- The generic clocked containers (`CRDT.Lww_Sets` and the clocked sync
  layers) write V3 with the clock strategy of the instantiation.
- No current package writes V1. V1 exists as a read-only legacy format.

## Migration

Two helpers re-emit a header in a newer format:

- `Migrate_Header_To_V3` reads a V1, V2, or V3 header and writes a V3
  header. The clock kind comes from the source when it is V3, or from your
  argument when the source is V1 or V2.
- `Migrate_Header` reads a V1 or V2 header and writes a V2 header.

```ada
CRDT.Serialization.Migrate_Header_To_V3
  (Source, Dest, Kind, Total, Count, Clock_Kind);
--  Source is now positioned after its header; Dest holds a fresh
--  V3 header.  Copy the fields after the header in your own code.
```

The helpers move only the header. Copy the payload fields with your field
reader and writer, or re-serialise the container, so the field encodings
match the new header.

## Upgrade guidance

Rolling upgrades work without a conversion step: every reader reads all
older formats. Convert archived data to V3 when you touch it, and new
writes carry the strategy byte from the start. The
[V1 to V2 migration guide](../changelogs/crdt-1.4.0-migration.md) records
the one-time breaking change in the protocol history.

## See also

- [Containers, wrappers, and the hybrid logical clock](containers-and-wrappers.md)
  -- the state you write to a stream.
- [Sync layers](sync.md) -- the payloads that a stream carries.
- [V1 to V2 migration guide](../changelogs/crdt-1.4.0-migration.md) -- the
  one-time breaking change in the protocol history.
