#!/bin/bash
#
# Loop - External wrapper for Codex
#
# Usage:
#   ./randroid-loop.sh                                  # Interactive prompts
#   ./randroid-loop.sh <mode> <iterations> [workflow]
#
# Iteration modes:
#   inf or -1         - Loop forever (ignores completion promise)
#   comp or 0         - Loop until RANDROID_LOOP_COMPLETE found
#   # (number)        - Run exactly N iterations (ignores completion promise)
#
# Git workflows:
#   commit   - Commit locally only (no push)
#   push     - Commit and push (default)
#   pr       - Open PR, wait for CI (no merge)
#   pr-merge - Open PR, wait for CI, then merge
#
# Context:
#   fresh    - Clear context between iterations (default, always true for wrapper)
#   keep     - Not supported in wrapper mode (use interactive Codex instead)
#
# Examples:
#   ./randroid-loop.sh                         # Interactive prompts
#   ./randroid-loop.sh research inf            # Infinite loop
#   ./randroid-loop.sh research comp           # Until complete
#   ./randroid-loop.sh implement 5             # Exactly 5 iterations
#   ./randroid-loop.sh implement 5 pr          # 5 iterations, open PR
#   ./randroid-loop.sh implement comp pr-merge # Until complete, PR + merge
#

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
COMPLETION_PROMISE="RANDROID_LOOP_COMPLETE"
DELAY_BETWEEN_ITERATIONS=2

# Exponential backoff for infinite mode when no work done
MIN_BACKOFF_DELAY=5
current_backoff_delay=$MIN_BACKOFF_DELAY

# Parse arguments
MODE="${1:-}"
ITERATIONS="${2:-}"
GIT_WORKFLOW="${3:-}"

# Interactive mode selection if not provided
if [[ -z "$MODE" ]]; then
    echo ""
    echo "========================================"
    echo "  Loop"
    echo "========================================"
    echo ""
    echo "Which mode would you like to run?"
    echo ""
    echo "  1) Research  - Explore, investigate, create implementation specs"
    echo "  2) Implement - Execute on specs, write code, ship"
    echo ""
    read -p "Select mode [1-2]: " mode_choice

    case "$mode_choice" in
        1|research|r)
            MODE="research"
            ;;
        2|implement|i)
            MODE="implement"
            ;;
        *)
            echo "Invalid selection. Exiting."
            exit 1
            ;;
    esac
fi

if [[ "$MODE" != "research" && "$MODE" != "implement" ]]; then
    echo "Error: Mode must be 'research' or 'implement'"
    exit 1
fi

# Interactive git workflow selection if not provided
if [[ -z "$GIT_WORKFLOW" ]]; then
    echo ""
    echo "What should happen after each task?"
    echo ""
    echo "  1) push     - Commit and push to current branch (default)"
    echo "  2) commit   - Commit locally only, no push"
    echo "  3) pr       - Open PR, wait for CI (no merge)"
    echo "  4) pr-merge - Open PR, wait for CI, then auto-merge"
    echo ""
    read -p "Select [1-4, default=1]: " workflow_choice

    case "$workflow_choice" in
        ""|1|push)
            GIT_WORKFLOW="push"
            ;;
        2|commit)
            GIT_WORKFLOW="commit"
            ;;
        3|pr)
            GIT_WORKFLOW="pr"
            ;;
        4|pr-merge|merge)
            GIT_WORKFLOW="pr-merge"
            ;;
        *)
            echo "Invalid selection. Using 'push'."
            GIT_WORKFLOW="push"
            ;;
    esac
fi

# Validate git workflow
case "$GIT_WORKFLOW" in
    commit|push|pr|pr-merge)
        ;;
    *)
        echo "Error: Invalid git workflow: $GIT_WORKFLOW"
        echo "Valid options: commit, push, pr, pr-merge"
        exit 1
        ;;
esac

# Context management - wrapper always uses fresh context
echo ""
echo "Context: fresh (each iteration starts clean)"
echo "  Note: Wrapper mode always uses fresh context."
echo "  For keep-context mode, use interactive Codex or Claude Code."

# Prompt for optional directions
echo ""
echo "Any specific directions for this run?"
echo "(e.g., topics to research, priorities, specific tasks to focus on)"
echo ""
read -p "Directions (press Enter to skip): " DIRECTIONS

# Treat skip-like responses as empty
if [[ "$DIRECTIONS" =~ ^(no|none|skip|-|n/a|)$ ]]; then
    DIRECTIONS=""
