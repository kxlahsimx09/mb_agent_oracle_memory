---
title: arra_search FTS5 tokenizer handles both `flow:<slug>` (prefixed canonical, post-
tags: [repo:arra-oracle-v3, mcp-tools, search, fts5, vector, brew-ops, tag-convention, flow-slug, tokenizer, P-002, no-op-fix, investigation]
created: 2026-04-20
source: brew-ops session 2026-04-20 GMT+7 — empirical investigation triggered by W9 audit P2 item; verified against live oracle.db via bun:sqlite
project: github.com/soul-brews-studio/arra-oracle-v3
---

# arra_search FTS5 tokenizer handles both `flow:<slug>` (prefixed canonical, post-

arra_search FTS5 tokenizer handles both `flow:<slug>` (prefixed canonical, post-2026-04-19) and `["flow", "<slug>"]` (bare two-tag legacy, pre-2026-04-19) forms equivalently — no fallback layer needed in src/tools/search.ts.

Empirical finding (verified 2026-04-20 against the live oracle.db): a query for `flow:deposit-qr-request` returns 49 docs across both tag-form eras; an OR-expanded query `(flow deposit qr request) OR (deposit qr request)` returns the same 49 docs. The expansion adds zero rows because FTS5's unicode61 tokenizer treats `:` and `-` as token separators, so both stored tag forms — `["flow:deposit-qr-request"]` and `["flow", "deposit-qr-request"]` — tokenize to the same four tokens (`flow`, `deposit`, `qr`, `request`). After sanitizeFtsQuery() strips the colon, the query also reduces to those four tokens. Match recall is identical.

Vector search has the same property in practice: bge-m3 embeddings of frontmatter containing `tags: [flow:slug]` versus `tags: [flow, slug]` differ by one character (colon vs comma) and produce nearly-identical vectors. Top-K results overlap heavily.

The gap that DID exist (and prompted the W9 audit P2 follow-up) is at code paths that bypass arra_search and query the SQLite `oracle_documents.concepts` column with a raw `LIKE '%flow:<slug>%'` substring. That LIKE is strict-substring and never matches the bare two-tag form. Any caller relying on this — Studio frontend tag filters that hit raw SQL, future W4 routing if it queries by exact tag substring, ad-hoc scripts — would silently miss the legacy half of the tag space (the load-bearing W8 ratifications, S-strength assessments, cross-repo breadcrumbs from earlier W2 cycles).

Recommendation: when a caller needs to "find all docs about flow X", use `arra_search query="flow:<slug>"` rather than raw SQL substring. The MCP tool's FTS5 path covers both eras for free. For callers that genuinely need structured tag filtering at the SQL layer (e.g. analytics dashboards counting per-flow drift), the safest pattern is to query both forms explicitly: `WHERE concepts LIKE '%flow:slug%' OR (concepts LIKE '%"flow"%' AND concepts LIKE '%slug%')` — or migrate to using the FTS5 view.

What NOT to do: do not add an OR-expansion to sanitizeFtsQuery / handleSearch in src/tools/search.ts. The expansion is a no-op given the current tokenizer (verified empirically) and would be cargo-cult code. It would also add complexity that future readers might "simplify away" without understanding why it was there. The inline behavior is implicit in the tokenizer choice; making it explicit at the query layer is wrong abstraction.

What WOULD trigger a re-evaluation: switching tokenizer from unicode61 to one that treats `:` or `-` as in-word characters (trigram, custom). At that point the two tag forms would no longer collapse to the same tokens, and a query expansion (or a proper schema change to a normalized tag table) would become necessary. A regression test that asserts both forms match the same query is a cheap hedge against this — but was deferred per the user's "learning only" preference (2026-04-20 brew-ops session).

Cross-references: see W9 change-log entry 2026-04-20 (mb_agent_oracle_memory commit `0bdfdc3`) for the audit context that flagged this as a P2 follow-up; AGENTS.md §The session preamble at `.claude/oracle-preamble.md` documents the canonical-since-2026-04-19 + bare-legacy-not-retroactively-re-tagged decision; learning `2026-04-19_pattern-w9-step3-extractor-regex-fix` for the original audit that listed this among three P2 items.

---
*Added via Oracle Learn*
