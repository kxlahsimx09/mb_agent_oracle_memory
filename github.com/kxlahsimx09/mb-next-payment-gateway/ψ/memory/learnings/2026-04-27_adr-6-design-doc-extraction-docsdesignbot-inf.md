---
title: §ADR-6 design-doc extraction — docs/design/bot-infra/ created (4 files); ADR bod
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-6, doc-organization, design-doc-extraction, bot-infrastructure, third-extraction, convention-battle-tested, user-driven-audit, pre-emptive-extraction]
created: 2026-04-27
source: docs/adr.md@a69d143 + docs/design/bot-infra/{README,phase-1-deployment,vendor-evaluation,phase-2-watch-list}.md
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §ADR-6 design-doc extraction — docs/design/bot-infra/ created (4 files); ADR bod

§ADR-6 design-doc extraction — docs/design/bot-infra/ created (4 files); ADR body shrunk 136 → 73 lines (-46%).

User-driven audit triggered by user concern: "เอกสาร ADR อยากให้แน่ใจว่าไม่มีส่วนไหนเป็น design ที่ลงลึก ถ้ามีให้แยกออกมาเหมือน withdraw นะ". Ran full audit of §ADR-1 through §ADR-8.

Audit results:
- §ADR-1 (11 lines), §ADR-3 (12), §ADR-5 (11), §ADR-7 (12) — clean, brevity-enforced
- §ADR-2 (29 lines, RBAC Phase 1/2 plan) — decision-level, OK
- §ADR-4 (17 lines) — clean
- §ADR-4a (54 lines) — already extracted prior pass → docs/design/withdrawal-lane/
- §ADR-4b (67 lines) — decision-level (Decision #5 8-step list = same shape as §ADR-4a inline enumeration), OK
- §ADR-6 (136 lines) — FLAGGED: clear "how it's built" content + close to 150-line extract threshold
- §ADR-8 (67 lines) — already extracted prior pass → docs/design/bot-gateway-dispatch/

Only §ADR-6 needed extraction. Implementation-detail content identified:
- Infrastructure spec table (VPS/proxy specs, exact costs)
- Docker-compose deployment layout
- Phase 1.5 cost-optimization survey (ARM VPS, ProxyEmpire/IP2World/etc, free monitoring stack)
- Full GoLogin evaluation (cost math, 300-hr cap analysis, bandwidth caveat, pass-0 cost-claim correction)
- Full Steel Browser evaluation (10-incident detail, v0.5.2-beta maturity, open production-blocking bugs #245/#222/#247)
- Phase 2 watch list table (signals + sources + cadence)
- Phase 2 candidate evaluation priority + cost math

Created docs/design/bot-infra/ with 4 files (358 lines total):
- README.md (46 lines) — overview + full prior-art citation list + decision→implementation map + cross-cutting notes
- phase-1-deployment.md (107 lines) — Hetzner specs, docker-compose, session/proxy/keepalive ops, fleet ceiling math, Phase 1.5 detail
- vendor-evaluation.md (120 lines) — GoLogin + Steel full evaluation + comparison summary
- phase-2-watch-list.md (85 lines) — Phase 2 triggers + candidate priority + watch list + re-evaluation procedure + rollback plan

§ADR-6 body shrunk 136 → 73 lines. Decision-level content preserved: Context, load-bearing C-001, Options table (4 rows), Decision + 5-point rationale, Browser idle shutdown rejection, Phase 1.5 summary (4 bullets), Phase 2 summary (4 triggers + 3-candidate priority), Consequences, Trade-offs, Resolved + Deferred questions, Prior art summary + pointer, Related ADRs. Cross-references updated: §ADR-4b deposit auto-match note added (bot scraper internals owned by §ADR-6, not §ADR-4b).

No body decisions changed. §ADR-6 stays #decision (refined 2026-04-23 pass 1; no re-ratification). arra_supersede not applied — pass-1 learning remains primary record; this pass is doc-organization only.

Pattern reinforcement — third bidirectional ADR-vs-design-doc extraction in 4 days:
- §ADR-4a pass 6 (2026-04-23): 369 → 51 lines (-86%)
- §ADR-8 pass 4 (2026-04-24): 118 → 66 lines (-44%)
- §ADR-6 pass-this (2026-04-27): 136 → 73 lines (-46%)

Convention now battle-tested across 3 instances. Predictable shape:
- Keep inline: "decisions + why + summary tables + consequences + trade-offs + revisit triggers + resolved/deferred questions"
- Extract to design doc: "specs + procurement + full vendor evaluations + operational procedures + spec-level rationale"
- Trigger heuristic (~150 lines) is conservative — pre-emptive extraction at 136 lines is good practice when content is clearly "how it's built"

Durable lesson: User-prompted audit caught pre-emptively (before line threshold breach). Future architect should periodically run cross-section audit even when no specific section breaches threshold — content nature can be design-level even at borderline sizes.

Threads opened: none. Threads closed: none. Commit: a69d143 on PR #3. Total file impact: docs/adr.md 622 → 558 lines after extract (-10% additional after archival pass earlier today).

Next-pass candidates surfaced: §ADR-4d ratification (thread #53 active, C1-C5 architect-recommended pending), §ADR-4c baseline (auto-expire), wallet-table cross-cutting ADR, deposit-create API ADR.

---
*Added via Oracle Learn*
