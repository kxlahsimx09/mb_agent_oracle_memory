---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 249
parent_thread: 249
parent_oracle: orchestrator
subject: DONE — AUTH-005 lockout-lifecycle fix (preserve-current) → PR #265
context: see thread #249 reply (msg 1179). Single-doc fix landed; awaiting your merge (§9).
needs_response: false
priority: normal
created: 2026-05-27T16:34:50+07:00
handled_at: 2026-05-27T16:36:00+07:00
handled_by_thread: 249
handled_note: AUTH-005 lockout-lifecycle fix DONE → PR #265 (preserve-current, no new ADR; two regimes incl sub_client; binding-#decision elevation left as [open question], not actioned). notify/needs_response=false. #249 CLOSED. Surfaced to user for merge (§9). Last held item of the arc.
---

AUTH-005 lockout-lifecycle fix DONE. PR #265 open, off current origin/main.
https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/265 — branch `writer/auth-005-lockout-lifecycle-249`.

PRESERVE-CURRENT, no new ADR (architect ruling #244). Single story AUTH-005 (epic-auth-rbac.md + INDEX row).

- Over-claim corrected: sign-in ENDPOINT rate-limit = platform-delegated (Supabase GoTrue) ✓ kept; account LOCKOUT lifecycle = app-logic on `banned_until` ban primitive (NOT Supabase-covered).
- Added: auto-lock-after-5 + TWO REGIMES (internal users = permanent hard lock, super-admin-unlock only; external tenants merchant/client/sub-client/partner = ~15-min soft auto-expiry) + admin-unlock.
- Cross-ref AUTH-002 (lock half); AUTH-002 left untouched.
- HELD elevation flagged in-doc as `[open question]` (two-regime → binding #decision needs §ADR-2 + user sign-off) — NOT actioned.

Trust: heading stays [S2 ratified]; lockout flagged inline preserve-current/S4; 5/15-min = current-prod baselines, not ratified.
P-004: all 6 claims verified against current code. Precision note: `sub_client` is in the external/Redis 15-min regime too (brief said merchant/client/partner) — included for faithfulness.
Gates: mermaid 5/5 PASS; MDX scan clean. Pass learning `2026-05-27_refresh-on-amendment-auth-005-lockout-lifecycle`.

I do not merge (§9) — over to you. Full content in thread #249 (msg 1179).
