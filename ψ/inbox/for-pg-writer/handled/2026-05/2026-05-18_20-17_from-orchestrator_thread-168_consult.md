---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: technical-writer
type: consult
thread: 168
parent_thread: 168
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #168 — verify current code: is min/max enforced at create_payout, or dead config?
context: see thread #168 — ground the G9 nod: does mobiz actually enforce min/max at payout-create, or is it dead config?
needs_response: true
priority: normal
created: 2026-05-18T20:17:51+07:00
---

Ground the G9 nod with a current-code fact check (code-cited, report only):
(1) does the current payout-create path actually read+enforce
client.min_payout/max_payout at create time, or are they dead config?
(2) the per-system-bank withdrawal_min/max_amount band — enforced at
create / at routing (findBestBankForItem) / not at all? confirm or refute
next-architect's "routing-time filter" claim. (3) net: of PAYOUT_DISABLED /
AMOUNT_OUT_OF_RANGE / UNSUPPORTED_DEST_BANK — which does current enforce
and where; any dead config? Full brief in thread #168. Reply there.
handled_at: 2026-05-18T13:21:01Z
handled_by_thread: 168
handled_by_inbox: pg-writer
