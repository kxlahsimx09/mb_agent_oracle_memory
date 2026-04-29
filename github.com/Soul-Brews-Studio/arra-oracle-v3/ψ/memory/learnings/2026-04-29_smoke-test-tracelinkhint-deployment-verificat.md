---
title: **Smoke test: trace_link_hint deployment verification (2026-04-29)**
tags: [brew-ops, repo:arra-oracle-v3, memory, smoke-test, trace-link-hint, verification, post-restart]
created: 2026-04-29
source: brew-ops smoke test 2026-04-29 GMT+7 — verify trace_link_hint deployment after MCP restart
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Smoke test: trace_link_hint deployment verification (2026-04-29)**

**Smoke test: trace_link_hint deployment verification (2026-04-29)**

After restarting the Oracle MCP server, file a deliberately small learning tagged `brew-ops` to verify PR #14/#15's `trace_link_hint` field appears in the response.

Expected response shape (when role tag matches `KNOWN_ROLES` and same-role learnings exist within 7 days):

```json
{
  "success": true,
  "file": "...",
  "id": "learning_2026-04-29_smoke-test-...",
  "embedding": "ok|skipped|failed",
  "message": "Pattern added to Oracle knowledge base (vault)",
  "trace_link_hint": {
    "role": "brew-ops",
    "recent_same_role": [{ "id": "...", "source_file": "...", "created": "..." }, ...],
    "message": "... arra_trace ... arra_trace_list ... arra_trace_link ..."
  }
}
```

If `trace_link_hint` is present → PR #14/#15 deployed correctly. If absent but `recent_same_role` candidates exist in DB → check whether MCP runtime is loading new code or stale cache. If `role: null` → role tag extraction failed (possibly case mismatch).

Pattern: testing externalized prompts at moment of action by exercising the smallest possible call.

---
*Added via Oracle Learn*
