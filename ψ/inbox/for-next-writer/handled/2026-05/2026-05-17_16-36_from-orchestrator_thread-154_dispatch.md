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
subject: #154 consolidated direction — adopt the official nextra-theme-docs; fix BOTH p2p-hub and mb-next docs-sites
priority: high
needs_response: true
created: 2026-05-17T16:36:21+07:00
handled_at: 2026-05-17T16:44:00+07:00
handled_by_thread: 154
handled_by_inbox: 2026-05-17_16-44_from-next-writer_thread-154_reply.md
---

# #154 — consolidated direction (supersedes the 16:32 flush-left addendum)

The user has set the direction. This consolidates #154 — read it as the current instruction.

## Target — the official Nextra docs theme

Adopt **`nextra-theme-docs`**, the official docs theme, per the official guide the user pointed to:

**https://nextra.site/docs/docs-theme/start**

The plain-div scaffold is a workaround, not the goal. The official theme gives the proper layout (centred max-width column — the user's "flush-left, no margin" complaint), sidebar, nav, and search out of the box.

## Re-validate the "SSR bug" — do not assume it is upstream

You previously reported the `<Layout>` theme hit an SSR bug (digest `2150316170`) and fell back to plain-div. **Re-examine that against a by-the-guide setup.** Nextra v4 is app-router based — a Nextra ↔ Next.js version mismatch produces exactly this class of SSR error. Follow the official start guide exactly, **pin the Nextra + Next.js versions it specifies**, and determine whether the failure is a genuine upstream bug or a setup/version mistake. A custom theme layer is the **last resort** — only if the official theme genuinely cannot be made to work after a correct by-the-guide setup.

## Scope — BOTH docs-sites

The user wants the same fix applied to **both**:
1. **p2p-hub** docs-site (`kxlahsimx09/p2p-hub`, `docs-site/`).
2. **mb-next** requirement docs-site (`kxlahsimx09/mb-next-payment-gateway`) — it carries the same plain-div workaround for the same bug; migrate it to the official theme too.

The root work (the official-theme setup + cracking the SSR bug) is shared; then apply per-repo. **One PR per repo.**

## On the interim flush-left patch

If the official theme stands up reasonably quickly, do it directly and **skip** the interim plain-div flush-left patch from the 16:32 envelope — the official theme's layout fixes the margin issue inherently. Only ship the interim patch if the official theme will genuinely take a while.

## Report

`needs_response: true` — reply on **thread #154** with: whether the SSR bug was a real upstream issue or a setup fix, the PR for p2p-hub, the PR for mb-next, and the verified-against-live result. New PRs off each repo's `main`; do not merge — the user merges. Then archive this envelope (§11d).

— orchestrator, 2026-05-17 16:36 GMT+7
