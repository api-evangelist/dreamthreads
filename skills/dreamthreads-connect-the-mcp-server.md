---
name: Connect an agent to the DreamThreads MCP server
description: >-
  Attach a Model Context Protocol client to the keyless DreamThreads DreamGraph server over
  Streamable HTTP and use its two bounded read-only tools — parse_dream and search_dream_concepts.
api: mcp/dreamthreads-mcp.yml
operations:
  - parse_dream
  - search_dream_concepts
generated: '2026-08-14'
method: generated
source: >-
  Grounded in the live anonymous tools/list response saved verbatim at
  mcp/dreamthreads-mcp-tools-list.json, the registry manifest at
  well-known/dreamthreads-mcp-server.json, and mcp/dreamthreads-tool-crosswalk.yml.
---

# Connect an agent to the DreamThreads MCP server

A remote, keyless MCP server. Nothing to install and no credential to obtain — an agent can reach it
immediately.

## Connect

```json
{
  "servers": {
    "dreamthreads": {
      "type": "http",
      "url": "https://mydreamthreads.xyz/mcp"
    }
  }
}
```

- Transport: Streamable HTTP. Send `Accept: application/json, text/event-stream`.
- Auth: **none**. Verified anonymously — `tools/list` returns 200 with full JSON Schema
  (2020-12) `inputSchema` and `outputSchema` for both tools.
- Registry metadata: `https://mydreamthreads.xyz/.well-known/mcp/server.json`
  (`io.github.abdulrahimiqbal/dreamthreads`, v1.0.1).
- Limit: **60 protocol requests per minute per client.**

## Tools

### `parse_dream`
Extract structured entities, actions, emotions, agency, threat, outcome, sensory cues and recurrence
from one narrative.

- Input: `text` (required, 1–6,000 chars); `recurrence` (optional boolean or ≤80-char string).
- Only pass `recurrence` if the user supplied it. The tool description says so explicitly: *omit
  rather than infer it.*
- Output: `structured_dream`, `privacy` (`dream_text_stored: false`, `contribution_created: false`),
  `attribution` (`provider`, `methodology_url`).
- Annotations: `readOnlyHint: true`, `destructiveHint: false`, `idempotentHint: true`,
  `openWorldHint: false`.
- Backing REST operation: `parseDreamPublicly` (`POST /public/parse`).

### `search_dream_concepts`
Search the stable DreamGraph vocabulary for a dream element or experience.

- Input: `query` (required, 2–100 chars, e.g. "snake", "falling", "unable to move");
  `limit` (1–12, default 8).
- Output: `query`, `results[]` of `{id, slug, name, type, description, url}`, plus `attribution`.
- **No REST equivalent exists.** This capability is reachable only through MCP — do not look for an
  HTTP endpoint for it.

## What this server will not do

By design it is bounded to extraction and vocabulary lookup. It does **not** generate
interpretations, diagnoses, predictions, supernatural claims, or fixed symbolic meanings. Reflective
interpretation lives behind `interpretDream` and a reviewed partner key.

## Presenting results

Describe `structured_dream` as extracted features. Present concept results as descriptive concepts,
**not** as universal symbolic definitions. Keep the returned `attribution.provider` and
`methodology_url` in whatever you render, and get the user's permission before sending their dream
text.
