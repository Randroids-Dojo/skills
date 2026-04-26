#!/bin/bash
#
# Loop - Stop Hook for Claude Code
#
# This hook intercepts session exit and feeds the prompt back
# to create a self-sustaining loop with fresh context each iteration.
#
# Iteration modes:
#   -1 = Infinite (ignore completion promise, loop forever)
#    0 = Until complete (stop when completion promise found)
#   >0 = Exact count (ignore completion promise, run exactly N times)
#
# State is tracked in: state/loop.local.md
#

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_FILE="${SKILL_DIR}/state/loop.local.md"

# If no state file, allow exit (not in loop mode)
if [[ ! -f "$STATE_FILE" ]]; then
    exit 0
fi

# Read state
read_state() {
    local key="$1"
    grep "^${key}:" "$STATE_FILE" 2>/dev/null | sed "s/^${key}: *//" || echo ""
}

MODE=$(read_state "mode")
ITERATION=$(read_state "iteration")
ITERATIONS=$(read_state "iterations")  # -1=infinite, 0=until complete, N=exact
GIT_WORKFLOW=$(read_state "git_workflow")
FRESH_CONTEXT=$(read_state "fresh_context")
COMPLETION_PROMISE=$(read_state "completion_promise")
BACKOFF_DELAY=$(read_state "backoff_delay")

# Default values
ITERATION=${ITERATION:-0}
ITERATIONS=${ITERATIONS:-0}
GIT_WORKFLOW=${GIT_WORKFLOW:-push}
FRESH_CONTEXT=${FRESH_CONTEXT:-false}
COMPLETION_PROMISE=${COMPLETION_PROMISE:-RANDROID_LOOP_COMPLETE}

# Exponential backoff settings
MIN_BACKOFF_DELAY=5
BACKOFF_DELAY=${BACKOFF_DELAY:-$MIN_BACKOFF_DELAY}

# If fresh context mode, let the wrapper script handle looping
if [[ "$FRESH_CONTEXT" == "true" ]]; then
    NEW_ITERATION=$((ITERATION + 1))

    # Update state with incremented iteration for wrapper to check
    cat > "$STATE_FILE" << EOF
---
mode: ${MODE}
iteration: ${NEW_ITERATION}
iterations: ${ITERATIONS}
git_workflow: ${GIT_WORKFLOW}
fresh_context: ${FRESH_CONTEXT}
completion_promise: ${COMPLETION_PROMISE}
backoff_delay: ${BACKOFF_DELAY}
updated_at: $(date -Iseconds)
---
EOF

    # Allow exit - wrapper script will restart claude
    exit 0
fi

# Read the last output from stdin (piped from Claude)
LAST_OUTPUT=$(cat)

# Only check completion promise in "until complete" mode (ITERATIONS=0)
if [[ $ITERATIONS -eq 0 ]]; then
    if echo "$LAST_OUTPUT" | grep -q "$COMPLETION_PROMISE"; then
        echo ""
        echo "========================================"
        echo "  LOOP COMPLETE (promise found)"
        echo "========================================"
        echo "Mode: $MODE"
        echo "Iterations: $ITERATION"
        echo "Completed at: $(date)"
        echo ""

        # Clean up state file
        rm -f "$STATE_FILE"

        # Play completion sound on macOS
        if command -v afplay &> /dev/null; then
            afplay /System/Library/Sounds/Glass.aiff 2>/dev/null &
        fi

        exit 0  # Allow exit
    fi
fi

# Check iteration limit (only for positive ITERATIONS values)
if [[ $ITERATIONS -gt 0 && $ITERATION -ge $ITERATIONS ]]; then
    echo ""
    echo "========================================"
    echo "  ITERATIONS COMPLETE"
    echo "========================================"
    echo "Mode: $MODE"
    echo "Completed $ITERATION iterations"
    echo "Finished at: $(date)"
    echo ""

    # Clean up state file
    rm -f "$STATE_FILE"

    # Play completion sound on macOS
    if command -v afplay &> /dev/null; then
        afplay /System/Library/Sounds/Glass.aiff 2>/dev/null &
    fi

    exit 0  # Allow exit
fi

# Continue looping: increment iteration and reject exit
NEW_ITERATION=$((ITERATION + 1))
NEW_BACKOFF_DELAY=$BACKOFF_DELAY

# Exponential backoff for infinite mode when completion promise is hit
if [[ $ITERATIONS -eq -1 ]]; then
    if echo "$LAST_OUTPUT" | grep -q "$COMPLETION_PROMISE"; then
        echo ""
        echo "No work this iteration, backing off for ${BACKOFF_DELAY}s..."
        sleep "$BACKOFF_DELAY"
        # Double the backoff delay (no max cap)
        NEW_BACKOFF_DELAY=$((BACKOFF_DELAY * 2))
    else
        # Meaningful work done, reset backoff
        if [[ $BACKOFF_DELAY -gt $MIN_BACKOFF_DELAY ]]; then
            echo "Work completed, resetting backoff delay"
        fi
        NEW_BACKOFF_DELAY=$MIN_BACKOFF_DELAY
    fi
fi

# Update state file
cat > "$STATE_FILE" << EOF
---
mode: ${MODE}
iteration: ${NEW_ITERATION}
iterations: ${ITERATIONS}
git_workflow: ${GIT_WORKFLOW}
fresh_context: ${FRESH_CONTEXT}
completion_promise: ${COMPLETION_PROMISE}
backoff_delay: ${NEW_BACKOFF_DELAY}
updated_at: $(date -Iseconds)
---
EOF

echo ""
echo "========================================"
echo "  LOOP - Iteration $NEW_ITERATION"
echo "========================================"
echo "Mode: $MODE"
if [[ $ITERATIONS -eq -1 ]]; then
    echo "Progress: $NEW_ITERATION (infinite)"
    if [[ $NEW_BACKOFF_DELAY -gt $MIN_BACKOFF_DELAY ]]; then
        echo "Current backoff: ${NEW_BACKOFF_DELAY}s"
    fi
elif [[ $ITERATIONS -eq 0 ]]; then
    echo "Progress: $NEW_ITERATION (until complete)"
else
    echo "Progress: $NEW_ITERATION / $ITERATIONS"
fi
echo ""

# Reject exit to trigger re-prompt
# Exit code 1 tells Claude Code to continue with the same prompt
exit 1
