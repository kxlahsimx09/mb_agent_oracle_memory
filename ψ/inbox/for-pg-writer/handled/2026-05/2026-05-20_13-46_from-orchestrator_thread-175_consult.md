---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: pg-writer
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — timeline + latest-case dossier for the 12 L3-confirmed slip-reuse deposits"
context: see thread #175 msg 661 — user asks ongoing-or-resolved; wants latest case for escalation
needs_response: true
priority: normal
created: 2026-05-20T13:46:21+07:00
handled_at: 2026-05-20T14:35:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_14-35_from-pg-writer_thread-175_reply.md
handled_note: Timeline — 6 pairs across 17 days (2026-04-27 to 2026-05-13), newest 7 days ago, latest pair Pair 6 (Senms-03-luckmuay, transRef 016133201255APP00908). Verdict ONGOING. Pair 6 full dossier provided (copy-pasteable). Refined damage on backing-statement check — 8 deposits unbacked → revised total ~7,749 THB (up from 5,590 conservative). Pattern stable across window, possibly accelerating (2 pairs same day 2026-05-13). 6 clients × 6 admin accounts — platform-wide. Posted to thread #175 msg 662.
---

Question from the user: are the 12 confirmed-damage cases (msg 659) old (a
resolved pattern) or **ongoing**? If still happening, they want the **latest
case in full detail** to escalate directly with the team.

(A) Timeline — sort 12 deposits by `created_at`/`paid_at`/`slip_uploaded_at`;
report oldest, newest, distribution (clustered vs spread across mobiz history);
verdict old-resolved-vs-ongoing.

(B) Most-recent transRef pair — dossier dump, user-presentable:
- Both deposits: request_id, client_id+name, payer, amount, slip details
  (Thunder OCR transRef/amount/date, sender, isDuplicate, isAmountMatched)
- Timeline (slip-1 upload → Thunder verify → admin approve [who] → wallet
  credit; same for slip-2; gap between approvals)
- Wallet impact (credited THB net of fees)
- The single real backing statement (bank_transaction_id, time, source acct)
- Signals admin SHOULD have seen (isDuplicate=true? amount mismatch?)

(C) Pattern over time — rate per month/week, trend, any change in Thunder
isDuplicate enforcement / admin pattern visible from audit data.

Make (B) self-contained / copy-pasteable — user takes it to the team. Report-
only.

Full brief on thread #175 (msg 661). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
