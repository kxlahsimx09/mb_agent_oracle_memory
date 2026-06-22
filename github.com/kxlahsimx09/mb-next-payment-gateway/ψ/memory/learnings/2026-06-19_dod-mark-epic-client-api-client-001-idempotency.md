---
title: DoD-MARK — epic-client-api (CLIENT-001 idempotency + CLIENT-002 per-client rate-
tags: [dod-mark, epic-done, client-api, idempotency, rate-limit, seal-green, live-n-a, served-from-store-sentinel, value-verbatim]
created: 2026-06-19
source: next-pm campaign pmmark — MARK #4 (FINAL)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — epic-client-api (CLIENT-001 idempotency + CLIENT-002 per-client rate-

DoD-MARK — epic-client-api (CLIENT-001 idempotency + CLIENT-002 per-client rate-limit) = 🟢 epic-DONE, 2026-06-19 (next-pm, campaign pmmark). The two S2-ratified cross-cutting client-API ingress NFRs. Marked on gates 1–4 GREEN; §ADR-21 LIVE-gate ruled N/A (non-money cross-cutting ingress NFR — OWNER architect P1; SPEC §0 no money movement → no money-invariant recompute). Each gate verified by next-pm directly against its primary artifact (gh state NOT trusted — reviewer verdict lives in the PR body header).

5 GATES:
1. BUILD ✅ — PR #642 MERGED → main, merge commit 269687e (confirmed ancestor of origin/main HEAD 55df841 via git merge-base --is-ancestor; mergedAt 2026-06-19T16:50:13Z). CLIENT-001 = idempotency TTL sweep (sweep_expired_idempotency_keys(int) + idempotency-ttl-sweep pg_cron, closing §ADR-11 negative-consequence (ii): a key whose client never retries was never reclaimed under the prior lazy-purge-only path). CLIENT-002 = fresh per-client dual-window rate-limit at the deployable tier (rate_limit_counters + check_rate_limit(uuid,text) RPC per-client/per-scope/minute+day + rate_limit_config defaults + per-client rate_limit_overrides (RL4) + _shared/rate-limit.ts EF ingress middleware FAIL-OPEN, wired into deposits-create/payouts-create after GW4 verify before idempotency; sweep_rate_limit_counters + 5-min cron); machine-only grants on all 3 new functions + both new tables.
2. REVIEW ✅ — next-code-reviewer PR #642 body-header APPROVE (3-dim): Requirement ✅ (§ADR-11 C1–C5 + §A3 RL1–RL4) / Clean-code ✅ (idempotent migrations, bounded LIMIT+FOR UPDATE SKIP LOCKED sweeps off hot path, machine-only grants, consistent minute→day lock ordering) / Perf ✅ (hot path = one O(1) RPC: 1 PK select + 2 PK upserts, all indexed; no full scans/N+1). gh state=COMMENTED = self-authored build-PR degrade (§9a/#618); self-merged on APPROVE + the investigator SEAL GREEN (§9a two-gate).
3. VERIFY ✅ — next-tester EF-tier (campaign clientapitest) 13/13 GREEN vs the DEPLOYED tester stack (mb-next-tester ref yupsevcrubgprsbujbpu), bound off the SPEC contract not the code, ground-truthed by HTTP wire + direct psql on the REVOKEd surfaces: CLIENT-001 I1–I6b + CLIENT-002 R-a..R-e.
4. SEAL ✅ — next-investigator (campaign clientapiseal) SEAL GREEN — independent falsification (OWN probe/fixtures/caSEAL- row-prefix, tester's run-verify.ts NOT executed): all 13/13 PASSes survive, 0 contradictions. Added strictly-stronger evidence than the tester for "handler not re-run": a served-from-store sentinel injection (overwrote idempotency_keys.response_body with a unique marker; the wire echoed the sentinel verbatim at both 201 and 400 ⇒ replay is provably read from the stored row, not re-executed — airtight + constraint-independent) + completed_at-unchanged + request_hash==SHA256(body), closing the UNIQUE(request_id) confound. PR #642 mergeable on this SEAL.
5. LIVE ✅ N/A (ruled) — non-money cross-cutting ingress NFR (OWNER architect P1; SPEC §0). The guarded DEPOSIT/PAYOUT money journeys recompute their own invariants live under their own signoffs — no own live_signoff row. Precedent: CLIREAD #611 / PROV #612 / OTPLOG #566.

NAMED non-blocking nuance (tester + investigator + reviewer all concur): replay is JSON-VALUE-verbatim, not BYTE-verbatim — response_body is a jsonb column per the SPEC's own §1.2 schema; Postgres canonicalizes jsonb key-order, so a replay has identical status + key/value set but a different byte order. Invisible to any JSON client; §1.4 "verbatim" holds at the JSON-value level; byte-identity neither mandated nor possible under ratified jsonb storage. NOT a defect, NOT blocking.

MARK = DOCS-ONLY flip PR #648 (base main, head docs/client-api-epic-done-pmmark, commit 59c84c6; epic-client-api.md Build-status DoD section + INDEX.md Client-API Contract flip). LEFT FOR OWNER MERGE per §9a — NOT self-merged (sibling marks #644/#646/#647 same posture). This is the LAST mark of campaign pmmark (after MARK1 statement-matching #644, MARK2 admin-audit #646, MARK3 callback-delivery #647).

---
*Added via Oracle Learn*
