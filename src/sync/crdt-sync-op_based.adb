package body CRDT.Sync.Op_Based
  with SPARK_Mode => On
is

   procedure Append (Log : in out Op_Log; Op : Operation) is
   begin
      if Log.Count < Log.Capacity then
         Log.Count := Log.Count + 1;
         Log.Ops (Log.Count) := Op;
      end if;
   end Append;

   function Size (Log : Op_Log) return Natural is
   begin
      if Log.GC <= Log.Count then
         return Log.Count - Log.GC;
      end if;
      return 0;
   end Size;

   function Get (Log : Op_Log; Index : Positive) return Operation is
   begin
      if Index <= Log.Capacity and then Log.GC <= Log.Capacity - Index then
         return Log.Ops (Log.GC + Index);
      end if;
      return Log.Ops (1);
   end Get;

   procedure Acknowledge (Log : in out Op_Log; Up_To_Seq : Natural) is
   begin
      while Log.GC < Log.Count and then Log.GC + 1 <= Log.Capacity and then Log.Ops (Log.GC + 1).Seq <= Up_To_Seq loop
         Log.GC := Log.GC + 1;
      end loop;
   end Acknowledge;

   procedure Compact (Log : in out Op_Log) is
      New_Count : Natural := 0;
      Old_GC    : constant Natural := Log.GC;
      Old_Count : constant Natural := Log.Count;
   begin
      if Log.GC < Log.Count then
         for I in Log.GC + 1 .. Log.Count loop
            pragma Loop_Invariant (New_Count = I - (Log.GC + 1));
            pragma Loop_Invariant (New_Count + 1 <= Log.Count - Log.GC);
            New_Count := New_Count + 1;
            Log.Ops (New_Count) := Log.Ops (I);
         end loop;
      end if;
      Log.Count := New_Count;
      Log.GC := 0;
      pragma Assert (Log.GC = 0);
      pragma Assert (Log.Count = Old_Count - Old_GC);
      pragma Assert (Log.Count <= Log.Capacity);
   end Compact;

   procedure Acknowledge_From (Log : in out Op_Log; Peer : Core.Replica_Id; From_Seq : Natural) is
   begin
      --  Record the per-peer watermark (fixed 8-slot array; out-of-range
      --  peers are ignored rather than resized).
      if Peer in Log.Peer_Acks'Range and then From_Seq > Log.Peer_Acks (Peer) then
         Log.Peer_Acks (Peer) := From_Seq;
      end if;
      --  The purge frontier is the minimum across all peers: every
      --  operation at or below it is delivered to every peer.
      declare
         Min_Ack : Natural := Natural'Last;
      begin
         for P in Log.Peer_Acks'Range loop
            pragma Loop_Invariant (Min_Ack >= 0);
            if Log.Peer_Acks (P) < Min_Ack then
               Min_Ack := Log.Peer_Acks (P);
            end if;
         end loop;
         if Min_Ack < Natural'Last and then Min_Ack > 0 then
            --  Move the GC watermark forward over the safely
            --  acknowledged prefix (ops are stored in Seq order).
            while Log.GC < Log.Count and then Log.GC + 1 <= Log.Capacity and then Log.Ops (Log.GC + 1).Seq <= Min_Ack loop
               Log.GC := Log.GC + 1;
            end loop;
         end if;
      end;
   end Acknowledge_From;

   procedure Purge_Acknowledged (Log : in out Op_Log) is
      New_Count : Natural := 0;
      Old_GC    : constant Natural := Log.GC;
      Old_Count : constant Natural := Log.Count;
   begin
      --  Same shift as Compact, but keep the GC watermark raised so the
      --  purged prefix stays excluded from Size/Get accounting.
      if Log.GC < Log.Count then
         for I in Log.GC + 1 .. Log.Count loop
            pragma Loop_Invariant (New_Count = I - (Log.GC + 1));
            pragma Loop_Invariant (New_Count + 1 <= Log.Count - Log.GC);
            New_Count := New_Count + 1;
            Log.Ops (New_Count) := Log.Ops (I);
         end loop;
      end if;
      Log.Count := New_Count;
      pragma Assert (Log.Count = Old_Count - Old_GC);
      pragma Assert (Log.GC <= Log.Count);
   end Purge_Acknowledged;

   function Min_Unacked_Seq (Log : Op_Log) return Natural is
      Min_Ack : Natural := Natural'Last;
   begin
      for P in Log.Peer_Acks'Range loop
         pragma Loop_Invariant (Min_Ack >= 0);
         if Log.Peer_Acks (P) < Min_Ack then
            Min_Ack := Log.Peer_Acks (P);
         end if;
      end loop;
      if Min_Ack = Natural'Last then
         return 0;
      end if;
      --  First Seq not covered by the per-peer watermark minimum.
      return Min_Ack + 1;
   end Min_Unacked_Seq;

end CRDT.Sync.Op_Based;
