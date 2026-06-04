---
title: **Gap-sweep apply-time verification: the writer-vs-architect boundary is "is thi
tags: [requirements, gap-sweep, adr-grounding, writer-scope, verification]
created: 2026-05-31
source: next-writer (campaign ng2write, gap-sweep wave 2)
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# **Gap-sweep apply-time verification: the writer-vs-architect boundary is "is thi

**Gap-sweep apply-time verification: the writer-vs-architect boundary is "is this decision already RATIFIED in an ADR?"** (mb-next campaign ng2write wave 2, PR #290, 2026-05-31, repo kxlahsimx09/mb-next-payment-gateway). Of 6 candidate requirements amendments handed down, only 3 were genuinely writer-ownable; the discriminator each time was whether a ratified ADR decision already backs the story:

- **APPLIED (ratified → writer authors):** ADMIN-005 audit-log query surface (§ADR-13 D2/D3 + §ADR-2 G4-D query indexes — the ADMIN epic uniquely lacked the dedicated *read* story its siblings WALLET-002/TOPUP-004/CALLBACK-005 already had; ADMIN-002 was write-only). WALLET-006 partner self-service wallet/MDR read (§ADR-2 partner is an entity_type with dashboard JWT + RLS; §ADR-12 §Amendment 2026-05-27 SC3 explicitly makes partner-self Phase-1 same-path as client-self — auth substrate already ratified; WALLET-002 covered only client+admin). Callback gateway network-identity = egress source-IP (§ADR-9 §Amendment 2026-05-29 EG1, which the callback epic had not yet reflected at all).

- **BOUNCED (needs a NEW ADR/amendment → NOT writer):** wallet-high-balance alert + ops-report — §ADR-15 D6 enumerates exactly 32 alerts and says "Catalog expansion further via amendment"; a new alert IS an ADR amendment. Topup residual-MDR routing — §ADR-16 §Scope boundary lists it OUT OF SCOPE: "residual-fee-routing drift fix (queued separately in §ADR-10 follow-up)." Callback redirect-chain handling — CU6 covers DNS-rebind only; HTTP-3xx redirect-following is an unaddressed SSRF vector → §ADR-9 amendment.

- **SHIPPED (skip):** fleet reboot-ack (FLEET-001 AC4 + FLEET-003 + FLEET-004). PROV-008 3 open-questions (already in PROV-008 §Notes + entity-provisioning revision-log 2026-05-31 items a/b/c).

**Durable rules:** (1) An orchestrator's framing of an item can be WRONG in a load-bearing way — item 5 said "gateway-identity HEADER"; the ratified reality was egress SOURCE-IP (EG1), not a header. Verify the ADR, then author what's actually ratified, not the framing. (2) "Catalog expansion via amendment" / "queued separately in §ADR-X follow-up" / "out of scope" in an ADR's scope-boundary are hard STOP signals for a writer — the decision is NOT yet ratified. (3) Re-verify every coarse-check claim against HEAD: several items the orchestrator suspected real were either already shipped or amendment-gated.

---
*Added via Oracle Learn*
