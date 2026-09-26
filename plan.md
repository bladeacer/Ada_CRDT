# Session Plan: v1.14.0 Release (Resumable)

Resume from this file. Everything below reflects the actual repo state on disk.

## Context Snapshot

- Branch: main. All 10332 tests pass (`make test`, baseline was 10290; new
  Security category adds 15, Fugue GC + purge tests included).
- `make prove` last result: **Silver, 1006 VCs, 11 unproved** (was 18 at session
  start; a mid-session round got it to 7 before the latest LMS/SHA edits raised
  it to 11).
- Op-based purge postcondition (`Log_GC (Log) = 0`) and all other new code
  outside the two crypto bodies already prove.
- SARIF for finding extraction: `obj/adacovex-proof/obj/gnatprove/gnatprove.sarif`
  (filter `might fail` / `unproved`; plain SARIF contains proved VCs too).
- `make prove` regenerates `sbom.json` and badges; exit 1 while any VC unproved.
- Prove invocation pattern (Makefile:124): swaps `alire-dev.toml` in, runs
  `adacovex prove --target=. --dal=C --emit-svg=docs/badges/ --no-loop-unrolling`.

## Task 1: Fix the Last SPARK Findings (target: Platinum, 0 unproved)

Remaining findings after the latest round (re-extract from SARIF after each run,
line numbers will shift):

- `crdt-security-sha256.adb:112` -- the declare-block LLI difference
  `(LLI (Bytes'Last) - LLI (Bytes'First)) + 1` cannot be proved: for an
  unconstrained `Stream_Element_Array` formal, bounds span the base type and
  the difference can overflow LLI.
- `crdt-security-lms.adb` -- `Coef` Pre (line ~43), `U32_At` Pre/Post/body
  (lines ~172-190): same root cause, arithmetic on `S'Last - S'First` and
  `S'Length` of unconstrained formals.

Root-cause knowledge (do not rediscover):

- gnatprove cannot prove `'Length`, `'Last - 'First`, or bound-difference
  arithmetic on **unconstrained** `Stream_Element_Array` formals because the
  base-range bounds can overflow the arithmetic.
- Precedent that works: `CRDT.Core.LEB128` (`src/core/crdt-core-leb128.ads`)
  uses `'Range` membership and bound-vs-constant comparisons only, and proves.
- Key insight: `U32_At` and `Coef` are only ever called with **constrained**
  subtypes (`OTS_Signature` 1..140, `LMS_Signature` 1..244, `N_String` 1..32,
  `Qc` 1..34). Changing the formals from unconstrained `Byte_Array` to those
  constrained subtypes makes `S'Length` statically known and every check
  trivially provable.

Concrete next fixes (apply in this order):