fi

# Interactive iteration selection if not provided
if [[ -z "$ITERATIONS" ]]; then
    echo ""
    echo "How many iterations should the loop run?"
    echo ""
    echo "  inf) Infinite - Loop forever (Ctrl+C to stop)"
    echo " comp) Until complete - Stop when tasks exhausted"
    echo "    #) Or enter a custom number"
    echo ""
    read -p "Select [inf/comp/#, default=inf]: " iter_choice

    case "$iter_choice" in
        ""|inf|infinite|-1)
            ITERATIONS=-1
            ;;
        comp|complete|0|done)
            ITERATIONS=0
            ;;
        *)
            if [[ "$iter_choice" =~ ^[0-9]+$ ]]; then
                ITERATIONS="$iter_choice"
            else
                echo "Invalid selection. Using infinite mode."
                ITERATIONS=-1
            fi
            ;;
    esac
fi

# Normalize iterations value
case "$ITERATIONS" in
    inf|infinite)
        ITERATIONS=-1
        ;;
    comp|complete|done)
        ITERATIONS=0
        ;;
esac

# Initialize loop state (for agent to read)
if [[ -n "$DIRECTIONS" ]]; then
    "${SCRIPT_DIR}/setup-loop.sh" "$MODE" --iterations "$ITERATIONS" --git-workflow "$GIT_WORKFLOW" --fresh-context --directions "$DIRECTIONS"
else
    "${SCRIPT_DIR}/setup-loop.sh" "$MODE" --iterations "$ITERATIONS" --git-workflow "$GIT_WORKFLOW" --fresh-context
fi

# Prompt files
PROMPT_FILE="${SKILL_DIR}/${MODE}-loop.md"
SHARED_FILE="${SKILL_DIR}/loop-shared.md"
if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "Error: Prompt file not found: $PROMPT_FILE"
    exit 1
fi
if [[ ! -f "$SHARED_FILE" ]]; then
    echo "Error: Shared file not found: $SHARED_FILE"
    exit 1
fi

# Output tracking
OUTPUT_FILE="/tmp/randroid-output-$$.txt"
LOG_FILE="/tmp/randroid-log-$$.txt"
SUMMARY_FILE="/tmp/randroid-summary-$$.txt"

# Initialize summary file
echo "" > "$SUMMARY_FILE"

cleanup() {
    rm -f "$OUTPUT_FILE" "$SUMMARY_FILE"
    echo ""
    echo "Log file: $LOG_FILE"
}
trap cleanup EXIT

# Capitalize mode for display (portable across bash/zsh/sh)
MODE_DISPLAY="$(echo "$MODE" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"

# Function to display iteration summaries
show_summary() {
    if [[ -s "$SUMMARY_FILE" ]]; then
        echo ""
        echo "========================================"
        echo "  ITERATION SUMMARIES"
        echo "========================================"
        cat "$SUMMARY_FILE"
        echo ""
    fi
}

# Header
echo ""
echo "========================================"
echo "  Loop: $MODE_DISPLAY Mode"
echo "========================================"
if [[ $ITERATIONS -eq -1 ]]; then
    echo "Iterations: INFINITE (Ctrl+C to stop)"
    echo "Completion promise: IGNORED"
elif [[ $ITERATIONS -eq 0 ]]; then
    echo "Iterations: until $COMPLETION_PROMISE"
else
    echo "Iterations: exactly $ITERATIONS"
    echo "Completion promise: IGNORED"
fi
echo "Git workflow: $GIT_WORKFLOW"
echo "Started at: $(date)"
echo ""
echo "Press Ctrl+C to stop"
echo "========================================"
echo ""

iteration=0
start_time=$(date +%s)

while true; do
    iteration=$((iteration + 1))
    iter_start=$(date +%s)

    # Show progress
    if [[ $ITERATIONS -eq -1 ]]; then
        echo ""
        echo "=== Iteration $iteration (infinite) $(date '+%H:%M:%S') ==="
    elif [[ $ITERATIONS -eq 0 ]]; then
        echo ""
        echo "=== Iteration $iteration (until complete) $(date '+%H:%M:%S') ==="
    else
        echo ""
        echo "=== Iteration $iteration of $ITERATIONS $(date '+%H:%M:%S') ==="
    fi
    echo ""

    # Log iteration start
    echo "[$(date)] Iteration $iteration started" >> "$LOG_FILE"

    # Build the prompt (mode-specific + shared)
    PROMPT=$(cat "$PROMPT_FILE")
    PROMPT="${PROMPT}

