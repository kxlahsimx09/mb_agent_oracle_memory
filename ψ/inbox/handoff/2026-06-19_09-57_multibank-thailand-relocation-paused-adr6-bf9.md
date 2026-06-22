# Handoff — Multibank fair-router → Thailand bankbot relocation (PAUSED for ADR review)

**Date:** 2026-06-19 (GMT+7) · Orchestrator · campaigns `multibank` (+ `adrcheck` for the ADR review)
**Status:** Multibank fair-router test **DONE-GREEN**; the **Thailand relocation is PAUSED before any destructive op**, pending owner↔architect resolution of an **§ADR-6 BF9 conflict**. Owner is taking this handoff to discuss with the architect.

## Goal (what we're trying to do)
1. Verify the deposit+payout **FAIR-ROUTER** works across multiple same-bank bots (3 SCB in one pool). ✅ DONE-GREEN.
2. **RELOCATE the entire bankbot ECS cluster** ap-southeast-1 (Singapore) → **ap-southeast-7 (Thailand)** with **FIXED THAI IPs** (rationale: real Thai bank portals geo-restrict/allowlist scraper SOURCE IPs), then **DECOMMISSION the SG services**. Bake into staging now ("กัน prod ลืม"). ⏸ PAUSED (ADR conflict below).

## DONE (staging, ap-southeast-1) + PRs awaiting owner merge
- **Fair-router test GREEN:** DEPOSIT spread 0 (scb1=3/scb2=3/scb3=3, matched→paid, per-login isolated) + PAYOUT spread 0 (`fair_router_assign` LRU, exactly-once per-account claim, 3 distinct batch_ids, per-bank isolation).
- **Infra built:** 1 multi-account MOCK portal `scbportal.3-1-0-33.sslip.io` (per-login isolation) on oracle-runner; 3 SCB bots (accounts 0117000001/0005/0006, pool olive-P1, distinct logins/keys; 3 distinct EPHEMERAL SG IPs verified, no NAT); `scb-fleet.json`.
- **Found + fixed a PROD bug:** `create_payout` Mode-1 (pool path) 500'd on ambiguous `status` (42702) → payout fair-router unreachable for ALL clients via Mode-1 in prod (existing tests missed it — they use Mode-2). One-line column-qualify fix, applied to staging sinuw (verified has_bug=false/has_fix=true).
- **PRs OPEN (await owner merge):** #31 (multi-account portal, mb-next-bank-bot) · #613 (create_payout fix, gateway) · #614 (fair-router harness, gateway). Earlier this session: #607 (B↔C restart-split, verified-green); #585–604 merged.

## PAUSED / NOT done (the relocation)
- brew-ops PAUSED before ANY destructive op: **NO SG decommission, NO TH resources created.** SG cluster + portal still UP (portal HTTP 200).
- Owner-locked NAT approach for fixed Thai IP: **3 MANAGED NAT GW + 3 EIP (~$123/mo).** ap-se-7 feasibility GREEN (region + Fargate enabled, fresh quotas).

## ⚠️ THE ADR CONFLICT — for the architect discussion (review covered all 26 ADRs; full detail in `system-architect_adrcheck_findings.md`)
**§ADR-6 BF9 — CONFLICT (the gate):** fixed Thai IP via NAT/EIP DIRECTLY contradicts the PARKED 2026-06-05 BF9.
- Plan premise: "banks ALLOWLIST IPs → fixed cloud IP = good."
- BF9 premise: "banks FRAUD-SCORE by **ASN** → a cloud-datacenter ASN (even per-bot, even in TH) reads as fraud/bot-farm → CAPTCHA/challenge/suspension." 3-NAT/3-EIP fixes the bot-farm concern but NOT the core ASN problem.
- **Resolvable only by ONE fact:** do the target Thai banks operate an EXPLICIT per-IP allowlist? **YES** → allowlisted cloud EIP trusted, ASN moot → amend BF9, proceed. **NO** → BF9 holds, keep residential/edge egress (do NOT use cloud EIP).
- **KEY (BF8): compute-region is INDEPENDENT of bank-facing IP** → relocating COMPUTE to TH is FINE; only the FIXED-CLOUD-IP egress is contested. **DECOUPLE them.**

Other findings:
- **§ADR-9 EG4 DECOMMISSION HAZARD:** "decommission SG" must NOT touch the merchant-facing callback-egress proxy EIP in SG (merchant-whitelisted, never-release) — would break ALL merchant callbacks. Scope decommission to the bankbot FLEET only.
- **§ADR-6 BF8 ratification gap:** the 2026-06-05 amendment is #provisional + names a gating one-bot migrate+verify pass → ratify + verify before treating relocation as blessed.
- **§ADR-8 role-separation (clarify):** the 3 SCB accounts are deposit+payout (mixed-method); §ADR-8 keeps accounts role-separated → mixed-method through one pool may trigger §ADR-8 revisit (h). Confirm test intent.
- **Multi-account mock portal = NO conflict:** §ADR-6 "1 container=1 account" governs the PROD scraper; a mock simulating the bank website (many accounts) is §ADR-21 test infra → more faithful, not a violation.
- No conflict: create_payout fix (§ADR-4a), §ADR-20/15, data residency (gateway DB stays SG).

## Resume point (after the architect discussion)
1. **Decide §ADR-6 BF9:** verify the bank per-IP-allowlist fact → amend BF9 (proceed with fixed cloud EIP) OR keep residential egress (drop cloud-EIP; compute-only move to TH).
2. If proceeding: scope decommission to the bankbot fleet ONLY (preserve §ADR-9 merchant EIP); ratify §ADR-6 amendment + run the one-bot verify pass; confirm §ADR-8 role-separation.
3. The COMPUTE relocation to TH (decoupled from egress) is ADR-aligned (BF8) — can proceed regardless of the egress decision.

## Refs
- Architect full review: `system-architect_adrcheck_findings.md` (worktree `mb-next-payment-gateway.wt-c-adrcheck`)
- Campaign memory: `campaign-multibank-fairrouter.md`
- PRs: #31 (bank-bot), #613, #614, #607 (gateway)
- Infra: portal `scbportal.3-1-0-33.sslip.io` (SG, up); gateway DB `sinuw` (ap-southeast-1); SG ECS cluster `mb-next-bankbot` (up, NOT decommissioned)
- All fleet agents PARKED; zero destructive op pending.
