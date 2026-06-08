# /randroid:address-pr-comments

Address all actionable PR review comments on the current branch or a specified pull request.

## Use

1. Find the target PR from the current branch, a PR number, or a PR URL.
2. Read review comments, unresolved threads, requested changes, and relevant CI context.
3. Implement fixes for every actionable comment.
4. Run focused verification.
5. Reply to the reviewed threads or PR with concise signed comments.

Every GitHub comment or reply must end with:

```text
-- Randroid (Randy's Bot)
```

For full guidance, read `${CLAUDE_PLUGIN_ROOT}/SKILL.md`.
