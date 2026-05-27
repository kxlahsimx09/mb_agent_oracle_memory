---
from: next-writer
from_role: next-product-writer
to: orchestrator
to_role: orchestrator
type: progress
thread: 235
parent_thread: 234
parent_oracle: orchestrator
subject: #233 anchor-resolution DONE — PR #260 (SETTLE-001/002 + AUTH-007 S4→S2); campaign #234 authoring complete
needs_response: false
priority: normal
created: 2026-05-26T21:40:00+07:00
handled_at: 2026-05-26T21:45:00+07:00
handled_by_thread: 235
handled_note: #233 anchor-resolution DONE → PR #260 (last authoring item for #234). type=progress, needs_response=false — no reply envelope. Relayed to #234. Campaign #234 authoring complete; holding formal close until PRs #257/#259/#260 merge (per #228 precedent).
---

#233 anchor-resolution pass DONE — **PR #260** (`writer/settle-auth007-anchor-resolution-233` → main, off a09f00b). Do-not-merge-without-user. **Last authoring item for campaign #234.**

All three `[AWAITING_THREAD:233]` anchors closed; **no AC rewrites** (both §ADR-2/§ADR-12 amendments confirm the existing ACs as authored). Exact text from next-architect:

- **SETTLE-001** (epic-source-flows) — wallet reserves **at create** via the §ADR-10 freeze (`amount + settlement_fee`, fee default 0), mirroring payout; settles out on success, releases on reject/failure. Cite §ADR-12 §Amdt 2026-05-26 M1.
- **SETTLE-002** (epic-source-flows) — config-gated withdrawal-service fee (default 0, distinct from MDR); approve settles the freeze out, reject releases it. The prod "skips MDR" finding = fee is config-0 (off), not missing. Cite §ADR-12 §Amdt M2.
- **AUTH-007** (epic-auth-rbac) — promoted **S4 → S2**; anchor dropped; posture = fail-closed default + super-admin-only immediate-effect toggle to fail-open (audited); scope = admin money-out only, not machine/client API. Cite §ADR-2 §Amdt 2026-05-26 (PR #257).

**Sync touches** (same class): INDEX (S4→S2, "seven S2" blurb, resolved-anchor notes) + README ("OTP & Trust" row → ratified). Also swept the now-stale **AUTH-006/#229** open-thread INDEX note — a tail from PR #255 that didn't sync INDEX; closed it here. Marker tokens reworded to plain `thread-233` so future orphan-sweep greps stay clean.

**P-004:** PRs #257/#259 are open (do-not-merge), so the ADR amendment text isn't on main yet — same parallel-PR pattern as #228 A1/A4 (cited §ADR-4a PA7 from then-open PR #246). Verified M1/M2 + S1–S4 section labels and verbatim handoff text against the #257/#259 diffs before citing — matched the relay exactly. Writer PR + the two ADR PRs merge together under user approval.

Gates: no Given/When/Then lines touched; no live `[AWAITING_THREAD]`/`[RATIFICATION_PENDING]` markers remain in `docs/requirements/`; MDX clean.

Detail in thread #235 (msg 1094). Learning: `2026-05-26_233-anchor-resolution-pass-thread-235-campaig`. Campaign #234 authoring complete on my side — ready for you to close #234.
