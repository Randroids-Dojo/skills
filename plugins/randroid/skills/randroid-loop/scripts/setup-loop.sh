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
#   --task-tracker <T>  Select dot or dot-html when no state exists
#   --no-commit         Shorthand for --git-workflow none
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
#   none     = Leave verified changes uncommitted
#   commit   = Commit locally only (no push, default)
#   push     = Commit and push to current branch
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
GIT_WORKFLOW="commit"  # Safe default: local commit only
FRESH_CONTEXT="false"  # Default: keep context (Claude Code stop hook)
DIRECTIONS=""  # Optional user guidance
REQUESTED_TASK_TRACKER=""

detect_task_tracker() {
    local has_html="false"
    local has_markdown="false"
    [[ -d ".dots" ]] && find .dots -name '*.html' -print -quit 2>/dev/null | grep -q . && has_html="true"
    [[ -d ".dots" ]] && find .dots -name '*.md' -print -quit 2>/dev/null | grep -q . && has_markdown="true"

    if [[ "$has_html" == "true" && "$has_markdown" == "true" ]]; then
        echo "conflict"
    elif [[ "$has_html" == "true" ]]; then
        echo "dot-html"
    elif [[ "$has_markdown" == "true" ]]; then
        echo "dot"
    elif [[ -n "$REQUESTED_TASK_TRACKER" ]]; then
        echo "$REQUESTED_TASK_TRACKER"
    elif command -v dot-html >/dev/null 2>&1 && command -v dot >/dev/null 2>&1; then
        echo "ambiguous"
    elif command -v dot-html >/dev/null 2>&1; then
        echo "dot-html"
    elif command -v dot >/dev/null 2>&1; then
        echo "dot"
    else
        echo "missing"
    fi
}

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
        --task-tracker)
            REQUESTED_TASK_TRACKER="$2"
            shift 2
            ;;
        --no-commit)
            GIT_WORKFLOW="none"
            shift
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
TASK_TRACKER="$(detect_task_tracker)"

case "$TASK_TRACKER" in
    dot|dot-html)
        if ! command -v "$TASK_TRACKER" >/dev/null 2>&1; then
            echo "Error: Selected task tracker is unavailable: $TASK_TRACKER"
            exit 1
        fi
        ;;
    ambiguous)
        echo "Error: Both dot and dot-html are available but this project has no existing Dots state. Pass --task-tracker dot or --task-tracker dot-html."
        exit 1
        ;;
    conflict)
        echo "Error: .dots contains both Markdown and HTML task files. Resolve the tracker conflict before starting the loop."
        exit 1
        ;;
    *)
        echo "Error: No supported Dots task tracker is available."
        exit 1
        ;;
esac

# Validate git_workflow
case "$GIT_WORKFLOW" in
    none|commit|push|pr|pr-merge)
        ;;
    *)
        echo "Error: Invalid git workflow: $GIT_WORKFLOW"
        echo "Valid options: none, commit, push, pr, pr-merge"
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
task_tracker: ${TASK_TRACKER}
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
echo "  Task tracker: $TASK_TRACKER"
echo "  Fresh context: $FRESH_CONTEXT"
if [[ -n "$DIRECTIONS" ]]; then
    echo "  Directions: (provided)"
fi
echo "  State file: $STATE_FILE"
echo ""
