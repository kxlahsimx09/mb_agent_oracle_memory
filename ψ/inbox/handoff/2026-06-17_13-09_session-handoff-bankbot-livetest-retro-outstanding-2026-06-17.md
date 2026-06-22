# SESSION HANDOFF + COMBINED RETRO — §ADR-21 bankbot live-test (orchestrator session 2026-06-16→17)

## What shipped this session (3 campaigns)
1. **liverun** — §ADR-21 portal-UI live test (DEPOSIT admin actions via real admin-portal UI), 43G/8A/0R → **PR #538 MERGED to main**. Path-A portal-EF-wiring routed to orchestrator/bui (handoff 2026-06-16_19-00).
2. **botscrape** — bankbot 100%: deposit + withdraw via REAL bot scrape, **PROVEN GREEN 8G/2A/0R** (RUN #10). NO direct-inject; bot↔portal contract unchanged. → PR #545 (gateway harness) + PR #17 (bank-bot).
3. **simreset** — control-plane POST /sim/reset (clears statements+approvals) wired into the harness clean step so every run starts clean; persistence kept. → PR #18 (bank-bot) + PR #550 (gateway).

## OUTSTANDING (owner action)
- **4 PRs OPEN, owner-merge pending (stacked: withdraw → reset):** bank-bot #17→#18 ; gateway #545→#550.
- **Follow-up #10 — SIM session-fidelity hardening** (owner-deferred): SCB 3 distinct users + single-session-per-user + session timeout; KTB keepalive (mb-next has banks/ktb/index.js:232-312 but never CALLS it; current calls it every 30s app.js:1862/2155) + KTB mock timeout. SCB login MODES/flow/loginIfNeeded-reuse already byte-identical to current — no gap there.
- Informational: L4 out-row carries match_hash ∅ / linked-to-payout=false (leg GREEN via callback+settle; the outbound-statement→payout reconcile-link is a separate gateway concern).

## COMBINED RETRO (next-dev + next-live-tester + brew-ops — all 3 converge)

### The one root cause: deployed-only bugs invisible to local tests
The SCB withdraw maker→approver chain drilled through **~7 deployed-only layers** (CORS → in-memory session wiped on restart → non-durable approval queue → cross-worker stale file read → FIFO-head stale-task → approver page client-renders empty queue at tick-login timing → payout.success callback not wired). EVERY layer was invisible until the one above it was fixed + redeployed. next-dev's fidelity suite stayed green (110→114) and the bot code never changed — **"ran the RIGHT code through the WRONG substrate."** Local = clean in-memory store, single process, createPortal() factory, fresh session, goto-after-submit. Deployed = restart durability, real node server.js bootstrap, multi-worker shared-disk, SPA client-render + tick-login timing, long-lived bot session, packaging. The local suite STRUCTURALLY cannot catch a single one.

### The feedback loop: slow, serial, idle-heavy
One full cycle ≈ **25–45 min** (live-tester run ~12 min + dev fix + brew-ops full image-rebuild & ECS+SSM redeploy ~5–15 min + re-run ~12 min). The withdraw lane = ~7 of these. Chain is strictly serial (live-tester verify → next-dev fix → brew-ops redeploy → live-tester re-run) — 4 hand-offs, each a context switch + wait. Every agent **sat IDLE between bounces**; brew-ops + dev were **torn down to free quota and re-dispatched FRESH each cycle, losing warm context**. Env drag stacked on top: Anthropic API 500/529 overload, chromium version mismatch on fresh installs, egress-ACL block (manual per run-host), stale-task accumulation (no up-front reset → phantom-failure cycles), brew-ops's dpay-MCP = legacy Mongo (couldn't verify the next-gateway Supabase → every cycle ended in a hand-off, never self-serve green). Note: GH Actions image build was ~90s — NOT the bottleneck; the cost was hand-assembly + cross-agent serialization + no fast local inner loop.

### Top process improvements (ranked, cross-agent consensus)
1. **A deployed-mirror local test** — real node server.js + SIM_DATA_FILE + ≥2 workers sharing the volume + a restart between maker-submit and approver-read + a stubbed bot at the real tick-login timing (goto at tick START). All ~7 deployed-only layers would have surfaced in ONE local pass. Gate redeploy on "deployed-shape green," not "clean-store green." (dev #1+#2, live-tester #2)
2. **Fast leg-only sub-journey** — a withdraw-ONLY remote entrypoint (skip deposit/auth/bbot) turns each L4 re-run from ~12 min → ~2 min and sharpens the signal. (live-tester #1)
3. **One-command idempotent redeploy.sh <commit>** (whole chain → single GREEN/RED) + **dev self-serve redeploy** so deploy isn't a per-cycle human bottleneck; kills the hand-assembly + shell-measurement-artifact false alarms (brew-ops chased a SIM_CONTROL_SECRET "divergence" ghost = a heredoc-quoting artifact). (brew-ops #1+#3, dev #3)
4. **Keep the SIM stack persistently up + stop tearing down/re-dispatching agents per cycle** (warm context; the stack was healthy idle between runs — it was the AGENTS being respawned). (brew-ops #2)
5. **Read access to the deployed state at diagnosis time** — SSM/logs for dev, Supabase for brew-ops — so diagnosis/verification isn't always a hand-off. (dev #4, brew-ops #4)
6. **Day-1 hygiene**: /sim reset from the start (state accumulation bit us reactively); a short "deployed runtime contract" doc for the bot (tick-login timing, /landing/inquiry shape `json.data.toDoList.data.sections[0].tasks[]`, session lifetime); batch multiple suspected fixes per redeploy; auto-attach the journey log + host state on every bounce. (dev #5+#6, live-tester, brew-ops)

### One-line lesson (all three agreed)
"Clean-store single-process GREEN is a CONTRACT test, not a DEPLOYMENT test. For a stateful service behind redeploy + multi-worker + SPA + a long-lived client, the test substrate must match the deploy substrate — or every state bug ships and bounces."

## Who changed what (system-wide)
- next-dev → mb-next-bank-bot (mock portal + bot): all SIM fixes, ZERO banks/** (bot contract) change, fidelity green throughout.
- next-live-tester → gateway poc/integration: L4 withdraw lane, deposit pool-routing, callback-seam, /sim/reset wiring; 11 gated journeys; diagnosed every layer with SSM/CloudWatch/DB; refused direct-inject.
- brew-ops → AWS infra: all SIM-stack deploys, payout ECS loop, Caddy ACL, secrets, cloudflared.
- orchestrator → dispatch/route/escalate/close; fresh slug per campaign, no reuse; closed idle agents to free quota.
