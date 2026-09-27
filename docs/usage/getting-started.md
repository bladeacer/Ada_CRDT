# Getting Started

## Install

Install the crate with [Alire](https://alire.ada.dev):

```bash
alr with crdt
```

Include the crate in your project file:

```ada
with "crdt";
```

Alire fetches the GNAT toolchain on the first build. No other dependency is
necessary.

## First PN-Counter

A PN-Counter tracks per-replica increments and decrements. Each replica gets
one actor slot, so memory is fixed by the replica count, not by the operation
count. See [the API reference](../api-docs/crdt-pn_counters.md) for the full
interface.

```ada
with CRDT.Pn_Counters;

procedure Counter_Demo is
   A : CRDT.Pn_Counters.PN_Counter (Max_Actors => 3);
   B : CRDT.Pn_Counters.PN_Counter (Max_Actors => 3);
begin
   CRDT.Pn_Counters.Increment (A, 5, Actor => 1);
   CRDT.Pn_Counters.Increment (B, 2, Actor => 2);

   CRDT.Pn_Counters.Merge (A, B);
   --  CRDT.Pn_Counters.Value (A) is now 7.
end Counter_Demo;
```

`Merge` keeps the larger per-actor entry. The merge is commutative,
associative, and idempotent, so the replicas converge no matter how the
messages reorder or repeat.

## First LWW set

A Last-Writer-Wins set keeps an add and a remove timestamp per element. An
element is present when its add timestamp is greater than its remove
timestamp. Use `CRDT.Lww_Sets`, which accepts any clock strategy:

```ada
with CRDT.Clocks.Vector;
with CRDT.Lww_Sets;

procedure Set_Demo is
   package V is new CRDT.Clocks.Vector (Max_Replicas => 4);

   package S is new CRDT.Lww_Sets
     (Element_Type => Integer,
      Max_Set_Size => 100,
      Clock        => V.Clock_Time,
      Clk_Kind     => CRDT.Clocks.Clock_Vector,
      ">"          => V.">",
      Max          => V.Max,
      Write_Clock  => V.Write_Clock,
      Read_Clock   => V.Read_Clock);

   Set : S.LWW_Clocked_Set (Capacity => 100);
   TS  : V.Clock_Time := (others => 0);
begin
   S.Add (Set, 42, TS);
end Set_Demo;
```

The [clock strategies page](clock-strategies.md) explains how to choose the
clock. The deprecated `CRDT.Lww_Element_Sets` package stays available for
existing code; new code must use `CRDT.Lww_Sets`.

## First sync loop

A minimal replica pair merges the remote state on every receive. The
[state-based sync layer](sync.md) holds the full lifecycle:

```ada
with CRDT.Sync.State_Based;

procedure Sync_Demo is
   Config : CRDT.Sync.State_Based.Sync_Config :=
     (Max_Replicas => 4, Delta_Sync => True, HLC_Node => 1);

   Local  : CRDT.Sync.State_Based.Replica_State :=
     CRDT.Sync.State_Based.Create (Config);
   Remote : CRDT.Sync.State_Based.Replica_State :=
     CRDT.Sync.State_Based.Create (Config);
begin
   --  On every receive from a peer:
   CRDT.Sync.State_Based.Merge (Local, Remote);
end Sync_Demo;
```

Containers and sync layers compose: put the set or counter in your replica
record, call `Merge` on both the container and the sync state, and the
replica state converges.

## Build and test your project

```bash
alr build
```

Every container uses pre-allocated bounded storage. Size the `Capacity` and
`Max_Actors` discriminants to your worst-case replica and element counts,
and the library allocates no heap at run time.
