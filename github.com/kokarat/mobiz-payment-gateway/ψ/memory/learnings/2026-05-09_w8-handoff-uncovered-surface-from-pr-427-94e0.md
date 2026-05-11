---
title: W8 handoff — uncovered surface from PR #427 (`94e0c1a`, 2026-05-08): the new ext
tags: [technical-writer, repo:mobiz-payment-gateway, current, w8-handoff, uncovered-surface, flow:telegram-wallet-high-balance-alert, telegram, wallet-alert]
created: 2026-05-09
source: controllers/WalletAlertController.go@94e0c1a + routes/telegram.go@94e0c1a + services/telegramNotify.go@94e0c1a
project: github.com/kokarat/mobiz-payment-gateway
---

# W8 handoff — uncovered surface from PR #427 (`94e0c1a`, 2026-05-08): the new ext

W8 handoff — uncovered surface from PR #427 (`94e0c1a`, 2026-05-08): the new external-cron-driven Telegram wallet-alert endpoint `POST /api/v1/telegram/wallet-alert/high-balance` (controllers/WalletAlertController.go + routes/telegram.go + services/telegramNotify.go SendHighBalanceAlert). No existing flow doc in `docs/flows/` covers this surface — W9 would normally classify this as Class D (undocumented step inside an existing flow's territory), but per Step 4 §rules this is a brand-new actor-crossing with no covering flow, so it is **not** D — it is uncovered-surface and goes to W8 authoring queue instead. Proposed flow slug: `telegram-wallet-high-balance-alert`. Actors: External cron (driver) → API gateway (BotAuthMiddleware) → WalletAlertController → MongoDB read-replica (wallets + clients) → Redis (idempotency hash + sent-time) → Telegram Bot API → Wallet Alert Channel ("แจ้งเตือน Wallet" room). Notable behaviour worth a flow: idempotency via SHA-1 hash of `(client_name, balance/50k bucket)` with 23-hour resend window; Redis fail-open posture; single-message rate-limit-safe shape; channel-pre-provisioning requirement; threshold env (default 200k THB). Sister flow surface candidates that could share authoring scope: the existing telegram report endpoints (`POST /api/v1/telegram/report/{hourly,daily}`) follow a similar external-cron-driven actor model and are also uncovered. Recommend authoring `telegram-wallet-high-balance-alert.md` first (smaller, self-contained); the report endpoints can be a separate authoring pass or a multi-flow batch when convenient. Documented in current-system.md §3.1 + §6.7 + §8.4 by W2 PR #428 (2026-05-09); the W8 author can pull design context from those rows + the PR #427 commit body.

---
*Added via Oracle Learn*
