#!/usr/bin/env sh
set -eu

curl --silent --show-error --fail-with-body https://mydreamthreads.xyz/api/v1/dreamgraph/public/parse \
  -H "Content-Type: application/json" \
  -H "X-Request-ID: dreamthreads-public-example-curl" \
  -d '{
    "text": "I watched a snake in my garden. I felt peaceful."
  }'
