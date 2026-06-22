# Handoff: campaign o-fix-live-red — livetest RED findings fixed (CLOSED)

**From:** orchestrator (MaxpayPlus) · **Date:** 2026-06-20 GMT+7 · driven from handoff `2026-06-20_17-05_livetest-allrun-results-and-findings`

## Outcome — all 3 RED + correlated AMBERs resolved; collapsed to 2 real bugs + 1 false-alarm
- **F1 (RED, 2 legs)** tri-epic deposit faults — REAL harness bug. `chainToPaid` reached `paid` via admin-approve V2 gate but the fault deposit had no promptpay → 400 V2_PARTIAL_DATA. Fix: drive paid via feedStatement auto-match (like GREEN Journey B). **PR #659 commit 1.**
- **F3 (RED, 1 leg)** FRD3 isolation — NOT a gateway bug; F2 fallout (scb3 produced 0 matched statements → empty array trips the over-strict crossOk guard; matcher structurally cannot cross-account-match). Hardened: decouple crossOk(isolation) from completeness. **PR #659 commit 2.**
- **F2 (AMBER, root cause of F3)** scb3+ktb1 deployed bots 401 since 09:10:45 UTC — the tri-epic A harness re-keys their gateway bot creds WITHOUT syncing AWS Secrets Manager / restarting ECS. TWO triggers: (a) ktb1 = cast BANK_MAINT UUID collides byte-for-byte with deployed ktb1 (static; uuidfix missed it); (b) scb3 = cast client C1 is a member of the live fleet pool, so a tri-epic A C1 deposit fair-routes onto deployed scb3 → ensureBotCredential mints on it (dynamic). Fixes: universal bot-driver fleet guard + BANK_MAINT decouple + provisionCast pool-hygiene self-heal + legMatch/legCollision skip-mint-on-fleet-bank. **PR #659 commits 3-5.**

## Done / verified
- **PR #659** (kxlahsimx09/mb-next-payment-gateway, branch campaign/o-fix-live-red, 5 commits) — OPEN, **awaiting owner review+merge**.
- **brew-ops re-provisioned scb3 + ktb1** (mint/rotate → Secrets Manager → ECS force-new-deploy): both gateway-probe **200**, statement bots scraping, payout bots polling. + seeded a **dedicated NON-cast FLEET client** `0117e000-0c11-…-00f1` (oliveK_FLEET) into the live fleet pool so FR1 stays GREEN after the self-heal strips cast clients.

## Outstanding (owner)
1. **Merge PR #659** (per safety rules, orchestrator does not merge).
2. **A-RUN FREEZE:** do NOT run tri-epic A against the shared fleet until PR #659 merges — the harness still re-keys scb3+ktb1 until then (the new guard now makes that a LOUD RED, not a silent clobber).
3. **Durability note:** the dedicated FLEET client is persistent staging data; if a LIVE_DEDICATED_STACK wipe could remove it, consider harness-seeding it (flagged, non-blocking).

## Notes
- 2× Claude account/token rotations mid-run (incl. /login → MaxpayPlus) killed dev+investigator; recovered by re-spawn (`maw team spawn --exec`) + break-pane into own windows + absolute-path resume. No work lost.
- brew-ops's gateway audit_log CORRECTED the investigator's initial "scb3 = not harness" verdict (found the dynamic C1-routing mint path) — good multi-agent cross-check.
- Campaign closed `--keep-worktrees` (PR pending review); 3 teammate processes verified dead. Findings in ψ/memory/mailbox/{next-dev-1,next-investigator,brew-ops}/.
