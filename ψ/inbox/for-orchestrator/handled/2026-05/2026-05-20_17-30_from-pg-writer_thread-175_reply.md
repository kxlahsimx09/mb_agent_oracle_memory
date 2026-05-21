---
from: pg-writer
from_role: pg-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: re — #175 — list Pair 1..5 dossiers (full mobiz escalation pack, match Pair 6 shape)
in_reply_to: 2026-05-20_16-56_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T17:30:00+07:00
---

Full Pair 1..5 dossier pack posted to thread #175 (message 679), matching the Pair 6 (msg 662) shape exactly. Together with Pair 6, the user now has the complete mobiz escalation pack — self-contained, copy-pasteable.

**What's in the dossier pack:**

For each of the 6 pairs:
- Pair-level header: transRef, BKK date, client, sysbank(s), admins, approval gap
- Per-deposit (× 2): request_id, declared payer, amount/fee/net, slip_trans_ref + slip_duplicate_of + notes, full Thunder OCR snippet (transRef, slip date, slip amount, sender bank + masked account + Thai name, receiver proxy, isAmountMatched, isDuplicate, amountInOrder/amountInSlip)
- Backing-statement check (verified via dpay): "real backing yes/no + details"
- Timeline (BKK)
- Signals admin should have seen
- Wallet trail
- Per-pair damage attribution

Plus a closing **common-patterns paragraph** (8 structural observations across all 6 pairs):
1. Every "second" slip in a pair triggered slip-upload duplicate check, silently bypassed by admin-uploader (no [force-approve] required)
2. Thunder isDuplicate + isAmountMatched written but never read by mobiz code
3. Admin-approve V1/V2 fired only 2/12 (Pair 3 A + Pair 6 B); both used [force-approve]; events `log.Printf` only, no `audit_logs[]` write
4. Approval timing rubber-stampy (Pair 4 = 13s, Pair 5 = 7s by SAME admin)
5. 6 admin accounts × 6 clients — platform-wide
6. 3 of 6 pairs use different sysbanks for the two deposits (cross-sysbank slip-reuse, visually obvious)
7. Slip-uploaded times closely correlate with slip's claimed transfer time → real-transfer slips being reused, not fabricated
8. **Total confirmed unrefunded damage ≈ 7,749.30 THB across 9 fraudulent credits**; single largest = Pair 3 Deposit A at **2,452.50 THB** (the 700-slip-on-2500-deposit amount-mismatch). Most recent case 7 days ago — ongoing.

**Notable individual findings worth flagging to the team:**
- Pair 5 — `[force-approve]`-free silent approval of a Thunder-flagged-duplicate on the very FIRST upload (Thunder already knew this transRef from outside the 12). Same admin double-credited 1500 THB twice in 7 seconds.
- Pair 3 Deposit A's `[force-approve]` justification text claims "เงินเข้าบัญชีระบบ" (money came into system account) — but production has no 2500-THB backing statement from this payer at this sysbank. The override may have been incorrect.
- Pair 2 — slip's actual sender bank (KTB) doesn't match deposit's declared payer bank (SCB or KBANK). mobiz has no slip-sender vs deposit-declared-payer comparison check.

— pg-writer
