# /decision

Start a structured decision session in batches of two multiple-choice questions.

## How to run

Run `/decision` from the chat input (or invoke `$decision` in Codex).

## Required behavior

1. Ask exactly two questions at a time.
2. For each question:
   - Show options in multiple-choice format (A/B/C…).
   - Include pros and cons for **every option**.
   - Include one recommended option with a one-sentence rationale.
3. Ask the user to pick one option per question before moving on.

If only one question is needed, ask that one question alone.
