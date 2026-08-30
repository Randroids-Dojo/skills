---
name: decision
description: Structure a decision as one or two multiple-choice questions at a time, with tradeoffs and a recommendation for every question. Use when the user wants guided help choosing among alternatives or explicitly asks for a decision session.
---

# Decision Assistant

Use this skill when the user wants help choosing between alternatives and asks for structured guidance.

## Core behavior (required)

1. Ask exactly **two questions at a time**.
2. For each question:
   - Provide **2–5 mutually exclusive choices** as explicit multiple-choice options.
   - For every option, include:
     - `Pros:` concise list
     - `Cons:` concise list
   - After listing options, clearly include **`Recommended choice:`** and a one-line reason.
3. End the message with a short response prompt asking for selected options (e.g., `Pick one option for each question`).
4. Wait for the user’s answer before asking the next pair.
5. Keep the next pair scoped by prior answers.

## Output format

Use this structure for each pair:

- `Question 1`
  - `A) Option`
    - `Pros: ...`
    - `Cons: ...`
  - `B) Option`
    - `Pros: ...`
    - `Cons: ...`
  - `Recommended choice: A`
- `Question 2`
  - same structure

No code execution is required unless explicitly requested.

## Scope guardrails

- Do not ask more than two questions in one assistant turn.
- Do not skip pros/cons.
- Do not provide a full recommendation for all questions without first collecting the user’s selections.
- If the user asks for a different number of questions, still enforce “two at a time” by splitting them into batches.
- If only one question is requested, provide one question only in that turn and do not invent extra unrelated questions.
