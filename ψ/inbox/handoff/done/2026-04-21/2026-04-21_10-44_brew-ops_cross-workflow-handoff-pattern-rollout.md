---
to: brew-ops
from: brew-ops (2026-04-21 morning session, context-near-full)
severity: P1
source-workflow: workflow-5-memory-audit (Step 17 trigger pattern dogfood)
related-thread-ids: []
related-trace-ids: []
related-pr: https://github.com/kokarat/bank-bot/pull/90
created: 2026-04-21T10:44+07:00
---

## Symptom

The cross-workflow handoff escalation pattern was just added to workflow-5 §B (mb_agent_oracle_memory commit `242eb14`, 2026-04-21 morning) but **none of the other workflows (W2/W4/W8/W9/thread-resolve/tester W1) point to it**. Author of any non-W5 workflow that hits a memory/search/trace anomaly today still has no breadcrumb to "file a handoff at ψ/inbox/handoff/...". The escalation channel exists but is undiscoverable from the calling side.

This handoff itself is the **first dogfood of the new escalation pattern** — current session is at context-near-full, so closes the loop by producing the handoff that the next session will execute.

## What was tried (current session, complete)

The 2026-04-21 brew-ops session did substantial spec evolution:

**Spec changes already landed (mb_agent_oracle_memory main, all pushed):**

- `f0b51e5` — W9 Step 4b (section-level marker reconciliation, sibling-synced both repos)
- `6370550` — workflow-thread-resolve closing-message rule (sibling-synced)
- `1e27b2f` — tester W1 Step 8 retro path discipline + §The ψ/ trap section
- `065e3ab` — tester W1 Step 7 split (detect→amend / new)
- `9da4c55` — workflow-5 Step 13c (cross-repo orphan-marker sweep)
- `242eb14` — workflow-5 §Trigger + §Step 17 Telegram report + DoD updates ← this handoff exercises §Trigger.B

**Code changes (arra-oracle-v3 fork branch `feat/all-prs-rebased-2026-04-20`, all pushed to `kxlahsimx09/arra-oracle-v3`):**

- `aa4d681` — arra_learn KNOWN_PROJECTS typo guard + Levenshtein suggestion
- `005d709` — gitignore .mcp.json (project-scope MCP safety)

**External:**
- bank-bot PR #90 — orphan strip for `[AWAITING_THREAD:16]` markers in `docs/flows/ktb-single-transfer-withdrawal.md` (4 locations) — awaiting human review/merge
- New MCP `brew-ops-telegram` registered locally (token in `~/.claude.json`, bot identity `brew_ops_alert_bot`, chat_id `2002026175` — separate from writer-fleet `telegram` MCP)

**Audit findings that motivated this handoff:**

```
- Existing handoff infrastructure: ψ/inbox/handoff/ exists with 8 closed entries
  (free-form markdown, no frontmatter — different convention from new structured
  format I introduced for brew-ops escalations)
- ψ/inbox/handoff/done/ subdir does NOT exist (spec says move to done/<YYYY-MM-DD>/
  after processing — needs creating before first real handoff is processed)
- 0 workflows mention escalation to brew-ops via ψ/inbox/handoff path
- 0 workflows mention "escalate to brew-ops" pattern at all
- "brew-ops" string appears in workflows but only as metadata (changelog signatures,
  not call-to-action)
```

## Evidence

- Spec: `mb_agent_oracle_memory/github.com/Soul-Brews-Studio/arra-oracle-v3/.agent/skills/brew-ops/references/workflow-5-memory-audit.md` §How this workflow gets triggered (especially §B "Escalated handoff from another workflow")
- Audit grep results (the 5-step audit run earlier this session):
  - W2 mobiz/bank-bot: 3 brew-ops mentions, 0 handoff-path, 0 escalate-brew
  - W8 mobiz/bank-bot: 1-3 brew-ops mentions, 0/0
  - W9 mobiz/bank-bot: 4-5 brew-ops mentions, 0/0
  - workflow-thread-resolve mobiz/bank-bot: 1 brew-ops, 0/0
  - tester W1 (mobiz only): not checked but assumed 0/0
