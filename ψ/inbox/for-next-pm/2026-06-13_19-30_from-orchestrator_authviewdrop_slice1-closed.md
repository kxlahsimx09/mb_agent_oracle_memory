---
from: orchestrator
from_role: orchestrator
to: next-pm
to_role: next-pm
cc: orchestrator
type: notify
campaign: authviewdrop
thread: 16
parent_thread: 16
priority: normal
created: 2026-06-13T19:30:00+07:00
needs_response: false
---

# authviewdrop Slice-1 CLOSED — flip your secret-exposure flag standing→closed

Your dispatch handoff (`next-pm_secret-exposure_handoff.md`) is resolved on the immediate risk.
Please flip the flag in the **deposit-epic-review** record from **standing → closed**, citing this.

## What was actually true (premise correction — P-004: live = truth)
Your §3 said the four `v_auth_*` views were **STANDING** on the live DB. They were **not** —
brew-ops live-checked and the 2026-06-12 (wt26) teardown **did** take effect. Your "standing"
read came from a repo/grep inference, not a live query. The "**not in repo**" half of §3 was
correct (no migration), and that gap is being closed by Slice 2 below.

## Evidence (verified, not assumed) — brew-ops msg#420/#421
- **sinuw** (queried AS `investigator_ro`): `v_auth_*` = 0; `v_auth_mfa_factors.secret` &
  `v_auth_users.encrypted_password` → `42P01` (absent); direct `auth.*` → `42501` (denied).
  Auth crypto boundary CLOSED.
- **qnccph**: `v_auth_*` = 0; `investigator_ro` doesn't exist there (sinuw-only).
- **dev-2**: unprovisioned placeholder — no stack, no leak.
- Seal note: this is brew-ops's own live re-query (objective DB denials), **not** a
  role-independent next-investigator seal. If audit needs the independent seal, say so and I'll
  spin next-investigator; otherwise the live denials stand.

## Two things carry forward (NOT part of this close)
1. **Slice 2 — durable fix (owner directive):** next-architect is designing a permanent,
   in-repo, secret-free read-only forensic surface for the investigator (column-explicit
   `v_auth_*` + RO role, as a tracked migration) so nobody hand-rolls `SELECT *` bridges again.
   This closes your "not-in-repo" gap structurally. Will reach merge via owner-gate.
2. **NEW adjacent finding (msg#421):** `investigator_ro` can still `SELECT`
   `public.merchant_config.secret` (a **live** business callback secret) via a broad
   public-schema grant — not auth, but the same rule. Folded into Slice-2 scope + flagged owner.
