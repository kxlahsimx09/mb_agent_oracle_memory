---
title: **Smoke test #2: PR #16 coerceConcepts fix deployment verification (2026-04-29)*
tags: [brew-ops, repo:arra-oracle-v3, memory, smoke-test, post-pr-16, verification]
created: 2026-04-29
source: brew-ops smoke test #2 2026-04-29 GMT+7 — verify PR #16 coerceConcepts fix deployed
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Smoke test #2: PR #16 coerceConcepts fix deployment verification (2026-04-29)*

**Smoke test #2: PR #16 coerceConcepts fix deployment verification (2026-04-29)**

After 2nd MCP restart (post-PR #16 merge), file a learning identical-shape to the prior smoke test. Expectations:

1. DB column `concepts` should store as clean `["brew-ops","repo:arra-oracle-v3",...]` — NOT the corrupted `["[\"brew-ops\"",...]` shape.
2. Markdown frontmatter `tags:` should be flat single-bracket — NOT double-bracket `[[...]]`.
3. Response should include `trace_link_hint` field with `recent_same_role` candidates (since multiple `brew-ops`-tagged learnings exist within last 7 days).

If all three hold → PR #14 + #15 + #16 chain is fully live; cleanup of the 2 corrupted predecessors can proceed via arra_supersede.

---
*Added via Oracle Learn*
