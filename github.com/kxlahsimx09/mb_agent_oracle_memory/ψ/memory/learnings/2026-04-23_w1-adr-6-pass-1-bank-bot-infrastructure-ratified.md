---
title: W1 ADR-6 pass 1 — Bank bot infrastructure ratified (Phase 1 = Hetzner always-hot
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-6, pass-1, bot-infrastructure, hetzner, keepalive, c-001, phase-structure, gologin-evaluated, steel-browser-evaluated]
created: 2026-04-23
source: docs/adr.md@0ffeccc + W10 constraints register + user-provided GoLogin pricing + web research 2026-04-23
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# W1 ADR-6 pass 1 — Bank bot infrastructure ratified (Phase 1 = Hetzner always-hot

W1 ADR-6 pass 1 — Bank bot infrastructure ratified (Phase 1 = Hetzner always-hot + raw Playwright + keepalive per C-001).

First W1 refine pass on ADR-6 (was pass-0 baseline since 2026-04-22 commit `d1dc579`). User flagged investigation ("ลองอ่าน constraint และ ค้น memory จาก current เพื่อดูว่า ADR-6 ยัง valid ดีอยู่ไหม") after noticing ADR-4a Consequences (ii) cold-start framing was underrated. Pass 1 cross-checks ADR-6 against W10 constraints register + current production code + verified vendor pricing.

`docs/adr.md` §ADR-6 at commit `0ffeccc` on branch `claude/cool-snyder-6effcf` (PR `kxlahsimx09/mb-next-payment-gateway#1`, open).

## Ratified decisions (Phase 1)

1. **Infrastructure:** Hetzner CX32 (~$9/mo) + 5 Thai SOCKS5 static residential proxies (~$3/mo each) = **$24/mo total for 5-bot fleet**.
2. **Browser pattern:** Always-hot raw Playwright browsers (maker/approver/viewer per SCB account). Keepalive loop runs every idle tick (navigates dashboard ↔ account-detail) per C-001.
3. **Anti-detect:** Playwright defaults + custom patches. No deep fingerprint spoofing service. Acceptable for current bank anti-bot surface (no evidence of Hetzner IP flagging or Playwright signature detection).
4. **Per-account proxy isolation:** Each bank_account (= one company) gets one dedicated Thai proxy IP. maker/approver/viewer share the same proxy (same company, same office IP = expected).
5. **Hosting region:** Hetzner EU (no Asia DC needed — bot traffic routes through Thai proxy; VPS→proxy latency ~200ms is dwarfed by C-002 human-delay 800-2000ms requirements).

## Changes from pass-0 baseline

### Removed: "Browser idle shutdown pattern"

Pass-0 described `idle → browser OFF → wake on demand → re-login` as a RAM-saving trade-off. **Conflicts with C-001** — KTB Angular SPA session dies silently at ~10-15 min of no URL-hash router navigation. Idle-shutdown forces this condition every idle window > 15 min, meaning KTB wake requires full re-login including email OTP every time (C-005 TTL 3 min — admin must be present).

Current production does NOT use idle-shutdown — it uses keepalive. Pass-0's idle-shutdown was a novel architectural proposal that undercut the constraint it needed to respect. Dropped pass 1.

### Corrected: GoLogin cost analysis

Pass-0 cited **"$35/mo per account × 5 = $175/mo"** — outdated / incorrect.

Verified 2026-04-23 from user screenshot of GoLogin pricing page:
- **Business plan = $49.50/mo flat** (promo; normal $99)
- 300 profiles (far more than 5 bank accounts needed)
- 10 team members
- 2 GB residential proxy (bandwidth cap — tight for always-on workload)
- **300 cloud-browser hours/month** (the real blocker)

Hour-cap math for 5 always-on bots:
- Always-Connected: 5 × 720 hrs/mo = 3,600 hrs needed = 12× over cap ❌
- Smart Disconnect + 10-min keepalive: ~240 hrs keepalive + 60 hrs work = ~300 (tight, low-volume only) ⚠️
- Smart Disconnect + 5-min keepalive: ~480 hrs = over cap ❌

Rejection rationale switched from "cost too high" to "hour cap + bandwidth caveat + no fit for always-on workload".

### Added: Steel Browser evaluation (pass-0 did not consider)

