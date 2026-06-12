# next-code-reviewer → orchestrator — PR #418 verdict: APPROVE (next-tester restSelectStrict 42501-guard)

**Campaign:** secres · **Thread:** #16 · **Date:** 2026-06-12 10:52 GMT+7 · **PR:** #418 (`test/sv7c-probe-42501-guard` → `main`, harness-only +67/−5)
**Verdict:** **APPROVE** (VERIFIED) · COMMENTED review carrying the verdict on the PR (shared-account block on formal APPROVE; verify `gh pr view 418 --json reviews`). Tester self-merges on this.
**needs_response:** false

---

## Bottom line

Clean, additive, behavior-preserving belt-and-suspenders. Harness-only (`poc/integration/src/probes/`, CODE-BLIND), no production surface, no sequencing vs the secres wave. Reviewed diff + full files at PR head.

## Verified

- **Consistency:** `restSelect` (http.ts:40) already reads via `svcHeaders` at the same URL; `restSelectStrict` mirrors it exactly, only surfacing non-2xx instead of swallowing to `[]`. ⇒ while `service_role` is retained (post-SV7c normal case AND today's pre-SV7c state), both probes behave byte-identically (same headers/URL, `rows[0]?.x ?? "(missing)"` unchanged on 2xx).
- **Never throws on a privilege error:** non-2xx returns an envelope; `JSON.parse` try/caught. Only un-caught surface (fetch/text network rejection) == pre-existing `restSelect` exposure, not a privilege error. Catch-less sequential smoke runner cannot be aborted by a 42501. Strictly safer than `restSelect`.
- **Loud + attributable denied path:** future service_role strip → `DENIED 42501: permission denied for view …` in the assertion detail instead of misleading `(missing)`.
- **No ordering dependency:** reads via service_role, which SV7c retains → works before and after the SV7c revoke. Matches the "no sequencing" note.
- **Import hygiene exact:** `svcHeaders` still used in both files (direct fetches) → kept correctly; `restSelect` dropped from success-payout-audit (only use replaced) and kept in payout-view-contract (still used for `withdrawal_queue` L101). No dead imports.

## Minor (non-blocking, no change requested)
`restSelectStrict` flags `denied:true` for any non-2xx (404/400 too), not only 42501 — arguably better (surfaces all read failures), and the pin-comment says "e.g. a 42501" so not misrepresented.

## Status / queue

All four reviews this session complete:
| PR | what | verdict |
|---|---|---|
| #416 | arch SV7c/SV8/SV9 docs+directives | REQUEST-CHANGES → **APPROVE** (re-cut 412b84a) |
| #417 | dev-1 rbac coherence T1+T2 | **APPROVE** |
| #418 | tester restSelectStrict guard | **APPROVE** |

Standing by for the next campaign PRs — notably the **separate dev-1 migration/pgTAP PRs** (`20260612000010/20/30` + `sv7b_…`/`sv8_…` tests) that land off main AFTER docs-only #416 merges: I'll verify each carries the byte-identical app-owned filters the #416 directives now specify (plan() ≡ sweep ≡ migration scope) and runs green on a pgTAP stack before approving. Also watching for the live-tester L2-iii/AR6 harness + next-tester service_role probe adaptation.

— next-code-reviewer · team secres

handled_at: 2026-06-12T12:15:00+07:00
handled_by: orchestrator-buildteam-wt26 (relayed to tester for verified self-merge)
