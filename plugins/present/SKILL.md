---
name: present
description: Plan, build, or revise clear presentations, pitches, explanatory documents, and interactive HTML arguments using appropriate visuals and inspectable evidence. Use when the user asks to turn research or source material into a deck or document, improve an existing presentation's structure and visual explanation, or add useful interactivity to a pitch. Also use for guidance or an outline for those artifacts. Do not use for routine prose-only edits, simple file conversion, generic websites or dashboards, or ordinary questions that do not request presentation or document guidance.
---

# Present

Help the intended reader understand an idea, examine its support, and make the requested decision or use the explanation. Work on the user's actual subject. Produce the requested artifact or guidance; do not substitute a proposal about improving communication.

Treat the research as guidance for design choices, with explicit limits. Studies of learning and comprehension do not establish that a business pitch will win approval. Avoid universal slide counts, word limits, compression targets, and promises that interaction improves every presentation.

## Read the relevant references

- Read [composition](references/composition.md) when planning or revising the structure, visuals, or layout of a deck or document.
- Read [interactive HTML](references/interactive-html.md) before choosing interactions or building an HTML presentation. It covers live and independent use, transparent models, implementation, export, and verification.
- Read [research](references/research.md) when explaining the evidence behind a recommendation, resolving a design tradeoff, or writing about presentation methods. It separates experiments, practitioner precedents, and practical inferences.
- Consult [worked examples](references/examples.md) when translating a source claim into an exhibit, choosing an interaction, or preparing instructions for another agent.

Use the available format-specific skills and tools for native slide, document, PDF, or web authoring and delivery. Resolve resources relative to this skill directory. Keep the workflow portable; do not assume a particular editor, hosting service, browser tool, or installed sibling skill.

## Workflow

### 1. Establish the assignment from the available context

Identify the subject, intended audience, their existing knowledge, what they need to understand or decide, the delivery setting, and the required format. Distinguish a live presentation from something read independently. Respect explicit length, template, brand, accessibility, and native-editability requirements.

Read the supplied material and inspect an existing artifact before redesigning it. Reuse established context and preferences. Ask only when missing information would materially change correctness or direction; otherwise state a reasonable assumption briefly and continue. Do not invent a decision or call to action for an explanatory document that needs neither.

For a revision, retain factual meaning, required sections, functional links, source attribution, notes, and useful existing design. Match the scope of the request. A request to fix a chart does not authorize replacing the whole deck.

### 2. Establish what the source supports

Maintain a lightweight inventory of the claims, their evidence, and qualifications that change their meaning. Distinguish observed results, source assertions, estimates, model outputs, and illustrative examples. Track units, denominators, populations, time periods, and uncertainty when they matter.

Use supplied evidence before conducting additional research. Verify time-sensitive or uncertain claims against suitable primary sources when needed. Place citations close to the claims they support; preserve enough source detail for a reader to check them. Do not invent numbers, benefits, causal relationships, quotes, or user behavior to make a visual work. Label a missing input and limit the claim it prevents you from making.

### 3. Plan the reading sequence and the exhibits together

Lead with the useful answer, recommendation, or orienting question. Give enough context for a reader to recognize the situation. Use a concrete case when it clarifies an abstraction. Order the explanation by the relationships the reader needs, not by the order in which the research happened.

For each section, decide the reader's question, the supported point, the evidence that makes it understandable, and the consequence. Keep this planning scaffold out of the final artifact unless it helps its reader.

Give an argumentative slide a clear supported claim and evidence the audience can examine. Topic headings and concise labels remain appropriate for navigation, introductions, reference material, and genuine questions. Do not force every heading into a sentence or every slide into the same layout.

Choose visual forms from composition.md. Draw the relevant relationship, show the actual interface, or compare the actual alternatives. Add complexity in stages when needed, retaining earlier information required to understand the next step. Keep compared cases visible together where possible.

### 4. Decide whether interaction helps

Choose an interaction only when it helps the audience answer a consequential question by changing an assumption, comparing a case, following a process, inspecting evidence, or trying representative behavior. Use interactive-html.md to specify the input, the resulting change, and the insight before implementing it. This is a design step, not an extra approval gate.

Make the main explanation and a meaningful result visible before interaction. Keep material limitations visible. Offer exploration at the point it becomes useful. A control that merely reveals another paragraph may add unnecessary work. When the intended delivery environment cannot support the interaction, choose clear static scenarios or a linked demonstration.

### 5. Build the actual artifact

Use the requested format and the appropriate authoring tools. A scrolling HTML document, HTML slide deck, native deck, or static document can each be appropriate. Do not change formats merely because a different tool is easier to use.

Build an intentional hierarchy with consistent typography, spacing, alignment, labels, and visual encodings. Use relevant imagery, diagrams, or screenshots that carry information. Avoid decorative components repeated across unrelated ideas, irrelevant stock imagery, and animation without an explanatory purpose. Preserve meaningful density; a cleaner layout can contain substantial information.

Write connected prose that states the actual behavior and reasoning. Replace vague slogans and fragment chains such as "One budget. Two apps. A choice you can examine." with a concrete heading or explanation of the relationship. Keep useful short labels and independent facts. Do not impose groups of three, rhetorical contrasts, or dramatic cadence on the source.

Use the unbury skill for a prose pass when available and appropriate, without making it a required installation. Preserve qualifications, technical meaning, required metadata, and functional text during editing. Clear writing and useful visuals must reinforce each other.

For an independently read version, supply the context that live narration would otherwise provide. For print or PDF, make essential results, assumptions, and qualifications readable in static form. Keep text searchable and available to assistive tools; ensure that the central argument survives a reader or agent receiving only the initial page or export.

### 6. Verify the delivered experience

Check claims against the source inventory after editing. Verify arithmetic, chart labels, scales, sample definitions, and the logic behind any calculated conclusion. Keep comparisons under consistent conditions; disclose meaningful differences.

Render and inspect the actual pages or slides using the format's verification workflow. Check hierarchy, text fit, readable labels, source placement, and missing or misleading elements. For a revision, inspect the changed views and any affected export; do not expand verification without a concrete reason.

For HTML, exercise the actual controls and their resulting text and visuals. Check representative states, relevant boundaries or failure cases, reset behavior, keyboard access, a narrow screen, and the real print/export output. A code check is not a browser check, and a successfully written file is not proof that a viewer can open it. State any material verification limitation honestly.

Use a quick reader check suited to the task: can someone state the main point, explain its support, and identify the important limit or decision? When possible, ask a fresh reviewer to do that from the artifact. Judge correctness and useful understanding rather than clicks, time spent, or visual polish alone.

### 7. Deliver within the user's scope

Provide the finished artifact or requested guidance, with a concise explanation of the important choices and any unresolved gaps. If building is requested, continue through authoring and verification rather than stopping at an outline. If only advice or an agent handoff is requested, deliver that without manufacturing extra files.

Follow the host's file-saving and sharing rules. Preserve the identity of an existing artifact when updating it; create a new artifact when requested. Publish, deploy, send, or modify an external service only when the session authorizes that action. Reuse existing authorization rather than asking again.

## Completion check

- Does the work explain the user's actual subject in the requested form?
- Can a new reader understand the main point before interacting?
- Does each important claim have appropriate support and its material qualifications?
- Do the visuals make relationships easier to see, with comparisons kept honest?
- Does each interaction answer a useful question and update all affected results?
- Do the intended viewing and exported versions work, with any limits reported?
- Has editing preserved facts and useful detail while removing unnecessary effort?
