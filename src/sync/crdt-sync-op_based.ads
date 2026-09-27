--  Operation-Based (CmRDT) sync engine.
--  Replicas broadcast granular, immutable mutation events.
--  Downstream operations must be applied exactly once.
--
--  Network trait: Hyper-low bandwidth consumption, ideal for
--  ordered delivery channels (WebSockets, TCP/TLS streams).
--
--  Requirements traceability:
--  - HLR-SYNC-OP: Operation-based sync with bounded log
--  - HLR-SYNC-ACK: Acknowledge + compact processed operations
with CRDT.Core;

package CRDT.Sync.Op_Based
  with SPARK_Mode
is

   --  Kind of operation for discriminated record.
   type Op_Kind is (Op_Insert, Op_Delete, Op_Increment, Op_Decrement);

   --  A single mutation operation for replication.
   --  @field Seq      Monotonic sequence number.
   --  @field Node     Replica that generated this operation.
   --  @field Kind     Discriminant: which variant is active.
   --  @field Position Insertion position (for Op_Insert).
   --  @field Del_Position  Deletion position (for Op_Delete).
   --  @field Amount   Increment/decrement amount.
   --  @field Actor    Target replica for counter ops.
   type Operation (Kind : Op_Kind := Op_Insert) is record
      Seq  : Natural;
      Node : Core.Replica_Id;
      case Kind is
         when Op_Insert =>
            Position : Positive;

         when Op_Delete =>
            Del_Position : Positive;

         when Op_Increment | Op_Decrement =>
            Amount : Natural;
            Actor  : Core.Replica_Id;
      end case;
   end record;

   --  Bounded operation log for buffering outgoing operations.
   type Op_Log (Capacity : Positive) is private;

   --  Return the total entry count (including GC'd).
   --  @param Log  Operation log to query.
   --  @return Total number of entries written.
   function Log_Count (Log : Op_Log) return Natural
   with Post => Log_Count'Result <= Log.Capacity;

   --  Return the GC watermark.
   --  @param Log  Operation log to query.
   --  @return Number of acknowledged (GC'd) entries.
   function Log_GC (Log : Op_Log) return Natural
   with Post => Log_GC'Result <= Log.Capacity;

   --  Append an operation to the log.
   --  Does nothing if the log is full.
   --  @param Log  Operation log to append to.
   --  @param Op   Operation to record.
   procedure Append (Log : in out Op_Log; Op : Operation)
   with Post => Log_Count (Log) <= Log.Capacity, Depends => (Log => (Log, Op));

   --  Number of unacknowledged operations.
   --  @param Log  Operation log to query.
   --  @return Count of operations not yet acknowledged.
   function Size (Log : Op_Log) return Natural;

   --  Get operation at index (1-based, excluding GC'd).
   --  @param Log    Operation log to query.
   --  @param Index  1-based index.
   --  @return Operation at that index (first log entry if out of bounds).
   function Get (Log : Op_Log; Index : Positive) return Operation;

   --  Mark operations up to Seq as acknowledged (ready for GC).
   --  @param Log       Operation log to modify.
   --  @param Up_To_Seq  Acknowledge all operations with Seq <= this.
   procedure Acknowledge (Log : in out Op_Log; Up_To_Seq : Natural)
   with Post => Log_GC (Log) <= Log_Count (Log), Depends => (Log => (Log, Up_To_Seq));

   --  Compact the log and physically remove acknowledged operations.
   --  @param Log  Operation log to compact.
   procedure Compact (Log : in out Op_Log)
   with Post => Log_GC (Log) = 0 and then Log_Count (Log) <= Log.Capacity, Depends => (Log => Log);

   --  Raise the acknowledgement watermark for one peer and move the
   --  purge frontier to the smallest registered-peer watermark.  The
   --  causal prefix up to the frontier is safe to purge because every
   --  registered peer has confirmed delivery of it.
   --  Contract: call this for every live peer.  A peer registers on
   --  its first call; peers outside the fixed 8-slot table are
   --  ignored.  Retiring a peer means the application keeps
   --  acknowledging on its behalf or rebuilds the log.
   --  @param Log        Operation log to update.
   --  @param Peer       Peer whose watermark to record.
   --  @param From_Seq   The peer confirmed delivery up to this Seq.
   procedure Acknowledge_From (Log : in out Op_Log; Peer : Core.Replica_Id; From_Seq : Natural)
   with Depends => (Log => (Log, Peer, From_Seq));

   --  Physically remove every operation acknowledged by all
   --  registered peers.  Purge recomputes the causal frontier from the
   --  per-peer watermark table itself (the minimum over registered
   --  peers), releases that prefix, and compacts the storage.  It is
   --  the companion of Acknowledge_From for callers that want the
   --  frontier to be derived from the peer table rather than from the
   --  GC marker, and it leaves the watermark table intact so the
   --  frontier keeps advancing monotonically.
   --  @param Log  Operation log to purge.
   procedure Purge_Acknowledged (Log : in out Op_Log)
   with Post => Log_GC (Log) = 0 and then Log_Count (Log) <= Log.Capacity, Depends => (Log => Log);

   --  Smallest Seq that is still unacknowledged by at least one
   --  registered peer (the purge frontier).  0 when no peer has
   --  registered or when every logged operation is acknowledged by
   --  every registered peer.
   --  @param Log  Operation log to query.
   --  @return The purge frontier sequence number.
   function Min_Unacked_Seq (Log : Op_Log) return Natural;

private

   type Op_Array is array (Positive range <>) of Operation;

   --  Registered-peer flags (fixed 8-peer table).
   type Boolean_Array is array (Positive range <>) of Boolean;

   type Op_Log (Capacity : Positive) is record
      Ops         : Op_Array (1 .. Capacity);
      Count       : Natural := 0;
      GC          : Natural := 0;
      --  Highest Seq each registered peer has confirmed, and which
      --  slots are registered.  Causal-history purge uses the minimum
      --  over registered peers as the purge frontier.  A peer becomes
      --  registered on its first Acknowledge_From call.  May change
      --  between minor versions (internal state).
      Peer_Acks   : Core.VTime (1 .. 8) := (others => 0);
      Peer_Active : Boolean_Array (1 .. 8) := (others => False);
   end record
   with Type_Invariant => GC <= Count and then Count <= Capacity;

   --  Expression function for SPARK visibility. See public spec for docs.
   --  @param Log  Operation log to query.
   --  @return Total number of entries written.
   function Log_Count (Log : Op_Log) return Natural
   is (Log.Count);
   --  Expression function for SPARK visibility. See public spec for docs.
   --  @param Log  Operation log to query.
   --  @return Number of acknowledged (GC'd) entries.
   function Log_GC (Log : Op_Log) return Natural
   is (Log.GC);

end CRDT.Sync.Op_Based;
