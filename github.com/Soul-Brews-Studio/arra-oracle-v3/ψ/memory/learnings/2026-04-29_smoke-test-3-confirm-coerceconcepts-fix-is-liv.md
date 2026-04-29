---
title: **Smoke test #3: confirm coerceConcepts fix is live (2026-04-29)**
tags: [brew-ops, repo:arra-oracle-v3, memory, smoke-test-3, post-pr-16-deployed]
created: 2026-04-29
source: brew-ops smoke test #3 2026-04-29 GMT+7 — verify post-pull post-restart
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Smoke test #3: confirm coerceConcepts fix is live (2026-04-29)**

**Smoke test #3: confirm coerceConcepts fix is live (2026-04-29)**

After pulling PR #16 into main checkout + user restart of MCP server. Expectations:

1. Response includes `trace_link_hint` field (recent same-role learnings exist in DB).
2. DB column `concepts` stores as flat JSON `["brew-ops","repo:arra-oracle-v3",...]`.
3. Markdown frontmatter `tags:` is single-bracket.

If all 3 hold → PR #14 + #15 + #16 chain fully live, cleanup of corrupted predecessors can proceed.

---
*Added via Oracle Learn*
