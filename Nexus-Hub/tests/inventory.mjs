import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const root = path.dirname(fileURLToPath(import.meta.url));
let fixture = fs.readFileSync(path.join(root, 'inventory.fixture.luau'), 'utf8');
for (const name of ['Assets', 'Inventory']) {
  const source = fs.readFileSync(path.join(root, '..', 'src', `${name}.luau`), 'utf8');
  fixture = fixture.replace(`-- INSERT_${name.toUpperCase()}_MODULE`, `local ${name} = (function()\n${source}\nend)()`);
}
const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'nexus-inventory-'));
try {
  const target = path.join(directory, 'check.luau');
  fs.writeFileSync(target, fixture);
  const result = spawnSync(process.argv[2] || 'luau', [target], { stdio: 'inherit' });
  if (result.error) throw result.error;
  process.exitCode = result.status ?? 1;
} finally {
  fs.rmSync(directory, { recursive: true, force: true });
}
