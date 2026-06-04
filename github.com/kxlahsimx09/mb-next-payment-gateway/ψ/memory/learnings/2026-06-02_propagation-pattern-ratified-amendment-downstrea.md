---
title: Propagation pattern — ratified amendment downstream-handoff notes drive epic-pro
tags: [adr-propagation, callback, egress-ip, onboarding, requirements-writing, meaning-lock]
created: 2026-06-02
source: next-writer (eg1prop) — PR #306
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Propagation pattern — ratified amendment downstream-handoff notes drive epic-pro

Propagation pattern — ratified amendment downstream-handoff notes drive epic-prose fan-out. §ADR-9 §Amendment 2026-05-29 (EG — Outbound Callback Egress IP Stability) carries a §Implementation/downstream-handoff note that explicitly names where the "callback source IP allowlist" onboarding fact must land: DEPOSIT-001 + PAYOUT-001 + the callback-integration onboarding doc. Wave-2 PR #290 only applied it to the CALLBACK epic (CALLBACK-003, epic-callback-delivery.md:178/184/268, which itself left a follow-up flag). Campaign eg1prop (PR #306, branch writer/eg1prop vs main, NOT merged) closed the DEPOSIT-001 + PAYOUT-001 half.

MEANING-LOCK that kept this safe: the egress-IP fact is an ONBOARDING/OPERATIONAL fact ONLY — the gateway sends callbacks from a stable, merchant-whitelistable egress IP and a merchant needing source-IP allowlisting receives the published egress IP(s) at onboarding. It is NOT a client-facing request field, NOT a response field, NOT a new behavioral AC. The callback WIRE contract (§ADR-9 WC1–WC11 + CU1–CU8 endpoint safety) is unchanged. Framing mirrored verbatim from the wave-2 CALLBACK-003 boundary note so the same fact reads identically across epics. Cite §ADR-9 §Amendment 2026-05-29 (EG) + note the 2026-06-01 EG8–EG10 refinement (production egress = containerized ECS/Fargate behind NAT Gateway + EIP). No adr.md change — EG already ratified.

GAP found + bounced: the "callback-integration onboarding doc" named in the EG handoff does NOT exist in-repo. Checked: docs-site/content is empty (.gitkeep only); docs/requirements/epic-client-api.md is the idempotency/rate-limit cross-cutting epic; docs/design/client-api-gateway/README.md is an internal edge-gateway impl spec. None is a merchant onboarding doc. Per instruction, did NOT invent one — bounced to team-lead. This matches wave-2's own deferral flag, so the onboarding doc is a standing gap awaiting either creation or a re-home decision.

Re-verify-at-HEAD discipline: both epics had pre-existing `egress` grep matches, but they were the unrelated callback-resend idempotency learnings (2026-04-19 / 2026-04-21) — NOT the allowlist fact. Always read the matches, don't trust the grep hit count, before deciding "already present / skip".

---
*Added via Oracle Learn*
