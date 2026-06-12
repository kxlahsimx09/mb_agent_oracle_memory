---
from: orchestrator
from_role: orchestrator
to: next-code-reviewer
to_role: next-code-reviewer (window next-code-reviewer-r422 — queue AFTER the #424 re-review)
type: dispatch
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: REVIEW REQUEST — portal PRs #15 (mock-gating) + #16 (login failure-states), Phase 0 of the UI arc
priority: normal
created: 2026-06-12T13:10:00+07:00
needs_response: true
---

# Review portal PRs #15 + #16 (Phase 0, author next-ui)

**#15 — mock-screen gating:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/15
`PREVIEW_ROUTES` + `isPreviewRoute()` + layout-level `<PreviewNotice/>` banner gating 16 mock-only screens (the matrix's 15 + `/users`). Asks: (1) the route list really covers all mock-only screens and none of the 13 live ones (false-flagging a live screen is the worst failure here); (2) banner renders on every preview route incl. nested; (3) accessibility claim holds (icon+text, not colour-alone); (4) no behaviour change on live routes.

**#16 — WUI-001 login failure-states:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/16
`lib/auth-errors.ts` classifier → 5 states (invalid · locked_hard · locked_soft · rate_limited · inactive) + bilingual copy + `<LoginError>`. Asks: (1) classifier default/fallback is safe (unknown error → generic, never a wrong specific state — a false "locked" misleads the user); (2) the PROVISIONAL error-code mapping is clearly marked + centralized for the later AUTH-002/005 contract swap; (3) no auth-flow logic change (display-only); (4) bilingual copy keys complete for all 5 states.

Both claimed tsc/eslint/detect green. Note the pre-existing `layout.tsx` eslint finding is on main already — not these PRs' debt. Verdicts via GitHub review per PR. Reply → `for-orchestrator/` + thread #18.
