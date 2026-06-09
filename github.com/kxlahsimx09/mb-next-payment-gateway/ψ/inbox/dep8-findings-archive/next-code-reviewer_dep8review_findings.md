# next-code-reviewer — dep8review findings

**PR:** #334 — DEPOSIT-008 admin verify-slip-now — RBAC perm rename to `deposit:verify-slip` (+ Step-0 SPEC)
**Branch:** campaign/dep8dev → main
**Verdict:** ## VERDICT: APPROVE
**Reviewed:** 2026-06-07

## Scope of the genuine delta
Code-only delta on top of the ~95% pre-deployed substrate. 5 files, +218/-22:
- `supabase/functions/admin-deposit-verify-now/index.ts` — `requirePermission` arg rename + header comment refresh (flags resolved).
- `supabase/functions/_shared/admin-auth.ts` — `ROLE_PERMISSIONS.super_admin` entry rename.
- `poc/integration/src/gateway/middleware/admin-auth-core.ts` — byte-aligned core map rename.
- `poc/integration/src/probes/deposit-verify-slip-now.ts` — AC8 403 assertion rename.
- `docs/spec/deposit-008-verify-now-slice.md` — new Step-0 SPEC (test-facing contract).

The single functional change: RBAC permission string `deposit:verify-slip-now` → `deposit:verify-slip`.

## Dimension 1 — MEETS REQ + ADR ✅
- **RBAC name correct.** DEPOSIT-008 story (epic-deposit.md AC list + journey step 2) explicitly names `deposit:verify-slip`; §ADR-13 amendment F3 mandates the flat `<resource>:<action>` namespace; the string is consistent with the sibling `deposit:resend-callback` / `deposit:upload-slip`. The prior `-now` suffix was a mechanically-derived guess (old thread #174 G-6 flag); this rename is the right ratified value. Without it a `super_admin` granted `deposit:verify-slip` would 403 (AC1-3 break) and AC8's `required_permission` body would be wrong.
- **Rename complete + byte-aligned.** Applied at all 3 functional sites (EF `requirePermission` call L76, EF `_shared` map L57, gateway core map L51) plus the probe assertion (L234). The two `ROLE_PERMISSIONS` maps remain identical. No stray `deposit:verify-slip-now` perm string remains in executable code — remaining `verify-slip-now` hits are endpoint-path / dir-name / prose only (`/admin/deposits/:id/verify-slip-now`, EF dir, error detail strings), which are correct and unchanged.
- **ADR-4d Amendment 2026-05-20 verdict-only-flip (VF1/VF2).** Correctly out of this delta — the flip lives in the `record_slip_verify_attempt` / `admin_verify_slip_now` RPC (migration 20260519000010 / 20260520000008). EF passes verdict through; RPC flips `pending→checking` only on `genuine`/`forged`, no flip on `thunder_system_error`/`thunder_timeout`. EF docstring item 2 describes this accurately. Matches AC1/AC2/AC6.
- **Append-only D9 (AC7), admin-owns-terminal D5 (AC2 no auto-reject), one-per-call batch→400 (AC9), terminal→409 (AC4), no_slip→400 (AC5), 404 not_found** — all present and correct in the EF shell + RPC contract; mockThunder error/timeout → `error_message` set, `thunder_response_raw` null (AC6). The `mockThunder` valid-verdict set matches the §ADR-4d D4 outcome set.

## Dimension 2 — CODE CLEAN ✅ (2 cosmetic nits, non-blocking)
- Rename is clean, comments refreshed accurately, both prior #174 G-6 flags retired with correct rationale. `requirePermission` returns `{error:"forbidden", required_permission: perm}` so the 403 body echoes the new string automatically (no hardcoded duplicate).
- **Nit 1 (pre-existing, not in diff):** EF docstring L4-5 says "15-minute sweep"; the requirements + §ADR-4d D3 amendment 2026-06-01 use a 5-minute operator-tunable default anchored on `slip_uploaded_at`. Stale prose, untouched by this PR.
- **Nit 2:** probe docstring L14 still reads "RBAC `deposit:verify-slip-now`" while the live assertion at L234 was renamed. Cosmetic comment drift; harmless. Worth a one-line tidy on a later pass.

## Dimension 3 — PERF ✅
- EF is a thin auth+RPC shell: one `app_user` read (in `adminAuth`) + one `admin_verify_slip_now` RPC. No loops, no N+1, no added round-trips. `mockThunder` is trivial and mock-only (prod swaps in the real HTTP call). The rename adds zero runtime cost. No concerns.

## Noted deviation (documented + acceptable)
AC8 wording groups "no permission OR no valid admin JWT" under one 403. The substrate splits per HTTP convention: **403** = valid token, role lacks `deposit:verify-slip`; **401** = missing/malformed/unknown token. The SPEC §1 explicitly documents this as binding for AC8 and both paths satisfy the observable invariant (request rejected, no Thunder call, no `slip_verify_attempts` row). HTTP-correct and a reasonable, pre-disclosed design decision — not a blocker.

## Conclusion
The genuine delta is correct, complete, byte-aligned, and faithful to the DEPOSIT-008 9 ACs, §ADR-13 F3, and §ADR-4d D4/D5/D8/D9 + the 2026-05-20 verdict-only-flip amendment. Only cosmetic comment nits remain. **APPROVE.**
