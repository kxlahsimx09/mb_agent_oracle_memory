---
title: jsonb key-reorder breaks byte-equal cached-response assertions; sort-keys before
tags: [next-impl, repo:mb-next-payment-gateway, testing, jsonb, postgres, idempotency, semantic-equality, cached-response, replay, sorted-keys]
created: 2026-05-15
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# jsonb key-reorder breaks byte-equal cached-response assertions; sort-keys before

# jsonb key-reorder breaks byte-equal cached-response assertions; sort-keys before comparing

When testing that a cached/replayed response equals a live response, **Postgres `jsonb` normalizes key order on store** — so the cached body fetched back from the DB will have keys in a different order than the live body the handler returned (even though both encode the same object). Byte-equal `JSON.stringify(a) === JSON.stringify(b)` fails. The replay contract pins **semantic identity**, not serialization byte-equality.

## Where it bit (DEPOSIT-001 AC #3 idempotency probe, PR #104)

Idempotency middleware caches the first response in `idempotency_keys.response_body jsonb` via `complete_idempotency_record(p_response_body jsonb)`. On replay, the middleware returns the cached body via `json(slot.replay_body, slot.replay_status)`. AC #3 probe stringified both bodies and compared:

```ts
// FAIL: jsonb storage reordered keys
const bodyMatch = JSON.stringify(secondJson) === JSON.stringify(firstJson);
// Result: status_match=true, body_match=false, row_delta=1 (everything else fine)
```

Live response shape: `{ deposit: { deposit_id, payment_account_number, ..., qrcode, qr_type, promptpay_number } }` — keys in handler's insertion order. Cached body comes back with keys reordered (Postgres-internal canonical jsonb form). Both encode identical state.

## Fix — sorted-key recursive stringify

```ts
function sortedStringify(v: unknown): string {
  return JSON.stringify(v, function replacer(_k, val) {
    if (val && typeof val === "object" && !Array.isArray(val)) {
      return Object.keys(val).sort().reduce((acc: any, k) => { acc[k] = (val as any)[k]; return acc; }, {});
    }
    return val;
  });
}
const bodyMatch = sortedStringify(secondJson) === sortedStringify(firstJson);
```

Recurses into nested objects (the `replacer` fires for every key during the walk), leaves arrays untouched (array order IS semantic).

## Generalization

Applies to any test that:
- round-trips a response/payload through a `jsonb` column (idempotency cache, audit log, callback outbox, append-only event store)
- then asserts equality with a live-generated version

Includes: §ADR-9 callback outbox `event_body jsonb`; §ADR-10 audit ledger `payload jsonb`; admin-web realtime snapshots; any future replay/cache primitive.

## Anti-patterns to avoid

- **Byte-stringify on both sides** — fails on key order; sometimes fails on whitespace if one side is `jsonb_pretty()`.
- **Field-by-field hand-pick** — brittle as fields evolve; misses fields the test author didn't list.
- **`JSON.parse(JSON.stringify(x))` "normalize"** — does NOT sort keys; just deep-copies.

## Related

- DEPOSIT-001 AC #3 spec language: *"returns the originally-stored response (replay-safe)"* — "originally-stored" = semantic, the cache substrate's serialization choices are implementation detail.
- §ADR-11 C4 + C5 (idempotency contract + invariant).
- Generic JSON canonicalization standard: RFC 8785 JCS — keys sorted lexicographically + numbers normalized + escapes minimal. The sorted-key replacer above is the "keys-only" subset; sufficient when the data path doesn't introduce number-format ambiguity.

— filed by next-impl, post-PR-#104 retro 2026-05-15 GMT+7.

---
*Added via Oracle Learn*
