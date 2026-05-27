---
title: W1 gap-analysis — next-product-writer source sweep found the next requirement ad
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, gap-analysis, workflow-1, source-flow, auth-rbac, fleet-control, monitoring, settlement, pullout, direct-transfer]
created: 2026-05-25
source: W1 gap-analysis session 2026-05-25 Asia/Bangkok, no file edits
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 gap-analysis — next-product-writer source sweep found the next requirement ad

W1 gap-analysis — next-product-writer source sweep found the next requirement additions should prioritize missing ratified surfaces, not new invention.

Current docs/requirements coverage: Deposit, Payout, Client Self-Topup, Bot Dispatch, Statement Matching, Wallet & Ledger are authored; README still marks Settlement, Pullout, Direct Transfer, Auth & RBAC, and OTP & Trust as planned.

Highest-confidence W1 additions:
- Source-flow trio from §ADR-12: Settlement, Pullout, Direct Transfer. ADR-12 is ratified and production Mongo has non-trivial current evidence: settlements 2,877 rows, direct_transfers 589 rows, pullout_tasks 155 rows. These should become new epics or one source-flow epic split by flow.
- Auth & RBAC from §ADR-2 + §ADR-13 + poc/2: login/2FA, tenant scope, role permission model, IP allowlist, login audit. Current Mongo evidence includes users 685, login_logs 36,832, otp_logs 39,568, roles 7.
- Fleet-control from §ADR-14: maintenance override, force-refresh-config, reboot session, halt-pool, fleet_command_log audit. This is operator-facing and ratified but currently only noted in cross-repo.md, not authored as requirements.
- Monitoring/Alerting from §ADR-15: Telegram alert routing, request_id traceability, alert catalog/runbook workflow. Ratified but absent as requirement epic.

Do not revive PAYOUT-006 as payout rejected: earlier retro flagged rejected terminal as a gap, but §ADR-9 thread #120 withdrew payout rejected; failed is the sole unsuccessful payout terminal. At most add an INDEX deferred/withdrawn note for discoverability, not a story.

Where additions should land:
- docs/requirements/README.md epic index rows should link to new epics.
- docs/requirements/INDEX.md should gain story ids under new sections.
- docs/requirements/cross-repo.md should gain boundary rows for settlement/pullout/direct-transfer once authored because they use withdrawal_queue/bankbot execution.
- docs/requirements/glossary.md needs first-class entries for settlement, pullout, direct transfer, auth/RBAC, OTP/trust, fleet-control, and monitoring terms as those epics land.

---
*Added via Oracle Learn*
