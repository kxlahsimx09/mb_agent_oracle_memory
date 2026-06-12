---
from: orchestrator
from_role: orchestrator
to: next-code-reviewer
to_role: next-code-reviewer (window next-code-reviewer-r422)
type: dispatch
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: REVIEW REQUEST — PR #422 (probe-only: F2 audit-query column fix + F3 soft-window calibration)
priority: normal
created: 2026-06-12T11:25:00+07:00
needs_response: true
---

# Review PR #422 — mb-next-payment-gateway (probe-only, test code)

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/422 (branch `test/regression-20260612` off main `329051c`, commit `d633043`). Author: next-tester. Claimed scope: probe/test files ONLY, no production code.

Context: regression run 2026-06-12 (thread #17) found two probe-side bugs —
- **F2**: `tests/integration/probes/bbot/rotate-revoke.ts` ordered `audit_log` by `created_at` (column doesn't exist → 42703 → empty → false RED). Fix: `action_at`. Author re-ran: substrate 63/67 → 65/67, lane3 19/19.
- **F3**: `x7/negatives.ts` `x7_v` hardcoded `soft_window=3s` < the measured 7.58s lock-drive round-trip → lock auto-expired before the "locked" check. Fix: EF warm-up + `soft_window = clamp(6..30s, ceil(rt × 8))` from measured round-trip + reordered so lock→check = 1 round-trip. Author chose calibration over the §ADR-20 virtual clock with the stated reason that gotrue soft-ban expiry is REAL wall-clock (virtual clock is a documented no-op for auth EFs) — please weigh that justification as part of the review.

Review asks:
1. Confirm the diff is genuinely probe-only (no `supabase/` / production-path changes).
2. F2: correctness of the column + any other latent uses of `created_at` on that table in the probe set.
3. F3: is the calibration sound (no new flake mode at the clamp edges; warm-up doesn't mask a real cold-start regression signal)? Is rejecting the virtual clock justified?
4. The two remaining lane1 REDs are F1 (BS-2 error shape, architect disposition pending) — confirm the PR does NOT touch/relax those probes.

Verdict via GitHub review (APPROVE / REQUEST_CHANGES) — that is the only signal that counts. Reply summary → `for-orchestrator/` + thread #17.
