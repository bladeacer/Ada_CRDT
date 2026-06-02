package body Ada_CRDT.Protected is

   ---------------------
   -- Shared_PN_Counter
   ---------------------

   protected body Shared_PN_Counter is

      procedure Increment (By    : Natural := 1;
                           Actor : Core.Replica_Id) is
      begin
         Pn_Counters.Increment (C, By, Actor);
      end Increment;

      procedure Decrement (By    : Natural := 1;
                           Actor : Core.Replica_Id) is
      begin
         Pn_Counters.Decrement (C, By, Actor);
      end Decrement;

      procedure Merge (Source : Pn_Counters.PN_Counter) is
      begin
         Pn_Counters.Merge (C, Source);
      end Merge;

      function Value return Integer is
      begin
         return Pn_Counters.Value (C);
      end Value;

      function Snapshot return Pn_Counters.PN_Counter is
      begin
         return C;
      end Snapshot;

   end Shared_PN_Counter;

   ---------------------
   -- Shared_LWW
   ---------------------

   package body Shared_LWW is

      protected body Shared_Set is

         procedure Add (E  : Element_Type;
                        TS : Core.Lamport_Time) is
         begin
            LWW_Pkg.Add (S, E, TS);
         end Add;

         procedure Remove (E  : Element_Type;
                           TS : Core.Lamport_Time) is
         begin
            LWW_Pkg.Remove (S, E, TS);
         end Remove;

         procedure Merge (Source : LWW_Pkg.LWW_Element_Set) is
         begin
            LWW_Pkg.Merge (S, Source);
         end Merge;

         function Contains (E : Element_Type) return Boolean is
         begin
            return LWW_Pkg.Contains (S, E);
         end Contains;

         function Snapshot return LWW_Pkg.LWW_Element_Set is
         begin
            return S;
         end Snapshot;

      end Shared_Set;

   end Shared_LWW;

   ---------------------
   -- Shared_RGA
   ---------------------

   package body Shared_RGA is

      protected body Shared_RGA_Obj is

         procedure Insert (Pos   : Positive;
                           Id    : RGA_Pkg.Node_Id;
                           Value : Element_Type) is
         begin
            RGA_Pkg.Insert (R, Pos, Id, Value);
         end Insert;

         procedure Insert_Bulk (Pos    : Positive;
                                Id     : RGA_Pkg.Node_Id;
                                Values : RGA_Pkg.Element_Array) is
         begin
            RGA_Pkg.Insert_Bulk (R, Pos, Id, Values);
         end Insert_Bulk;

         procedure Delete (Pos : Positive) is
         begin
            RGA_Pkg.Delete (R, Pos);
         end Delete;

         procedure Merge (Source : RGA_Pkg.RGA) is
         begin
            RGA_Pkg.Merge (R, Source);
         end Merge;

         procedure Compact is
         begin
            RGA_Pkg.Compact (R);
         end Compact;

         function Get (Pos : Positive) return Element_Type is
         begin
            return RGA_Pkg.Get (R, Pos);
         end Get;

         function Size return Natural is
         begin
            return RGA_Pkg.Size (R);
         end Size;

         function Snapshot return RGA_Pkg.RGA is
         begin
            return R;
         end Snapshot;

      end Shared_RGA_Obj;

   end Shared_RGA;

end Ada_CRDT.Protected;
