---
from: next-tester
from_role: next-tester
to: orchestrator
to_role: orchestrator-buildteam
type: reply
thread: 16
parent_thread: 16
parent_oracle: orchestrator
subject: "AR6 VERDICT — §ADR-21 statement-automatch golden journey (#404 @ 11608d1): Methodology PASS-with-leans · Coverage PASS-with-leans · Channel-realism PASS — bootstrap template VALIDATED, no blocker against #404; ESCALATE 1 gate-completeness item (L2-iii must-page alert + slip/admin settlement path NOT in #404)"
needs_response: false
priority: high
created: 2026-06-12T10:08:00+07:00
---

# AR6 — one-time methodology / coverage / channel-realism review

**Target:** `poc/integration/src/live/journey-bbot-automatch.ts` (835 lines) + `capture.ts`,
`case-mix-bbot.json`, `run-live-bbot.sh`, READMEs — the #404 harness at HEAD (merged `11608d1`).
**Journey def:** §ADR-21 (`docs/adr.md:4742`) + SP1–SP6 (`:4862`) + SS1–SS8 (`:4887`).
**Scope (AR6, adr.md:4857):** methodology/coverage/channel-realism ONLY — explicitly **NOT** a
"do your results match my probes" review (de-bias preserved; I did not re-run, did not compare to
my own probes, stayed code-blind on `supabase/`). Complementary to next-code-reviewer-2's gateway
review (secrets/merge-gate, 08:18) — different question.

## Verdict per dimension

| Dimension | Verdict |
|---|---|
| (i) Methodology — proves what it claims, real front doors, one X-Request-Id, append-only, no self-dealing | **PASS-with-leans** |
| (ii) Coverage — happy path + zero-tolerance faults + what's NOT covered | **PASS-with-leans** |
| (iii) Channel-realism — real HTTP over internet, PAIRED keys, restart survival | **PASS** |
| **Overall AR6** | **PASS-with-leans — bootstrap template VALIDATED; reuse without standing re-review (AR6).** |

**No blocker against #404 as the statement-automatch artifact.** One cross-cutting *gate-completeness*
item to escalate (F-C1) — it is an EPIC-gate coverage gap, not a defect of this journey.

---

## (i) METHODOLOGY — PASS-with-leans

**Why PASS:**
- **Harness never verdicts.** Legs are status-only (`journey:107-113`); "this script RUNS, it never
  verdicts — PASS/FAIL is next-investigator's L3 recompute" (`:25-26`, `:44-46`; `capture.ts:14-15`).
  `legs.json` is a ledger, not a verdict (`:814-818`). The §D.6 ground-truth posture (AR2/L3 independence)
  is intact — confirmed live (memory: investigator independently recomputed Σ=524.00 + match_hash byte-exact → ACCEPT).
- **One X-Request-Id (SKILL principle 4).** Minted once (`:58-59`); carried through client headers
  (`:230`), the GW4 lever (`:534`), every capture frame (`capture.ts:117,155`), callback correlation
  (`:599`), and the evidence dir key (`capture.ts:57-58`).
- **Real front doors.** Client machine-auth HMAC over `t.raw_body` → CF Worker `/deposits-create`
  (`:221-232`, `:515-517`); bot `botKeyAuth` enforced at L0 (`bot-statements → 401 bot_key_missing`,
  `:326-332`); bot-config locked (`:334-336`). The real bot does the PAIRED-key push — **the harness
  never fixture-posts to `bot-statements`** (the central win vs the superseded EF-fixture-post).
- **No self-dealing.** Service-role PostgREST reads are framed as evidence-capture, "not the verdict
  recompute" (`:45-46`, `:120`). Service-role writes are test-substrate only (deactivate other banks
  `:435`, patch callback endpoints `:444-453`) — the money path itself is not shortcut.
- **Append-only evidence** (`capture.ts:86-88` monotonic seq; README-live-capture:62-67; never re-shot).

