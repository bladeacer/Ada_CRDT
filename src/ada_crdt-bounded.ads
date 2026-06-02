with Ada_CRDT.Core;
with Ada_CRDT.Pn_Counters;
with Ada_CRDT.Lww_Element_Sets;
with Ada_CRDT.Rga;

-- Bounded (pre-allocated) container wrappers for Ada_CRDT types.
-- All dynamic structures use fixed-size arrays specified at compile time,
-- eliminating heap allocation during runtime.
--
-- This is critical for mission-critical systems where dynamic memory
-- allocation is restricted to prevent fragmentation and OOM crashes.

package Ada_CRDT.Bounded is

   -- Bounded PN-Counter with a fixed maximum number of actors.
   -- Usage:
   --    type My_Counter is new Bounded_PN_Counter (Max_Actors => 10);
   --    C : My_Counter;
   --    Ada_CRDT.Pn_Counters.Increment (C, 5, 1);
   subtype Bounded_PN_Counter is Pn_Counters.PN_Counter;

   -- Bounded LWW-Element-Set with a fixed capacity.
   -- Usage:
   --    package Bnd_LWW is new Bounded_LWW_Set (Integer, 100);
   generic
      type Element_Type is private;
      Max_Set_Size : Positive;
   package Bounded_LWW_Set is
      package LWW_Pkg is new Ada_CRDT.Lww_Element_Sets
        (Element_Type, Max_Set_Size);
      subtype Set is LWW_Pkg.LWW_Element_Set (Max_Set_Size);
   end Bounded_LWW_Set;

   -- Bounded RGA with fixed item capacity and stride.
   -- Usage:
   --    package Bnd_RGA is new Bounded_RGA (Character, 100, 64);
   generic
      type Element_Type is private;
      Max_Items   : Positive;
      Max_Stride  : Positive := 64;
      Max_Replicas : Positive := 32;
   package Bounded_RGA is
      package RGA_Pkg is new Ada_CRDT.Rga
        (Element_Type, Max_Items, Max_Stride, Max_Replicas);
      subtype Sequence is RGA_Pkg.RGA (Max_Items);
   end Bounded_RGA;

end Ada_CRDT.Bounded;
