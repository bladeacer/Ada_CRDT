with Ada_CRDT.Core;

generic
   type Element_Type is private;
   Max_Set_Size : Positive;
package Ada_CRDT.Lww_Element_Sets with
  SPARK_Mode
is

   type Timestamp_Entry is record
      Element : Element_Type;
      Time    : Core.Lamport_Time;
   end record;

   type Timestamp_Array is array (Positive range <>) of Timestamp_Entry;

   type LWW_Element_Set (Capacity : Positive) is private;

   function Contains (S : LWW_Element_Set; E : Element_Type) return Boolean;

   procedure Add (S  : in out LWW_Element_Set;
                  E  : Element_Type;
                  TS : Core.Lamport_Time);

   procedure Remove (S  : in out LWW_Element_Set;
                     E  : Element_Type;
                     TS : Core.Lamport_Time);

   procedure Merge (Target : in out LWW_Element_Set;
                    Source : LWW_Element_Set);

private

   type LWW_Element_Set (Capacity : Positive) is record
      Add_Array    : Timestamp_Array (1 .. Capacity);
      Add_Size     : Natural := 0;
      Remove_Array : Timestamp_Array (1 .. Capacity);
      Remove_Size  : Natural := 0;
   end record;

end Ada_CRDT.Lww_Element_Sets;
