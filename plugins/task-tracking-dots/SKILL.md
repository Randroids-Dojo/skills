---
name: task-tracking-dots
description: "Create, list, complete, and block tasks using the Dots CLI with priorities and dependencies. Use when tracking todos, managing a task list, recording progress across sessions, setting task blockers, or coordinating dependent work items."
compatibility: "Requires the dot CLI available in the session environment."
---

# Task Tracking with Dots

Dots is a lightweight task tracker for managing work across sessions. Use the `dot` CLI to create tasks, list pending items, mark tasks complete with reasons, set blockers, and track dependencies.

## Preflight: ensure dot is installed

Before running any workflow commands, check for the `dot` CLI:

```bash
command -v dot >/dev/null 2>&1
```

If `dot` is not found, install it.

Homebrew:

```bash
brew install joelreymont/tap/dots
```

From source (requires Zig 0.15+):

```bash
git clone https://github.com/joelreymont/dots.git
cd dots
zig build -Doptimize=ReleaseSmall
cp zig-out/bin/dot ~/.local/bin/
```

Make sure `~/.local/bin` is on your `PATH`, then verify:

```bash
dot --version
```

## Essential Session Workflow

At the start of every session:

```bash
dot ls
dot ready
```

Before starting any task:

```bash
dot on <id>
```

After completing any task:

```bash
dot off <id> -r "What was done"
```

Never leave completed tasks open. Always close with a short reason.

---

## Creating Dots

```bash
# Quick add
dot "Fix the bug"

# With priority and description
dot add "Design API" -p 1 -d "Details"

# As child of another dot
dot add "Subtask" -P dots-1

# Depends on another dot
dot add "After X" -a dots-2
```

### Priority Levels

| Level | Meaning |
|------:|---------|
| 0 | Critical (do now) |
| 1 | High |
| 2 | Medium (default) |
| 3 | Low |
| 4 | Backlog |

---

## Working With Dots

```bash
dot ls              # List open dots
dot ready           # Show unblocked dots
dot show dots-1     # Show dot details
dot tree            # Show hierarchy
dot find "query"   # Search dots
```

Workflow reminders:
- Always check open/ready dots before starting new work.
- Use `dot on <id>` before work begins.
- Use `dot off <id> -r "..."` immediately after completion.

---

## Closing Tasks Properly

Every completed task needs a reason. Keep it brief and specific.

```bash
dot off dots-5 -r "Fixed null check in player.gd"
dot off dots-12 -r "Already implemented in previous session"
dot off dots-3 -r "Created PR #42, awaiting review"
```

If you discover a task is already done, close it with evidence in the reason.

---

## Partial Progress

If a task is only partially complete:
- Create a subtask to capture the remaining work, or
- Create a follow-up dot that depends on the current one.

This keeps the current dot accurate and preserves context for the next session.

---

## Dots vs TodoWrite

- **Dots**: multi-step work, tasks that may span sessions, or work with dependencies.
- **TodoWrite**: small, single-session checklists meant to be visible to the user.

When work changes the repository, update the corresponding dot immediately.
