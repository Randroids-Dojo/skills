---
name: randroid
description: "Randroid command namespace. Use when the user asks for available Randroid slash commands or invokes /randroid directly."
---

# Randroid Commands

## loop

Run the autonomous research/implementation loop. In Claude Code, use `/randroid:loop`.

The loop supports either task tracker:
- `dot-html` for HTML-backed tasks under `.dots/`
- `dot` for Markdown-backed tasks under `.dots/`

Each iteration detects the project tracker and uses the selected command as `$DOT`. Do not mix `dot` and `dot-html` in one project.

Bundled loop resources:
- `commands/loop.md`: Claude Code slash command instructions
- `research-loop.md` and `implement-loop.md`: mode-specific prompts
- `loop-shared.md`: shared task tracker, git workflow, iteration, and completion rules
- `scripts/setup-loop.sh`: initializes loop state
- `scripts/randroid-loop.sh`: external loop wrapper for Codex
- `hooks/stop-hook.sh`: Claude Code keep-context loop hook

## address-pr-comments

Address every actionable PR review comment end to end: inspect the feedback, update the code, verify the change, and reply clearly.

## Workflow

1. Identify the target PR from the user's link/number, the current branch, or the available GitHub tooling. If no PR can be identified, ask for the PR URL or number.
2. Gather all review comments, review threads, requested changes, and relevant CI context. Prefer thread-aware APIs when available so resolved and outdated comments are not mistaken for open work.
3. Classify each comment as actionable, already addressed, outdated, duplicate, or needing clarification. Do not ignore requested changes.
4. Implement fixes for all actionable comments. Keep edits scoped to the review feedback unless a nearby change is required for correctness.
5. Run the smallest meaningful verification for the changed area. If verification cannot run, say exactly why in the PR response and final message.
6. Reply to each addressed thread, or leave a concise PR summary if the available tooling cannot reply inline. Mention what changed and any tests run.
7. Do not mark a thread resolved unless the issue is actually fixed or the reviewer explicitly made it non-actionable.

## Comment Signature

Every comment or reply posted to GitHub must end with this signature on its own line:

```text
-- Randroid (Randy's Bot)
```

Do not use a different sign-off. Do not omit the signature from inline review replies, PR comments, or review summaries.

## Response Style

- Be specific about the files or behavior changed.
- Keep replies short; reviewers need status, not a changelog.
- If a comment is not actionable, explain why and sign the reply.
- If user approval is required before posting comments in the current harness, prepare the exact signed comment text and ask before posting.