1. `crdt-security-lms.adb`:
   - `Coef`: change formal `S : Byte_Array` to `S : N_String`, Pre back to
     `Idx < S'Length` (statically 32). Callers pass `Q_Hash`/`Qc` (both
     N_String or 1..34; `Qc` is `Byte_Array (1 .. N_Length + 2)` -- change Qc
     decl to a subtype or keep Coef formal as `Byte_Array` but Pre
     `Idx <= S'Last - S'First`... no: simplest is make `Qc` an `N_String`
     sized 34 via its own subtype and give Coef a constrained formal).
     Preferred: `subtype Qc_String is Byte_Array (1 .. N_Length + 2);` and
     overload/typematch Coef's formal to the intersection: easiest is to keep
     one `Coef (S : Byte_Array; ...)` but add
     `Pre => S'First <= S'Last and then S'First + SEO (Idx) <= S'Last`
     (bound + constant only, no bound-bound subtraction). If still unproved,
     fall back to constrained formals + one Coef per call site type.
   - `U32_At`: change formal `S : Byte_Array` to `S : OTS_Signature`
     (constrained 1..140), Pre `Off + 3 < S'Length` or `Off in 0 .. S'Length - 4`
     (S'Length = 140 static). Keep LLI result + Post range 0 .. 2**32 - 1.
     Call sites already pass `Sig : OTS_Signature` and `Sig : LMS_Signature`;
     the Verify site passes a `LMS_Signature` -- slice it to its
     `OTS_Signature` prefix or give U32_At a second overload for
     `LMS_Signature` (the two calls are `U32_At (Sig, 0)` and
     `U32_At (Sig, 4 + OTS_Signature'Length)`; with constrained formals both
     prove).
2. `crdt-security-sha256.adb` `Update`: drop the bounds-difference block.
   Count bytes inside the existing loop instead -- `Ctx.Len := Ctx.Len + 1`
   per iteration of `for I in Bytes'Range` (modular increment per byte, no
   'Length, no bounds arithmetic anywhere). Keep `for I in Bytes'Range` byte
   streaming.
3. Re-run `make prove`; re-extract findings from SARIF; iterate. If a stubborn
   check remains, run gnatprove directly on one unit for a fast cycle:
   `alr exec -- gnatprove -P crdt.gpr -j0 -u crdt-security-lms.adb --no-loop-unrolling`
   (dev manifest must be swapped in: same pattern as Makefile prove target).
4. Each prove round must be followed by `make test` staying 10332/0.

Definition of done: `make prove` exits 0 and prints Platinum with 0 unproved;
`./test_crdt` still passes 10332.

## Task 2: Third-Party Notices + Credits

- `docs/THIRD_PARTY_NOTICES.md`: add sections for the crypto/spec references:
  FIPS 180-4 (SHA-256), RFC 2104 (HMAC), RFC 4231 (HMAC test vectors),
  RFC 8554 (LMS/LM-OTS), NIST SP 800-208 (stateful hash-based signatures),
  RFC 8708 (HMAC-SHA-256 in X.509, optional mention). Spec references, not
  code copies -- mark them as normative references. Keep every existing
  attribution (Yjs engine port, Automerge/Fugue design references, etc.).
- `docs/CREDITS.md`: mirror the same additions, keep existing entries.
- Both files: ASCII only, British English (STE where user-facing).

## Task 3: Docs Reorganisation (adacovex-style)

Model: `../adacovex` docs tree (self-contained index pages per section,
`usage/` section, README links out to doc pages).

- Create `docs/usage/` with user-facing pages (new content, not just API):
  - `index.md` (self-contained section index)
  - `getting-started.md` (install via Alire, first PN-counter + LWW set, sync loop)
  - `engines.md` (Yjs vs Naive vs Fugue: when to pick which, GC behaviour)
  - `clock-strategies.md` (Lamport vs Vector vs Matrix, defaults, trade-offs)
  - `security.md` (SHA-256 integrity, HMAC psk deployments, LMS verify-only
    signing model, key provisioning guidance)
  - `sync.md` (state-based vs op-based, ack/purge lifecycle for op logs)
  - `serialization.md` (V1/V2/V3 wire formats, migration)
  - `engine-comparison.md` (upstream robustness comparison vs Yjs/Automerge --
    the not-yet-done objective 6; source notes from earlier docs/index.md
    drafts)
- Each section index page must be self-contained (no "see above" chains).
- README.md: replace bare repo-internal links with links to the new doc pages;
  keep Quick Reference table (generated).
- AGENTS.md: adopt the adacovex docs-writing guidelines section sensibly
  (read `../adacovex/AGENTS.md` first), do not copy verbatim; keep our STE
  overrides and changelog conventions.
- Regenerate/update: `tools/agents-tree.map` (+ `make agents-tree`) for
  `src/security/` and new files; `tools/doc-links.map` (+ `make doc-links`) for
  new docs.
- STE rules apply to all new docs: British English, ASD-STE100 via vendored
  `skills/simple-english/`, max 4 sentences per paragraph, check
  `docs/ste100-technical-names.md` before coining terms. ASCII only.

## Task 4: Compliance Artifacts

- `make prove` currently fails the DAL-C gate with "Orphan HLR tags found in
  source": `HLR-SEC-SHA256`, `HLR-SEC-HMAC`, `HLR-SEC-LMS` (in
  `crdt-security*.ads`) and `SYNC-ACK` (in `crdt-sync-op_based.ads`) are in
  source but missing from `docs/compliance/HLR.md`.
- Add HLRs for: SHA-256, HMAC, LMS, and causal ack/purge (SYNC-ACK). Check
  whether Fugue `Compact` (GC) needs its own tag or folds into an existing
  sequence HLR.
- Update `docs/compliance/LLR.md` (map new HLRs to subprograms: `SHA256.Update/
  Final/Digest`, `HMAC.Compute/Equal`, `LMS.Verify/Verify_OTS/Compute_KC`,
  `Op_Based.Acknowledge_From/Purge_Acknowledged/Min_Unacked_Seq`,
  `Fugue.Compact/Unlink_Node`) and `docs/compliance/TRACE.md` (both directions).
- Regenerate `docs/api-docs/crdt-spark-coverage.md`:
  `python3 tools/gen-coverage.py` (no new SPARK_Mode => Off scopes exist --
  verify).

## Task 5: Version Bump + Changelog

- `make bump-version VERSION=1.14.0` (updates alire manifests, AGENTS.md,
  release/index tomls).
- Write `docs/changelogs/crdt-1.14.0.md` in the canonical format
  (template: `docs/changelogs/crdt-1.13.0.md`): `### CRDT 1.14.0`, italic
  Date line, theme summary, `## Changes` (C1..Cn: RTD docs, Fugue tombstone
  GC, causal history purge, PQ security layer, clock strategy docs),
  `## Fixes` if applicable, `## Test Suite` (10332 passing), `## Proof
  Results` (table with final numbers from gnatprove.out after Task 1),
  `## Traceability` (28 HLR tags after additions -- confirm count),
  `## Breaking Changes` (None. + justification), `## Version`
  (Bumped from 1.13.0 to 1.14.0.).
- Style: ASCII, `--` dashes, Title Case headings, sentence case text.

## Task 6: Final Gate Run (in this order)

1. `make test` -- 10332 passing.
2. `make prove` -- Platinum, 0 unproved (regenerates badges + sbom.json).
3. `make changelog-check`
4. `make link-check`
5. `make ascii-check`
6. `make spark-off-check`
7. `make compliance` -- regenerates VERIFICATION.md; must pass (proof stats +
   test count + HLR consistency).
8. `make doc` if docstrings changed enough to warrant regen; verify
   `docs/api-docs/` + Quick Reference.
9. Optionally RTD build check: sphinx build still succeeds with new docs pages.

## Notes / Gotchas

- `make test` writes `test_result.md` -- run before `make compliance` so the
  verification report picks up fresh counts.
- `make fmt` (gnatformat) if formatting drifts; gnatformat swaps dev manifest
  automatically.
- Do not commit anything unless asked.
- Fugue ordering gotcha for future tests: document order follows Node_Id sort,
  not insertion position (GC'd slot reuse inserts by Id order).
- The sibling adacovex is at `../adacovex` (used by make prove; also the docs
  structure template).

Also update associated docs and third party notices once all of this is done.
