package body CRDT.Security.SHA256
  with SPARK_Mode
is

   use type Word32;

   --  Round constants (fractional parts of cube roots of the first 64
   --  primes, FIPS 180-4 section 4.2.2).
   K : constant array (0 .. 63) of Word32 :=
     (16#428A2F98#,
      16#71374491#,
      16#B5C0FBCF#,
      16#E9B5DBA5#,
      16#3956C25B#,
      16#59F111F1#,
      16#923F82A4#,
      16#AB1C5ED5#,
      16#D807AA98#,
      16#12835B01#,
      16#243185BE#,
      16#550C7DC3#,
      16#72BE5D74#,
      16#80DEB1FE#,
      16#9BDC06A7#,
      16#C19BF174#,
      16#E49B69C1#,
      16#EFBE4786#,
      16#0FC19DC6#,
      16#240CA1CC#,
      16#2DE92C6F#,
      16#4A7484AA#,
      16#5CB0A9DC#,
      16#76F988DA#,
      16#983E5152#,
      16#A831C66D#,
      16#B00327C8#,
      16#BF597FC7#,
      16#C6E00BF3#,
      16#D5A79147#,
      16#06CA6351#,
      16#14292967#,
      16#27B70A85#,
      16#2E1B2138#,
      16#4D2C6DFC#,
      16#53380D13#,
      16#650A7354#,
      16#766A0ABB#,
      16#81C2C92E#,
      16#92722C85#,
      16#A2BFE8A1#,
      16#A81A664B#,
      16#C24B8B70#,
      16#C76C51A3#,
      16#D192E819#,
      16#D6990624#,
      16#F40E3585#,
      16#106AA070#,
      16#19A4C116#,
      16#1E376C08#,
      16#2748774C#,
      16#34B0BCB5#,
      16#391C0CB3#,
      16#4ED8AA4A#,
      16#5B9CCA4F#,
      16#682E6FF3#,
      16#748F82EE#,
      16#78A5636F#,
      16#84C87814#,
      16#8CC70208#,
      16#90BEFFFA#,
      16#A4506CEB#,
      16#BEF9A3F7#,
      16#C67178F2#);

   function Initial_Context return Context is
   begin
      return Context'(H => (16#6A09E667#, 16#BB67AE85#, 16#3C6EF372#, 16#A54FF53A#, 16#510E527F#, 16#9B05688C#, 16#1F83D9AB#, 16#5BE0CD19#), Len => 0, Buf => (others => 0), BufN => 0);
   end Initial_Context;

   function SHR (X : Word32; N : Natural) return Word32
   is (Shift_Right (X, N));

   function ROTR (X : Word32; N : Natural) return Word32
   is (Rotate_Right (X, N));

   function Ch (X, Y, Z : Word32) return Word32
   is ((X and Y) xor ((not X) and Z));

   function Maj (X, Y, Z : Word32) return Word32
   is ((X and Y) xor (X and Z) xor (Y and Z));

   function BSIG0 (X : Word32) return Word32
   is (ROTR (X, 2) xor ROTR (X, 13) xor ROTR (X, 22));

   function BSIG1 (X : Word32) return Word32
   is (ROTR (X, 6) xor ROTR (X, 11) xor ROTR (X, 25));

   function SSIG0 (X : Word32) return Word32
   is (ROTR (X, 7) xor ROTR (X, 18) xor SHR (X, 3));

   function SSIG1 (X : Word32) return Word32
   is (ROTR (X, 17) xor ROTR (X, 19) xor SHR (X, 10));

   --  Compress one 64-byte block into the chaining state.
   procedure Compress (Ctx : in out Context; Block : Byte_Array_64) is
      W                       : array (0 .. 63) of Word32 := (others => 0);
      A, B, C, D, E, F, G, Hh : Word32;
      T1, T2                  : Word32;
   begin
      for T in 0 .. 15 loop
         W (T) := (Word32 (Block (4 * T + 1)) * 2**24) or (Word32 (Block (4 * T + 2)) * 2**16) or (Word32 (Block (4 * T + 3)) * 2**8) or Word32 (Block (4 * T + 4));
      end loop;
      for T in 16 .. 63 loop
         W (T) := ((SSIG1 (W (T - 2)) + W (T - 7)) + SSIG0 (W (T - 15))) + W (T - 16);
      end loop;

      A := Ctx.H (1);
      B := Ctx.H (2);
      C := Ctx.H (3);
      D := Ctx.H (4);
      E := Ctx.H (5);
      F := Ctx.H (6);
      G := Ctx.H (7);
      Hh := Ctx.H (8);

      for T in 0 .. 63 loop
         T1 := (Hh + BSIG1 (E)) + (Ch (E, F, G) + (K (T) + W (T)));
         T2 := BSIG0 (A) + Maj (A, B, C);
         Hh := G;
         G := F;
         F := E;
         E := D + T1;
         D := C;
         C := B;
         B := A;
         A := T1 + T2;
      end loop;

      Ctx.H (1) := Ctx.H (1) + A;
      Ctx.H (2) := Ctx.H (2) + B;
      Ctx.H (3) := Ctx.H (3) + C;
      Ctx.H (4) := Ctx.H (4) + D;
      Ctx.H (5) := Ctx.H (5) + E;
      Ctx.H (6) := Ctx.H (6) + F;
      Ctx.H (7) := Ctx.H (7) + G;
      Ctx.H (8) := Ctx.H (8) + Hh;
   end Compress;

   procedure Init (Ctx : out Context) is
   begin
      Ctx := Initial_Context;
   end Init;

   procedure Update (Ctx : in out Context; Bytes : Byte_Array) is
   begin
      --  Stream one byte at a time through the partial block buffer.
      --  BufN is bounded by its subtype to a partial block, so the
      --  buffer index and the full-block test need no extra reasoning.
      --  The byte counter is a 64-bit modular value incremented once
      --  per streamed byte: modular arithmetic wraps instead of
      --  overflowing, and the wrap matches the 64-bit bit-length
      --  field of the FIPS 180-4 padding rule. Counting inside the
      --  loop keeps 'Length and bound-difference arithmetic out of
      --  this unit: gnatprove cannot bound that arithmetic for an
      --  unconstrained array formal, while a modular per-byte
      --  increment needs no bounds knowledge at all.
      for I in Bytes'Range loop
         Ctx.Len := Ctx.Len + 1;
         Ctx.Buf (Ctx.BufN + 1) := Bytes (I);
         if Ctx.BufN + 1 = Block_Length then
            declare
               --  Compress takes a local copy of the full block: Ctx
               --  is an in out actual of the same call, and passing
               --  Ctx.Buf directly would alias the two formals
               --  (SPARK RM 6.4.2).
               Full : constant Byte_Array_64 := Ctx.Buf;
            begin
               Compress (Ctx, Full);
            end;
            Ctx.BufN := 0;
         else
            Ctx.BufN := Ctx.BufN + 1;
         end if;
      end loop;
   end Update;

   procedure Final (Ctx : in out Context; Out_D : out Hash) is
      Pad  : Byte_Array (1 .. 72) := (others => 0);
      Bits : constant Count := Ctx.Len * 8;
      PadZ : Natural;
   begin
      --  0x80 terminator, zeros, then the 64-bit big-endian bit count.
      --  BufN is bounded by its subtype, so both branches give
      --  PadZ in 0 .. 63 and the padded total reaches a multiple of 64.
      Pad (1) := 16#80#;
      if Ctx.BufN < 56 then
         PadZ := 55 - Ctx.BufN;
      else
         PadZ := 119 - Ctx.BufN;
      end if;

      --  The counter is modular, so the product wraps exactly like the
      --  FIPS 180-4 length field.
      for K in Natural range 0 .. 7 loop
         declare
            Div : constant Count := Count'(2**(8 * (7 - K)));
            Pos : constant Natural := (2 + PadZ) + K;
         begin
            Pad (Ada.Streams.Stream_Element_Offset (Pos)) := Byte ((Bits / Div) and 255);
         end;
      end loop;

      --  Update consumes terminator + zeros + length.
      Update (Ctx, Pad (1 .. Ada.Streams.Stream_Element_Offset ((1 + PadZ) + 8)));

      Out_D := (others => 0);
      for I in Natural range 1 .. Hash_Length loop
         declare
            Wd  : constant Word32 := Ctx.H (((I - 1) / 4) + 1);
            Sel : constant Natural := (I - 1) mod 4;
         begin
            Out_D (Ada.Streams.Stream_Element_Offset (I)) := Byte (Shift_Right (Wd, 8 * (3 - Sel)) and 16#FF#);
         end;
      end loop;
   end Final;

   procedure Digest (Bytes : Byte_Array; Out_D : out Hash) is
      Ctx : Context;
   begin
      Init (Ctx);
      Update (Ctx, Bytes);
      Final (Ctx, Out_D);
   end Digest;

end CRDT.Security.SHA256;
