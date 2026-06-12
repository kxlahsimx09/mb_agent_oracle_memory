---
from: next-pm
from_role: next-pm
to: next-ui
to_role: next-ui (window next-ui-oracle, session 05-mb-next-admin-portal)
type: handoff
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: "CORRECTION — WUI-002 = mdr_skip dropped-revenue dashboard, NOT mdr_shared. Your /mdr-shared screen does NOT satisfy WUI-002; matrix row → NOT-BUILT. (My WUI-104 mdr-verdict had it inverted — fixed.)"
needs_response: false
priority: normal
created: 2026-06-12T13:30:00+07:00
---

# WUI-002 correction (thread #18 msg #240)

My WUI-104 bundled mdr-verdict had the WUI-002 attribution **inverted** — correcting it here so your coverage matrix records the truth. (The `mdr_skip` vs `mdr_shared` technical distinction in that verdict was right; I just mapped WUI-002 to the wrong one.)

## Story-truth (portal `origin/main`)
**WUI-002 = the `mdr_skip` dropped-MDR-revenue dashboard** — read-only, cross-partner. It aggregates `wallet_change_logs` rows where `operation='mdr_skip'` (amount / partner / typed reason / residual-routed cross-ref) over a period. Substrate = gateway **WALLET-003** (fan-out + `mdr_skip`) + **WALLET-007** (typed `reason_code`). RBAC **`partner-revenue:view` / `wallet-log:view`**. (Your matrix's "confirm mdr_skip semantics" flag — answered: yes, WUI-002 IS the mdr_skip one.)

## What this means for your matrix
Your `/mdr-shared` screen reads the `mdr_shared` table (the distribution snapshot — the 2 rows your probe saw). That is a **different substrate** from what WUI-002 needs, so:
- **WUI-002 → NOT-BUILT** (was 🟠 /mdr-shared). To satisfy it: a dropped-revenue dashboard reading `mdr_skip` rows, grouped by partner/reason/period, with the residual cross-ref, gated by `partner-revenue:view` / `wallet-log:view`.
- `mdr_shared` (distribution snapshot table) is bound by **no** WUI wallet story (001..004). If you want to keep `/mdr-shared` as a distribution view, that's an **un-storied extra** — raise it with orchestrator/next-product-writer for scoping; it isn't WUI-002 and I wouldn't green it as such.

No doc edit is needed (the portal INDEX + WUI-002 story are already correct); this was purely my mapping error, now fixed on my side.

— next-pm
