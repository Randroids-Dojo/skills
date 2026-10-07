# Interactive HTML for pitches and explanations

## Contents

- [Choose the viewing form](#choose-the-viewing-form)
- [Choose an interaction](#choose-an-interaction)
- [Make models inspectable](#make-models-inspectable)
- [Design the reading experience](#design-the-reading-experience)
- [Implement and verify](#implement-and-verify)
- [Current technical references](#current-technical-references)

## Choose the viewing form

Choose HTML when changing, inspecting, or trying something helps evaluate the idea, and the intended audience can reliably open it. HTML also supports ordinary static explanation. Do not treat the file format itself as an improvement in the argument.

| Setting | Starting point | Design consequence |
| --- | --- | --- |
| Readers open a shared link independently | A responsive scrolling document with section links | Provide a complete reading order, meaningful initial exhibits, and optional exploration nearby. |
| A presenter guides a meeting | An HTML slide deck or a document prepared for presentation | Use legible projected views, presenter-controlled pacing, and prepared examples with reset. |
| Both live and independent use | Shared content with deliberately designed presentation and reading views | Replace missing narration with captions or prose; test both layouts. A mode switch alone does not supply the explanation. |
| Reviewers require a native deck or PDF | The required artifact with static scenarios and a link to a useful demo | Preserve a complete argument in the required format. |

For a short independent pitch, start with HTML, CSS, and enough JavaScript for the useful behavior. Add a framework when its capabilities justify it. For slide navigation, speaker notes, scroll view, and PDF export, consider reveal.js; verify current documentation before relying on configuration details. Select a data or UI framework only when the exhibit's complexity needs it. Avoid turning a small explanation into an unnecessary application.

## Choose an interaction

For each proposed control, identify the reader's question, the input they change, the visible consequence, and the insight. Reject the control if that relationship is unclear. Do not require the user to approve routine interaction choices within an authorized build.

| Reader question | Pattern | Required behavior |
| --- | --- | --- |
| How do these approaches differ? | Synchronized comparison | Feed the same case and progress state into both approaches; keep units, scales, and outputs comparable. |
| Does the recommendation hold under my assumptions? | A small scenario model | Recalculate the relevant results and explanatory text together; expose assumptions and limits. |
| What happens next, including when something fails? | A process with next, back, pause, and reset | Preserve the relevant prior state, identify the active step, and provide a readable complete overview. |
| Can I do the proposed task? | A bounded prototype | Support one representative task and a relevant exception; label simulated behavior and avoid implying production readiness. |
| Where does this claim come from? | Evidence next to the claim | Reveal source details or calculations without losing the reader's place; keep decision-changing caveats visible. |
| How does this apply to my situation? | Relevant examples or section navigation | Give readers a clear route to useful material and back to the main explanation; keep the shared conclusion accessible. |
| Is my intuition wrong in a useful way? | An optional prediction followed by evidence | Ask one meaningful prediction, then explain the measured or modeled result; keep a skip and a complete readable answer. |

The comparison pattern has a practitioner precedent in [Red Blob Games' diagram structure](https://www.redblobgames.com/making-of/diagram-structure/). Optional prediction has a precedent in [Nicky Case's design patterns](https://blog.ncase.me/explorable-explanations-4-more-design-patterns/). Treat these as adaptable methods, not proven business outcomes.

## Make models inspectable

Choose controls for variables the reader can reasonably question. Distinguish measured inputs from assumed or illustrative inputs. Show units, provenance, definitions, and material omissions. Explain the calculation near the result or in an accessible detail view. Limit precision to what the evidence supports.

Keep a meaningful default with labeled presets when they save effort. Expose plausible adverse conditions if they affect the decision. When the model's own assumptions imply that the proposed approach becomes worse, update the explanation accordingly. Do not force a reversal where the model contains none or invent uncertainty to manufacture balance.

Handle dependent inputs consistently. A cost, capacity, or probability assumption may affect several outputs; update charts, numbers, captions, and verdicts from the same state. Declare important constraints rather than allowing impossible combinations. Use a model only where a defensible relationship exists; do not translate qualitative uncertainty into arbitrary scores.

Use sensitivity to show what would change the decision. If a range is a scenario range, label it as such; do not present it as a confidence interval. A responsive result demonstrates the stated calculation or mechanism. It does not establish that the forecast or simulated product behavior will occur in practice.

These choices apply [Bret Victor's argument for explorable models within an authored explanation](https://worrydream.com/ExplorableExplanations/). Consult research.md for its scope and the limits of the empirical evidence on interaction.

## Design the reading experience

Make the recommendation or main explanation understandable before a reader uses a control. Pair each exhibit with an explanation of what is already visible and a specific invitation to explore when needed. Preserve the reader's position as values change. Keep controls close to their effects, labeled in the reader's terms.

Use ordinary navigation and scrolling unless another behavior serves the explanation. Avoid scroll hijacking, mandatory quizzes, hover-only discoveries, and content that appears only after a long animation. Use motion to explain a transition or relationship. Provide user control over pacing and respect reduced-motion preferences.

Prefer semantic headings, paragraphs, tables, buttons, labels, and form inputs. Keep text selectable, searchable, and available to assistive tools. Provide keyboard operation and visible focus; avoid drag-only controls. Give important graphics an equivalent text or tabular explanation. Test on a narrow screen rather than assuming the desktop layout scales down.

For forwarding and review, use stable section links. Preserve scenario state in a shareable link when it helps reviewers discuss the same case; only encode information appropriate for that delivery channel. Make reset discoverable. Use versioned or dated evidence when the underlying facts can change.

For print/PDF, explicitly author the default and other decision-relevant scenarios as labeled static views. Include their input values, results, and limitations. Exclude useless inactive controls from the print layout. Retain sources and necessary explanation; inspect pagination and clipping. Do not assume custom widgets will export correctly or that printed controls remain interactive.

## Implement and verify

Keep presentation content, assumptions, calculation logic, and rendering understandable in the source. Derive related output from one consistent state. Avoid a backend, external API, live data dependency, or AI generation inside the reader's flow unless the task needs it. Where the viewing environment requires an offline file, package the necessary assets appropriately.

Verify the actual artifact with the tools available in the environment:

1. Check calculations against independently worked examples, including any threshold where the conclusion changes. Exercise relevant edge cases and invalid inputs.
2. Operate the controls in a browser. Confirm every affected visual and sentence updates correctly, repeated use is stable, and reset returns to the initial state.
3. Inspect the intended desktop or projected view, a narrow view, keyboard operation, and reduced-motion behavior where motion is used.
4. Open the actual shared or embedded result when permitted. Verify that its viewer can read the path or URL. Distinguish a host delivery error from a JavaScript error before editing the exhibit.
5. Inspect the actual print/PDF or other required fallback. Check that a reader can still follow the important cases and their evidence.

Use proportionate verification. If the browser or target host cannot be exercised, report that specific limit; passing DOM or syntax checks does not establish a successful render. Diagnose read failures using the current environment's allowed roots, file type, and viewer contract. Do not copy a workspace path from an unrelated session or treat a successfully written file as a delivered visualization.

## Current technical references

Checked 2026-10-07. Recheck when implementing; capabilities and defaults may change.

- [reveal.js scroll view](https://revealjs.com/scroll-view/): supports viewing authored slides as a scrollable page. Review navigation and snapping settings for the intended reading experience.
- [reveal.js speaker view](https://revealjs.com/speaker-view/): supports notes, next-slide preview, and a timer; local speaker view requires a local web server.
- [reveal.js PDF export](https://revealjs.com/pdf-export/): documents browser printing, notes, and fragment handling. The documented export support is confirmed for Chrome/Chromium; custom exhibits still need inspection.
- [W3C: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html): explains keyboard access and pointer alternatives.
- [W3C: Animation from Interactions](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions): explains disabling nonessential motion and reduced-motion support. This is a Level AAA criterion; applying it alone does not establish full accessibility conformance.
