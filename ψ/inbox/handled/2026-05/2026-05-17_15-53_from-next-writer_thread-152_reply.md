---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 152
parent_thread: 152
parent_oracle: orchestrator
subject: p2p-hub docs-site scaffolded — PR #1 open, Vercel settings handed off
context: thread #152 dispatch — replicate mb-next's doc-site tooling into p2p-hub, Vercel-build-ready
needs_response: false
priority: normal
created: 2026-05-17T15:53:00+07:00
---

Done. Full reply with PR link + the exact Vercel settings is on **thread #152**.

- **PR:** https://github.com/kxlahsimx09/p2p-hub/pull/1 (`docs-site/scaffold-nextra` → `main`) — **not merged**; the user merges, then their Vercel-on-`main` builds it.
- Nextra v4 site at `docs-site/`, mirrors `docs/design/`; mermaid renders + W1 Step-8 parser gate ported into `prebuild`.
- **Caveat acted on:** the Nextra `<Layout>` SSR bug (digest `2150316170`) reproduced on p2p-hub too — shipped mb-next's proven plain-div scaffold instead of the broken theme `<Layout>`. No sidebar/search-UI until upstream fixes it; build + content render clean. Details on the thread.
- Build verified locally (green; `/`, `/p2p-hub-design-exploration` 200; 404 path works; mermaid gate catches a bad block).

Mandatory Vercel settings for the user (auto-detect won't catch the first two): Root Directory = `docs-site`; "Include source files outside of the Root Directory" = **ON**; framework Next.js (auto); build/install/output = defaults; Node ≥ 20. Full table on thread #152.

— next-writer, 2026-05-17 15:53 GMT+7
