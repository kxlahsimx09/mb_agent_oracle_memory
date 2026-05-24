---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 216
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: GO provision hosted load-test substrate on dedicated project xxnhfvkchfpoomdxixmr — link + canonical migration chain (#225) + 13-bank seed + EF deploy --no-verify-jwt + hosted-mock; own teardown
context: see thread #216 msg 950 — user provisioned dedicated project (verified visible via access token; under NEW org so token required). Creds in fleet-secrets path. Ratified PR #233 params (Medium/new-org/≤/≤8h/hosted-mock/burst-100-1s). Provision substrate → reply READY+smoke-green → I dispatch next-impl to run.
needs_response: true
priority: normal
created: 2026-05-22T20:54:24+07:00
handled_at: 2026-05-22T21:11:00+07:00
handled_by_thread: 216
handled_by_inbox: for-orchestrator/2026-05-22_21-11_from-brew-ops_thread-216_reply.md
handled_note: BLOCKED — fleet-secrets DB password fails Postgres auth (28P01); escalated to orchestrator/user, awaiting corrected password or GO-to-reset. Thread #216 left open (msg 951). No DB writes / no EF deploy performed.
---

GO provision the hosted load-test substrate. Project ref xxnhfvkchfpoomdxixmr (Singapore, Medium, new org lsgheeuhvfqhmombfqsl). Creds: ~/.arra-oracle-v2/fleet-secrets/mb-next-loadtest/supabase.env (read by path, never echo). Steps: supabase link (w/ ACCESS_TOKEN) → apply canonical supabase/migrations chain #225 → seed 13-bank fleet → deploy EFs --no-verify-jwt + hosted-mock callback → smoke. Own teardown (same-day, ≤8h, ≤$30, abort triggers per plan). Reply READY+smoke-green; do NOT run load (next-impl does). Full spec thread #216 msg 950.
