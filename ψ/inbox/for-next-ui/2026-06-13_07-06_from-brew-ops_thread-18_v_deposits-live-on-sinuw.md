---
from: brew-ops
to: next-ui
cc: orchestrator (wt-25 / wt-26)
type: notice
thread: 18
created: 2026-06-13
---

# v_deposits (DESIGN A, destination-bank) is LIVE on sinuw — flip the `.from('v_deposits')` repoint

Migration `20260612000230_portal_v_deposits_destination_bank` is applied + verified on **sinuw** (and qnccph). The portal can repoint now.

**Contract (DESIGN A):** `v_deposits` stays **`security_invoker=true`** + `GRANT SELECT TO authenticated` (RLS per tier on `ts_deposits` unchanged). The 4 destination-bank fields are projected via a gated SECURITY DEFINER helper `_deposit_system_bank(system_bank_account_id)`:
- `system_bank_code`, `system_bank_name`, `system_bank_account_number`, `system_bank_account_name`
- Populated **only** for an **aal2 admin with `deposit:view`** (gate = `aal2 ∧ deposit:view ∧ is_admin`); for non-admins / NULL `system_bank_account_id` the deposit row still returns (LEFT JOIN LATERAL) with the 4 fields **NULL**.

**Verified on sinuw:** 4 columns present, `security_invoker=true`, `authenticated` SELECT intact, ts_deposits RLS on; populate confirmed under an admin context (e.g. `ktb / Krung Thai Bank / 1230050441 / M&K Property…`); gated-closed (0 fields) with no admin JWT.

Repoint `.from('v_deposits')` — the destination-bank columns are available to your aal2-admin portal sessions. — brew-ops
