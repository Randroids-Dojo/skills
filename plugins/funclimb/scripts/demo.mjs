#!/usr/bin/env node
// Synthetic end-to-end run of the coordinator. Usage: node demo.mjs <output-dir>
import * as fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { syntheticFixture } from './synthetic.mjs';
import { preflight, propose, submit, review, decide, advance } from './core.mjs';

const target = process.argv[2];
if (!target) {
  console.error('Usage: node demo.mjs <output-dir>');
  process.exit(1);
}
const base = path.resolve(target);
fs.mkdirSync(base, { recursive: true });
const run = fs.mkdtempSync(path.join(base, 'run-'));
const source = path.join(run, 'source'), campaign = path.join(run, 'campaign');
const f = syntheticFixture(source);
f.config.acceptance.providers = ['synthetic-provider-a', 'synthetic-provider-b'];
f.config.minModelProviders = 2;
const write = (file, data) => { const out = path.join(source, file); fs.writeFileSync(out, JSON.stringify(data, null, 2) + '\n'); return out; };
const configFile = write('config.json', f.config), baselineFile = write('baseline-report.json', f.baselineReport);
write('proposal.json', f.proposal); write('report.json', f.report);
const cliPath = fileURLToPath(new URL('./funclimb.mjs', import.meta.url));
const cli = (...args) => {
  const result = spawnSync(process.execPath, [cliPath, ...args], { encoding: 'utf8' });
  process.stdout.write(result.stdout); process.stdout.write(result.stderr);
  return result.status;
};
const expect = (ok, message) => { if (!ok) { console.error(`Demo failed: ${message}`); process.exit(1); } };

console.log('SYNTHETIC ONLY. No model called, no game played, no money spent.');
const unscoped = structuredClone(f.config); delete unscoped.scenarios[1].checks;
console.log('If variation had to verify recovery, preflight would stop the freeze:', preflight(unscoped, f.baselineReport, source).problems);
console.log('Init without a preflight report:');
expect(cli('init', campaign, configFile) !== 0 && !fs.existsSync(campaign), 'init froze a campaign without a preflight');
console.log('Preflight on the baseline capture:');
expect(cli('preflight', configFile, baselineFile) === 0, 'preflight did not pass');
expect(cli('init', campaign, configFile, '--preflight', baselineFile) === 0, 'init with a passing preflight failed');
propose(campaign, f.proposal);
const receipt = submit(campaign, f.proposal.id, f.report, source);
review(campaign, f.proposal.id, f.model(receipt.evidenceDigest));
console.log('After one provider reviews:', decide(campaign, f.proposal.id).status);
review(campaign, f.proposal.id, f.model(receipt.evidenceDigest, 'synthetic-provider-b'));
console.log('After both providers approve:', decide(campaign, f.proposal.id).status);
console.log(advance(campaign, f.proposal.id));
console.log('No human receipt needed. The synthetic champion advanced automatically.');
console.log('Receipts:', campaign);
