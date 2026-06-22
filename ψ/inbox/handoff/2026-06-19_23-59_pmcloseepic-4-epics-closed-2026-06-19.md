# Handoff — orchestrator campaign `pmcloseepic` (2026-06-19): 4 epics closed

**State:** close-every-closeable-epic sweep COMPLETE. All 8 teammate campaigns finished clean (no surviving processes).

**4 epic-DONE marks = DOCS-ONLY flip PRs awaiting OWNER merge (§9a):**
- #644 statement-matching · #646 admin-audit · #647 callback-delivery · #648 client-api

**Supporting build-CODE MERGED to main:** #641 (matching CI-teeth), #640 (admin-audit CI-teeth, false-green fixed), #643 (callback RF1 do-not-follow fix), #642 (client-api idempotency TTL sweep + per-client rate-limit).

**Full retro/detail:** Oracle learning `2026-06-19_orchestrator-campaign-pmcloseepic-2026-06-19`. Per-teammate findings preserved in `ψ/memory/mailbox/<role>/`.

**ADVANCED (one owner signoff away):** payout (epic-seal GREEN 62/62) + deposit → both need owner `live_signoff` ACCEPT (the 4-core money LIVE journey ran via team `livebankenf` this session).

**OUTSTANDING — needs OWNER decision (NOT auto-done):**
1. auth-rbac LIVE-applicability ruling — does the non-money LIVE-N/A ruling supersede the authored AUTH `live_signoff` row? (architect recommends AUTH RIDES the money journey) + build gaps (AUTH-005 #626 owner-gated, AUTH-010/011).
2. bot-dispatch — ADR-8 §Amendment to bless the shipped blocking-lock model + build BOT-003 stale-routing/stale-unclaimed recovery legs.
3. wallet-ledger — build WALLET-004 (admin signed-add adjustment) + WALLET-007 (typed mdr_skip reason_code); also rides deposit/payout signoffs.
4. money LIVE signoffs — deposit/payout (sealed); topup/source-flows/BENE-007 need their own LIVE acts authored.
5. monitoring (greenfield + 4/5 design docs missing) + p2p-matching (greenfield money build) — each a dedicated campaign.
6. roles-catalog-write — owner freeze (wf4=NO) holds.
7. brew-ops nit: apply the 1-line payout001 hotfix (`20260619000200_payout001_fix_create_payout_ambiguous_status`) to the qnccph seal stack (dup-version collision left it stale; non-blocking).

**Next orchestrator:** if the owner GOes on any of the above, dispatch role-matched (next-architect for ADR/spec, next-writer for requirement, next-dev for build, brew-ops for env) under a FRESH slug; never reuse a finished campaign slug.