# Artifact formats

Keep the shape the artifact's readers expect. The skill removes cognitive overhead inside that shape; it does not flatten every artifact into one short paragraph. For each type: who reads it, what the first sentence must do, which structure survives, and what is most often cut.

| Artifact | Reader and decision | First sentence | Structure to keep | Usually cut |
| --- | --- | --- | --- | --- |
| PR description | Reviewer deciding whether to approve | The wrong behavior, or for a feature, what the user can now do | A template's required sections stay. Headings only where a reviewer will jump to a section; a short description with a natural sequence reads faster as paragraphs | Test internals, defended alternatives, restated assurances, praise of the fix |
| Code review comment | Author deciding whether to change the code | The problem in the code and its consequence | One comment, one point. A suggestion block when the fix is short | Motivation essays, hedged politeness stacks, restating the code being commented on |
| Technical documentation | User trying to do or understand one thing | What the thing does, in the user's terms | Reference structure, parameter tables, examples | Marketing framing, history, alternatives not offered |
| Architecture explanation | Engineer building a mental model of the system | The responsibility of the component and its main interaction | Diagrams, component lists, data flow in order | Implementation trivia, justifications for choices no one questions |
| Design document | Reviewer deciding whether the approach is sound | The problem and the proposed decision | Problem, goals and non-goals, proposal, alternatives, risks, open questions. Can stay long | Exhaustive alternative dismissal, restated goals in every section, defensive caveats |
| Issue description | Maintainer deciding priority and reproducing | Expected versus actual behavior, with the concrete input | Environment, reproduction, expected, actual, workaround if any | Speculated fixes ahead of the symptom, evidence stacking, proof of diligence |
| Slack message | Teammate deciding whether they need to act | The status or the ask | Plain paragraphs, at most a short list. No headings | Background the channel already knows, hedges, sign-off flourishes (not provenance or attribution trailers, which are functional) |
| Project update | Stakeholder deciding whether to intervene | State relative to plan and anything that needs their decision | Done, in progress, blocked, decisions needed | Narrative of the week, per-task detail, self-assessment |
| Release notes | User deciding whether to upgrade and what to change | What changed for the user, breaking changes first | Grouped by impact: breaking, added, fixed | Internal refactors, implementation mechanics, how hard it was |
| Engineering proposal | Decision-maker deciding yes, no, or later | The proposal and its cost in one or two sentences | Proposal, why now, cost, risks, what happens if we do nothing | Preamble on the importance of the topic, symmetric pros and cons padding |
| AI research summary | Reader deciding whether to read the source | The finding and its limits | Finding, evidence, limits, what it means for us | Faux-profound framing, symmetrical "not only, but also" claims, restated significance |

## Rules that apply across artifacts

- Match the length to the reader's decision, not to the length of the source.
- If the artifact's template requires a section the source has nothing for, write one honest sentence ("Not verified on Windows") rather than padding.
- Code blocks and tables often replace paragraphs. A before/after pair of wire payloads explains a serialization bug faster than any prose.
- Preserve links, identifiers, version numbers, and names the reader will search for.
- Preserve machine-significant text exactly and in place: issue-closing lines (`Fixes #263`, `Closes #12`), task-list checkboxes (`- [ ]`, `- [x]`), attribution trailers ("Generated with ..."), changelog directives, template headings, automation markers, structured metadata. GitHub, bots, and release tooling read these, so rewriting or relocating them changes behavior, not style. A heading that may be template-required is preserved; the editorial-heading rule does not apply to it.
- The body stands alone. Titles and bodies appear separately in notifications, changelogs, search results, and API responses. A good title lets the body repeat less, but never lets it assume the reader saw the title.
- Keep the author's first person where they are reporting what they did or did not verify. It carries accountability.
- Put a behavior change that consumers must know about at the end of the section describing the change, not in trailing notes. A compatibility-minded reader looks for it there.
