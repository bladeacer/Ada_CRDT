with Ada.Streams;
with CRDT.Clocks;
with CRDT.Core;
with CRDT.Core.LEB128;

--  Generic Last-Writer-Wins Element Set over any clock strategy.
--  Stores (element, Clock_Time) pairs for add and remove sets.
--  An element is present if its add-timestamp exceeds its remove-timestamp.
--
--  @formal Element_Type  Type of elements to store in the set.
--  @formal Max_Set_Size  Maximum number of distinct elements.
--  @formal Clock_Time    Timestamp type from a CRDT.Clocks.* strategy.
--  @formal "<", "=", ">" Clock comparison operators.
--  @formal Max            Element-wise max for merge.
--  @formal Write_Clock    Serialise a clock timestamp.
--  @formal Read_Clock     Deserialise a clock timestamp.

generic
   type Element_Type is private;
   Max_Set_Size : Positive;
   type Clock_Time is private;
   Clk_Kind : CRDT.Clocks.Clock_Kind;
   with function "<" (L, R : Clock_Time) return Boolean is <>;
   with function "=" (L, R : Clock_Time) return Boolean is <>;
   with function ">" (L, R : Clock_Time) return Boolean is <>;
   with function Max (L, R : Clock_Time) return Clock_Time;
   with procedure Write_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : Clock_Time) is <>;
   with procedure Read_Clock (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Clock_Time) is <>;
package CRDT.Lww_Sets with SPARK_Mode is

   Max_Capacity : constant Positive := Max_Set_Size;

   type Timestamp_Entry is record
      Element : Element_Type;
      Time    : Clock_Time;
   end record;

   type Timestamp_Array is array (Positive range <>) of Timestamp_Entry;

   type LWW_Clocked_Set (Capacity : Positive) is private;

   --  Number of add entries currently tracked.
   --  @param S  The set to query.
   --  @return Add entry count, always <= Capacity.
   function Add_Count (S : LWW_Clocked_Set) return Natural
   with Post => Add_Count'Result <= S.Capacity;

   --  Number of remove entries currently tracked.
   --  @param S  The set to query.
   --  @return Remove entry count, always <= Capacity.
   function Remove_Count (S : LWW_Clocked_Set) return Natural
   with Post => Remove_Count'Result <= S.Capacity;

   --  Check if an element is currently in the set.
   --  An element is present if its add timestamp exceeds its remove timestamp.
   --  @param S  The set to query.
   --  @param E  Element to look up.
   --  @return True if element is considered present.
   function Contains (S : LWW_Clocked_Set; E : Element_Type) return Boolean;

   --  Add an element with the given clock timestamp.
   --  @param S   The set to modify.
   --  @param E   Element to add.
   --  @param TS  Clock timestamp for this add operation.
   procedure Add (S : in out LWW_Clocked_Set; E : Element_Type; TS : Clock_Time)
   with Post => Add_Count (S) <= S.Capacity, Depends => (S => (S, E, TS));

   --  Remove an element with the given clock timestamp.
   --  @param S   The set to modify.
   --  @param E   Element to remove.
   --  @param TS  Clock timestamp for this remove operation.
   procedure Remove (S : in out LWW_Clocked_Set; E : Element_Type; TS : Clock_Time)
   with Post => Add_Count (S) <= S.Capacity, Depends => (S => (S, E, TS));

   --  Merge another set's add/remove entries into this set.
   --  For each entry, keeps the higher timestamp.
   --  @param Target  The set to merge into.
   --  @param Source  The set to merge from.
   procedure Merge (Target : in out LWW_Clocked_Set; Source : LWW_Clocked_Set)
   with Post => Add_Count (Target) <= Target.Capacity, Depends => (Target => (Target, Source));

   --  Remove all entries, resetting to empty state.
   --  @param S  The set to clear.
   procedure Clear (S : in out LWW_Clocked_Set)
   with Post => Add_Count (S) = 0 and then Remove_Count (S) = 0, Depends => (S => null);

   --  Serialize the clocked set to a stream (V3: LEB128 + clock kind byte).
   --  @param Stream  Output stream to write to.
   --  @param Item    Set to serialize.
   procedure Write_LWW_Clocked_Set (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : LWW_Clocked_Set);

   --  Deserialize the clocked set from a stream (auto-detects V1/V2/V3).
   --  @param Stream  Input stream to read from.
   --  @param Item    Set to populate from stream data.
   procedure Read_LWW_Clocked_Set (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out LWW_Clocked_Set);

   for LWW_Clocked_Set'Write use Write_LWW_Clocked_Set;
   for LWW_Clocked_Set'Read use Read_LWW_Clocked_Set;

private

   type LWW_Clocked_Set (Capacity : Positive) is record
      Add_Array    : Timestamp_Array (1 .. Capacity);
      Add_Size     : Natural := 0;
      Remove_Array : Timestamp_Array (1 .. Capacity);
      Remove_Size  : Natural := 0;
   end record;

end CRDT.Lww_Sets;
