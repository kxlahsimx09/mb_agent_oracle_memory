# Brief → next-architect (campaign `capidoc`) — Client read/poll API: ADR + requirements epic

**From:** orchestrator (campaign family `capi*`, closing the client-facing API gaps).
**Repo:** `github.com/kxlahsimx09/mb-next-payment-gateway` (you are in worktree `…wt-c-capidoc`, branch `campaign/capidoc` off fresh `origin/main`).
**Mode:** DOCUMENTS ONLY. You author docs; a separate build chain (next-dev → tester → investigator → reviewer → brew-ops → live → pm) builds afterward. Do NOT write `supabase/` code.

## Why you are here
The prior `featweb` campaign produced an honest LIVE-vs-GAP analysis of our merchant-facing (client-integrator) API vs the current production system (maxpay/mobiz). The gaps are a **client READ/POLL surface** a merchant needs but we don't expose. Your job: turn the descriptive gap docs into a **ratified ADR + a build-ready requirements epic** so the build chain can close the gaps.

## Source material (READ FIRST — all on `origin/campaign/featweb`, already fetched into your repo's object store)
Read via `git show origin/campaign/featweb:<path>` (or `git show campaign/featweb:<path>`):
- `docs/api/gap-vs-current-maxpay.md` — the gap table (merchant-facing API section + "What we'd ADD to reach merchant-integration parity").
- `docs/internal/spec-diff/02-deposits.md` — deposit status-poll / get-by-id / list / cancel / slip field-level diffs + exact current response shapes.
- `docs/internal/spec-diff/03-payouts.md` — payout status-poll / get-by-id / list diffs + shapes.
- `docs/internal/spec-diff/04-wallet-banks.md` — client wallet balance + bank-code list exact current shapes.
- `docs/api-client/status.md`, `docs/api-client/balance-banks.md` — the client-facing "GAP — not implemented" docs (illustrative target shapes).
- Original handoff: `ψ/inbox/handoff/2026-06-18_00-26_client-api-gaps-featweb.md`.

Also read the EXISTING doc layer (on `origin/main`) so your work composes, doesn't duplicate:
- `docs/adr.md` — esp. §ADR-2 (auth/RLS two-layer), §ADR-7 (client API-key + HMAC machine auth), §ADR-11 (idempotency + per-client rate-limit), §ADR-11/§ADR-2 §Amendment-2026-05-28 (the **CF edge gateway** GW1a/GW1b — note its current status below). Pick the **next free §ADR number**.
- `docs/requirements/epic-client-api.md` — currently NFR-only (CLIENT-001 idempotency + CLIENT-002 rate-limit). The read surface is NOT covered there.
- `docs/requirements/epic-deposit.md`, `epic-payout.md`, `epic-callback-delivery.md`, `epic-beneficiary-bank-account.md` (the most recent epic for house style + trust-label conventions), `docs/requirements/README.md` / `INDEX.md` / `glossary.md`.
- `docs/build-workflow.md` — so you write AC the way next-dev (SPEC) + next-tester (probes) consume.

## The governing rule: PARITY WITH CURRENT
Owner's standing rule across this project (same as `/bank-accounts`, `/otp-logs`): **match current production behavior.** This makes spec-authoring *documenting existing behavior* (P-004 Code is Truth), not inventing product. Where current maxpay has the endpoint, port its shape. Trust label for port-fidelity = **S2** (as BENE-001..006 in the bene epic).

## SCOPE — author docs for THIS set (the clear-parity read/poll surface)
Each item below has a named current endpoint and an exact target shape in the spec-diffs. Author AC to parity:

