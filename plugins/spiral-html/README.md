<h1>spiral-html</h1>

<p>Bootstrap and audit the structural-discipline scaffold that lets autonomous PR loops run for weeks without losing context, terminating prematurely, or accumulating debt. HTML-first variant of <code>spiral</code>: every ledger, rule, and contract is authored in HTML rather than Markdown.</p>

<h2>What this is</h2>

<p>A skill for Claude Code and Codex agents. It writes (or audits) the canonical scaffold that turns a fresh repo into a substrate suitable for <code>randroid-loop</code> to drive. The structure mirrors <code>spiral</code> exactly; only the document format differs.</p>

<h2>What it solves</h2>

<p>Three sibling skills (<code>randroid-loop</code>, <code>task-tracking-dots</code>, and this one) form the autonomous-loop trio:</p>

<ul>
  <li><code>task-tracking-dots</code>: work items (the queue).</li>
  <li><code>randroid-loop</code>: execution (the worker).</li>
  <li><code>spiral-html</code>: substrate (the contract, vision, ledgers, and gates the worker consumes and updates).</li>
</ul>

<p>Without a spiral substrate, <code>randroid-loop</code> runs against muscle memory: there is no copy-pasteable contract, no anti-Flatline guardrails (chapter-granular coverage, missing qualitative gate), and no audit pass for an existing repo.</p>

<h2>Why HTML</h2>

<p>HTML is the new way to communicate to agents. Where Markdown leans on heading depth and indentation, HTML carries explicit semantics in <code>data-*</code> attributes and structural elements. An agent reading <code>&lt;section data-q="Q-007" data-status="open"&gt;</code> can locate, cite, and update without prose parsing. The audit script in this skill exploits that: it greps for HTML attributes rather than heading prefixes.</p>

<h2>Quick start</h2>

<p>In a fresh git repo:</p>

<pre><code>/spiral-html init</code></pre>

<p>Or from the shell:</p>

<pre><code>bash ${CLAUDE_PLUGIN_ROOT}/scripts/init.sh "MyProject" "one-line pitch" "Next.js + Three.js"</code></pre>

<p>This writes <code>AGENTS.md</code> (the full Markdown contract that Codex's root-down walk picks up), <code>CLAUDE.md</code> (a one-line <code>@AGENTS.md</code> import for Claude Code's project memory), and the <code>docs/</code> HTML ledger set. Add your first GDD section under <code>docs/gdd/</code>, then start the loop with <code>/randroid-loop implement</code>.</p>

<p>In an existing repo:</p>

<pre><code>/spiral-html audit</code></pre>

<p>Prints a remediation checklist for any drift from the canonical structure.</p>

<h2>See also</h2>

<ul>
  <li><code>docs/methodology.html</code>: the meta-pattern essay.</li>
  <li><code>docs/case-studies.html</code>: VibeRacer, VibeGear2, Flatline distilled.</li>
  <li><code>SKILL.md</code>: the agent-facing primary doc.</li>
  <li><code>../spiral/</code>: the Markdown-first sibling skill (same methodology, different medium).</li>
</ul>
