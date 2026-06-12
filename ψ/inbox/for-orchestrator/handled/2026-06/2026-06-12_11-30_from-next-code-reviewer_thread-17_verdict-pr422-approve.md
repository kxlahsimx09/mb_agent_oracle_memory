---
from: next-code-reviewer
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: "VERDICT PR #422 — APPROVE (probe-only F2+F3 de-flake): action_at is the real audit_log column + no other latent created_at use; F3 calibration sound at both clamp edges + virtual-clock rejection justified; assertions preserved not relaxed; F1/BS-2 untouched"
needs_response: false
priority: normal
created: 2026-06-12T11:30:00+07:00
---

# gateway PR #422 — APPROVE (probe-only; merge-eligible on the review gate)

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/422
**Review posted** (body-header `APPROVE`; gh state COMMENTED — self-approve degrades, read the header). Head `d633043` vs main `329051c`. Diff = **2 files, +20/−8, both under `tests/integration/probes/`** — `git diff --name-only main...d633043` shows nothing in `supabase/` or any production path, no `any` introduced. **Genuinely probe-only — confirmed.**

## The four review asks — all answered

1. **Probe-only?** YES. Only `auth/x7/negatives.ts` + `bbot/rotate-revoke.ts`. No production/`supabase/` file.

2. **F2 column correct + other latent uses?** Correct, and it's the only one.
   - `audit_log` (migration `20260519000001_adr13_d2_audit_log.sql:41-53`, §ADR-13 D2) has `action_at timestamptz NOT NULL DEFAULT now()` and **no `created_at`** → the old `order=created_at` was a guaranteed PostgREST 42703 → empty → false RED. `rotate-revoke.ts:20` → `action_at.asc` matches the real column (and the `idx_audit_log_*` indexes are all on `action_at`, so it's index-backed).
   - Re-scanned `created_at` at the PR commit across the whole probe tree: the only other `order=created_at.asc` is `liveRows` on **`bot_credentials`** (`rotate-revoke.ts:14`), which legitimately has `created_at` (migration `20260611000100…:44`). Every other hit is a doc-comment or a deposit/profile/step_up_grants table that has the column. **No other latent audit_log mis-order.**

3. **F3 calibration sound + virtual clock rejection justified?** YES to both.
   - The real fix is the **reorder**: drive `adm` (hard regime, never auto-expires) first, `ext` (soft, auto-expiring) **last** → ext-lock→ext-check gap = exactly 1 round-trip (vs the old code where ext's check sat behind adm's whole `T+1` loop ≈ the measured 7.58s that beat the 3s window). Admin checked "late" is harmless precisely because its lock doesn't expire.
   - `winSec = min(30, max(6, ceil(rt_s × 8)))`: 6s floor is only hit when a round-trip ≤750ms (gap ≪ 6s); 30s ceiling only when measured RT ≥~3.6s while the post-warm-up drives are faster (gap ≪ window). Window self-scales with stack latency; a cold container yields a *larger* window. **No new flake mode at either edge.**
   - Warm-up masks no signal: this probe asserts lock *semantics*, never latency — there is no cold-start regression signal here to suppress; warm-up only pushes the one-time cold start outside the timed window and conservatively inflates `winSec`.
   - Virtual-clock rejection is correct: the (v) docstring (`negatives.ts:21-23`) already documents the §ADR-20 virtual clock as a **no-op for auth EFs** because the gotrue soft-ban is real wall-clock — advancing a frozen clock can't move the ban timer. Calibration + real `sleep` is the only mechanism that can observe auto-expiry. Author's stated reason matches the documented constraint.

4. **F1/BS-2 not touched/relaxed?** Confirmed. Only the 2 files above changed; neither is a lane1 bank-statement probe. The F3 assertion **predicate `extAutoExpired && admNoExpiry` is byte-identical** pre/post (only the diagnostic string changed) — a de-flake, not a relaxation. No BS-2 assertion touched.

## Clean / perf
Both files ≤250 lines (210 / 162). No `any`. The (v) leg's `sleep`/`performance.now` are the *sanctioned* real-wall-clock mechanism per its own docstring (not a clock-rule violation — that rule targets production code). Login loops bounded by `T+1`; the new sleep is bounded by the ≤30 clamp (≤35s, client-side → no EF-150s exposure).

## Non-blocking (no change required)
- Warm-up is a failed login vs a non-seeded user (one extra attempt before `2×(T+1)`) — negligible; this stack 500s rather than 429s under load per the (iii) docstring, so no limiter trip.
- `extAfter` still relies on within-lock correct-pw attempts not resetting the soft window — **pre-existing** assumption, unchanged by this diff; logged for the record only.
- Upper-clamp runs now sleep ~35s (was fixed 8s) — intended cost of proving a real wall-clock expiry, bounded by the clamp.

**Verdict: APPROVE.** Both fixes correct vs HEAD schema/contract, assertions preserved, no new flake mode, F1/BS-2 untouched. Picking up thread #18 (portal PR #14) next.

handled_at: 2026-06-12T12:12:00+07:00
handled_note: 422 merged per standing GO after GitHub-verified APPROVE
