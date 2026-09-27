with CRDT.Security.SHA256;

package body CRDT.Security.HMAC
  with SPARK_Mode
is

   use type SHA256.Byte;

   --  Local 64-byte block (HMAC pad length, same as SHA-256 block).
   subtype Block64 is SHA256.Byte_Array (1 .. 64);

   --  Normalise the key to exactly one block: hash keys longer than
   --  the block size, zero-pad shorter ones (RFC 2104 section 2).
   function Normalise_Key (Key : Byte_Array) return Block64 is
      use type Ada.Streams.Stream_Element_Offset;

      K : Block64 := (others => 0);
   begin
      if Key'Length > 64 then
         declare
            D : SHA256.Hash;
         begin
            SHA256.Digest (Key, D);
            for I in Natural range 1 .. 32 loop
               K (Ada.Streams.Stream_Element_Offset (I)) := D (Ada.Streams.Stream_Element_Offset (I));
               pragma Loop_Invariant (True);
            end loop;
         end;
      else
         for I in Natural range 0 .. Key'Length - 1 loop
            K (Ada.Streams.Stream_Element_Offset (1 + I)) := Key (Key'First + Ada.Streams.Stream_Element_Offset (I));
            pragma Loop_Invariant (True);
         end loop;
      end if;
      return K;
   end Normalise_Key;

   procedure Compute (Key : Byte_Array; Message : Byte_Array; Out_Tag : out Tag) is
      K     : constant Block64 := Normalise_Key (Key);
      I_Pad : Block64;
      O_Pad : Block64;
      Ctx   : SHA256.Context;
      Inner : SHA256.Hash;
   begin
      for I in Block64'Range loop
         I_Pad (I) := K (I) xor 16#36#;
         O_Pad (I) := K (I) xor 16#5C#;
      end loop;

      --  Inner: SHA256 (I_Pad || Message).
      SHA256.Init (Ctx);
      SHA256.Update (Ctx, I_Pad);
      SHA256.Update (Ctx, Message);
      SHA256.Final (Ctx, Inner);

      --  Outer: SHA256 (O_Pad || Inner).
      SHA256.Init (Ctx);
      SHA256.Update (Ctx, O_Pad);
      SHA256.Update (Ctx, Inner);
      SHA256.Final (Ctx, Out_Tag);
   end Compute;

   function Equal (Left, Right : Tag) return Boolean is
      Diff : SHA256.Byte := 0;
   begin
      for I in Tag'Range loop
         Diff := Diff or (Left (I) xor Right (I));
         pragma Loop_Invariant ((Diff = 0) = (for all J in Tag'First .. I => Left (J) = Right (J)));
      end loop;
      return Diff = 0;
   end Equal;

end CRDT.Security.HMAC;
