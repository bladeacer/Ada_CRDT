with CRDT.Security.SHA256;

package body CRDT.Security.HMAC
  with SPARK_Mode
is

   --  Local 64-byte block (HMAC pad length, same as SHA-256 block).
   type Block64 is array (1 .. 64) of Byte;

   --  Normalise the key to exactly one block: hash keys longer than
   --  the block size, zero-pad shorter ones (RFC 2104 section 2).
   function Normalise_Key (Key : Byte_Array) return Block64
   with Pre => Key'Length > 0
   is
      K : Block64 := (others => 0);
   begin
      if Key'Length > Block64'Length then
         declare
            D : SHA256.Hash;
         begin
            SHA256.Digest (Key, D);
            for I in D'Range loop
               K (I) := D (I);
               pragma Loop_Invariant (for all J in 1 .. I => K (J) = D (J));
            end loop;
         end;
      else
         for I in Key'Range loop
            K (1 + (I - Key'First)) := Key (I);
            pragma Loop_Invariant (True);
         end loop;
      end if;
      return K;
   end Normalise_Key;

   procedure Compute
     (Key     : Byte_Array;
      Message : Byte_Array;
      Out_Tag : out Tag)
   with Pre => Key'Length > 0
   is
      K     : constant Block64 := Normalise_Key (Key);
      I_Pad : Block64;
      O_Pad : Block64;
      Ctx   : SHA256.Context;
      Inner : SHA256.Hash;
   begin
      for I in Block64'Range loop
         I_Pad (I) := K (I) xor 16#36#;
         O_Pad (I) := K (I) xor 16#5C#;
         pragma Loop_Invariant (True);
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

   function Equal (Left, Right : Tag) return Boolean
   is
      Diff : Byte := 0;
   begin
      for I in Tag'Range loop
         Diff := Diff or (Left (I) xor Right (I));
         pragma Loop_Invariant (for all J in 1 .. I => (Left (J) = Right (J)) or Diff /= 0);
      end loop;
      return Diff = 0;
   end Equal;

end CRDT.Security.HMAC;
