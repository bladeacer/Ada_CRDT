# Security: SHA-256, HMAC, and LMS verification

The `CRDT.Security` packages add integrity and authenticity to replica
state exchange. Three packages, three levels:

| Package | Level | Basis |
|---------|-------|-------|
| `CRDT.Security.SHA256` | Detects corrupted or tampered state | FIPS 180-4 |
| `CRDT.Security.HMAC` | Proves the sender holds a shared key | RFC 2104 |
| `CRDT.Security.LMS` | Proves the state carries a signature from the key holder | RFC 8554, NIST SP 800-208 |

All three packages use no heap and run in constant-bounded memory. See
[the API reference](../api-docs/index.md) for the full signatures.

## SHA-256 integrity

Hash the state before you send it and compare the digest after you receive
it. This detects transmission faults and accidental corruption:

```ada
with CRDT.Security.SHA256;

procedure Integrity_Demo is
   package SHA renames CRDT.Security.SHA256;

   Ctx : SHA.Context;
   D1  : SHA.Hash;
   D2  : SHA.Hash;
begin
   SHA.Init (Ctx);
   SHA.Update (Ctx, State_Bytes);
   SHA.Final (Ctx, D1);
   --  Send State_Bytes and D1.  The receiver repeats the two steps
   --  into D2 and compares D1 with D2.
   null;
end Integrity_Demo;
```

`Digest` is the one-shot form of the same three steps. The streaming form
lets you hash state piece by piece without a joined buffer.

## HMAC-SHA-256 authentication

An HMAC proves that the sender holds a key that the receiver also holds. Use
it when every replica shares one symmetric key (a psk-style deployment):

```ada
with CRDT.Security.HMAC;

procedure Auth_Demo is
   package H renames CRDT.Security.HMAC;

   T : H.Tag;
begin
   H.Compute (Key => My_Key, Message => State_Bytes, Out_Tag => T);
   --  Send State_Bytes and T.  The receiver recomputes and calls
   --  H.Equal (T_Received, T_Recomputed).
end Auth_Demo;
```

`HMAC.Equal` compares the two tags in time that depends only on the tag
length, so the comparison does not leak where the first difference is. An
HMAC authenticates the sender only to holders of the same key; it does not
prove origin to a third party. For that, use LMS.

## LMS signature verification

LMS is a stateful hash-based signature scheme (RFC 8554). Its security
rests only on the pre-image resistance of SHA-256, so a quantum computer
does not break it the way it breaks RSA and ECDSA. This library verifies
signatures only. Signing needs stateful one-time private keys that must
never be reused, and this library never holds secret key state.

The deployment model:

- A hardware token or a signing service signs the replica state offline.
- Each replica verifies with the public key before it accepts a `Merge`.
- The verifier holds `CRDT.Security.LMS.Public_Key` only: the tree
  identifier, the OTS typecode, and the root hash `T1`.

```ada
with CRDT.Security.LMS;

procedure Verify_Demo is
   package L renames CRDT.Security.LMS;

   Accepted : constant Boolean :=
     L.Verify (Pub => Pub, Message => State_Bytes, Sig => Sig);
begin
   if not Accepted then
      --  Reject the state.  Do not merge it.
      null;
   end if;
end Verify_Demo;
```

The supported parameter sets are `LMOTS_SHA256_N32_W8` (p = 34, w = 8) and
`LMS_SHA256_M32_H5` (height 5). The package also exposes the reference
primitives (`Compute_OTS_Public`, `Leaf_Hash`, `Node_Hash`,
`Hash_LMS_Node`, `OTS_Checksum`) so a provisioning tool can derive and check
public-key material without holding secrets.

## Key provisioning guidance

- Give every replica the LMS public key out of band, through the channel
  that distributes your trust anchors.
- Keep signing keys in the token or service that signs. Never copy them to
  replicas.
- Use one leaf of the H5 tree per signature, and advance the leaf index
  monotonically. Reusing a leaf lets an attacker forge signatures for that
  leaf.
- Rotate keys by publishing a new public key and switching replicas in a
  bounded window.
- For HMAC deployments, give each replica pair a key of at least 32 bytes
  and never reuse the key across deployment environments.

The test vectors come from RFC 4231 (HMAC) and the RFC 8554 worked examples.
See the normative reference list in
[the third-party notices](../THIRD_PARTY_NOTICES.md).

## See also

- [Sync layers](sync.md) -- authenticate a message before you apply it.
- [Third-party notices](../THIRD_PARTY_NOTICES.md) -- the normative references
  for the test vectors.
- [API reference](../api-docs/index.md) -- the exact package contracts.
