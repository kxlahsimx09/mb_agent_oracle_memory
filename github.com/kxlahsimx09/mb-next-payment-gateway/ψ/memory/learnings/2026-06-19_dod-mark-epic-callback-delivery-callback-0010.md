---
title: DoD-MARK — epic-callback-delivery (CALLBACK-001..005) = 🟢 epic-DONE (2026-06-19
tags: [dod-mark, epic-done, callback-delivery, shape-a-seal, rf1-redirect, ssrf, do-not-follow-redirect, live-n-a, ride-along]
created: 2026-06-19
source: next-pm (campaign pmmark)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — epic-callback-delivery (CALLBACK-001..005) = 🟢 epic-DONE (2026-06-19

DoD-MARK — epic-callback-delivery (CALLBACK-001..005) = 🟢 epic-DONE (2026-06-19, next-pm campaign pmmark). The automatic webhook delivery engine (callback_queue / callback_attempts / dispatch-callback EF). Marked on concrete gate-to-artifact evidence (gone-and-looked, gh state NOT trusted — the reviewer verdict lives in the PR #643 BODY HEADER, gh state reads COMMENTED). Mark PR #647 (DOCS-ONLY flip, base main, head docs/callback-delivery-epic-done-pmmark, commit c730495) — OPEN, MERGEABLE, NOT self-merged (left for OWNER per §9a). Team-lead green-gate confirmed #643 MERGED before the mark.

THE 4 GATES (each verified directly by next-pm):
- BUILD ✅ — the engine is real deployed code; the one reopened leg CALLBACK-003 RF1 (response-time redirect = do-not-follow) closed by PR #643 MERGED → main (merge commit 4cdd244 = origin/main HEAD, confirmed ancestor; mergedAt 2026-06-19T16:32:47Z; commit c955164): redirect:"manual" on the outbound fetch + a 3xx/opaqueredirect recorded as callback_redirect_blocked riding the normal retry/dead-letter ladder, NO source/money mutation, the Location target provably never contacted (callbackRedirectReason() short-circuits before res.text()). dispatch-callback/index.test.ts 5 pass / 0 fail / 29 expect(); full bun test supabase/functions 66 pass / 0 fail / 275 expect().
- REVIEW ✅ — next-code-reviewer PR #643 body-header "✅ REVIEW VERDICT: APPROVE" (2026-06-19T16:32:36Z) on c955164, all 3 dimensions PASS (closes §ADR-9 RF1 exactly — redirect:"manual", Location never fetched, short-circuit precedes res.text(); minimal; mirrors the existing unsafe-handling shape); reviewer re-ran EF 5/0/29 + full 66/0/275. gh state COMMENTED = self-authored build-PR degrade (§9a/#618); self-merged on APPROVE + the RF1 re-seal GREEN.
- VERIFY/SEAL ✅ — next-investigator Shape-A SEAL GREEN (§6 + §10). §6 re-derived the engine from raw rows on qnccph = 8/8 engine checks PASS: CALLBACK-001 at-least-once + dead-letter ladder (pending→dispatching→…→dead_letter at MAX_ATTEMPTS=3; 200→short-circuit); 002 HMAC over t.body + X-Maxpay-Signature + fresh t per attempt + X-Maxpay-Event-Id + 5-min window + dedup_key UNIQUE (source_type:source_id:event); 003 SSRF triad legs (a) raw-URL-reject at create, (b) config-time HTTPS/private-IP validation, (c) create-time snapshot, (d) dispatch-time callbackUrlUnsafeReason() re-check; 004 taxonomy + review-silent; 005 append-only callback_attempts (UPDATE+DELETE blocked) + denorm + resend_callback; money invariant exactly-one terminal callback per transition (dedup_key UNIQUE makes a second enqueue impossible). The sole §6 🔴 was RF1 UNIMPLEMENTED. §10 RF1 RE-SEAL GREEN closes it (re-verified as a NON-money EF control by code + unit teeth 5/0). Overall = callback-delivery SEAL GREEN.
- LIVE (§ADR-21) ✅ N/A (ruled) — non-money engine (OWNER P1; architect row 2 / §2). The engine moves no money of its own; its one money-touching invariant (#2 exactly-one callback byte-matching the net move) is recomputed live under the DEPOSIT/PAYOUT signoffs it rides (§10 ride-along — NO own live_signoff row is authored). Precedent: CLIREAD #611 / PROV #612 / OTPLOG #566.

REUSABLE PATTERN: a non-money ENGINE epic with substantial deployed code closes via Shape-A (right-sized investigator SEAL re-deriving the engine from raw rows + reviewer APPROVE), not the by-construction CI-teeth Shape-B. When an investigator reopens ONE leg (here RF1 redirect-SSRF), the dev's fix PR + the investigator's targeted RE-SEAL of just that leg (verified as a non-money EF control where it moves no money) re-closes the seal — the rest of the §6 engine seal stays valid. A non-money engine is LIVE-N/A (P1) and its one money-touching invariant RIDES the money epics' signoffs (§10 ride-along) — no own live_signoff row.

---
*Added via Oracle Learn*
