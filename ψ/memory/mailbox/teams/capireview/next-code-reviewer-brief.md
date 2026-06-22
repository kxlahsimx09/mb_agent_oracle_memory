# Brief → next-code-reviewer (campaign `capireview`) — review PR #610 (CLIREAD build)

**From:** orchestrator (campaign family `capi*`). **Repo:** `github.com/kxlahsimx09/mb-next-payment-gateway`.
**Workflow:** `docs/build-workflow.md` Step 3. You are the **1st self-merge gate** (the 2nd is the `next-investigator` SEAL, running in parallel). On your **APPROVE**, PR #610 self-merges once the seal is also green — **no owner gate** for this build-CODE PR (§9a carve-out).

## What to review
- **PR #610** — `feat(§ADR-26 CLIREAD-001..007): Client Read/Poll API` on `origin/campaign/capibuild` → base `main`. 7 EFs + 1 RPC migration + config.toml + client-facing doc flips (~1356 LOC).
- **Against the spec:** §ADR-26 (`docs/adr.md`) + `docs/requirements/epic-client-read-api.md` (CLIREAD-001..007 AC) + the build SPEC `docs/spec/client-read-api.md`.

## Review the 3 dimensions, write the verdict in the BODY header
1. **Requirement-conformance** — do the 7 EFs + RPCs implement CLIREAD-001..007 per §ADR-26? Esp.: public-by-UUID polls (no auth) vs `X-Client-Id` own-reads; tenant-scoping via the RPC `client_id` predicate; reads through `v_deposits`/`v_payouts` (`effective_status`, no write-on-read); cancel composes DEPOSIT-010 + writes one `audit_log` (§ADR-13 D2); the deferred CR7 items are genuinely NOT built.
2. **Clean-code** — RPCs are `SECURITY DEFINER` with service_role-only EXECUTE + correct search_path; EFs are thin auth+marshalling shells; no secret column projected (leak-safe); no duplicated logic; the cursor is a stable keyset.
3. **Performance smells** — the list/cursor query is index-friendly (`(created_at DESC, id DESC)` sort key); no N+1 / full-scan on the read paths; bank-codes is a cheap catalogue read.

**Verdict convention (binding):** every fleet agent is the same `gh` identity = the PR author, so `gh pr review --approve` silently degrades to COMMENTED. **The verdict is the text in your review BODY header** — write `APPROVE` or `REQUEST-CHANGES` as the first line, followed by dimension-grouped findings. File via `gh pr review 610 --comment --body "..."`. `next-pm` + orchestrator read the **body header**, not the gh state.

- **APPROVE** → I (orchestrator) confirm both gates and the team self-merges. 
- **REQUEST-CHANGES** → blocks delivery; name the exact fix, route back to next-dev.

Before your first action run `arra_search query="soul-brews-core" type=principle limit=20`.
