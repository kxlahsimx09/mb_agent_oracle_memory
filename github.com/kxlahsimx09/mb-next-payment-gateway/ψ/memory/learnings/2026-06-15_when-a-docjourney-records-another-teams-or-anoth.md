---
title: When a doc/journey records another team's or another repo's work as "not built" 
tags: [grounding, cross-repo, honest-limits, docs, deploy-status, verification]
created: 2026-06-15
source: next-live-tester (quad-epic LIVE campaign, 2026-06-15)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# When a doc/journey records another team's or another repo's work as "not built" 

When a doc/journey records another team's or another repo's work as "not built" / "pending-deploy" / "stuck", re-verify it against ground truth BEFORE editing or trusting it — check the OTHER repo's merged PRs (gh pr list/view), the deployed config (`config.toml` verify_jwt entries, deployed EF/migration list on origin/main), and prior run evidence — not the handoff's own framing.

Across one campaign this caught FOUR stale claims, each corrected only because of grounding: (1) bbot outbound/OTP "not built yet" → actually merged in mb-next-bank-bot PRs #8/#10/#12/#13/#15/#16; (2) AUTH-010 "admin-only / client self-service deferred" → client self-service was then built (#522); (3) the client-self EFs were "merged" but ABSENT from config.toml (no verify_jwt=false) → genuinely NOT deploy-ready, so they correctly stayed `S` until brew-ops fixed+deployed (#523); (4) a deploy-status note kept being mistaken for an honest-limit.

Two durable rules from it:
- **Honest-limits ≠ deploy-status.** A structural SIM-scope limit (no real bank, latency-not-gated, one representative journey, ACCEPT≠evidence) does NOT disappear when more EFs deploy. A "pending-deploy → S" caveat is transient build-status and SHOULD be flipped once verified deployed. Keep them in separate buckets so "we deployed X, why didn't the limits shrink?" never confuses a reader.
- **Split the verdict, don't blanket it.** When part of a story is deployed and part isn't (admin path live, client-self path config-gapped), mark it split (L admin · S client-self) with the exact reason, rather than flipping the whole story prematurely — then flip the remainder only after grounding the fix.

Process note: on a reused feature branch where the owner merges PRs mid-work, every new push needs a NEW PR (the prior one closes on merge); expect mergeability to read CONFLICTING/UNKNOWN briefly after a same-file merge upstream and re-check after a few seconds.

---
*Added via Oracle Learn*
