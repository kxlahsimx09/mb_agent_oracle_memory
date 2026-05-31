---
title: [repo: kxlahsimx09/mb-next-payment-gateway — project slug not yet registered in 
tags: [requirements, adr, payout, statement-matching, wallet, idempotency, campaign-gapw3]
created: 2026-05-30
source: next-writer (campaign gapw3)
---

# [repo: kxlahsimx09/mb-next-payment-gateway — project slug not yet registered in 

[repo: kxlahsimx09/mb-next-payment-gateway — project slug not yet registered in running Oracle MCP; fleet JSON .agent/fleet/20-mb-next-payment-gateway.json exists, needs server restart]

Campaign gapw3 (branch writer/gapw3-tier3b): 4 ADR-backed AC/edge-case additions to existing requirement stories in docs/requirements/, all re-verified against HEAD 0fb63c0 + cited ADR before editing. All 4 landed (none skipped).

EDIT 1 — epic-payout.md PAYOUT-001 §Edge-cases: a payout whose amount falls outside the withdrawal min/max band of EVERY active bank in the pool is unroutable; fair-router selects no bank, payout stays pending, NO error callback at this stage (already accepted at create). Waits for operator band reconfig / PAYOUT-008 auto-cancel / PAYOUT-010 maintenance backstop. Lane-local cross-reference to BOT-001 (owns the fair-router side, PR #261) — no duplication. Cite §ADR-8 §Amendment 2026-05-26 AF2 (docs/adr.md ~line 1831 — "current-system behavior verbatim", unroutable item stays pending_routing).

EDIT 2 — epic-statement-matching.md MATCH-003 AC: payout-driven trigger — when a payout transitions into review (stuck-claim sweep / mark_review) the outbound matcher fires to link an already-ingested unmatched direction='out' debit row to it; distinct from statement-driven trigger and pg_cron safety-net sweep. Cite §ADR-4a §Amendment 2026-05-16 RR1 (the three trigger paths a/b/c, docs/adr.md ~line 350-353; (b) payout-driven is the primary hit path).

EDIT 3 — epic-wallet-ledger.md WALLET-003 AC: super-admin designates a partner wallet as the system-residual MDR bucket; exactly one wallet carries is_owner at any time (designating a new one atomically clears the prior); a read returns the current system-residual wallet. Cite §ADR-10 D1 (docs/adr.md ~line 2356-2357 — "is_owner=true is a single-row constraint, exactly one system-residual wallet"). WALLET-003 chosen over WALLET-005 because it is the MDR-distribution story and already references the system-residual wallet as platform-as-partner.

EDIT 4 — epic-client-api.md CLIENT-001 AC: replay guarantee applies to ALL stored responses including error responses — same-key/same-body retry of a request that originally returned a 4xx-class outcome replays that stored error without re-executing payment logic. Framed as product behavior; status/body shape left to impl per ADR. Cite §ADR-11 Decision #4 / C4 (docs/adr.md ~line 2523-2524 — "same key + same body within TTL → return stored response"; GW3 line 127 confirms stored response captured from handler/RPC).

Revision log: added one epic-payout-revision-log.md entry for the PAYOUT-001 change (other 3 epics noted only in PR body per scope). One PR against main, not merged.

Verification note: ADR-10 D1 cleanly backs the single-row is_owner invariant + atomic-clear + read; "super-admin designates" actor framing is the product wrapper (admin write surface governed by §ADR-13, already cited in epic-wallet-ledger). ADR-11 C4 + Decision #2 response_snapshot + GW3 cleanly back error-response replay; no wire-format pinned.

---
*Added via Oracle Learn*
