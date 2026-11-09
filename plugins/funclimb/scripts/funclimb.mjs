#!/usr/bin/env node
import path from 'node:path';
import { preflight, initialize, load, readJson, propose, submit, review, decide, assess, close, advance, accounting, acceptancePolicy } from './core.mjs';

const usage = `FunClimb evidence coordinator

node <skill>/scripts/funclimb.mjs preflight <config.json> <baseline-report.json>
node <skill>/scripts/funclimb.mjs init <empty-campaign-dir> <config.json> --preflight <baseline-report.json>
node <skill>/scripts/funclimb.mjs init <empty-campaign-dir> <config.json> --skip-preflight "reason"
node <skill>/scripts/funclimb.mjs propose <campaign-dir> <proposal.json>
node <skill>/scripts/funclimb.mjs submit <campaign-dir> <experiment-id> <report.json>
node <skill>/scripts/funclimb.mjs review <campaign-dir> <experiment-id> <review.json>
node <skill>/scripts/funclimb.mjs decide <campaign-dir> <experiment-id>
node <skill>/scripts/funclimb.mjs advance <campaign-dir> <experiment-id>
node <skill>/scripts/funclimb.mjs accept <campaign-dir> <experiment-id> "reason"
node <skill>/scripts/funclimb.mjs reject <campaign-dir> <experiment-id> "reason"
node <skill>/scripts/funclimb.mjs status <campaign-dir>

Preflight checks a baseline-only capture of every scenario; init reruns it and freezes only on a pass.
Artifacts are copied relative to report.json. Reviews cite the returned evidenceDigest.
Human reviews are operator attestations, not authenticated identities.
No model calls, game changes, merges, or spending are executed by this CLI.`;

const baselineCapture = file => ({ report: readJson(file), reportDir: path.dirname(path.resolve(file)) });

function printPreflight(config, check) {
  const lines = [];
  if (check.ok) {
    const metrics = config.metrics.map(m => m.id).join(', ') || 'none';
    lines.push(`FunClimb preflight passed: ${check.scenarios.length} scenarios on baseline ${config.baselineRevision}; metrics ${metrics}.`);
    for (const s of check.scenarios) lines.push(`- ${s.id} (${s.group}): ${s.seeds} seed${s.seeds === 1 ? '' : 's'}; checks ${s.checks.join(', ')}`);
  } else {
    lines.push(`FunClimb preflight found ${check.problems.length} problem${check.problems.length === 1 ? '' : 's'}:`);
    for (const problem of check.problems) lines.push(`- ${problem}`);
  }
  if (check.warnings.length) lines.push('Warnings:', ...check.warnings.map(w => `- ${w}`));
  lines.push(check.ok
    ? 'Freeze it with: init <new-campaign-dir> <config.json> --preflight <baseline-report.json>'
    : 'Nothing is frozen. Fix the config or harness and rerun preflight. When a scenario cannot exercise a check, give that scenario its own checks list.');
  console.log(lines.join('\n'));
}

try {
  const args = process.argv.slice(2);
  const [command, root, arg, extra, value] = args;
  if (!command || command === '--help' || command === 'help') { console.log(usage); process.exit(0); }
  const lengths = { preflight: [3], init: [3, 5], propose: [3], submit: [4], review: [4], decide: [3], advance: [3], accept: [4], reject: [4], status: [2] };
  if (!lengths[command]?.includes(args.length)) throw new Error(usage);
  let result;
  switch (command) {
    case 'preflight': {
      const config = readJson(root), capture = baselineCapture(arg);
      const check = preflight(config, capture.report, capture.reportDir);
      printPreflight(config, check);
      process.exitCode = check.ok ? 0 : 1;
      break;
    }
    case 'init': {
      let options = {};
      if (extra === '--preflight') options = { preflight: baselineCapture(value) };
      else if (extra === '--skip-preflight') options = { skipPreflight: value };
      else if (extra !== undefined) throw new Error(usage);
      const state = initialize(root, readJson(arg), options);
      result = { initialized: path.resolve(root), preflight: state.events[0] };
      break;
    }
    case 'propose': result = propose(root, readJson(arg)); break;
    case 'submit': result = submit(root, arg, readJson(extra), path.dirname(path.resolve(extra))); break;
    case 'review': result = review(root, arg, readJson(extra)); break;
    case 'decide': result = decide(root, arg); break;
    case 'advance': result = advance(root, arg); break;
    case 'accept': result = close(root, arg, 'accepted', extra); break;
    case 'reject': result = close(root, arg, 'rejected', extra); break;
    case 'status': {
      const state = load(root);
      const preflightEvent = state.events.find(e => e.type === 'preflight' || e.type === 'preflight-skipped') ?? null;
      result = { name: state.config.name, mode: state.config.mode, acceptance: acceptancePolicy(state.config), execution: state.config.execution ?? null, preflight: preflightEvent, acceptedRevision: state.acceptedRevision, budget: state.config.budget, usedAndReserved: accounting(state), experiments: state.experiments.map(e => ({ id: e.id, ...assess(state, e.id) })) };
      break;
    }
  }
  if (result !== undefined) console.log(JSON.stringify(result, null, 2));
} catch (error) {
  console.error(`FunClimb: ${error.message}`);
  process.exitCode = 1;
}
