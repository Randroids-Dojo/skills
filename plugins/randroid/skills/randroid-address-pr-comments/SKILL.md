---
name: randroid-address-pr-comments
description: Address actionable pull-request review feedback end to end by locating the PR, resolving each current comment, implementing focused fixes, verifying them, and replying with evidence. Use when the user asks to handle PR comments, requested changes, unresolved review threads, or reviewer feedback.
---

# Address PR Comments

Resolve the current actionable review feedback without expanding the PR's scope.

## Workflow

1. Identify the pull request from the user's URL or number, the current branch, or repository metadata. If multiple candidates remain, ask for the exact PR.
2. Read current review comments, unresolved threads, requested changes, relevant CI failures, and the surrounding code before editing.
3. Classify each item as actionable, already resolved, stale after later changes, duplicate, or requiring user/product direction.
4. Implement the smallest coherent fix for every actionable item. Preserve unrelated user changes.
5. Run focused verification for each affected area, then run the repository's required broader checks when warranted.
6. Re-read current review state before replying so superseded or newly added feedback is not missed.
7. Treat an end-to-end request to address comments as authorization to reply only on the identified PR. If the user asked only to inspect, plan, or prepare fixes, do not post. When authorized, reply concisely with what changed and the verification evidence. End every GitHub reply written by this workflow with:

```text
-- Randroid (Randy's Bot)
```

8. Resolve threads only when the platform permits it and the response is genuinely complete. Do not merge, deploy, or publish unless the user separately authorized that action.
9. Finish with a receipt listing addressed items, deferred or blocked items, verification, and remaining review state.