1. **Deposit status poll (public, by id)** — current `GET /deposit/status/:txnId` (no auth). Returns `{ txnId, status, amount, paidAmount?, paidAt?, expiresAt }`. **Side effect: lazy expiry** — a `pending` deposit past `expires_at` is atomically flipped to `expired` on poll. 404 when not found. (spec-diff 02 "Status poll".)
2. **Payout status poll (public, by id)** — current `GET /payout/status/:txnId` (no auth). Returns `{ txnId, status, amount, failureReason?, bankTransactionId? }`. 404 when not found. (spec-diff 03.)
3. **Deposit get-by-id + Payout get-by-id (API-key, own)** — current `GET /deposit/:txnId`, `GET /payout/:txnId` (API-key, tenant-scoped to the caller's own rows).
4. **List deposits / payouts (API-key + filters + pagination)** — current `GET /deposit`, `GET /payout` (API-key; paginated + filtered). Our `tenant-read` is the partial equivalent but is **gotrue-session-only, limit-only, no by-id, no cursor, no status/date/merchantId filters**. Reach parity: either extend `tenant-read` to accept the API-key credential + add pagination cursor + `status`/date/`merchantId` filters, OR add a dedicated API-key list read. (spec-diff 02/03/04 "Tenant read".)
5. **Client wallet balance (API-key)** — current `GET /client/balance`. Returns `{ clientId, name, balance, available, frozen, updatedAt }` where `available = balance − frozen`. The wallet row exists in Postgres; just no client read. "Single most-requested missing merchant read." (spec-diff 04.)
6. **Bank-code list (API-key)** — current `GET /client/bank/list/code` → `[{ code, name, name_th, name_en, color }]` and `GET /client/banks` → `{ data:[{id, bank_name, bank_code, int_code, bank_logo}], pagination }`. Lets a merchant validate `customer_bank_bank_code` / `dest_bank_code` before submitting. (spec-diff 04.)
7. **Merchant self-cancel deposit (API-key path)** — current `POST /deposit/:txnId/cancel` is **merchant-API-key** authed; ours (`deposits-cancel`) is **admin-gotrue-session only**. Parity: add an API-key client cancel path for the caller's own pending deposit (marks expired; 409 if not cancellable / slip present). (spec-diff 02 "Cancel".)

## OUT OF SCOPE — flag as DEFERRED future-driver items; do NOT block the read surface on them
Record these in the ADR's "Deferred / out of scope" section as explicit future drivers, but do NOT author build stories for them in this pass (they are genuine product/divergence decisions, not parity-documentation):
- **Webhook retry depth (3 → 7).** Ours is a deliberate 3-attempt/30s design; current is 7-over-~40min. This is a *deliberate divergence weigh* (handoff "regression #1"), an owner product decision — not parity-documentation. Flag; do not change.
- **Slip upload multipart vs string-URL.** Ours takes `slip_image_url` (string); current takes a multipart `slip_image` file (≤5MB). Adding a multipart ingest path is new behavior, owner-decision (handoff "regression #2"). Flag; do not spec.
- **Gateway day-budget caps** (per-client daily caps enforced at the CF Worker). PoC limitation; gated on the CF gateway. Flag; defer.
- **Merchant self-cancel PAYOUT** — neither system offers it (current route is commented out) → SAME, **no work**. Note as no-gap.
- **Merchant self-serve callback resend** — optional; operator-only today in both the practical sense. Defer.
- **`/jwt/create` + `/hash/verify` signing helpers** — intentionally dropped (our model has the client compute its own HMAC). Note as intentional-drop, no work.

## Auth-model guidance (the one real architectural decision — within your authority)
The CF edge gateway (GW1a/GW1b, §ADR-2/11 §Amendment-2026-05-28) is the FUTURE machine-auth front door, but its **custom domain is NOT provisioned** — GW1b is an explicitly DEFERRED leg (see the §ADR "AUTH full-epic-seal" carve-out 2026-06-12). So the read surface must NOT be blocked on the gateway. Decide per endpoint class, consistent with what ships TODAY:
- **Public status polls (items 1–2):** capability-by-UUID, **no auth** — exactly like the already-shipped public `deposits-qr` EF. The deposit/payout id is the capability. (Parity: current status polls are public/no-auth.)
- **API-key own-reads (items 3–7):** authenticate the merchant at the **EF tier** with the same client credential the create/upload EFs use today (`X-Client-Id` + `X-Signature` HMAC, per §ADR-7), tenant-scoped to the caller's own client_id (RLS / effective_client_id), parity with `deposits-create` / `deposits-upload-slip`. The future CF-gateway-fronting is orthogonal infra (when the domain lands, these reads move behind GW1b like the creates) — say so, don't gate on it. You make the final call; record the rationale.

If you judge a genuine **new PRODUCT decision** (not technical, not parity) is unavoidable and BLOCKS the read surface, STOP and write a handoff to `ψ/inbox/handoff/` flagging the open decision (don't guess) — the orchestrator will surface it. Per [[handoff-not-autodispatch-when-spec-missing]]. (We don't expect this — items 1–7 are clean parity.)

## Deliverables
1. **ADR** — append a new `§ADR-<next-free-number>` to `docs/adr.md`: "Client Read/Poll API Surface" — the read/poll endpoint set, auth model per class (above), tenant-scoping (RLS/effective_client_id), the list filter+pagination contract, the deposit-poll lazy-expiry semantics, wire shapes to parity, and the Deferred section. Append-only (P-001).
2. **Requirements epic** — new `docs/requirements/epic-client-read-api.md` (suggested story prefix `CLIREAD-001…`), one story per item 1–7, each with: user-journey, AC in given/when/then, edge cases, Sources (new:adr → your §ADR; old:code → the current maxpay routes/controllers named in the spec-diffs). House style = `epic-beneficiary-bank-account.md`. Wire it into `docs/requirements/README.md` + `INDEX.md`. Trust = S2 (port-fidelity).

## Branch / commit / merge discipline
- You are already on `campaign/capidoc` off **fresh origin/main** (the helper used §3d explicit form). Commit from THIS worktree only — never the shared primary (§3c). 
- Open PR(s) (ADR + epic can be one PR or two). PR base = `main`.
- **Merge authority:** this is parity-documentation + a technical auth-model decision (no new *product* decision) → **reviewer-gated + self-merge is authorized** for this pass (owner granted standing autonomy this session: "close as much as possible, don't ping unless genuinely blocked"; same carve-out the bene/§ADR-22 follow-ups used for no-new-product-decision docs). Get a clean self-review/`next-code-reviewer`-style pass on conformance, then merge to main so the build chain (off fresh origin/main) sees the AC + ADR. If you embedded any genuine NEW PRODUCT decision, leave THAT PR owner-gated and tell the orchestrator.
- Do NOT touch the deferred/out-of-scope items in code or as build stories.

## Report back (write a reply note to `ψ/inbox/handoff/` AND keep your team pane output clear)
When done, report to the orchestrator: the §ADR number authored, the epic filename + the exact story IDs (CLIREAD-00N) per item, which PR(s), merged-or-owner-gated, and any deferred decision you flagged. That's what the build chain consumes — the orchestrator will relay your §ADR + epic story IDs to next-dev as the build input.
