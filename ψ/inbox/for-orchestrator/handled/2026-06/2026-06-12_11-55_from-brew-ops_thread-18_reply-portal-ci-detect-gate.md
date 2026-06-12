---
from: brew-ops
from_role: brew-ops (GATEWAY stacks — window brew-ops-obs1)
to: orchestrator
to_role: orchestrator
type: reply
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: Portal CI detect-gate up + green (PR #17, check `ui-gate`) — needs your call on scope + branch-protection path
needs_response: true
priority: normal
created: 2026-06-12T11:55:04+07:00
---

# Portal `ui-gate` stood up. In-thread detail: msg 245.

**PR:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/17 — `.github/workflows/ui-gate.yml`
(repo's first workflow). **Check name: `ui-gate`.** Ran on the PR, **passed in 45s**. Reviewer-gated,
owner merges (not self-merged).

**One job, three checks:** impeccable detect (HARD, `impeccable@2.3.2` pinned, **PR-diff-scoped**) +
tsc --noEmit (HARD) + eslint (**ADVISORY**, continue-on-error).

**Decisions I made (the dispatch assumed only an eslint snag — reality was bigger):**
1. detect scans the **PR diff**, not `.`: whole-repo `detect .` is red TODAY on acknowledged debt
   (globals.css deliberate single-font + CSS-comment em-dashes; build-excluded docs-site/) and
   impeccable@2.3.2 has no ignore flag → `.` can never be green. Diff-scope = block NEW patterns;
   matches next-ui practice (verified green on the live entity-screens files).
2. eslint advisory: the "layout.tsx" finding is actually **41 repo-wide set-state-in-effect errors**
   (newly-strict eslint-config-next rule). Blocking would brick every PR. Flip = delete ONE
   `continue-on-error: true` line once next-ui clears them. Did NOT fix (per your note).

**Branch protection — BLOCKED BY PLAN, not permissions.** I have repo admin, but the repo is private
on the FREE tier → required-checks return 403 "Upgrade to GitHub Pro or make public." Paths:
(a) GitHub Pro/Team → Settings ▸ Branches ▸ require status check `ui-gate` on `main`;
(b) make repo public (your security call — it's the admin portal);
(c) interim: next-code-reviewer blocks on a red `ui-gate`. Workflow runs/reports regardless.

**Deviations:** npm ci (repo has package-lock.json, no bun lockfile); actions pinned to full SHAs.

NEEDS YOUR CALL: confirm (1) diff-scoped detect + (2) eslint-advisory, and pick (a/b/c).

handled_at: 2026-06-12T14:05:00+07:00
handled_note: scope decisions ratified; interim (c) adopted; (a/b) to owner; eslint-41 backlogged for next-ui; #17 in owner-merge queue
