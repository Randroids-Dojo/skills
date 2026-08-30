---
name: randroid
description: Route requests to the focused Randroid development workflows and explain which capability to use. Use when the user asks what Randroid skills are available, invokes the Randroid namespace without naming a workflow, or needs help choosing among loop execution, PR feedback handling, VibeReview playtesting, and UI de-slopping.
---

# Randroid

Choose the smallest focused workflow that matches the request:

- **Randroid Loop:** use `randroid-loop` for bounded research or implementation cycles with Dots tracking and an explicit git workflow.
- **Address PR Comments:** use `randroid-address-pr-comments` for resolving current pull-request review feedback and replying with verification evidence.
- **VibeReview:** use `randroid-vibereview` for browser-game playtests, captured evidence, and Spiral-HTML ledger updates.
- **Clean Slop:** use `randroid-clean-slop` for screenshot-led removal of generic AI visual and copy patterns.

Load and follow only the selected skill. Do not combine workflows merely because they share this namespace. If the user's request does not identify a workflow and more than one is plausible, briefly explain the distinction and ask which outcome they want.

Claude Code also exposes these skills under the `randroid` plugin namespace. The portable skill names above are the source of truth; legacy command aliases may remain for compatibility.
