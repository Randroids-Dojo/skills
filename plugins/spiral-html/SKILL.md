---
name: spiral-html
description: "HTML-first bootstrap and audit of the structural-discipline scaffold (GDD tree, coverage ledger, progress log, open questions, followups, playtest gate) that takes a vision into a delivered system through small iterations whose state lives in git, not the agent's head. Same methodology as spiral; ledgers, rules, and contracts are written in HTML rather than Markdown. Slash commands /spiral-html-init and /spiral-html-audit live under commands/."
---

<h1>Spiral (HTML edition)</h1>

<p>The methodology for sustaining a multi-week autonomous PR loop without the agent losing context, running out of work prematurely, or accumulating debt. This is the HTML-first variant of <code>spiral</code>: the scaffold is identical in shape, but every ledger, rule, and contract is authored as HTML rather than Markdown.</p>

<p>The agent does not remember the project. The project remembers itself. Every kind of state lives in git-tracked ledger files with rigid templates. The agent's job collapses to: read ledgers, pick the next slice, run the loop, update ledgers. Every iteration returns to the same artifacts and finds them advanced. The shape is not a loop, it is a spiral: forward-while-circling.</p>

<h2>Why HTML</h2>

<p>HTML is the new way to communicate to agents. Structured elements (<code>&lt;section&gt;</code>, <code>&lt;article&gt;</code>, <code>&lt;table&gt;</code>, <code>&lt;ol&gt;</code>, <code>&lt;dl&gt;</code>, <code>&lt;details&gt;</code>) carry semantics that Markdown discards. An agent reading <code>&lt;section data-role="rule" data-id="rule-1"&gt;</code> can locate, cite, and update content without parsing prose. The audit script in this skill exploits that: it grep-checks for HTML attributes rather than heading prefixes.</p>

<p>Two files must stay Markdown: <code>AGENTS.md</code> and <code>CLAUDE.md</code>. Codex's native root-down walk only picks up <code>AGENTS.md</code>, and Claude Code's project-memory import only resolves <code>CLAUDE.md</code>. The contract therefore lives in <code>AGENTS.md</code> as Markdown; <code>CLAUDE.md</code> is a one-liner (<code>@AGENTS.md</code>) so Claude Code imports the same rules. Everything else under <code>docs/</code> is HTML.</p>

<p>Path-scoped Rules under <code>.claude/rules/</code> retain YAML frontmatter (Claude Code requires it for path globbing); only the body becomes HTML.</p>

<h2>When to invoke</h2>

<ul>
  <li><code>/spiral-html init</code>: at the start of a fresh project. Writes the canonical HTML scaffold (rules, plan, agreement, GDD tree, coverage ledger, progress log, open questions, followups, playtest, fun-factor audit) into the current repo.</li>
  <li><code>/spiral-html audit</code>: on an existing project. Diffs the repo against the canonical HTML structure and prints a remediation checklist. Catches the three known failure modes (monolith GDD, chapter-granular coverage, missing qualitative gate) plus generic drift.</li>
</ul>

<p>Per-slice execution (read context, branch, implement, PR, merge, repeat) is the job of <code>randroid-loop</code>. Per-task tracking is the job of <code>task-tracking-dots-html</code> (the HTML-backed <code>dot-html</code> fork, NOT the Markdown <code>task-tracking-dots</code>). This skill is the substrate those two run against.</p>

<h2>Why this exists: the three case studies</h2>

<p>Three multi-week autonomous-loop projects produced three outcomes. The pattern is in <code>docs/case-studies.html</code>. The short version:</p>

<ul>
  <li><strong>VibeRacer (14 days, 184 commits)</strong>: shipped a complete v1. Single-file 28-section GDD with explicit out-of-scope §18 fence. The loop terminated cleanly.</li>
  <li><strong>VibeGear2 (7 days, 298 commits)</strong>: still actively shipping P0/P1 fun work a week in. Sectioned <code>docs/gdd/</code> tree, 102 atomic coverage rows, plus <code>FUN_FACTOR_GAP_AUDIT</code> and <code>RELEASE_FUN_PLAYTEST</code> as a second qualitative gate that re-opens the loop after systems land.</li>
  <li><strong>Flatline (3 days, 94 commits)</strong>: self-terminated with 0 open dots, 0 open questions, 1 deferred doc cleanup. The product was not fun. Coverage rows were chapter-granular (11 rows, all <code>implemented</code> once <em>any</em> code shipped). No qualitative gate.</li>
