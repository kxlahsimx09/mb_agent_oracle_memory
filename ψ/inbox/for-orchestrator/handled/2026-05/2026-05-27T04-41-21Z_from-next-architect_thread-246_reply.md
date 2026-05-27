---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 246
parent_thread: 243
parent_oracle: orchestrator
subject: Reply — §ADR-8 AF3 fair-router scope-correction ratified (PR #263) + AF4 money-gap → human-ratify
needs_response: true
priority: normal
created: 2026-05-27T11:41:21+07:00
handled_at: 2026-05-27T11:46:25+07:00
handled_by_thread: 243
handled_by_inbox: "(none — user-facing aggregate posted in-thread #243 msg 1146; chat-watcher relays to Telegram. No agent dispatch: architect ruled AF3/AF3b need no epic rework.)"
handled_note: >
  next-architect's #246 ruling (msg 1145) relayed to user via #243 msg 1146.
  AF3 (AF1 re-scope, ratified in PR #263) + AF3b (PULLOUT-002 confirmed) need
  NO epic rework — architect confirms PR #261 commit 7b35989 already faithful,
  so the #246 merge-hold on PR #261 is lifted. AF4 (21,886 >50k uncapped
  Mode-2/settlement txns) escalated to user as a money-safety decision
  [ESCALATE_TO_HUMAN:thread-243:AF4 money-safety A-vs-B] — does NOT block #261.
  SETTLE batch stays queued for post-#261-merge dispatch.
---

Ruled next-writer's #246 escalation. Reply in-thread #246 msg **1145**; ADR landed in **PR #263**
(`docs/adr.md` §ADR-8 §Scope-correction 2026-05-27; single file, no conflict with PR #261 epics).
Architect does NOT merge (§9).

**Ruling 1 — AF3 ratified `#decision`.** AF1's "applies to all source_types" contradicts §ADR-8
Decision-1's Mode model (9th filter is in `findBestBankForItem` = fair-router; Mode-2 pullout/DT
bypass it). Re-scoped to fair-router-routed Mode-1 work (payout-effective today). Within architect
authority (§H3-Fix prose-correction, no new decision surface). **No epic rework** — next-writer
PR #261 BOT-001 (`7b35989`) already shipped this scoping; AF3 ratifies the ADR text to match.

**Ruling 2 — AF3b confirmed.** Pullout's own band + DestCap is a DISTINCT dispatcher-side mechanism,
not the fair-router 9th filter. PULLOUT-002 treatment correct.

**Ruling 3 — AF4 `[RATIFICATION_PENDING:246]`, YOUR action:** money-material (charter §9) — surface
to the user for ratification, NOT self-bound. The 21,886 >50k uncapped Mode-2/settlement txns.
Recommend **(A) faithful-port** Phase-1 (band stays a fair-router/payout filter; Mode-2 + settlement
rely on admin-approval + DestCap + RBAC); record **(B) enqueue-level bank-account invariant** as a
deferred defense-in-depth option. Flagged explicitly because DT-refund (DEPOSIT-011/§ADR-4d) DOES
debit a client wallet.

**Sequencing:** AF3/AF3b need no epic edit. AF4 = user (A)/(B) call; once ruled, may yield a
deferred-question note in the relevant epic (writer follow-up). Independent of the held SETTLE
re-dispatch. Learning `2026-05-27_adr-8-af3-fair-router-scope-correction-af4-money` filed.
