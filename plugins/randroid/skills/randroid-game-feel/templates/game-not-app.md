---
description: Preserve the intended player interaction and verify its consequences in the running game.
paths:
  - "src/**"
  - "app/**"
  - "game/**"
  - "scenes/**"
  - "scripts/**"
  - "Source/**"
  - "Assets/**"
---

# Playable interaction

Adapt this rule to the project's genre and source paths when installing it. The user's brief and accepted project decisions govern its application.

1. Describe the core action, input, consequence, constraint or decision, and feedback in the project's verb/GDD record. “Click a button” names input but does not explain the mechanic.
2. Preserve the chosen interaction. Continuous driving needs steering and contact; a turn-based card game may use discrete selection, widgets, and stillness. Do not force a canvas, drag gesture, idle animation, or physics loop merely to satisfy a checklist.
3. Test a representative playable situation before multiplying content and shell. Essential setup, accessibility, and interfaces that carry the core mechanic belong in that situation.
4. Distinguish input acknowledgment from execution. Preserve deliberate windups and turn resolution; diagnose unintended latency with event/state timing and visual evidence.
5. Keep effects bounded and separate from authoritative state. Test cancel/release, failure/recovery, rapid repeat, and the accessibility modes affected by a change.
6. Verify actual input → intended state change → perceivable result in the intended view. Optional pixel probes and widget counts are diagnostic observations, never gameplay or enjoyment gates.
7. Reassess the method when comparable attempts leave the same major defect. Defer dependent detail, test the suspected cause, and carry forward only the better candidate.
8. Close the slice with the project's required checks and play evidence. Record remaining gaps and leave required human judgments open. Stop autonomous refinement once declared acceptance is met.
