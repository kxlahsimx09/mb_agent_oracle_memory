# Brief → next-tester (campaign `capitest`) — PROBE the Client Read/Poll API (CLIREAD-001..007)

**From:** orchestrator (campaign family `capi*`). **Repo:** `github.com/kxlahsimx09/mb-next-payment-gateway` (worktree `…wt-c-capitest`, branch `campaign/capitest` off fresh origin/main).
**Workflow:** `docs/build-workflow.md` Step 1 (parallel) → Step 2 (verify by falsification). You are **layer-1 de-bias**: you bind probes off the **SPEC only** and you are **FORBIDDEN from reading `next-dev`'s `supabase/` implementation code — ever** (not even read-only). Expected behaviour comes from the SPEC/AC, never the code.

## Your contract — the SPEC (read it, bind every probe off it)
```
git show origin/campaign/capibuild:docs/spec/client-read-api.md
```
That SPEC is the single shared contract (branch `origin/campaign/capibuild`, path `docs/spec/client-read-api.md`). It gives, per story: exact HTTP method/path/EF-name, request shape (headers — public vs `X-Client-Id`), 200 JSON field names, status codes + error tokens, the observable DB surface, and **the probe "teeth"** to assert. Also read the AC in `docs/requirements/epic-client-read-api.md` (origin/main) + §ADR-26 (docs/adr.md). If the SPEC changes mid-build, the dev broadcasts it — re-read it; never go read the code.

## The 7 stories (probe each per its SPEC section)
- **CLIREAD-001/002** — public-by-UUID deposit/payout status polls: shape, unknown→404, and the **0-lag lazy-expiry teeth** (a slip-less `pending` deposit past `expires_at` reads `expired` while the physical row stays `pending` — the poll must NOT write).
- **CLIREAD-003** — get-by-id own (deposit+payout), `X-Client-Id`; **cross-tenant id → 404** (RLS-unreachable, indistinguishable from unknown).
- **CLIREAD-004** — list own + cursor pagination + filters; **teeth:** (a) two cursor pages cover the set with no overlap/no gap; (b) any filter combo ⊆ own rows; (c) another tenant's `merchantId` → `[]`; bad cursor → 400.
- **CLIREAD-005** — wallet balance `{clientId,name,balance,available,frozen,updatedAt}`, `available = balance − frozen`.
- **CLIREAD-006** — bank-code list; `code`/`name` are the load-bearing codes the create paths validate; decoration fields absent (project-what-exists).
- **CLIREAD-007** — self-cancel deposit (the **write** contract): → `cancelled` terminal (≠ expired); 409 `NOT_PENDING`/`SLIP_PRESENT`; idempotent re-cancel (200, no 409, no Idempotency-Key); **403 cross-tenant vs 404 unknown** (distinct from the reads' 404-RLS model — assert BOTH separately); exactly one `audit_log` row on a fresh cancel, none on re-cancel.

## Stack + the Stack-readiness gate (STRUCTURAL precondition — do this FIRST before any probe)
- **Your stack = `tester`** — Supabase ref `yupsevcrubgprsbujbpu`, slot `.secrets/slots/tester.env`.
- The new migration + 7 EFs (`client-deposit-status`, `client-payout-status`, `client-deposits`, `client-payouts`, `client-wallet-balance`, `client-bank-codes`, `client-deposit-cancel`) are deployed to the tester stack by **brew-ops** (the sole shared-stack deploy actor — you don't hold tester creds to deploy, and must not). 
- **Run `scripts/stack-freshness.sh tester`** + confirm the 7 EFs **respond (not 404)** and the new RPCs exist before probing. **A bare or STALE stack is a BLOCKER to surface to the orchestrator, never a silent idle, and NEVER counted green.** If the EFs 404, tell the orchestrator "tester stack not yet deployed — need brew-ops" and wait for the ready signal; do not idle answering keepalives, do not fabricate green.
- **Parallel-build now:** while the dev builds + brew-ops deploys, **design + build your probes + fixtures from the SPEC** and **validate the harness first** (confirm it actually FAILS on a violation) so a later green is trustworthy. Then run once the stack is ready.

## Report (Step 2)
Report **per-AC PASS/FAIL derived from DB ground-truth / API responses** (never the dev's claim, never the code). Hand the full probe result set to the orchestrator so I route it to `next-investigator` for the independent ground-truth seal. A bare/stale stack or a harness that can't fail = surface it, not a green.

Before your first action run `arra_search query="soul-brews-core" type=principle limit=20`.
