---
title: ## Three reviewer smell classes from the authphase2 PR train (PRs #380/#382/#385
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, smell, request-changes, adr, ci-assertion, rbac, authphase2]
created: 2026-06-11
source: PRs https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/380 /382 /385 reviews 2026-06-11
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## Three reviewer smell classes from the authphase2 PR train (PRs #380/#382/#385

## Three reviewer smell classes from the authphase2 PR train (PRs #380/#382/#385, 2026-06-11)

**1. Universal audit-clean claims in amendments — grep before believing.** #382's CA5 closed a drift-audit flag with "no further 3-segment-format strings at HEAD" — falsified by one grep: `adr.md` §ADR-16 carried live `admin:topup:create/approve/reject/list` (the exact predicted drift class, plus `reject`/`list` weren't even F3 enum members). Check: any amendment claiming an audit found nothing → run the audit's own search yourself before approving the closure. Also: a flag must be closed AT ITS SITE (in-place marker), not only from the closing amendment.

**2. Born-failing CI assertions — check the relation's cardinality.** #382's CA7 specified `rbac_seed_vs_catalogue` as set-EQUALITY of seed (~12 strings, partial Phase-1 implementation) vs catalogue (~60+ members) — failing on day one forever. The drift-catching direction is SUBSET (no seed string outside the catalogue); the inverse is a report, not a gate. Check: for any spec'd assertion comparing a partial implementation against a full catalogue/spec, ask which direction catches the disease and whether the stated relation can EVER pass in the phase it ships in.

**3. Pinned-source-lacks-required-content seam.** #380's SV5 pinned the role_permissions seed source = the EF ROLE_PERMISSIONS map, while SV6's read predicates required `:view` members — the map had ZERO `:view` strings, so as enumerated every human read would return zero rows (or read-RBAC silently wouldn't bind admins, depending on unstated predicate composition). Check: when an amendment pins a data SOURCE and a CONSUMER, verify the source actually contains what the consumer needs (grep the source), and that the predicate composition (where does the admin OR-arm sit relative to the new AND term?) is stated, not assumed. Echo in #385: the dev's seed carried ('super_admin','admin:super') — a role-shaped label seeded as a permission, violating the canonical-only seed rule the same train ratified (CA7); seed contents must be diffed against the ratifying text, not the legacy map.

---
*Added via Oracle Learn*
