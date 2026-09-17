# Patterns that slow the reader

Use this as a diagnostic list. Each entry names the pattern, what it costs the reader, the usual fix, and when to leave it alone. A pattern is a defect only when it costs the reader time or accuracy in this text. Clusters matter more than single occurrences; one em dash is style, and a paragraph of them is a missing hierarchy.

The first group causes real comprehension problems. The later groups are mostly stylistic tells; fix them second, and only where they get in the way.

## 1. Information order

These cost the most because the reader cannot find the point without reading everything.

| Pattern | What it looks like | Cost | Fix |
| --- | --- | --- | --- |
| Implementation before behavior | "In `Microsoft.Extensions.AI`, require-any and require-specific are the same type, differing by a nullable property..." | The reader must hold framework details in memory with no idea what they explain | Open with the observable wrong behavior, then explain the representation that caused it |
| Buried main point | Context, qualifications, and evidence precede the claim they support | The reader reads the evidence without knowing what it is evidence for | State the claim, then support it |
| Flat rhetorical weight | Every fact gets its own sentence, bold, or bullet at the same level | The reader cannot tell the central idea from a side effect | Give the central idea the first sentence; subordinate the rest grammatically or move it down |
| Preemptive defense | Every objection a reviewer might raise is answered before the change is explained | The reader processes rebuttals to objections they have not formed | Explain the change, then answer the one or two objections a reviewer would actually raise, in a notes section |
| Mixed altitude | Conceptual behavior, framework abstractions, code, and wire format interleaved in one paragraph | The reader cannot tell which layer a sentence describes | Establish the relationship once (behavior, then representation, then wire), and keep each paragraph on one layer |
| Abstraction before example | A general rule stated in full, followed by no instance | The reader has to invent the instance to check the rule | Give the concrete example first, or instead |
| Reasoning narration | "I first considered X, then realized Y, so I went with Z" | The reader retraces a path they did not need to walk | State Z. Mention X only if a reviewer would propose it |
| Summary after every section | Each heading ends by restating its own point; the document ends by restating all of them | Length grows with no new information | Delete the restatement. If the section's point was unclear, fix the section |
| Hidden implication | The cause says "A causes X"; a later section says "the fallback uses A"; nothing connects them | The reader either misses that the fallback recreates X or has to derive it, and the clearer rewrite hides it just as well as the original did | State the relationship, at the source's own certainty, if it follows from the source's claims alone; otherwise flag it for the author. See "Derived consequences" in SKILL.md |

## 2. Over-completeness and defense

| Pattern | What it looks like | Cost | Fix |
| --- | --- | --- | --- |
| Evidence stacking | Three independent proofs of a claim the reader accepted after the first | Dilutes the one proof that matters | Keep the strongest, cite the rest by name if at all |
| Dramatic restatement | "The name was dropped. The call succeeded anyway. Nothing warned. The getter had zero call sites in the shipped assembly." | Four sentences carry one fact; the escalation reads as persuasion | State the fact once, precisely |
| Canned assurance | "All existing tests pass and behavior is preserved" attached to every change | The reader cannot tell where real risk lives, because every change claims none | Report the specific check that was run and the specific thing not verified |
| Hedge stacks | "This should, in most cases, generally be safe, though edge cases may exist" | The reader cannot tell whether the author is worried | One hedge, stated as the specific condition it covers |
| Exhaustive alternatives | An alternatives section listing options no one would propose | The reader evaluates options that were never live | Keep alternatives a reviewer would raise or the team previously chose |
| Test mechanics in prose | The assertion strategy, comparison semantics, and handler design described in full | The reader can read the test; prose cannot be verified against itself | Name the test, what it asserts, and its before/after result |
| Obvious conclusion restated | "That is the point of the fix" after a sentence that already made the point | Nothing new | Delete |
| Reassurance nobody asked for | "Nothing to document outside this repo" | Reader must decide whether the absence is meaningful | Delete unless a reviewer would otherwise check |

