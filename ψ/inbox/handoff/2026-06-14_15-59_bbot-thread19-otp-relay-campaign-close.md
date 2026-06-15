## Handoff — campaign `bbot` (thread-19 OTP-relay → full bankbot Phase-2 build) · 2026-06-14 GMT+7

**State:** DONE (build) — everything buildable merged. Gateway: **PR #495** (bot lanes BBOT-010/011/012/013) + **PR #496** (fleet FLEET-001..004) MERGED to main, DoD-marked. Bank-bot: **PR #10** MERGED (real getOTP + KTB mock-portal OTP form + SIM OTPService; producer-HMAC verified compatible with the gateway verifier).

**Retro:** `ψ/memory/retrospectives/2026-06/14/16.10_thread19-bbot-otp-relay-build-campaign.md` (full arc + AI Diary + Honest Feedback + 4 lessons).

**OUTSTANDING (user/brew-ops):**
1. 🎯 LIVE SIM run (thread-19 goal / §ADR-21 LIVE gate): brew-ops provisions sim-env `OTP_PRODUCER_KEY/_SECRET` → run realistic-OTP-login end-to-end. Code all merged; only the live run remains.
2. Owner-merge DoD-mark doc PRs: **#497** (bot) + fleet-mark (`campaign/bbotfleetmark` `05e224d`, may need push).
3. Cleanup ~12 `mb-next-*.wt-c-bbot*` worktrees + maw teams (panes retired; preserve uncommitted probes in `wt-c-bbottest` first).

**Key learning:** deploy-env-guard = brew-ops sole deploy owner for ALL stacks (overrides build-workflow "dev self-deploys"); keep `supabase db push`/`functions deploy` OUT of orchestrator dispatch prompts (hook greps the command text).