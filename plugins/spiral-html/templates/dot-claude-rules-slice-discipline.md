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

<h1>Slice discipline</h1>

<p>This rule loads when editing source code under typical project layouts. It enforces the slice contract from <code>docs/IMPLEMENTATION_PLAN.html</code>.</p>

<h2>What to do</h2>

<ul>
  <li>Touch only what the current slice needs. If you find yourself "while I'm here" cleaning a separate file, stop. That is a separate slice.</li>
  <li>Refactors land as part of the slice that touches the code, not as a separate invisible cleanup pass.</li>
  <li>Three similar lines is better than a premature abstraction. Wait for the third repetition before extracting.</li>
  <li>Do not add error handling, fallbacks, or validation for scenarios that cannot happen. Trust internal code and framework guarantees. Validate at system boundaries only.</li>
  <li>Do not add features, refactor, or introduce abstractions beyond what the task requires. A bug fix does not need surrounding cleanup.</li>
</ul>

<h2>What to avoid</h2>

<ul>
  <li>Tangential file edits ("while I'm here, let me also...").</li>
  <li>Backwards-compat shims for code you can just change.</li>
  <li>Renaming unused vars to silence the linter.</li>
  <li>Speculative comments explaining future-hypothetical scenarios.</li>
  <li>Half-finished implementations.</li>
</ul>

<h2>Why this matters</h2>

<p>Every slice that touches files outside its scope makes the next slice harder to review and harder to revert if it regresses. The smaller and tighter the slice, the cheaper the spiral compounds.</p>
