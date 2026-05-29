---
description: Every shipped feature appends a Build log entry to the relevant GDD section.
paths:
  - "docs/gdd/**.html"
---

<h1>GDD build log discipline</h1>

<p>This rule loads when editing GDD section files. Each section is the canonical spec for one requirement. Build logs grow with the code so the next slice can read what landed without rediscovering it.</p>

<h2>What to do</h2>

<p>Every GDD section file follows this shape:</p>

<pre><code>&lt;!DOCTYPE html&gt;
&lt;html lang="en"&gt;
&lt;head&gt;&lt;meta charset="utf-8"&gt;&lt;title&gt;&lt;Requirement title&gt;&lt;/title&gt;&lt;/head&gt;
&lt;body&gt;

  &lt;h1&gt;&lt;Requirement title&gt;&lt;/h1&gt;
  &lt;p data-status="not_started|partial|done"&gt;Status: &lt;status&gt;&lt;/p&gt;

  &lt;section data-role="spec"&gt;
    &lt;p&gt;Spec text: what the feature is, what it does, what it does NOT do.&lt;/p&gt;
  &lt;/section&gt;

  &lt;section data-role="build-log"&gt;
    &lt;h2&gt;Build log&lt;/h2&gt;
    &lt;ul&gt;
      &lt;li data-date="YYYY-MM-DD"&gt;one-line summary of what shipped. Files: &lt;code&gt;src/...&lt;/code&gt;, &lt;code&gt;tests/...&lt;/code&gt;. PR #N.&lt;/li&gt;
      &lt;li data-date="YYYY-MM-DD"&gt;Earlier entry&lt;/li&gt;
      &lt;li data-date="YYYY-MM-DD"&gt;Earliest entry, kept verbatim&lt;/li&gt;
    &lt;/ul&gt;
  &lt;/section&gt;

&lt;/body&gt;
&lt;/html&gt;
</code></pre>

<p>When a slice touches the requirement covered by this file:</p>

<ol>
  <li>Update the <code>&lt;p data-status="..."&gt;</code> value if the status changed (<code>not_started</code> → <code>partial</code>, <code>partial</code> → <code>done</code>).</li>
  <li>Append a new <code>&lt;li data-date="..."&gt;</code> to the top of the <code>&lt;section data-role="build-log"&gt;</code> list.</li>
  <li>The build log entry MUST name the key files added or modified.</li>
  <li>The build log entry MUST link the PR number once known.</li>
  <li>Do NOT rewrite past build log entries, even if the implementation has since changed. Add a new entry instead.</li>
  <li>When this slice CREATES a new GDD section file, add a matching entry to the Index in <code>docs/gdd/index.html</code> as a real <code>&lt;a href&gt;</code> hyperlink (not bare <code>&lt;code&gt;</code> text), plus a one-line description. The index must stay navigable.</li>
</ol>

<h2>What to avoid</h2>

<ul>
  <li>Updating the spec text to match what shipped (the spec is the <em>intent</em>; the build log is <em>what landed</em>).</li>
  <li>Removing the <code>data-status</code> attribute.</li>
  <li>Removing or rewriting past build log entries.</li>
  <li>Splitting one feature across multiple GDD section files (the granularity of <code>docs/GDD_COVERAGE.json</code> rows is the right unit).</li>
</ul>

<h2>Why this matters</h2>

<p>Build logs are how the next slice starts cheap. A new slice working in a touched area reads the most recent build log entries to understand what files own the behavior, what defaults were chosen, and what assumptions are still live. Without build logs, every slice pays the rediscovery tax. With them, the spiral compounds.</p>
