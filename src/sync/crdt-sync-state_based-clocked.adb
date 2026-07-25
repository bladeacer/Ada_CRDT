package body CRDT.Sync.State_Based.Clocked with
  SPARK_Mode => On
is

   function Create (Config : Sync_Config) return Replica_State is
   begin
      return Replica_State'
        (Max_Replicas => Config.Max_Replicas,
         Clocks       => (others => <>));
   end Create;

   procedure Merge (Local : in out Replica_State; Remote : Replica_State) is
   begin
      for I in 1 .. Local.Max_Replicas loop
         Local.Clocks (I) := Max (Local.Clocks (I), Remote.Clocks (I));
      end loop;
   end Merge;

   function Compute_Delta (Local : Replica_State;
                            Remote_SV : Clock_Time) return Natural is
      pragma Unreferenced (Local, Remote_SV);
   begin
      return 0;
   end Compute_Delta;

   function Is_Ahead (SV : Clock_Time; TS : Clock_Time) return Boolean is
   begin
      return SV > TS;
   end Is_Ahead;

end CRDT.Sync.State_Based.Clocked;
