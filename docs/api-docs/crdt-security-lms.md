# CRDT.Security.LMS

LM-OTS and LMS hash-based signature verification (RFC 8554,
NIST SP 800-208 approved).  Post-quantum: security rests only on
the pre-image resistance of SHA-256, so a quantum computer does not
break it the way it breaks RSA and ECDSA.

Verify-only by design: signing requires stateful one-time private
keys that must never be reused, and this library never holds secret
key state.  Peers sign CRDT state offline (a hardware token, a
signing service) and replicas verify with the public key before a
Merge is accepted.

Supported parameter sets (RFC 8554 tables 1 and 2, SP 800-208
section 4):
LMOTS_SHA256_N32_W8  (p = 34, ls = 0, w = 8, n = 32)
LMS_SHA256_M32_H5    (h = 5, m = 32)

Requirements traceability:
- HLR-SEC-LMS: Post-quantum LMS signature verification

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

### type LMS_Signature

```ada
subtype LMS_Signature is Byte_Array (1 .. LMS_Sig_Length);
```

> u32str(q) || lmots_signature || u32str(type) || path[0..h-1]

### type N_String

```ada
subtype N_String is Byte_Array (1 .. N_Length);
```

### type OTS_Private_Key

```ada
type OTS_Private_Key is array (0 .. P - 1) of N_String;
```

### type OTS_Signature

```ada
subtype OTS_Signature is Byte_Array (1 .. 4 + N_Length * (P + 1));
```

> u32str(type) || C || y[0] .. y[p-1]

### type Public_Key

```ada
type Public_Key is record
OTS_Type : Natural;
I        : Byte_Array (1 .. 16);
T1       : N_String;
end record;
```

## Functions

### function Compute_OTS_Public (I : CRDT.Security.LMS.Byte_Array; Q : Standard.Natural; X : CRDT.Security.LMS.OTS_Private_Key) return CRDT.Security.LMS.N_String `[Pre]`

| Parameter | Description |
|-----------|-------------|
| `I` | 16-byte tree identifier. |
| `Q` | Leaf number. |
| `X` | Private key elements. |

**Returns:** The OTS public key K.

### function Hash_LMS_Node (I : CRDT.Security.LMS.Byte_Array; R : Standard.Natural; D : Standard.Natural; Rest : CRDT.Security.LMS.Byte_Array) return CRDT.Security.LMS.N_String `[Pre]`

| Parameter | Description |
|-----------|-------------|
| `D` | Two-byte domain separator. |
| `I` | 16-byte tree identifier. |
| `R` | Node or leaf number for the security string. |
| `Rest` | Chained value. |

**Returns:** The next chain element.

### function Leaf_Hash (I : CRDT.Security.LMS.Byte_Array; Q : Standard.Natural; OTS_K : CRDT.Security.LMS.N_String) return CRDT.Security.LMS.N_String `[Pre]`

| Parameter | Description |
|-----------|-------------|
| `I` | 16-byte tree identifier. |
| `OTS_K` | OTS public key for that leaf. |
| `Q` | Leaf number. |

**Returns:** The leaf node value.

### function Node_Hash (I : CRDT.Security.LMS.Byte_Array; Node_Num : Standard.Natural; Left : CRDT.Security.LMS.N_String; Right : CRDT.Security.LMS.N_String) return CRDT.Security.LMS.N_String `[Pre]`

| Parameter | Description |
|-----------|-------------|
| `I` | 16-byte tree identifier. |
| `Left` | Left child value. |
| `Node_Num` | Internal node number (1 .. 2^h - 1). |
| `Right` | Right child value. |

**Returns:** The internal node value.

### function OTS_Checksum (Q_Hash : CRDT.Security.LMS.N_String) return Standard.Natural

| Parameter | Description |
|-----------|-------------|
| `Q_Hash` | 32-byte message hash. |

**Returns:** The 16-bit checksum, left-shifted by ls.

### function Verify (Pub : CRDT.Security.LMS.Public_Key; Message : CRDT.Security.LMS.Byte_Array; Sig : CRDT.Security.LMS.LMS_Signature) return Standard.Boolean

| Parameter | Description |
|-----------|-------------|
| `Message` | Signed message bytes. |
| `Pub` | LMS public key. |
| `Sig` | LMS signature. |

**Returns:** True when the signature is valid for this key.

### function Verify_OTS (Pub_Type : Standard.Natural; I : CRDT.Security.LMS.Byte_Array; Q : Standard.Natural; Message : CRDT.Security.LMS.Byte_Array; Sig : CRDT.Security.LMS.OTS_Signature; Expected_K : CRDT.Security.LMS.N_String) return Standard.Boolean `[Pre]`

| Parameter | Description |
|-----------|-------------|
| `Expected_K` | Expected OTS public key K for this leaf. |
| `I` | 16-byte tree identifier. |
| `Message` | Signed message bytes. |
| `Pub_Type` | Expected LM-OTS typecode. |
| `Q` | Leaf number. |
| `Sig` | LM-OTS signature. |

**Returns:** True when the signature completes to Expected_K.
