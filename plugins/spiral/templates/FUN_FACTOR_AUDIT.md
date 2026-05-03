# Fun Factor Gap Audit

> **Backlog generator.** Run this audit when `docs/GDD_COVERAGE.json` is ≥80% `done`. Re-run after every major system lands. This is the source of the P0 / P1 polish work that prevents the loop from terminating before the product is good. Each gap identified here becomes a `Q-NNN` open question or an `F-NNN` followup.
>
> This doc exists because the Flatline failure mode is: every coverage row is `done`, every test passes, every checkbox is green, but the product is not actually fun. Coverage rows say a *system* exists. They cannot say the system *delivers experience*. This audit asks the questions coverage cannot.

## How to run an audit

1. Set today's date as the audit header (`## Audit YYYY-MM-DD`).
2. Walk each prompt below. Write a one-sentence answer for each. Be honest. "Yes" answers do not generate work; gaps do.
3. For each gap, decide: is this a question (`Q-NNN`) or a followup (`F-NNN`)?
4. Add the entry. Reference the audit date in the entry's Context line.
5. Save the audit. Do not delete previous audits; let the file grow.

Append-only. Earlier audits are preserved.

## Prompts

### The first session

- Does the first 90 seconds make the player want to keep playing?
- What is the first specific moment that surprises a new user (positive or negative)?
- Where does a new user get stuck or confused?

### The core action

- Does the core action feel good at every skill level (novice, mid, expert)?
- Is there meaningful skill expression? Can two players visibly perform differently at the same task?
- Does the core action have texture (light cues, weight, follow-through), or does it feel binary?

### Variety

- Do the variations within the system feel distinct, or do they feel like recolors?
- If the player picks a "different" option (track / character / mode / layout), do they have a different experience?
- Is there a surprise still waiting for a player who has played for an hour?

### Difficulty arc

- Where is the difficulty too high (frustration without learning)?
- Where is the difficulty too low (boredom)?
- Is there a clear "I want to keep going to get better" pull?

### Stickiness

- What brings a player back the next day?
- What makes a player tell a friend about this?
- What is the smallest change that would meaningfully improve retention?

### Polish you have been postponing

- List up to five "we know this needs work" items you have been quietly avoiding. Be specific.
- For each, name the smallest slice that would meaningfully address it.

## Audit log

### Audit {{TODAY}} (initial)

(populate when first run, after at least one full system has landed and coverage is non-trivial)

### Earlier audits

(append previous audits below this line as they age out, newest above oldest)
