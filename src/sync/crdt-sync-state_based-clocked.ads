with Ada.Streams;
with CRDT.Clocks;

--  Generic state-based sync engine parameterised over any clock strategy.
--  Mirrors the interface of CRDT.Sync.State_Based but uses the provided
--  clock strategy's Clock_Time for replica state tracking instead of a
--  hardcoded VTime + HLC.
--
--  The state vector is an array of Clock_Time values, one per replica slot.
--  Merge applies Max element-wise.  Comparison operations use the
--  strategy's "<", "=", ">" operators.
--
--  Requirements traceability:
--  - HLR-SYNC-STATE: State-based sync with vector clocks
--  - HLR-SYNC-DELTA: Delta computation for partial state exchange
--
--  @formal Clock_Time  Timestamp type from a clock strategy.
--  @formal "<"         Clock less-than comparison.
--  @formal "="         Clock equality comparison.
--  @formal ">"         Clock greater-than comparison.
--  @formal Max         Element-wise maximum for merge.
--  @formal Write_Clock Serialise a clock timestamp.
--  @formal Read_Clock  Deserialise a clock timestamp.

generic
   type Clock_Time is private;
   with function "<" (L, R : Clock_Time) return Boolean is <>;
   with function "=" (L, R : Clock_Time) return Boolean is <>;
   with function ">" (L, R : Clock_Time) return Boolean is <>;
   with function Max (L, R : Clock_Time) return Clock_Time;
   with procedure Write_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : Clock_Time) is <>;
   with procedure Read_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Clock_Time) is <>;
package CRDT.Sync.State_Based.Clocked with SPARK_Mode is

   --  Configuration for a clocked state-based sync session.
   type Sync_Config is record
      Max_Replicas : Positive := 32;
      Delta_Sync   : Boolean := True;
   end record;

   --  Per-replica tracked state using the generic clock time.
   type Replica_State (Max_Replicas : Positive) is private;

   --  Create initial state where every replica clock is default-initialised.
   --  @param Config  Sync configuration.
   --  @return  Freshly initialized replica state.
   function Create (Config : Sync_Config) return Replica_State;

   --  Merge remote state into local state using element-wise Max.
   --  Both states must use the same Max_Replicas configuration.
   --  @param Local   Local state to update.
   --  @param Remote  Remote state to merge from.
   procedure Merge (Local : in out Replica_State; Remote : Replica_State)
   with Pre => Local.Max_Replicas = Remote.Max_Replicas, Depends => (Local => (Local, Remote));

   --  Compute delta: how many local clocks are ahead of the remote's clock.
   --  Counts entries in Local.Clocks that exceed Remote_SV.
   --  @param Local      Local replica state.
   --  @param Remote_SV  Remote clock timestamp.
   --  @return  Count of replicas where local clock is ahead of remote.
   function Compute_Delta (Local : Replica_State; Remote_SV : Clock_Time) return Natural;

   --  Check if a state vector has advanced past a given clock timestamp.
   --  @param SV  State vector to check.
   --  @param TS  Clock timestamp to compare against.
   --  @return  True if any entry in the SV is at or past TS.
   function Is_Ahead (SV : Clock_Time; TS : Clock_Time) return Boolean;

private

   type Clock_Array is array (Positive range <>) of Clock_Time;

   type Replica_State (Max_Replicas : Positive) is record
      Clocks : Clock_Array (1 .. Max_Replicas);
   end record;

end CRDT.Sync.State_Based.Clocked;
