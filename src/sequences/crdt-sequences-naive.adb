with Ada.Streams;
with CRDT.Clocks;
with CRDT.Core.LEB128;
with CRDT.Serialization;

package body CRDT.Sequences.Naive
  with SPARK_Mode
is

   use type Core.Replica_Id;

   function Invariant (R : RGA) return Boolean
   is (R.Count <= R.Capacity
       and then (R.Head = 0 or else R.Head in 1 .. R.Capacity)
       and then (R.Free = 0 or else R.Free in 1 .. R.Capacity)
       and then (for all I in 1 .. R.Capacity => R.Items (I).Next in 0 .. R.Capacity));

   function Id_Less (Left, Right : Node_Id) return Boolean
   is (Left.Seq < Right.Seq or else (Left.Seq = Right.Seq and then Left.Replica < Right.Replica));

   function Id_Eq (Left, Right : Node_Id) return Boolean
   is (Left.Replica = Right.Replica and then Left.Seq = Right.Seq);

   procedure Alloc_Item (R : in out RGA; Idx : out Natural) with Pre => Invariant (R), Post => Idx in 0 .. R.Capacity and then Invariant (R) is
   begin
      if R.Free /= 0 then
         Idx := R.Free;
         R.Free := R.Items (R.Free).Next;
         R.Items (Idx).Next := 0;
      elsif R.Count < R.Capacity then
         R.Count := R.Count + 1;
         Idx := R.Count;
      else
         Idx := 0;
      end if;
   end Alloc_Item;

   procedure Free_Item (R : in out RGA; Idx : Natural) with Pre => Idx in 1 .. R.Capacity and then Invariant (R), Post => Invariant (R) is
   begin
      R.Items (Idx).Deleted := False;
      R.Items (Idx).Next := R.Free;
      R.Items (Idx).Id := (Replica => 1, Seq => 0);
      R.Free := Idx;
   end Free_Item;

   procedure New_Item (R : in out RGA; Id : Node_Id; Val : Element_Type; Idx : out Natural) with Pre => Invariant (R), Post => Idx in 0 .. R.Capacity and then Invariant (R) is
   begin
      Alloc_Item (R, Idx);
      if Idx > 0 then
         R.Items (Idx).Id := Id;
         R.Items (Idx).Value := Val;
         if R.Total < R.Capacity then
            R.Total := R.Total + 1;
         end if;
      end if;
   end New_Item;

   procedure Copy_Item (R : in out RGA; Src : RGA_Item; Idx : out Natural) with Pre => Invariant (R), Post => Idx in 0 .. R.Capacity and then Invariant (R) is
   begin
      Alloc_Item (R, Idx);
      if Idx > 0 then
         R.Items (Idx) := Src;
         R.Items (Idx).Next := 0;
         if R.Total < R.Capacity then
            R.Total := R.Total + 1;
         end if;
      end if;
   end Copy_Item;

   function Find_Last (R : RGA) return Natural with Pre => Invariant (R), Post => Find_Last'Result in 0 .. R.Capacity is
      Cur   : Natural := R.Head;
      Steps : Natural := 0;
   begin
      if Cur = 0 then
         return 0;
      end if;
      loop
         pragma Loop_Invariant (Cur in 1 .. R.Capacity and then Steps <= R.Capacity);
         pragma Loop_Variant (Increases => Steps);
         exit when R.Items (Cur).Next = 0 or else Steps >= R.Capacity;
         Cur := R.Items (Cur).Next;
         Steps := Steps + 1;
      end loop;
      return Cur;
   end Find_Last;

   function Find_Node (R : RGA; Id : Node_Id) return Natural with Pre => Invariant (R), Post => Find_Node'Result in 0 .. R.Capacity is
      Cur   : Natural := R.Head;
      Steps : Natural := 0;
   begin
      loop
         pragma Loop_Invariant (Cur in 0 .. R.Capacity and then Steps <= R.Capacity);
         pragma Loop_Variant (Increases => Steps);
         exit when Cur = 0 or else Steps >= R.Capacity;
         if R.Items (Cur).Id = Id then
            return Cur;
         end if;
         Cur := R.Items (Cur).Next;
         Steps := Steps + 1;
      end loop;
      return 0;
   end Find_Node;

   procedure Link_Before (R : in out RGA; Before, New_Idx : Natural) with Pre => Invariant (R) and then Before in 0 .. R.Capacity and then New_Idx in 1 .. R.Capacity, Post => Invariant (R) is
      Cur : Natural;
   begin
      if Before = R.Head then
         R.Items (New_Idx).Next := R.Head;
         R.Head := New_Idx;
      else
         Cur := R.Head;
         while Cur /= 0 and then R.Items (Cur).Next /= Before loop
            pragma Loop_Invariant (Cur in 0 .. R.Capacity);
            Cur := R.Items (Cur).Next;
         end loop;
         if Cur /= 0 then
            R.Items (Cur).Next := New_Idx;
            R.Items (New_Idx).Next := Before;
         end if;
      end if;
   end Link_Before;

   procedure Append_Item (R : in out RGA; Idx : Natural) with Pre => Invariant (R) and then Idx in 1 .. R.Capacity, Post => Invariant (R) is
      Last : constant Natural := Find_Last (R);
   begin
      if Last = 0 then
         R.Head := Idx;
      else
         R.Items (Last).Next := Idx;
      end if;
   end Append_Item;

   function Find_Insertion_Before (R : RGA; Id : Node_Id) return Natural with Pre => Invariant (R), Post => Find_Insertion_Before'Result in 0 .. R.Capacity is
      Before : Natural := 0;
      T_Idx  : Natural := R.Head;
      Steps  : Natural := 0;
   begin
      loop
         pragma Loop_Invariant (T_Idx in 0 .. R.Capacity and then Before in 0 .. R.Capacity and then Steps <= R.Capacity);
         pragma Loop_Variant (Increases => Steps);
         exit when T_Idx = 0 or Before /= 0 or Steps >= R.Capacity;
         if Id_Less (Id, R.Items (T_Idx).Id) then
            Before := T_Idx;
         else
            T_Idx := R.Items (T_Idx).Next;
         end if;
         Steps := Steps + 1;
      end loop;
      return Before;
   end Find_Insertion_Before;

   function Find_Pos (R : RGA; Pos : Positive) return Natural with Pre => Invariant (R), Post => Find_Pos'Result in 0 .. R.Capacity is
      P     : Natural := Pos;
      Cur   : Natural := R.Head;
      Steps : Natural := 0;
   begin
      loop
         pragma Loop_Invariant (Cur in 0 .. R.Capacity and then P in 1 .. Natural'Last and then Steps <= R.Capacity);
         pragma Loop_Variant (Increases => Steps);
         exit when Cur = 0 or Steps >= R.Capacity;
         if P = 1 then
            return Cur;
         end if;
         P := P - 1;
         Cur := R.Items (Cur).Next;
         Steps := Steps + 1;
      end loop;
      return 0;
   end Find_Pos;

   -- Iterator
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

   function Element (Container : RGA; Position : Cursor) return Element_Type with SPARK_Mode => Off is
      Idx : constant Natural := Find_Pos (Container, Position.Pos);
   begin
      if Idx = 0 then
         raise Constraint_Error with "Naive element: position out of range";
      end if;
      return Container.Items (Idx).Value;
   end Element;

   -- Public ops
   function Count (R : RGA) return Natural
   is (R.Count);

   function Size (R : RGA) return Natural
   is (R.Total);

   function Get (R : RGA; Pos : Positive) return Element_Type with SPARK_Mode => Off is
      Idx : constant Natural := Find_Pos (R, Pos);
   begin
      if Idx = 0 then
         raise Constraint_Error with "RGA.Get: position out of range";
      end if;
      return R.Items (Idx).Value;
   end Get;

   procedure Insert (R : in out RGA; Pos : Positive; Id : Node_Id; Value : Element_Type) is
      Idx     : Natural;
      Before  : Natural;
      New_Idx : Natural;
   begin
      if R.Head = 0 then
         New_Item (R, Id, Value, Idx);
         if Idx > 0 then
            R.Head := Idx;
         end if;
         return;
      end if;

      Before := Find_Pos (R, Pos);
      New_Item (R, Id, Value, New_Idx);
      if New_Idx > 0 then
         if Before = 0 then
            Append_Item (R, New_Idx);
         else
            Link_Before (R, Before, New_Idx);
         end if;
      end if;
   end Insert;

   procedure Insert_Bulk (R : in out RGA; Pos : Positive; Id : Node_Id; Values : Element_Array) is
      Cur_Pos : Positive := Pos;
      Cur_Seq : Natural := Id.Seq;
   begin
      for I in Values'Range loop
         pragma Loop_Invariant (Invariant (R));
         Insert (R, Cur_Pos, (Replica => Id.Replica, Seq => Cur_Seq), Values (I));
         if Cur_Pos = Positive'Last then
            Cur_Pos := Positive'Last;
         else
            Cur_Pos := Cur_Pos + 1;
         end if;
         if Cur_Seq = Natural'Last then
            Cur_Seq := Natural'Last;
         else
            Cur_Seq := Cur_Seq + 1;
         end if;
      end loop;
   end Insert_Bulk;

   procedure Delete (R : in out RGA; Pos : Positive) is
      Idx : constant Natural := Find_Pos (R, Pos);
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
      type Src_Ref is record
         Idx : Natural;
         Id  : Node_Id;
      end record;
      type Src_Array is array (Positive range <>) of Src_Ref;

      Srcs     : Src_Array (1 .. Max_Items) := (others => (Idx => 0, Id => (Replica => 1, Seq => 0)));
      Src_Last : Natural := 0;
      S_Idx    : Natural := Source.Head;
      Steps    : Natural := 0;
   begin
      loop
         pragma
           Loop_Invariant
             (S_Idx in 0 .. Source.Capacity and then Src_Last <= Max_Items and then Steps <= Source.Capacity and then (for all J in 1 .. Src_Last => Srcs (J).Idx in 1 .. Source.Capacity));
         pragma Loop_Variant (Increases => Steps);
         exit when S_Idx = 0 or else Steps >= Source.Capacity;
         if Find_Node (Target, Source.Items (S_Idx).Id) = 0 and then Src_Last < Max_Items then
            Src_Last := Src_Last + 1;
            Srcs (Src_Last) := (Idx => S_Idx, Id => Source.Items (S_Idx).Id);
         end if;
         S_Idx := Source.Items (S_Idx).Next;
         Steps := Steps + 1;
      end loop;

      if Src_Last > 0 then
         for I in 1 .. Src_Last - 1 loop
            pragma Loop_Invariant (for all K in 1 .. Src_Last => Srcs (K).Idx in 1 .. Source.Capacity);
            for J in reverse I + 1 .. Src_Last loop
               pragma Loop_Invariant (for all K in 1 .. Src_Last => Srcs (K).Idx in 1 .. Source.Capacity);
               if Id_Less (Srcs (J).Id, Srcs (J - 1).Id) then
                  declare
                     Tmp : constant Src_Ref := Srcs (J);
                  begin
                     Srcs (J) := Srcs (J - 1);
                     Srcs (J - 1) := Tmp;
                  end;
               end if;
            end loop;
         end loop;
      end if;

      for I in 1 .. Src_Last loop
         pragma Loop_Invariant (Invariant (Target) and then (for all J in 1 .. Src_Last => Srcs (J).Idx in 1 .. Source.Capacity));
         declare
            New_Idx  : Natural;
            Src_Item : RGA_Item;
            Src_Id   : Node_Id;
            Before   : Natural;
         begin
            Src_Item := Source.Items (Srcs (I).Idx);
            Src_Id := Srcs (I).Id;
            Copy_Item (Target, Src_Item, New_Idx);
            if New_Idx > 0 then
               Before := Find_Insertion_Before (Target, Src_Id);
               if Before = 0 then
                  Append_Item (Target, New_Idx);
               else
                  Link_Before (Target, Before, New_Idx);
               end if;
            end if;
         end;
      end loop;
   end Merge;

   function "=" (Left, Right : RGA) return Boolean with SPARK_Mode => Off is
      L_Idx : Natural := Left.Head;
      R_Idx : Natural := Right.Head;
   begin
      loop
         pragma Loop_Invariant (L_Idx in 0 .. Left.Capacity and then R_Idx in 0 .. Right.Capacity);
         if L_Idx = 0 and R_Idx = 0 then
            return True;
         end if;
         if L_Idx = 0 or R_Idx = 0 then
            return False;
         end if;
         if Left.Items (L_Idx).Id /= Right.Items (R_Idx).Id or else Left.Items (L_Idx).Value /= Right.Items (R_Idx).Value or else Left.Items (L_Idx).Deleted /= Right.Items (R_Idx).Deleted then
            return False;
         end if;
         L_Idx := Left.Items (L_Idx).Next;
         R_Idx := Right.Items (R_Idx).Next;
      end loop;
   end "=";

   procedure Compact (R : in out RGA) is
      Cur   : Natural := R.Head;
      Prev  : Natural := 0;
      Next  : Natural;
      Steps : Natural := 0;
   begin
      loop
         pragma Loop_Invariant (Cur in 0 .. R.Capacity and then Prev in 0 .. R.Capacity and then Steps <= R.Capacity);
         pragma Loop_Invariant (Invariant (R));
         pragma Loop_Variant (Increases => Steps);
         exit when Cur = 0 or else Steps >= R.Capacity;
         Next := R.Items (Cur).Next;
         if R.Items (Cur).Deleted then
            if Prev = 0 then
               R.Head := Next;
            else
               R.Items (Prev).Next := Next;
            end if;
            Free_Item (R, Cur);
            if R.Total > 0 then
               R.Total := R.Total - 1;
            end if;
         else
            Prev := Cur;
         end if;
         Cur := Next;
         Steps := Steps + 1;
      end loop;
   end Compact;

   -- Serialization
   procedure Write_RGA (Stream : access Ada.Streams.Root_Stream_Type'Class; Item : RGA) with SPARK_Mode => Off is
      use Ada.Streams;
   begin
      Core.LEB128.Encode (Stream, 2);
      Core.LEB128.Encode (Stream, Item.Total);
      Core.LEB128.Encode (Stream, Item.Count);
      declare
         Cur : Natural := Item.Head;
      begin
         while Cur /= 0 loop
            Node_Id'Write (Stream, Item.Items (Cur).Id);
            Boolean'Write (Stream, Item.Items (Cur).Deleted);
            Element_Type'Write (Stream, Item.Items (Cur).Value);
            Cur := Item.Items (Cur).Next;
         end loop;
      end;
   end Write_RGA;

   procedure Read_RGA (Stream : access Ada.Streams.Root_Stream_Type'Class; Item : out RGA) with SPARK_Mode => Off is
      use Ada.Streams;
      use CRDT.Serialization;
      Kind      : Protocol_Kind;
      Total     : Natural;
      Num_Items : Natural;
      Id        : Node_Id;
      Deleted   : Boolean;
      Val       : Element_Type;
      Prev_Idx  : Natural := 0;
      New_Idx   : Natural;
      Ignore_CK : CRDT.Clocks.Clock_Kind;
   begin
      Read_Header (Stream, Kind, Total, Num_Items, Ignore_CK);

      if Num_Items > Item.Capacity then
         raise Constraint_Error with "Naive Read_RGA: item count" & Natural'Image (Num_Items) & " exceeds capacity" & Natural'Image (Item.Capacity);
      end if;

      Item.Total := Total;
      Item.Head := 0;
      Item.Count := 0;
      Item.Free := 0;

      for J in 1 .. Num_Items loop
         Node_Id'Read (Stream, Id);
         Boolean'Read (Stream, Deleted);
         Element_Type'Read (Stream, Val);
         Alloc_Item (Item, New_Idx);
         if New_Idx > 0 then
            Item.Count := J;
            Item.Items (New_Idx).Id := Id;
            Item.Items (New_Idx).Deleted := Deleted;
            Item.Items (New_Idx).Value := Val;
            if Prev_Idx = 0 then
               Item.Head := New_Idx;
            else
               Item.Items (Prev_Idx).Next := New_Idx;
            end if;
            Prev_Idx := New_Idx;
         end if;
      end loop;
   end Read_RGA;

end CRDT.Sequences.Naive;
