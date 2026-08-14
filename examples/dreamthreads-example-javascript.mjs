import { randomUUID } from "node:crypto";

const apiKey = process.env.DREAMTHREADS_API_KEY;
if (!apiKey) throw new Error("Set DREAMTHREADS_API_KEY in your server environment.");

const response = await fetch("https://mydreamthreads.xyz/api/v1/dreamgraph/interpret", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${apiKey}`,
    "Content-Type": "application/json",
    "X-Request-ID": randomUUID(),
  },
  body: JSON.stringify({
    text: "I watched a snake in my garden. I felt peaceful.",
    waking_context: "I recently started caring for a garden.",
  }),
});

const result = await response.json();
if (!response.ok) throw new Error(`${result.error?.code}: ${result.error?.message}`);
console.log(JSON.stringify(result, null, 2));
