---
title: W1 §ADR-4b deposit auto-match lane — pass 1 baseline (#provisional, [RATIFICATIO
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4, adr-4b, deposit, auto-match, matcher, atomic-finalize, wallet, mdr, callback, drift-q4a, multi-candidate-safety, provisional, pass-1, baseline, ratification-pending, thread-52, input-1-sufficient, scope-discipline]
created: 2026-04-27
source: docs/adr.md@98984d3 §ADR-4b + thread:#52 opening message + Oracle learnings cited inline
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 §ADR-4b deposit auto-match lane — pass 1 baseline (#provisional, [RATIFICATIO

W1 §ADR-4b deposit auto-match lane — pass 1 baseline (#provisional, [RATIFICATION_PENDING:52]).

Deep dive of the `match-deposits` Edge Function bullet under §ADR-4 ("Decoupled Processing"), scoped to the auto-match lane only. Sibling of §ADR-4a withdrawal lane — both children of §ADR-4. Sibling flow `deposit-slip-upload-admin-approve` (manual admin path, mutually exclusive on any single deposit) out of scope; sibling `deposit-auto-expire-pending` (TTL terminal) deferred to §ADR-4c future.

Grounded in Input 1 only (Oracle learnings) — no Input 5 code reads needed this pass. Current-system writers (`pg-writer` + `bot-writer`) had already published the load-bearing facts via mobiz thread #17 ratification (2026-04-19). W1 input-priority order working as designed: cheap source first, escalate only when insufficient.

Critical drift the next-system designs around — mobiz Q4a:
`services/transactionMatcher.go:592-701@37dfb26 finalizeDeposit` does not abort when client wallet update fails. Deposit can reach `status=paid` with uncredited client wallet but distributed partner MDR. Classified bug in current system (PR pending). Next-system closes the class **structurally at the engine level** via thin PL/pgSQL transaction — `finalize_deposit` RPC commits the full bundle (deposit-paid + client-wallet-credit + partner-MDR-fanout + audit-log + transactions + mdr-shared + callback-enqueue) as all-or-nothing. Aligns with ADR-3 (atomic-wallet-ops boundary).

7 numbered decisions in §ADR-4b:
1. Statement intake = `submit-statements` EF (§ADR-4 step 1 carry-over)
2. Match engine = `match-deposits` EF — KTB regex `NNN-NNNNNNN` for full account; SCB last4 + source-bank-code via `resolveBankCodeFromPrefix` allowlist
3. Multi-candidate review parking — Q4c safety carry-over; `match_status='review_required'` + `match_candidates[]`; **never auto-pick** (intentional safety classification)
4. 30s retry → pg_cron 1-min sweep, 1-hour look-back — Q4b carry-over
5. Atomic finalize = `finalize_deposit` RPC — single Postgres transaction; closes Q4a drift unconditionally
6. Admin manual re-match endpoint preserved — Q4b recovery path for >1-hour-old statements
7. Unsupported-bank allowlist preserved — Q4d carry-over (parser-support coupling intentional)

5 sub-questions deferred to thread #52 ratification:
- Q1 atomic-finalize boundary (architect-rec: full atomicity)
- Q2 multi-candidate safety (architect-rec: preserve as-is)
- Q3 retry cadence (architect-rec: 1-min acceptable)
- Q4 auto-expire scope split (architect-rec: separate §ADR-4c future)
- Q5 admin endpoint preservation (architect-rec: yes preserve)

Section is ~63 lines, under ~150-line extract threshold. No `docs/design/deposit-lane/` folder this pass. If pass-2 grows section, extract per §ADR-4a pass-6 / §ADR-8 pass-4 ADR-vs-design-doc convention.

Pass-1 scope discipline applied — resisted creep into wallet-table schema, admin-API auth, bot scraper internals (all named as deferred questions, none drafted). Same pattern as §ADR-4a pass-1 + §ADR-8 pass-1.

Threads opened: #52 (5-sub-question ratification, financial-code-adjacent, not security-sensitive). Threads closed: none. Commit: 98984d3 on PR #3.

Pattern reinforced — substrate reuse from §ADR-4a:
The withdrawal lane established the substrate (Edge Function + thin PL/pgSQL atomic boundary + pg_cron sweep). Deposit lane reuses the same substrate with different specifics (matcher logic vs claim logic; bank-statement-driven vs item-driven; sweep on unmatched statements vs sweep on stuck-claimed items). Both lanes converge architecturally — clean evidence that ADR-3/4 substrate is general-purpose, not withdrawal-specific.

Next pass candidate: ratify thread #52 → resolution pass; or §ADR-4c (deposit-auto-expire) when capacity available; or wallet-table schema pass (data-model — cuts across both withdrawal and deposit lanes).

---
*Added via Oracle Learn*
