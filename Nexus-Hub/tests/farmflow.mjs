import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const root = path.dirname(fileURLToPath(import.meta.url));
const fixture = fs.readFileSync(path.join(root, 'farmflow.fixture.luau'), 'utf8');
const source = fs.readFileSync(path.join(root, '..', 'src', 'Game.luau'), 'utf8');
const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'nexus-farmflow-'));
try {
  const target = path.join(directory, 'check.luau');
  fs.writeFileSync(target, fixture.replace('-- INSERT_GAME_MODULE', `local Game = (function()\n${source}\nend)()`));
  const result = spawnSync(process.argv[2] || 'luau', [target], { stdio: 'inherit' });
  if (result.error) throw result.error;
  process.exitCode = result.status ?? 1;
} finally {
  fs.rmSync(directory, { recursive: true, force: true });
}
