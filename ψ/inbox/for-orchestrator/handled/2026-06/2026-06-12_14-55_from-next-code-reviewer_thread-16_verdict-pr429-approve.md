# next-code-reviewer → orchestrator — PR #429 verdict: APPROVE (composed-epic LIVE gate CE1–CE4) → OWNER MERGES

**Campaign:** livegate · **Thread:** #16 · **Date:** 2026-06-12 14:55 GMT+7 · **PR:** #429 (`arch/adr21-composed-epic-gate` → `main`, docs-only +21, RATIFICATION-BEARING)
**Verdict:** **APPROVE** · COMMENTED review carrying the verdict (shared-account block; verify `gh pr view 429 --json reviews`). My APPROVE is the reviewer-gate; **the OWNER merges the ratification** (not self-merge).
**needs_response:** false

---

## Bottom line
Sound, well-guarded composition rule on the ratified G1/G2 DONE-semantics. The gate is NOT weakened, the anti-gaming conditions are L3-enforced, the boundary is honest, and CE1 is structurally consistent with the #427 `live_signoff` table I just approved.

## Verified
- **CE1 ↔ #427 consistency:** CE1's "two rows, same request_id, distinct epic, structurally native to #427" holds — `epic` is a first-class NOT-NULL column, the DONE-check index is `(epic, request_id)` (non-UNIQUE), and there's NO unique-on-request_id (PK on `id uuid`). The ADR and the migration agree exactly.
- **CE1 gate-integrity:** each epic still needs its own seal (G1) + own L3 read + own ACCEPT row; composition only carries multiple axes when surfaces overlap.
- **CE2 anti-gaming teeth (load-bearing):** (i) REAL front door — a service_role/fixture bypass feeds ONLY the deposit L5; (ii) auth-axis L3 read confirms (amr+factor / app_user.role / audit_log) the money action was gated by a real aal2 identity → the auth L5 is L3-VERIFIED, not assumed; a bypass cannot earn it.
- **CE3 honest boundary:** LIVE proves the auth HAPPY path; deny-properties (aal1→401, RBAC-deny, cross-tenant=0, alg-confusion) stay seal+probe-covered (Honest limit 6). "Composition sound BECAUSE deny-props sealed" — correct. Step-up/AUTH-007 correctly scoped out + not owed.
- **CE4 gate discipline:** verified G1 status — AUTH-RBAC sealed GREEN (2026-06-10, qnccph 9e69725, AUTH-001..004+AAL2); DEPOSIT NOT epic-sealed (per-slice DoD only) → NAMES the DEPOSIT epic-seal as the must-pass prereq before the run. Premises cited/auditable; accepted (owner ratifies).

## Ratification + consistency
Ratification ruling correct (normative G1/G2 change + owner L5 redirect → owner merges, §ADR-21 convention + KF3/#414 precedent). Additive — no internal contradiction (unlike the #420 flip); G2's per-epic ACCEPT row and CE1's one-row-per-epic are consistent.

## One optional non-blocking note (architect discretion)
The §L5/G2 text says the row is "keyed to the run request_id + owner identity"; CE1 makes the effective DONE-check key `(epic, request_id)`. Not a contradiction (the original isn't falsified), but a one-clause pointer on the L5/G2 line would stop a reader from assuming request_id-only keying (which would collide for composed runs). Optional.

## Cross-link for the fleet
CE4 names a hard dependency: **the deposit+auth LIVE run is gated on a next-investigator DEPOSIT epic-seal** (AUTH already sealed; DEPOSIT not). That's the next real prereq before the composed run can execute — flagging so the lane plans the deposit epic-seal.

## Session tally — 14 reviews
Open merges: #429 (owner), #426 (architect self), #420 (owner). brew-ops wave 2 (#416→#421→#425→#428; #423 anytime after #416; #427 after #428). Standing by.

— next-code-reviewer · team livegate

handled_at: 2026-06-12T19:35:00+07:00
handled_by: orchestrator-buildteam-wt26 (handed to owner for ratification merge)
