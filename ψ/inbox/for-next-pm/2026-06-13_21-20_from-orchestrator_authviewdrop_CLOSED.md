---
from: orchestrator
from_role: orchestrator
to: next-pm
to_role: next-pm
cc: orchestrator
type: notify
campaign: authviewdrop
thread: 16
parent_thread: 16
priority: normal
created: 2026-06-13T21:20:00+07:00
needs_response: false
---

# authviewdrop CLOSED — your secret-exposure handoff resolved

Final disposition of `next-pm_secret-exposure_handoff.md`.

## Done
- **Slice 1 (the original ask):** the four unsafe `SELECT *` `v_auth_*` bridge views are gone
  on sinuw+qnccph and live-verified — `investigator_ro` cannot read TOTP `secret` /
  `encrypted_password` / `*_token` (42501/42P01). Auth crypto boundary CLOSED. (Premise note:
  they were already torn down 2026-06-12; the "standing" flag was a repo/grep inference, not a
  live query — P-004: live = truth.)
- **Durable pattern (PR #486, merged + independently APPROVED):** ADR §ADR-13 **SV10** rule
  ("never `SELECT *` over `auth.*`/business `public.*` into a grantable object; secrets never
  readable by a non-owner") — greppable + enforced by a 26-assert guard test. This closes the
  "standing but invisible / not-in-repo" gap structurally.
- **mig 020 applied to sinuw:** secret-free column-explicit `v_auth_*` forensic views, granted
  `investigator_ro` only. investigator has a clean, sanctioned auth read-path; secrets excluded
  by construction; verified working as investigator_ro.

## Decided NOT to do (and why) — important reframing
The adjacent finding (investigator_ro can also read `merchant_config.secret` / `bot_credentials` /
callback keys / `app_settings` via a broad 44-table grant) was confirmed by brew-ops's live sweep.
**Owner ruling:** `sinuw` is **staging with synthetic/probe data** — those "secrets" are not real,
so the over-grant is least-privilege hygiene, not a confidentiality breach (matches your original
LOW rating). The full **D2 deny-by-default** revoke+allowlist is **DEFERRED until a real-prod
stack exists**; the broad public grant stays as-is on staging. mig 030 (D1 surgical, incomplete)
is **held/abandoned** (revert pending).

## Carried forward
- **When a real-prod gateway stack exists:** build D2 (`REVOKE ALL ON public FROM investigator_ro`
  + explicit secret-free allowlist). brew-ops's sweep already enumerated the secret tables to fence:
  `merchant_config`, `client`, `bot_credentials`, `client_callback_endpoints`,
  `ts_deposits/ts_payouts/v_deposits` callback keys, `app_settings`. SV10 is the standing rule.
- **mig 030 revert** out of main (D1 abandoned) — pending owner go.

## Handoff-hygiene lesson (for future PM secret-exposure flags)
Confirm **stack = prod vs staging** and **data = real vs synthetic** *before* rating severity. This
one read as a standing crypto-secret exposure but was staging/synthetic → hygiene, not breach. A
live query (not a repo grep) is the authority on "is it still exposed" (P-004).

Please flip the flag **standing → closed** in the deposit-epic-review record.
