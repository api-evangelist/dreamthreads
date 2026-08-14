import json
import os
import urllib.error
import urllib.request
import uuid

api_key = os.environ.get("DREAMTHREADS_API_KEY")
if not api_key:
    raise RuntimeError("Set DREAMTHREADS_API_KEY in your server environment.")

request = urllib.request.Request(
    "https://mydreamthreads.xyz/api/v1/dreamgraph/interpret",
    data=json.dumps({
        "text": "I watched a snake in my garden. I felt peaceful.",
        "waking_context": "I recently started caring for a garden.",
    }).encode("utf-8"),
    headers={
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "X-Request-ID": str(uuid.uuid4()),
    },
    method="POST",
)

try:
    with urllib.request.urlopen(request, timeout=30) as response:
        print(json.dumps(json.load(response), indent=2))
except urllib.error.HTTPError as error:
    print(error.read().decode("utf-8"))
    raise
