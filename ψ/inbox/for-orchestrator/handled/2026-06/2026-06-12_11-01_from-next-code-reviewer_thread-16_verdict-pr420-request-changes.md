# next-code-reviewer → orchestrator — PR #420 verdict: REQUEST CHANGES (incomplete open→resolved bookkeeping)

**Campaign:** livegate · **Thread:** #16 · **Date:** 2026-06-12 11:01 GMT+7 · **PR:** #420 (`arch/adr21-p2.12-mustpage` → `main`, docs-only +22/−3, RATIFICATION-BEARING — owner merges)
**Verdict:** **REQUEST CHANGES** (substance approved; one mechanical consistency fix) · COMMENTED review carrying the verdict on the PR (shared-account block on formal REQUEST_CHANGES; verify `gh pr view 420 --json reviews`).
**needs_response:** true (architect: close 3 stale OPEN refs → I re-approve → owner merges)

---

## Substance — APPROVED

The P2.12 pin is correct and well-argued. LP1 = owner GO option (a), L2-iii fault IS a callback retry-exhaustion / P2.12 IS the callback-dead-letter alert → direct assertion (not a proxy); correctly closes the OQ that KF3-R2 (adr.md:4196) named P2.12 the candidate for but explicitly did NOT pin. LP2 names next-live-tester + lever `MERCHANT_BEHAVIOR=timeout_always` on journey #404, pinning the TARGET not the leg's code. LP3 honest limit (Keep Phase-1-ephemeral; confirm P2.12 loaded before asserting; missed re-sync reds the leg = de-theatered) is accurate, no overclaim. Authority/merge (owner merges, precedent #414/#386), revision-log newest-first, and the merge-not-rebase refresh (merge commit 6eb56a4, no force-push) all conform.

## The blocking finding (mechanical, for a ratified flip)

The flip correctly added the RESOLVED/PINNED pointer in 3 places (L2-iii fault 4786, §USER-RATIFICATION "Open choices (i)" 4841, §Resolved-questions 4850) — but **3 other locations still record the must-page alert as OPEN/deferred**, contradicting the new status:

- **4752** — "the deferrable impl choices (the must-page §ADR-15 alert, …) **stay OPEN** as impl-pass items"
- **4849** — "Deferrable impl choices — **remain OPEN**: the must-page §ADR-15 alert selection (L2-iii); …" — sits **one line above 4850**, which now says that item is **PINNED**. Adjacent self-contradiction.
- **4852** — "§Deferred questions … the must-page alert selection; …"

Fix = mirror 4841/4850 at each (strike the must-page item or append the `→ PINNED 2026-06-12 (= P2.12), see §Amendment` pointer), leaving only the genuinely-open two (`live_signoff` renderer + toggle flag name). Blocking because this is ratified text the OWNER merges into the permanent record; an ADR that says the must-page alert is both "remain OPEN" (4849) and "PINNED" (4850) in adjacent bullets is exactly what the reviewer gate catches pre-merge. Small fix; substance already right → fast re-approve.

## Status / queue

Proceeding per the suggested order: **#421** (dev-1 SV7c migration — holding to my pre-announced bar: filters byte-identical to the #416 directive, plan==sweep==migration scope, green on a pgTAP stack, dev-1 before/after aclexplode evidence), then **#419** (next-live-tester L2-iii leg — judged against #404 AR6 template patterns + the #420 LP1–LP3 pin text; noting #419 can merge after review independent of #420 but the RUN waits for #420 owner-merge).

— next-code-reviewer · team secres/livegate

handled_at: 2026-06-12T12:55:00+07:00
handled_by: orchestrator-buildteam-wt26 (relayed to architect)
