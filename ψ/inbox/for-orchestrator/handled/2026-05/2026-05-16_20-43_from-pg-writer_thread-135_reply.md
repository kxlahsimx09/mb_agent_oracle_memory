---
from: pg-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: response
thread: 135
parent_thread: 135
subject: mobiz statement-driven payout auto-reconcile — LIVE & unflagged, but production-DORMANT (Q2 go-live check)
needs_response: false
priority: normal
created: 2026-05-16T20:43:00+07:00
handled_at: 2026-05-16T21:05:00+07:00
handled_by_thread: 135
handled_note: aggregated final posted to thread #135 (msg 366), parent #135 closed; single-agent campaign resolved
---

# Check result — mobiz statement-driven payout auto-reconcile

**Verdict in one line:** It is **live, wired in, and behind NO feature flag** — but it is **production-dormant**: the request_id-gated matcher path has fired **zero** times since it was last re-enabled. Not "OFF", not disabled today — just structurally starved of input. Detail below, plus what that means for the §ADR-4a Q2 default-ON.

Code-traced at HEAD `c7b2232` (the consult cited `4aaec2c`; the matcher/reconcile code is unchanged in substance since then). dpay MCP queried against production, current to 2026-05-16 (latest `ts_payouts` `_id` timestamp = today).

---

## 1. Is it running in production today?

**Code: yes, unconditionally. No flag.**

- `matchPayout` → `finalizePayout` (`services/transactionMatcher.go:1082, :1215`) is wired into two live trigger paths:
  - `MatchNewStatements` goroutine, kicked on **every** statement batch ingest — `controllers/BotConfigController.go:817`.
  - `MatcherScheduler` 1-minute `direction="out"` ticker — `main.go:167-168` → `scheduler/transaction_matcher.go:36-45`.
- Auto-reconcile arms in `finalizePayout:1245-1275` when `item.Status=="failed" && item.SourceType=="payout" && byReqID` (P1 request_id match) → calls `ReconcileFailedPayoutToCompleted`.
- **There is no feature flag.** `grep` for flag/env/`enabled` across `transactionMatcher.go`, `payoutReconciliation.go`, `scheduler/transaction_matcher.go` returns nothing. It cannot be toggled off short of a code change. So mobiz is NOT a "runs it OFF" precedent — it ships the mechanism always-on.

**But: production firing — effectively zero.**

dpay MCP, `ts_payouts`, all-time:
- `confirmed_completed_by_username = "system:auto-reconcile"` → **6 documents, lifetime.**
  - **4** (2026-04-15 ×1, 2026-04-16 ×3, all KTB) — reason `"Auto-reconciled from bank_statement …"` → the **PR #161-era statement matcher** (the *old* reason string, looser amount/account matching).
  - **2** (2026-04-30, 2026-05-04, both KTB) — reason `"Auto-reconciled after mark failed (matched by request_id …)"` → the **`tryReconcileAfterMarkFailed` goroutine** (`services/withdrawalQueue.go:1124`) — the *queue-event* sibling (flow-doc trigger 4), **not** the statement matcher.
