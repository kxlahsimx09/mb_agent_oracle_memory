---
from: next-code-reviewer-2
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "VERDICT bot PR #4 — REQUEST-CHANGES (CI build+push ECR): build leg sound + secrets handling clean; R1 strip temp branch trigger / R2 drop unused id-token:write / R3 retarget+relocate Dockerfile bump — all at retarget time; deployed images stand"
needs_response: false
priority: high
created: 2026-06-11T17:16:00+07:00
---

# bot PR #4 — REQUEST-CHANGES (merge-gate only; deployed artifacts stand)

**PR:** https://github.com/kxlahsimx09/mb-next-bank-bot/pull/4
**Review posted** (body-header `REQUEST-CHANGES`; gh state COMMENTED).

Scope per dispatch: images from this branch are ALREADY deployed (runs
27335551432 / 27337015152 green; live SIM stack runs them). This verdict gates
the **merge**, not the deployment, and does **not block PR #3**.

## What's sound

Builds both variants from the PR-#3 targets, pushes `{sim,realbank}-<sha>` +
`-latest`, digests in run summary — matches the orchestrator's remote-build
ruling and brew-ops's CI leg. Secrets handling clean: keys flow only through
`configure-aws-credentials` (masked); no `pull_request`/`pull_request_target`
trigger → no fork-secret path; repo PRIVATE so the literal account id is
acceptable. Auth = owner option 1 (owner decision, not a finding; OIDC
alternative documented in-file).

## Required before merge (all at retarget time)

- **R1** — strip the `ci/build-push-ecr` branch trigger from `on.push.branches`.
  Load-bearing TODAY (brew-ops redeploys ride it) — do not remove before
  retargeting — but on main it leaves a standing path where a side-branch push
  silently overwrites `:*-latest` without main's review gate. Pair with
  **deleting the branch after merge** (push workflows run from the pushed ref's
  own file copy — the stale branch copy stays live until the branch is gone).
- **R2** — drop `id-token: write` until the OIDC swap actually lands; unused by
  the access-key path; grant it in the same commit that adopts `role-to-assume`.
- **R3** — re-base to main (PR body already promises this) + relocate the
  `v1.58.2-jammy` Dockerfile bump (`85150c7`) into PR #3, whose file it amends
  (cherry-pick recommended in my #3 verdict) — returns #4 to workflow-only,
  one-PR-per-story.

Non-blocking recommendations in the review: pin third-party actions to commit
SHAs (they execute with live AWS creds), `concurrency` group for the `-latest`
tag races, add `.dockerignore` to trigger paths, `timeout-minutes`, optional
`cache-from: type=gha`.

**Re-review:** ping me on the retarget push — I re-check R1/R2/R3 + any new
diff only.

— next-code-reviewer-2, 2026-06-11 17:16 +07
