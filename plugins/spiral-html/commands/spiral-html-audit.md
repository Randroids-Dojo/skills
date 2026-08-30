---
description: Audit a repository against the HTML-first Spiral scaffold.
argument-hint: "[repository path]"
disable-model-invocation: true
---

<h1>/spiral-html audit</h1>

<p>Diff the current repo against the canonical HTML-first spiral scaffold and print a remediation checklist.</p>

<h2>When to use</h2>

<p>On any existing repo to check whether it is a fit substrate for an autonomous PR loop. Runs nine checks and reports drift. Does not modify anything.</p>

<p>Run this:</p>

<ul>
  <li>After <code>randroid:loop</code> completes a long run, to surface stale ledgers.</li>
  <li>Before assuming a project is "done." Catches the Flatline failure mode (chapter-granular coverage + missing qualitative gate = early termination).</li>
  <li>When inheriting a project that was set up without <code>spiral-html init</code>, to see how much retrofit is needed.</li>
</ul>

<h2>How to invoke</h2>

<pre><code>bash ${CLAUDE_PLUGIN_ROOT}/scripts/audit.sh [path-to-repo]</code></pre>

<p>Default path is the current directory.</p>

<h2>What it checks</h2>

<ol>
  <li>Missing canonical files (including <code>docs/DEPENDENCY_LEDGER.html</code>).</li>
  <li>Monolith <code>docs/GDD.html</code> instead of a <code>docs/gdd/</code> tree.</li>
  <li>Chapter-granular coverage rows (heuristic: fewer than 14 rows per project-week).</li>
  <li>Missing qualitative gate (<code>docs/PLAYTEST.html</code> or <code>docs/FUN_FACTOR_AUDIT.html</code>).</li>
  <li>Stale progress log (newest <code>&lt;article data-date="..."&gt;</code> older than 7 days).</li>
  <li>Open questions without a <code>&lt;dt&gt;Recommended default&lt;/dt&gt;</code> entry.</li>
  <li>Followups without a <code>data-priority</code> attribute.</li>
  <li>Em-dash drift in the canonical files.</li>
  <li><code>docs/DEPENDENCY_LEDGER.html</code> missing the <code>&lt;section id="watch-list"&gt;</code> region (the Dependency Upgrade Gate has nothing to fire against without it).</li>
</ol>

<h2>Output</h2>

<p>A checklist with one line per finding, ordered from most-blocking to least-blocking. No remediation file is written. Fix in place, re-run.</p>