## 3. Rhetorical constructions

| Pattern | What it looks like | Cost | Fix | Leave it when |
| --- | --- | --- | --- | --- |
| Contrast against a strawman | "This isn't a refactor, it's a correctness fix" | The reader discards a claim nobody made | "This fixes a correctness bug" | The reader plausibly held X, and the contrast corrects them |
| Escalating contrast | "It's not just faster, it's cheaper" | Two facts dressed as a reveal | "It is faster and cheaper" | Never needed for facts |
| Triple negation | "No exception, no warning, no log line" | Rhythm substitutes for the one precise fact | "The request succeeds, so nothing signals the problem" | The three items are genuinely distinct and each matters |
| Symmetrical pairs | "Matching on the property rather than the type" | Sometimes fine, but often the "rather than" clause restates the bug already explained | Keep only when the reader needs the contrast to understand the change | The contrast is the actual content |
| Punchy fragment | "Not a detail. A design decision." | Drama, no added information | Write the sentence | Never in technical text |
| Self-posed question | "The fix? A single null check." | Suspense the reader did not want | "The fix is a null check" | Never in technical text |
| Invented concept label | "This is the acceleration trap" | The reader learns a term that exists only in this document | Describe the mechanism | The label is already used by the team |
| Polished transition | "Crucially", "With that in place", "This matters because" | Marks a spot where the previous sentence failed to carry the point | Delete, then check whether the previous sentence needs to be stronger | Rarely |

## 4. Word-level tics

| Pattern | Example | Fix | Leave it when |
| --- | --- | --- | --- |
| Metaphor for a plain verb | "dropped on the floor", "load-bearing", "plumbing", "the seam" | "discarded", "required", "transport code", "the boundary" | The literal version is longer or vaguer |
| Vague attribution | "Best practice suggests" | Name the source or delete the appeal | Never |
| Synonym cycling | the handler, the endpoint, the route, for one thing | Pick one name and reuse it | Never in technical text |
| Magic adverbs | "quietly", "actually", "simply" | Delete; state the mechanism if the adverb was hiding one | The adverb carries a fact ("silently" meaning "without an error") |
| Generic AI vocabulary | delve, robust, seamless, leverage, streamline, pivotal, underscore | Replace with the specific claim | The word is the precise one |
| "Serves as" | "serves as the entry point" | "is the entry point" | Never |
| Filler stance | "It's worth noting", "To be clear", "I want to be transparent that" | Delete; state the thing | Never |

## 5. Formatting habits

| Pattern | Cost | Fix | Leave it when |
| --- | --- | --- | --- |
| Heading that only labels the next paragraph | The reader stops for a signpost that points nowhere; a short artifact with a natural sequence gains no navigation from it | Ask whether the heading helps the reader find something. If it only labels, remove it and let the prose carry the structure | The reader will jump to or return to the section, the artifact has genuinely independent parts, or the template requires it |
| Bullets replacing prose | Bullets drop "because", "so", and "unless", so the reader loses the causal chain | Write the paragraph when the items depend on each other | The items are genuinely parallel and independent |
| Bold on random nouns | Emphasis with no hierarchy | Bold the one thing a skimmer must not miss, or nothing | Consistent use for a label pattern |
| Em dash as universal joiner | Facts are chained without stating their relationship | Use the conjunction that names the relationship, or split the sentence | A single aside where an aside is the clearest form |
| Parenthetical stacks | Each qualifier hides in parentheses so the sentence looks simpler than it is | Promote the qualifier that matters to its own sentence; delete the rest | One short parenthetical that would otherwise interrupt the sentence |
| Tables for non-tabular content | The reader looks for a comparison that is not there | Prose or a list | The content has rows and columns |

## Reading the diagnosis

The fix for most of these is not deletion. It is deciding what the reader needs first, and putting it first. Once the main point leads, many tells become harmless or disappear because the sentences that carried them no longer exist.
