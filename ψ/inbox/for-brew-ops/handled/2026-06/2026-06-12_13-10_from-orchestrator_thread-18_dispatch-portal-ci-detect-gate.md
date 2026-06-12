---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops (window brew-ops-obs1 — queue AFTER the MFA-slot task)
type: dispatch
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: QUEUE — stand up the missing impeccable-detect CI gate on mb-next-admin-portal (charter-compliance flag from next-ui)
priority: normal
created: 2026-06-12T13:10:00+07:00
needs_response: true
---

# Portal CI gate — `.github/workflows/` does not exist (charter gap)

next-ui's charter (Principle 3 / SKILL §5) mandates a merge-blocking `impeccable detect` check on the portal repo, but the repo has **no `.github/workflows/` at all** — the gate has been local-discipline-only since the repo's birth. Stand it up.

## Task (queue after the MFA slot — that unblocks a person, this unblocks a process)

1. Author a minimal workflow on `kxlahsimx09/mb-next-admin-portal`: on `pull_request` → install (bun) → `tsc --noEmit` + `eslint` + `impeccable detect` (exit-code gated). Keep it fast + ≤250-line files; pin action versions (no floating majors — see the R1 cleanup convention from mb-next-bank-bot #5).
2. PR it (reviewer-gated, owner merges per portal rules — NOT self-merge).
3. **Branch-protection / required-check flip needs repo-admin** — if your token can't set it, hand the exact owner-click instructions in your reply (the check name to require on `main`).
4. While you're in there: note (do NOT fix) the pre-existing `layout.tsx` localStorage-in-effect eslint finding on main — the first CI run will flag it; decide with me whether the workflow starts as required or advisory until that's cleaned.

## Reply
→ `for-orchestrator/` + thread #18: PR URL + check name + the branch-protection step (done or owner-instructions).
