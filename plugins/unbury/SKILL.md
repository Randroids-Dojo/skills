---
name: unbury
description: Rewrite AI-generated or AI-influenced technical writing so a competent engineer builds the correct mental model as fast as possible, without losing technical accuracy. Use when the user asks to de-slop, humanize, tighten, or clarify a PR description, code review comment, design doc, architecture explanation, issue, Slack update, release notes, proposal, or AI research summary, or says text sounds AI-written or buries the point. Do not use for visual or UI slop, for translating between languages, or for making writing casual.
---

# Unbury

Turn exhaustive AI-style explanation into edited engineering communication. The reader is a technically competent engineer who does not yet know the situation. Every edit serves one measure:

**How quickly does that reader build the correct mental model?**

This is not "sound less like AI" and not "make it casual." The output should read like a strong engineer explaining something clearly to another strong engineer. Technical accuracy, necessary qualifications, and the artifact's native format all survive the edit.

The target is minimum cognitive load, not minimum word count. The rewrite may be much shorter, about the same length, or occasionally longer; all three are fine if the reader reaches the correct model faster and every decision-critical fact survives. One added sentence can lower the load when it saves the reader from inferring a consequence they needed. Do not use a compression percentage as a target.

## Workflow

1. **Extract the facts before touching the prose.** Read the whole source. List every claim it makes, grouped by the hierarchy below. Mark each claim as supported by the source, asserted by the source, or unverifiable from where you sit. This list is the accuracy contract for the rewrite.
2. **Identify the artifact and its reader.** A PR description is read by a reviewer deciding whether to approve. A Slack update is read by someone deciding whether they need to act. A design doc is read by someone deciding whether the approach is sound. Choose the format from [references/artifacts.md](references/artifacts.md) and keep it.
3. **Write the first sentence as concrete behavior.** State what happened in observable terms: the input, the wrong output, the visible consequence. Framework names, type hierarchies, and wire formats come after the reader can picture the behavior. The body stands on its own; titles and bodies are shown separately in notifications, changelogs, and search results, so a good title may reduce repetition but never carries the point for the body. The case study in [references/examples.md](references/examples.md) teaches the move; apply it to new material rather than reproducing the example.
4. **Order the rest by the hierarchy.** Move context, evidence, alternatives, and edge cases below the point they support. The rule applies inside each section too: a "Cause" section opens with the defect, not with the library background that explains it, and a "Change" section states its scope (which files, surfaces, or consumers) before the code that shows it.
5. **Check the causal chain you just built.** Does any later claim recreate, contradict, weaken, or qualify a condition established earlier? Handle what you find under "Derived consequences" below.
6. **Triage every sentence.** Does the reader need this fact here to understand the idea, make a decision, or trust a claim? Keep it, move it later, or cut it, using "What to cut, move, or keep" as the deciding authority.
7. **Only then fix style.** Contrast constructions, triples, metaphors, fragments, em dashes, and parentheticals are edited where they slow comprehension, using [references/patterns.md](references/patterns.md) as a diagnostic list, not a ban list.
8. **Check accuracy against the fact list.** Every claim in the rewrite must trace to the source, and every rule under "Boundaries" must hold. A claim you could not verify is carried from the source, neither dropped nor strengthened because verification was unavailable; keep it when it matters to the explanation.
9. **Check what compression removed.** Whenever a shorter draft exists, yours or someone else's, list every fact present in the longer draft and absent from the shorter one and test each against the keep list. A cleaner draft that dropped a behavior change, a compatibility concern, a verification limitation, or a decision-critical caveat is not an improvement. Restore the fact, usually as one sentence, and keep the shorter draft's ordering.
10. **Deliver.** Provide the rewrite in the artifact's format, with delivery notes listing what was removed, what was deliberately kept, any consequence flagged but not written in, and any claim carried unverified where that distinction matters. Verification disclaimers belong in the notes, not the artifact, unless its reader needs them.

## Information hierarchy for technical explanations

1. What happened? (observable behavior, concrete input and output)
2. What should have happened?
3. Why did it happen? (the mechanism, now that the reader knows the symptom)
4. What changed?
5. How do we know the fix works?
6. Implementation details and edge cases that materially matter

Not every artifact needs every level. A Slack update might stop at level four. A design doc spends most of its length at levels three and four. The order still holds: concrete behavior before framework terminology, the main point before the supporting evidence, the change before the alternatives.

Prefer one concrete example over an abstraction whenever the example communicates the rule. Prefer a literal technical statement over a metaphor whenever the literal statement is as short.

## Derived consequences

Once the source's own claims are in causal order, do they compose into something the author did not say? Reordering can expose a relationship the original prose obscured, and a rewrite that only tightens will hide it just as well. Distinguish two cases.

A **directly derived consequence** follows from facts or mechanisms the source already establishes, with no new domain knowledge or assumption. The source says using principal A causes failure X; later it says fallback Y uses principal A. Therefore fallback Y recreates the condition the source says causes X. Surfacing this makes an existing implication explicit, so it belongs in the rewrite, worded to the source's own certainty: "therefore" or "which means" when the source states the mechanism as fact, "appears to" when the source hedged. For example: "Because this fallback again uses the agent principal, it appears to recreate the principal mismatch described above."

An **externally inferred consequence** needs domain knowledge, an assumption, behavior the source does not establish, or investigation beyond what you have. Do not insert it as fact. Flag it in the delivery notes.

