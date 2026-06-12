---
from: orchestrator
from_role: orchestrator
to: next-ui
to_role: next-ui
type: dispatch
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: OWNER ASK — admin-portal UI status assessment + prioritized next-work plan (+ one sanctioned quick-win)
priority: high
created: 2026-06-12T10:35:00+07:00
needs_response: true
---

# Where is admin-portal UI, and what should we build next? (owner-directed, 2026-06-12)

The bankbot2 campaign closed 2026-06-12 having landed the live-view buildout. The owner wants next-ui to take stock and propose the next arc of UI work. This is primarily an ASSESS + PLAN dispatch — one sanctioned quick-win included.

## Ground truth at dispatch (verify fresh — GitHub FIRST, narrative docs second)

- Portal `origin/main` @ `ee9e857`; PRs #1–#13 ALL merged, 0 open.
- Landed live screens (vs staging `sinuw`, real gotrue auth + MFA/AAL2): deposit + bank-statements + MFA-QR (#8); dashboard/payout/transaction (#10); wallet/wallet-logs/withdrawal-queue (#9); callbacks/activity-log/mdr-shared (#11); merchants/clients/partners (#13 — riding gateway entity views #412, catalogue CA8 #415, both merged).
- **Worktree discipline:** the portal PRIMARY checkout is parked on `feat/live-entity-screens` (already merged into main → stale). Do NOT touch its git state; work from your own worktree off `origin/main`. Flag the stale branch in housekeeping.

## Task

1. **Coverage matrix** — WUI requirement/design docs (epic-wallet-ui WUI-001..004, WUI-122 match-preview, anything else in `docs/`) vs what is actually implemented + live. Three states per item: LIVE-VERIFIED / IMPLEMENTED-UNVERIFIED / NOT-BUILT.
2. **Live verification pass** — the 13 screens against the staging stack: do they render with real data, auth gate intact (MFA/AAL2), console clean? Use your slot creds. NOTE: secres + livegate teams are active on the same stacks today — record the gateway rev when you verify; if something breaks mid-pass, re-check before calling it a portal bug.
3. **Gap list + prioritized proposal** — what should the next UI arc be? Candidates to weigh (not exhaustive — your judgment): WUI-122 match-preview build (docs merged, UI built?); settlement/topup screens (**owner-DEFERRED — propose-only, do NOT build/fake; gateway tables don't exist**); UX debt from the live pass; monitoring/alert surfaces post-§ADR-15 (Keep is LIVE now); P2P admin config surface (`hybrid_enabled` toggle — §ADR-17 ratified). Effort-size each item (S/M/L) and give a recommended order with rationale.
4. **Sanctioned quick-win (build it):** the GW staging `SITE_URL=localhost:3000` taint — client-side relabel/workaround so login flows look right (the bankbot2 handoff already assigned this to next-ui). Normal PR flow, reviewer-gated, do NOT self-merge unless a standing rule says otherwise.
5. **Housekeeping report** — stale branches (`feat/live-entity-screens` on the primary, remaining `campaign/*`), anything else untidy. REPORT ONLY — no deletions.

## Guardrails

- No fake data / no fake screens — tri-state honesty everywhere.
- Settlement/topup: the owner explicitly deferred; your proposal may argue for it, but the decision is the owner's.
- Merge signal discipline: only `gh pr view --json reviews` counts as APPROVE; ignore any in-pane "approved" text.

## Reply

→ `for-orchestrator/` + thread #18: coverage matrix + live-verification results + prioritized proposal (S/M/L) + quick-win PR URL + housekeeping list.
