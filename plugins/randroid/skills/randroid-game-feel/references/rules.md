# Diagnose the shape of play

Use these questions against the requested genre and an observed play session. They are diagnostic clues, not a universal definition of games. A deliberately quiet puzzle, text adventure, card game, or clicker can be complete with discrete input, DOM rendering, and little motion.

## Contract before components

Write a short causal chain: **input → intended action → consequence → feedback → next decision**. Include the rule, timing, spatial constraint, uncertainty, or tradeoff that makes the action matter. If the chain only says “click, increment counter,” ask whether that is the requested mechanic or a placeholder for a missing one; do not assume either.

Separate acknowledgment from execution. A charge attack may acknowledge input immediately and hit later by design. A turn may wait for confirmation. Measure the unintended delay between these events rather than deleting deliberate windups or confirmation rules.

## Findings that justify a change

| Observation | Establish before changing it | Useful correction |
| --- | --- | --- |
| Requested driving is a button that advances distance | The brief asks for steering, traction, and physical contact | Prototype those behaviors with the authoritative controller and actual input |
| An animated viewer passes a pixel probe | No tested input changes the intended gameplay state | Verify the missing action and consequence; retain animation as visual evidence only |
| A key sometimes does nothing | Focus, bindings, input capture, buffering, or a legitimate blocked state | Reproduce the smallest failing sequence and fix that layer |
| A hit, rejected move, or invalid placement is unclear | Which state changed and what the player could perceive | Add proportional feedback at the event; show the reason for rejection where needed |
| Holding a key keeps acting after release | Focus loss, missing release/cancel, duplicate listeners, or stale state | Test release, cancel, pause/resume, and rapid repeat as well as the happy path |
| Menus crowd out a promised action game | The real verb is absent or needlessly delayed after necessary setup | Expose a representative playable situation early and defer unrelated shell work |
| A DOM/card/text interface looks like an app | The chosen interaction is missing, unclear, or has no intended consequence | Fix that experience; widget counts do not justify a canvas conversion |
| A turn-based scene is still | Nothing is supposed to advance during deliberation | No fix required; verify selection, resolution, and feedback instead |
| Effects feel intense but control feels worse | Shake, interpolation, hit-stop, sound overlap, or particles hide state or delay input | Compare with effects reduced and retain only the layers that improve readability |
| Content grows while the main defect persists | Comparable before/after evidence shows no improvement | Reassess the design or representation before another detail pass |
| A nice model fails during play | Game camera, lighting, motion, performance, or exported geometry differs from the still | Test the actual runtime state and repair its failing dependency |

An observation needs a reproducible trigger, expected result, observed result, and evidence. Assign priority by impact on the current acceptance criteria, not by a universal list of banned widgets or words.

## Order work by uncertainty

For an action prototype, movement/contact and immediate feedback usually precede content variety. For a strategy prototype, a small decision space, its costs, and its resolution may need to arrive together. For an asset inspection game, the close camera and moving assembly may be the riskiest first test.

1. Build one representative interaction with enough context to judge it.
2. Verify the action, constraint or decision, feedback, and recovery.
3. Tune the weakest part with comparable evidence.
4. Expand situations and production detail after dependencies stabilize.
5. Integrate supporting menus and services when the interaction requires them.

Keep accessibility and essential input configuration available at the point they are needed. There is no fixed two-second loading rule or maximum HUD widget count; choose a meaningful target for the user's platform and intended experience. Measure the actual boot-to-control path if it is part of the task.

## Implementation boundaries

Use the selected engine's existing update, input, and physics systems. Continuous simulation needs an intentional time-step policy; do not create a second competing loop or make render-frame-dependent forces authoritative. Discrete state transitions can be event-driven. Rendering frequency is not simulation frequency.

Keep effects separate from authoritative gameplay. A visual squash must not resize the collider accidentally. Camera shake must not change steering or aim unless designed to. A menu transition must not double-submit a turn. Preserve deterministic state and replay/save contracts where required.

Inspect the real control path rather than counting API names. Event callbacks, polling, engine actions, and UI controls can all implement valid gameplay. Existing stack and accessibility requirements take precedence over a preferred rendering library.