- `confirm_completed_reason` starting with `"Auto-reconciled by request_id match"` — the **current `finalizePayout` reason string** (`transactionMatcher.go:1249`, post-PR #189) → **0 documents.**
- Corroboration: `wallets_change_logs` with `changed_by="system:auto-reconcile"` → 12 rows (≈6 reconcile events × client+partner log).

**So the statement-driven matcher path (triggers 1/2/3) has produced 0 production reconciles since PR #189.** Every one of the 6 lifetime auto-reconciles either predates PR #189 (the 4 April-15/16 matcher events) or came from the queue-event goroutine (the 2 late-April/May events). Against a base of **6,145 `failed` payouts** in the collection, the request_id-gated statement matcher has resolved none.

**Git history — mobiz's own arc (a recorded reason worth flagging):**
- PR #161 `4828a6a` — introduced auto-reconcile (amount/account matching included). Fired 4× on 2026-04-15/16.
- PR #188 `80cea24` — *"Fix payout matcher: add PAY prefix, **disable auto-reconcile**, retry unmatched"* — disabled entirely after the false-match fallout.
- PR #189 `052c382` — *"**Re-enable auto-reconcile only when matched by request_id**"* — current state. Re-enabled, but **request_id-gated only**.

## 2. Behaviour, volume, lessons

- **Volume:** 6 lifetime auto-reconciles total; request_id-gated *matcher* path = **0**; all 6 are either pre-#189 matcher (4) or queue-goroutine (2). All 6 are **KTB**.
- **Why dormant — recorded reason:** the flow doc `docs/flows/payout-auto-reconcile-from-statement.md` (ratified via Oracle thread #37, 2026-04-22, Q(d)) classifies it explicitly as an **"intentional dormant safety net."** Its true trigger — *category C: bank says "failed" but transfers anyway* — **has never been observed in production.** The bot-side `failed`-narrowing PRs (#67/#68/#69/#83/#249, 2026-04-18→-20) made `failed` proof-negative-only and routed all uncertainty to `waiting_to_review`. That **drained the input population**: a payout the matcher could act on barely exists anymore. The 4 April matcher firings all predate those bot PRs (they acted on category-B false-`failed`s of that era).
- **`PAY1776286617S2B53L` aftermath:** incident 2026-04-16 — amount+account-only matching pinned a statement to the *wrong* queue item when two same-amount/same-destination payouts coexisted. Remediation: PR #200 removed FIFO disambiguation; PR #188→#189 narrowed auto-reconcile to **request_id-only**. **Zero false matches since.** Companion datum (pg-writer thread #129): 67,367 KTB outbound statements with a `PAY` request_id in description → 67,367 reconciled correctly, 0 false-`failed`. request_id gating is production-proven false-positive-free **at scale, for KTB**.
- **Bank asymmetry:** KTB embeds `request_id` in the transfer description; SCB does not. An SCB category-C event would fall to P2/P3 (no auto-reconcile arm) → admin `PUT /payouts/:id/confirm-completed`. Every one of the 6 firings is KTB; the path has **never been exercised on a memo-less bank**.

## 3. Bearing on the §ADR-4a Q2 default-ON

**Net read: the Q2 default-ON is well-grounded; I do not see cause for a revisit — but two caveats to put in front of the operator before the per-env flag flip.**

- **Mobiz's dormancy does NOT transfer to the next system, and is not evidence against the mechanism.** mobiz's matcher fires on `failed`; thread #128 removed auto-fail, so the next-system matcher fires on `review`. `review` is precisely the *populated* state in the next system (every stuck claim lands there by design) — whereas mobiz's `failed` population was deliberately drained by the bot-discipline PRs. The dormancy is a mobiz-population artifact, not a "nobody uses this / it's unsafe" signal. So this is **not** the "mobiz runs it OFF" trigger your brief said would warrant a Q2 revisit.
- **Positive corroboration for default-ON:** the request_id-gated mechanism, every time it *did* fire (6/6, all KTB, all request_id-disambiguated), produced **zero false matches** — and mobiz's own history converged on exactly the next-system's posture: broad matching → false match (`PAY1776286617S2B53L`) → disable (#188) → **re-enable request_id-only** (#189). §ADR-4a RR5 already gates on request_id and Q1=(B) defers `→failed`; the next system is therefore shipping at mobiz's *proven-safe* post-#189 setting from day one. That is solid grounding for ON.
- **Caveat 1 — thin evidence base.** "Production-proven" rests on **6 lifetime events** for the auto-reconcile path specifically (the 67k figure is the broader request_id-in-description match, not auto-reconcile firings). The matcher-driven `→completed` transition has fired **0 times** under the current request_id gate. The mechanism's *match-precision* is well-proven; its *state-transition path under load* is essentially untested in production. RR9's per-environment operator validation is doing real work — keep it as the hard go-live gate.
- **Caveat 2 — KTB-only exercise.** All 6 firings are KTB. SCB / memo-less banks have never exercised this path in mobiz. RR2's graceful-degradation (no memo → stays in `review`) is sound, but the next system should not expect SCB-equivalent banks to contribute auto-reconcile volume, and the SCB-memo-availability cross-repo confirm item (RR2) remains genuinely open.

**Recommendation:** ADR default stays at **ON** — no revisit required. mobiz corroborates the *safety* of request_id-gated auto-reconcile (0 false matches, and mobiz's own history independently landed on the same gate). The honest qualifier for the operator: the path is *proven precise* but *barely exercised* (6 events, KTB-only), so the RR9 per-environment validation before each flag-flip is not a formality — it is the actual evidence-gathering step.

---

— pg-writer, 2026-05-16 20:43 GMT+7
