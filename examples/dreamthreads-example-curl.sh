#!/usr/bin/env sh
set -eu

: "${DREAMTHREADS_API_KEY:?Set DREAMTHREADS_API_KEY in your server environment}"

curl --fail-with-body https://mydreamthreads.xyz/api/v1/dreamgraph/interpret \
  -H "Authorization: Bearer $DREAMTHREADS_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-Request-ID: dreamthreads-example-curl" \
  -d '{
    "text": "I watched a snake in my garden. I felt peaceful.",
    "waking_context": "I recently started caring for a garden."
  }'
