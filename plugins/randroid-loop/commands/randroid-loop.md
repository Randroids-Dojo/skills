# Randroid Loop

A self-sustaining development loop with two modes: **Researcher** and **Implementor**.

## Prerequisites

**Full permissions required.** The loop runs autonomously and needs unrestricted access.

## Startup Flow

When this command is invoked, ask the user FOUR questions using AskUserQuestion, then one text prompt:

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

### Question 5: Iterations (Text prompt - NOT AskUserQuestion)
After the AskUserQuestion completes, ask:
> "How many iterations? Enter a number, 'inf' for infinite, or 'comp' for until complete:"

Parse the response:
- Number (e.g., "2", "5", "10") → exact iteration count
- "inf", "infinite", "-1" → infinite mode (-1)
- "comp", "complete", "0" → until complete mode (0)

After collecting answers:
1. Initialize loop state by running: `"${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh" <mode> --iterations <N> --git-workflow <workflow> [--fresh-context] [--directions "..."]`
2. Build the prompt by combining mode-specific + shared content:
   - Read `${CLAUDE_PLUGIN_ROOT}/<mode>-loop.md`
   - Read `${CLAUDE_PLUGIN_ROOT}/loop-shared.md`
   - Concatenate: mode-specific + shared
3. Begin execution based on context mode

**Fresh context mode (default):**
You are the orchestrator. Run this loop:

```
iteration = 0
PROMPT = contents of <mode>-loop.md + "\n\n" + contents of loop-shared.md

LOOP:
    iteration += 1
    print "=== Iteration {iteration} ==="
    result = Task(prompt=PROMPT, subagent_type="general-purpose")

    # Check termination
    if iterations == 0 and result contains "RANDROID_LOOP_COMPLETE":
        EXIT LOOP
    elif iterations > 0 and iteration >= iterations:
        EXIT LOOP

    GOTO LOOP
```

**CRITICAL**: After each Task returns, check for completion promise or iteration limit. If neither → spawn another Task.

## Modes

### Research Mode
- Creates `research:` prefixed dots for exploration
- Creates `implement:` prefixed dots as deliverables
- Does NOT write production code

### Implementor Mode
- Pulls from ready `implement:` dots
- Writes code, tests, and documentation
- Creates new dots if scope expands

## Loop Termination

Output `<promise>RANDROID_LOOP_COMPLETE</promise>` when:
- No more ready tasks for your mode
- All work is committed and pushed
