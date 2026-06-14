# Handoff — Payout lane (KTB transfer + SCB approver): bring it LIVE (parts B + C)

**Filed:** 2026-06-14 ~18:30 +07:00 by brew-ops (thread #19 follow-on).
**Why:** the deposit + OTP-login lane is LIVE & proven; the owner wants the **payout** lane too ("เดี๋ยวเวลาใช้จริง ต้องเอามาใช้ ขา payout ด้วย"). Part **A** (SCB mock dual-mode) is DONE by brew-ops. **B** (bot runtime) + **C** (gateway queue confirm) remain — this is the handoff for them.

---

## Cross-repo audit verdict (#current `kokarat/bank-bot` @5cb612f vs #next `kxlahsimx09/mb-next-bank-bot` @fbbe493, 2026-06-14)

Both bots drive the SAME real bank portals, so #current is the behavioural ground truth. **Result: the bank-portal contract is 100% identical — ZERO drift.** Every portal-facing file is **byte-identical** (checksum-verified): SCB `{login,statement,dashboard,maker,checker,approver,selectors}.js`, KTB `{login,statement,dashboard,transfer,selectors}.js`, `banks/{base,index}.js`, `core/browser.js`, `core/otp_api.js`, `core/otp_email.js`. Portal file-set matches exactly (no missing/extra). → **the SIM mock (built to #next selectors) is therefore faithful to #current behaviour too**, and the #next scrapers will behave identically to #current against a real bank.

**All drift is confined to the gateway/runtime layer (the allowed exception):**
- `core/api.js` (326 lines) — the gateway interface (mobiz Go → Supabase EFs). Expected.
- `core/secrets.js`, `core/maintenance.js` (#next-only) — bot-side cred loading from the fleet-secret slot + maintenance-window check. Non-portal, gateway-adjacent.
- `app.js` (2568 lines) — #next is **statements-only** (`login`/`ensureLoggedIn`/`scrapeStatement`/`setApi`); #current runs the **full payout lane**. This is NOT portal drift — it is exactly the "payout runtime not deployed in #next" gap this handoff addresses (see B2's DE-RISK note: #current `app.js` is the port-ready reference).

No action needed on the portal contract. The only "drift" is the missing payout runtime (B) + the gateway interface (C), both already scoped below.

---

## What is already DONE (do not rebuild)

1. **Gateway OTP relay — LIVE + provisioned on staging `sinuw` (`sinuwgsqqyqzlpaavimf`).** `bot-otp` (read) + `bot-otp-log` (producer write) + `otp_logs`; `OTP_PRODUCER_ENC_KEY`+`OTP_PRODUCER_ENV=sim` set as EF secrets; SIM producer cred minted (`mint_otp_producer_credential(env='sim')`, **fleet-wide — one cred serves BOTH banks**, in slot `staging-otp-sim-producer.env`). Bank-agnostic: `bank_code='scb'` and `'ktb'` both resolve. **Reuse as-is for payout — no gateway OTP change.**
2. **`core/api.js getOTP` — real, bank-agnostic.** Both `batchTransferFlow` (KTB) and `approverFlow` (SCB) already take/poll `getOTP`. Proven end-to-end for KTB login OTP (otp_logs ref `F6785` → bot read → dashboard).
3. **SCB mock DUAL-MODE — part A, PR #13** (`kxlahsimx09/mb-next-bank-bot`, `feat/scb-mock-dual-mode`). One portal serves BOTH deposit (viewer statements) AND payout (approver todo + approve-OTP). `SIM_OTP_ENABLED=true` now ADDS the payout lane instead of replacing statements. 18/18 mock-portal tests green incl. `tests/mock-portal-scb-dual.test.js`.
4. **deploy.yml whole-dir portal tar — PR #11** (so portal deploys ship all module deps).
5. **Gateway payout-queue EFs EXIST + DEPLOYED on staging** (the 10 net-new in the 2026-06-14 wf7 deploy): `bot-fetch-processing`, `bot-claim`, `bot-queue-mark`, `bot-transfer-proof`, `bot-tx-checkpoint`. (Plus `bot-balance`.) So **C is largely built** — see C below for the remaining confirm.

---

## The core finding (why this is bigger than the OTP login was)

`app.js` is the **"Phase-1 statements-only runtime"** — the only thing deployed on the live SCB+KTB Fargate bots. It does NOT drive payouts. The payout flows exist in code but **no deployed runner invokes them**:
- KTB: `banks/ktb/transfer.js` `batchTransferFlow(page, items, getOTP)` — single-role **batch transfer** (1-5 recipients, submit once, **1 OTP at submit**). `getSupportedFlows() → ['transfer']`.
- SCB: `banks/scb/{maker,checker,approver}.js` — **dual-control** (maker submits → checker → approver approves WITH OTP at the approve step). `supportedRoles() → ['maker','approver','checker']`.

And `core/api.js` `PHASE2_STUBS` shows the bot's payout-queue client methods (`claimItems`, `fetchProcessingItems`) are **stubs that throw** — even though the gateway EFs they'd call are deployed.

**So "KTB/SCB can do payout" = NOT yet.** The OTP relay (the hard, payment-auth part) is the only piece that's ready; it's reused. The rest is the bot runtime + client + the KTB mock transfer UI.

---

## B — Bot-side runtime (owner: bank-bot dev)

**B1. Graduate the Phase-2 stub client methods in `core/api.js`** (like `getOTP` was): implement `fetchProcessingItems(systemBankId)`, `claimItems(...)`, plus `queue-mark` / `transfer-proof` / `tx-checkpoint` calls against the deployed EFs (`bot-fetch-processing`, `bot-claim`, `bot-queue-mark`, `bot-transfer-proof`, `bot-tx-checkpoint`). Same `X-Bot-Key`/`X-Bot-Signature` auth as the other bot EFs. Confirm each EF's request/response contract first (C).

**B2. A payout RUNTIME entry** (e.g. `payout-app.js`, sibling to `app.js`) that loops:
fetch processing batch (`bot-fetch-processing`) → claim (`bot-claim`) → drive the bank flow → submit proof (`bot-transfer-proof`) → mark queue (`bot-queue-mark`) / checkpoint (`bot-tx-checkpoint`). Per bank:
- **KTB:** `batchTransferFlow(page, items, getOTP)` — one OTP at submit (rides the relay).
- **SCB:** `makerFlow`/`checkerFlow`/`approverFlow` — `approverFlow` matches the gateway processing batch (`batchItems`) against the bank todo (`apiTasks` via `/landing/inquiry`), approves matched with OTP. ⚠ `approverFlow` cross-checks `otpConfig.api.fetchProcessingItems(systemBankId)` — needs B1 + `systemBankId` wired (the #12 fidelity test skips it by passing no `systemBankId`; the live runtime must pass it).

  **🔑 DE-RISK (cross-repo audit 2026-06-14): `#current` `kokarat/bank-bot` `app.js` IS the reference payout runtime — do NOT write B2 from scratch, PORT it.** The audit proved `banks/**` + `core/browser.js` + `core/otp_api.js`/`core/otp_email.js` are **byte-identical** between #current and #next (same selectors, same login/statement/transfer/maker/checker/approver flows). #current's `app.js` already orchestrates the FULL payout lane against that identical `banks/` — it calls `bankModule.{isDualControl, getSupportedFlows, supportsBatchTransfer, makerFlow, checkerFlow, approverFlow, batchTransferFlow, transferFlow, getAccountSummary, checkApiHealth, keepSessionAlive, logout}`. #next `app.js` was stripped to statements-only (`login`/`ensureLoggedIn`/`scrapeStatement`/`setApi`) — that strip IS the gap. So B2 = lift #current `app.js`'s payout orchestration and swap ONLY the gateway calls (the mobiz-Go → Supabase-EF surface, i.e. the `core/api.js` methods B1 graduates). The bank-portal half ports 1:1.

**B3. KTB mock transfer UI** — `sim/mock-portal/ktb-server.js` currently models login + dashboard + statements + **login-OTP only**. It has **no transfer/payout page**. Add the transfer flow per `banks/ktb/selectors.js` `TRANSFER` (โอนเงิน → `.plus-icon` add recipients → ถัดไป → ยืนยัน → **OTP form** → ยืนยัน), and on submit have the mock (as SIM OTPService) `postOtpLog` the transfer-OTP (reuse `otp-service.js`, `bank_code='ktb'`). This is the KTB analog of part A. (SCB dual-mode mock is already done, PR #13.)

**B4. Deploy + verify e2e** (brew-ops can run the deploy once B1-B3 land):
- SCB: redeploy the SCB portal EC2 (`i-0d96a92a6035b46f1`) with PR #13 + `SIM_OTP_ENABLED=true` + `API_URL`/`OTP_PRODUCER_*` env (the dual-mode portal keeps the viewer scraping). Stand up an SCB payout/approver Fargate task with maker+checker+approver creds. Seed a maker task (`POST /sim/approval-task`) → approver approves with OTP → `CusLanding-SucceessPopUp`.
- KTB: redeploy the KTB portal EC2 (`i-0d14cd9f357365e3b`) with the new transfer UI. Stand up a KTB transfer task (transfer/maker cred). Seed a payout batch → `batchTransferFlow` → OTP via relay → success.
- Proof (like KTB login): `otp_logs` row posted by the portal at submit/approve + read by the bot; the gateway payout queue advances to done.

**Note on credentials:** the live bots today carry only `viewer` creds (`BANK_CREDENTIALS={"viewer":[...]}`). Payout tasks need the payout-role creds (KTB `transfer`/`maker`; SCB `maker`+`checker`+`approver`) provisioned in the per-account fleet-secret slots + SM.

---

## C — Gateway payout queue (owner: architect/next-dev — payment-auth, de-bias)

The EFs are **deployed** (B's client calls them), so C is mostly **confirmation + seal**, not new build:
- Confirm/seal the request/response **contracts** of `bot-fetch-processing`, `bot-claim`, `bot-queue-mark`, `bot-transfer-proof`, `bot-tx-checkpoint` against B1's client (the withdrawal/queue lane — "epic-bot-dispatch BOT-001..004"). Verify auth (bot key), dedup/idempotency, and the state machine (processing → claimed → proof → done) on the truth DB.
- Same **de-bias** posture as the OTP relay: the payout/withdrawal-approval surface is payment-auth-sensitive → architect SPEC/ADR → next-dev → next-tester VERIFY+SEAL, not a brew-ops one-shot.
- If any EF is a partial/stub on the gateway side (deployed but not contract-complete), that's the real C build.

---

## Sequencing

1. **C-confirm** the 5 payout EF contracts (architect/next-dev) — unblocks B1.
2. **B1** client methods + **B3** KTB mock transfer UI (bank-bot dev) — parallel.
3. **B2** payout runtime (bank-bot dev).
4. **B4** deploy + e2e (brew-ops) — gated on B1-B3 + payout-role creds provisioned.

Reuse throughout: the **fleet-wide SIM OTP producer cred** (already minted) + `getOTP` (already real) + SCB dual-mode mock (PR #13). The OTP relay is NOT on the critical path — it's done.

## References
- bank-bot PRs: **#13** (SCB dual-mode, A — merge to unblock B4 SCB), **#11** (deploy.yml fileset), #10 (KTB OTP login), #12 (SCB approve-OTP mock, superseded by #13's dual-mode).
- gateway: payout EFs under `supabase/functions/bot-{fetch-processing,claim,queue-mark,transfer-proof,tx-checkpoint}/`; OTP relay `bot-otp`/`bot-otp-log` + migration `bbot010_otp_relay`.
- bot: `core/api.js` (`PHASE2_STUBS`), `banks/ktb/transfer.js`, `banks/scb/{maker,checker,approver}.js`, `sim/mock-portal/{server,pages,ktb-server,otp-service}.js`.
- prior handoffs: `2026-06-14_15-59_bbot-thread19-otp-relay-campaign-close.md`; memory `ktb-mock-portal-buildspec`, `deploy-currency-initiative`.
