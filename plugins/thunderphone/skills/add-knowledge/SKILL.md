---
name: add-knowledge
description: Create, import, search, update, or attach ThunderPhone knowledge. Use when someone asks to upload documents, import a URL, create a knowledge base, wait for indexing, search retrieved content, attach knowledge_base_ids or knowledge_document_ids to an agent, or debug missing answers.
license: MIT
compatibility: Requires THUNDERPHONE_API_KEY and rights to the source content.
metadata:
  author: thunderphone
  version: "1.0"
---

# Add knowledge to an agent

1. **Prepare the source.** Use content the organization is authorized to store
   and expose to callers. Remove secrets and unrelated personal data. Prefer
   clear headings, canonical facts, and one maintained source per fact.
2. **Choose a container.** Use `POST /v1/knowledge-bases` to group related
   material. Use flat `POST /v1/knowledge/documents` for a standalone upload or
   text document. Use `POST /v1/knowledge/documents/import-url` for a permitted
   URL.
3. **Submit the content.** For files, send multipart form data and retain the
   returned document ID. For URL imports, record the canonical source URL and
   refresh policy.

Canonical JSON request for importing a permitted web page:

```json request POST /v1/knowledge/documents/import-url
{
  "url": "https://example.com/pricing",
  "name": "Pricing"
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/knowledge/documents \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "X-ThunderPhone-Client: skills/add-knowledge@1.0" \
  -F "file=@$DOCUMENT_PATH"
```

```python
import os, requests

with open(os.environ["DOCUMENT_PATH"], "rb") as document:
    r = requests.post("https://api.thunderphone.com/v1/knowledge/documents",
        files={"file": document},
        headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
                 "X-ThunderPhone-Client": "skills/add-knowledge@1.0"}, timeout=120)
r.raise_for_status()
print(r.json())
```

```ts
import { openAsBlob } from "node:fs";
const form = new FormData();
form.set("file", await openAsBlob(process.env.DOCUMENT_PATH!));
const response = await fetch("https://api.thunderphone.com/v1/knowledge/documents", {
  method: "POST", headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "X-ThunderPhone-Client": "skills/add-knowledge@1.0" }, body: form,
});
if (!response.ok) throw new Error(await response.text());
console.log(await response.json());
```

4. **Wait for readiness.** Poll `GET /v1/knowledge/documents/{document_id}` or
   the knowledge-base document list. Do not attach or test content still marked
   pending/processing. Investigate failed indexing before retrying.
5. **Search directly.** Use `POST /v1/knowledge/search` or
   `POST /v1/knowledge-bases/{knowledge_base_id}/search` with representative
   caller questions. Check that the retrieved passage supports the intended
   answer and excludes unrelated content.
6. **Attach to the agent.** Patch `knowledge_base_ids` and/or
   `knowledge_document_ids`,
   review the draft, deploy it, and run spoken test scenarios.
7. **Verify.** Test exact facts, paraphrases, conflicts, missing information,
   and content the agent should refuse to invent. Confirm source updates are
   reindexed before relying on them.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Document remains processing | Import or extraction has not completed | Poll with backoff; inspect failure detail before the retry endpoint. |
| Search returns irrelevant passages | Document is broad, duplicated, or poorly structured | Split and clean sources, then re-run representative queries. |
| Agent cannot use ready content | IDs are not attached to the deployed revision | Patch the agent, review its draft, and deploy. |
| Agent states unsupported facts | Prompt allows guessing or sources conflict | Add a no-invention boundary and remove or reconcile stale sources. |

## Source and safety rules

- Follow [knowledge base](https://thunderphone.com/docs/guides/knowledge-base.md) and the [knowledge API reference](https://thunderphone.com/docs/api-reference/knowledge-bases.md).
- Do not upload content without rights or expose secrets and unnecessary personal data.
- Direct search quality is evidence for retrieval, not proof of spoken answer quality.
- Preserve source provenance and remove stale copies rather than relying on ordering.

See [references/knowledge-lifecycle.md](references/knowledge-lifecycle.md).
