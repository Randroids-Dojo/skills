import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

// Keep this launcher compatible with the Mac's system Node22. The CLI still requires Node24.
try {
  const self = fs.realpathSync(fileURLToPath(import.meta.url));
  const roots = [];
  for (const start of [process.cwd(), path.dirname(self)]) {
    for (let directory = start; ; directory = path.dirname(directory)) {
      roots.push(directory, path.join(directory, 'FunClimb'));
      if (path.dirname(directory) === directory) break;
    }
  }
  roots.push(path.join(os.homedir(), 'Documents/Dev/FunClimb'), path.join(os.homedir(), 'Dev/FunClimb'));
  const candidates = process.env.FUNCLIMB_ROOT ? [path.resolve(process.env.FUNCLIMB_ROOT)] : [...new Set(roots)];
  const found = candidates.find(candidate => {
    try {
      return JSON.parse(fs.readFileSync(path.join(candidate, 'package.json'), 'utf8')).name === 'funclimb' &&
        fs.statSync(path.join(candidate, 'bin/funclimb.mjs')).isFile();
    } catch { return false; }
  });
  if (!found) throw new Error('FunClimb coordinator checkout not found. Set FUNCLIMB_ROOT to an existing checkout; the skill does not download one.');
  const root = fs.realpathSync(found);
  const cli = path.join(root, 'bin/funclimb.mjs');
  const pinned = fs.readFileSync(path.join(root, '.node-version'), 'utf8').trim();
  const localNode = path.join(root, '.tools', `node-v${pinned}-${process.platform}-${process.arch}`, process.platform === 'win32' ? 'node.exe' : 'bin/node');
  const runtimes = process.env.FUNCLIMB_NODE ? [process.env.FUNCLIMB_NODE] : [localNode, process.execPath];
  let runtime;
  for (const candidate of [...new Set(runtimes)]) {
    const probe = spawnSync(candidate, ['--version'], { encoding: 'utf8' });
    const version = probe.stdout?.trim();
    if (probe.status === 0 && /^v(\d+)\./.test(version) && Number(version.match(/^v(\d+)/)[1]) >= 24) {
      runtime = { node: candidate, version };
      break;
    }
  }
  if (!runtime) throw new Error('No working existing Node24 runtime. Set FUNCLIMB_NODE to one; no runtime was installed or global version changed.');
  const args = process.argv.slice(2);
  if (args.length === 1 && args[0] === '--info') {
    console.log(JSON.stringify({ root, ...runtime, cli, template: path.join(root, 'examples/campaign.template.json'), cwd: process.cwd() }, null, 2));
  } else {
    const result = spawnSync(runtime.node, [cli, ...args], { stdio: 'inherit', cwd: process.cwd() });
    if (result.error) throw result.error;
    if (result.signal) throw new Error('Coordinator stopped by signal ' + result.signal);
    process.exitCode = result.status ?? 1;
  }
} catch (error) {
  console.error('FunClimb launcher: ' + error.message);
  process.exitCode = 1;
}
