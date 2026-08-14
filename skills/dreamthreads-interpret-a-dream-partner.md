---
name: Generate a reflective dream interpretation (partner key)
description: >-
  Call the reviewed-partner DreamGraph endpoints to produce a tentative, context-aware dream
  reflection with a factor trace and provenance, or a keyed structured parse with waking and
  physiological context. Requires a bearer partner key issued after human review.
api: openapi/dreamthreads-dreamgraph-openapi.yml
operations:
  - interpretDream
  - parseDream
  - getDreamGraphHealth
generated: '2026-08-14'
method: generated
source: >-
  Grounded in openapi/_original/dreamthreads-dreamgraph-openapi.json (operationIds verified),
  authentication/dreamthreads-authentication.yml, conventions/dreamthreads-conventions.yml and
  errors/dreamthreads-problem-types.yml.
---

# Generate a reflective dream interpretation

Use this only when the user actually wants a **reflection**. If structured extraction is enough, use
`parseDream` (keyed) or the keyless `parseDreamPublicly` skill instead — it is cheaper and needs no
credential.

## Credential

- `Authorization: Bearer <DREAMTHREADS_API_KEY>`, HTTP bearer, format "DreamThreads partner API key".
- Keys are issued **only after human review** at
  <https://mydreamthreads.xyz/dream-interpretation-api#request-access>. There is no self-serve key.
- The key is server-side only. It is origin-restricted, pausable and rotatable, and it must never
  appear in browser code. If it may have leaked, stop using it and email `rahim@mydreamthreads.xyz`
  for rotation.
- There is no test key and no sandbox: a partner key is a live key.

## Steps

1. **Interpret** — `interpretDream`: `POST /interpret`.
   ```
   POST https://mydreamthreads.xyz/api/v1/dreamgraph/interpret
   Authorization: Bearer $DREAMTHREADS_API_KEY
   Content-Type: application/json
   X-Request-ID: <your uuid>

   {
     "text": "<1-6000 char narrative>",
     "lens": "<optional short interpretive lens>",
     "waking_context": "<optional>",
     "physiological_context": "<optional>"
   }
   ```
   Send `waking_context` whenever the user has given it — context is the whole point of this API and
   it materially changes the reading.
2. **Read `data.interpretation`**: `essence`, `symbols[]`, `reading`, `question`, `reasonTrace[]`
   (`{factor, value, effect}` — why the reading moved), `provenance[]` (typed reviewed claims), plus
   `dreamgraphVersion`, `parserVersion` and `engineVersion`. Also present: `data.diagnostic`,
   `data.timing`, `data.attribution`.
3. **Or parse with context** — `parseDream`: `POST /parse`, same auth, accepts
   `text`, `waking_context`, `physiological_context`, `recurrence`. Returns structured context with
   no generated meaning. Use this for indexing, journaling, routing, research or analytics.

## Non-negotiable output rules

These come from the provider's own terms, not from style preference:

- The output is **reflective** — never diagnostic, predictive, supernatural, or a fixed statement of
  meaning. Do not market it as medical or psychological advice.
- **Preserve the uncertainty language.** Do not rewrite "may be" into "means".
- **Preserve `data.attribution`** — the provider name and the deep link must survive into whatever
  you render.
- Do not present a symbol as having one universal meaning; the reason trace exists so the user can
  see which of their own factors moved the reading.

## Errors

RFC 9457 `application/problem+json`, with `error.code` and `request_id` on every one.

| Status | code | What to do |
|---|---|---|
| 400 | `invalid_dream` | 1–6,000 characters required. |
| 401 | `invalid_api_key` | Key missing, invalid, or inactive — do not retry, re-issue. |
| 413 | `payload_too_large` | Shrink the body. |
| 429 | `rate_limit_exceeded` | Partner quotas are set during review and not published; back off. |
| 502 | `interpretation_failed` | Upstream model failed. Retry with backoff, or fall back to `parseDream` for structure without a reading. |
| 503 | `feature_disabled` | The capability is off for this partner. Contact support with `request_id`. |

There is no idempotency key. Every call is a fresh computation, so a retry after a 5xx is safe but
will consume quota.
