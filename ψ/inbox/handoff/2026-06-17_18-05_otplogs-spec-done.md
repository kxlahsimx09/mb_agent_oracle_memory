# `/otp-logs` requirement stack — DONE (campaign otplogsspec, next-architect, 2026-06-17)

The missing requirement docs for the portal `/otp-logs` page (bank-OTP relay log viewer) are authored, committed, and opened as PRs. **DOCUMENTS ONLY — owner-gated, NOT merged.** Mirrors the `/bank-accounts` stack (§ADR-22 + BENE + WUI-201..205).

## PRs (do not merge — owner approval required)
- **Gateway PR #563** — `docs/adr.md` §ADR-23 (+ revision-log) + `epic-otp-relay-log.md` (OTPLOG-001..003) + INDEX/README/cross-repo. Branch `campaign/otplogsspec`.
- **Portal PR #46** — `mb-next-admin-portal` `epic-otp-logs-ui.md` (WUI-211..213) + INDEX. Branch `campaign/otp-logs-ui` (isolated worktree off origin/main, per §3c).

## 🔒 CONFIRMED: the OTP code is REDACTED
§ADR-23 P2 + OTPLOG-002 + WUI-212 ratify the TEETH rule: **`v_otp_logs` NEVER projects `otp_logs.otp` — the code is excluded by construction, even to super-admin** (the OTP analogue of the v_users no-secret-column rule; a pgTAP absence test enforces it). The mock page's click-to-reveal `otp` column is **deleted** in the UI spec. Any reveal/partial-mask/copy/export of the code is flagged a defect.

## Parity findings (grounded — mobiz Go @ 03d6383 + live dpay otp_logs ~51,190 docs; 2 agents corroborated)
- **Current production DOES have an operator OTP-log screen** (contrast: I expected maybe none): `GET /api/v1/otp-logs` + `/:id` + `/account/:acc_number` (routes/otplog.go:11-20), RBAC `otp-log:view` seeded **only to super_admin** (insert-roles.js:43). → who-reads parity = **super-admin-only**. ✅ mirrored.
- 🔴 **Current returns the raw OTP UNMASKED** (models/otp_logs.go:11). Next REDACTS it — a deliberate, owner-mandated divergence from parity. Documented as such.
- 🔴 **Current has NO retention** in code (unbounded raw-OTP PII window; db/indexes.go:255-258 plain index, 0 delete jobs). Live dpay shows ~7-day window (out-of-code TTL). Next BBOT-010 substrate already purges **24h-post-expiry** — tighter (a hardening, not re-decided here).
- **CORRECTION (P-004):** the brief said "introduce a NEW RBAC resource `otp-log`". GROUND TRUTH: `otp-log` is **ALREADY** a ratified §ADR-13 F3 catalogue member (rbac_seed_vs_catalogue_test.sql:90, `view create update delete`). So **NO catalogue-add**; the read rides existing `otp-log:view` (the user:view/system-bank:view precedent). The "NEW resource" framing is corrected in §ADR-23 P4.

## OPEN OWNER DECISIONS (escalated — current has no clean equivalent, NOT guessed)
- **(c1 / OQ-1, MATERIAL) Metadata-retention window** `[RATIFICATION_PENDING:owner]` `[ESCALATE_TO_HUMAN]` — 24h-post-expiry (substrate-ratified, tighter) vs a longer **redacted-metadata** archive (current keeps OTP-log rows unbounded). Substrate-level (§ADR-6/BBOT-010), owner-gated.
- **(OQ-2) `from_email` parity gap** — the next BBOT-010 `otp_logs` table OMITS `from_email` (current/dpay has it). The mock shows it; UI can't unless the substrate adds the column. Confirm: port the column or drop the field.
- **(OQ-3) Method badges (D/T/P/S)** — not relay-row fields (they're the system bank's config on bank_account_method). Join or drop.
- **(OQ-4) Parse-failure visibility** — no current equivalent; a parse failure never lands an otp_logs row (EF 400), so the view shows only successful saves. A failure viewer is net-new.
- **(c3) The redaction divergence** — recorded for owner awareness (not a decision): next never returns the code; current does.

## Next phase (later, owner-authorized — NOT started)
Build chain: next-dev authors the `v_otp_logs` migration (owner-context projection, code excluded, admin-tier WHERE gate, seed `super_admin:otp-log:view`) + pgTAP TEETH test → brew-ops deploys from main → next-ui wires `/otp-logs` to the view + drops the reveal column → de-preview. All per §ADR-23 §Scope boundary.