---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 174
parent_thread: 174
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "RE #174 — G-8..G-12 probe round done — hosted 162/162; G-10 STOP+flag"
needs_response: true
priority: normal
created: 2026-05-19T22:10:00+07:00
handled_at: 2026-05-19T22:04:53+07:00
handled_by_thread: 174
handled_by_inbox: for-orchestrator/handled/2026-05/2026-05-19_22-04_from-orchestrator_thread-174_reply.md
---

G-8..G-12 probe round — PR #185 (stacked on #183). Full reply on thread #174
(msg 618). All probe-only — no migration, no EF.

- **G-8** — determinism pass: deposit_d6 retry budget 6→30; deposit_d7
  recovery gate rewritten to not depend on the racy post-state.
- **G-9** — PAYOUT-003 `mark_failed` atomic-rollback twin (new probe; same
  CHECK(frozen>=0) fault-injection as the mark_success twin — no new
  substrate after all).
- **G-11** — PAYOUT-009 reconcile degradation paths (amount-mismatch /
  flag-off / memo-less; new probe).
- **G-12** — DEPOSIT-003 AC5 + DEPOSIT-005 AC3 sweep-restart (new probe;
  deterministic — bounded partial tick + restart tick, end-state gated).

Hosted-verified `spdazjbmyagekwxixfct` — smoke **162/162 PASS, 0 failed**,
**two consecutive runs** (the determinism evidence). 7 new assertions green,
both G-8 flaky probes green on both runs.

⚠ **G-10 — STOP + flag.** `v_payouts.effective_status` does NOT exist on the
deployed substrate (PGRST205 — no view, no migration defines it). Probing the
view-contract needs the `v_payouts` view PORTED first — a PORT, not a
probe-only gap, contrary to the round's "all probe, no PORTs" framing. Did
not silently expand scope. Your ruling: (A) greenlight a small `v_payouts`
(+ PA4 write-path guard) PORT chunk — low-risk, `v_deposits` precedent + PA2
ratified; or (B) defer G-10 with G-13/G-14.

Stack `main ← #170 ← … ← #183 ← #185`. #174 close-order: all done except the
G-10 ruling. `parent_session`/`parent_thread` route this back to your session.

— next-impl
