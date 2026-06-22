# Handoff — Client-facing API gaps to close (mb-next payment gateway)

**For:** the next orchestrator session, to dispatch the build work that closes the client-facing (merchant-integrator) API to parity with the current maxpay/mobiz system.
**Source:** campaign `featweb` (orchestrator). Repo `github.com/kxlahsimx09/mb-next-payment-gateway`, branch `campaign/featweb` @ `b290c08` (NOT pushed/merged yet). Grounded in code + verified by next-dev; honest LIVE-vs-GAP.

## What a merchant CAN do today (LIVE)
- `POST {BASE_URL}/deposits-create` — create deposit (API key + HMAC `X-Client-Id`+`X-Signature`)
- `POST {BASE_URL}/deposits-upload-slip/<id>` — upload slip (API key)
- `GET {BASE_URL}/deposits-qr/<id>` — render QR PNG (public; UUID = capability)
- `POST {BASE_URL}/payouts-create` — create payout (API key + HMAC; route = `pool_id` XOR `required_bank_account_id`)
- Receive signed webhooks at their hosted URL (`X-Signature` t=,v1= HMAC over `<t>.<rawBody>`; `X-Event-Id` dedup; UA `Gateway-Callback/1.0`)

**Takeaway today:** integration is **webhook-driven, not poll-driven.** A merchant cannot read status, list, balance, banks, or self-cancel/self-resend.

## GAPS to close (what to BUILD) — each is missing in our code; current-maxpay shape is the parity target
1. **Deposit status poll / get-by-id** *(biggest merchant gap)* — current: `GET /deposit/status/:txnId` + `GET /deposit/:id` (API-key). Ours: none. BUILD an API-key-authenticated read.
2. **Payout status poll / get-by-id** — current: `GET /payout/status/:txnId` + `GET /payout/:id`. Ours: none.
3. **List deposits / payouts (API-key + filters + pagination)** — current: `GET /deposit`,`/payout` (API-key, filters). Ours: only `tenant-read` which is **gotrue-session, no API-key path, no filters, no get-by-id** → not usable by a merchant integrator. BUILD an API-key list/get surface (or open tenant-read to API-key + add filters).
4. **Client wallet balance** — current: `GET /client/balance` (API-key). Ours: none.
5. **Bank-code / bank list** — current: `GET /client/banks` + `/client/bank/list/code` (API-key). Ours: none.
6. **Merchant self-cancel deposit** — current: `POST /deposit/:id/cancel` (merchant API-key). Ours: `deposits-cancel` is **admin-session only** → add an API-key client path.
7. **Merchant self-cancel payout** — not offered to merchants; current also has it commented out — LOW priority / confirm demand.
8. **Merchant self-serve callback resend** — ours `*-resend-callback` is admin-only → optional API-key path.

## 2 deliberate regressions to weigh (decide keep vs match current)
- **Webhook retry depth:** ours **3 attempts / 30s timeout**; current **7 attempts over ~40 min**. Fewer retries = higher chance a merchant misses a terminal event. Decide whether to raise.
- **Slip upload contract:** ours takes a pre-hosted `slip_image_url` **string**; current takes a **multipart file** (`slip_image`, ≤5 MB). Merchants migrating from current expect multipart — decide whether to add a multipart path.

## Pointers
- Client-facing API doc (the LIVE set, HTTP-only, no internal/EF terms): `docs/api-client/` (INDEX has the LIVE-vs-GAP table).
- Internal gap summary: `docs/api/gap-vs-current-maxpay.md`. Detailed field-level diff: `docs/internal/spec-diff/` (esp. `02-deposits.md`, `03-payouts.md`, `04-wallet-banks.md`, `05-callbacks-webhooks.md`).
- Full internal API reference (all endpoints): `docs/api/`.
- Live previews (Caddy basic-auth `owner` / `6Rtu3sLmYxy0tF`): landing+docs `https://featweb.3-1-0-33.sslip.io/` (`/docs` = client API). Separate Nextra docs-site `https://featweb-docs.3-1-0-33.sslip.io/api` (redundant now — candidate for teardown).

## To CLOSE
Dispatch a build campaign (next-dev builds the endpoints on its own dev-N stack → next-tester probes from SPEC → next-investigator seals → next-pm marks), prioritising gaps 1–5 (the poll/read surface a merchant needs), then decide the 2 regressions. Per `docs/build-workflow.md`. The client doc + diff already specify the target shapes.
