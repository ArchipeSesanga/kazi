// Prints the deployed Cloud Function names exported by functions/src/index.ts,
// one per line (honouring `export { a as b }`). Used by the deploy workflow to
// deploy functions one at a time (africa-south1 / Eventarc needs that).
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

export function functionNames(source) {
  const names = [];
  for (const m of source.matchAll(/export\s*\{([^}]*)\}/g)) {
    for (const part of m[1].split(',')) {
      const p = part.trim();
      if (!p) continue;
      const [orig, alias] = p.split(/\s+as\s+/);
      names.push((alias ?? orig).trim());
    }
  }
  return names;
}

const here = dirname(fileURLToPath(import.meta.url));
if (process.argv[1] && resolve(process.argv[1]) === resolve(fileURLToPath(import.meta.url))) {
  const src = readFileSync(resolve(here, '../functions/src/index.ts'), 'utf8');
  console.log(functionNames(src).join('\n'));
}
