package body CRDT.Sync.State_Based
  with SPARK_Mode => On
is

   function Create (Config : Sync_Config) return Replica_State with SPARK_Mode => Off is
   begin
      return Replica_State'(Max_Replicas => Config.Max_Replicas, HLC_Clock => CRDT.HLC.Create (Config.HLC_Node), SV => (others => 0));
   end Create;

   procedure Merge (Local : in out Replica_State; Remote : Replica_State) is
   begin
      if Local.SV'Length = Remote.SV'Length then
         CRDT.Core.VTime_Merge (Local.SV, Remote.SV);
      end if;
   end Merge;

   function Compute_Delta (Local : Replica_State; Remote_SV : Core.VTime) return Natural is
      Result : Natural := 0;
   begin
      if Local.SV'Length /= Remote_SV'Length or else Remote_SV'First /= Local.SV'First then
         return 0;
      end if;
      for I in Local.SV'Range loop
         if Local.SV (I) > Remote_SV (I) then
            Result := Result + 1;
         end if;
         pragma Loop_Invariant (Result <= (I - Local.SV'First + 1));
      end loop;
      return Result;
   end Compute_Delta;

   function Is_Ahead (SV : Core.VTime; TS : Core.Lamport_Time) return Boolean is
   begin
      if TS.Stamp = 0 then
         return False;
      end if;
      for I in SV'Range loop
         pragma Loop_Invariant (for all J in SV'First .. I - 1 => Natural (SV (J)) < TS.Stamp);
         if Natural (SV (I)) >= TS.Stamp then
            return True;
         end if;
      end loop;
      return False;
   end Is_Ahead;

end CRDT.Sync.State_Based;
