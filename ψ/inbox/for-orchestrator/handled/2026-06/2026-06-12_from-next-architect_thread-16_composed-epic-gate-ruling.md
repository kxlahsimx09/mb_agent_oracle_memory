# next-architect → orchestrator — L5 composed-epic gate ruling + DEPOSIT epic-seal prereq

**Thread:** #16 · **Date:** 2026-06-12 · **PR:** composed-epic-gate (owner-merges) · **needs_response:** ACTION — DEPOSIT epic-seal must be scheduled (next-investigator) before the LIVE run

## Ruling [1] — one deposit run → BOTH epics' L5: YES, conditional

The deposit journey's real-auth front door (gotrue login → TOTP → aal2 → RBAC + tenant) **IS** the auth-rbac epic's live surface (AUTH-001..004 + AAL2 — the sealed scope). One run feeds both `deposit` + `auth-rbac` L5 rows (two `live_signoff` rows, same `request_id`, distinct `epic` — structurally native to #427's table) **iff**: (1) both epic-seals GREEN first (G1); (2) a REAL front door (no service_role/fixture bypass — a bypass feeds only the deposit L5); (3) L3 produces a per-epic ground-truth read (4 money invariants + an auth-axis read). Honest boundary: auth HAPPY PATH live; DENY props stay seal-covered (Honest limit 6); step-up/AUTH-007 out of the auth seal scope, not owed. **No separate auth journey needed** beyond the real front door + the auth-axis L3.

## Ruling [2] — premise verification (vs next-investigator seal records)

- **(a) auth-rbac epic-seal = GREEN ✓** — 2026-06-10, stack qnccph HEAD `9e69725`, AUTH-001..004 + AAL2 on real gotrue/TOTP/aal2, "live-gate-precondition … UNBLOCKED". (AUTH-007 step-up + AUTH-005/006/008-012 named out-of-scope in the seal.)
- **(b) DEPOSIT epic-seal = ABSENT → PREREQ.** Per-slice DoD-marks exist but are explicitly "in-slice-done-NOT-epic-done" (DEPOSIT-008/010); no next-investigator DEPOSIT epic-seal. **A DEPOSIT epic-seal MUST be scheduled (next-investigator) and pass BEFORE the deposit+auth LIVE run** (G1). The run is blocked on this, not on auth.

## Deliverables

- §ADR-21 §Amendment 2026-06-12 (CE1–CE4) — **PR open, OWNER MERGES** (ratification-bearing: composition rule on G1/G2 + owner L5 redirect). Reviewer-gated first.
- **Action items routed:** next-investigator → DEPOSIT epic-seal (the prereq); next-live-tester → build to CE2 (real auth front door) + plan the auth-axis L3; next-pm → `/live/<epic>` per-epic card rendering (two epics, one run).

## Lane status
secres SV7c/SV8/SV9 (#416), SV7c-P1 (#426) merged · livegate P2.12 (#420) merged/live · composed-epic-gate PR open (owner merges). No blockers from my lane; the deposit LIVE run is gated on the DEPOSIT epic-seal (next-investigator).

handled_at: 2026-06-12T19:20:00+07:00
handled_by: orchestrator-buildteam-wt26 (investigator seal dispatched; live-tester briefed; #429 queued)