$(cat "$SHARED_FILE")"

    # Append directions if provided
    if [[ -n "$DIRECTIONS" ]]; then
        PROMPT="${PROMPT}

## User Directions

${DIRECTIONS}"
    fi

    # Run Codex
    if codex exec --yolo \
        --output-last-message "$OUTPUT_FILE" \
        "$PROMPT" 2>&1 | tee -a "$LOG_FILE"; then

        iter_end=$(date +%s)
        iter_duration=$((iter_end - iter_start))
        echo ""
        echo "Iteration $iteration completed in ${iter_duration}s"
        echo "[$(date)] Iteration $iteration completed (${iter_duration}s)" >> "$LOG_FILE"

        # Extract structured summary from log (--output-last-message only has final message)
        iter_summary=$(sed -n 's/.*<iteration-summary>\(.*\)<\/iteration-summary>.*/\1/p' "$LOG_FILE" | tail -1)
        if [[ -n "$iter_summary" ]]; then
            echo "Iteration $iteration (${iter_duration}s): $iter_summary" >> "$SUMMARY_FILE"
        else
            echo "Iteration $iteration (${iter_duration}s): (no summary provided)" >> "$SUMMARY_FILE"
        fi

        # Only check completion promise in "until complete" mode (ITERATIONS=0)
        if [[ $ITERATIONS -eq 0 ]]; then
            if [[ -f "$OUTPUT_FILE" ]] && grep -q "$COMPLETION_PROMISE" "$OUTPUT_FILE"; then
                echo ""
                echo "========================================"
                echo "  LOOP COMPLETE (promise found)"
                echo "========================================"
                total_time=$(( $(date +%s) - start_time ))
                echo "Total iterations: $iteration"
                echo "Total time: ${total_time}s"
                echo "[$(date)] Loop complete after $iteration iterations" >> "$LOG_FILE"

                show_summary

                # Play completion sound on macOS
                if command -v afplay &> /dev/null; then
                    afplay /System/Library/Sounds/Glass.aiff &
                fi
                break
            fi
        fi

    else
        echo "Warning: Iteration $iteration had errors (exit code: $?)"
        echo "[$(date)] Iteration $iteration had errors" >> "$LOG_FILE"
    fi

    # Check iteration limit (only for positive ITERATIONS values)
    if [[ $ITERATIONS -gt 0 && $iteration -ge $ITERATIONS ]]; then
        echo ""
        echo "========================================"
        echo "  ITERATIONS COMPLETE"
        echo "========================================"
        total_time=$(( $(date +%s) - start_time ))
        echo "Completed $iteration iterations"
        echo "Total time: ${total_time}s"
        echo "[$(date)] Completed $iteration iterations" >> "$LOG_FILE"

        show_summary

        # Play completion sound on macOS
        if command -v afplay &> /dev/null; then
            afplay /System/Library/Sounds/Glass.aiff &
        fi
        break
    fi

    # Exponential backoff for infinite mode when completion promise is hit
    if [[ $ITERATIONS -eq -1 ]]; then
        if [[ -f "$OUTPUT_FILE" ]] && grep -q "$COMPLETION_PROMISE" "$OUTPUT_FILE"; then
            echo ""
            echo "No work this iteration, backing off for ${current_backoff_delay}s..."
            echo "[$(date)] Backoff: ${current_backoff_delay}s (no work found)" >> "$LOG_FILE"
            sleep "$current_backoff_delay"
            # Double the backoff delay (no max cap)
            current_backoff_delay=$((current_backoff_delay * 2))
        else
            # Meaningful work done, reset backoff
            if [[ $current_backoff_delay -gt $MIN_BACKOFF_DELAY ]]; then
                echo "Work completed, resetting backoff delay"
                echo "[$(date)] Backoff reset (work completed)" >> "$LOG_FILE"
            fi
            current_backoff_delay=$MIN_BACKOFF_DELAY
            echo ""
            echo "Continuing to next iteration in ${DELAY_BETWEEN_ITERATIONS}s..."
            sleep "$DELAY_BETWEEN_ITERATIONS"
        fi
    else
        echo ""
        echo "Continuing to next iteration in ${DELAY_BETWEEN_ITERATIONS}s..."
        sleep "$DELAY_BETWEEN_ITERATIONS"
    fi
done