- Existing handoff sample (free-form, pre-pattern): `ψ/inbox/handoff/closed/2026-04-18/2026-04-16_16-33_test-a-payout-confirm-completed-pr179-opened.md`

## Expected outcome

Three concrete deliverables:

### Deliverable 1 — Create `ψ/inbox/handoff/done/.gitkeep`

Spec says brew-ops moves processed handoffs to `done/<YYYY-MM-DD>/` after picking up. Directory must exist before that's possible.

```bash
mkdir -p ~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory/ψ/inbox/handoff/done
touch ~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory/ψ/inbox/handoff/done/.gitkeep
```

### Deliverable 2 — Add "Memory/search/trace anomaly → brew-ops handoff" pointer to each workflow's §Escalation section

10 sibling-synced edits + 1 single-copy edit + 1 workflow-5 clarification = 12 file edits.

Files (all in `mb_agent_oracle_memory/github.com/kokarat/{mobiz-payment-gateway,bank-bot}/.agent/skills/technical-writer/references/`):

- `workflow-2-track-commit.md` (mobiz + bank-bot)
- `workflow-4-reconcile-drift.md` (mobiz + bank-bot)
- `workflow-8-flow-map.md` (mobiz + bank-bot)
- `workflow-9-track-flows.md` (mobiz + bank-bot)
- `workflow-thread-resolve.md` (mobiz + bank-bot)
- `tester/references/workflow-1-validate-integration-tests.md` (mobiz only — bank-bot has no tester role)

Plus workflow-5 clarification (Deliverable 3 below).

**Edit template** — add a new sub-section in each workflow's `## Escalation` (or `## Escalation matrix`) section. Sibling-sync verbatim modulo project-name:

```markdown
### Memory/search/trace anomalies — escalate to brew-ops

If your pass encounters one of these patterns and cannot resolve it in scope:

| Symptom | Likely cause |
|---|---|
| `arra_search` returned 0 for content you know exists | possible FTS5 / vector / tokenizer drift |
| `arra_learn` succeeded but search can't find the new entry | possible indexer / vector connect race |
| `arra_trace` succeeded but `arra_trace_get` returns missing fields | possible trace tool bug (e.g., 2026-04-21 trace project-corrupt incident) |
| `arra_supersede` says success but old doc still appears un-flagged | possible supersede chain breakage |
| Closed thread leaves `[AWAITING_THREAD:N]` markers stranded across repos | cross-repo orphan — see workflow-5 §13c |
| `verify.sh` fails with new pattern not covered by existing fixes | possible new corruption class |
| Path-typo files (`bank-bot<`, `pure-bot`, etc.) keep recurring | input-validation gap |

Don't try to debug in-pass. File a handoff at:

```
$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/ψ/inbox/handoff/<YYYY-MM-DD>_<HH-MM>_brew-ops_<topic>.md
```

Format per `arra-oracle-v3/.agent/skills/brew-ops/references/workflow-5-memory-audit.md` §How this workflow gets triggered → §B (Escalated handoff). brew-ops will pick up next session via fresh wake (`maw wake brew-ops --fresh "..."`).

If unsure whether to escalate: file a P2 handoff with `expected outcome: investigation only`. brew-ops can downgrade to "no action needed" cheaply; a missed real signal is more expensive.
```

**Important — placement within each workflow's existing structure:**
- W2/W8/W9 already have `## Escalation` sections — add as new sub-section at the END, before the `---` separator.
- W4 (`reconcile-drift`) has `## Escalation` similar.
- workflow-thread-resolve has `## Anti-patterns` — add the new sub-section AFTER that, before `## Change log`.
- tester W1 has `## Common pitfalls this workflow has hit before` — add the new sub-section AFTER that, before the `**Created:** / **Revised:**` footer.

### Deliverable 3 — Clarify in workflow-5 §B that the structured frontmatter format is brew-ops-specific

Existing handoffs in `ψ/inbox/handoff/closed/` are free-form markdown with no frontmatter — a different convention used for agent-to-agent project status updates (e.g., "PR #179 opened, here's context"). The structured format I added to workflow-5 §B is **specifically for `to: brew-ops` escalations**.

