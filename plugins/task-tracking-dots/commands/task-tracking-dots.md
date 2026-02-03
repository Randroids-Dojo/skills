# Task Tracking with Dots

Use the `dot` CLI to track work items across sessions and manage dependencies. Always check open tasks, mark work in progress, and close tasks with a completion reason.

## Preflight

Confirm the `dot` CLI is available:

```bash
command -v dot >/dev/null 2>&1
```

If `dot` is missing, install it and verify:

```bash
brew install joelreymont/tap/dots
dot --version
```

## Quick Reference

```bash
# Start of session
dot ls
dot ready

# Work on a task
dot on <id>
dot off <id> -r "What was done"

# Create dots
dot "Fix the bug"
dot add "Design API" -p 1 -d "Details"
dot add "Subtask" -P dots-1
dot add "After X" -a dots-2

# Inspect
dot show dots-1
dot tree
dot find "query"
```

For full guidance, read `${CLAUDE_PLUGIN_ROOT}/SKILL.md`.
