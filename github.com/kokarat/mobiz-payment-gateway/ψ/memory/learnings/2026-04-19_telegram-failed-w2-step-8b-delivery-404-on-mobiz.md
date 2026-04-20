---
title: telegram-failed — W2 Step 8b delivery 404 on mobiz PR #230 summary
tags: [telegram-failed, workflow-bug, repo:cross, repo:mobiz-payment-gateway, w2, bot-delivery, mcp, recovered-from-double-wrap]
created: 2026-04-19
source: telegram_send() returned {"ok": false, "error": "Not Found", "error_code": 404} at 2026-04-19T15:05+07:00 — recovered 2026-04-19
project: github.com/kokarat/mobiz-payment-gateway
---

# telegram-failed — W2 Step 8b delivery 404 on mobiz PR #230 summary

telegram-failed — W2 Step 8b delivery 404 on mobiz PR #230 summary

At 2026-04-19T15:05+07:00 the mobiz W2 pass attempting to publish the Step 8b Telegram narrative summary for PR #230 received an HTTP 404 from the Telegram Bot API. Raw tool response: `{"ok": false, "error": "Not Found", "error_code": 404}`. The PR itself landed cleanly (bot-side and mobiz-side PRs both merged after human review); only the outbound Telegram notification failed.

Root-cause hypothesis (not verified at the time of the incident, filed as `#telegram-failed` per the W2 spec's fallback): the `telegram_send` MCP tool's `chat_id` resolution via `TELEGRAM_DEFAULT_CHAT_ID` env either returned an invalid chat id or the bot token is no longer a member of the target chat. 404 from the Telegram Bot API on a `sendMessage` call means either (a) the bot token is invalid — returns `401 Unauthorized`, or (b) the chat_id doesn't exist / the bot isn't in that chat — returns `400 Bad Request: chat not found`, or (c) the API method path is wrong — returns `404 Not Found`. This case was (c) or a gateway-layer 404 between the MCP server and api.telegram.org — the MCP plugin's URL construction is the first suspect.

Impact: zero downstream — the PR is the load-bearing artefact per W2 spec. The Step 8b note is informational. The `#telegram-failed` tag is the spec's documented escape hatch: file the learning, note the failure in the retro, and continue. Do NOT block the PR or retry the telegram send in-session — the MCP plugin has its own retry policy.

Followup candidate for separate investigation: confirm (a) the MCP server's construction of the Telegram API URL, (b) whether the bot token → chat_id → api.telegram.org path has regressed since the Step 8b addition landed earlier on 2026-04-19, (c) whether the 15:05 delivery failure is a one-off or represents a persistent outage. A re-test via `telegram_send` from a clean session on 2026-04-20 would disambiguate.

Context: Step 8b itself was added to the mobiz W2 workflow spec earlier on 2026-04-19 and this was one of the first real passes to exercise the step. First-run issues are expected; the workflow's fallback is by design to accept delivery failures rather than block PRs.

RECOVERED 2026-04-19 from double-wrap file `2026-04-19_title-telegram-failed-w2-step-8b-delivery-4.md`; supersedes `learning_2026-04-19_title-telegram-failed-w2-step-8b-delivery-4`.

---
*Added via Oracle Learn*
