# Campaign `botscrape` CLOSED — bankbot 100% (deposit + withdraw via REAL bot scrape) PROVEN GREEN, 0 RED

**Owner mandate:** make the §ADR-21 live-test exercise the bank seam through the REAL deployed bankbot 100% for BOTH deposit-inbound AND withdraw-outbound — no harness direct-inject; bot↔portal contract identical to current bankbot; may modify mock portal; don't change requirement/ADR. **ACHIEVED.**

## Result (RUN #10 `live-bbot-l4green-1781670593`, BOT_MODE=remote)
**8 GREEN / 2 AMBER / 2 SKIPPED / 0 RED.** GREEN: L0, L1a-bot-witness, L1b-client-wire, **L1c-scrape-push (deposit via real bot scrape)**, **L1d-automatch**, L1e-cursor, **L4-withdraw-realbot (withdraw via real bankbot)**, L2b-clawback. AMBER = the L2a pair (by-design without BOT_RESTART_CMD). NO feedStatement anywhere. L4 chain: bot CLAIMS → maker SUBMITS → approver MATCHES+APPROVES+OTP → portal posts direction='out' → **bot RE-SCRAPES the out-row** → settle=success → payout.success cb=received.

## PRs (OPEN, owner-merge pending — DO NOT MERGE without owner)
- **PR #545** github.com/kxlahsimx09/mb-next-payment-gateway (branch campaign/botscrape, tip 97744a4): live-bbot real-bot withdraw lane (extended journey-bbot-automatch L4) + deposit pool-routing fix + payout callback-seam (merchant-config) fix. Live-harness only (poc/integration/src/live).
- **PR #17** github.com/kxlahsimx09/mb-next-bank-bot (branch campaign/botscrape-withdraw-scrape, tip 54336f3, 7 commits): mock-portal + bot — withdraw out-row + bot re-scrape, persist, SCB maker-submit UI, durable session (HMAC), durable approval queue, file-backed queue read, Dockerfile payout-app.js, /landing/inquiry client-render of the durable todo, /sim/approval-reset. ZERO bot-code change to banks/** ; all fidelity tests green (110→114); SP5 pin-5 (real-bank image has no sim/ bytes) held.

## The withdraw approver chain drilled through 7 deployed-only layers (each precisely diagnosed + fixed, no direct-inject, contract preserved)
CORS (pre-campaign) → in-memory session wiped on restart (durable HMAC session) → approval-queue not durable (approvals.jsonl) → cross-worker stale read (list() re-reads file) → FIFO-head stale-task block (brew-ops clear + /sim/approval-reset) → approver client-side read empty (/landing/inquiry serves durable queue + page client-renders it) → payout.success callback not firing (harness merchant-config wiring).

## Who did what
- **next-dev** (mb-next-bank-bot): all mock-portal + bot fixes above (PR #17). Mode-blind, contract-faithful, fidelity green throughout.
- **next-live-tester** (gateway poc/integration): the L4 withdraw lane + deposit pool-routing + callback-seam (PR #545); ran 10 gated journeys; diagnosed every layer with SSM/CloudWatch/DB proof; refused direct-inject.
- **brew-ops** (infra): built/rebuilt SIM images, redeployed SCB+KTB portals + bots from each commit, ran the payout-app.js ECS loop (mb-next-bankbot-payout, DRY_RUN=false), Caddy /sim ACL (added run-host egress 3.1.0.33), aligned SIM_CONTROL_SECRET, cloudflared (earlier liveinfra).
- **orchestrator** (me): dispatched/chained the team (fresh slug botscrape, no reuse), routed every bounce, escalated the SCB-vs-KTB + scope forks to owner, closed each idle teammate to free quota.

## OUTSTANDING follow-ups (owner-deferred, tracked — not blocking)
- **SIM session-fidelity hardening** (owner chose follow-up): mock uses ONE user (simviewer) + never-expires sessions; real SCB = 3 distinct users (viewer/maker/approver) + single-session-per-user; real KTB needs keepSessionAlive (mb-next has the method banks/ktb/index.js:232-312 but never calls it — current calls it every 30s app.js:1862/2155) — wire it + KTB mock session timeout. SCB login MODES/flow/loginIfNeeded-reuse are already byte-identical to current — no gap there. Do as one pass after merge.
- The L4 out-row carries match_hash ∅ / linked-to-payout=false (informational — leg GREEN via callback+settle; the outbound statement→payout reconcile-link is a separate gateway concern, not exercised by this leg's bar).
- Earlier sibling campaign `liverun` (§ADR-21 portal-UI) already MERGED (PR #538); its Path-A portal-EF-wiring was routed to orchestrator/bui (handoff 2026-06-16_19-00).
