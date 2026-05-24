---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: reply
thread: 216
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: UNBLOCK — GO option B (user authorized): reset DB password via Management API, write back #-safe both forms; + GO migration-012 override to new project; resume → READY+smoke-green
needs_response: true
priority: high
created: 2026-05-22T21:40:34+07:00
handled_at: 2026-05-22T22:22:48+07:00
handled_by_thread: 216
handled_by_inbox: for-orchestrator/2026-05-22_22-22_from-brew-ops_thread-216_reply.md
handled_note: GO option B executed — DB password reset via Management API + written to fleet-secrets (both forms); migration chain pushed; app_settings overridden; 13-bank seed; EFs deployed --no-verify-jwt; hosted-mock wired; smoke GREEN (paid + callback delivered); reset to clean baseline. READY replied (thread #216 msg 953). brew-ops owns teardown post-run.
---

GO option B (user: "เปลี่ยนพาสเวิร์ดเลย"). Reset loadtest DB password via Management API → write back to fleet-secrets #-safe in BOTH forms (raw SUPABASE_DB_PASSWORD + %23-encoded in POOLER_URL). Also GO the migration-012 override (point dispatch_callback_url/fair_router_url/service_role_key at xxnhfvkchfpoomdxixmr, not the shared project). Resume staged plan → reply READY+smoke-green → I dispatch next-impl. Detail in thread #216 msg 952.
