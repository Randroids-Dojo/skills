---
name: randroid-game-feel
description: Improve a game's core interaction, responsiveness, feedback, and playable iteration. Use when a game feels like an app or menu, the user asks for game feel or juice, a prototype needs its first playable loop, or game-not-app rules need installing. Preserve the chosen genre, including turn-based, card, text, and intentional clicker games. Visual redesign alone belongs to randroid-clean-slop; evidence capture alone belongs to randroid-vibereview.
---

# Game Feel

Make the intended player action work, communicate its consequence, and verify it in the running game. Menus, moving pixels, and passing unit tests can each exist while the requested gameplay is missing. Begin with a concrete play scenario rather than a generic visual score.

## Establish the interaction

Read the user's latest brief and existing game contract. Record the core action, input, consequence, uncertainty or resistance, and expected feedback. Use [templates/VERB_SHEET.md](templates/VERB_SHEET.md) when that record does not already exist. Keep small changes small; an input fix does not require rewriting the GDD.

Preserve the genre and intended controls. Driving may require continuous steering and physics; a card game may use discrete selection and stay still between turns. Widgets, text, menus, and accessible alternative controls are legitimate when they serve that interaction. Do not add idle animation, drag gestures, or a new engine to satisfy a probe.

Read [references/rules.md](references/rules.md) when diagnosing the shape of play or ordering a prototype. For substantial art or repeated refinement, also read [references/production-checkpoints.md](references/production-checkpoints.md): functional, visual, motion, performance, and human acceptance require different evidence.

## Rescue an existing game

1. Reproduce the reported problem in the actual play state. Use the project's supported runtime tools or authorized computer-use tools. Read [references/verification.md](references/verification.md) for scenario design, optional diagnostic probes, and measurement limits.
2. Name the failed experience and point to its evidence: the car rotates but cannot drive, a card commits before the player can inspect its cost, or a hit has no readable consequence. A DOM count or screenshot difference alone is not a finding.
3. Trace the failure to input, state transition, simulation, camera, feedback, or presentation. Fix the earliest broken dependency in one coherent slice. Avoid redesigning working controls to match a template.
4. For feedback work, use [references/juice.md](references/juice.md). Compare the same action before and after, including release/cancel, failure/recovery, rapid repetition, and accessibility modes where affected.
5. Re-run the affected scenario and required project checks. Report observed behavior, evidence, and remaining gaps; distinguish measured response from subjective enjoyment.

## Build a playable slice

Choose the smallest representative interaction that can disprove the design. Test movement and contact for a driving game, a decision and its resolution for a strategy game, or timing and recovery for an action game. Include enough constraints to make the chosen action meaningful; a strategy decision may require goals from the start.

Establish control and basic feedback before multiplying content, progression, or decorative shell. Accessibility, input setup, rules necessary to understand a decision, and a shop/inventory that is itself the core mechanic belong in the relevant early slice. Use the existing engine loop; a discrete game does not need a new continuous simulation.

Define a bounded done-when before refining: the expected state change occurs under actual input, its result is legible through the intended camera/interface, the relevant failure/recovery works, and required checks pass. Use [references/prompts.md](references/prompts.md) for task examples. Stop at the requested acceptance; leave required human enjoyment judgments open with a concrete build ready to review.

## Install project rules

When asked to install durable rules, adapt [templates/game-not-app.md](templates/game-not-app.md) and [templates/AGENTS-rule.md](templates/AGENTS-rule.md) to the chosen genre and repository conventions. Merge with existing instructions; do not overwrite them or introduce a competing contract.

- In a Claude rules project, use `.claude/rules/game-not-app.md` and adjust its path scope.
- For Codex, place the short summary in the applicable `AGENTS.md`; follow existing nested-rule conventions without replacing an existing file or symlink.
- Add or update the verb sheet at the existing GDD location, or `docs/VERB_SHEET.md` if none exists. Use the matching path in the installed rules.
- Add applicable play checks to the project's existing playtest record. Keep unrelated scaffolding intact. Commit or push only within the user's authorization.

Finish with the concrete before/after behavior, verification artifacts, and any remaining acceptance gaps. A probe's successful exit means it collected observations, never that the game is fun or complete.
