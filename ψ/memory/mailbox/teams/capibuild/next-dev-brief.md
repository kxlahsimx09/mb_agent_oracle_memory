# Brief → next-dev (campaign `capibuild`) — BUILD the Client Read/Poll API (CLIREAD-001..007)

**From:** orchestrator (campaign family `capi*`). **Repo:** `github.com/kxlahsimx09/mb-next-payment-gateway` (you are in worktree `…wt-c-capibuild`, branch `campaign/capibuild` off fresh `origin/main`).
**Workflow:** `docs/build-workflow.md` (Step 0 SPEC-first → Step 1 parallel build). You build; a separate `next-tester` probes from your SPEC **without ever reading your code** (de-bias). brew-ops deploys shared stacks. You deploy ONLY your own dev-1 sandbox.

## What to build — CLIREAD-001..007 (the merged spec is your contract)
The doc layer is MERGED to `origin/main`:
- **§ADR-26 — Client Read/Poll API Surface** in `docs/adr.md` (CR1–CR7; the endpoint-level decisions, auth model, wire shapes, lazy-expiry, cursor/filter contract, deferred items). **This is your authority.**
- **`docs/requirements/epic-client-read-api.md`** — CLIREAD-001..007 with full AC (your story contract).
- Wire-shape grounding (field-by-field current-vs-next) on `origin/campaign/featweb`: `docs/internal/spec-diff/02-deposits.md` · `03-payouts.md` · `04-wallet-banks.md`; client-facing HTTP shapes in `docs/api-client/{status,balance-banks}.md`.

The 7 stories (all S2 parity, EF tier — NOT gated on the unprovisioned CF gateway):
1. **CLIREAD-001** deposit status poll — **public, capability-by-UUID (no auth)**, like the shipped `deposits-qr` EF. `{txnId,status,amount,paidAmount?,paidAt?,expiresAt}`; status via `v_deposits.effective_status` (0-lag lazy-expiry, **no write-on-read**); unknown id → 404.
2. **CLIREAD-002** payout status poll — public-by-UUID. `{txnId,status,amount,failureReason?,bankTransactionId?}`; unknown → 404.
3. **CLIREAD-003** deposit + payout get-by-id (own) — **§ADR-7 `X-Client-Id`+`X-Signature` HMAC at EF tier**, tenant-scoped to own `client_id` (§ADR-2 RLS / `effective_client_id`); cross-tenant/unknown → 404; read through leak-safe `v_deposits`/`v_payouts_read`.
4. **CLIREAD-004** list deposits/payouts — API-key, own scope; **cursor pagination + filters** (`status`, date range, `merchantId`, `transaction_id`, amount exact+range); filters only ever NARROW within own rows. **Architect lean: a dedicated API-key read EF over `v_deposits`/`v_payouts_read`, leaving `tenant-read`'s gotrue-session contract untouched** — your impl call, record it in the SPEC.
5. **CLIREAD-005** wallet balance — API-key, own wallet. `{clientId,name,balance,available,frozen,updatedAt}`, `available = balance − frozen` (from the deployed wallet `{balance,frozen}` model; epic-wallet-ledger).
6. **CLIREAD-006** bank-code list — API-key. `[{code,name,name_th,name_en,color}]` and/or `{data:[{id,bank_name,bank_code,int_code,bank_logo}],pagination}`. **project-what-exists** on decoration fields (`color`/`bank_logo`/`name_th`/`name_en`) — surface what the bank/system-bank substrate holds, do NOT invent. The **code/name pair is load-bearing** (the codes the create paths validate against).
7. **CLIREAD-007** merchant self-cancel deposit (API-key path) — API-key, own `client_id`. **ADDS** an API-key actor path; the admin-session `deposits-cancel` stays untouched. Composes **DEPOSIT-010**: → `cancelled` terminal (≠ `expired`, §ADR-9); 409 `NOT_PENDING`/`SLIP_PRESENT`; idempotent re-cancel (no 409, no client `Idempotency-Key`); **403 cross-tenant / 404 unknown** (the write contract — differs from the reads' RLS-404); §ADR-13 D1 3-layer write + canonical `audit_log` (D2).

**DO NOT build the §ADR-26 CR7 deferred items** (webhook retry depth, slip multipart, day-caps, self-cancel-payout, callback-resend, jwt/hash helpers).

## Step 0 — SPEC-FIRST (do this EARLY, before deep impl)
Emit the **test-facing SPEC** to `docs/spec/client-read-api.md` — the contract `next-tester` binds probes off **without reading your code**. It must name, per endpoint:
- **HTTP**: method + path/EF name, request shape (params/headers — incl. `X-Client-Id`/`X-Signature` where applicable, or "public, no auth"), response JSON shape (exact field names), status codes + error tokens.
- **DB / observable surface**: tables/views/columns the probes read (e.g. `v_deposits.effective_status`, the wallet row, the bank catalogue source), and any RPCs.
- The CLIREAD-00N ↔ endpoint mapping, and the cursor/filter contract for CLIREAD-004.
**Commit + push the SPEC to `origin/campaign/capibuild` EARLY** and **report its `branch` + `path` back to the orchestrator** (`origin/campaign/capibuild` : `docs/spec/client-read-api.md`) so I relay it to `next-tester`. If the contract changes later, broadcast the change — never "go read my code."

## Step 1 — BUILD
- Implement EFs / RPCs / migrations / views per §ADR-26. Reuse existing substrate: `v_deposits`/`v_payouts_read` leak-safe views, `effective_status` (§ADR-4c), the wallet model, the bank/system-bank catalogue, DEPOSIT-010 cancel semantics, §ADR-7 `_shared` auth helpers, §ADR-13 D1/D2 write+audit for the cancel.
- **Deploy to YOUR dev-1 sandbox ONLY** for self-verification: project ref `qvmjywljrgqzyxshexhx`, slot `.secrets/slots/dev-1.env`. Reset the sandbox to a clean state first, then `supabase db push` + `functions deploy` your new migrations+EFs there and smoke them. This is the **one** deploy you may run (§9b dev-N exception). **Do NOT deploy to tester / seal / staging** — that's brew-ops (you don't hold those creds anyway).
- **Hand off to brew-ops** (report to orchestrator) the **exact migration set + EF list** (file names + the commit/PR ref) so brew-ops can cross-stack deploy to `tester` (`yupsevcrubgprsbujbpu`) + `investigator` seal (`qnccphgykzdydebmdwdf`).
- Flip the client-facing HTTP docs `docs/api-client/{status,balance-banks}.md` from GAP → LIVE for the shipped endpoints (same PR is fine).

## PR / branch / merge discipline
- Commit from THIS worktree only (§3c); you're already on `campaign/capibuild` off fresh origin/main (§3d).
- Open the PR (base `main`) once the build is real. Push the SPEC to the branch FIRST (Step 0).
- **Self-merge is a build-CODE carve-out gated on TWO greens** (per fleet rule): `next-code-reviewer` **APPROVE** (read the review **BODY header**, not gh state) **AND** `next-investigator` **SEAL**. Do NOT self-merge before both land. No destructive ops.
- Before your first action run `arra_search query="soul-brews-core" type=principle limit=20`.

## Report back to the orchestrator (concise, when each milestone lands)
1. **SPEC pushed** → `origin/campaign/capibuild` : `docs/spec/client-read-api.md` (so I dispatch the tester).
2. **dev-1 self-verify** result (smoke green on the sandbox).
3. **brew-ops handoff list** — migrations + EFs to deploy to tester+seal (commit/PR ref).
4. **PR number** opened.
Then await the VERIFY/REVIEW/SEAL chain; self-merge only on the two greens.
