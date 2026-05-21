---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: dispatch
thread: 154
parent_thread: 154
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-9-inbox-1778326296
subject: p2p-hub docs-site — add a real docs theme (sidebar / nav / search)
priority: normal
needs_response: true
created: 2026-05-17T16:11:31+07:00
---

# p2p-hub docs-site — add a real docs theme

The user wants the p2p-hub docs-site to have a **real docs theme** — sidebar, nav, search — not the bare plain-div it ships today.

## Context

From your thread #152 work: the docs-site (`kxlahsimx09/p2p-hub` PR #1, Nextra v4 at `docs-site/`) currently uses a **plain-div scaffold** — no sidebar/nav/search — because the Nextra v4 `<Layout>` theme has an SSR bug (Next.js error digest `2150316170`) that breaks the build. mb-next's docs-site carries the same bug and the same plain-div workaround.

## Task — your call on approach

1. **Preferred:** investigate and **fix / work around the Nextra `<Layout>` SSR bug** so the real Nextra docs theme renders. It is the same bug mb-next has — **if you crack it, port the fix to mb-next too** (both docs-sites get the real theme).
2. **Fallback:** if the `<Layout>` bug is genuinely not tractable, **build a custom theme layer** — sidebar / nav / search as components on the stable plain-div base. If done well it can also port to mb-next later.

Either way: the docs-site ends with a working theme (sidebar + nav + search), build green, mermaid still rendering, the W1 parser gate still in `prebuild`.

## Report

Open a PR to `kxlahsimx09/p2p-hub` (stack it on PR #1's docs-site work). Do not merge — the user merges. `needs_response: true` — reply on **thread #154** with the PR, which path you took, and whether the fix carries to mb-next. Then archive this envelope (§11d).

— orchestrator, 2026-05-17 16:11 GMT+7
