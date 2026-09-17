---
name: unbury
description: Rewrite AI-generated or AI-influenced technical writing so a competent engineer builds the correct mental model as fast as possible, without losing technical accuracy. Use when the user asks to de-slop, humanize, tighten, or clarify a PR description, code review comment, design doc, architecture explanation, issue, Slack update, release notes, proposal, or AI research summary, or says text sounds AI-written or buries the point. Do not use for visual or UI slop, for translating between languages, or for making writing casual.
---

# Unbury

Turn exhaustive AI-style explanation into edited engineering communication. The reader is a technically competent engineer who does not yet know the situation. Every edit serves one measure:

**How quickly does that reader build the correct mental model?**

This is not "sound less like AI" and not "make it casual." The output should read like a strong engineer explaining something clearly to another strong engineer. Technical accuracy, necessary qualifications, and the artifact's native format all survive the edit.

## Workflow

1. **Extract the facts before touching the prose.** Read the whole source. List every claim it makes, grouped by the hierarchy below. Note which claims the source actually supports and which it merely asserts. This list is the accuracy contract for the rewrite.
2. **Identify the artifact and its reader.** A PR description is read by a reviewer deciding whether to approve. A Slack update is read by someone deciding whether they need to act. A design doc is read by someone deciding whether the approach is sound. Choose the format from [references/artifacts.md](references/artifacts.md) and keep it.
3. **Write the first sentence as concrete behavior.** State what happened in observable terms: the input, the wrong output, the visible consequence. Framework names, type hierarchies, and wire formats come after the reader can picture the behavior. See the case study in [references/examples.md](references/examples.md).
4. **Order the rest by the hierarchy.** Move context, evidence, alternatives, and edge cases below the point they support. Do not let them precede it. The rule applies inside each section too: a "Cause" section opens with the defect, not with the library background that explains it, and a "Change" section states its scope (which files, surfaces, or consumers) before the code that shows it.
5. **Triage every sentence.** Ask: does the reader need this fact here to understand the idea, make a decision, or verify an important claim? Keep it, move it later, or cut it. Cut content the reader can inspect directly in the code, diff, or linked source.
6. **Only then fix style.** Contrast constructions, triples, metaphors, fragments, em dashes, and parentheticals are edited where they slow comprehension, using [references/patterns.md](references/patterns.md) as a diagnostic list, not a ban list.
7. **Check accuracy against the fact list.** Every claim in the rewrite must trace to the source. Every qualification that changes what is true must survive. No new confidence, no new claims, no softened warnings.
8. **Deliver.** Provide the rewrite in the artifact's format. When the edit removed or relocated substantive content, add a short list of what was removed and what was deliberately kept, so the author can object.

## Information hierarchy for technical explanations

1. What happened? (observable behavior, concrete input and output)
2. What should have happened?
3. Why did it happen? (the mechanism, now that the reader knows the symptom)
4. What changed?
5. How do we know the fix works?
6. Implementation details and edge cases that materially matter

Not every artifact needs every level. A Slack update might stop at level four. A design doc spends most of its length at levels three and four. The order still holds: concrete behavior before framework terminology, the main point before the supporting evidence, the change before the alternatives.

Prefer one concrete example over an abstraction whenever the example communicates the rule. Prefer a literal technical statement over a metaphor whenever the literal statement is as short.

## What to cut, move, or keep

Cut when the reader can get it from the code or when it restates something already established:

- test mechanics beyond the test's name, what it asserts, and its before/after result
- "alternative considered" sections for alternatives no reviewer would propose
- evidence stacked to defend a claim the reader already accepted
- the same fact restated in more dramatic language
- conclusions obvious from the preceding sentence
- process narration ("I then investigated", "it is worth noting")
- reassurance that nothing else changed, unless a reviewer would otherwise worry

Move later when it matters but not yet: caveats, behavior changes, compatibility notes, related work, unverified environments.

Keep, even when it makes the text longer or less tidy:

- qualifications that change what is true ("only on the beta surface", "not verified on Windows")
- explicit statements of what was not done or not verified
- behavior changes a consumer must know about
- how the copies differ when one code snippet stands for changes in several places
- the one number or name a reader needs to verify the claim. A count that CI or the diff already reports is not that number
- the author's uncertainty, stated as uncertainty
- the fact that backs any evaluative word you keep. "Asserts the exact request" needs the one clause that says why a wrong request cannot pass. Otherwise drop the adjective

Expect the correct rewrite to be much shorter than the source. Do not preserve a sentence because the source contained it. Do not shorten by deleting facts the reader needs.

## Style rules that serve comprehension

These are judgments, not prohibitions. Apply them when the construction costs the reader time; leave it alone when it is the clearest option.

- **Contrast constructions** ("not X, but Y", "rather than", "instead of") are fine when the contrast is the point. Remove them when X is a strawman the reader never held.
- **Triples and symmetrical phrasing** ("No exception, no warning, no log line") trade precision for rhythm. Replace with the single fact they encode ("The request succeeds, so nothing flags the problem").
- **Metaphors** ("load-bearing", "dropped on the floor", "plumbing") are fine when the literal version is longer or vaguer. Replace them when the literal version is a plain verb ("discarded", "ignored", "passed through").
- **Em dashes and parentheticals** signal an aside. One aside per paragraph is readable. A paragraph built from asides is a list of facts with no hierarchy; give it one.
- **Sentence fragments for punch** are a tell of drama, not of clarity. Write the sentence.
- **Headings** organize content the reader will navigate. Three sentences do not need a heading.
- **Bullets** are right for parallel, independent items such as before/after test results, and wrong for a causal chain. Do not fold a scannable list into a paragraph to save words.
- **Polished transitions** ("With that in place", "Crucially", "This matters because") usually mark a spot where the previous sentence should have carried the point.
- **Exhaustive completeness** is not accuracy. Listing every case the author checked does not help the reader who needs to know the one case that matters.

## Boundaries

- Never change the meaning of a technical claim, strengthen a hedge into a certainty, or drop a stated limitation.
- Never invent a fact, number, test result, or rationale the source does not contain. If the source is missing a level of the hierarchy, say so rather than fill it.
- Do not remove the artifact's required structure (PR template sections, issue fields, ADR headings) or the author's voice where it carries information.
- Do not simplify the technical content. The reader is competent. Simplify the path to the content.
- When the source has no defect at some level, leave that level alone. Some sentences are already good.

## Self-check before delivering

Read only the first two sentences of the rewrite. Can a reader who has never seen the issue say what was broken? If not, the lede is still buried.

Then read the whole rewrite as the reviewer, decision-maker, or teammate it is for. Can they understand what was broken, why, and what changed substantially faster than from the original, with no loss of what they need to act? If not, iterate.
