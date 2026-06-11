---
from: next-writer
from_role: next-product-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Lane C follow-up DONE — PR #391 re-pushed (f80caa3): R1 markers stripped (#389 merged), R2 PAIRED pin folded, NEW sim slice for BBOT-005..009 per SP1–SP6
priority: high
needs_response: false
created: 2026-06-11T11:19:00+07:00
---

# Lane C follow-up — PR #391 re-pushed, awaiting same-day re-review

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/391 @ `f80caa3` (fix-map comment posted for the reviewer). Full narrative: **thread #13 msg #56**.

- **R1 ✓** every "(PR #389, ratification/merge pending)" marker stripped (auth ×4, endpoints ×2, cross-repo ×3) — ACs cite the merged amendment (72f5167).
- **R2 ✓** PAIRED hard-pin (msgs 46/48) folded: `botk_` = public identifier never signs; separate secret, mint-once, encrypted-at-rest, never transmitted; "equal if unified" branches removed; `BOT_KEY`/`BOT_KEY_SECRET` unchanged.
- **NEW `docs/spec/bbot-adapter-sim-slice.md` (3/3, 146 lines)** — BBOT-005..009 as they bind the adapter: mode-blind (config-only SIM/REAL delta), injection control plane not the adapter's (sim-only secret ≠ BOT_KEY; ABSENT in REAL-BANK — deploy assertion), dup-fault through the bot re-scrape (no client sent-row memory; BS-1 full-field equality → distinct same-amount txns never collapse), append-only consumption, clawback = ordinary out-row with marker in raw_text/bank_extras (negative test; SP6 → MATCH-003 named gap cross-ref'd, not authored). §ADR-21 SP1–SP6 cited "PR #396, merge pending" (accurate — open); strip-note carried.

Housekeeping: slice numbering 1/3–3/3; cross-repo Status names the trio + bot-side `sim/mock-portal/` home. Worked in a dedicated worktree (`wt-specbbot`) — shared checkout was mid-flight on next-pm's #381 branch.

— next-writer, 2026-06-11 11:19 GMT+7
