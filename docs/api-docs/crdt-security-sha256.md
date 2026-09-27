# CRDT.Security.SHA256

SHA-256 hash (FIPS 180-4), pure SPARK buffer interface.
One-shot and streaming (Init/Update/Final) forms.  No heap use.

Used by the post-quantum verification layer (CRDT.Security.*) as the
hash function H for LM-OTS/LMS (RFC 8554) and as the HMAC-SHA-256
compression core (RFC 2104).

Requirements traceability:
- HLR-SEC-SHA256: SHA-256 hash for integrity and signatures

> **Note:** 14 public item(s) shown below; 6 private internal item(s) are in the `private` section.

## Types

### type Buf_Count

```ada
subtype Buf_Count is Natural range 0 .. Block_Length - 1;
```

### type Byte

```ada
subtype Byte is Ada.Streams.Stream_Element;
```

### type Byte_Array

```ada
subtype Byte_Array is Ada.Streams.Stream_Element_Array;
```

### type Byte_Array_64

```ada
type Byte_Array_64 is array (1 .. Block_Length) of Byte;
```

### type Context

```ada
type Context is record
H    : Word_Array_8 := (16#6A09E667#, 16#BB67AE85#, 16#3C6EF372#,
16#A54FF53A#, 16#510E527F#, 16#9B05688C#,
16#1F83D9AB#, 16#5BE0CD19#);
Len  : Count := 0;
Buf  : Byte_Array_64 := (others => 0);
BufN : Buf_Count := 0;
end record;
```

### type Count

```ada
type Count is mod 2 ** 64;
```

### type Hash

```ada
subtype Hash is Byte_Array (1 .. Hash_Length);
```

### type Word32

```ada
type Word32 is new Interfaces.Unsigned_32;
```

### type Word_Array_8

```ada
type Word_Array_8 is array (1 .. 8) of Word32;
```

## Functions

### function Initial_Context return CRDT.Security.SHA256.Context

## Procedures

### procedure Digest (Bytes : CRDT.Security.SHA256.Byte_Array; Out_D : CRDT.Security.SHA256.Hash)

| Parameter | Description |
|-----------|-------------|
| `Bytes` | Input bytes. |
| `Out_D` | 32-byte digest. |

### procedure Final (Ctx : CRDT.Security.SHA256.Context; Out_D : CRDT.Security.SHA256.Hash)

| Parameter | Description |
|-----------|-------------|
| `Ctx` | Context to finish. |
| `Out_D` | 32-byte digest. |

### procedure Init (Ctx : CRDT.Security.SHA256.Context) `[Post]`

| Parameter | Description |
|-----------|-------------|
| `Ctx` | Context to initialise. |

### procedure Update (Ctx : CRDT.Security.SHA256.Context; Bytes : CRDT.Security.SHA256.Byte_Array) `[Depends]`

| Parameter | Description |
|-----------|-------------|
| `Bytes` | Input bytes. |
| `Ctx` | Context to update. |

---

## Private Section

- **type** `Word32`
- **type** `Count`
- **subtype** `Buf_Count`
- **type** `Word_Array_8`
- **type** `Byte_Array_64`
- **type** `Context`
