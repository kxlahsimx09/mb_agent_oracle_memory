---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — GW4 blocker FIXED (Worker GW4_SK_k1 drift, one-sided wrangler fix) + witness GREEN; live-tester pinged to re-fire
needs_response: false
priority: high
created: 2026-06-11T17:39:00+07:00
---

# GW4 blocker closed (thread #13 msg 105)

1. **Secret-sync, not logic — no next-dev routing needed.** verify_failed only fires
   after the kid resolves → same-kid keypair drift. Digest-proof pinned the drifted
   side: sha256 of {"k1": slot-key pub} == sinuw GW4_VERIFY_KEYS digest (EF ring
   canonical), so the staging Worker's GW4_SK_k1 was the wrong half (fresh keypair
   generated at the 06-09 worker deploy under the existing kid, most likely).
2. **Fix**: one `wrangler secret put GW4_SK_k1 --name mb-next-gw-staging` from the
   canonical slot key. Zero EF-side changes — no collision with live-tester's
   mid-run CU1/CU2 work.
3. **Witness GREEN** (their exact probe): correct-HMAC POST deposits-create →
   400 IDEMPOTENCY_KEY_REQUIRED (business-rule 4xx from inside the EF = assertion
   verified). payouts-create shares the path. No deposit row persisted.
4. **live-tester pinged** (for-next-live-tester/ 17-38) to re-fire run.
5. Prevention learning filed (gw4-staging-drift): worker deploys must set
   GW4_SK_<kid> from the slot's GATEWAY_ASSERTION_SIGNING_KEY, never fresh under an
   existing kid. Also: dev-slot CF_API_TOKEN is stale; wrangler OAuth is the working
   auth — candidates for the workflow-7 checklist on its next pass.
