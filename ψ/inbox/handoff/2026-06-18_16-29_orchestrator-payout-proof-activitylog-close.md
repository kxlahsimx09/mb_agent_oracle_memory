# Handoff — orchestrator (payout-proof + activity-log arc) 2026-06-18 16:28 GMT+7

**Retros:** `ψ/memory/retrospectives/2026-06/18/09.28_orchestrator-payout-proof-activity-log.md` (this arc) + `…/05.10_orchestrator-botlog-payoutproof.md` (the BOTLOG arc). Supersedes the 12-12 handoff.

**Done this arc (all verified + live; ~16 campaigns, all closed, fleet clean):**
- **Payout PROOF** capture+upload — #26/#27 MERGED + rolled; live-upload 404 bug FIXED (`-payout` API_URL had a `/functions/v1` suffix breaking the storage-PUT string-concat → clean origin, rev :12).
- **Payout activity-log Tier-1** (lifecycle → source='bot') — #28 MERGED + rolled.
- **Payout activity-log Tier-2** (actions → source='bot') — §ADR-15 §Amendment #590 RATIFIED → allowlist #592 MERGED+deployed sinuw (+5 types) → bot emit #29 MERGED + 3 bots rolled (`97ca5c19`). Verified: sinuw accepts the 5 types HTTP 201 under bankbot_logger; RLS negatives reject.
- Earlier-merged: #584 (security checklist).

**OUTSTANDING (owner):**
- merge **#53** (mb-next-admin-portal — portal advisory badge on source='bot' rows). **Only open PR.**
- Pending-NATURAL: a real bot-uploaded proof object + real source='bot' payout-action rows (round-trips VERIFY-proven; await a natural claim/transfer).
- CI: add `payout-app.js` (+ tests/**) to `build-push-ecr.yml` push-paths (it currently excludes payout-only PRs → manual build needed).
- D1 ES256 signer ratify + prod BOT_TOKEN_SIGNING_KEY + migrations if/when bots → prod.
- storage-client: strip `/functions/v1` from API_URL so the footgun can't recur. D2 per-bot kill-switch. token rotation before 2026-08-01.

**Note:** all on sinuw/staging. The 3 live ECS bot services = bot/ktb/**payout** (payout-app.js); payout-lane PRs MUST roll `-payout`.
