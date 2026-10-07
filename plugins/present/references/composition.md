# Composition

Compose for the audience and delivery. Treat these choices as guidance, not universal laws about attention or learning. See [research.md](research.md) for supporting research and its limits.

## Contents

- [Choose the delivery](#choose-the-delivery)
- [Connect claims and evidence](#connect-claims-and-evidence)
- [Match the representation to the information](#match-the-representation-to-the-information)
- [Preserve the meaning of evidence](#preserve-the-meaning-of-evidence)
- [Compose a readable visual hierarchy](#compose-a-readable-visual-hierarchy)
- [Respect existing artifacts and constraints](#respect-existing-artifacts-and-constraints)
- [Worked example](#worked-example)

## Choose the delivery

| Delivery | Compose for | Keep available |
| --- | --- | --- |
| Live deck | A speaker explaining a sequence. Use readable visuals, selective labels, and controlled reveals. | Supporting detail in notes or appendix; a usable static view of each important explanation. |
| Read-alone deck or document | A reader who cannot hear the missing explanation. Include context, transitions, captions, definitions, and qualifications. | References and methods that readers can inspect without guessing what a figure means. |
| Interactive page | A reader who benefits from changing an input, tracing a process, inspecting evidence, or choosing a relevant route. | A meaningful initial view, clear controls, essential caveats, and a static explanation. |

Honor the requested format. Choose HTML for useful behavior or distribution requirements. For dual-use decks, supply notes or a companion explanation that survives sharing.

## Connect claims and evidence

Before laying out a slide or section, identify its purpose, material claim, supporting evidence, and necessary qualification. Split content when those purposes compete; retain related material when seeing it together enables comparison.

Use a takeaway title for a supported finding. Use a short label or question when it better serves navigation. Do not force sentence headings or exaggerate certainty. Place evidence near the claim it supports.

Start unfamiliar material with a concrete case: one task, customer situation, transaction, or system event. Distinguish its relevance from evidence about prevalence. Reuse the case while adding complexity. Preserve positions, labels, and scale across stages; introduce each element when needed. Finish with a complete reference view when the parts need to be understood together.

## Match the representation to the information

| Information | Useful representation | Composition guidance |
| --- | --- | --- |
| Amount, trend, distribution | Chart | Choose the chart for the comparison; label measures and meaningful differences. |
| Exact values or several comparable attributes | Table | Align comparable fields; make units and missing values explicit. |
| Existing interface or observable problem | Annotated screenshot | Crop to relevant context; point to the behavior or detail being discussed. |
| Components and relationships | Diagram | Use labeled connections and only the components needed for the explanation. |
| Ordered events, handoffs, or timing | Process diagram, sequence, or timeline | Make order, actors, conditions, and waiting visible where relevant. |
| Alternatives or before-and-after behavior | Matched views | Keep inputs, layout, scale, and measurement definitions consistent. |
| Consequences under varying assumptions | Scenario table or sensitivity chart | Expose assumptions and limits; use controls only if exploration adds value. |

Use photography, illustration, and video when appearance, setting, emotion, or behavior contributes to understanding. Decorative icons, stock imagery, and repeated cards should earn their space. Keep a demonstration's simulated behavior distinguishable from working functionality.

## Preserve the meaning of evidence

- Label units, population, time window, sample size, and measurement definitions where needed to interpret a figure. Distinguish counts, rates, percentage changes, and percentage-point changes.
- Start bars at zero when their lengths encode magnitude. For line or scatter plots, choose a range that serves the question and visibly disclose relevant truncation. Avoid comparing magnitudes across inconsistent scales.
- Preserve uncertainty, missingness, exclusions, and denominators. Identify whether ranges represent confidence intervals, observed variation, or scenarios. Do not imply uncertainty estimates exist when none were supplied.
- Compare the same data conditions where possible. If samples, dates, exposure, or definitions differ, explain that beside the comparison. Avoid attributing causation to an uncontrolled before-and-after change.
- Preserve the distinction between observed facts, calculations, estimates, assumptions, and illustrations. Recalculate derived numbers from source values; do not improve the apparent result through rounding or selective examples.
- Put material caveats beside the conclusion. Provide real, retrievable sources with dates or locators in captions, notes, or references. Never invent citations, quotations, customer evidence, or precision.

## Compose a readable visual hierarchy

Establish a small hierarchy for titles, body text, captions, and supporting detail. Choose type sizes for the actual viewport, projection distance, or printed page; inspect at the intended viewing size. Avoid shrinking content until it fits. Recompose, split, or move secondary detail when necessary.

Use a consistent alignment grid, margins, spacing, and chart-label placement. Keep labels near their referents. Reuse colors, shapes, and line styles for the same meanings across the artifact. Do not rely on color alone: add labels, patterns, or other distinguishable cues.

Aim for useful density: leave space that clarifies grouping while retaining needed detail. A comparison may need several panels; a reference page may need a dense table. Avoid arbitrary word quotas, mandatory card layouts, and repeated slogans.

Make beauty relevant through typography, proportion, imagery, and restraint. Preserve contrast, logical reading order, semantic headings, meaningful link text, and text alternatives for informative visuals. Caption meaningful audio or video. Keep essential information accessible without motion, hover, or a particular color perception.

## Respect existing artifacts and constraints

Inspect the source artifact, template, brand rules, and requested changes before revising. Preserve required wording, relationships, section order, notes, citations, legal text, and unresolved comments unless the task authorizes changing them. Distinguish editorial cleanup from substantive changes.

Use native editable text, tables, charts, and shapes when the requested artifact supports them. Preserve master layouts, theme fonts, brand colors, aspect ratio, and object editability where applicable. Check export behavior, reading order, clipping, wrapping, and font substitution. If a constraint prevents clarity, propose a specific adjustment rather than silently discarding it.

## Worked example

**Invented source facts for illustration only:** A fictional worksheet contains 20 scripted tasks, each run through the current flow and a prototype. Median completion time is 8 minutes versus 5 minutes. Validation failures are 0 of 20 versus 2 of 20. These are single scripted runs, not a study with real users; no statistical uncertainty is available.

**Live slide:** Use the supported title, “The prototype is faster in this example, with more validation failures.” Show two bars on one zero-based axis labeled “Median minutes per task”: Current 8; Prototype 5. Place failure counts beside the corresponding bars. Include a visible qualification: “Invented illustration; same 20 scripted tasks; no real-user evidence.” Let narration explain the workflow difference; keep the fictional worksheet and calculation detail in notes.

**Read-alone document:** Retain the same values, counts, and chart scales. Explain what was compared; mark the validation-failure definition as unspecified rather than inventing it. Caption the chart with the task set and units. Explain that this illustrates a speed/error tradeoff but establishes neither real-user benefit nor causation. Keep the caveat beside the finding and include the illustrative source table for inspection without a presenter.
