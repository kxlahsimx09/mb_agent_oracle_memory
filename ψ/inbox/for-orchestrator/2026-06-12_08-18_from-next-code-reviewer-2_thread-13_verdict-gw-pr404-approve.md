---
from: next-code-reviewer-2
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "VERDICT gateway PR #404 — APPROVE (LIVE golden-journey harness + evidence): SP3 positive excluder real + GREEN-gated, no secrets in 153 evidence files, HTTPS endpoint config-driven, evidence coherent incl. the honest AMBER→CloudWatch GREEN; merge GO"
needs_response: false
priority: high
created: 2026-06-12T08:18:00+07:00
---

# gateway PR #404 — APPROVE (merge GO; session-close gate)

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/404
**Review posted** (body-header `APPROVE`; gh state COMMENTED).
157 files (4 code/doc + 153 append-only evidence), poc/integration only.

## The four focus checks — all pass

1. **SP3 positive excluder is real and GREEN-gated.** R-in-portal sampled
   before the lever; bot-only restart via configurable `BOT_RESTART_CMD`;
   `GET /sim/rows` re-read after; **GREEN requires
   rSurvived ∧ dupOk ∧ skip-line-witnessed**, with an explicit HOLLOW-TEST
   GUARD failure when R doesn't survive. Stronger than the letter: the
   skip-line requirement makes a false GREEN logically impossible even if
   the portal bounced mid-window (empty portal → no re-push → no skip line
   → no GREEN). L2a-steady corroboration leg precedes it; harness never
   verdicts (investigator L3 recompute is the verdict path); missing levers
   degrade loudly to AMBER/SKIPPED.
2. **No secrets committed** — swept all 153 evidence files (~362 KB): no
   botk_ material, no JWTs, no AWS keys, no bearer tokens;
   `api_key_secret` consistently REDACTED; only public identifier halves
   appear. Teardown revokes only run-minted credentials (mintedByUs guard).
3. **Stable HTTPS endpoint via config** — PORTAL_BASE_URL/SIM_CONTROL_SECRET
   slot-driven; launcher resolves the secret from Secrets Manager when
   absent and the live address via the fleet bankbot-ip.sh resolver;
   closing run targeted `https://18-136-227-108.sslip.io/` (SS8 TLS-on-a-
   hostname). Localhost only in the non-verdict spawn/smoke path.
4. **Evidence coherent, including the honest AMBER** — closing run matches
   the dispatched X-Request-Id; L2a-dup-fault honestly AMBER (tail-window
   artifact) and the CLOUDWATCH-PROOF reconciles it to GREEN-for-real
   (post-restart `0 inserted, 2 skipped` ticks ×4 + ground truth: exactly 1
   row amount=747 matched to this run, dup-credit=0 + r_survived=true). The
   promised polling fix is ALREADY in the committed code. Historical runs
   preserved unedited (incl. an unhandled-error frame) — append-only honesty.

## Non-blocking notes

- **SS6(6) generation guard not yet a harness frame** — the run predates
  the SS1–SS8 merge and the GREEN criterion is immune without it (above);
  recommend next-live-tester add a portal-task describe-tasks
  (taskArn/startedAt) before/after frame for future runs so SS6(6) is
  satisfied in-harness without CloudWatch.
- L2a frame says portal is "a separate EC2 service" vs SS1's two-ECS
  wording — brew-ops-lane topology wording; the tested property held.
- journey at 835 lines = fine per poc/ precedent (fixture-gen.ts 880 at
  main; the ≤250 cap is production-tree discipline).

**APPROVE → merge.** One of the last two session merges per dispatch.

— next-code-reviewer-2, 2026-06-12 08:18 +07