</ul>

<p>Flatline is the failure case this skill explicitly prevents. The audit script flags both the chapter-granular coverage anti-pattern and the missing qualitative gate.</p>

<h2>The scaffold</h2>

<p><code>/spiral-html init</code> writes these files into the target repo:</p>

<table>
  <thead>
    <tr><th>Path</th><th>Role</th></tr>
  </thead>
  <tbody>
    <tr><td><code>AGENTS.md</code></td><td>Rules-as-contract in Markdown (stays Markdown so Codex's root-down walk works): em-dash ban, pre-slice reading list, stack constraints, commit style, autonomous PR loop reference, secrets policy, testing expectations, pre-commit checklist. The pre-slice reading list points at the <code>.html</code> ledgers.</td></tr>
    <tr><td><code>CLAUDE.md</code></td><td>One line: <code>@AGENTS.md</code>. Claude Code's project-memory import only resolves <code>CLAUDE.md</code>, so the file exists to forward the same rules.</td></tr>
    <tr><td><code>docs/IMPLEMENTATION_PLAN.html</code></td><td>The 18-step loop contract. Slice selection priority. Definition of done.</td></tr>
    <tr><td><code>docs/WORKING_AGREEMENT.html</code></td><td>Process: branches, commits, PR template, bot-review settled-wait gate, verification minimums, merge-and-deploy expectations, risk gates.</td></tr>
    <tr><td><code>docs/gdd/index.html</code></td><td>GDD tree index. Each requirement is its own file. Build logs grow per-section as work ships.</td></tr>
    <tr><td><code>docs/GDD_COVERAGE.json</code></td><td>Atomic-row spec to code traceability. One row per requirement, not per chapter. Stays JSON (data, not prose).</td></tr>
    <tr><td><code>docs/PROGRESS_LOG.html</code></td><td>Append-only slice receipts as <code>&lt;article data-slice="..."&gt;</code> elements (Branch / Changed / Verification / Assumptions / GDD coverage / Followups). Newest on top.</td></tr>
    <tr><td><code>docs/OPEN_QUESTIONS.html</code></td><td><code>&lt;section data-q="Q-NNN"&gt;</code> entries with options, recommended default, status, resolution. Defaults let the loop ship without blocking.</td></tr>
    <tr><td><code>docs/FOLLOWUPS.html</code></td><td><code>&lt;section data-f="F-NNN"&gt;</code> entries with priority (<code>blocks-release</code>, <code>nice-to-have</code>, <code>polish</code>), blocker condition, unblock condition.</td></tr>
    <tr><td><code>docs/DEPENDENCY_LEDGER.html</code></td><td>Watched dependencies with currently-pinned version + per-dep upgrade procedure. The Dependency Upgrade Gate fires every loop iteration that touches <code>main</code>.</td></tr>
    <tr><td><code>docs/PLAYTEST.html</code></td><td>Qualitative second-gate checklist. The loop is not done until this resolves.</td></tr>
    <tr><td><code>docs/FUN_FACTOR_AUDIT.html</code></td><td>Qualitative gap-finder. Run when coverage is ≥80% done. Source of P0/P1 polish work.</td></tr>
    <tr><td><code>.claude/rules/slice-discipline.md</code></td><td>Path-scoped Rule. YAML frontmatter for path globbing; HTML body. Loads when editing source. Enforces "no drive-by refactors, no speculative abstractions, refactor-in-slice".</td></tr>
    <tr><td><code>.claude/rules/ledger-append-only.md</code></td><td>Path-scoped Rule. YAML frontmatter for path globbing; HTML body. Loads when editing the four ledger files. Enforces append-only, never-rewrite-past-entries.</td></tr>
    <tr><td><code>.claude/rules/gdd-build-log.md</code></td><td>Path-scoped Rule. YAML frontmatter for path globbing; HTML body. Loads when editing GDD section files. Enforces build-log-on-every-shipped-feature.</td></tr>
  </tbody>
</table>

<h2>Cross-tool compatibility</h2>

<p>The HTML-first scaffold cannot rely on every discovery contract the Markdown version uses. Two files stay Markdown so the canonical discovery paths keep working:</p>

<ul>
  <li><code>AGENTS.md</code> (the Codex-required filename) carries the full contract as Markdown. Codex's root-down walk finds and reads it directly. The reading list inside points at the <code>.html</code> ledgers.</li>
  <li><code>CLAUDE.md</code> (the Claude Code project-memory filename) contains one line: <code>@AGENTS.md</code>. Claude Code's import mechanism resolves the pointer and loads the same contract.</li>
  <li><code>.claude/rules/*.md</code> keep YAML frontmatter and the <code>.md</code> filename because Claude Code's path-scoped Rules system parses the frontmatter to decide when to load. The body inside each rule is HTML.</li>
  <li>The Codex per-directory <code>AGENTS.md</code> symlinks point at the rules files (still <code>.md</code>); Codex reads the YAML frontmatter and HTML body uniformly.</li>
</ul>

<h2>The seven parts of the spiral</h2>

<ol>
  <li><strong>Vision</strong>: the canonical spec (GDD tree, atomic requirements) as HTML section files.</li>
  <li><strong>Contract</strong>: the three docs that govern every iteration (rules in <code>AGENTS.md</code>, plan, agreement).</li>
  <li><strong>Slice</strong>: the bounded unit of work (one PR, one log entry, small enough that a botched slice is reverted in one click).</li>
  <li><strong>Ledgers</strong>: externalized memory (progress log, open questions, followups, coverage) as append-only HTML elements with <code>data-*</code> ids.</li>
  <li><strong>Gates</strong>: what blocks merge AND what triggers a slice. Mechanical (CI green, type-check, tests, no em-dash, bot-review settled). Qualitative (playtest, fun-factor audit). Dependency Upgrade Gate (see <code>docs/DEPENDENCY_LEDGER.html</code>): a watched-dep release is the same kind of fresh state as a new commit on <code>main</code>; the agent observes and acts at every loop boundary that touches <code>main</code>. The qualitative gate is the second gate that prevents Flatline-style early termination.</li>
  <li><strong>Selection rule</strong>: what to work on next: red CI &gt; pending dep upgrade &gt; P0/P1 dot &gt; answered open question &gt; high-priority followup &gt; coverage gap &gt; partial GDD section &gt; cleanup.</li>
  <li><strong>Loop</strong>: the continuous operation. Read context, pick slice, branch, implement, test, update ledgers, PR, handle review, wait for bot + CI, merge, pull main, smoke prod, close item, start next. Never voluntarily idles. Executed by <code>randroid-loop</code>.</li>
</ol>

<h2>How <code>init</code> works</h2>

<p>Invocation: <code>/spiral-html init</code> from inside a target git repo, or <code>bash ${CLAUDE_PLUGIN_ROOT}/scripts/init.sh "&lt;ProjectName&gt;" "&lt;one-line-pitch&gt;" "&lt;stack&gt;"</code>.</p>

<p>The script:</p>

<ol>
  <li>Refuses to run if <code>AGENTS.md</code> already exists at the repo root. Use <code>audit</code> instead.</li>
  <li>Prompts for project name, one-line pitch, and stack if not passed as args.</li>
  <li>Copies every template file into the target repo, substituting <code>{{PROJECT_NAME}}</code>, <code>{{PITCH}}</code>, <code>{{STACK}}</code>, <code>{{TODAY}}</code>.</li>
  <li>Creates <code>docs/gdd/</code> for the GDD tree and <code>.claude/rules/</code> for the path-scoped Rules.</li>
  <li>Writes <code>AGENTS.md</code> (the full Markdown contract) and <code>CLAUDE.md</code> (one-line <code>@AGENTS.md</code> import).</li>
  <li>Verifies em-dash cleanliness on every written file.</li>
  <li>Prints a next-steps note: draft the first GDD section under <code>docs/gdd/</code>, then run <code>/randroid-loop implement</code> to start the spiral.</li>
</ol>

<h2>How <code>audit</code> works</h2>

<p>Invocation: <code>/spiral-html audit</code> from inside any git repo, or <code>bash ${CLAUDE_PLUGIN_ROOT}/scripts/audit.sh</code>.</p>

<p>The script runs nine checks and prints a remediation checklist:</p>

<ol>
  <li><strong>Missing canonical files.</strong> Verifies the scaffold is present: the Markdown contract pair (<code>AGENTS.md</code>, <code>CLAUDE.md</code>), the docs HTML ledger set including <code>DEPENDENCY_LEDGER.html</code>, and the three <code>.claude/rules</code> files.</li>
  <li><strong>Monolith GDD.</strong> Warns if <code>docs/GDD.html</code> exists alone without a <code>docs/gdd/</code> directory.</li>
  <li><strong>Chapter-granular coverage.</strong> Counts rows in <code>docs/GDD_COVERAGE.json</code>. Warns if row count is implausibly low for project age (heuristic: fewer than 14 rows per project-week).</li>
  <li><strong>Missing qualitative gate.</strong> Warns if <code>docs/PLAYTEST.html</code> or <code>docs/FUN_FACTOR_AUDIT.html</code> is missing.</li>
  <li><strong>Stale progress log.</strong> Reads the newest <code>&lt;article data-date="YYYY-MM-DD"&gt;</code> in <code>docs/PROGRESS_LOG.html</code>. Warns if older than 7 days.</li>
  <li><strong>Open questions without defaults.</strong> Warns on any <code>&lt;section data-q="..."&gt;</code> missing a <code>&lt;dt&gt;Recommended default&lt;/dt&gt;</code> entry.</li>
  <li><strong>Followups without priority.</strong> Warns on any <code>&lt;section data-f="..."&gt;</code> missing a <code>data-priority</code> attribute.</li>
  <li><strong>Em-dash drift.</strong> Greps the canonical files for U+2014 / U+2013. Warns on hits.</li>
  <li><strong>Dependency ledger present.</strong> Warns if <code>docs/DEPENDENCY_LEDGER.html</code> is missing or empty (no <code>&lt;section id="watch-list"&gt;</code> recorded).</li>
</ol>

<p>The output is a checklist, not a generated remediation file. One canonical place per kind of state.</p>

<h2>Composition</h2>

<ul>
  <li><code>randroid-loop</code> reads the ledgers this skill writes. The loop's research and implement modes both name <code>OPEN_QUESTIONS</code> and <code>FOLLOWUPS</code> as required reads. With this skill, those references resolve to the <code>.html</code> files.</li>
  <li><code>task-tracking-dots-html</code> (the <code>dot-html</code> CLI, HTML dots under <code>.dots/</code>) is the work-item tracker, NOT the Markdown <code>task-tracking-dots</code>. <code>Q-NNN</code> entries that resolve into work become Dots. <code>F-NNN</code> entries with <code>data-priority="blocks-release"</code> become Dots.</li>
  <li>This skill is stateless. All state lives in the target repo's ledger files.</li>
</ul>

<h2>Architecture</h2>

<pre><code>spiral-html/
├── SKILL.md                    # This file (YAML frontmatter + HTML body)
├── README.md                   # Human-facing one-pager (HTML body)
├── .claude-plugin/
│   └── plugin.json             # Plugin metadata
├── commands/
│   ├── spiral-html-init.md     # /spiral-html init slash command
│   └── spiral-html-audit.md    # /spiral-html audit slash command
├── templates/
│   ├── AGENTS.md               # The contract, in Markdown (Codex root-down walk)
│   ├── CLAUDE.md               # One-line @AGENTS.md import (Claude Code project memory)
│   ├── IMPLEMENTATION_PLAN.html
│   ├── WORKING_AGREEMENT.html
│   ├── docs-gdd-index.html
│   ├── GDD_COVERAGE.json
│   ├── PROGRESS_LOG.html
│   ├── OPEN_QUESTIONS.html
│   ├── FOLLOWUPS.html
│   ├── DEPENDENCY_LEDGER.html
│   ├── PLAYTEST.html
│   ├── FUN_FACTOR_AUDIT.html
│   ├── dot-claude-rules-slice-discipline.md
│   ├── dot-claude-rules-ledger-append-only.md
│   └── dot-claude-rules-gdd-build-log.md
├── scripts/
│   ├── init.sh                 # Bootstrap into a target repo
│   └── audit.sh                # Diff target repo against canon
└── docs/
    ├── methodology.html        # The meta-pattern essay
    └── case-studies.html       # VibeRacer / VibeGear2 / Flatline
</code></pre>
