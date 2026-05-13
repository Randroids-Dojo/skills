# Task Tracking with HTML Dots

Use the `dot` CLI from `Randroids-Dojo/dots-html`; it stores tasks as `.html` files under `.dots/`.

## Preflight

```bash
command -v dot >/dev/null 2>&1 && dot --version
```

Install this fork if needed:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/install-html-dots.sh
```

## Quick Reference

```bash
dot ls
dot ready
dot on <id>
dot off <id> -r "What was done"

dot "Fix the bug"
dot add "Subtask" -P dots-1
dot add "After X" -a dots-2

dot show dots-1
dot tree
dot find "query"
```

For full guidance, read `${CLAUDE_PLUGIN_ROOT}/SKILL.md`.
