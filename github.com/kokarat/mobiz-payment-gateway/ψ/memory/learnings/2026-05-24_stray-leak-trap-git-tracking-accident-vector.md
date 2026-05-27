---
title: ψ/ stray-leak trap — git-tracking accident vector now guarded by #482 (16467ff) 
tags: [tester, repo:mobiz-payment-gateway, current, psi-trap, gitignore, workflow-hygiene, no-op]
created: 2026-05-24
source: .gitignore@16467ff (PR #482) + .agent/skills/tester/references/workflow-1-validate-integration-tests.md §The ψ/ trap
project: github.com/kokarat/mobiz-payment-gateway
---

# ψ/ stray-leak trap — git-tracking accident vector now guarded by #482 (16467ff) 

ψ/ stray-leak trap — git-tracking accident vector now guarded by #482 (16467ff) adding `/ψ` to repo `.gitignore`.

What changed: PR #482 (`16467ff`, 2026-05-25) added `/ψ` to `mobiz-payment-gateway/.gitignore` (+ comment). The W1/W2 workflow "ψ/ trap" sections state "ψ/ is NOT in this repo's .gitignore as of 2026-04-19" and cite 21 stray vault files historically committed into mobiz git history across 3 failed cleanup attempts (commits 414f568 / 2965cda / da4d13a) plus the 2026-04-19 15:06 W2 retro-leak incident.

What it fixes vs not: The `.gitignore` entry closes ONLY incident-risk #3 (stray `ψ/` write at repo root getting `git add`-ed into permanent product-repo history) — a misrouted retro/learning at `mobiz-payment-gateway/ψ/...` will no longer appear as untracked noise nor be accidentally staged. It does NOT fix risk #1 (Oracle won't index a stray write) or risk #2 (invisible to other agents). So the Step-8 pre-write `readlink ~/.arra-oracle-v2/ψ` check + post-write stray-find recovery in workflow-1/workflow-2 remain load-bearing — the gitignore is a backstop against the worst consequence, not a replacement for path discipline.

Scope: not a production-surface or test-surface change — #482 is otherwise seed-migration JS for goodpay/youpay brand DBs (scripts/init-*-db/*.js). Surfaced during the W1 no-op pass over increment c551524..16467ff.

---
*Added via Oracle Learn*
