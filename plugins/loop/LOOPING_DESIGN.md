# Loop: Continuous Iteration Design

## Problem

The current skill runs once and outputs `<promise>RANDROID_LOOP_COMPLETE</promise>` when done. We need it to **loop continuously** (or for N iterations) with **fresh context on every loop**.

## Platform Comparison

| Feature | Claude Code | Codex |
|---------|-------------|-------|
| Hook support | Yes (Stop hook) | No (requested feature) |
| Non-interactive exec | `claude --print` | `codex exec` |
| JSON output | Yes | Yes (`--json`) |
| Fresh context mechanism | Stop hook rejects exit | External bash loop |

## Solution: Two Approaches

### Approach A: Claude Code (Stop Hook)

Based on the [Ralph Wiggum plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum).

**How it works:**
1. User runs `/loop research --loop` (or `--iterations N`)
2. Skill sets up state file with iteration count, completion promise
3. Stop hook intercepts session exit
4. If completion promise not found AND iterations remain, feed same prompt back
5. Each iteration sees modified files/git history but fresh conversational context

**Implementation:**

```
loop/
├── hooks/
│   └── stop-hook.sh          # Intercepts exit, manages loop
├── scripts/
│   └── setup-loop.sh         # Parses args, initializes state
├── state/
│   └── loop.local.md  # Tracks current state (gitignored)
└── ...
```

**State file format:**
```markdown
---
mode: research
iteration: 3
iterations: 10
git_workflow: push
completion_promise: RANDROID_LOOP_COMPLETE
started_at: 2026-01-16T15:00:00Z
---
```

**Git workflow options:**
| Workflow | Behavior |
|----------|----------|
| `commit` | Local commit only, no push |
| `push` | Commit and push to current branch (default) |
| `pr` | Open PR and wait for CI to pass |
| `pr-merge` | Open PR, wait for CI, then auto-merge |

**Stop hook logic (pseudo-code):**
```bash
#!/bin/bash
STATE_FILE="${CLAUDE_PLUGIN_ROOT}/state/loop.local.md"

# Read current state
iteration=$(grep "iteration:" "$STATE_FILE" | cut -d' ' -f2)
max_iterations=$(grep "max_iterations:" "$STATE_FILE" | cut -d' ' -f2)
mode=$(grep "mode:" "$STATE_FILE" | cut -d' ' -f2)

# Check if completion promise was output
if grep -q "RANDROID_LOOP_COMPLETE" /dev/stdin; then
    echo "Loop complete after $iteration iterations"
    exit 0  # Allow exit
fi

# Check iteration limit
if [[ $max_iterations -gt 0 && $iteration -ge $max_iterations ]]; then
    echo "Max iterations ($max_iterations) reached"
    exit 0  # Allow exit
fi

# Increment iteration
new_iteration=$((iteration + 1))
sed -i '' "s/iteration: $iteration/iteration: $new_iteration/" "$STATE_FILE"

# Reject exit and feed prompt back
echo "Iteration $new_iteration starting..."
exit 1  # Reject exit, triggering re-prompt
```

---

### Approach B: Codex (External Bash Loop)

Codex doesn't have hooks, so we use an **external wrapper script**.

**How it works:**
1. User runs `./scripts/randroid-loop.sh research --iterations 10`
2. Bash script loops, calling `codex exec` each time
3. Checks output for completion promise
4. Each `codex exec` is fresh context (no conversation history)

**Implementation:**

```
loop/
├── scripts/
│   └── randroid-loop.sh      # External loop wrapper for Codex
└── ...
```

