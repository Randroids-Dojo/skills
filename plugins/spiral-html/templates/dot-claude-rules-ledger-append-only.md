---
description: Ledger files are append-only. Never delete or rewrite past entries.
paths:
  - "docs/PROGRESS_LOG.html"
  - "docs/OPEN_QUESTIONS.html"
  - "docs/FOLLOWUPS.html"
  - "docs/GDD_COVERAGE.json"
---

<h1>Ledger append-only discipline</h1>

<p>This rule loads when editing the four ledger files. They are the externalized memory of the project. The agent does not remember; the project remembers itself. That contract breaks if past entries are rewritten.</p>

<h2>What to do</h2>

<section data-ledger="docs/PROGRESS_LOG.html">
  <h3><code>docs/PROGRESS_LOG.html</code></h3>
  <ul>
    <li>Add new <code>&lt;article data-slice="..."&gt;</code> entries at the TOP of the relevant section. Newest first.</li>
    <li>Never edit a past entry. If a past entry is wrong, add a new entry that corrects it.</li>
    <li>Every implementation slice gets its own article. Required <code>&lt;dl&gt;</code> fields: Branch / PR / Changed / Verification / Assumptions / GDD coverage / Followups.</li>
  </ul>
</section>

<section data-ledger="docs/OPEN_QUESTIONS.html">
  <h3><code>docs/OPEN_QUESTIONS.html</code></h3>
  <ul>
    <li>New questions get the next monotonic <code>Q-NNN</code> id (set on the <code>&lt;section data-q="..."&gt;</code>).</li>
    <li>When a question resolves, leave the entry in place. Update <code>data-status</code> to <code>resolved</code> and fill in the <code>Resolution</code> entry. Move the entry under the <code>&lt;aside id="resolved"&gt;</code> region.</li>
    <li>Never delete a past question, even if it was wrong. Add a new question that supersedes it and reference the old id in the <code>Resolution</code> entry.</li>
  </ul>
</section>

<section data-ledger="docs/FOLLOWUPS.html">
  <h3><code>docs/FOLLOWUPS.html</code></h3>
  <ul>
    <li>New followups get the next monotonic <code>F-NNN</code> id (set on the <code>&lt;section data-f="..."&gt;</code>).</li>
    <li>When a followup ships, leave the entry in place and append a <code>&lt;dt&gt;Resolved&lt;/dt&gt;&lt;dd&gt;PR #N&lt;/dd&gt;</code> pair. Move under a <code>&lt;main id="resolved"&gt;</code> region if you have one.</li>
    <li>Never delete a past followup, even if it became irrelevant. Add a <code>&lt;dt&gt;Resolved&lt;/dt&gt;&lt;dd&gt;N/A (dropped because &lt;reason&gt;)&lt;/dd&gt;</code> pair and move it.</li>
  </ul>
</section>

<section data-ledger="docs/GDD_COVERAGE.json">
  <h3><code>docs/GDD_COVERAGE.json</code></h3>
  <ul>
    <li>Update <code>status</code> and append to <code>implementationRefs</code> / <code>testRefs</code> / <code>followupRefs</code> as work ships.</li>
    <li>Do not delete rows whose requirements got cut. Set <code>status: "out_of_scope"</code> and add a note.</li>
    <li>The <code>id</code> of a row is permanent. Do not renumber.</li>
  </ul>
</section>

<h2>Why this matters</h2>

<p>A future slice cannot trust ledgers that get retroactively edited. The audit trail is the contract. Treating these files as a database (overwrite + delete) destroys the institutional memory that lets the spiral run for weeks.</p>
