---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: perf-harness fidelity gap-analysis DELIVERED (review-only) — ranked ADD/SKIP on thread #254
needs_response: false
priority: normal
created: 2026-05-27T13:00:00+07:00
handled_at: 2026-05-27T20:03:00+07:00
handled_by_thread: 254
handled_note: >
  Relayed to user via Telegram (chat 2002026175, msg id 34) at 2026-05-27T20:03+07:00.
  Review-only deliverable complete; no reply envelope sent (needs_response=false).
  Trace marker posted to thread #254 (msg 1201). Thread left pending for user direction.
---

Gap-analysis posted to thread #254 (msg 1200) + durable learning filed. REVIEW ONLY — no harness changes, did not touch the running perf harness/substrate.

**Structural finding:** harness has 2 layers. (A) Sustained load (driver.ts + §D runner) drives ONLY create endpoints, `--no-verify-jwt` (auth bypassed), callbacks→mock, and created deposits NEVER finalize (no statement stream) → the write-amplifying money path is absent from every §D number. (B) Small correctness probes (G-L2/4/6/9) do drive finalize/MDR/coalescing but at 40–200 deposits, not at volume.

**Reframe (changes ranking):** prod's biggest write flow `audit_trail` ~184k/day is the HTTP REQUEST LOG (→ Axiom, not Postgres, in next-system). Real next-system `audit_log` ≈ `activity_logs` ~1,507 rows LIFETIME = sparse. So next-system DB write-pressure = deposit-finalize fan-out + callback attempt-log, NOT any audit log.

**Ranked ADDs:** (1) drive deposits→FINALIZE under load (statement-intake advisory-lock + ~9 writes/finalize + MDR hot-row partner wallets); (2) callback attempt-log append ~6×/callback + coalescing at 44.7k/day; (3) DB per-client rate-limit counter = row-lock hotspot; (4) per-request RLS/RBAC/api-key reads — NOT fixed, erode the CPU-bound §D ceiling (auth was OFF for all §D verdicts); (5) verify idempotency uses the DB dedup-table.

**SKIPs (perf-neutral):** admin-audit (sparse, ≠HTTP log), monitoring (external sinks), fleet-control (operator cadence, own tables), source-flows settlement/pullout/DT (<100/day), topup (~8/day), auth login-path, callback signing/payload.

Headline: front door driven hard; money path never driven at volume. Can quantify writes/sec per ADD or deepen any row on request. Relayer: please pass to user.
