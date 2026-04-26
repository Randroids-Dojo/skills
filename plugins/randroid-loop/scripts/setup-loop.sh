#!/bin/bash
#
# Loop - Setup Script for Claude Code
#
# Initializes the loop state file for the stop hook to use.
#
# Usage:
#   ./setup-loop.sh <mode> [options]
#
# Options:
#   --iterations <N>    Set iteration mode (see below)
#   --loop, --infinite  Run forever (Ctrl+C to stop)
#   --until-complete    Run until completion promise (default)
#   --git-workflow <W>  Set git workflow (see below)
#   --commit-only       Shorthand for --git-workflow commit
#   --open-pr           Shorthand for --git-workflow pr
#   --pr-and-merge      Shorthand for --git-workflow pr-merge
#   --fresh-context     Clear context between iterations (requires wrapper script)
#
# Iteration modes:
#   -1 = Infinite (ignore completion promise, loop forever)
#    0 = Until complete (stop when completion promise found)
#   >0 = Exact count (ignore completion promise, run exactly N times)
#
# Git workflows:
#   commit   = Commit locally only (no push)
#   push     = Commit and push to current branch (default)
#   pr       = Open PR and wait for CI to pass
#   pr-merge = Open PR, wait for CI, then merge
#

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${SKILL_DIR}/state"
STATE_FILE="${STATE_DIR}/loop.local.md"

# Parse arguments
MODE=""
ITERATIONS=0  # Default: until complete
GIT_WORKFLOW="push"  # Default: commit and push
FRESH_CONTEXT="false"  # Default: keep context (Claude Code stop hook)
DIRECTIONS=""  # Optional user guidance

while [[ $# -gt 0 ]]; do
    case "$1" in
        research|implement)
            MODE="$1"
            shift
            ;;
        --iterations)
            ITERATIONS="$2"
            shift 2
            ;;
        --loop|--infinite)
            ITERATIONS=-1
            shift
            ;;
        --until-complete)
            ITERATIONS=0
            shift
            ;;
        --git-workflow)
            GIT_WORKFLOW="$2"
            shift 2
            ;;
        --commit-only)
            GIT_WORKFLOW="commit"
            shift
            ;;
        --open-pr)
            GIT_WORKFLOW="pr"
            shift
            ;;
        --pr-and-merge)
            GIT_WORKFLOW="pr-merge"
            shift
            ;;
        --fresh-context)
            FRESH_CONTEXT="true"
            shift
            ;;
        --directions)
            DIRECTIONS="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$MODE" ]]; then
    echo "Error: Mode (research or implement) is required"
    exit 1
fi

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Validate git_workflow
case "$GIT_WORKFLOW" in
    commit|push|pr|pr-merge)
        ;;
    *)
        echo "Error: Invalid git workflow: $GIT_WORKFLOW"
        echo "Valid options: commit, push, pr, pr-merge"
        exit 1
        ;;
esac

# Create state file
cat > "$STATE_FILE" << EOF
---
mode: ${MODE}
iteration: 0
iterations: ${ITERATIONS}
git_workflow: ${GIT_WORKFLOW}
fresh_context: ${FRESH_CONTEXT}
completion_promise: RANDROID_LOOP_COMPLETE
backoff_delay: 5
started_at: $(date -Iseconds)
---
EOF

# Append directions as markdown content (if provided)
if [[ -n "$DIRECTIONS" ]]; then
    cat >> "$STATE_FILE" << EOF

## User Directions

$DIRECTIONS
EOF
fi

echo "Loop initialized:"
echo "  Mode: $MODE"
if [[ $ITERATIONS -eq -1 ]]; then
    echo "  Iterations: INFINITE (Ctrl+C to stop)"
    echo "  Completion promise: IGNORED"
elif [[ $ITERATIONS -eq 0 ]]; then
    echo "  Iterations: until RANDROID_LOOP_COMPLETE"
else
    echo "  Iterations: exactly $ITERATIONS"
    echo "  Completion promise: IGNORED"
fi
echo "  Git workflow: $GIT_WORKFLOW"
echo "  Fresh context: $FRESH_CONTEXT"
if [[ -n "$DIRECTIONS" ]]; then
    echo "  Directions: (provided)"
fi
echo "  State file: $STATE_FILE"
echo ""
