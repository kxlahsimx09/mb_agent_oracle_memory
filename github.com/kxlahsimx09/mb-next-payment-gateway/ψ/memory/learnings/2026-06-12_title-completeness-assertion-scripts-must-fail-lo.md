---
title: title: Completeness-assertion scripts must fail-loud on an EMPTY expected set (t
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, smell, request-changes, shell, assertion, false-pass, obs-1]
created: 2026-06-12
source: PR #424 review, 2026-06-12 (thread #17); empirically reproduced the comm -23 empty-source exit-0
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: Completeness-assertion scripts must fail-loud on an EMPTY expected set (t

title: Completeness-assertion scripts must fail-loud on an EMPTY expected set (the comm/diff empty-source false-pass)

A script that asserts "deployed == source" (or any "actual ⊇ expected") via a set-diff will FALSE-PASS when the EXPECTED/source side is empty, because "nothing is missing" when you expected nothing. This is the empty-list trap in disguise — and it's most dangerous in the very tools written to prevent silent omission.

Witnessed 2026-06-12, gateway PR #424 (OBS-1 recurrence-fix), `scripts/ef-deploy-list.sh --assert`:
`missing="$(comm -23 <(printf '%s\n' "$src") <(printf '%s\n' "$deployed"))"` — with `src=""` (list_source enumerated zero EFs), `comm -23` of a single empty line vs the deployed set yields no `missing` → prints "OK — every EF at HEAD is deployed + ACTIVE" and exits 0. Reproduced: `src="" deployed="bot-config\nauth-login\ntenant-read"` → missing=[] → exit 0. The display even showed `source=0` but the exit code stayed 0, so any CI / runbook close-out keyed on exit status is fooled.

Asymmetry to watch: the empty-DEPLOYED direction (actual side empty) fails correctly (everything in source is missing → exit 1). Only the empty-EXPECTED/source side is blind. So testing "stack is empty → fails" does NOT prove "broken checkout → fails".

Review rule for any "assert all X are present" script:
1. Guard the expected set is non-empty BEFORE the diff: `[ -z "$src" ] && { echo "enumerated ZERO expected — refusing to assert" >&2; exit 2; }`. Better: a sanity floor (expected ≥ known-min).
2. Mentally set the expected side to ∅ and confirm the exit code is non-zero, not just the happy "stack missing everything" case.
3. `grep -c .` / `wc -l` count *displays* are not guards — automation reads the exit code, not the printed number.
4. Confirm a failed data fetch can't masquerade as empty-actual: curl `-fsS` under `set -euo pipefail` (a non-2xx aborts the command-substitution assignment) is the correct pattern — PR #424 got this part right.

This is the same family as the `grep -c` / empty-glob false-pass and ties to [[review-pr-scope-against-the-pr-base-sha]] (verify against ground truth, not a possibly-degenerate intermediate).

---
*Added via Oracle Learn*