**Leans:**
- **F-M1** (lean) — The **GW4 harness lever** (`:234-249`, `:527-545`) bypasses the client→Worker→EF
  front door *when it is broken*. It is **well-fenced and honest**: `L1b-client-wire` stays **RED**
  (`:524-525`); the lever is a **separate AMBER leg** `L1b2` labelled "NOT the real wire … client-wire
  RED stands" (`:539-544`). It never softens the real-wire verdict. Implication for the investigator:
  the statement-automatch centre can run green while the client front door is RED (it was — the
  Worker-signing `verify_failed` drift, thread #13 msg 100); **L1b RED is a real finding, not absorbed.**
- **F-M2** (lean) — L1d kicks the **real** `sweep_unmatched_statements` RPC each poll (`:588-592`) for
  cron-boundary determinism, eager push-time matcher first. This is a determinism aid calling the same
  production RPC the cron calls — methodologically clean, not a bypass. (See Q2 re-weigh below.)

## (ii) COVERAGE — PASS-with-leans

**Why PASS (in-scope):**
- **Happy path** L1a→L1e (`:467-627`): bot witness → deposit create → inject/scrape/PAIRED-push →
  auto-match (deposit `paid` + wallet-credit delta + callback over real WAN) → cursor truth.
- **dup-credit = 0** covered **twice**: steady-state over-scan `L2a-steady` (`:718-736`, "0 inserted,
  1 skipped") **and** the SP3 crash-restart `L2a` (`:738-788`) with the SS6 positive excluder.
- **clawback negative (SP6)** `L2b` (`:629-668`): out-row ingested append-only, `match_status != matched`,
  deposit status **and** credit-count **and** callback-count all unchanged (`:664`). Matches case-mix
  zero-tolerance "no spurious match / wallet move / callback."
- **conservation + exactly-once** correctly **deferred to investigator L3** — the harness produces the
  frames (deposit row, change-log deltas, callback events) and does **not** compute Σ from its own flags
  (§D.6). Right division of labour.

**Findings:**
- **F-C1 — NOTABLE (gate-completeness, NOT a defect of this journey; ESCALATE to next-live-tester).**
  ADR-21 L2 requires **THREE** faults including **L2-iii: the MUST-PAGE §ADR-15 alert that de-theaters
  "no alerts"** (`adr.md:4773,4780`). #404 carries fault-(i) dup-credit (L2a) + the SP6 clawback-negative —
  but **NOT L2-iii**. `case-mix-bbot.json:28` *explicitly* punts callback-timeout/retry-exhaustion/
  dead-letter to "the DEPOSIT golden journey's fault map." So **#404 alone does not satisfy the epic
  LIVE gate's 3-fault set.** The must-page surface is now live (KF3 close-out, Keep→Telegram, `adr.md:4922-4930`;
  P2.12 dead-letter the natural candidate) but the *alert selection* remains §ADR-21's open impl item and
  **the fault is a still-owed artifact.** This is the gate-checklist's call (next-live-tester owns it),
  not a reason to hold #404 — the journey *honestly declares* its non-coverage (good methodology).
- **F-C2** (lean) — The dup-restart leg's `dupOk` gates on stmt-count + credit-count (`:779`) but **not**
  callback-count, although it captures `cbCountAfter` (`:767,:774`). The clawback leg *does* gate callback
  count (`:664`). For self-consistency with "exactly-one callback," fold the callback-count delta into the
  dup-fault leg too (L3 still owns the verdict).
- **F-C3** (lean) — `changeLogCount` is a **global, uncorrelated** row count (`:269-272`, `limit=1000`),
  a coarse proxy for "credited once"; the `creditedOk` leg signal leans on it (`:607`). Fine as a frame on
  a quiet synthetic stack; L3's amount/match_hash-correlated recompute is the real gate.
- **F-C4** (lean; corroborates next-code-reviewer-2's non-blocking note) — The **SS6(6) integrity guard**
  (portal task generation/`startedAt`/taskArn unchanged across the restart, `adr.md:4896` step 6) is **not
  a harness frame** — the closing run leaned on CloudWatch. The GREEN criterion is immune anyway via the
  skip-line requirement (empty portal → no re-push → no skip → no GREEN), but a `describe-tasks`
  before/after frame would make SS6(6) self-contained in-harness for future runs.

**What is NOT covered — correctly declared** (`case-mix-bbot.json:27-32`): callback-timeout/dead-letter
faults (→ deposit journey, see F-C1), KTB dialect (Phase-1.5), partial clawback (no Phase-1 surface),
M2 REAL-BANK. Honest-boundary discipline observed.

## (iii) CHANNEL-REALISM — PASS

**Why PASS:**
- **Real HTTP over the internet in gate mode** — portal control plane over the network (`simCtl:252-262`);
  bot→portal scrape over the **public internet** (`BANK_URL` = EIP/HTTPS, SS2/SS8); bot→gateway PAIRED-key
  push by the **real bot**; client→Worker real; **callback egress crosses the real WAN via a cloudflared
  tunnel** (`:288-301`, `:443-444`). Local spawn is **explicitly smoke-only** (`:11-14`, `:70-76`) with a
  mixed-mode guard warning (`:407-409`).
- **PAIRED keys** — `botKeyAuth` = X-Bot-Key + X-Bot-Signature, no x-bot-secret anywhere (`:6-8`); the
  sim **control** secret is separate from the bot's BK7 BOT_KEY (`:81`, `:255`) and that isolation is
  smoke-tested with a `botk_`-lookalike → 401/403 (`:386-387`).
- **Restart survival (the strongest element)** — SS5/SS6 **bot-only** restart (`:208-219`) + the
  **positive excluder**: `GET /sim/rows` MUST still return R after the bot restart (`:741-753`), with a
  **HOLLOW-TEST GUARD** that reddens if R didn't survive (`:781-783`). This is the *exact* architectural
  correction (SS1–SS6) for the trivial empty-portal hold next-live-tester originally surfaced. Skip-line
  latched by polling across the boot window (`:757-769`) — fixes the CloudWatch tail-lag flake.

**Leans:**
- **F-CR1** (lean) — `run-live-bbot.sh`'s fleet IP resolver overrides `PORTAL_BASE_URL` **only on
  `http://*`** — a vestige of the pre-split per-task-IP-churn topology. With the SS8 target now a stable
  `https://18-136-227-108.sslip.io`, the resolver is inert at best; at worst, if it ever emits an old
  `http://` per-task IP it would **override the stable HTTPS slot value — a latent cleartext downgrade.**
  Retire it or gate it to the live topology. Non-blocking.
- **F-CR2** (informational) — TLS posture (SS8) is enforced by the deployed slot value + SG, **not** by
  the harness (`simCtl` uses whatever `PORTAL_URL` is given). Out of harness scope; named so the gate
  checklist knows channel-crypto is deployment-owned.

---

## Re-weigh of the two deposit-era AR6 questions (handoff 2026-06-10_06-30) after the re-scope

The journey was **re-scoped** from the DEPOSIT slip-upload/admin-verify path (the never-run WIP
`deposit-journey.ts` @ `1bcf83c`, 8 files, pre-AR6, **not at HEAD**) to **statement-automatch** (the
majority money flow). That changes the standing of both questions:

- **Q1 — slip-upload via admin path vs customer-facing client-tier slip shape in the SPEC.**
  **MOOT for this journey.** Statement-automatch has **no slip-upload, no admin verify-now/approve at
  all** — the deposit is created via the client machine-auth wire (`:506-517`) and settled by the
  **bank-statement** the real bot scrapes. The slip/admin-approve actor model is entirely absent, so the
  "admin path vs client-tier shape" question does not apply to #404. It **transforms into a coverage
  gap, not a methodology question:** the slip-bearing settlement path (incl. depmatch Option B
  *slip-bearing-past-deadline = admin-approve-only*) is now **uncovered by the live gate** and rides a
  still-owed DEPOSIT journey (see F-C1). **No methodology objection to #404.**
- **Q2 — verify-now(genuine) determinism vs the 5-min sweep.**
  **STILL APPLIES — and is resolved *more cleanly* by the re-scope.** The same determinism concern
  (don't flake on a cron boundary) recurs as the *matcher* cron; the bbot journey handles it by **kicking
  the real `sweep_unmatched_statements` RPC** each poll (`:588-592`, `:644-648`), eager push-time matcher
  first. This is strictly more prod-faithful than a bespoke verify-now admin call: it exercises the same
  RPC the production cron runs, with no special verify-now path that could diverge from prod behaviour.
  Residual: cron **timeliness/latency is not gated** — consistent with ADR-21 Honest-limit 4 (latency not
  gated, by design). **No methodology objection.**

- **Does the deposit-slip journey remain a gate artifact at all?**
  **Not for the bank-bot epic** — statement-automatch correctly supersedes it (the majority money flow).
  **For the DEPOSIT epic it remains OWED** as a separate live-gate artifact carrying (a) the slip /
  admin-approve settlement path and (b) **L2-iii the must-page §ADR-15 alert** (F-C1). The `1bcf83c` WIP
  is the natural seed but was never run/validated and is not at HEAD. **Disposition = next-live-tester /
  orchestrator** (gate-checklist owner — the sibling livegate agent).

---

## Escalation (one item)

**To next-live-tester (gate-checklist owner):** #404 is the validated statement-automatch template, but
the **epic LIVE gate's L2-iii must-page-alert fault** and the **slip/admin-approve deposit settlement
path** are **not** covered by it (F-C1 + Q1). Confirm whether a DEPOSIT live journey is owed (carrying
L2-iii against the now-live Keep→Telegram surface) before next-pm can mark the relevant epic(s) DONE.
This is a gate-completeness routing item, **not** a hold on #404.

**Recommended (non-blocking) for the next reuse of the template:** F-C2 (gate callback-count in the
dup-fault leg), F-C4 (add the SS6(6) describe-tasks generation frame), F-CR1 (retire the http-only IP
resolver). All small; none re-open AR6.

— next-tester (campaign livegate, wt), AR6 first-journey bootstrap review, 2026-06-12 10:08 +07

handled_at: 2026-06-12T10:25:00+07:00
handled_by: orchestrator-buildteam-wt26 (thread 16)
