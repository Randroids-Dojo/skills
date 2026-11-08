import * as fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';

// This fixture exercises the coordinator. Nothing here is observed gameplay.
export function syntheticFixture(directory) {
  fs.mkdirSync(directory, { recursive: true });
  const config = {
    schemaVersion: 2, name: 'Synthetic council demonstration', mode: 'synthetic', baselineRevision: 'demo-base',
    pillars: ['Readable consequences', 'Agency through meaningful timing'],
    coreLoop: { input: 'Press action', action: 'Commit a timed move', consequence: 'State records the move', resistance: 'A timing window', feedback: 'A readable response', nextDecision: 'Retry or change timing' },
    scenarios: [{ id: 'core', group: 'development', procedure: 'Synthetic ordinary action and recovery.' }, { id: 'variation', group: 'validation', procedure: 'Synthetic changed timing situation.' }],
    checks: ['core-action', 'feedback', 'recovery'],
    metrics: [{ id: 'frame-p95', unit: 'ms', better: 'lower', maxRegression: 1 }],
    minTrials: 3, minModelProviders: 3,
    acceptance: { mode: 'council', providers: ['synthetic-provider-a', 'synthetic-provider-b', 'synthetic-provider-c'], votesRequired: 2 },
    budget: { maxCostUsd: 0, maxMinutes: 60, maxExperiments: 5, stopAfterNoGain: 3 }
  };
  const proposal = { id: 'clearer-action', baselineRevision: 'demo-base', candidateRevision: 'demo-candidate', hypothesis: 'Clearer action feedback may make timing easier to understand.', change: 'Adjust one feedback cue.', expectedObservation: 'Players can explain and intentionally repeat the action.', risk: 'The cue might obscure timing.', estimatedCostUsd: 0, estimatedMinutes: 10 };
  const report = { schemaVersion: 1, mode: 'synthetic', baselineRevision: 'demo-base', candidateRevision: 'demo-candidate', environment: { platform: 'SYNTHETIC', device: 'No device tested', input: 'No input performed', settings: 'Fixture only' }, costUsd: 0, minutes: 5, trials: [], artifacts: [], notes: 'All observations, values and feedback are fictional fixtures.' };
  for (const scenario of config.scenarios) {
    for (const variant of ['baseline', 'candidate']) {
      const file = `${scenario.id}-${variant}.txt`;
      fs.writeFileSync(path.join(directory, file), `SYNTHETIC ONLY: ${scenario.id}/${variant}. No gameplay was captured.\n`);
      report.artifacts.push({ scenarioId: scenario.id, variant, revision: report[variant + 'Revision'], kind: 'trace', path: file });
      for (let i = 1; i <= 3; i++) report.trials.push({ scenarioId: scenario.id, variant, seed: String(i), checks: { 'core-action': 'pass', feedback: 'pass', recovery: 'pass' }, metrics: { 'frame-p95': variant === 'baseline' ? 16 : 15 } });
    }
  }
  const model = (evidenceDigest, provider = 'synthetic-provider-a') => ({ mode: 'synthetic', kind: 'model', reviewer: provider + '-fixture', provider, evidenceDigest, preference: 'candidate', confidence: 'high', blockingFindings: [], evidenceRefs: report.artifacts.slice(0, 2).map(a => ({ sha256: createHash('sha256').update(fs.readFileSync(path.join(directory, a.path))).digest('hex'), observation: `SYNTHETIC ${a.variant} trace only; no gameplay observed.` })), observations: 'SYNTHETIC: council review fixture, no model called.' });
  const human = evidenceDigest => ({ mode: 'synthetic', kind: 'human', reviewer: 'synthetic-human-fixture', playedBoth: true, evidenceDigest, preference: 'candidate', observations: 'SYNTHETIC: no person played a game; this only exercises the gate.' });
  return { config, proposal, report, model, human };
}
