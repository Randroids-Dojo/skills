# Task Tracking with HTML Dots

Use the `dot-html` CLI from `Randroids-Dojo/dots-html`; it stores tasks as `.html` files under `.dots/`.

## Preflight

```bash
command -v dot-html >/dev/null 2>&1 && dot-html --version
```

Install this fork if needed:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/install-html-dots.sh
```

## Quick Reference

```bash
dot-html ls
dot-html ready
dot-html on <id>
dot-html off <id> -r "What was done"

dot-html "Fix the bug"
dot-html add "Subtask" -P dots-1
dot-html add "After X" -a dots-2

dot-html show dots-1
dot-html tree
dot-html find "query"
```

For full guidance, read `${CLAUDE_PLUGIN_ROOT}/SKILL.md`.
