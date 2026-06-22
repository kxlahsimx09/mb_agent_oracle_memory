---
title: epic-seal — /otp-logs ① retention 24h→7d + ② from_email port (PR #578) — SEAL.
tags: [next-investigator, repo:mb-next-payment-gateway, next, epic-seal, seal, otp, v_otp_logs, retention, from_email, otplogsenhseal, pr-578]
created: 2026-06-17
source: next-investigator_otplogsenhseal_findings.md @ seal-stack qnccphgykzdydebmdwdf (migrations …000010/…000020)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# epic-seal — /otp-logs ① retention 24h→7d + ② from_email port (PR #578) — SEAL.

epic-seal — /otp-logs ① retention 24h→7d + ② from_email port (PR #578) — SEAL.

next-investigator falsified PR #578 from RAW seal-DB on its OWN seal stack qnccphgykzdydebmdwdf (distinct from tester stack yupsevcrubgprsbujbpu; did NOT inherit the tester green). Deployed seal substrate carries the #578 migration set (20260618000010 + 20260618000020 on top of …20260617000140). Method: Supabase Management-API db/query (in-tx seeds always ROLLBACK, zero residue) + real anon REST; auth contexts via set_config('request.jwt.claims',…); own-discovered identities + own unique canary.

HEADLINE TEETH = PASS — OTP code STILL never in v_otp_logs after the ② view re-create. (a) Structural: pg_get_viewdef projects exactly 12 cols [id,bank_account_id,system_bank_code,account_name,acc_number,reference_code,source,from_email,otp_expires_at,created_at,last_read_at,is_expired]; o.otp NOT in the SELECT list — the DROP+CREATE did not widen to the code. (b) Behavioral: seeded unique canary into base otp_logs.otp via real save_bot_otp, read as gated super-admin → canary ABSENT from row_to_json AND composite row::text, PRESENT in base (neg control), gated SA sees the row (count=1, discriminates). (c) Detector-of-detector: forcing the marker into a projected col → same search FINDS it, so absence is meaningful.

② from_email PASS: projected text @ ord 8; round-trip surfaces verbatim; SMS path (no p_from_email) → NULL in base+view, no error; single 8-arg save_bot_otp overload, proacl = postgres+service_role only (no PUBLIC/anon exec).
① retention PASS: cron purge-expired-otp-logs = DELETE FROM public.otp_logs WHERE otp_expires_at < app_now() - interval '7 days' (schedule 17 * * * *); zero '24 hours' remnant anywhere; only one otp_logs purge job; app_now() virtual-clock anchor preserved.
Negative-access matrix PASS (discriminating, not constant-0): anon REST 401 (no grant), aal1/non-admin(client_viewer)/admin-no-perm(support_admin) → 0, gated super_admin aal2 → 1. Gate = auth_aal2() ∧ has_read_perm('otp-log') ∧ auth_db_is_admin(); only super_admin role carries otp-log:view.

Zero residue post-run. NO OTP-code appearance, NO contradiction → SEAL (withholding nothing). Carve-outs (do not block): bot-otp-log EF HTTP-forward DEFERRED (needs brew-ops-minted seal producer cred; authoritative ② observable proven at the save_bot_otp RPC layer); PR #578 OPEN at seal time — seal is against the deployed #578 substrate, post-merge re-deploy currency is the downstream brew-ops step. Full verdict: next-investigator_otplogsenhseal_findings.md.

---
*Added via Oracle Learn*
