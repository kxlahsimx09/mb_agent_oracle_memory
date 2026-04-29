---
title: Vendor pricing correction — GoLogin Business plan (2026-04-23 verified).
tags: [system-architect, repo:mb-next-payment-gateway, repo:cross, next, prior-art, vendor-pricing, gologin, cost-correction, cloud-browser, hour-cap, adr-6]
created: 2026-04-23
source: User-provided GoLogin Business plan screenshot 2026-04-23; supersedes pass-0 "$35/account" claim in ADR-6 baseline
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# Vendor pricing correction — GoLogin Business plan (2026-04-23 verified).

Vendor pricing correction — GoLogin Business plan (2026-04-23 verified).

Cross-link learning for use when architect sessions cite GoLogin pricing in trade-off analysis. Pass-0 ADR-6 baseline cited **"$35/mo per account"** (apparently from pre-2026 pricing or a different plan tier) — this was carried forward in pass-1/2 analysis and led to early-session overestimate of GoLogin cost by ~3.5× (7× once hour cap accounted for).

## Verified pricing (2026-04-23, user-supplied screenshot)

### Business plan
- **Promo:** $49.50/mo (50% off)
- **Normal:** $99.00/mo
- **7-day free returns**

### Included
- 300 profiles
- 10 team members
- 2 GB residential proxy
- **300 cloud-browser hours per month** (pool across all profiles)
- Free proxies (type not specified — likely datacenter or shared)
- 24/7 expert support

## Hour-cap implications

The 300-hour cap is the critical constraint for always-on workloads:
- 1 profile always-on = 720 hrs/month alone (24 × 30)
- 5 profiles always-on = 3,600 hrs/month — **12× over cap**
- Smart Disconnect + 10-min keepalive × 5 bots ≈ 240 hrs/month keepalive alone (tight)
- Smart Disconnect + 5-min keepalive × 5 bots ≈ 480 hrs/month — over cap

**Not suitable for 5-bot always-hot payment-bot workload.** GoLogin Business plan is designed for affiliate-style operators who run profiles intermittently across many accounts, not continuous 24/7 session coverage.

## When GoLogin Business IS suitable (corrected targeting)

- ≤ 3 concurrent profiles always-on → fits within 2,160 hrs/mo for full always-on (but that's not what the plan offers — still bounded by 300 hrs)
- Intermittent use: 300 hrs / 30 days = 10 hrs/day distributed across profiles
- QA/tester environments (bursty cloud-browser usage)
- New-bank-integration ramp-up (Phase 2 option (d))
- **Anti-detect fingerprinting is the primary value** — if fingerprints add material detection avoidance, the $49.50 premium is justified; if not, Hetzner self-host is cheaper

## Runtime modes — cost model does not vary by mode

- Always-Connected and Smart Disconnect are both **same plan cost** — pricing is per-profile-count × hour-pool, not per-mode
- This corrects another prior-session claim that "Always-Connected costs more than Smart Disconnect"
- Mode choice is technical (when do you need browser runtime) not cost-based

## Bandwidth (2 GB residential) sub-constraint

- Always-on browser with keepalive + work alone likely exceeds 2 GB/mo per bot if routed through residential
- Free proxies (presumably datacenter) would not satisfy C-002 "per-account Thai residential" requirement for bank portals
- Plan would likely require external Thai SOCKS5 proxies alongside for C-002 compliance → $49.50 + $15 = $64.50/mo

## Local-mode (Orbit)

Not priced separately in this plan. If GoLogin local-mode runs browsers on user infrastructure (e.g., our Hetzner VPS) and does NOT count toward cloud-browser hours, this could bypass the hour cap. Needs verification before architect trusts this path. Filed as Phase 2 investigation question.

## Recommendation for future sessions

1. **Do not cite "$35/account"** — supersede with "$49.50/mo Business with 300-hr cap".
2. **Verify current pricing on https://gologin.com/pricing when decisions hinge on cost** — pricing changes.
3. **Always compute hour-cap fit before recommending GoLogin** for any always-on workload.
4. **Consider local-mode separately** — same subscription may bypass cloud-browser hour cap; requires verification.

## Related

- `learning_2026-04-23_w1-adr-6-pass-1-bot-infrastructure-ratified` (primary ADR-6 pass-1 record)
- `docs/adr.md` §ADR-6 at commit `0ffeccc` (implements the corrected analysis)

## Tags

system-architect, repo:mb-next-payment-gateway, repo:cross, next, prior-art, vendor-pricing, gologin, cost-correction, cloud-browser, hour-cap, adr-6

---
*Added via Oracle Learn*
