---
description: Keep slice changes scoped. No drive-by refactors, no speculative abstractions.
paths:
  - "src/**"
  - "app/**"
  - "lib/**"
  - "components/**"
  - "pages/**"
  - "scripts/**"
  - "tests/**"
---

# Slice discipline

This rule loads when editing source code under typical project layouts. It enforces the slice contract from `docs/IMPLEMENTATION_PLAN.md`.

## What to do

- Touch only what the current slice needs. If you find yourself "while I'm here" cleaning a separate file, stop. That is a separate slice.
- Refactors land as part of the slice that touches the code, not as a separate invisible cleanup pass.
- Three similar lines is better than a premature abstraction. Wait for the third repetition before extracting.
- Do not add error handling, fallbacks, or validation for scenarios that cannot happen. Trust internal code and framework guarantees. Validate at system boundaries only.
- Do not add features, refactor, or introduce abstractions beyond what the task requires. A bug fix does not need surrounding cleanup.

## What to avoid

- Tangential file edits ("while I'm here, let me also...").
- Backwards-compat shims for code you can just change.
- Renaming unused vars to silence the linter.
- Speculative comments explaining future-hypothetical scenarios.
- Half-finished implementations.

## Why this matters

Every slice that touches files outside its scope makes the next slice harder to review and harder to revert if it regresses. The smaller and tighter the slice, the cheaper the spiral compounds.
