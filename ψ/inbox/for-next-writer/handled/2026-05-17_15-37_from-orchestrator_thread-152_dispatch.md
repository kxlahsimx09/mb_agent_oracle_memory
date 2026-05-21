---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: dispatch
thread: 152
parent_thread: 152
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-9-inbox-1778326296
subject: p2p-hub docs-site — replicate mb-next's doc-site tooling, make the repo Vercel-build-ready
priority: normal
needs_response: true
created: 2026-05-17T15:37:29+07:00
---

# p2p-hub docs-site — same tooling as mb-next, on Vercel

The user wants the `p2p-hub` design doc rendered as a **doc-site**, the **same doc library** mb-next's requirement docs use, deployed on Vercel — so it reads easily.

- Repo: **`kxlahsimx09/p2p-hub`** — already pushed. The doc: `docs/design/p2p-hub-design-exploration.md`.
- The **user** will create the Vercel project and link it to this repo's `main` branch. Your job is the **repo side** — make it Vercel-build-ready.

## Task

1. **Inspect mb-next's docs-site setup** — the doc library / static-site generator it uses, its config, the build deps (`package.json`), and the Vercel build configuration (build command, output dir, any `vercel.json`, framework preset). You have worked mb-next's docs all session — you know where this lives.
2. **Replicate it into the `p2p-hub` repo** — port the generator + config + deps so `docs/` renders as a site. Mirror mb-next's `docs/` conventions so the existing `docs/design/p2p-hub-design-exploration.md` is picked up, and the structure is ready for the rest of the design docs.
3. **Mermaid** — include mermaid rendering support **and** the W1 Step-8 mermaid parser gate; the p2p design doc contains diagrams.
4. **Caveat** — mb-next's own Vercel "Vercel" PR check has been failing all session (a misconfigured team-invite integration, per earlier investigation). If mb-next's docs-site config is itself unclear or broken, **do not copy a broken setup** — flag it on the thread and scaffold a clean, working doc-site config for p2p-hub instead.

## Report

Open a PR to `kxlahsimx09/p2p-hub` (off `main`); do not merge — the user merges, then their Vercel-on-`main` builds it. `needs_response: true` — reply on **thread #152** with the PR and **the exact Vercel settings the user must set** (framework preset / build command / output directory / install command), in case Vercel's auto-detect does not catch them. Then archive this envelope (§11d).

— orchestrator, 2026-05-17 15:37 GMT+7
