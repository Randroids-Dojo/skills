#!/usr/bin/env node
import path from 'node:path';
import { initialize, load, readJson, propose, submit, review, decide, assess, close, advance, accounting, acceptancePolicy } from './core.mjs';

const usage = `FunClimb evidence coordinator

node <skill>/scripts/funclimb.mjs init <empty-campaign-dir> <config.json>
node <skill>/scripts/funclimb.mjs propose <campaign-dir> <proposal.json>
node <skill>/scripts/funclimb.mjs submit <campaign-dir> <experiment-id> <report.json>
node <skill>/scripts/funclimb.mjs review <campaign-dir> <experiment-id> <review.json>
node <skill>/scripts/funclimb.mjs decide <campaign-dir> <experiment-id>
node <skill>/scripts/funclimb.mjs advance <campaign-dir> <experiment-id>
node <skill>/scripts/funclimb.mjs accept <campaign-dir> <experiment-id> "reason"
node <skill>/scripts/funclimb.mjs reject <campaign-dir> <experiment-id> "reason"
node <skill>/scripts/funclimb.mjs status <campaign-dir>

Artifacts are copied relative to report.json. Reviews cite the returned evidenceDigest.
Human reviews are operator attestations, not authenticated identities.
No model calls, game changes, merges, or spending are executed by this CLI.`;

try {
  const [command, root, arg, extra, ...rest] = process.argv.slice(2);
  if (!command || command === '--help' || command === 'help') { console.log(usage); process.exit(0); }
  const lengths = { init: [3], propose: [3], submit: [4], review: [4], decide: [3], advance: [3], accept: [4], reject: [4], status: [2] };
  if (!lengths[command]?.includes(process.argv.slice(2).length) || rest.length) throw new Error(usage);
  let result;
  switch (command) {
    case 'init': initialize(root, readJson(arg)); result = { initialized: path.resolve(root) }; break;
    case 'propose': result = propose(root, readJson(arg)); break;
    case 'submit': result = submit(root, arg, readJson(extra), path.dirname(path.resolve(extra))); break;
    case 'review': result = review(root, arg, readJson(extra)); break;
    case 'decide': result = decide(root, arg); break;
    case 'advance': result = advance(root, arg); break;
    case 'accept': result = close(root, arg, 'accepted', extra); break;
    case 'reject': result = close(root, arg, 'rejected', extra); break;
    case 'status': {
      const state = load(root);
      result = { name: state.config.name, mode: state.config.mode, acceptance: acceptancePolicy(state.config), execution: state.config.execution ?? null, acceptedRevision: state.acceptedRevision, budget: state.config.budget, usedAndReserved: accounting(state), experiments: state.experiments.map(e => ({ id: e.id, ...assess(state, e.id) })) };
      break;
    }
  }
  console.log(JSON.stringify(result, null, 2));
} catch (error) {
  console.error(`FunClimb: ${error.message}`);
  process.exitCode = 1;
}
