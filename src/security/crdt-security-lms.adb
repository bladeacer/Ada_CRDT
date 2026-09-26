with CRDT.Security.SHA256;

package body CRDT.Security.LMS
  with SPARK_Mode
is

   --  Hash one RFC 8554 node: H (I || u32str (r) || u16str (D) || Rest).
   function Hash_Node
     (I    : Byte_Array;
      R    : Natural;
      D    : Natural;
      Rest : Byte_Array) return N_String
   with Pre => I'Length = 16 and then R <= 2 ** 31 - 1
   is
      use type Ada.Streams.Stream_Element_Offset;
      Ctx   : SHA256.Context;
      Out_D : N_String;
      U32   : constant Byte_Array (1 .. 4) :=
        (1 => Byte ((R / 2 ** 24) mod 256),
         2 => Byte ((R / 2 ** 16) mod 256),
         3 => Byte ((R / 2 ** 8) mod 256),
         4 => Byte (R mod 256));
      U16   : constant Byte_Array (1 .. 2) :=
        (1 => Byte ((D / 2 ** 8) mod 256),
         2 => Byte (D mod 256));
   begin
      SHA256.Init (Ctx);
      SHA256.Update (Ctx, I);
      SHA256.Update (Ctx, U32);
      SHA256.Update (Ctx, U16);
      SHA256.Update (Ctx, Rest);
      SHA256.Final (Ctx, Out_D);
      return Out_D;
   end Hash_Node;

   --  Coefficient extraction: the i-th w-bit digit of S
   --  (RFC 8554 section 3.1.3).  W = 8, so one byte per digit.
   function Coef (S : Byte_Array; Idx : Natural) return Natural
   is (Natural (S (S'First + Ada.Streams.Stream_Element_Offset (Idx))))
   with Pre => Ada.Streams.Stream_Element_Offset (Idx) < S'Length;

   function Hash_LMS_Node
     (I    : Byte_Array;
      R    : Natural;
      D    : Natural;
      Rest : Byte_Array) return N_String
   is (Hash_Node (I, R, D, Rest));

   --  Winternitz chain step (RFC 8554 algorithms 1 and 4b inner loop):
   --  H (I || u32str (q) || u16str (i) || u8str (j) || tmp), where i is
   --  the chain number and j the step within the chain.
   function Chain_Step
     (I     : Byte_Array;
      Q     : Natural;
      Chain : Natural;
      Step  : Natural;
      Tmp   : N_String) return N_String
   with Pre => I'Length = 16 and then Step <= 255 and then Q <= 2 ** 31 - 1
   is
      Ctx   : SHA256.Context;
      Out_D : N_String;
      U32   : Byte_Array (1 .. 4) :=
        (Byte ((Q / 2 ** 24) mod 256),
         Byte ((Q / 2 ** 16) mod 256),
         Byte ((Q / 2 ** 8) mod 256),
         Byte (Q mod 256));
      U16   : Byte_Array (1 .. 2) :=
        (Byte ((Chain / 2 ** 8) mod 256),
         Byte (Chain mod 256));
      U8    : constant Byte_Array (1 .. 1) :=
        (1 => Byte (Step mod 256));
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

   function OTS_Checksum (Q_Hash : N_String) return Natural
   is
      Sum : Natural := 0;
   begin
      for I in 0 .. (N_Length * 8 / W) - 1 loop
         Sum := Sum + ((2 ** W - 1) - Coef (Q_Hash, I));
         pragma Loop_Invariant (Sum <= (I + 1) * (2 ** W - 1));
      end loop;
      return Sum * 2 ** LS;
   end OTS_Checksum;

   --  K = H (I || u32str (q) || u16str (D_PBLC) || y (0) .. y (p-1))
   --  (RFC 8554 algorithm 1 step 4).
   function OTS_Public_Row
     (I    : Byte_Array;
      Q    : Natural;
      Rest : Byte_Array) return N_String
   with Pre => I'Length = 16 and then Rest'Length = P * N_Length
   is
      Ctx   : SHA256.Context;
      Out_D : N_String;
      U32   : Byte_Array (1 .. 4) :=
        (Byte ((Q / 2 ** 24) mod 256),
         Byte ((Q / 2 ** 16) mod 256),
         Byte ((Q / 2 ** 8) mod 256),
         Byte (Q mod 256));
      U16   : Byte_Array (1 .. 2) :=
        (Byte ((D_PBLC / 2 ** 8) mod 256),
         Byte (D_PBLC mod 256));
   begin
      SHA256.Init (Ctx);
      SHA256.Update (Ctx, I);
      SHA256.Update (Ctx, U32);
      SHA256.Update (Ctx, U16);
      SHA256.Update (Ctx, Rest);
      SHA256.Final (Ctx, Out_D);
      return Out_D;
   end OTS_Public_Row;

   function Compute_OTS_Public
     (I : Byte_Array;
      Q : Natural;
      X : OTS_Private_Key) return N_String
   is
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
            Rest (Ada.Streams.Stream_Element_Offset (J * N_Length + 1)
                  .. Ada.Streams.Stream_Element_Offset ((J + 1) * N_Length)) := Z;
         end;
      end loop;
      return OTS_Public_Row (I, Q, Rest);
   end Compute_OTS_Public;

   function Leaf_Hash
     (I     : Byte_Array;
      Q     : Natural;
      OTS_K : N_String) return N_String
   is (Hash_Node (I, 2 ** H + Q, D_LEAF, OTS_K));

   function Node_Hash
     (I        : Byte_Array;
      Node_Num : Natural;
      Left     : N_String;
      Right    : N_String) return N_String
   is
      Rest : Byte_Array (1 .. 2 * N_Length) := (others => 0);
   begin
      Rest (1 .. N_Length) := Left;
      Rest (N_Length + 1 .. 2 * N_Length) := Right;
      return Hash_Node (I, Node_Num, D_INTR, Rest);
   end Node_Hash;

   --  Parse a 4-byte big-endian unsigned integer at a byte offset.
   --  Modular arithmetic on Unsigned_32 cannot overflow, and the final
   --  conversion to Natural is exact because the value is < 2**32 and
   --  Natural covers 0 .. 2**31 - 1 on 32-bit... which is not enough,
   --  so the top byte is masked to 127 first? No: keep Long_Long_Integer
   --  accumulation in strict byte-sequential order so every partial sum
   --  is provably bounded by the next power of two.
   function U32_At (S : Byte_Array; Off : Natural) return Natural
   with Pre => S'Length >= 4 and then Off <= Natural'Last - 4
               and then Ada.Streams.Stream_Element_Offset (Off) + 4 <= S'Length
   is
      use type Ada.Streams.Stream_Element_Offset;
      Base : constant Ada.Streams.Stream_Element_Offset :=
        S'First + Ada.Streams.Stream_Element_Offset (Off);
      Sum  : Long_Long_Integer := 0;
   begin
      for K in Natural range 0 .. 3 loop
         pragma Loop_Invariant (Sum in 0 .. 2 ** (8 * K) - 1);
         Sum := Sum * 2 ** 8
              + Long_Long_Integer (S (Base + Ada.Streams.Stream_Element_Offset (K)));
         pragma Assert (Sum in 0 .. 2 ** (8 * (K + 1)) - 1);
      end loop;
      return Natural (Sum);
   end U32_At;

   procedure Compute_KC
     (Pub_Type : Natural;
      I        : Byte_Array;
      Q        : Natural;
      Message  : Byte_Array;
      Sig      : OTS_Signature;
      Kc       : out N_String;
      Valid    : out Boolean)
   is
      Sig_Type : Natural;
      C        : N_String := (others => 0);
      Y        : OTS_Private_Key := (others => (others => 0));
      Q_Hash   : N_String := (others => 0);
   begin
      Kc := (others => 0);
      Valid := False;
      if Pub_Type /= LMOTS_SHA256_N32_W8 then
         return;
      end if;
      if Sig'Length /= 4 + N_Length * (P + 1) then
         return;
      end if;
      Sig_Type := U32_At (Sig, 0);
      if Sig_Type /= Pub_Type then
         return;
      end if;

      --  Parse C and the chain values y (0) .. y (p-1).
      declare
         use type Ada.Streams.Stream_Element_Offset;
         Base : constant Ada.Streams.Stream_Element_Offset := Sig'First + 4;
      begin
         C := Sig (Base .. Base + N_Length - 1);
         for J in 0 .. P - 1 loop
            Y (J) := Sig
              (Base + Ada.Streams.Stream_Element_Offset (N_Length * (J + 1))
               .. Base + Ada.Streams.Stream_Element_Offset (N_Length * (J + 2)) - 1);
         end loop;
      end;

      --  Q = H (I || u32str (q) || u16str (D_MESG) || C || message).
      declare
         Ctx : SHA256.Context;
         Pre : Byte_Array (1 .. 16 + 4 + 2 + N_Length) := (others => 0);
      begin
         Pre (1 .. 16) := I;
         Pre (17) := Byte ((Q / 2 ** 24) mod 256);
         Pre (18) := Byte ((Q / 2 ** 16) mod 256);
         Pre (19) := Byte ((Q / 2 ** 8) mod 256);
         Pre (20) := Byte (Q mod 256);
         Pre (21) := Byte ((D_MESG / 2 ** 8) mod 256);
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
         Qc   : Byte_Array (1 .. N_Length + 2) := (others => 0);
         Ctx  : SHA256.Context;
         Rest : Byte_Array (1 .. P * N_Length) := (others => 0);
         U32  : Byte_Array (1 .. 4) :=
           (Byte ((Q / 2 ** 24) mod 256),
            Byte ((Q / 2 ** 16) mod 256),
            Byte ((Q / 2 ** 8) mod 256),
            Byte (Q mod 256));
         U16  : Byte_Array (1 .. 2) :=
           (Byte ((D_PBLC / 2 ** 8) mod 256),
            Byte (D_PBLC mod 256));
      begin
         Qc (1 .. N_Length) := Q_Hash;
         Qc (N_Length + 1) := Byte ((Cksm / 2 ** 8) mod 256);
         Qc (N_Length + 2) := Byte (Cksm mod 256);

         for J in 0 .. P - 1 loop
            declare
               A : constant Natural := Coef (Qc, J);
               Z : N_String := Y (J);
            begin
               --  Chain from digit a up to 2^w - 1 (= 255 for W8).
               if A <= 255 then
                  for Step in A + 1 .. 255 loop
                     Z := Chain_Step (I, Q, J, Step, Z);
                  end loop;
               end if;
               Rest (Ada.Streams.Stream_Element_Offset (J * N_Length + 1)
                     .. Ada.Streams.Stream_Element_Offset ((J + 1) * N_Length)) := Z;
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

   function Verify_OTS
     (Pub_Type   : Natural;
      I          : Byte_Array;
      Q          : Natural;
      Message    : Byte_Array;
      Sig        : OTS_Signature;
      Expected_K : N_String) return Boolean
   is
      Kc    : N_String := (others => 0);
      Valid : Boolean;
      use type N_String;
   begin
      Compute_KC (Pub_Type, I, Q, Message, Sig, Kc, Valid);
      return Valid and then Kc = Expected_K;
   end Verify_OTS;

   function Verify
     (Pub     : Public_Key;
      Message : Byte_Array;
      Sig     : LMS_Signature) return Boolean
   is
      --  Layout: u32str (q) || lmots_signature || u32str (type) || path.
      Q        : Natural;
      Sig_Type : Natural;
      Ots_Type : Natural;
      Path     : array (0 .. H - 1) of N_String := (others => (others => 0));
      Node_Num : Natural;
      T        : N_String;
      Kc       : N_String := (others => 0);
      Valid    : Boolean;
   begin
      if Sig'Length /= LMS_Signature'Length then
         return False;
      end if;

      Q        := U32_At (Sig, 0);
      Sig_Type := U32_At (Sig, 4 + OTS_Signature'Length);
      Ots_Type := Pub.OTS_Type;

      if Sig_Type /= LMS_SHA256_M32_H5 then
         return False;
      end if;
      if Ots_Type /= LMOTS_SHA256_N32_W8 then
         return False;
      end if;
      if Q >= 2 ** H then
         return False;
      end if;

      --  Parse the authentication path.
      declare
         use type Ada.Streams.Stream_Element_Offset;
         Path_Off : constant Ada.Streams.Stream_Element_Offset :=
           8 + Ada.Streams.Stream_Element_Offset (OTS_Signature'Length);
      begin
         for J in 0 .. H - 1 loop
            Path (J) := Sig
              (Sig'First + Path_Off + Ada.Streams.Stream_Element_Offset (J * N_Length)
               .. Sig'First + Path_Off
                  + Ada.Streams.Stream_Element_Offset ((J + 1) * N_Length) - 1);
         end loop;
      end;

      --  Public key candidate of the one-time signature.
      declare
         I : constant Byte_Array := Pub.I;
      begin
         Compute_KC (Ots_Type, I, Q, Message,
                     Sig (Sig'First + 4 .. Sig'First + 3 + OTS_Signature'Length),
                     Kc, Valid);
         if not Valid then
            return False;
         end if;

         --  Leaf hash: T (2^h + q) = H (... || D_LEAF || Kc).
         T := Leaf_Hash (I, Q, Kc);
         Node_Num := 2 ** H + Q;
         pragma Assert (Node_Num in 2 ** H .. 2 ** (H + 1) - 1);

         --  Walk the Merkle path up to the root (RFC 8554 section 5.4.2).
         --  The first parent is an internal node by construction; every
         --  later parent is at most half of the previous one, so it
         --  stays inside 1 .. 2**H - 1 (the last parent is the root 1).
         for Level in 0 .. H - 1 loop
            pragma Loop_Invariant (Node_Num in 2 ** (H - Level) .. 2 ** (H + 1) - 1);
            pragma Loop_Variant (Increases => Level);
            declare
               Parent : constant Natural := Node_Num / 2;
               pragma Assert (if Level < H - 1 then Parent >= 2 ** (H - Level - 1));
               pragma Assert (Parent <= 2 ** H - 1);
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
