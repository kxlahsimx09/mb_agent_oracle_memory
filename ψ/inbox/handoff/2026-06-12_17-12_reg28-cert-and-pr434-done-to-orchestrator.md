ψ ENVELOPE — TO: orchestrator (campaign reg28 parent) · FROM: next-tester · 2026-06-12

SUBJECT: reg28 NO-REGRESSION re-cert DONE + PR #434 probe-maintenance DONE (incl. F1 BS-2 rebind)

## VERDICT: NO REGRESSION at main `e69bc76` (post #423/#424/#425/#427/#428/#429/#430/#431/#432)
Ran the full established suite on **qnccph** (`investigator.env` — same stack as the morning #17 cert; `tester.env`→yupsev still ~15 migs stale). Every delta vs the morning baseline (`329051c`: pgTAP 171/171 · A6 9/0/1 · substrate 65/67) is **intentional ratified substrate evolution** (SV7c/SV8/SV9 #423/#425, CA8 #415, v_payouts_read #428, live_signoff #427) — new green coverage or a security *tightening* that made an unchanged probe's old expectation stale. No previously-passing contract broke.

**Pre-flight GREEN:** qnccph @ mig head `20260612000050` (141 migs, all 5 new present), v_payouts_read+live_signoff present, **EF ledger `--assert` 27/27 ACTIVE** (#424 list).

**Matrix**
- **pgTAP 171→353, 0 genuine regressions.** Baseline RLS files identical (rls_tenant 35/35, v_deposits 13/13); NEW all-green: sv8 121 (#423), live_signoff 17 (#427), rbac_seed/CA7 31; sv7b 48→61. `auth_phase2_a4_rls` carried 2 STALE assertions → diagnostic rebind 75/75: (a) SV6a super_admin `:view` 10→**13** (CA8 #415, seeded by mig `20260611000300` — already present at `329051c`, so the morning #17 cert OVER-COUNTED it, not a wave regression); (b) anon `is(count,0)`→hard-`42501` (SV9 #425 revoked anon SELECT). CA7 `rbac_seed_vs_catalogue` independently GREEN ⇒ seed correct.
- **A6 9/0/1** (= baseline) after restoring fixture. GOTCHA worth carrying: qnccph business tables were **EMPTY** (truncated since morning by bbot/substrate resetForTest) → A6 positive probes need a pre-seeded `CLIENT_A`=`2222…0001` `ts_deposits` fixture; I seeded 2 rows + deleted after (no residue). The 1 non-pass was `p8_sv7a` soft-zero → SV9 #425 emptied that category (no public RLS table still grants anon SELECT) — companion p8_sv7b covers the moved tables.
- **bbot substrate 65/67 → 67/67** after the F1 BS-2 rebind below (lane1 28/28; lane3 19/19 confirms #422 F2 in main).

## PR #434 — `test/reg28-probe-maintenance` (off main, reviewer+owner-gated, **OPEN, NOT merged**, head sha `a658da0`)
Test-only, 4 files, validated live on qnccph:
- **R1** `supabase/tests/auth_phase2_a4_rls_test.sql`: SV6a `10→13`; anon `is`→`throws_ok 42501`. → 75/75.
- **R2** `tests/integration/probes/auth/exposure/a6-probes.ts`: `ANON_RLS_SOFTZERO_TABLES → []` (SV9-emptied, guarded sentinel), 3 tables folded into `ANON_HARD_DENY_TABLES`. → A6 9/0/1.
- **R3** `tests/integration/probes/bbot/bk-auth.ts` + `_spec.ts`: BS-2 intake legs now assert `status===500 && error==="submit_statements_failed" && inserted!==1` (dropped 4xx-range + badStatementDate substring); cursor-int64 echo leg untouched. Per next-architect **F1 BS-2 DISPOSED option (b)** (PR #435; their envelope `2026-06-12_16-59_f1-bs2-disposition-to-next-tester.md`). → bbot 67/67.
- `docs/test-index.md` F1 disposition is carried by **#435** — intentionally NOT duplicated here.

## Open items for you / reviewer
1. PR #434 needs **next-code-reviewer** then **owner merge** (house rule: merge-not-rebase, no self-merge). I did not merge.
2. Reviewer judgement calls flagged in the PR: R1 SV6a is an "asserted VERBATIM #380" pin (confirm CA8 super_admin growth is intended — memory says ratified, Phase-1); R2 `p8_sv7a` could be formally retired vs kept as the empty-set sentinel.
3. Non-blocking robustness note: A6 positive probes are stack-state-dependent (need seeded CLIENT_A deposits) — consider making them self-seeding so the suite is stack-state-independent.

Artifacts: findings `next-tester_reg28_findings.md` (reg28 worktree root); memory `regression-cert-reg28-2026-06-12.md` (+ MEMORY.md index). Stayed entirely off sinuw / dev-N / seal slots / the in-flight livegate run / PR #433 / tunnels throughout. Nothing merged, no prod/substrate/EF code changed.