Add a clarifying paragraph in workflow-5 §B (after the frontmatter spec, before "To trigger brew-ops to pick up the handoff"):

```markdown
**Format scope clarification**: this structured frontmatter format is for `to: brew-ops` escalations specifically. Pre-existing handoffs in `ψ/inbox/handoff/closed/` use a free-form markdown convention (agent-to-agent project status updates, e.g., "PR opened, here's context") — that convention remains valid for non-brew-ops handoffs. brew-ops handoffs MUST use the structured frontmatter so the fresh-wake claude can parse trigger context, severity, and scope hints reliably.
```

## Scope hint (for next session)

Direct workflow-5 §13c (cross-repo orphan markers) is NOT triggered by this handoff — this is a procedural change, not a memory-anomaly investigation. Skip §1-§14 of the audit; jump straight to the deliverables above.

The next session should:

1. Read this handoff in full
2. Execute Deliverables 1, 2, 3 in order
3. Sibling-sync verification: each pair (W2 mobiz vs W2 bank-bot, etc.) must have IDENTICAL escalation table content modulo whatever's already different in the file (e.g., territory examples)
4. Single commit per logical group: 1 commit for the 10 sibling-synced edits (theme: "propagate brew-ops escalation pointer to writer/thread-resolve workflows"), 1 commit for tester W1, 1 commit for workflow-5 clarification + done/.gitkeep dir
5. Push mb_agent_oracle_memory main
6. Move THIS handoff to `ψ/inbox/handoff/done/2026-04-21/` (per workflow-5 §B post-processing rule)
7. Send Telegram report via `mcp__brew-ops-telegram__telegram_send` (Step 17) — first real Telegram dogfood

## Telegram template suggestion (for the Step 17 send after this handoff is processed)

```html
<b>🔔 Oracle Audit — {YYYY-MM-DD HH:MM} GMT+7</b>
trigger: handoff #2026-04-21_10-44_brew-ops_cross-workflow-handoff-pattern-rollout

<b>สรุป</b>
✅ ทำตาม handoff ครบ 3 deliverables
- ψ/inbox/handoff/done/ subdir created
- 11 workflow files ได้ "escalate to brew-ops" pointer แล้ว (sibling-synced)
- workflow-5 §B clarified: structured format = brew-ops escalations only

<b>ผลกระทบ</b>
ตอนนี้ทุก writer/tester ที่เจอ memory/search/trace anomaly จะรู้ทางเขียน handoff
มา brew-ops แล้ว — ไม่ต้องเดา ไม่ต้องเงียบ

📝 รายละเอียด: <code>{retro filename}</code>
```

## Open follow-ups beyond this handoff scope (next-next session)

These are flagged for visibility, NOT for the next session to do:

- **(closing-message rule for tester W1)** — tester rarely closes threads, so closing-message rule from workflow-thread-resolve is low-priority for tester W1 propagation. Defer.
- **(populate §Change log of tester W1 properly)** — currently uses `**Revised:**` footer entries; could promote to a real `## Change log` section matching W2/W4/W8/W9 convention. Cosmetic, not load-bearing.
- **(Phase 2 — Option D trace-anchor edges)** — wait for workflow-5 §13c (Phase 1) to surface recurring orphan patterns before investing in trace infrastructure.
- **(Watcher integration of W5 / tester W1)** — currently only W2 + W9 chained in watcher. W5 daily cron via launchd is the §Trigger.C path; not yet implemented.

## References

- Session retrospective: `~/.arra-oracle-v2/ψ/memory/retrospectives/2026-04/21/08.55_brew-ops-marathon-w2-w9-spec-evolution-memory-audit-watcher-extension.md` (covers the morning's work up to ~08:55; the afternoon's W5 evolution + this handoff is in next retro)
- W5 §B (the spec this handoff exercises): `mb_agent_oracle_memory/github.com/Soul-Brews-Studio/arra-oracle-v3/.agent/skills/brew-ops/references/workflow-5-memory-audit.md` (commit `242eb14`)
- bank-bot PR #90 (the orphan-strip companion): https://github.com/kokarat/bank-bot/pull/90
