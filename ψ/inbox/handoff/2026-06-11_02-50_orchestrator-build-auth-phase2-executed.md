---
to: orchestrator-build (next session) + owner + brew-ops + next-tester + next-dev
from: orchestrator-build 2026-06-11 (session 2)
priority: P1
topic: auth Phase-2 (exposure A1-A6 + authdocs W1-W10) EXECUTED — 6 PRs merged, #386 awaits OWNER, wave-2 deployed, strict re-run in flight
project: github.com/kxlahsimx09/mb-next-payment-gateway
tags: [orchestrator, auth-phase2, authexposure, authdocs, sv7b, rls, ratification, owner-gate]
---

# auth Phase-2 executed — gateway @ main `88e9759`

Track 3+4 from `ψ/memory/auth-hardening-2026-06/STATUS.md` (full DONE/PENDING ledger updated there — this handoff is the pointer + owner asks).

## MERGED today (all reviewer-gated by next-code-reviewer, separate agent; self-merge per standing owner GO)
- **#380** A1 §ADR-2 + A2 §ADR-13 (split-by-verb) + W2-W6 — 2 fix rounds: **SV7a** (3 surviving `adminweb_anon_select` policies — anon key could read bank_statements/callback_queue/callback_attempts) + **SV6a** (the role→`:view` grant matrix was ratified NOWHERE; now pinned, composition binding)
- **#383** A5 epic/spec propagation + W7/W8 + **AUTH-008 spec** (AUTH-010 not authored — W9-gated)
- **#384** F2 X2-429 contract-model + 7 A6 exposure probes (de-bias witnesses; tri-state, no fake-green)
- **#385** **A4** split-by-verb RLS migration `20260611000010` + pgTAP 123/123 (EXPLAIN once-per-query proof; seed canonical-only 44 rows)
- **#387** **SV7b** enumeration — 27 RLS-less public tables anon-readable (incl. client.api_key, merchant_config.secret) found by the reviewer during #385; closure rule ratified-posture-riding (authority reasoning on the PR)
- **#388** SV7b stopgap — revoke anon+authenticated SELECT on `client` + `merchant_config` (`20260611000020`)

## ⏳ OWNER ACTION REQUIRED
- **Merge PR #386** — RATIFICATION: W1 F3 catalogue-add CA1-CA7 (+ `admin-users-unlock`→`user:unlock` flip + §ADR-16 `topup:*` correction) + W9 K1 two-slot rotation. Reviewer APPROVE (advisory) on the PR. (#382 auto-closed on stacked-base delete; #386 = byte-identical replacement.)

## Deployed (brew-ops, wave-2): both stacks qnccph + sinuw
Migrations `…0010` + `…0020` applied + spot-checked GREEN (role_permissions=44; client/merchant_config 42501; A4 tables anon→zero; auth-login EF healthy). **NO EFs deployed** — the unlock-EF flip rides #386.

## In flight at handoff time
- **next-tester strict re-run** (A6 7 probes strict + new P8 anon-leg) vs sinuw — PR + evidence to follow; PROBE_M1_A3 stays env-gated (A3 not landed).

## Follow-up queue (pinned, not started — see STATUS.md for owners)
1. **SV7b full-set migration** — `rls_or_no_grants` sweep + REVOKE ALL on all 27 tables (one deliverable) — next-dev
2. **CA2/CA4 EF flips** after #386 merges (reset-2fa, step-up-posture + drop 2 DEPRECATED map grants) — next-dev
3. **A3** gotrue/CF config (m1 password-grant block, m4) — CF leg + X3b transform still custom-domain-blocked (F3)
4. **AUTH-010 spec** post-#386 — next-writer; **PoC twin re-align** — next-impl

## ADDENDUM — wave-3 closed same day (owner merged #386 at `39c64d7`)
- **#392** MERGED — CA2/CA4 EF flips + dropped the 2 DEPRECATED map exceptions (zero old-string enforcement sites).
- **#393** MERGED — AUTH-010 spec (`docs/spec/auth-010-api-key-lifecycle-slice.md`, 5/5 AC bijection vs epic, K1a-K1c faithful).
- **F4 CLOSED** — brew-ops deployed ALL 26 EFs @ `47be8d6` to qnccph + sinuw; `admin-users-unlock` first-ever on qnccph (401 not 404). Canonical strings + canonical-only ROLE_PERMISSIONS live everywhere.
- **CAMPAIGN CLOSED @ main `3ab1c7f`** — carry-forward list lives in STATUS.md §"CAMPAIGN CLOSED" (SV7b full-set next up; A3/F3 domain-blocked; W10 leftover 011/012/009/006; PoC twin; LIVE-gate prereqs).

## Ops learnings this session (Oracle learning `2026-06-11_maw-wake-fleet-restore-cascade` + FLAGS)
- **`maw wake` restores the whole fleet roster** (16+ old windows, resumed claude sessions, froze the machine) — dispatch with plain `tmux new-window` + interactive claude + `send-keys`; never kill tmux windows by index in a loop (renumber shifts mid-loop).
- Long `send-keys` messages can stick as "[Pasted text]" in the composer — verify submission, send a second Enter.
- Stacked-base PRs auto-close when the base merges + branch deletes → retarget impossible on closed PRs; open a replacement PR (the #382→#386 dance).
- The gateway PRIMARY checkout is on `req/bank-bot-integration` (bankbot team WIP) — do not touch its git state; use detached worktrees.
