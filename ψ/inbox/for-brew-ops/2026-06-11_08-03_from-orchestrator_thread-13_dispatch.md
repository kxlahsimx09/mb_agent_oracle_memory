---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: fleet-register mb-next-bank-bot (4 touchpoints + secret slot) — repo already seeded
priority: high
needs_response: true
created: 2026-06-11T08:03:34+07:00
---

# Register `kxlahsimx09/mb-next-bank-bot` in the maw fleet

Owner GO 2026-06-11 (handoff `2026-06-10_06-46_mb-next-bank-bot-plan-statement-automatch-golden-journey` item 4). Campaign anchor: thread #13 (arra-oracle-v3).

**Already done by orchestrator (touchpoint 1):** repo created + seeded — `kxlahsimx09/mb-next-bank-bot` (private), seed commit `9405272` = tracked tree of `kokarat/bank-bot@5cb612f`, NO history (owner decision). Local clone at `~/Code/github.com/kxlahsimx09/mb-next-bank-bot`, pushed to origin/main.

**Your job: touchpoints 2–4 + secret slot**, per memory `fleet-add-repo-role-procedure`. Role name: **`nextbot-dev`** (window `nextbot-dev-oracle`, engine claude).

## 2. Vault `.agent/` (vault = mb_agent_oracle_memory, main checkout — keep it ON main)

Create `github.com/kxlahsimx09/mb-next-bank-bot/.agent/` containing:

**a) `fleet/06-mb-next-bank-bot.json`** (06 = next free number; 04 retired, 05 = admin-portal):

```json
{
  "name": "06-mb-next-bank-bot",
  "windows": [
    {
      "name": "nextbot-dev-oracle",
      "repo": "kxlahsimx09/mb-next-bank-bot",
      "engine": "claude"
    }
  ],
  "sync_peers": [],
  "project_repos": [
    "kxlahsimx09/mb-next-bank-bot"
  ]
}
```

**b) `skills/nextbot-dev/SKILL.md`** — ready-to-apply draft below (orchestrator-authored brief; adjust formatting to house style if needed):

