---
name: task-tracking-dots-html
description: Manages task tracking with the HTML-backed Dots fork from Randroids-Dojo/dots-html. Use when tracking work items across sessions with dot-html CLI files stored as .html documents.
compatibility: Requires curl and either a matching GitHub release asset or Zig 0.15+ for source builds.
---

# Task Tracking with HTML Dots

Use the `dot-html` CLI from `Randroids-Dojo/dots-html` to track work items across sessions. This fork stores dots as `.html` documents under `.dots/`.

## Preflight

Check for the CLI:

```bash
command -v dot-html >/dev/null 2>&1 && dot-html --version
```

If `dot-html` is missing, install this fork:

```bash
plugins/task-tracking-dots-html/scripts/install-html-dots.sh
```

When installed from a global skill, run the script from the installed skill directory. If the release has no matching binary asset for the current OS/architecture, the script clones `https://github.com/Randroids-Dojo/dots-html` and builds with Zig.

## Session Workflow

At the start of every session:

```bash
dot-html ls
dot-html ready
```

Before starting work:

```bash
dot-html on <id>
```

After completing work:

```bash
dot-html off <id> -r "What was done"
```

Never leave completed tasks open. Close with a short reason.

## Creating Dots

```bash
dot-html "Fix the bug"
dot-html add "Design API" -p 1 -d "Details"
dot-html add "Subtask" -P dots-1
dot-html add "After X" -a dots-2
```

## Inspecting Work

```bash
dot-html ls
dot-html ready
dot-html show dots-1
dot-html tree
dot-html find "query"
```

## File Storage

New dots are stored as HTML files:

```text
.dots/
  dots-example-1234abcd.html
  dots-parent-2345bcde/
    dots-parent-2345bcde.html
    dots-child-3456cdef.html
```

The CLI owns these files. Prefer `dot-html` commands for changes so status, dependencies, archive moves, and parent-child paths stay consistent.
