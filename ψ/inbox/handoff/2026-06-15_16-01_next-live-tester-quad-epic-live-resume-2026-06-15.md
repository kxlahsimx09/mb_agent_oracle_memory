# Handoff — next-live-tester · §ADR-21 quad-epic LIVE journey (2026-06-15, end of session)

**Repo:** github.com/kxlahsimx09/mb-next-payment-gateway · **branch:** `agents/8-3epic-live`

## One-line state
Doc + harness are COMPLETE and all infra is DEPLOYED to staging. **The §ADR-21 LIVE gate has NEVER been RUN — that is the single next step.**

## Done
- **Design doc** `docs/requirements/live-test-journey.md` (renders on the Nextra doc-site as "LIVE Test Journey", alongside the requirement pages) — quad-epic (AUTH/BANK-BOT/DEPOSIT/PAYOUT), one unified multi-tenant journey, 4 `live_signoff` rows; covers 13 DEP + 12 AUTH + 11 PAYOUT + 13 BBOT + cross-cutting. Current with the deployed surface.
- **Harness** (campaign "olive", `poc/integration/src/live/`): `journey-tri-epic.ts` runs all 4 acts + `act-{auth,bbot,deposit,payout}.ts` + `clean-state.ts` + `fixture-cast/users.ts` + `bot-driver.ts` (+10 EF wrappers). Bundle-clean. Launcher `run-live-tri-epic.sh`.
- **Deployed (staging `mb-next-staging` / sinuw):** AUTH-010 admin (`admin-clients-*`) + client self-service (`client-self-*`) + AUTH-011 (`admin-users-set-role`) — #518/#519/#522 + #523 verify_jwt fix (51/51 EFs ACTIVE). SIM bot + mock portal on AWS ECS (slot carries PORTAL_BASE_URL/SIM_CONTROL_SECRET/BOT_*; `build-push-ecr` green; prior bbot LIVE runs L3 PASS in `evidence/live/bbot/`).
- Merged PRs: #491/502/509/510/513/515/516/517/520/522/523. **OPEN: #521** (AUTH-010/011 S→L doc flip, MERGEABLE — owner-merge).
- Honest-limits: only **AUTH-007 step-up** stays `S` (no deployed gate — payout correct/reverse explicitly NOT step-up per §ADR-2 S2 carve-out). §11 = structural SIM-scope limits (not deploy-status); buckets A=permanent-while-SIM, B=closes at M2/LIVE-run, C=closes by building the named leg.

## Next (resume here)
1. `cd poc/integration && bun install` (node_modules absent — pulls playwright).
2. **DRY-VALIDATE:** `./run-live-tri-epic.sh` (no GO flags, no `LIVE_DEDICATED_STACK` → append mode, no wipe) → L0 + provision + opening balances, STOP. First real execution; confirms ECS bot/portal up.
3. **Gated run:** `OWNER_GO_LIVE_ALL=1 ./run-live-tri-epic.sh` (+ `LIVE_DEDICATED_STACK=1` ONLY on a dedicated stack — global `reset_runtime_state` wipe).
4. **Verdict chain (other roles):** next-investigator **L3** recomputes the 4 invariants from raw tables (the PASS/FAIL; runner ≠ grader) → owner **L5** writes the 4 `live_signoff` ACCEPT rows. G2 DONE = seal AND signoff.

## Lessons (load-bearing)
- **Re-verify "not built / pending" claims against the OTHER repo's PRs + `config.toml` before editing the doc.** This session caught (and corrected) stale bbot "not built", AUTH-010 admin-only-vs-client, and the `client-self` config.toml deploy gap — only because of grounding; the team then closed the gap (#523).
- **Honest-limits ≠ deploy-status.** Deploying EFs removes a transient `S`-pending note, not a structural §11 limit.
- **`agents/8-3epic-live` is reused and the owner merges PRs mid-work → every new push needs a NEW PR** (PRs kept stacking behind merged ones / conflicting).
- Money unit = baht `numeric(18,2)`. `reset_runtime_state` = global `WHERE true` wipe (keeps config + audit_log), gated on `LIVE_DEDICATED_STACK=1`. `bot-driver.ts` = bot-auth helper (BK7 HMAC `x-bot-key`/`x-bot-signature` over `${t}.${rawBody}`; OTP read = no-body GET canonical `${t}.GET.<path>`; OTP write = producer plane `x-otp-key`).

Full detail in project memory `tri-epic-live-journey-design.md` (RESUME POINT block at top).
