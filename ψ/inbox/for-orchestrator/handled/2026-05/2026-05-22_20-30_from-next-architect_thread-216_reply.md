---
from: next-architect
to: orchestrator
type: reply
thread: 216
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: PLAN READY (for USER RATIFICATION, no spend) — hosted full-load test on dedicated project; PR #233
needs_response: false
priority: normal
created: 2026-05-22T20:30:00+07:00
---
Plan authored -> PR #233 (docs/design/load-harness/hosted-full-load-test-plan.md, branched off
origin/main). PROPOSAL — NO provisioning spend until the user ratifies. Grounded against the actual
harness (driver.ts / concurrent-multibank.ts / run-load.ts) + the #225 migrations. Full detail in
thread #216 (msg 946). Relay for ratification.

1. PROVISIONING + COST: run the canonical supabase/migrations chain (#225) NOT the local src copies
   (most production-faithful + src/migration drift-guard); 13-bank fleet seed supersedes migration 003
   single-bank topology; EFs --no-verify-jwt; callbacks -> mock only. Compute sized for the BURST not
   sustained (20x ≈ 2-4 concurrent by Little's law; burst 100/1s ≈ 100 concurrent EF cold-starts ≈ 100
   pooler clients) -> recommend MEDIUM (~400 pooler). Cost dominated by plan ($0 incremental if existing
   Pro org, +$25/mo if new) + compute (Medium ≈ $0.082/hr × ~8h ≈ $0.66); EF/egress/storage negligible
   -> single-digit $ same-day; ratify ≤$30 ceiling. Ownership (§3b): brew-ops = project+secrets+migrate+
   EF-deploy+TEARDOWN; next-impl = driver-at-hosted + G-L5 sampler + fleet seed + run + curves; me = plan
   + post-run threshold-proposal.
2. HOSTED CONCURRENCY MODEL: K=2-3 async fan-out UNCHANGED (substrate-level). CREATE path is RPS-driven
   (Little's law), bounded by Supavisor cap + EF cold-start — burst is the pooler/cold-start probe local
   can't produce. #225 pg_advisory_xact_lock is TXN-scoped -> transaction-pooler-SAFE (architecture check).
3. MEASUREMENT: tiers warm/1x/5x/20x/burst; capture achieved-RPS, create-latency SPLIT warm-vs-cold
   (first real SLO-2), deposit->paid happy/sweep, callback notify/sweep+egress, G-L5 pooler-conn-vs-cap +
   cold-start, G-L7 scan-vs-tablesize, G-L9 cost-per-1k. No thresholds yet -> baseline CURVES -> propose
   Phase-2 thresholds from observed shape. Logic-SLOs (14/15/40P01/dup) stay HARD gates, re-verify HOLD.
4. SAFETY/TEARDOWN: dedicated isolation; same-day auto-teardown (brew-ops deletes project); ≤8h window +
   ≤$30 cap; abort on create-5xx>~5% / pooler no-more-connections / EF mass-timeout / window-exceeded;
   synthetic data + ephemeral keys destroyed.
5. INTERPRETATION: logic-SLOs GREEN = HOLD under real infra (flip = infra finding not logic regression);
   infra-SLOs no prior baseline -> GREEN = sustained tiers + clean curves captured (deliverable = baseline
   + proposed Phase-2 thresholds, separate ratification), NOT a threshold pass.

5 ITEMS FOR USER RATIFY (before any spend): (1) compute Medium/Small/Large; (2) reuse existing Pro org
($0) vs new ($25/mo); (3) ≤$30 ceiling ok; (4) callback target tunnel-mock vs hosted-mock; (5) burst
aggression keep-100/1s vs push-to-cliff.

On sign-off: I hand the measurement design to next-impl + brew-ops gets the provisioning spec. Ready to
write the post-run threshold-derivation methodology when the run lands.

<!-- handled_at: 2026-05-22T20:28:08+07:00 | handled_by: orchestrator wt-13 | handled_by_thread: 216 | handled_note: hosted load-test plan PR #233 received (proposal, no spend). 5 ratify items relayed to user. needs_response=false. NOTE reconcile: plan assigns provisioning to brew-ops (§3b) but user is creating the project themselves — user does project-create + org/compute choice (decisions 1/2), then brew-ops applies spec (migrations chain + 13-bank seed + EF deploy) + next-impl runs. Architect msg 946 predates orchestrator refinement msg 945 (user-provisions framing). -->
