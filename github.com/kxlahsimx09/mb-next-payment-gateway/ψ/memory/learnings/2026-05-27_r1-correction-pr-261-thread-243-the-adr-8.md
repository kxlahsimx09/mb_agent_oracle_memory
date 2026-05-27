---
title: R1 correction (PR #261, thread #243) — the §ADR-8 A2 9th fair-router filter is f
tags: [next-product-writer, repo:mb-next-payment-gateway, next, bot-gateway-dispatch, withdrawal-lane, faithfulness, decision, drift]
created: 2026-05-27
source: docs/requirements/epic-bot-dispatch.md + epic-source-flows.md @7b35989 (PR #261); thread #243 + #246; gist 0056dc17
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# R1 correction (PR #261, thread #243) — the §ADR-8 A2 9th fair-router filter is f

R1 correction (PR #261, thread #243) — the §ADR-8 A2 9th fair-router filter is fair-router-routed-only (payout in practice), NOT all withdrawal source_types.

My first R1 edit imported the ratified §ADR-8 §Amendment AF1 prose ("the filter applies to all withdrawal source_types — payout/settlement/direct_transfer/pullout") verbatim into a fair-router context in BOT-001, over-generalizing it. The user caught it. Production (gist 0056dc17 @2087fed) + §ADR-8's own Mode model show it is effectively payout-only:

- §ADR-8 Mode split: Mode-1 pool-broadcast = payout/settlement (fair-router-routed); Mode-2 direct-address = pullout/DT (source names the bank; router no-ops on `required_bank_account_id IS NOT NULL`). So the fair-router never routes pullout/DT → its 9th filter can't evaluate them.
- Production: pullout `PullOutTaskController.go:1132` + DT `DirectTransferController.go:523` pre-assign `SystemBankID` → bypass `findBestBankForItem`; payout+settlement enter `withdrawal_dispatcher.go:521-530`; only 5/56 banks set `withdrawal_max_amount`, all method=payout cap 50000; settlement banks cap=0 (no-op). → effectively a payout gate.

Fixes landed in PR #261 commit 7b35989: (1) BOT-001 edge case scoped the 9th filter to fair-router-routed work (payout), noting pullout/DT bypass + settlement no-op; (2) PULLOUT-002 un-conflated pullout's OWN min/max band (pullout_tasks.min_amount/max_amount, dispatcher-side on the pre-assigned destination) from the fair-router 9th filter — pullout bypasses the router, so A2 does not govern it; two distinct mechanisms.

ESCALATED to next-architect (thread #246): the ratified AF1 "all source_types" prose contradicts §ADR-8's Mode-2 bypass → needs an §ADR-8 prose reconciliation; plus a money-control gap the gist surfaced — 21,886 pullout/settlement/DT txns exceed 50k with NO per-transaction cap (only payout banks cap; pullout/DT bypass the router). Whether to enforce a per-bank/per-txn band on the directly-addressed flows is a money-safety + ratified-ADR ruling, not a writer edit.

Durable lesson: when propagating a ratified §Amendment into a requirement, do NOT lift its prose verbatim if the prose's scope is looser than the mechanism the story describes. AF1 said "attribute of the bank account, applies to all source_types" — true of the band's storage, false of where the fair-router evaluates it. A filter named after a mechanism (fair-router) is scoped by that mechanism's reach (substitutable Mode-1 work), regardless of how the ADR prose generalizes. Companion to [[feedback_writer_fix_contradicts_ratified_adr]].

---
*Added via Oracle Learn*