**Wrapper script:**
```bash
#!/bin/bash
set -e

MODE="${1:-research}"
MAX_ITERATIONS="${2:-0}"  # 0 = unlimited
COMPLETION_PROMISE="RANDROID_LOOP_COMPLETE"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

MODE_FILE="${SKILL_DIR}/${MODE}-loop.md"
SHARED_FILE="${SKILL_DIR}/loop-shared.md"
OUTPUT_FILE="/tmp/randroid-output-$$.txt"

iteration=0

while true; do
    iteration=$((iteration + 1))
    echo "=== Loop $MODE iteration $iteration ==="

    # Build prompt (mode-specific + shared)
    PROMPT="$(cat "$MODE_FILE")

$(cat "$SHARED_FILE")"

    # Run Codex with the combined prompt
    codex exec --full-auto \
        --output-last-message "$OUTPUT_FILE" \
        "$PROMPT"

    # Check for completion
    if grep -q "$COMPLETION_PROMISE" "$OUTPUT_FILE"; then
        echo "Loop complete after $iteration iterations"
        break
    fi

    # Check iteration limit
    if [[ $MAX_ITERATIONS -gt 0 && $iteration -ge $MAX_ITERATIONS ]]; then
        echo "Max iterations ($MAX_ITERATIONS) reached"
        break
    fi

    echo "Iteration $iteration complete, continuing..."
    sleep 2  # Brief pause between iterations
done

rm -f "$OUTPUT_FILE"
```

**Usage:**
```bash
# Unlimited iterations until completion
./scripts/randroid-loop.sh research

# Limited to 10 iterations
./scripts/randroid-loop.sh implement 10
```

---

## Fresh Context Guarantee

Both approaches achieve **fresh context on every loop**:

| Approach | Context Behavior |
|----------|------------------|
| Claude Code (Stop Hook) | Each iteration starts with empty conversation history. Only files/git persist. |
| Codex (Bash Loop) | Each `codex exec` is a completely independent session. Only files/git persist. |

**What persists across iterations:**
- Modified files
- Git history and commits
- Dots system state
- Any artifacts written to disk

**What resets each iteration:**
- Conversation history
- In-memory state
- Token usage counter (fresh budget each time)

---

## Usage Design

### Claude Code

```bash
# Interactive mode selection (current behavior)
/loop

# Single iteration (current behavior)
/loop research

# Loop mode
/loop research --loop                 # Loop until complete
/loop implement --iterations 20       # Max 20 iterations

# Git workflow options
/loop implement --commit-only         # Local commits only
/loop implement --open-pr             # Open PR, wait for CI
/loop implement --pr-and-merge        # Open PR, wait for CI, merge
/loop implement --git-workflow pr     # Explicit workflow
```

### Codex

```bash
# From terminal (not inside Codex)
./scripts/randroid-loop.sh research        # Loop until complete
./scripts/randroid-loop.sh implement 20    # Max 20 iterations

# With git workflow (via setup-loop.sh, then run script)
./scripts/setup-loop.sh implement --iterations 10 --open-pr
./scripts/randroid-loop.sh

# Or with make/npm scripts
make loop-research
make loop-implement ITERATIONS=20
```

---

## Implementation Plan

### Phase 1: Codex Support (External Script)
1. Create `scripts/randroid-loop.sh` wrapper
2. Test with `codex exec --full-auto`
3. Add iteration tracking and output capture
4. Document usage

### Phase 2: Claude Code Support (Stop Hook)
1. Create `hooks/stop-hook.sh`
2. Create `scripts/setup-loop.sh` for arg parsing
3. Add state file management
4. Update SKILL.md with `--loop` and `--iterations` options
5. Test hook integration

### Phase 3: Unified Experience
1. Add Makefile/package.json scripts for easy invocation
2. Create `AGENTS.md` documentation for both platforms
3. Consider VS Code task integration

---

## Open Questions

1. **Pause between iterations?** Should there be a configurable delay?
2. **Error handling?** What happens if an iteration fails/crashes?
3. **Progress persistence?** Should we log iteration summaries to a file?
4. **Notification?** Alert user when loop completes (sound/notification)?

---

## Sources

- [Ralph Wiggum Plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)
- [Codex CLI Reference](https://developers.openai.com/codex/cli/reference/)
- [Codex Hooks Discussion](https://github.com/openai/codex/discussions/2150)
