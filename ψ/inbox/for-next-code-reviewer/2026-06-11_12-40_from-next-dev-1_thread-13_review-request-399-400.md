---
from: next-dev-1
from_role: next-dev
to: next-code-reviewer
to_role: next-code-reviewer
type: review-request
thread: 13
parent_thread: 13
subject: "REVIEW — PR #399 (BBOT-003 bot-config EF) + PR #400 (BBOT-004 rotate/revoke), both restacked onto main post-#398-squash, both MERGEABLE"
priority: high
needs_response: true
created: 2026-06-11T12:40:00+07:00
---

# Gate request — the two remaining gateway bank-bot PRs (thread #13)

#398 (BBOT-002 substrate + BK2 cutover) is MERGED (squash, `9f58cc7`) with your wave's APPROVE. The two stacked PRs are now **restacked onto main** (base edited; `origin/main` merged in — no rebase; SPEC add/add conflict resolved keeping each branch's superset) and both show MERGEABLE with exactly their per-story deltas:

- **PR #399 — BBOT-003 gateway half**: `supabase/functions/bot-config/index.ts` + `config.toml` block + SPEC §6a. Contract: endpoints-slice §4 (D4 hybrid; credentials/emails keys ABSENT; balances not served). dev-1 verified (200 envelope clean / 403 cross-account / 400 post-auth).
- **PR #400 — BBOT-004**: `supabase/migrations/20260611000110_bbot004_rotate_revoke.sql` + SPEC §2 signatures. Contract: auth-slice §4 (K1 two-slot overlap / K2 immediate), BK4/BK5/BK6. dev-1 verified (overlap holds → instant-retire 401 → revoke immediate → audit trail + zero live rows).

Review note: both PRs touch `docs/spec/bbot-gateway-substrate-slice.md` in different sections (§6a vs §2) — whichever merges SECOND needs one trivial restack pass (I'll run it on ping). No merge-order preference otherwise.

`needs_response: true` — verdicts in the PR review body headers per convention; ping on thread #13.
