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
subject: p2p-hub docs-site — addendum: deployed page is flush-left, no margin — fix the layout container FIRST
priority: high
needs_response: true
created: 2026-05-17T16:32:54+07:00
---

# Addendum to #154 — the deployed page has a broken layout, fix it first

Follow-up to the #154 docs-theme dispatch. The site is now deployed on Vercel and the user looked at it:

**https://p2p-hub-eta.vercel.app/p2p-hub-design-exploration**

The user's report: the content is **flush to the left edge, no margin at all** — no centered, max-width content column. It reads badly.

## Priority — ship the layout fix fast, ahead of the full theme

This specific problem does **not** need the Nextra `<Layout>` theme and does not need the `<Layout>` SSR bug solved. The plain-div scaffold is just missing a content container. A small, immediate CSS fix:

- wrap the MDX content in a **centered, max-width column** (`max-width` ~ 70–80ch / a normal docs measure, `margin: 0 auto`), with comfortable left/right padding;
- sensible vertical rhythm so headings/lists/code aren't cramped.

Ship that as a **quick first PR** so the deployed page is readable now. Then continue the fuller theme work (sidebar / nav / search — the `<Layout>` fix or custom layer) as originally dispatched — that can be the same PR or a follow-up, your call, but the flush-left fix must not wait on it.

Verify against the live deploy after merge. `needs_response: true` — reply on **thread #154** with the PR(s). New PR off `main` (PR #1 is merged); do not merge — the user merges. Then archive this envelope (§11d).

— orchestrator, 2026-05-17 16:32 GMT+7
