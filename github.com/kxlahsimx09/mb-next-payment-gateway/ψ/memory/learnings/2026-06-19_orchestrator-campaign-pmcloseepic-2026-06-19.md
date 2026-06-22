---
title: Orchestrator campaign `pmcloseepic` (2026-06-19) — close-every-closeable-epic sw
tags: [orchestrator, team-dispatch, pmcloseepic, epic-done, buildepic, srcflow-001-precedent, live-gate-na, ci-teeth-conformance, false-green-pin-rot, callback-rf1-ssrf, wallet-004-007-gap, client-api, payout-seal, admin-audit, next-pm, accepted, repo:mb-next-payment-gateway]
created: 2026-06-19
source: orchestrator campaign pmcloseepic — close-every-closeable-epic, 2026-06-19
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Orchestrator campaign `pmcloseepic` (2026-06-19) — close-every-closeable-epic sw

Orchestrator campaign `pmcloseepic` (2026-06-19) — close-every-closeable-epic sweep, 4 epics closed. Owner asked the PM to find epics not-yet-closed-but-closeable and close them all (+ do doable dev). RESULT: 4 epic-DONE marks (docs-flip PRs, OWNER-merge per §9a): #644 statement-matching, #646 admin-audit, #647 callback-delivery, #648 client-api. Supporting build-CODE PRs MERGED: #641 (matching CI-teeth), #640 (admin-audit CI-teeth), #643 (callback RF1 fix), #642 (client-api idempotency+rate-limit).

KEY MECHANICS / REUSABLE LESSONS:
1. The closeable-NOW bucket was EMPTY at audit — the prior buildepic2 campaign had already flipped every green-but-unmarked non-money epic. So "close the rest" meant DOING the missing gate work, not just marking.
2. The 3 bucket-E "built-as-substrate" epics (admin-audit, statement-matching, callback-delivery) closed via the SRCFLOW-001 (#618) precedent: next-architect ASSESS=satisfied-by-construction → next-dev static CI-teeth conformance test (fail-on-violation, no stack) + next-code-reviewer APPROVE [+ right-sized next-investigator seal] → next-pm mark. All NON-money → §ADR-21 LIVE-gate N/A (owner P1 ruling 2026-06-19: "does money move? if not → LIVE-N/A").
3. SEALS HAVE TEETH — they caught real defects, not rubber-stamps: (a) next-code-reviewer caught a FALSE-GREEN in the admin-audit CI-teeth (#640) — 2 assertions pinned to SUPERSEDED fn defs (13-arg write_audit_log vs the live 15-arg); fix = re-point pins to authoritative-latest + a rot-guard asserting each pin is the LAST `CREATE FUNCTION <name>`. (b) callback seal found CALLBACK-003 RF1 (do-not-follow redirect) UNIMPLEMENTED — fetch had no redirect:'manual' (Deno follows by default = SSRF redirect-chain); fixed in #643. (c) wallet seal found WALLET-004 (admin signed-add adjustment) UNBUILT + WALLET-007 (typed reason_code) not-to-spec.
4. ADMIN-005 scoped-reader gap resolved by PARITY-WITH-CURRENT: dpay production exposes NO non-admin/partner/client audit read → the absent scoped reader is parity-faithful, a legit Phase-2 deferral, NOT a gap → admin-audit markable.
5. client-api (CLIENT-001 idempotency + CLIENT-002 rate-limit) was ~90% pre-built (thread-#254 PoC); dev added the idempotency TTL sweep + promoted the rate-limit substrate. dev-2 slot was UNPROVISIONED (.secrets/slots/dev-2.env all REPLACE_ME) → brew-ops did the cross-stack deploy to the TESTER stack (yupsevcrubgprsbujbpu) instead; tester 13/13 GREEN + investigator seal GREEN (served-from-store sentinel proof).
6. payout epic-seal GREEN (62/62 raw-row invariants) → payout now ONE owner live_signoff ACCEPT away. qnccph seal stack missing the 1-line payout001 hotfix due to a DUP-version 20260619000200 collision (dtr file won the slot) — loaded inside the seal txn; brew-ops should apply it to make the slot permanently current.

STILL OWNER-GATED (surfaced, not auto-done): auth-rbac LIVE-applicability ruling (architect recommends AUTH RIDES the money journey, not LIVE-N/A) + build gaps (AUTH-005 #626); bot-dispatch ADR-8 §Amendment to bless the shipped blocking-lock model + build BOT-003 recovery legs; wallet WALLET-004/007 builds; money live_signoffs (deposit/payout sealed; topup/source-flows/BENE-007 need their own LIVE acts authored); monitoring + p2p greenfield builds; roles-catalog-write owner freeze (wf4=NO).

DISCIPLINE THAT WORKED: spawn role-matched teammates under own team slugs (pmcloseepic/teethclose/clientapi/callbackfix/clientapideploy/clientapitest/clientapiseal/pmmark), never reuse another team's agents; close each teammate on idle (tmux kill-pane) + resume-warm for follow-ons; never reuse a finished campaign slug. All 8 campaigns finished clean (no surviving processes).

---
*Added via Oracle Learn*
