---
title: §ADR-10 §Amendment 2026-05-31 (campaign ng2arch ITEM D, PR #295, NOT merged — pe
tags: [adr-10, mdr, residual-routing, is_owner-wallet, mdr_skip, money-decision, amendment, ratification-pending, ng2arch, topup]
created: 2026-05-31
source: next-architect (ng2arch follow-on ITEM D)
---

# §ADR-10 §Amendment 2026-05-31 (campaign ng2arch ITEM D, PR #295, NOT merged — pe

§ADR-10 §Amendment 2026-05-31 (campaign ng2arch ITEM D, PR #295, NOT merged — pending user GO, MONEY) — Residual-MDR Routing — the §ADR-16/§ADR-10-D4 deferred follow-up. §ADR-16 §Scope-boundary parked "residual-fee-routing drift fix (queued separately in §ADR-10 follow-up)"; §ADR-16 D5 deferred missing-wallet/abort here. §ADR-10 D4 closed the AUDIT half of mobiz thread #6 (no silent drop — every MDR-profile partner gets one `credit`/`mdr_skip` row) but NOT the MONEY half: when a partner share can't be credited (partner inactive / wallet missing), the fee was already deducted from client gross, so the un-creditable share is a real amount that must land somewhere.

RATIFIED class (a) within authority: RM1 — ledger-balance + per-share audit invariant: `gross = client-net-credit + Σ(credited partner shares) + Σ(un-routable shares)`; an un-routable share is NEVER silently dropped and never left to unbalance the books.

FLAGGED class (b) [RATIFICATION_PENDING:ng2arch-d] (MONEY): RM2 — destination of an un-routable share: (R1) credit the `is_owner` system-residual wallet [architect lean — uses the ratified §ADR-10 D1 "residual MDR holder, exactly one"; ledger balances; cleanest audit; mdr_skip row cross-refs the residual credit] / (R2) mdr_skip-and-hold suspense / (R3) reassign to active partners. NOT architect-self-bound.

Applies wherever inflow-MDR fans out: §ADR-4b D5 finalize_deposit + §ADR-16 D5 apply_client_topup. Story TOPUP-002 gained the residual AC (pending RM2); same §ADR-10 rule governs deposit lane (WALLET-003/DEPOSIT-002). Pattern: D4 closed the audit half of a silent-skip drift; the money half is a separate, money-material follow-up that needs the residual destination ratified. Repo: kxlahsimx09/mb-next-payment-gateway.

---
*Added via Oracle Learn*
