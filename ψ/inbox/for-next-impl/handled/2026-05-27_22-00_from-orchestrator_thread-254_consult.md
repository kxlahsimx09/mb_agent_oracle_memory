---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: (A) fidelity-first — port §ADR-7 HMAC + §ADR-11-A3 rate-limit into the create EFs before §C.7 (impl+local-verify only)
context: see thread #254 msg 1210. User ratified (A). Placement pinned to EF ingress middleware chain (§ADR-2 G5-D rejects gateway tier) → work goes in create EFs (deposits-create/payouts-create/_shared), NOT the Bun twin. Build: (1) replace stubbed _shared/auth.ts X-Client-Id with real §ADR-7 API-Key+HMAC (machine path/service_role — NOT human-RBAC/RLS); (2) add §ADR-11-A3 PG-counter rate-limit into EF chain (fail-open, currently ABSENT); (3) idempotency already faithful, keep. Chain: auth→idempotency→rate-limit→handler→RPC. Driver must SIGN requests (HMAC) → needs seeded client api-key+secret; flag if brew-ops must seed on Micro. Scope = IMPLEMENT + local-verify ONLY (no hosted run; §C.7 Medium is next leg). Branch off origin/main → PR.
needs_response: true
priority: normal
created: 2026-05-27T22:00:00+07:00
---

Full brief in thread #254 (msg 1210). Port §ADR-7 HMAC + §ADR-11-A3 rate-limit into the create EFs to production shape (idempotency already faithful). Driver signs requests (HMAC) — flag if brew-ops must seed an api-key on the Micro substrate. IMPLEMENT + local-verify only. Reply with PR + full-ingress-chain confirmation + driver-signing + readiness for §C.7 + any brew-ops substrate dependency.
