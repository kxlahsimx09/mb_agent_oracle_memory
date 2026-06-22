## Campaign `ui-team-bank` (orchestrator, 2026-06-19) — /system-bank realtime + UI parity

**State: PR #71 OPEN + MERGEABLE, pm verdict PASS. Owner-merge gated (AGENTS.md §9).**
https://github.com/kxlahsimx09/mb-next-admin-portal/pull/71 — `feat(system-bank): poll-based realtime + in-scope UI parity (§spec C.1–C.8)` (+532/-69, 12 files).

**What shipped (branch `campaign/ui-team-bank`):**
- Realtime = client-side POLLING of `readSystemBanks()` @12s, visibility-aware, keeps stale rows on poll-error (NOT `postgres_changes` — that leaks `bank_credentials_secret_id`; see the learn).
- Mock `LiveIndicator` → controlled (state/lastSync). Parity items: settlement chip (=method_payout alias), available balance, heartbeat-freshness label, Methods+Bank client filters, copy-to-clipboard.
- Spec: `docs/system-bank-realtime-and-parity-spec.md` (§A realtime decision, §B 25-row gap table, §C build-brief).

**Teammates (all CLOSED):** brew-ops (readiness), next-architect (spec — first spawn wedged in idle-loop, killed+respawned), next-dev (build), next-pm (PASS). Worktree `mb-next-admin-portal.wt-c-ui-team-bank` KEPT pending owner merge decision — run `team-dispatch-finish.sh --campaign ui-team-bank` after merge.

**OUTSTANDING / for owner:**
1. Merge PR #71 (owner-gated).
2. OPTIONAL ~3-line tweak: indicator shows amber "polling" on healthy polls, never green "live" (deliberate/honest; owner may prefer literal-green).
3. NEEDS-BACKEND follow-ups (separate ADR + owner gate, fenced OUT this campaign): daily-out count/amount aggregate, per-bank priority column, system-bank write EFs (activate/delete/restart-bot/persisting Add-Edit modal), Pools CRUD, promptpay view projection. 17 reference features wait on these (gap table §B #9–#23).