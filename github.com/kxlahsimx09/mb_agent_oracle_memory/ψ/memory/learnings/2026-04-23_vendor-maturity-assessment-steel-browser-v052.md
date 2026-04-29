---
title: Vendor maturity assessment — Steel Browser v0.5.2-beta (2026-04-23 snapshot).
tags: [system-architect, repo:mb-next-payment-gateway, next, prior-art, vendor-maturity, steel-browser, research-hygiene, process-learning, adr-6]
created: 2026-04-23
source: Web research 2026-04-23: github.com/steel-dev/steel-browser, docs.steel.dev, status.steel.dev/incidents
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# Vendor maturity assessment — Steel Browser v0.5.2-beta (2026-04-23 snapshot).

Vendor maturity assessment — Steel Browser v0.5.2-beta (2026-04-23 snapshot).

Cross-link learning for use when architect sessions consider Steel Browser as a raw-Playwright replacement or GoLogin alternative. Filed as **process hygiene reference** — early-session architect evaluation mistakenly positioned Steel as "interesting Phase 1.5 candidate" based on surface signals (GitHub stars, Apache 2.0 license, active commits); deeper research surfaced significant maturity concerns that should have been checked first.

## What Steel Browser is

- Open-source "browser infrastructure for AI agents" (framing from steel.dev)
- Puppeteer-compatible, WebSocket + CDP API
- Built on Chromium bundled in Docker image
- Session-lifecycle API: spawn → control → dispose
- Both self-host (free, open source) and hosted-cloud ($29+) options
- Apache 2.0 license

## Maturity state at 2026-04-23

### GitHub repository
- `github.com/steel-dev/steel-browser` — 6.9k stars, 922 forks, 20 open issues, 11 open PRs
- 242 commits on main, 21 releases total
- **v0.5.2-beta** current version (March 2026) — explicit "public beta" disclaimer
- Maintainers responsive (Discord + GitHub), but no formal SLA

### Steel.dev own hosted-cloud incidents (Feb-Apr 2026, per status.steel.dev)
- **10 incidents in 3 months:** 2 complete outages + 8 degraded-service events
- Session-creation failures recurred (Feb 20, Apr 14)
- Regional infrastructure problems (IAD, ORD, LAX outages)
- DNS issues affecting WebSocket connections + dashboard
- **Security patch broke Playwright compatibility** (Mar 29) — "rogue security patches that became too restrictive"
- Team acknowledged "ongoing architectural fragility rather than isolated incidents" and need to establish "playbooks"

### Production-blocking bugs open
- **#245:** `/v1/sessions/:sessionId/release` endpoint broken with recent images (bug label, unresolved)
- **#222:** UI stuck on "Session connecting..." with CDP/WebSocket errors (bug label, unresolved)
- **#247:** Performance degradation when loading multiple tabs concurrently (question label, scale concern)
- **#270:** Keyboard input broken in iOS Safari iframe session (bug label, edge case)

### No fintech / payment-system public track record
- Community examples focus on AI agents, general web automation, scraping
- No references to banking portal integration in GitHub discussions / blog / Discord
- Adopting Steel for bank bots = being a guinea pig in payment-system space

## Self-hosted on Hetzner feasibility

- Infrastructure cost equivalent to raw Playwright ($24/mo baseline)
- Resource requirements: 4 GB RAM + 10 GB disk minimum, ~300-500 MB per active session
- For 5 concurrent sessions on CX32 (8 GB): ~2-2.5 GB sessions + 2 GB Steel base + 2 GB OS = ~4.5 GB used, ~3.5 GB headroom (workable but tight)
- Production caveats from docs: "avoid exposing port 9223 to public", "use specific image versions not `latest`", "implement reverse proxy with HTTPS", "set memory limits", "configure restart policies and proper authentication"
- No explicit concurrency limits published

## Self-host vs cloud

- Self-host on Hetzner inherits the same code-base bug surface as cloud (#245 session release, #222 WebSocket, #247 performance)
- Advantage of self-host: pin specific version, not affected by Steel.dev's regional cloud outages
- Disadvantage: same upstream instability; ops responsibility stays with user

## Verdict — not production-ready for payment systems as of 2026-04-23

Reasoning:
1. **v0.5-beta + explicit unstable-API disclaimer** = migration cost in 6-12 months for payment-grade stability
2. **Own cloud 10 incidents/quarter** signals code-base fragility that self-host inherits
3. **Open production-blocking bugs unresolved** (session release, WebSocket connection) are *exactly* the paths a bank bot depends on
4. **No fintech track record** = unknown behavior under payment-system use patterns
5. **Anti-detect is "basic stealth"** — does not provide material advantage over raw Playwright for current bank anti-bot surface

**Phase 1 recommendation:** raw Playwright on Hetzner continues to be the right default for payment bots.

**Phase 2 re-evaluation triggers (before reconsidering Steel):**
- Steel hits **v1.0 GA** (commitment to stable API)
- Track record ≥ 6 months from v1.0 on status.steel.dev
- At least one publicly-known payment-system / bank integration using Steel
- Open production-blocking bugs (#245, #222) closed and tagged fixed
- Non-payment pilot on own infrastructure as rehearsal

## Research hygiene lesson (process note for future architect sessions)

When evaluating vendor tech for ADR inclusion:
1. **GitHub stars + license + recent activity are NOT sufficient** to assess production readiness.
2. **Always check:**
   - (a) Official pricing page directly — pricing changes, cached claims go stale
   - (b) Status / incident history page — operational maturity signal
   - (c) Open issues tagged bug with production-impacting labels
   - (d) Changelog — breaking changes cadence
   - (e) Community signals for *specific use case* — bank portals, payment systems, etc.
3. **Beta / v0.x projects deserve explicit Phase 2+ deferral** unless we are the first-party willing to be the guinea pig — which payment systems usually cannot afford.

Logged in ADR-6 pass-1 revision log as a reusable principle.

## Related

- `learning_2026-04-23_w1-adr-6-pass-1-bot-infrastructure-ratified` (primary ADR-6 pass-1 record)
- `docs/adr.md` §ADR-6 at commit `0ffeccc` (contains verdict)
- `github.com/steel-dev/steel-browser` (project home)
- `status.steel.dev/incidents` (incident ledger)

## Tags

system-architect, repo:mb-next-payment-gateway, next, prior-art, vendor-maturity, steel-browser, research-hygiene, process-learning, adr-6, phase-2-candidate

---
*Added via Oracle Learn*
