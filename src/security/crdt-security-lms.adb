with CRDT.Security.SHA256;
with Interfaces;

package body CRDT.Security.LMS
  with SPARK_Mode
is

   use type Interfaces.Unsigned_32;

   --  Hash one RFC 8554 node: H (I || u32str (r) || u16str (D) || Rest).
   function Hash_Node (I : Byte_Array; R : Natural; D : Natural; Rest : Byte_Array) return N_String with Pre => I'Length = 16 and then R <= 2**31 - 1 is
      use type Ada.Streams.Stream_Element_Offset;
      Ctx   : SHA256.Context;
      Out_D : N_String;
      U32   : constant Byte_Array (1 .. 4) := (1 => Byte ((R / 2**24) mod 256), 2 => Byte ((R / 2**16) mod 256), 3 => Byte ((R / 2**8) mod 256), 4 => Byte (R mod 256));
      U16   : constant Byte_Array (1 .. 2) := (1 => Byte ((D / 2**8) mod 256), 2 => Byte (D mod 256));
   begin
      SHA256.Init (Ctx);
      SHA256.Update (Ctx, I);
      SHA256.Update (Ctx, U32);
      SHA256.Update (Ctx, U16);
      SHA256.Update (Ctx, Rest);
      SHA256.Final (Ctx, Out_D);
      return Out_D;
   end Hash_Node;

   --  Coefficient extraction: the i-th w-bit digit of Q
   --  (RFC 8554 section 3.1.3).  W = 8, so one byte per digit.
   --  The formal is the statically constrained N_String: gnatprove
   --  cannot bound indexing arithmetic for an unconstrained array
   --  formal, while a static length reduces every check to a constant
   --  comparison (same idiom as CRDT.Core.LEB128).
   function Coef (Q : N_String; Idx : Natural) return Natural
   is (Natural (Q (N_String'First + Ada.Streams.Stream_Element_Offset (Idx))))
   with Pre => Idx < N_Length;

   function Hash_LMS_Node (I : Byte_Array; R : Natural; D : Natural; Rest : Byte_Array) return N_String
   is (Hash_Node (I, R, D, Rest));

   --  Winternitz chain step (RFC 8554 algorithms 1 and 4b inner loop):
   --  H (I || u32str (q) || u16str (i) || u8str (j) || tmp), where i is
   --  the chain number and j the step within the chain.
   function Chain_Step (I : Byte_Array; Q : Natural; Chain : Natural; Step : Natural; Tmp : N_String) return N_String with Pre => I'Length = 16 and then Step <= 255 and then Q <= 2**31 - 1 is
      Ctx   : SHA256.Context;
      Out_D : N_String;
      U32   : Byte_Array (1 .. 4) := (Byte ((Q / 2**24) mod 256), Byte ((Q / 2**16) mod 256), Byte ((Q / 2**8) mod 256), Byte (Q mod 256));
      U16   : Byte_Array (1 .. 2) := (Byte ((Chain / 2**8) mod 256), Byte (Chain mod 256));
      U8    : constant Byte_Array (1 .. 1) := (1 => Byte (Step mod 256));
   begin
      SHA256.Init (Ctx);
      SHA256.Update (Ctx, I);
      SHA256.Update (Ctx, U32);
      SHA256.Update (Ctx, U16);
      SHA256.Update (Ctx, U8);
      SHA256.Update (Ctx, Tmp);
      SHA256.Final (Ctx, Out_D);
      return Out_D;
   end Chain_Step;

   --  Checksum of the message hash (RFC 8554 algorithm 2).
   --  n * 8 / w = 32 digits; the 16-bit sum is at most 32 * 255.
   function Checksum (Q_Hash : N_String) return Natural
   is (OTS_Checksum (Q_Hash));

   function OTS_Checksum (Q_Hash : N_String) return Natural is
      Sum : Natural := 0;
   begin
      for I in 0 .. (N_Length * 8 / W) - 1 loop
         Sum := Sum + ((2**W - 1) - Coef (Q_Hash, I));
         pragma Loop_Invariant (Sum <= (I + 1) * (2**W - 1));
      end loop;
      return Sum * 2**LS;
   end OTS_Checksum;

   --  K = H (I || u32str (q) || u16str (D_PBLC) || y (0) .. y (p-1))
   --  (RFC 8554 algorithm 1 step 4).
   function OTS_Public_Row (I : Byte_Array; Q : Natural; Rest : Byte_Array) return N_String with Pre => I'Length = 16 and then Rest'Length = P * N_Length is
      Ctx   : SHA256.Context;
      Out_D : N_String;
      U32   : Byte_Array (1 .. 4) := (Byte ((Q / 2**24) mod 256), Byte ((Q / 2**16) mod 256), Byte ((Q / 2**8) mod 256), Byte (Q mod 256));
      U16   : Byte_Array (1 .. 2) := (Byte ((D_PBLC / 2**8) mod 256), Byte (D_PBLC mod 256));
   begin
      SHA256.Init (Ctx);
      SHA256.Update (Ctx, I);
      SHA256.Update (Ctx, U32);
      SHA256.Update (Ctx, U16);
      SHA256.Update (Ctx, Rest);
      SHA256.Final (Ctx, Out_D);
      return Out_D;
   end OTS_Public_Row;

   function Compute_OTS_Public (I : Byte_Array; Q : Natural; X : OTS_Private_Key) return N_String is
      Rest : Byte_Array (1 .. P * N_Length) := (others => 0);
   begin
      for J in 0 .. P - 1 loop
         declare
            Z : N_String := X (J);
         begin
            --  Complete the chain: 2^w - 1 = 255 steps.
            for Step in 1 .. 255 loop
               Z := Chain_Step (I, Q, J, Step, Z);
            end loop;
            Rest (Ada.Streams.Stream_Element_Offset (J * N_Length + 1) .. Ada.Streams.Stream_Element_Offset ((J + 1) * N_Length)) := Z;
         end;
      end loop;
      return OTS_Public_Row (I, Q, Rest);
   end Compute_OTS_Public;

   function Leaf_Hash (I : Byte_Array; Q : Natural; OTS_K : N_String) return N_String
   is (Hash_Node (I, 2**H + Q, D_LEAF, OTS_K));

   function Node_Hash (I : Byte_Array; Node_Num : Natural; Left : N_String; Right : N_String) return N_String is
      Rest : Byte_Array (1 .. 2 * N_Length) := (others => 0);
   begin
      Rest (1 .. N_Length) := Left;
      Rest (N_Length + 1 .. 2 * N_Length) := Right;
      return Hash_Node (I, Node_Num, D_INTR, Rest);
   end Node_Hash;

   --  Parse a big-endian unsigned 32-bit integer from a statically
   --  bounded 4-byte slice.  The result is Long_Long_Integer because a
   --  full 32-bit unsigned value does not fit in Natural on every
   --  supported target; callers narrow it to Natural once a range
   --  check has bounded the value.  The formal is the statically
   --  constrained U32_BE subtype: gnatprove cannot bound indexing or
   --  overflow checks for an unconstrained array formal, while a
   --  static length of 4 makes every check a constant computation
   --  (same idiom as CRDT.Core.LEB128).
   subtype U32_BE is Byte_Array (1 .. 4);

   function U32_At (S : U32_BE) return Long_Long_Integer with Post => U32_At'Result in 0 .. 2**32 - 1 is
      --  The fold runs on a modular 32-bit type: modular shift and or
      --  wrap instead of overflowing, so the body carries no overflow
      --  checks at all (same idiom as the SHA-256 Compress schedule).
      V : Interfaces.Unsigned_32 := 0;
   begin
      V := Interfaces.Shift_Left (V, 8) or Interfaces.Unsigned_32 (S (1));
      V := Interfaces.Shift_Left (V, 8) or Interfaces.Unsigned_32 (S (2));
      V := Interfaces.Shift_Left (V, 8) or Interfaces.Unsigned_32 (S (3));
      V := Interfaces.Shift_Left (V, 8) or Interfaces.Unsigned_32 (S (4));
      return Long_Long_Integer (V);
   end U32_At;

   procedure Compute_KC (Pub_Type : Natural; I : Byte_Array; Q : Natural; Message : Byte_Array; Sig : OTS_Signature; Kc : out N_String; Valid : out Boolean) is
      Sig_Type : Long_Long_Integer;
      C        : N_String;
      Y        : OTS_Private_Key;
      Q_Hash   : N_String;
   begin
      Kc := (others => 0);
      Valid := False;
      if Pub_Type /= LMOTS_SHA256_N32_W8 then
         return;
      end if;
      if Sig'Length /= 4 + N_Length * (P + 1) then
         return;
      end if;
      Sig_Type := U32_At (Sig (1 .. 4));
      if Sig_Type /= Long_Long_Integer (Pub_Type) then
         return;
      end if;

      --  Parse C and the chain values y (0) .. y (p-1).
      declare
         use type Ada.Streams.Stream_Element_Offset;
         Base : constant Ada.Streams.Stream_Element_Offset := Sig'First + 4;
      begin
         C := Sig (Base .. Base + N_Length - 1);
         for J in 0 .. P - 1 loop
            Y (J) := Sig (Base + Ada.Streams.Stream_Element_Offset (N_Length * (J + 1)) .. (Base + Ada.Streams.Stream_Element_Offset (N_Length * (J + 2))) - 1);
         end loop;
      end;

      --  Q = H (I || u32str (q) || u16str (D_MESG) || C || message).
      declare
         Ctx : SHA256.Context;
         Pre : Byte_Array (1 .. 16 + 4 + 2 + N_Length) := (others => 0);
      begin
         Pre (1 .. 16) := I;
         Pre (17) := Byte ((Q / 2**24) mod 256);
         Pre (18) := Byte ((Q / 2**16) mod 256);
         Pre (19) := Byte ((Q / 2**8) mod 256);
         Pre (20) := Byte (Q mod 256);
         Pre (21) := Byte ((D_MESG / 2**8) mod 256);
         Pre (22) := Byte (D_MESG mod 256);
         Pre (23 .. 22 + N_Length) := C;
         SHA256.Init (Ctx);
         SHA256.Update (Ctx, Pre);
         SHA256.Update (Ctx, Message);
         SHA256.Final (Ctx, Q_Hash);
      end;

      --  Complete each Winternitz chain and collect the candidate
      --  public key elements z (i) (RFC 8554 algorithm 4b step 3).
      declare
         Cksm : constant Natural := Checksum (Q_Hash);
         Ctx  : SHA256.Context;
         Rest : Byte_Array (1 .. P * N_Length) := (others => 0);
         U32  : Byte_Array (1 .. 4) := (Byte ((Q / 2**24) mod 256), Byte ((Q / 2**16) mod 256), Byte ((Q / 2**8) mod 256), Byte (Q mod 256));
         U16  : Byte_Array (1 .. 2) := (Byte ((D_PBLC / 2**8) mod 256), Byte (D_PBLC mod 256));
      begin
         for J in 0 .. P - 1 loop
            declare
               --  Digit J of Qc = Q_Hash || checksum (RFC 8554
               --  section 3.1.3): W = 8 makes one byte per digit, so
               --  digits 0..31 are the message-hash bytes and digits
               --  32..33 are the 16-bit checksum in network order.
               --  The digits are taken inline instead of through Coef:
               --  Qc is 34 bytes and Coef takes a statically bounded
               --  N_String, which is what keeps its checks provable.
               A : constant Natural := (if J < N_Length then Natural (Q_Hash (Ada.Streams.Stream_Element_Offset (J + 1))) else (if J = N_Length then (Cksm / 2**8) mod 256 else Cksm mod 256));
               Z : N_String := Y (J);
            begin
               --  Chain from digit a up to 2^w - 1 (= 255 for W8).
               --  A is a byte value, so A + 1 .. 255 is empty when A = 255.
               for Step in A + 1 .. 255 loop
                  Z := Chain_Step (I, Q, J, Step, Z);
               end loop;
               Rest (Ada.Streams.Stream_Element_Offset (J * N_Length + 1) .. Ada.Streams.Stream_Element_Offset ((J + 1) * N_Length)) := Z;
            end;
         end loop;

         SHA256.Init (Ctx);
         SHA256.Update (Ctx, I);
         SHA256.Update (Ctx, U32);
         SHA256.Update (Ctx, U16);
         SHA256.Update (Ctx, Rest);
         SHA256.Final (Ctx, Kc);
      end;

      Valid := True;
   end Compute_KC;

   function Verify_OTS (Pub_Type : Natural; I : Byte_Array; Q : Natural; Message : Byte_Array; Sig : OTS_Signature; Expected_K : N_String) return Boolean is
      Kc    : N_String;
      Valid : Boolean;
      use type N_String;
   begin
      Compute_KC (Pub_Type, I, Q, Message, Sig, Kc, Valid);
      return Valid and then Kc = Expected_K;
   end Verify_OTS;

   function Verify (Pub : Public_Key; Message : Byte_Array; Sig : LMS_Signature) return Boolean is
      --  Layout: u32str (q) || lmots_signature || u32str (type) || path.
      Q_Val    : Long_Long_Integer;
      Sig_Type : Long_Long_Integer;
      Q        : Natural;
      Path     : array (0 .. H - 1) of N_String := (others => (others => 0));
      Node_Num : Natural;
      T        : N_String;
      Kc       : N_String;
      Valid    : Boolean;
   begin
      if Sig'Length /= LMS_Signature'Length then
         return False;
      end if;

      Q_Val := U32_At (Sig (1 .. 4));
      Sig_Type := U32_At (Sig (4 + OTS_Signature'Length .. 4 + OTS_Signature'Length + 3));

      if Sig_Type /= Long_Long_Integer (LMS_SHA256_M32_H5) then
         return False;
      end if;
      if Pub.OTS_Type /= LMOTS_SHA256_N32_W8 then
         return False;
      end if;
      if Q_Val >= Long_Long_Integer (2**H) then
         return False;
      end if;
      Q := Natural (Q_Val);

      --  Parse the authentication path.
      declare
         use type Ada.Streams.Stream_Element_Offset;
         Path_Off : constant Ada.Streams.Stream_Element_Offset := 8 + Ada.Streams.Stream_Element_Offset (OTS_Signature'Length);
      begin
         for J in 0 .. H - 1 loop
            Path (J) := Sig ((Sig'First + Path_Off) + Ada.Streams.Stream_Element_Offset (J * N_Length) .. ((Sig'First + Path_Off) + Ada.Streams.Stream_Element_Offset ((J + 1) * N_Length)) - 1);
         end loop;
      end;

      --  Public key candidate of the one-time signature.
      declare
         I : constant Byte_Array := Pub.I;
      begin
         Compute_KC (Pub.OTS_Type, I, Q, Message, Sig (Sig'First + 4 .. Sig'First + 3 + OTS_Signature'Length), Kc, Valid);
         if not Valid then
            return False;
         end if;

         --  Leaf hash: T (2^h + q) = H (... || D_LEAF || Kc).
         T := Leaf_Hash (I, Q, Kc);
         Node_Num := 2**H + Q;
         pragma Assert (Node_Num in 2**H .. 2**(H + 1) - 1);

         --  Walk the Merkle path up to the root (RFC 8554 section 5.4.2).
         --  The first parent is an internal node by construction; every
         --  later parent is at most half of the previous one, so it
         --  stays inside 1 .. 2**H - 1 (the last parent is the root 1).
         for Level in 0 .. H - 1 loop
            pragma Loop_Invariant (Node_Num in 2**(H - Level) .. 2**(H + 1) - 1);
            pragma Loop_Variant (Increases => Level);
            declare
               Parent : constant Natural := Node_Num / 2;
               pragma Assert (if Level < H - 1 then Parent >= 2**(H - Level - 1));
               pragma Assert (Parent <= 2**H - 1);
               pragma Assert (Parent >= 1);
            begin
               if Node_Num mod 2 = 0 then
                  T := Node_Hash (I, Parent, T, Path (Level));
               else
                  T := Node_Hash (I, Parent, Path (Level), T);
               end if;
               Node_Num := Parent;
            end;
         end loop;

         return T = Pub.T1;
      end;
   end Verify;

end CRDT.Security.LMS;
