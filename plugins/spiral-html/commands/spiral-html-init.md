---
description: Initialize the HTML-first Spiral scaffold in a new repository.
argument-hint: "[project name, pitch, and stack]"
disable-model-invocation: true
---

<h1>/spiral-html init</h1>

<p>Bootstrap the HTML-first structural-discipline scaffold into the current repo.</p>

<h2>When to use</h2>

<p>At the start of a fresh project, before any feature code. Writes the canonical files (<code>AGENTS.md</code> as the Markdown contract, <code>CLAUDE.md</code> as a one-line <code>@AGENTS.md</code> import, plus the <code>docs/</code> HTML ledger set, including <code>docs/DEPENDENCY_LEDGER.html</code> and the qualitative-gate docs) so an autonomous PR loop can run against the repo. <code>AGENTS.md</code> and <code>CLAUDE.md</code> stay Markdown because Codex's root-down walk and Claude Code's project-memory import only resolve those filenames.</p>

<p>Refuses to run if <code>AGENTS.md</code> already exists. Use <code>/spiral-html audit</code> on existing repos instead.</p>

<h2>How to invoke</h2>

<p>Ask the user three questions via <code>AskUserQuestion</code> before running:</p>

<ol>
  <li><strong>Project name.</strong> Used in headers and substituted as <code>{{PROJECT_NAME}}</code>.</li>
  <li><strong>One-line pitch.</strong> Substituted as <code>{{PITCH}}</code>. Used in <code>AGENTS.md</code> and the GDD index.</li>
  <li><strong>Stack.</strong> Substituted as <code>{{STACK}}</code>. Used in <code>AGENTS.md</code> Rule 3. Free text. Examples: "Next.js + Three.js + Vercel KV", "Godot 4.x + GDScript", "Rust + axum + Postgres".</li>
</ol>

<p>Then run:</p>

<pre><code>bash ${CLAUDE_PLUGIN_ROOT}/scripts/init.sh "&lt;name&gt;" "&lt;pitch&gt;" "&lt;stack&gt;"</code></pre>

<p>After the script completes:</p>

<ol>
  <li>Print the list of written files.</li>
  <li>Tell the user the next step is to draft the first GDD section under <code>docs/gdd/&lt;n&gt;-&lt;title&gt;.html</code>.</li>
  <li>Suggest <code>/randroid:loop implement</code> once the first GDD section exists.</li>
</ol>

<h2>Output</h2>

<p>The script prints every written file path, plus a one-line note for the user about next steps.</p>
