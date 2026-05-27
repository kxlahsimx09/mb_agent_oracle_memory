---
title: §ADR-8 §Scope-correction AF4 PROMOTED — directly-addressed-flow money-gap ratifi
tags: [system-architect, repo:mb-next-payment-gateway, next, decision, withdrawal-queue, fair-router, settlement, money-control, adr-8]
created: 2026-05-27
source: docs/adr.md §ADR-8 §Amendment 2026-05-26 §Scope-correction (AF4) @839f570; thread #246 msg 1147
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §ADR-8 §Scope-correction AF4 PROMOTED — directly-addressed-flow money-gap ratifi

§ADR-8 §Scope-correction AF4 PROMOTED — directly-addressed-flow money-gap ratified `#decision` = option (A) faithful-port (thread #246 user GO msg 1147).

Follow-up to the AF3/AF3b/AF4 ruling (learning `2026-05-27_adr-8-af3-fair-router-scope-correction-af4-money`). The user ratified AF4 = **option (A) faithful port**, promoting the `[RATIFICATION_PENDING:246]` marker → ratified `#decision` in `docs/adr.md` §ADR-8 §Amendment 2026-05-26 §Scope-correction (PR #263, commit 839f570).

**The ratified decision (A).** The per-bank withdrawal amount band (`withdrawal_min_amount`/`withdrawal_max_amount`) stays a **fair-router (Mode-1 / payout-effective) filter**. The directly-addressed flows — pullout, direct-transfer, settlement — rely on their existing controls: admin approval + DestCap + RBAC + enqueue balance/outstanding validation. This matches current production exactly. The 21,886 pullout/settlement/DT txns >50k with no per-txn cap are **admin-gated movements (funds the system already controls), not an open hole**. No per-transaction cap is added to Mode-2/settlement in Phase-1.

**Option (B) recorded as DEFERRED defense-in-depth (not adopted).** Promote the band to an all-source-types **enqueue/queue-validation-layer** bank-account invariant — closes the gap, makes AF1's literal "all source_types" true, but is a deliberate divergence from current + money-material. **Revisit trigger = DT-refund (DEPOSIT-011 / §ADR-4d) Phase-2** — that flow DEBITS a client wallet (vs the admin-gated, system-controlled funds of pullout/DT/settlement), the concrete driver that would justify the enqueue-layer invariant. DEPOSIT-011 is currently an unauthored deferred-Phase-2 stub row (`epic-deposit.md:34`), so the (B) revisit and the DEPOSIT-011 authoring share the same Phase-2 timing.

**Writer follow-up = none blocking.** AF3/AF3b already shipped faithful in next-writer PR #261 BOT-001/PULLOUT-002 (commit 7b35989); (A) = current behavior, no new constraint to document. Optional non-blocking: a one-line cross-reference on the existing DEPOSIT-011 deferred-Phase-2 row (`epic-deposit.md:34`) pointing at §ADR-8 AF4 (B) so the deferred safeguard is not silently lost when the refund flow is eventually authored.

**Process.** Clean marker-flip promotion (the §ADR-12 SC1-4 + §ADR-4c A4 precedent) — no new decision surface, original `[RATIFICATION_PENDING:246]` prose + two-readings recommendation preserved inline per P-001. The money-material call was correctly user-ratified (charter §9), not architect-self-bound. Architect makes PR #263 ready; user merges (§9).

---
*Added via Oracle Learn*
