---
name: randroid-loop
description: Autonomous development loop with research and implementation modes
triggers:
  - /randroid
  - /randroid-loop
hooks:
  - event: Stop
    script: hooks/stop-hook.sh
---

# Randroid Loop

A self-sustaining development loop with two modes: **Researcher** and **Implementor**.

## Prerequisites

**Full permissions required.** The loop runs autonomously and needs unrestricted access.

### Claude Code
```bash
claude --dangerously-skip-permissions
```

### Codex
The script automatically uses `--yolo` mode (no sandbox, no prompts).

## Startup Flow

When this skill is invoked, ask the user FOUR questions using AskUserQuestion, then one text prompt:

### Question 1: Mode (AskUserQuestion)
- **Question**: "Which mode would you like to run?"
- **Options**:
  1. `Research` - Explore, investigate, and plan. Creates specs for implementation.
  2. `Implement` - Execute on specs. Write code, tests, and documentation.

### Question 2: Git Workflow (AskUserQuestion)
- **Question**: "What should happen after each task?"
- **Options**:
  - `Push` - Commit and push to current branch (default)
  - `Commit only` - Commit locally, no push
  - `Open PR` - Open PR, wait for CI (no merge)
  - `PR and merge` - Open PR, wait for CI, then auto-merge

### Question 3: Context Management (AskUserQuestion)
- **Question**: "Should each iteration start with fresh context?"
- **Options**:
  - `Fresh context` - Clear context between iterations (default, recommended)
  - `Keep context` - Maintain conversation history across iterations

### Question 4: Directions (AskUserQuestion - optional)
- **Question**: "Any specific directions for this run?"
- **Options** (mode-aware, user can select "Other" for custom):
  - `None` - No specific directions, work autonomously
  - For Research mode:
    - `Focus on specs` - Review and improve existing implementation specs
    - `Explore dependencies` - Research external libraries and frameworks
  - For Implement mode:
    - `Fix issues first` - Prioritize fixing build errors and warnings
    - `Skip tests` - Focus on implementation, skip test writing for now

If user selects "Other", they can provide custom directions like:
- "Focus on authentication patterns"
- "Search Apple developer docs for NSPanel"
- "Prioritize the archive feature"
- "Redo the task list with proper SwiftUI patterns"

The agent interprets directions intelligently (creating dots, modifying tasks, updating docs, changing priorities, etc.).

### Question 5: Iterations (Text prompt - NOT AskUserQuestion)
After the AskUserQuestion completes, ask:
> "How many iterations? Enter a number, 'inf' for infinite, or 'comp' for until complete:"

Parse the response:
- Number (e.g., "2", "5", "10") → exact iteration count
- "inf", "infinite", "-1" → infinite mode (-1)
- "comp", "complete", "0" → until complete mode (0)

**Key distinction:**
- **Infinite / N iterations**: Completion promise is IGNORED. Loop continues for re-analysis and improvement.
- **Until complete**: Only mode where completion promise stops the loop.

After collecting answers:
1. Initialize loop state by running: `./scripts/setup-loop.sh <mode> --iterations <N> --git-workflow <workflow> [--fresh-context] [--directions "..."]`
   - Iterations: -1=infinite, 0=until complete, N=exact count
   - Workflow: commit/push/pr/pr-merge
   - Directions: optional user guidance for the agent
2. Build the prompt by combining mode-specific + shared content:
   - Read `<mode>-loop.md` (mode-specific sections)
   - Read `loop-shared.md` (common sections)
   - Concatenate: mode-specific + shared
3. Begin execution based on context mode:

**Fresh context mode (default):**
You are the orchestrator. Run this loop in the main conversation:

```
iteration = 0
PROMPT = contents of <mode>-loop.md + "\n\n" + contents of loop-shared.md
DIRECTIONS = user's directions (if provided)

# Exponential backoff for infinite mode
MIN_DELAY = 5        # seconds
current_delay = MIN_DELAY

# If directions were provided, append them to the prompt
if DIRECTIONS:
    PROMPT = PROMPT + "\n\n## User Directions\n\n" + DIRECTIONS

LOOP:
    iteration += 1
    print "=== Iteration {iteration} ==="

    result = Task(prompt=PROMPT, subagent_type="general-purpose")

    # Check termination conditions
    if iterations == 0:  # "until complete" mode
        if result contains "RANDROID_LOOP_COMPLETE":
            print "Loop complete (promise found after {iteration} iterations)"
            EXIT LOOP
    elif iterations > 0:  # exact N iterations mode
        if iteration >= iterations:
            print "Completed {iteration} iterations"
            EXIT LOOP
    # iterations == -1 means infinite, continues below

    # Exponential backoff for infinite mode when no work done
    if iterations == -1:  # infinite mode
        if result contains "RANDROID_LOOP_COMPLETE":
            print "No work this iteration, backing off for {current_delay}s..."
            sleep(current_delay)
            current_delay = current_delay * 2  # No max cap
        else:
            # Meaningful work done, reset backoff
            current_delay = MIN_DELAY

    GOTO LOOP
```

