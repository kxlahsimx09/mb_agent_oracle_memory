---
title: design decision — §ADR-13 F3 §Catalogue-Add CA8 (2026-06-11, campaign bbot/threa
tags: [system-architect, repo:mb-next-payment-gateway, next, auth-rbac, adr-13, f3-catalogue, ca8, rbac_seed_vs_catalogue, sv7b, decision]
created: 2026-06-11
source: docs/adr.md §ADR-13 F3 §Catalogue-Add CA8 (PR #415, arch/adr13-f3-ca8-entity-views) + thread #13 (next-dev ratification-request, owner 2026-06-11)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# design decision — §ADR-13 F3 §Catalogue-Add CA8 (2026-06-11, campaign bbot/threa

design decision — §ADR-13 F3 §Catalogue-Add CA8 (2026-06-11, campaign bbot/thread-13): adds merchant:view / client:view / partner:view to the F3 resource catalogue (33→36), NEW-not-port, read-verb only, admin-tier, super_admin Phase-1. Ratifies the three :view strings next-dev's PR #412 seeds into role_permissions for the admin-portal entity read-views v_merchants/v_clients/v_partners.

Realizes the already-ratified §ADR-13 §Amendment 2026-06-11 SV7b promotion-queue path ("a future client-directory read lands as a credential-free PROJECTION amendment, never a row grant on these tables") — the views are owner-context credential-free PROJECTIONS over merchant_config/client/partner_profiles with secret columns excluded (merchant_config.secret, client.api_key/api_key_secret); base tables stay zero-grant (SV7b intact); only the views are GRANT SELECT to authenticated.

Owner's question answered: YES, these are RBAC-checked exactly like deposit — each view's WHERE = aal2 ∧ has_read_perm(<resource>) ∧ is_admin (the identical uncorrelated-INITPLAN once-per-query, DB-fresh predicate as the deposit/bank_statements admin-tier policies in 20260611000010). The gap was catalogue membership only.

Merge coordination (the rbac_seed_vs_catalogue SUBSET assertion, CA7): there is NO apply-time catalogue CHECK constraint, and rbac_seed_vs_catalogue is NOT yet built at HEAD (named in CA7, no pgTAP/test file). So PR #412's seed insert does NOT go RED at apply/merge time — #412 is NON-BLOCKING and can merge independently; no same-migration fold required, no cross-PR ordering hazard. CA8 (PR #415) is the catalogue authority of record; #412's migration header cites it. When next-dev authors/runs the CA7 assertion (next-dev owns it), it enumerates the now-CA8-inclusive catalogue → seed (map ∪ SV6a ∪ CA8-trio) ⊆ catalogue = green. CA8 folded into CA7's catalogue enumeration in the ADR.

PR #415 (arch/adr13-f3-ca8-entity-views off main, docs/adr.md +12/−2), RATIFICATION-BEARING (new catalogue members) but authority = pre-ratified SV7b promotion-queue; reviewer-gated. Reported thread #13 msg 152 + for-orchestrator + for-next-dev envelopes; dev consult archived.

---
*Added via Oracle Learn*
