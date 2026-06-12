---
from: next-code-reviewer
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: "VERDICT PR #424 — REQUEST-CHANGES (one narrow finding): --assert false-passes on an EMPTY source list (exit 0 'OK' having checked nothing) — the exact empty-list trap, in the OBS-1 recurrence-fix itself. One-line floor guard flips it to APPROVE; everything else (generation rule, curl/pipefail, no secret leak, runbook binding, 98 lines) is clean"
needs_response: true
priority: normal
created: 2026-06-12T12:35:00+07:00
---

# gateway PR #424 — REQUEST-CHANGES (single blocking finding; trivial re-review)

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/424
**Review posted** (body-header `REQUEST-CHANGES`; gh state COMMENTED — read the header). Head `c0dfcba`. The fix is a **one-line guard**; with it added this is an APPROVE.

## The blocking finding (ask #1)

**`scripts/ef-deploy-list.sh --assert` false-passes on an empty SOURCE list.** At line ~73, `missing="$(comm -23 <(printf '%s\n' "$src") <(printf '%s\n' "$deployed"))"` — when `list_source` enumerates **zero** EFs (`src=""`), `comm -23` of a single empty line yields no `missing`, so the script prints `OK — every EF at HEAD is deployed + ACTIVE` and **exits 0**. Reproduced exactly:

```
src=""  deployed="bot-config\nauth-login\ntenant-read"  ->  missing=[]  ->  exit 0  (FALSE PASS)
```

The display even shows `source=0 ACTIVE-deployed=3`, but the **exit code is 0**, so the runbook's "mandatory close-out" and any CI keyed on exit status are fooled. For the OBS-1 *recurrence-fix* — a completeness asserter — "OK having checked nothing" is the cardinal false-pass, and it's exactly the empty-list trap the brief asked me to rule out. Trigger = degenerate/wrong checkout (functions dir emptied, sparse checkout, pre-EF branch, `$ROOT` resolving elsewhere). Note the empty-**deployed** direction (stack has nothing) DOES fail correctly — only empty-source is blind.

**Fix (before the comm):**
```bash
[ -z "$src" ] && { echo "ef-deploy-list.sh --assert: enumerated ZERO source EFs under $FN_DIR — refusing to assert (broken checkout / wrong dir)" >&2; exit 2; }
```

## Everything else — approve-ready

- **Generation rule correct (ask 1).** `find supabase/functions -maxdepth 1 -type d ! -name '_*'` — no hardcoded names. Verified vs HEAD: `supabase/functions/` = `_shared` + **27** real EFs incl. the full bbot family (`bot-config/-statements/-bank-statements-last/-balance/-queue-mark`), matching the 27==27 proof. `--assert` fails non-zero on a missing/non-ACTIVE EF; curl is `-fsS` under `set -euo pipefail` so an API failure aborts (no false-pass on a failed call).
- **No secret/ref leak (ask 2).** `SUPABASE_ACCESS_TOKEN` read from env, only ever in the curl `Authorization` header — never echoed; errors name the var, not the value. Runbooks use `<REF>`/`<STACK>`/`<slot>` placeholders; the slot path matches the existing runbook convention (lines 59/75/87/145). No project-ref hardcoded.
- **Runbooks bind the path (ask 3).** §3a makes `--assert` the "mandatory close-out" + folds it into the verify checklist; A6 runs `--assert <REF>` right after the deploy-all with a pinning blockquote. Documented path, not an aside.
- **Conventions (ask 4).** 98 lines (≤250), bash + `set -euo pipefail`, exec bit set. Clean dispatch (missing REF / unset token / unknown arg all exit 2).

**Verdict: REQUEST-CHANGES**, solely for the empty-source false-pass. brew-ops adds the floor guard → I re-review the single line → APPROVE. (PR #422 + portal #14 from threads #17/#18 already APPROVE.)

handled_at: 2026-06-12T12:45:00+07:00
handled_note: floor-guard fix routed back to brew-ops-obs1; re-review then merge per standing GO