**CRITICAL**: After each Task returns, YOU (the orchestrator) must:
1. Check the result for the completion promise
2. Check if iteration limit reached
3. If neither → spawn another Task for the next iteration
4. Do NOT stop just because one Task finished

**Keep context mode:**
Run the loop directly in the current conversation. The stop hook will intercept exit and continue looping with accumulated context.

## Usage

### Interactive (Recommended)
```
/randroid
```
Prompts for mode, iterations, and optional directions.

### Direct (Skip Questions)
- `/randroid research` - Research mode, prompts for iterations
- `/randroid implement` - Implement mode, prompts for iterations
- `/randroid research --loop` - Research mode, infinite (ignores completion)
- `/randroid research --until-complete` - Research mode, stops on completion
- `/randroid implement --iterations 5` - Implement mode, exactly 5 iterations
- `/randroid implement --open-pr` - Open PR workflow
- `/randroid implement --pr-and-merge` - PR with auto-merge workflow
- `/randroid implement --commit-only` - Local commits only
- `/randroid implement --keep-context` - Keep conversation context (no fresh start)
- `/randroid implement --iterations 5 --open-pr` - Combine options

### With Directions
You can provide guidance for the agent. When prompted for directions:
- Select a preset option (mode-specific), or
- Select "Other" and type custom directions like:
  - "Focus on authentication patterns"
  - "Prioritize the archive feature, skip tests for now"

Directions can include:
- Topics to research or questions to answer
- Priorities for which tasks to work on
- Specific implementation guidance
- Requests to redo or improve previous work
- Scope changes (add/remove/modify tasks)

### Codex (External Script)
```bash
# From terminal (outside Codex)
./skills/randroid-loop/scripts/randroid-loop.sh
# Interactive prompts for mode, iterations, and git workflow
# Note: Wrapper always uses fresh context (each iteration is a new codex exec)

# Direct invocation:
./skills/randroid-loop/scripts/randroid-loop.sh research -1           # infinite
./skills/randroid-loop/scripts/randroid-loop.sh research 0            # until complete
./skills/randroid-loop/scripts/randroid-loop.sh implement 5           # exactly 5 iterations
./skills/randroid-loop/scripts/randroid-loop.sh implement 5 pr        # 5 iterations, open PR
./skills/randroid-loop/scripts/randroid-loop.sh implement 0 pr-merge  # until complete, PR + merge
```

## Modes

### Research Mode
The researcher explores, investigates, and plans. It:
- Creates `research:` prefixed dots to track its own exploration
- Creates `implement:` prefixed dots as deliverables for the implementor
- Does NOT write production code
- Outputs findings, decisions, and clear implementation specs

### Implementor Mode
The implementor executes. It:
- Pulls from ready `implement:` dots
- Writes code, tests, and documentation
- Creates new `implement:` dots if scope expands
- Creates `research:` dots if blocked by unknowns (for next research cycle)

## Loop Mechanics

### Fresh Context Each Iteration
Each loop iteration starts with **fresh conversational context**. Only the filesystem persists:
- Modified files
- Git history and commits
- Dots system state
- Research/implementation artifacts

This prevents context bloat and allows the agent to approach each iteration with clarity.

### What Persists
- All file changes from previous iterations
- Git commits and history
- `.dots/` task state
- Any written documentation or specs

### What Resets
- Conversation history
- In-memory state
- Token usage (fresh budget each iteration)

## Loop Termination

Output `<promise>RANDROID_LOOP_COMPLETE</promise>` when:
- No more ready tasks for your mode
- All work is committed and pushed

The loop also stops when `--iterations N` limit is reached.

## Architecture

```
skills/randroid-loop/
├── SKILL.md              # This file
├── research-loop.md      # Research mode prompt
├── implement-loop.md     # Implementor mode prompt
├── loop-shared.md        # Shared sections (git, dots, termination)
├── LOOPING_DESIGN.md     # Technical design doc
├── hooks/
│   └── stop-hook.sh      # Claude Code stop hook
├── scripts/
│   ├── setup-loop.sh     # Initialize loop state
│   └── randroid-loop.sh  # Codex external wrapper
└── state/
    └── .gitignore        # Excludes local state files
```
