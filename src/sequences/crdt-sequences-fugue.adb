with Ada.Streams;
with CRDT.Clocks;
with CRDT.Core.LEB128;
with CRDT.Serialization;

package body CRDT.Sequences.Fugue
  with SPARK_Mode => Off
is

   use type Core.Replica_Id;

   function Id_Less (Left, Right : Node_Id) return Boolean is
   begin
      if Left.Depth /= Right.Depth then
         return Left.Depth < Right.Depth;
      end if;
      if Left.Seq /= Right.Seq then
         return Left.Seq < Right.Seq;
      end if;
      return Left.Replica < Right.Replica;
   end Id_Less;

   function Id_Eq (Left, Right : Node_Id) return Boolean
   is (Left.Replica = Right.Replica and then Left.Seq = Right.Seq and then Left.Depth = Right.Depth);

   function Alloc_Item (R : in out RGA) return Natural is
      Idx : Natural;
   begin
      if R.Free /= 0 then
         Idx := R.Free;
         R.Free := R.Items (R.Free).Right;
         R.Items (Idx).Right := 0;
         R.Items (Idx).Left := 0;
         R.Items (Idx).Parent := 0;
         return Idx;
      elsif R.Count < R.Capacity then
         R.Count := R.Count + 1;
         return R.Count;
      end if;
      return 0;
   end Alloc_Item;

   function Inorder_First (R : RGA; Start : Natural) return Natural;
   function Inorder_Next (R : RGA; Idx : Natural) return Natural;

   function Inorder_First (R : RGA; Start : Natural) return Natural is
      Cur : Natural := Start;
   begin
      if Cur = 0 then
         return 0;
      end if;
      while R.Items (Cur).Left /= 0 loop
         Cur := R.Items (Cur).Left;
      end loop;
      return Cur;
   end Inorder_First;

   function Inorder_Next (R : RGA; Idx : Natural) return Natural is
      Cur : Natural := Idx;
   begin
      if R.Items (Cur).Right /= 0 then
         return Inorder_First (R, R.Items (Cur).Right);
      end if;
      loop
         if R.Items (Cur).Parent = 0 then
            return 0;
         end if;
         if R.Items (R.Items (Cur).Parent).Left = Cur then
            return R.Items (Cur).Parent;
         end if;
         Cur := R.Items (Cur).Parent;
      end loop;
   end Inorder_Next;

   function Inorder_Pos (R : RGA; Pos : Positive) return Natural is
      Cur : Natural := Inorder_First (R, R.Root);
      P   : Natural := Pos;
   begin
      while Cur /= 0 and then P > 1 loop
         P := P - 1;
         Cur := Inorder_Next (R, Cur);
      end loop;
      return Cur;
   end Inorder_Pos;

   function Find_Node (R : RGA; Id : Node_Id) return Natural is
      Cur : Natural := Inorder_First (R, R.Root);
   begin
      while Cur /= 0 loop
         if Id_Eq (R.Items (Cur).Id, Id) then
            return Cur;
         end if;
         Cur := Inorder_Next (R, Cur);
      end loop;
      return 0;
   end Find_Node;

   function Copy_Item (R : in out RGA; Src : RGA_Item) return Natural is
      Idx : constant Natural := Alloc_Item (R);
   begin
      if Idx > 0 then
         R.Items (Idx) := Src;
         R.Items (Idx).Left := 0;
         R.Items (Idx).Right := 0;
         R.Total := R.Total + 1;
      end if;
      return Idx;
   end Copy_Item;

   -- Iterator
   function Has_Element (Position : Cursor) return Boolean is
   begin
      return Position.Pos in 1 .. Position.Total;
   end Has_Element;

   function Has_Element (Container : RGA; Position : Cursor) return Boolean is
   begin
      return Position.Pos in 1 .. Container.Total;
   end Has_Element;

   function First (Container : RGA) return Cursor is
   begin
      if Container.Total = 0 then
         return Cursor'(Total => 0, Pos => 0);
      end if;
      return Cursor'(Total => Container.Total, Pos => 1);
   end First;

   procedure Next (Container : RGA; Position : in out Cursor) is
   begin
      if Position.Pos < Container.Total then
         Position.Pos := Position.Pos + 1;
      else
         Position.Pos := 0;
      end if;
   end Next;

   function Element (Container : RGA; Position : Cursor) return Element_Type is
      Idx : constant Natural := Inorder_Pos (Container, Position.Pos);
   begin
      if Idx = 0 then
         raise Constraint_Error with "Fugue element: position out of range";
      end if;
      return Container.Items (Idx).Value;
   end Element;

   -- Public ops
   function Count (R : RGA) return Natural
   is (R.Count);
   function Size (R : RGA) return Natural
   is (R.Total);

   function Get (R : RGA; Pos : Positive) return Element_Type is
      Idx : constant Natural := Inorder_Pos (R, Pos);
   begin
      if Idx = 0 then
         raise Constraint_Error with "Fugue.Get: position out of range";
      end if;
      return R.Items (Idx).Value;
   end Get;

   procedure Insert (R : in out RGA; Pos : Positive; Id : Node_Id; Value : Element_Type) is
      New_Idx : constant Natural := Alloc_Item (R);
   begin
      if New_Idx = 0 then
         return;
      end if;
      R.Items (New_Idx) := (Id => Id, Value => Value, others => <>);
      R.Total := R.Total + 1;

      if R.Root = 0 then
         R.Root := New_Idx;
         return;
      end if;

      declare
         Cur : Natural := R.Root;
         Ins : Boolean := False;
      begin
         while not Ins loop
            if Id_Less (Id, R.Items (Cur).Id) then
               if R.Items (Cur).Left = 0 then
                  R.Items (Cur).Left := New_Idx;
                  R.Items (New_Idx).Parent := Cur;
                  Ins := True;
               else
                  Cur := R.Items (Cur).Left;
               end if;
            else
               if R.Items (Cur).Right = 0 then
                  R.Items (Cur).Right := New_Idx;
                  R.Items (New_Idx).Parent := Cur;
                  Ins := True;
               else
                  Cur := R.Items (Cur).Right;
               end if;
            end if;
         end loop;
      end;
   end Insert;

   procedure Insert_Bulk (R : in out RGA; Pos : Positive; Id : Node_Id; Values : Element_Array) is
   begin
      for I in Values'Range loop
         declare
            Bulk_Id : constant Node_Id := (Replica => Id.Replica, Seq => Id.Seq + (I - Values'First), Depth => Id.Depth);
         begin
            Insert (R, Pos + (I - Values'First), Bulk_Id, Values (I));
         end;
      end loop;
   end Insert_Bulk;

   procedure Delete (R : in out RGA; Pos : Positive) is
      Idx : constant Natural := Inorder_Pos (R, Pos);
   begin
      if Idx > 0 then
         R.Items (Idx).Deleted := True;
      end if;
   end Delete;

   procedure Delete_Node (R : in out RGA; Id : Node_Id) is
      Idx : constant Natural := Find_Node (R, Id);
   begin
      if Idx > 0 then
         R.Items (Idx).Deleted := True;
      end if;
   end Delete_Node;

   procedure Merge (Target : in out RGA; Source : RGA) is
      S_Idx : Natural := Inorder_First (Source, Source.Root);
   begin
      while S_Idx /= 0 loop
         if Find_Node (Target, Source.Items (S_Idx).Id) = 0 then
            declare
               New_Idx : constant Natural := Copy_Item (Target, Source.Items (S_Idx));
            begin
               if New_Idx > 0 then
                  -- BST insert by Id order
                  declare
                     Cur : Natural := Target.Root;
                     Ins : Boolean := False;
                  begin
                     while not Ins loop
                        if Id_Less (Source.Items (S_Idx).Id, Target.Items (Cur).Id) then
                           if Target.Items (Cur).Left = 0 then
                              Target.Items (Cur).Left := New_Idx;
                              Target.Items (New_Idx).Parent := Cur;
                              Ins := True;
                           else
                              Cur := Target.Items (Cur).Left;
                           end if;
                        else
                           if Target.Items (Cur).Right = 0 then
                              Target.Items (Cur).Right := New_Idx;
                              Target.Items (New_Idx).Parent := Cur;
                              Ins := True;
                           else
                              Cur := Target.Items (Cur).Right;
                           end if;
                        end if;
                     end loop;
                  end;
               end if;
            end;
         end if;
         S_Idx := Inorder_Next (Source, S_Idx);
      end loop;
   end Merge;

   function "=" (Left, Right : RGA) return Boolean is
      L_Idx : Natural := Inorder_First (Left, Left.Root);
      R_Idx : Natural := Inorder_First (Right, Right.Root);
   begin
      loop
         if L_Idx = 0 and R_Idx = 0 then
            return True;
         end if;
         if L_Idx = 0 or R_Idx = 0 then
            return False;
         end if;
         if Left.Items (L_Idx).Id /= Right.Items (R_Idx).Id or else Left.Items (L_Idx).Value /= Right.Items (R_Idx).Value or else Left.Items (L_Idx).Deleted /= Right.Items (R_Idx).Deleted then
            return False;
         end if;
         L_Idx := Inorder_Next (Left, L_Idx);
         R_Idx := Inorder_Next (Right, R_Idx);
      end loop;
   end "=";

   --  Unlink node Idx from the BST and return it to the free list.
   --  Standard binary-search-tree deletion: a node with two children is
   --  replaced by its in-order successor node (contents swapped), which
   --  has at most one child. Iterative, no recursion, no rebalancing:
   --  the tree shape may degrade but the in-order sequence is preserved,
   --  which is the only property Merge, Get, and iterators rely on.
   procedure Unlink_Node (R : in out RGA; Idx : Natural) is
      Target : Natural := Idx;
      Child  : Natural;
      Sub    : Natural;
   begin
      --  If the target has two children, find its in-order successor
      --  (leftmost node of the right subtree), swap the contents, and
      --  delete the successor instead (it has at most one child).
      if R.Items (Target).Left /= 0 and then R.Items (Target).Right /= 0 then
         Sub := R.Items (Target).Right;
         while R.Items (Sub).Left /= 0 loop
            Sub := R.Items (Sub).Left;
         end loop;
         --  Swap payload contents (links keep their positions).
         declare
            Tmp : constant RGA_Item := R.Items (Target);
         begin
            R.Items (Target) := R.Items (Sub);
            R.Items (Sub) := Tmp;
         end;
         --  Restore the swapped link fields so each node keeps its
         --  place in the tree; only payload (Id, Value, Deleted)
         --  moved between Target and Sub.
         declare
            T_Par : constant Natural := R.Items (Target).Parent;
            T_L   : constant Natural := R.Items (Target).Left;
            T_R   : constant Natural := R.Items (Target).Right;
            S_Par : constant Natural := R.Items (Sub).Parent;
            S_L   : constant Natural := R.Items (Sub).Left;
            S_R   : constant Natural := R.Items (Sub).Right;
         begin
            R.Items (Target).Parent := T_Par;
            R.Items (Target).Left := T_L;
            R.Items (Target).Right := T_R;
            R.Items (Sub).Parent := S_Par;
            R.Items (Sub).Left := S_L;
            R.Items (Sub).Right := S_R;
         end;
         --  Fix the children's parent pointers after the swap.
         if R.Items (Target).Left /= 0 then
            R.Items (R.Items (Target).Left).Parent := Target;
         end if;
         if R.Items (Target).Right /= 0 then
            R.Items (R.Items (Target).Right).Parent := Target;
         end if;
         if R.Items (Sub).Left /= 0 then
            R.Items (R.Items (Sub).Left).Parent := Sub;
         end if;
         if R.Items (Sub).Right /= 0 then
            R.Items (R.Items (Sub).Right).Parent := Sub;
         end if;
         Target := Sub;
      end if;

      --  Now the target has at most one child: splice it out.
      if R.Items (Target).Left /= 0 then
         Child := R.Items (Target).Left;
      else
         Child := R.Items (Target).Right;
      end if;

      declare
         Par : constant Natural := R.Items (Target).Parent;
      begin
         if Child /= 0 then
            R.Items (Child).Parent := Par;
         end if;
         if Par = 0 then
            R.Root := Child;
         elsif R.Items (Par).Left = Target then
            R.Items (Par).Left := Child;
         else
            R.Items (Par).Right := Child;
         end if;
      end;

      --  Return the node to the free list (right pointer is the chain).
      R.Items (Target).Deleted := False;
      R.Items (Target).Id := Node_Id'(Replica => 1, Seq => 0, Depth => 0);
      R.Items (Target).Parent := 0;
      R.Items (Target).Left := 0;
      R.Items (Target).Right := R.Free;
      R.Free := Target;
   end Unlink_Node;

   procedure Compact (R : in out RGA) is
      Cur   : Natural;
      Nxt   : Natural;
      Guard : Natural := 0;
   begin
      --  Collect the nodes to remove first: unlinking swaps contents
      --  and rewrites links, so a live traversal during unlinking
      --  would visit shifted nodes. Two passes keep it correct.
      --  Pass 1: unlink every deleted node by identity.
      for I in 1 .. R.Count loop
         if R.Items (I).Deleted then
            Unlink_Node (R, I);
         end if;
      end loop;
      --  Pass 2: reclaim the unlinked (free-list) nodes.
      Cur := R.Free;
      while Cur /= 0 and then Guard < R.Capacity loop
         Nxt := R.Items (Cur).Right;
         if R.Total > 0 then
            R.Total := R.Total - 1;
         end if;
         Cur := Nxt;
         Guard := Guard + 1;
      end loop;
      --  Clear stale root/parent links pointing at freed slots.
      if R.Root /= 0 and then R.Items (R.Root).Parent = R.Root then
         R.Items (R.Root).Parent := 0;
      end if;
   end Compact;

   procedure Write_RGA (Stream : access Ada.Streams.Root_Stream_Type'Class; Item : RGA) is
      use Ada.Streams;
      Cur : Natural := Inorder_First (Item, Item.Root);
   begin
      Core.LEB128.Encode (Stream, 2);
      Core.LEB128.Encode (Stream, Item.Total);
      Core.LEB128.Encode (Stream, Item.Count);
      while Cur /= 0 loop
         Node_Id'Write (Stream, Item.Items (Cur).Id);
         Boolean'Write (Stream, Item.Items (Cur).Deleted);
         Element_Type'Write (Stream, Item.Items (Cur).Value);
         Cur := Inorder_Next (Item, Cur);
      end loop;
   end Write_RGA;

   procedure Read_RGA (Stream : access Ada.Streams.Root_Stream_Type'Class; Item : out RGA) is
      use Ada.Streams;
      use CRDT.Serialization;
      Kind      : Protocol_Kind;
      Total     : Natural;
      Num_Items : Natural;
      Id        : Node_Id;
      Deleted   : Boolean;
      Val       : Element_Type;
      Ignore_CK : CRDT.Clocks.Clock_Kind;
   begin
      Read_Header (Stream, Kind, Total, Num_Items, Ignore_CK);

      if Num_Items > Item.Capacity then
         raise Constraint_Error with "Fugue Read_RGA: item count" & Natural'Image (Num_Items) & " exceeds capacity" & Natural'Image (Item.Capacity);
      end if;

      Item.Total := Total;
      Item.Root := 0;
      Item.Count := 0;
      Item.Free := 0;

      for J in 1 .. Num_Items loop
         Node_Id'Read (Stream, Id);
         Boolean'Read (Stream, Deleted);
         Element_Type'Read (Stream, Val);
         Insert (Item, J, Id, Val);
         if not Deleted then
            -- mark non-deleted
            null;
         end if;
      end loop;
   end Read_RGA;

end CRDT.Sequences.Fugue;
