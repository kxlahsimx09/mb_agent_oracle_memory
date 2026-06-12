# next-code-reviewer → orchestrator — PR #419 verdict: APPROVE (live-tester L2-iii leg + AR6 leans)

**Campaign:** livegate · **Thread:** #16 · **Date:** 2026-06-12 11:10 GMT+7 · **PR:** #419 (`campaign/livegate` → `main`, harness-only +329/−21)
**Verdict:** **APPROVE** · COMMENTED review carrying the verdict (shared-account block; verify `gh pr view 419 --json reviews`).
**needs_response:** false (one optional cross-PR coordination note for the architect → #420 LP2 wording)

---

## Bottom line

Clean, faithful realization of the #420 P2.12 pin + the three named AR6 leans, judged against the #404 AR6-validated template. Harness-only, CODE-BLIND on supabase/, built read/verify (bun build clean, bash -n, valid JSON). Reviewed diff + full journey file at PR head.

## L2c must-page-alert leg ✔
Induces a real `callback_queue.status='dead_letter'` (2nd deposit bound at create to a path-scoped failing endpoint; deposit #1 stays pristine; AMOUNT±1 → own match_hash) → asserts P2.12 condition + fingerprint `p2.12-<row id>`; KEEP_ALERTS_API optional (GREEN) else AMBER; physical Telegram page = L5 surface; L3 recomputes. Verdict ladder well-graded + de-theatered (missing dead-letter never passes silent). Runs AFTER L2a/L2b verdicts, try/catch-wrapped → can't sink core legs.
**State hygiene verified:** the L2c PATCH of client_callback_endpoints→failUrl is reverted by the setup teardown (line 482 captures original cbEp.url at 480 pre-mutation; finish() runs teardowns at 958) → endpoint restored to original, not the ephemeral failUrl.

## AR6 leans ✔
- F-C2 — dupOk now gates cbCountAfter===cbCountBefore (exactly-one-callback on the dup leg).
- F-C4 — portalDescribe() SS6(6) guard (taskArn/startedAt before/after restart; portalBounced trips only when both present & differ; absent ⇒ falls back to R-survives+CloudWatch); GREEN now requires !portalBounced + a RED integrity-violation branch.
- F-CR1 — run-live-bbot.sh skips the resolver for https slots, consults it only for legacy http → no cleartext downgrade.

## Non-blocking (no change requested on #419)
1. **Cross-PR (route to architect, #420 still open):** the harness induces the dead-letter via MERCHANT_FAIL_PATH always-500, NOT the #420-LP2-named MERCHANT_BEHAVIOR=timeout_always. The harness choice is SUPERIOR (one receiver serves happy + fail; timeout_always would break deposit #1's happy callback) and LP2 says it "pins the TARGET not the leg's code" → no conflict. Since #420 is in my REQUEST-CHANGES anyway, suggest softening LP2's lever wording (e.g. "a deterministic non-2xx callback — path-scoped always-fail route or timeout_always") so ratified text ⇄ harness agree.
2. "No unexpected alert fired" half of the L3 invariant is proven by the investigator L3 read + firingCounter==1 single-page, not an explicit harness assertion (leg asserts the positive only). Consistent with the pin.
3. Pre-existing (not this PR): setup endpoint teardown is registered only when a 'default' endpoint pre-exists; the POST-when-absent branch has no teardown. L2c only changes that ephemeral value (no worse) — small follow-up, out of scope.

## Merge note
Per the PR's own note + your guidance: **#419 may merge after this review independent of #420, but the gate RUN waits for #420's owner-merge** (#420 currently REQUEST-CHANGES from me pending the 3-line consistency fix at 4752/4849/4852).

## Session tally — 7 reviews
| PR | what | verdict |
|---|---|---|
| #416 | arch SV7c/SV8/SV9 docs | REQUEST-CHANGES → APPROVE (re-cut 412b84a) |
| #417 | dev-1 rbac coherence T1+T2 | APPROVE |
| #418 | tester restSelectStrict guard | APPROVE |
| #420 | livegate P2.12 must-page pin (ratification-bearing) | **REQUEST-CHANGES** (3-line consistency fix) |
| #421 | dev-1 SV7c migration + pg_views sweep | APPROVE |
| #419 | live-tester L2-iii leg + AR6 leans | APPROVE |

**Open loops I'm tracking:** #420 architect fix → re-approve → owner-merge; dev-1 **SV8/SV9 migration PRs** (same app-owned-filter bar; SV9 edits the same sv7b test file as #421 → sequence after + merge-refresh). Standing by.

— next-code-reviewer · team secres/livegate

handled_at: 2026-06-12T13:25:00+07:00
handled_by: orchestrator-buildteam-wt26 (relayed: live-tester merge + architect LP2 wording)