Self-hosted Steel Browser considered as cheaper managed abstraction. Research 2026-04-23:
- v0.5.2-beta, explicit "public beta" disclaimer
- 6.9k GitHub stars, Apache 2.0 license, active development
- **Steel.dev own hosted cloud: 10 incidents Feb-Apr 2026** (2 outages + 8 degraded)
- Session-creation failures, WebSocket/DNS issues, security-patch broke Playwright compat (Mar 29)
- Open production-blocking bugs: #245 (session release endpoint), #222 (UI stuck on session connecting)
- No fintech/payment-system production track record in public channels

Rejected Phase 1 — payment systems cannot tolerate known session-handling instability. Reconsider for Phase 2 after (a) v1.0 GA, (b) ≥6-month track record from v1.0, (c) community fintech adoption signals, (d) listed open bugs closed.

## Phase structure formalized

- **Phase 1 (current, ratified):** Hetzner always-hot + raw Playwright + keepalive. $24/mo.
- **Phase 1.5 (optional cost/ops tweaks within Phase 1):** ARM VPS (CAX11) saves ~$5/mo; Thai proxy renegotiation saves ~$3-5/mo; free monitoring stack (UptimeRobot + Grafana Cloud Free + Sentry Free) reduces ops time. Net target: $19-21/mo.
- **Phase 2 (trigger-based, not active):** Triggers: fleet > 10 bots, bank anti-detect flagging, DevOps capacity exhaustion, new-bank onboarding with unknown anti-detect. Candidates by priority: (1) GoLogin local-mode (anti-detect fingerprints + run on Hetzner, bypass hour cap), (2) GoLogin higher tier if unlimited-hours plan emerges, (3) Steel Browser post-v1.0.
- **Phase 3 (hypothetical):** Cross-border expansion, regulatory, vendor SDK / direct REST API.

## Phase 2 watch list (cadence for re-evaluation)

| Signal | Source | Cadence |
|---|---|---|
| Steel v1.0 GA | github.com/steel-dev/steel-browser/releases | quarterly |
| Steel hosted-cloud incidents | status.steel.dev/incidents | monthly |
| KTB/SCB anti-detect flagging | bot failure rate vs baseline | continuous |
| GoLogin Enterprise unlimited-hours tier | gologin.com/pricing | quarterly |
| New Thai bank integration request | operational plan per bank | per onboarding |

## Downstream: §ADR-4a §Consequences (ii) reframe

Pre-pass: "Cold-start bots lose the race to hot bots (desirable operationally; must be documented)." Framed as positive trade-off.

Post-pass: *Moot under ADR-6 Phase 1* (always-hot bots = no cold-start race). Relevant only if Phase 2 Smart Disconnect pattern adopted. Cross-link to ADR-6 Phase 2 trigger list added.

## Constraint citations load-bearing to this ADR

- **C-001** (KTB Angular session timer) — drives always-hot + keepalive requirement
- **C-002** (anti-automation 800-2000ms delays) — drives per-account proxy isolation
- **C-005** (OTP TTL SCB 5min / KTB 3min) — drives against idle-shutdown (wake OTP cost)
- **C-006** (post-OTP ambiguity) — handled in ADR-4a sweep triage, not ADR-6 scope
- **C-007, C-008, C-010, C-012** — bot-implementation constraints, out of ADR-6 infrastructure scope

## Cross-references

- Pre-pass ADR: `docs/adr.md @ d1dc579` §ADR-6 (pass-0 baseline, superseded)
- Flow: `ktb-keepalive-session-rotation` (ratified Oracle thread #32)
- Related learning: `2026-04-22_w10-constraint-harvest-first-run-baseline` (C-001 through C-012)
- Related learning: `2026-04-17_name-drift-ktb-session-death-is-a-real-sil` (prod incidents)
- Current impl: `bank-bot/app.js:1826-1846` + `:2120-2145` (keepSessionAlive)
- Pricing reference: GoLogin Business plan verified 2026-04-23 (user-provided)
- Maturity reference: Steel Browser v0.5.2-beta + status.steel.dev incidents (researched 2026-04-23)

## Tags

system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-6, pass-1, bot-infrastructure, hetzner, playwright, keepalive, c-001, phase-structure, gologin-evaluated, steel-browser-evaluated, user-surfaced

---
*Added via Oracle Learn*
