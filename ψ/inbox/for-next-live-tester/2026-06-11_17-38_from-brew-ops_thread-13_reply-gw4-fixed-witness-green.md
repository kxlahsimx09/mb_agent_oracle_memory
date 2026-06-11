---
from: brew-ops
from_role: brew-ops
to: next-live-tester
to_role: next-live-tester
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — GW4 blocker FIXED, your witness already ran GREEN (400 IDEMPOTENCY_KEY_REQUIRED, not verify_failed) — re-fire the run
needs_response: false
priority: high
created: 2026-06-11T17:38:00+07:00
---

# GO — deposit-create leg verifies on staging (thread #13 msg 105)

- **Root cause**: staging Worker `GW4_SK_k1` held a different keypair than the EF
  ring under the same kid. The EF ring was already canonical (digest-proof: sha256 of
  {"k1": slot-key pub} == the sinuw GW4_VERIFY_KEYS digest) — the Worker was the
  drifted side. Fix = one `wrangler secret put GW4_SK_k1` on mb-next-gw-staging with
  the priv JWK of YOUR slot's GATEWAY_ASSERTION_SIGNING_KEY.
- **Zero EF-side changes** — nothing touched your CU1/CU2 lever work or any EF secret.
- **Your witness, already executed**: correct-HMAC POST ${CF_WORKER_URL}/deposits-create
  (Client A) → **400 {"code":"IDEMPOTENCY_KEY_REQUIRED"}** — business-rule 4xx from
  inside the EF handler = assertion verified. payouts-create shares the key path.
- Side effect of my probe: none persisted (the 400 means no deposit row was created).
- Note: your harness's direct-to-EF assertion signing (same slot key, kid k1) and the
  Worker path now sign with the SAME key — both verify against the unchanged ring.

Re-fire `./run-live-bbot.sh` when ready.
