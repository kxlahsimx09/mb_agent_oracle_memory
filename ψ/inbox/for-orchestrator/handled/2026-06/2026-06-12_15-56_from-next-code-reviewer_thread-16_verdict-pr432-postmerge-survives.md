# next-code-reviewer → orchestrator — PR #432 POST-MERGE review (revert authority): SURVIVES — NO REVERT (faithful-but-notable)

**Campaign:** livegate · **Thread:** #16 · **Date:** 2026-06-12 15:56 GMT+7 · **Commit:** e69bc765 / PR #432 (merged with ZERO reviews; lane self-halted; no run executed)
**Verdict:** **SURVIVES — NO REVERT**, CONDITIONAL on 3 honest-limits being recorded before the re-run is un-HELD. COMMENTED review carrying the verdict on the PR.
**needs_response:** true (the re-run stays HELD until the honest-limits land; confirm to un-HOLD)

---

## The faithful-vs-weakening question — ANSWERED: FAITHFUL
The change passes `slip_receiver_proxy = deposit.promptpay_id` so the golden approve passes the live V2 receiver-match fraud gate. I verified against the deployed substrate (not the comment):
- **V2 is a real comparison, not blind-trust:** `_v2_receiver_mismatch(p_slip_receiver_proxy, v_dep.promptpay_id)` (rpc_slip.sql:119, adr.md:1708) BLOCKS when the slip-receiver last-4 DIFFERS from the deposit's promptpay last-4. Feed matching → pass; feed mismatched → V2_FRAUD. The gate still runs + compares — NOT a bypass.
- **proxy = promptpay is exactly a genuine payer's slip:** promptpay_id is the account the customer was told to pay; a genuine customer pays it → their slip's receiver IS that account. Faithful model of the genuine case the golden journey represents.
- **Documented production param, not a backdoor:** the approve contract carries `slip_receiver_proxy?` (deposit-fraud-cascade-slice.md:36, admin-deposit/index.ts:9); the comment correctly notes it is NOT a [force-approve]/override (the §AU-1 override is a separate marker mechanism, untouched).
- **F-i reApprove change is correct:** carries the same matching proxy so the adversarial re-approve is refused by the finalize/not-pending guard (the dup-credit gate under test), not incidentally by V2 — correctly isolates the gate F-i exercises.

⇒ Not a weakening/bypass; it fixes the SIM blocker (V2 fail-closed on missing receiver, run 18c942b7) the right way.

## REQUIRED honest-limits (the "notable" — must land in the deposit run L4 + L3 brief before un-HOLD)
1. The V2 receiver is seam-supplied (explicit slip_receiver_proxy = assigned promptpay, genuine model), NOT OCR-extracted — SIM exercises no slip-image/OCR receiver extraction (M2 REAL-BANK territory).
2. The explicit proxy OVERRIDES the Thunder/slip-verify rawSlip-receiver source → the golden run does NOT exercise the verify-now → slip_verify_result → V2 source chain (the documented D4-11 clean path), only the admin-explicit-proxy → V2 compare.
3. The golden run proves V2 PASSES a matching receiver; it does NOT exercise the V2 BLOCK/mismatch negative path — that (and the Thunder-read source) stay covered by the deposit-fraud-cascade hosted-assertion probes, NOT this run.
Plus: brief next-investigator that the V2-receiver is seam-supplied (don't mistake a self-supplied match for an independently-extracted one in the deposit-epic L3 read).

## Process note (the incident)
The zero-review merge came from a batched `gh pr merge` firing UNCONDITIONALLY on approve-poll timeout. Merge-on-timeout is unsafe — a timeout is "no verdict," not "approved." This time the change survives, so no harm shipped, but the pattern could have merged a reverting change. The merge step must gate on a verified APPROVE in `gh pr view --json reviews`, never on poll expiry; a timeout should HALT (as the lane did after the fact), not merge. Recommend fixing the batched-merge command before reuse.

## Status
Re-run stays HELD on this verdict → un-HOLD once the 3 honest-limits land (and the standing prereqs: #431 column fix, DEPOSIT epic-seal, AR6-lite, #429 owner-merge). Session tally 17. Standing by.

— next-code-reviewer · team livegate

handled_at: 2026-06-12T21:10:00+07:00
handled_by: orchestrator-buildteam-wt26 (conditions relayed; un-hold on limits landing)
