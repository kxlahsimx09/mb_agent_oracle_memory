---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 232
parent_thread: 231
parent_oracle: orchestrator
subject: Reply — B7+B8 decision-ready deep-dive + ranked build-first list
needs_response: true
priority: normal
created: 2026-05-27T09:39:00+07:00
handled_at: 2026-05-27T09:42:00+07:00
handled_by_thread: 232
handled_note: B7+B8 decision-ready deep-dive (msg 1104) read + relayed to user in live orchestrator wt-22 CLI session. Campaign #231 OPEN — user now in case-by-case decision phase; architect idle awaiting which decisions lock + thunder-API commit. Next architect dispatch (decision-lock or further drill) = new consult envelope once user decides. Reply envelope = doorbell, handled.
---

B7 (dispute) + B8 (fraud) decision-ready deep-dive delivered in-thread #232
(msg 1104). Narrative form, NO build. Re-grounded `p2p-hub origin/main @6f7517e`
(0 commits since yesterday; PR #8 merged the §E *spec* into the doc, NOT
migrations 006–009 — enforcement substrate still unbuilt).

Each case = threat narrative → 4-bucket defense (PROTOCOL-PREVENTS-WHEN-BUILT /
CS-OPERATOR / LEGAL-POLICY / ACCEPTED-RESIDUAL) → one-line user-decision.
Covered B7.1/B7.3/B7.4/B7.5 (B7.2→B4.8) + B8.1–B8.9.

Cross-cutting substrate made concrete + tagged ⟦S1⟧–⟦S6⟧:
- ⟦S1⟧ provider `status`+`set_provider_status` (off-switch) · ⟦S2⟧ `apply_credit_penalty`
  (`admin_debit` producer — enum exists, producer missing = §D8 teeth) ·
  ⟦S3⟧ reputation signals · ⟦S4⟧ `match_verifications`+thunder gate (C8) ·
  ⟦S5⟧ `disputes`+open/resolve (C11) · ⟦S6⟧ `provider_keys`+liability_terms+vetting (C3).

Ranked build-first: 1.⟦S1⟧ 2.⟦S2⟧ (both tiny — convert B7.4 "no teeth"→real bounded
lever in ~a day) → 3.⟦S4⟧ C8 thunder gate (biggest fraud-defense ROI, closes B8.1;
⚠ external thunder-API dependency) → 4.⟦S5⟧ → 5.⟦S6⟧ → 6.⟦S3⟧.

Two USER/LEGAL gates that block builds:
- **G1 — B8.3/B11.4 legal classification: escalate to counsel BEFORE launch**
  (§D1 B2B-custodial reframe sharpened it). Launch-blocking.
- G2 — B7.5 liability-matrix rows + B8.7 vetting policy: user+legal authoring,
  prerequisite to ⟦S5⟧/⟦S6⟧.

needs_response: true — awaiting which decisions the user locks + whether to commit
to the thunder-API integration (gates ⟦S4⟧).
