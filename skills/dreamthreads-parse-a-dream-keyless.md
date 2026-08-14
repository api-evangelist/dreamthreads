---
name: Parse a dream without a key
description: >-
  Turn one dream narrative into structured features (entities, actions, emotions, agency, threat,
  outcome, sensory cues, recurrence) using the DreamThreads keyless public parser. No account, no
  API key. Dream text is not stored.
api: openapi/dreamthreads-dreamgraph-openapi.yml
operations:
  - parseDreamPublicly
  - getDreamGraphHealth
generated: '2026-08-14'
method: generated
source: >-
  Grounded in openapi/_original/dreamthreads-dreamgraph-openapi.json (operationIds verified),
  conventions/dreamthreads-conventions.yml, rate-limits/dreamthreads-rate-limits.yml and
  errors/dreamthreads-problem-types.yml.
---

# Parse a dream without a key

Use this when a user wants structured extraction from a dream narrative and does **not** want a
generated interpretation. This is the free path: no credential, no account, no storage.

## Before you call

- Get the user's explicit permission before sending dream text anywhere.
- Base URL: `https://mydreamthreads.xyz/api/v1/dreamgraph`
- The narrative must be UTF-8 and **1–6,000 characters**. Longer text is a `400 invalid_dream`
  (or `413 payload_too_large` if the whole body is oversized) — truncate or ask the user to shorten
  it rather than retrying the same body.

## Steps

1. **(Optional) Check liveness** — `getDreamGraphHealth`: `GET /health`, no auth. A 200 means the
   edge is reachable. It does **not** mean the interpretation model is up, so do not use it as a
   pre-check for step 3 of the interpretation skill.
2. **Parse** — `parseDreamPublicly`: `POST /public/parse`, no auth.
   ```
   POST https://mydreamthreads.xyz/api/v1/dreamgraph/public/parse
   Content-Type: application/json
   X-Request-ID: <your uuid>

   { "text": "<the dream narrative>", "recurrence": "<optional hint the user supplied>" }
   ```
   Only send `recurrence` if the **user said so**. Never infer it.
3. **Read the envelope.** Success is `{ data, request_id, version }`. The analysis is at
   `data.structured_dream`, with `data.privacy` asserting `dream_text_stored: false` and
   `contribution_created: false`, and `data.timing.parser_latency_ms`.

## Rate limits

12 requests/minute and 100/day **per client**. Read `RateLimit-Remaining` and `RateLimit-Reset`
(unix seconds) off every 2xx and stop before you hit zero. On `429 rate_limit_exceeded`, wait until
`RateLimit-Reset` — there is no `Retry-After` to lean on.

## Errors

All errors are RFC 9457 `application/problem+json` carrying both `error.code` and `request_id`.

| Status | code | What to do |
|---|---|---|
| 400 | `invalid_dream` | Text is empty or over 6,000 chars. Fix the input; do not retry as-is. |
| 413 | `payload_too_large` | Shrink the body. |
| 422 | `parse_failed` | Validated but unparseable. Ask for a fuller narrative. Do **not** loop. |
| 429 | `rate_limit_exceeded` | Back off to `RateLimit-Reset`. |
| 500 | `internal_error` | Retry with backoff; quote `request_id` if you report it. |

## How to present the result

Describe the output as **extracted features**, never as a meaning, diagnosis, or prediction. If the
user wants a reading, say that a reflective interpretation exists behind reviewed partner access
(`data.upgrade.interpretation_api`) rather than inventing one yourself.
