---
name: Telegram direct-transfer templates — escapeMD for underscore/asterisk/backtick/bracket in dynamic fields
description: As of bd10835 (2026-04-16, PR #162), services/telegramNotify.go applies escapeMD to every dynamic field in the four direct-transfer notification templates. Username "AMPAYCS1_BAS" tripped Telegram's legacy Markdown italic parser. sendMessage also now logs non-200 response bodies.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - telegram
  - notifications
source: services/telegramNotify.go @ 3b7e0f1
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Telegram direct-transfer templates — escapeMD for Markdown metacharacters

## Fact

`services/telegramNotify.go` gained `escapeMD(s string) string` which escapes the four characters Telegram's legacy "Markdown" parse mode treats as formatting metacharacters: underscore, asterisk, backtick, and left-bracket.

All dynamic fields in the four direct-transfer templates now pass through `escapeMD` before `fmt.Sprintf`:

- `SendTransferCreated`
- `SendTransferApproved`
- `SendTransferCompleted`
- `SendTransferFailed`

Static template text (headers, dividers, emoji, bold labels) is not escaped, so the message still renders with the same formatting.

`sendMessage` now reads the Telegram response body on non-200 replies via `io.ReadAll`, so the actual parse-mode error (e.g. "can't parse entities: can't find end of italic entity at byte offset N") ends up in the bot log instead of "telegram API returned status 400" with no reason.

Other templates (pullout, settlement, report, bank alert) are **not** escaped — they use different formatting and none have hit this bug in production. Can be migrated if a similar silent-drop incident appears.

## Why

Production trigger: the shared ops username "AMPAYCS1_BAS" contains an underscore. Telegram's legacy Markdown parser treats underscore as an italic-run start marker, sees an unclosed italic run (because the next underscore never arrives), and returns 400 Bad Request. The goroutine logged "telegram API returned status 400" with no reason and the team never knew which message was bad. Approve notifications survived by accident — their template happened to have fewer bold runs and a shorter field list, so the parser recovered before hitting the end.

## How to apply

- Any new Telegram template that interpolates a username, bank name, amount, or any other user-provided field must run the field through `escapeMD` before Sprintf. Do not trust that "it looks like plain text" — `AMPAYCS1_BAS` looks plain too.
- Switching the bot to HTML parse mode would remove the escape requirement, but every existing template would need a rewrite. Not proposed for now.
- `escapeMD` is internal to `telegramNotify.go` — if a second file needs the same logic, lift it into a shared helper rather than copy-paste.
- When a Telegram call fails, the body (not the status) is the diagnosis. Keep the `io.ReadAll` branch.

## Trace

commit `3b7e0f1` (specifically `bd10835` #162) → docs/current-system.md §6.7 + §8.4 → resolution PR #173
