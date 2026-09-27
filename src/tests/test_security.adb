with CRDT.Test_Support; use CRDT.Test_Support;
with CRDT.Security.SHA256;
with CRDT.Security.HMAC;
with CRDT.Security.LMS;
with Ada.Streams;
with Ada.Text_IO;       use Ada.Text_IO;

package body Test_Security is

   use type Ada.Streams.Stream_Element;
   use type Ada.Streams.Stream_Element_Offset;

   package SHA renames CRDT.Security.SHA256;

   --  Hex constant helper: parse an ASCII hex string to bytes.
   function Hex (S : String) return Ada.Streams.Stream_Element_Array is
      function Nybble (C : Character) return Ada.Streams.Stream_Element
      is (case C is
            when '0' .. '9' => Character'Pos (C) - Character'Pos ('0'),
            when 'a' .. 'f' => Character'Pos (C) - Character'Pos ('a') + 10,
            when others     => Character'Pos (C) - Character'Pos ('A') + 10);
      Off : Natural := S'First;
   begin
      return R : Ada.Streams.Stream_Element_Array (1 .. S'Length / 2) do
         for I in R'Range loop
            R (I) := Nybble (S (Off)) * 16 + Nybble (S (Off + 1));
            Off := Off + 2;
            pragma Loop_Invariant (True);
         end loop;
      end return;
   end Hex;

   function Img (B : Ada.Streams.Stream_Element_Array) return String is
      Hex_Digits : constant String := "0123456789abcdef";
      R          : String (1 .. 2 * Integer (B'Length));
   begin
      for I in B'Range loop
         R (2 * (Integer (I) - Integer (B'First)) + 1) := Hex_Digits (Natural (B (I)) / 16 + 1);
         R (2 * (Integer (I) - Integer (B'First)) + 2) := Hex_Digits (Natural (B (I)) mod 16 + 1);
         pragma Loop_Invariant (True);
      end loop;
      return R;
   end Img;

   procedure Run (RunR : in out Runner) is

      use CRDT.Security.SHA256;
      use type Ada.Streams.Stream_Element_Array;

      ------------------
      --  SHA-256     --
      ------------------

      procedure Test_SHA256_Vectors is
         D : Hash;
      begin
         New_Line;
         Put_Line ("[Security.SHA256]");

         --  FIPS 180-4 test vectors.
         Digest (Hex (""), D);
         RunR.Check (Img (D) = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", "SHA-256 empty message matches FIPS 180-4 vector");

         Digest (Hex ("61"), D);  --  "a"
         RunR.Check (Img (D) = "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb", "SHA-256 single byte matches FIPS 180-4 vector");

         Digest (Hex ("616263"), D);  --  "abc"
         RunR.Check (Img (D) = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", "SHA-256 ""abc"" matches FIPS 180-4 vector");

         --  56-byte message crosses the two-block padding boundary.
         --  "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
         Digest (Hex ("6162636462636465636465666465666765666768666768696768696a68696a6b696a6b6c6a6b6c6d6b6c6d6e6c6d6e6f6d6e6f706e6f7071"), D);
         RunR.Check (Img (D) = "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1", "SHA-256 56-byte message matches FIPS 180-4 vector");

         --  Streaming form must agree with the one-shot form.
         declare
            Ctx : Context;
            D2  : Hash;
            Msg : constant Ada.Streams.Stream_Element_Array := Hex ("6162636465");
         begin
            Init (Ctx);
            Update (Ctx, Msg (Msg'First .. Msg'First + 1));
            Update (Ctx, Msg (Msg'First + 2 .. Msg'Last));
            Final (Ctx, D2);
            Digest (Msg, D);
            RunR.Check (D2 = D, "SHA-256 streaming equals one-shot");
         end;

         Put_Line ("[Security.SHA256] done.");
      end Test_SHA256_Vectors;

      ----------------
      --  HMAC      --
      ----------------

      procedure Test_HMAC_Vectors is
         use CRDT.Security.HMAC;

         T         : Tag;
         Key_Short : constant Ada.Streams.Stream_Element_Array := Hex ("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b");
         Data      : constant Ada.Streams.Stream_Element_Array := Hex ("4869205468657265");  --  "Hi There"
      begin
         New_Line;
         Put_Line ("[Security.HMAC]");

         --  RFC 4231 test case 1.
         Compute (Key_Short, Data, T);
         RunR.Check (Img (T) = "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7", "HMAC-SHA-256 RFC 4231 case 1");

         --  RFC 4231 test case 2.
         declare
            Key : constant Ada.Streams.Stream_Element_Array := Hex ("4a656665");
            Msg : constant Ada.Streams.Stream_Element_Array := Hex ("7768617420646f2079612077616e7420666f72206e6f7468696e673f");
            T2  : Tag;
         begin
            Compute (Key, Msg, T2);
            RunR.Check (Img (T2) = "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843", "HMAC-SHA-256 RFC 4231 case 2");
         end;

         --  Long key (131 bytes) must be hashed first (RFC 4231 case 6).
         declare
            Key : constant Ada.Streams.Stream_Element_Array (1 .. 131) := (others => 16#AA#);
            Msg : constant Ada.Streams.Stream_Element_Array := Hex ("54657374205573696e67204c6172676572205468616e20426c6f636b2d" & "53697a65204b6579202d2048617368204b6579204669727374");
            T3  : Tag;
         begin
            Compute (Key, Msg, T3);
            RunR.Check (Img (T3) = "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54", "HMAC-SHA-256 RFC 4231 case 6 (long key)");
         end;

         --  Constant-time comparison.
         declare
            T4, T5 : Tag;
         begin
            Compute (Key_Short, Data, T4);
            T5 := T4;
            RunR.Check (Equal (T4, T5), "HMAC Equal: identical tags");
            T5 (1) := T5 (1) xor 1;
            RunR.Check (not Equal (T4, T5), "HMAC Equal: one byte differs");
         end;

         Put_Line ("[Security.HMAC] done.");
      end Test_HMAC_Vectors;

      ----------------
      --  LMS       --
      ----------------

      procedure Test_LMS_Verify is
         package L renames CRDT.Security.LMS;
         use type L.Byte;
         use type L.Byte_Array;
         use type Ada.Streams.Stream_Element_Array;

         --  Deterministic test tree: leaves 0 and 1 share one key set.
         I : constant L.Byte_Array (1 .. 16) := (others => 16#A5#);

         --  Deterministic private key for leaf q: H (I || q || "x" || i).
         function Make_Priv (Q : Natural) return L.OTS_Private_Key is
            X : L.OTS_Private_Key;
         begin
            for J in 0 .. L.P - 1 loop
               declare
                  Ctx : SHA.Context;
                  Pre : L.Byte_Array (1 .. 22) := (others => 0);
               begin
                  Pre (1 .. 16) := I;
                  Pre (17) := L.Byte ((Q / 256) mod 256);
                  Pre (18) := L.Byte (Q mod 256);
                  Pre (21) := Character'Pos ('x');
                  Pre (22) := L.Byte (J);
                  SHA.Init (Ctx);
                  SHA.Update (Ctx, Pre);
                  SHA.Final (Ctx, X (J));
               end;
               pragma Loop_Invariant (True);
            end loop;
            return X;
         end Make_Priv;

         --  Sign a message with the deterministic private key.  The
         --  randomiser C is fixed so the test is reproducible.
         function Make_OTS_Sig (Q : Natural; X : L.OTS_Private_Key; M : Ada.Streams.Stream_Element_Array) return L.OTS_Signature is
            Sig    : L.OTS_Signature := (others => 0);
            C      : constant L.N_String := (others => 16#42#);
            Ctx    : SHA.Context;
            Q_Hash : L.N_String;
            Pre    : L.Byte_Array (1 .. 16 + 4 + 2 + L.N_Length);
            Cksm   : Natural;
            Qc     : L.Byte_Array (1 .. L.N_Length + 2);
         begin
            Sig (1) := 0;
            Sig (2) := 0;
            Sig (3) := 0;
            Sig (4) := L.Byte (L.LMOTS_SHA256_N32_W8);
            Sig (5 .. 4 + L.N_Length) := C;

            --  Recompute Q_Hash exactly as the verifier does.
            Pre (1 .. 16) := I;
            Pre (17) := L.Byte ((Q / 2**24) mod 256);
            Pre (18) := L.Byte ((Q / 2**16) mod 256);
            Pre (19) := L.Byte ((Q / 2**8) mod 256);
            Pre (20) := L.Byte (Q mod 256);
            Pre (21) := L.Byte ((L.D_MESG / 2**8) mod 256);
            Pre (22) := L.Byte (L.D_MESG mod 256);
            Pre (23 .. 22 + L.N_Length) := C;
            SHA.Init (Ctx);
            SHA.Update (Ctx, Pre);
            SHA.Update (Ctx, M);
            SHA.Final (Ctx, Q_Hash);

            Cksm := L.OTS_Checksum (Q_Hash);
            Qc (1 .. L.N_Length) := Q_Hash;
            Qc (L.N_Length + 1) := L.Byte ((Cksm / 2**8) mod 256);
            Qc (L.N_Length + 2) := L.Byte (Cksm mod 256);

            for J in 0 .. L.P - 1 loop
               declare
                  A : constant Natural := Natural (Qc (Qc'First + Ada.Streams.Stream_Element_Offset (J)));
                  Z : L.N_String := X (J);
               begin
                  declare
                     U32 : constant L.Byte_Array (1 .. 4) := (L.Byte ((Q / 2**24) mod 256), L.Byte ((Q / 2**16) mod 256), L.Byte ((Q / 2**8) mod 256), L.Byte (Q mod 256));
                     U16 : constant L.Byte_Array (1 .. 2) := (L.Byte ((J / 2**8) mod 256), L.Byte (J mod 256));
                  begin
                     for Step in 1 .. A loop
                        declare
                           Ctx : SHA.Context;
                           U8  : constant L.Byte_Array (1 .. 1) := (1 => L.Byte (Step mod 256));
                        begin
                           SHA.Init (Ctx);
                           SHA.Update (Ctx, I);
                           SHA.Update (Ctx, U32);
                           SHA.Update (Ctx, U16);
                           SHA.Update (Ctx, U8);
                           SHA.Update (Ctx, Z);
                           SHA.Final (Ctx, Z);
                        end;
                        pragma Loop_Invariant (True);
                     end loop;
                  end;
                  Sig (Ada.Streams.Stream_Element_Offset (5 + L.N_Length + J * L.N_Length) .. Ada.Streams.Stream_Element_Offset (4 + L.N_Length + (J + 1) * L.N_Length)) := Z;
               end;
               pragma Loop_Invariant (True);
            end loop;
            return Sig;
         end Make_OTS_Sig;

         --  Build an H5 public key where every leaf uses the same
         --  deterministic OTS key (fixture only; leaves 1..31 unused).
         function Make_Pub return L.Public_Key is
            X     : constant L.OTS_Private_Key := Make_Priv (0);
            K0    : constant L.N_String := L.Compute_OTS_Public (I, 0, X);
            Leaf  : array (0 .. 31) of L.N_String;
            Level : array (0 .. 15) of L.N_String;
         begin
            for Q in 0 .. 31 loop
               Leaf (Q) := L.Leaf_Hash (I, Q, K0);
               pragma Loop_Invariant (True);
            end loop;
            for Q in 0 .. 15 loop
               Level (Q) := L.Node_Hash (I, 16 + Q, Leaf (2 * Q), Leaf (2 * Q + 1));
               pragma Loop_Invariant (True);
            end loop;
            return Pub : L.Public_Key do
               Pub.OTS_Type := L.LMOTS_SHA256_N32_W8;
               Pub.I := I;
               Pub.T1 := L.Node_Hash (I, 8, Level (0), Level (1));
            end return;
         end Make_Pub;

         Pub : constant L.Public_Key := Make_Pub;
         K0  : constant L.N_String := L.Compute_OTS_Public (I, 0, Make_Priv (0));
         M   : constant Ada.Streams.Stream_Element_Array := Hex ("68656c6c6f");
         Sig : L.OTS_Signature;

      begin
         New_Line;
         Put_Line ("[Security.LMS]");

         --  Round trip: sign with leaf 0, verify against the public key.
         Sig := Make_OTS_Sig (0, Make_Priv (0), M);
         RunR.Check (L.Verify_OTS (L.LMOTS_SHA256_N32_W8, I, 0, M, Sig, K0), "LMS: valid OTS signature verifies");

         --  Tampered message must fail.
         declare
            M2 : constant Ada.Streams.Stream_Element_Array := Hex ("68656c6c69");
         begin
            RunR.Check (not L.Verify_OTS (L.LMOTS_SHA256_N32_W8, I, 0, M2, Sig, K0), "LMS: tampered message fails OTS verification");
         end;

         --  Tampered signature byte must fail.
         declare
            Bad : L.OTS_Signature := Sig;
         begin
            Bad (Bad'First + 100) := Bad (Bad'First + 100) xor 1;
            RunR.Check (not L.Verify_OTS (L.LMOTS_SHA256_N32_W8, I, 0, M, Bad, K0), "LMS: tampered signature fails OTS verification");
         end;

         --  Wrong leaf number must fail (signature bound to q = 0).
         RunR.Check (not L.Verify_OTS (L.LMOTS_SHA256_N32_W8, I, 1, M, Sig, K0), "LMS: wrong leaf number fails OTS verification");

         --  Wrong tree identifier must fail.
         declare
            I2 : constant L.Byte_Array (1 .. 16) := (others => 16#5A#);
         begin
            RunR.Check (not L.Verify_OTS (L.LMOTS_SHA256_N32_W8, I2, 0, M, Sig, K0), "LMS: wrong tree identifier fails OTS verification");
         end;

         Put_Line ("[Security.LMS] done.");
      end Test_LMS_Verify;

   begin
      Test_SHA256_Vectors;
      Test_HMAC_Vectors;
      Test_LMS_Verify;
   end Run;

end Test_Security;
