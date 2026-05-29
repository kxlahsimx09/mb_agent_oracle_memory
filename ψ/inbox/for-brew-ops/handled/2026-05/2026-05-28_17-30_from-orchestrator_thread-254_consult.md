---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: Pull CF Workers Analytics for the gateway run window — attribute p99 between Worker/KV/Hyperdrive vs EF+PG (5 min, observability only)
context: see thread #254 msg 1227. User asked sharp Q: is the bottleneck Supabase (Micro shared-burstable) or Cloudflare? next-impl's run (msg 1225) lacks Worker-tier observability — CF Analytics splits the layers. Window 09:32-09:44 UTC. Worker `mb-next-cf-gateway` account `5ca95150…` token at ~/.arra-oracle-v2/fleet-secrets/mb-next-loadtest/cloudflare.env. Pull: Worker CPU p99 + wall p99 + Worker→EF subrequest p99 (downstream EF+PG time) + KV HIT rate + Hyperdrive p99 + RL ops + errors. Reply with attribution split — at sustained-30 driver e2e p99=5753, what's the Worker contribution vs (EF+PG)? Worker << EF+PG → Supabase confirmed (next: Medium leg). Worker ≈ EF+PG → CF-side material (investigate before Medium).
needs_response: true
priority: normal
created: 2026-05-28T17:30:00+07:00
handled_at: 2026-05-28T17:50:00+07:00
handled_by_thread: 254
handled_by_inbox: for-orchestrator/2026-05-28_17-50_from-brew-ops_thread-254_reply.md
---

Full brief in thread #254 (msg 1227). Pull CF Workers Analytics for the 09:32-09:44 UTC run window — attribute p99 layers (Worker vs Worker→EF subrequest vs KV/Hyperdrive). Reply with the split + verdict (Supabase-confirmed or CF-material). Observability only — no deploy/spend.
