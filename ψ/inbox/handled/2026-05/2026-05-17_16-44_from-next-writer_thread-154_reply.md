---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 154
parent_thread: 154
parent_oracle: orchestrator
in_reply_to: 2026-05-17_16-36_from-orchestrator_thread-154_dispatch.md
subject: "#154 — official nextra-theme-docs adopted on both docs-sites; SSR bug is a genuine upstream bug"
priority: high
needs_response: false
created: 2026-05-17T16:44:00+07:00
---

# #154 reply — official theme adopted, both repos; SSR bug verdict

Full detail posted to **thread #154** (message 446). Summary:

## SSR bug — genuine upstream bug, not a version mismatch

Re-validated against a by-the-guide setup (https://nextra.site/docs/docs-theme/start):
`next@15.5` + `nextra@4.6.1` + `nextra-theme-docs@4.6.1` — the matched
latest pair the guide installs; there is **no Nextra↔Next mismatch**.
Traced to source: `nextra-theme-docs@4.6.1`'s `<Layout>` destructures
`children` out of props before validating the rest against
`LayoutPropsSchema`, which still declares `children` **required**. Under
Zod 4 (shipped by Nextra 4.6) a missing non-optional key throws
"expected nonoptional, received undefined". Genuine bug in the current
latest theme; no version pin avoids it. Fixed with a one-line
`patch-package` patch (vestigial field → `.optional()`), applied via a
`postinstall` hook.

## Both docs-sites on the official theme

Skipped the interim plain-div flush-left patch — went straight to the
official `nextra-theme-docs` theme.

- **p2p-hub:** official theme = PR #2 (merged); content-column fix =
  **PR #3 (open)** — https://github.com/kxlahsimx09/p2p-hub/pull/3
- **mb-next:** **PR #148 (open)** — official theme + content-column fix
  in one PR — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/148

p2p-hub two PRs (not one) only because dispatches arrived sequentially
and PR #2 was merged before the 16:36 consolidation; PR #3 is the single
remaining PR.

## Verified

p2p-hub PR #2's official theme is live (`p2p-hub-eta.vercel.app`,
curl-confirmed navbar/sidebar/search). PR #3 and mb-next PR #148 verified
locally — clean `npm install && npm run build` green, content column +
`<article>` + `<main>` + `nextra-toc` present, routes 200 / 404.

**To close #154: user merges p2p-hub #3 and mb-next #148** (agents do not
merge). Live verification of the centered column follows those merges.

— next-writer, 2026-05-17 16:44 GMT+7
