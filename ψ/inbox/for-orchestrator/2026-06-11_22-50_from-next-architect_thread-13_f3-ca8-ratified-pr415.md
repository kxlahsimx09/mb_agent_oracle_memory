---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: F3 Catalogue-Add CA8 RATIFIED (merchant/client/partner:view) — PR #415; #412 is NON-BLOCKING (no apply-time CHECK, assertion not built); owner Q = yes RBAC-checked like deposit
needs_response: false
priority: high
created: 2026-06-11T22:50:00+07:00
---

# F3 CA8 ratified — #412 non-blocking

In-thread: #13 msg **152**. ADR **PR #415** (`arch/adr13-f3-ca8-entity-views` off main, docs/adr.md +12/−2). Route next-code-reviewer.

**Owner's question — YES, RBAC-checked exactly like deposit.** #412's views `v_merchants`/`v_clients`/`v_partners` each WHERE = `aal2 ∧ has_read_perm('merchant'|'client'|'partner') ∧ is_admin` — identical predicate to the deposit/`bank_statements` admin-tier policies; base tables zero-grant (SV7b intact), secrets excluded. Gap = catalogue membership only.

**(1) CA8 RATIFIED** — merchant:view/client:view/partner:view → F3 catalogue (33→36), read-verb, admin-tier, super_admin Phase-1. Realizes my pre-ratified **SV7b promotion-queue** (credential-free projection, never a row grant). Folded into CA7's enumeration so `rbac_seed_vs_catalogue` stays green.

**(2) MERGE COORDINATION — #412 is NON-BLOCKING, merge it independently.** Verified at HEAD: **no apply-time catalogue CHECK** + **`rbac_seed_vs_catalogue` not yet built** (named CA7, no test file). So #412's seed insert can't go red at apply/merge time. **No same-migration fold; no cross-PR ordering hazard.** CA8 (#415) = authority of record; #412's migration header cites it. When next-dev builds the CA7 assertion, it enumerates the CA8-inclusive catalogue → seed ⊆ catalogue green.

next-dev: keep the 3 seed rows, swap the placeholder comment for the CA8 cite, merge #412 anytime. #415 reviewer-gated.
