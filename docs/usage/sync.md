# Sync layers: state-based and operation-based

The library ships two sync layers. Both are CRDT-correct: replicas converge
no matter how messages reorder, repeat, or pause. They differ in what they
send over the network and what they demand from the transport.

| Layer | Package | Sends | Network fit |
|-------|---------|-------|-------------|
| State-based (CvRDT) | `CRDT.Sync.State_Based` | Full state or a delta | Lossy or unordered links; UDP, mesh, radio |
| Operation-based (CmRDT) | `CRDT.Sync.Op_Based` | Individual operations | Ordered, reliable links; TCP, WebSockets |

See [the API reference](../api-docs/crdt-sync-state_based.md) and
[the op-based reference](../api-docs/crdt-sync-op_based.md) for the full
contracts.

## State-based sync

A state-based replica merges the whole remote state into its own state. The
merge is idempotent, so a repeated delivery does no harm, and it needs no
delivery order. This makes the layer the most robust choice on unstable
links.

```ada
with CRDT.Sync.State_Based;

procedure State_Demo is
   Config : CRDT.Sync.State_Based.Sync_Config :=
     (Max_Replicas => 4, Delta_Sync => True, HLC_Node => 1);

   Local  : CRDT.Sync.State_Based.Replica_State :=
     CRDT.Sync.State_Based.Create (Config);
   Remote : CRDT.Sync.State_Based.Replica_State :=
     CRDT.Sync.State_Based.Create (Config);
begin
   CRDT.Sync.State_Based.Merge (Local, Remote);
end State_Demo;
```

With `Delta_Sync` enabled, `Compute_Delta` counts how many vector-clock
entries the remote peer lags behind. Send only the entries the peer misses.
The HLC in each state keeps wall-clock-friendly timestamps that still respect
causality; see [the clock strategies page](clock-strategies.md).

## Operation-based sync

An operation-based replica appends each mutation to a bounded log and sends
the operation itself. The payload per change is small, but the transport
must deliver every operation exactly once and in causal order. A downstream
replica applies each operation once.

```ada
with CRDT.Sync.Op_Based;

procedure Op_Demo is
   Log : CRDT.Sync.Op_Based.Op_Log (Capacity => 1000);
begin
   CRDT.Sync.Op_Based.Append
     (Log, (Kind => CRDT.Sync.Op_Based.Op_Insert,
            Seq  => 1, Node => 1, Position => 1));

   CRDT.Sync.Op_Based.Acknowledge (Log, Up_To_Seq => 1);
   CRDT.Sync.Op_Based.Compact (Log);
end Op_Demo;
```

## The acknowledgement and purge lifecycle

The log is bounded, so acknowledged operations must leave it to free space
for new ones. The layer gives you two ways to manage that lifecycle.

### Single-peer acknowledge

With one peer (or when the application tracks delivery itself), use the
pair that the header documents:

- `Acknowledge (Log, Up_To_Seq)` marks every operation up to `Seq` as
  delivered.
- `Compact (Log)` physically removes the acknowledged prefix.

### Causal purge across peers

With several peers, an operation is safe to release only when every peer has
confirmed delivery of it. Use the peer watermark pair:

- `Acknowledge_From (Log, Peer, From_Seq)` records the highest `Seq` that
  one peer confirmed. The first call registers the peer. The table holds a
  fixed eight peers; peers outside it are ignored.
- `Purge_Acknowledged (Log)` computes the purge frontier as the minimum over
  the registered peer watermarks, releases the prefix below it, and compacts
  the storage. It leaves the watermark table intact, so the frontier keeps
  advancing monotonically.
- `Min_Unacked_Seq (Log)` reports that frontier: the smallest `Seq` that at
  least one registered peer has not confirmed. It returns 0 when no peer has
  registered or when everything is confirmed.

Follow this lifecycle:

1. On every delivery confirmation from peer `P`, call
   `Acknowledge_From (Log, P, Seq)`.
2. On your housekeeping interval, call `Purge_Acknowledged (Log)`.
3. Before you retire a peer, keep acknowledging on its behalf until it
   confirms, or rebuild the log. A peer that never confirms blocks the
   frontier at its own watermark.

## Choosing a layer

Choose the state-based layer when the link can lose or reorder messages and
you want the simplest correct receiver. Choose the operation-based layer when
the transport is ordered and reliable and bandwidth is the scarce resource.
Containers compose with either layer: merge the containers with the same
cadence as the sync state. The
[serialization page](serialization.md) explains how the wire format carries
either layer's payloads.

## See also

- [Containers, wrappers, and the hybrid logical clock](containers-and-wrappers.md)
  -- take a `Snapshot` of a protected container and send it with `Merge`.
- [Serialisation](serialization.md) -- the wire formats for both layers.
- [Security](security.md) -- authenticate a message before you apply it.
