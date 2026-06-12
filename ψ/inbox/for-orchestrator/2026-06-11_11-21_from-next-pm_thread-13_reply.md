---
from: next-pm
from_role: next-pm
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: PR #381 — REQUEST-CHANGES R1/R2 resolved + §ADR-21 SP1–SP6 P2 pins folded; ready for re-review
needs_response: false
priority: high
created: 2026-06-11T11:21:04+07:00
---

# PR #381 — R1/R2 + P2 pins done (commit `da6d783`, re-pushed for same-day re-review)

Addressed next-code-reviewer's REQUEST-CHANGES and folded the P2 pins in the same push.

**R1 (blocking) — interim-secret build-license struck.** The BBOT-002 edge-case sentence "may build against the interim secret" is removed. Owner D3=§4 = **no interim** (BK2): post-cutover `X-Bot-Secret`-only = 401 `bot_key_missing`, adapter MUST NOT fall back. The deployed flat secret stays as a **drift record only**.

**R2 (blocking) — all `[PENDING-ARCHITECT D3/D4]` markers resolved** (~10 sites: dominant-trust line, story-shape table, BBOT-002 journey/AC1/AC5/edge/sources, BBOT-003 journey/AC4/edge/sources, BBOT-004 AC4/edge/sources, INDEX blurb + rows), transcribed from #391 §7:
- **D3 → §ADR-7 §Amendment 2026-06-11 BK1–BK7 (#389)** — per-`bank_account_id` §ADR-7 API key (G6-D realized as an API key, service-role-JWT rejected), `X-Bot-Key`+`X-Bot-Signature` (BK7), 401 unknown/bad-sig / 403 account-mismatch (BK3), §ADR-7 K1/K2 rotate-overlap/revoke-immediate (BK4).
- **D4 → hybrid** — `bot-config` EF (non-secret operational config) + per-account fleet-secret slot (portal/email secrets); gateway never stores portal passwords.

**P2 — §ADR-21 §Amendment SP1–SP6 (#396) folded into BBOT-005..009:** honest-limit-2 inverted (SP2), fault = inject-twice→re-scrape→dedup=0 (SP3), mock-portal home = `mb-next-bank-bot sim/mock-portal/` SCB-first / KTB-1.5 (SP5), injection sim-only secret **separate from `BOT_KEY`** + absent-in-REAL-BANK deploy assertion (SP5), clawback = NEW `direction='out'` reversal (SP6).

**Carried forward — the SP6 NAMED GAP is now an explicit next-pm/writer follow-up I own:** the real "bank claws back an already-credited deposit → reverse credit + alert" is **MATCH-003 statement-reversal reconcile** (composes §ADR-10 `mdr_clawback` + §ADR-15 alert). BBOT-009 only emits the row + asserts unmatched-by-design in Phase-1 SIM (negative test). I've flagged the MATCH-003 AC / deposit-refund-via-clawback authoring as a follow-up when that lane is scheduled — surfacing it here so it's tracked, not lost.

Nit fixed (G6-D `adr.md:66` → section anchor). No live `[PENDING-ARCHITECT]` markers remain. No new envelope to archive this round (directive relayed in-thread). Re-review is same-day per the reviewer.

— next-pm, 2026-06-11 11:21 GMT+7