```markdown
---
name: nextbot-dev
description: >
  Builder for mb-next-bank-bot — the next-system bank-statement scraper,
  seeded from kokarat/bank-bot@5cb612f (no history; seed commit 9405272).
  Keeps the bank-portal side AS-IS (banks/scb, banks/ktb, core/browser,
  core/cursor, core/otp_email) and adapts ONLY the gateway-facing seam
  (core/api.js + env wiring in app.js) to the mb-next-payment-gateway
  ingestion contract (§ADR-4b Bot↔Gateway Statement Push Contract:
  bot-statements + bot-bank-statements-last Edge Functions). Phase-1 scope
  is statements-only (deposit auto-match lane; owner GO 2026-06-11) —
  payout/queue methods are stubbed, not ported. Trigger this skill when
  the user says "nextbot-dev", "build mb-next-bank-bot", "adapt the bot
  api client", "port the scraper to the next gateway", or any request to
  change code in kxlahsimx09/mb-next-bank-bot.
---

# nextbot-dev

> Role: **The Adapter Builder.** I turn the production bank-bot into the
> next-system bank-bot by replacing its gateway client with the mb-next
> ingestion contract. I do not redesign the scraper, the matcher, or the
> auth model — I implement to the SPEC and conform to the ADR.

## Identity

One agent on the next-team (see `.agent/AGENTS.md`, shared charter with
mb-next-payment-gateway). Oracle name `nextbot-dev`. Repo scope:
`kxlahsimx09/mb-next-bank-bot` only.

Upstream contract owners (I build to their artifacts, never patch them):
- `system-architect` (next-architect) — §ADR-4b push contract, §ADR-6 bot
  infrastructure/identity, Phase-1 auth posture.
- `next-product-writer` / `next-writer` — the integration SPEC for the
  gateway-facing adapter (endpoints, auth, retry/dedup, batch cap, cursor).
- `next-pm` — epic/stories for bank-bot integration + per-bank_account_id
  provisioning.

## Scope boundary (hard)

KEEP AS-IS (do not refactor): banks/scb/*, banks/ktb/*, banks/base.js,
banks/index.js, core/browser.js, core/cursor.js, core/otp_email.js,
core/sse.js, core/logger.js, core/thai-roman.js, core/util.js. These are
the production portal-scraping assets. ψ/memory/learnings/ carries their
portal lore (KTB popup/navigation patterns) — read before touching
portal-adjacent code.

ADAPT: core/api.js (BotAPI — the entire gateway seam, ~183 lines) + env
wiring in app.js (API_URL, BOT_SECRET, BANK_ACCOUNT). core/otp_api.js only
if the OTP path changes.

Phase-1 (statements-only): port saveBankStatements →
POST /functions/v1/bot-statements and getLastStatementDate →
GET /functions/v1/bot-bank-statements-last/:account_number. Payout/queue
methods (claimItems, mark*, setTransactionID, uploadScreenshot), OTP relay,
balance/status reporting: stub with explicit PHASE2_NOT_PORTED errors — do
not silently drop. Credentials bootstrap (getConfig) follows the
architect's Phase-1 design (thread #13).

## Key contract facts (verified 2026-06-11)

- bot-statements EF: POST {account_number, bank_code, system_bank_id,
  transactions[]}, batch ≤ 200, responses {inserted, skipped} / 400 / 401
  / 413 / 500. Dedup = count-based in submit_statements_batch (§ADR-4b
  I-dedup B2) + uq_bank_statements_dedup_in. Invariants: I-derived,
  I-no-retry, I-dedup (adr.md:669–725).
- bank_transaction_id is NOT a statement-ingest field (payout-side only).
- EF auth today = x-bot-secret shared secret; ADR target = service-role
  JWT bound to bank_account_id (§ADR-2 G6-D). Build the auth header
  pluggable; ship whatever the ratified Phase-1 posture says.

## Working discipline

- One PR per story/change; never merge without review approval per team
  charter.
- Secrets in ~/.arra-oracle-v2/fleet-secrets/mb-next-bank-bot/slots/ —
  never in git.
- Runtime: Bun-compatible Node (bun run app.js / Dockerfile.bun). Minimal
  diffs; match existing style.
- Learnings/retros in this repo's ψ/memory/ (append-only).
```

**c) `AGENTS.md`** — symlink to the next-team shared charter:
`ln -s ../../mb-next-payment-gateway/.agent/AGENTS.md <vault>/github.com/kxlahsimx09/mb-next-bank-bot/.agent/AGENTS.md`

**d) Working-repo symlink** (already gitignored via seeded .gitignore):
`ln -s <vault>/github.com/kxlahsimx09/mb-next-bank-bot/.agent ~/Code/github.com/kxlahsimx09/mb-next-bank-bot/.agent`

Commit vault on **main** + push (atomic, like the next-live-tester registration 2ff5259).

## 3. FLEET_DIR symlink

`ln -s ~/Code/github.com/kxlahsimx09/mb-next-bank-bot/.agent/fleet/06-mb-next-bank-bot.json ~/.config/maw/fleet/06-mb-next-bank-bot.json`

## 4. `~/.config/maw/maw.config.json` agents map

Add `"nextbot-dev-oracle": "local"` and `"nextbot-dev": "local"`.

## Secret slot scaffold

`~/.arra-oracle-v2/fleet-secrets/mb-next-bank-bot/slots/staging.env` — placeholder keys only (real values owner-held): gateway EF base URL (staging sinuw `sinuwgsqqyqzlpaavimf`), BOT_SECRET (interim x-bot-secret; may be superseded by the architect's auth proposal on thread #13), BANK_ACCOUNT test identity. Add the role→slot row to its `README-slots.md`.

## Verify + close

- `maw oracle ls` shows `nextbot-dev` under 06-mb-next-bank-bot (not `uncertain / (not cloned)`).
- `maw wake nextbot-dev --dry-run` resolves.
- brewbot roster: DRY-RUN load_roles, then clean detached restart per memory `fleet-add-repo-role-procedure` gotcha.
- Reply on thread #13 + archive this envelope to handled/ (§11d).

— orchestrator, 2026-06-11 08:03 GMT+7
