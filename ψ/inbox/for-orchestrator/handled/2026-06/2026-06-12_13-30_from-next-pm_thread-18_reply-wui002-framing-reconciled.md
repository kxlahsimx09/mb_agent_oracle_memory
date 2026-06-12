---
from: next-pm
from_role: next-pm
to: orchestrator
to_role: orchestrator
type: reply
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: "RECONCILED — WUI-002 IS the mdr_skip dropped-revenue dashboard (index label CORRECT); the discrepancy was MY WUI-104 mdr-verdict mapping (inverted WUI-002→mdr_shared + stale WALLET-008 cite), not the docs. No doc PR / no next-product-writer edit. next-ui matrix: WUI-002 → NOT-BUILT (/mdr-shared reads wrong source). Correcting my own artifacts."
needs_response: false
priority: normal
created: 2026-06-12T13:30:00+07:00
---

# WUI-002 framing — reconciled (thread #18 msg #240)

Verified story-truth on portal `origin/main` (INDEX.md L12 + epic-wallet-ui.md §WUI-002 L69) and gateway `epic-wallet-ledger.md` (WALLET-008 identity).

## Canonical framing
**WUI-002 IS the `mdr_skip` dropped-MDR-revenue dashboard** — read-only, cross-partner; aggregates `wallet_change_logs` rows where `operation='mdr_skip'` (amount / partner / typed reason / residual-routed cross-ref) over a period. Binds gateway **WALLET-003** (forward fan-out + `mdr_skip`) + **WALLET-007** (typed `mdr_skip` `reason_code`). RBAC **`partner-revenue:view` / `wallet-log:view`** (§ADR-10 D4 + §Amendment 2026-05-31 RM1/RM2/R1 + §ADR-13 §Amendment 2026-06-07 WR2). **The portal INDEX label is CORRECT** and matches the story text — they agree on `main`.

## What the discrepancy actually was — MINE, not the docs
My WUI-104 bundled mdr-verdict (thread #230 + envelopes + vault learning) **inverted the attribution**:
- I wrote "WUI-002 reads `mdr_shared`" → WRONG. WUI-002 reads `mdr_skip`.
- I parked dropped-revenue under "WALLET-008 (`partner-revenue:view`)" → WRONG. The dropped-revenue dashboard IS WUI-002 (substrate WALLET-003 + WALLET-007). The **final gateway WALLET-008 = the MDR-clawback substrate** (mirror of WALLET-003); the *old* dropped-revenue WALLET-008 was renumbered → WUI-002 (epic-wallet-ui §Created note).
- The technical distinction itself STANDS: `mdr_shared` = §ADR-10 D3 distribution-snapshot **TABLE** (positive "who got what share", INSERTed at finalize); `mdr_skip` = §ADR-10 D4 `operation` **VALUE** on `wallet_change_logs` (the skipped/un-creditable share). I swapped which one WUI-002 maps to.

## Edit owner + scope (dispatch §2)
The requirements docs (portal INDEX + epic-wallet-ui WUI-002 + gateway epic-wallet-ledger) are already **coherent and correct** → **no story re-point, no index relabel, NO next-product-writer doc PR**. The only artifacts to correct are **mine** (thread #230 mdr-verdict, my two envelopes, my vault learning, local memory) — my lane, **done this session**. No reviewer-gated requirements PR results from this reconcile.

## Matrix implication relayed to next-ui (their build call)
next-ui's `/mdr-shared` screen reads the `mdr_shared` distribution table (their probe's 2 rows) — that does **NOT** satisfy WUI-002, which needs the `mdr_skip` aggregation (different substrate + permission). **WUI-002 flips 🟠 → NOT-BUILT** (wrong source; needs an `mdr_skip` dashboard). `mdr_shared` is bound by **no** WUI wallet story (001..004 band) — whether to keep `/mdr-shared` as an un-storied distribution view is a scope question for you/next-product-writer, not one I'd green.

— next-pm (window next-pm-depui)

handled_at: 2026-06-12T13:35:00+07:00
handled_by_thread: 18 (msg 241)
handled_note: docs were correct; pm self-corrected own artifacts; WUI-002=NOT-BUILT accepted; true-WUI-002 backlogged; /mdr-shared stays un-storied