This is not code review. It is one question asked of the fact list. A constructed walk-through is in [references/examples.md](references/examples.md).

## What to cut, move, or keep

Cut when it restates something already established or adds nothing the reader will act on:

- test mechanics beyond the test's name, what it asserts, and its before/after result
- "alternative considered" sections for alternatives no reviewer would propose
- evidence stacked to defend a claim the reader already accepted
- the same fact restated in more dramatic language
- conclusions obvious from the preceding sentence
- process narration ("I then investigated", "it is worth noting")
- reassurance that nothing else changed, unless a reviewer would otherwise worry

Move later when it matters but not yet: caveats, behavior changes, compatibility notes, related work, unverified environments.

Keep, even when it makes the text longer or less tidy, because the reader needs it here to decide, evaluate risk, or trust a claim:

- qualifications that change what is true ("only on the beta surface", "not verified on Windows")
- explicit statements of what was not done or not verified
- behavior and compatibility changes a consumer must know about
- a consequence that is not obvious from the source or the diff, including one derived under "Derived consequences"
- how the copies differ when one code snippet stands for changes in several places
- the one number or name a reader needs to verify the claim. A count that CI or the diff already reports is not that number
- identifiers the reader will search for, such as commit hashes, issue and PR numbers, and error strings, including ones you could not verify
- the author's uncertainty, stated as uncertainty
- the fact that backs any evaluative word you keep. "Asserts the exact request" needs the one clause that says why a wrong request cannot pass. Otherwise drop the adjective

That a fact is visible in the diff, tests, CI, or linked source argues for cutting it but does not decide it; the keep list decides. If it is not on the list, prefer the underlying source and drop the sentence. The boundary case from the worked PR example: prose repeating that a new code arm derives `DisableParallelToolUse` with the same expression as its neighbor is probably unnecessary, because the diff shows both arms; it becomes necessary if the derivation has a consequence the diff does not make obvious. Decide by whether the sentence surfaces something, not by whether the diff or the source contained it.

## Style rules that serve comprehension

These are judgments, not prohibitions. Apply them when the construction costs the reader time; leave it alone when it is the clearest option.

- **Contrast constructions** ("not X, but Y", "rather than", "instead of") are fine when the contrast is the point. Remove them when X is a strawman the reader never held.
- **Triples and symmetrical phrasing** ("No exception, no warning, no log line") trade precision for rhythm. Replace with the single fact they encode ("The request succeeds, so nothing flags the problem").
- **Metaphors** ("load-bearing", "dropped on the floor", "plumbing") are fine when the literal version is longer or vaguer. Replace them when the literal version is a plain verb ("discarded", "ignored", "passed through").
- **Em dashes and parentheticals** signal an aside. One aside per paragraph is readable. A paragraph built from asides is a list of facts with no hierarchy; give it one.
- **Sentence fragments for punch** are a tell of drama, not of clarity. Write the sentence.
- **Editorial headings** must earn the interruption they create. They help when the reader will navigate to a section, return to it later, or needs to see that the artifact has independent parts. They cost when a short artifact already has a natural sequence. Ask: does this heading help the reader find something, or does it merely label the paragraph that follows? If it merely labels, remove it and let the prose carry the structure. Headings a template requires or may require are functional content under "Boundaries", not editorial.
- **Bullets** are right for parallel, independent items such as before/after test results, and wrong for a causal chain. Do not fold a scannable list into a paragraph to save words.
- **Polished transitions** ("With that in place", "Crucially", "This matters because") usually mark a spot where the previous sentence should have carried the point.
- **Exhaustive completeness** is not accuracy. Listing every case the author checked does not help the reader who needs to know the one case that matters.

## Boundaries

- Never change the meaning of a technical claim, strengthen a hedge into a certainty, or drop a stated limitation.
- Never invent a fact, number, test result, or rationale the source does not contain. A directly derived consequence is not an invention; an externally inferred one is. If the source is missing a level of the hierarchy, say so in the delivery notes rather than fill it.
- Treat machine-significant and process-required text as functional content, not prose. This includes issue-closing lines (`Fixes #263`, `Closes #12`), GitHub task-list checkboxes (`- [ ]`, `- [x]`), attribution and provenance trailers ("Generated with ..."), changelog directives, template headings that are or may be required, automation markers, structured metadata, and identifiers or commands that must stay exact. A provenance trailer is not a sign-off flourish when it serves a machine, a repository convention, or an attribution requirement. Do not rewrite, relocate, merge, or delete any of these unless you know what consumes them and the result preserves that behavior. When unsure, leave the token and its placement untouched.
- Do not remove the author's voice where it carries information, such as first-person reports of what was and was not verified.
- Do not simplify the technical content. The reader is competent. Simplify the path to the content.
- When the source has no defect at some level, leave that level alone. Some sentences are already good.

## Self-check before delivering

Answer each question; if any answer is no, iterate.

- Reading only the first two sentences, without the title: can a reader who has never seen the issue say what was broken?
- Reading the causal chain once more: is every relationship found in step 5 either stated in the rewrite or flagged in the delivery notes?
- Reading the whole rewrite as its intended reader: do they understand what was broken, why, and what changed substantially faster than from the original, with nothing they need to act on lost?
- For each sentence after the explanation is complete: could the reader get it only here, or does the keep list require it? If neither, it goes.
- Compared with the longest correct draft you produced: is everything on the keep list still present?
