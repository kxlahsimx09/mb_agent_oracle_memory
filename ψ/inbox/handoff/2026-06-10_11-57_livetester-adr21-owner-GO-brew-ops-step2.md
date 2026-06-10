மHANDOFF → brew-ops — `next-live-tester` 6th role: owner GO given, Artifact A+B landed; your Step 2 (C+D+registration) is unblocked

**From:** next-architect · **Date:** 2026-06-10 GMT+7 · **Status:** §ADR-21 §Amendment 2026-06-10 is `#decision` (owner GO 2026-06-10). The gate (sequencing step 1) is **cleared.**

## What landed this pass (gateway repo — PR #366, NOT merged)
- **Artifact A** — `docs/adr.md`: `##### Amendment 2026-06-10` under §ADR-21 (AR1–AR7 + Registration + Revisit trigger), ratified `#decision`. Header lists the amendment; newest-first revision-log entry added.
- **Artifact B** — `docs/build-workflow.md`: `## Step 3a — LIVE gate` + at-a-glance `GATE LIVE` row.
- Branch `campaign/livetester-adr21`; PR https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/366 (owner merges, §9).

## AR3 — the owner's confirmed "why now" (the one judgement call the handoff flagged)
The `[OWNER RATIONALE — CONFIRM]` placeholder is **resolved.** Owner direction 2026-06-10 confirmed the reversal stands on **two operational benefits** (NOT an independence gain — A0's "zero independence gain" finding is affirmed):
1. **Credential isolation** — `next-live-tester` holds its OWN LIVE/staging secret slot; LIVE-mode-stack creds never co-reside in `next-tester`'s slot (§3b/§11a).
2. **Dedicated ownership of the live-journey** — one role authors+runs+records the per-epic journey end-to-end.

The candidate "avoids overloading next-tester as the fleet scales" was **dropped** — owner did not select it. Do not cite it.

## Your Step 2 (memory repo `mb_agent_oracle_memory`) — now unblocked
1. **Artifact D** — move the held-out SKILL from `brew-ops_next-live-tester_DRAFT-SKILL.md` into `.agent/skills/next-live-tester/SKILL.md`.
2. **Register the role** — the standard 4-touchpoint add + LIVE secret slot: clone/vault `.agent` symlink + `~/.config/maw/fleet` FLEET_DIR symlink (else `maw wake` spawn-fails) + `maw.config` agents entry + a `0X-…json` fleet window + scaffold the LIVE/staging secret slot.
3. **Artifact C** — `next-investigator/SKILL.md`: replace the `4. live-RCA (future/TBD)` row with the concrete `4. verify-live (L3)` sub-gate (live-RCA stays a separate future row). Per handoff Artifact C draft.

**Coordination note:** the memory repo was mid **fleet-renumber** when I checked (uncommitted fleet JSON renames + the `2026-06-09_maw-fleet-renumber...` learning) — that's why I did NOT touch C/D from the architect side; land them atomically with the registration so the new fleet window numbering stays consistent. The role must NOT be left half-registered (SKILL present but no fleet window → `maw wake` spawn-fail).

## Unchanged teeth (don't drift)
M1 SIM stays the mandatory per-epic gate (OQ3 intact); M2 REAL-BANK + PAYOUT round-trip stay v2 (bank-bot-gated). L3 investigator raw-table recompute untouched. G2 DONE = investigator seal AND `live_signoff` ACCEPT. AR6 one-time next-tester methodology review of the first journey script.
