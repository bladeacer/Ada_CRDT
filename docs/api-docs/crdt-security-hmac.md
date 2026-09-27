# CRDT.Security.HMAC

HMAC tag length in bytes (full SHA-256 output).

> **Note:** All items in this package are public.

## Types

### type Byte

```ada
subtype Byte is Ada.Streams.Stream_Element;
```

### type Byte_Array

```ada
subtype Byte_Array is Ada.Streams.Stream_Element_Array;
```

### type Tag

```ada
subtype Tag is Byte_Array (1 .. Tag_Length);
```

## Functions

### function Equal (Left : CRDT.Security.HMAC.Tag; Right : CRDT.Security.HMAC.Tag) return Standard.Boolean `[Post]`

| Parameter | Description |
|-----------|-------------|
| `Left` | Computed tag. |
| `Right` | Expected tag. |

**Returns:** True when both tags are identical.

## Procedures

### procedure Compute (Key : CRDT.Security.HMAC.Byte_Array; Message : CRDT.Security.HMAC.Byte_Array; Out_Tag : CRDT.Security.HMAC.Tag) `[Pre]`

| Parameter | Description |
|-----------|-------------|
| `Key` | Symmetric key (any length; longer than the block |
| `Message` | Bytes to authenticate. |
| `Out_Tag` | 32-byte authentication tag. |
