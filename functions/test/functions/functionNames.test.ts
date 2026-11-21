import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { describe, expect, it } from 'vitest';

// @ts-expect-error plain ESM script outside the TypeScript project
import { functionNames } from '../../../scripts/function-names.mjs';

import { MODERATOR_CALLABLES } from '../../../shared/moderation';

describe('shared contract', () => {
  it('every callable name in shared/moderation.ts is an exported function', () => {
    const src = readFileSync(resolve(process.cwd(), 'src/index.ts'), 'utf8');
    const names: string[] = functionNames(src);
    for (const name of Object.values(MODERATOR_CALLABLES)) expect(names).toContain(name);
  });
});

describe('scripts/function-names.mjs (used by the release deploy)', () => {
  it('honours "as" aliases and lists every exported function', () => {
    const names: string[] = functionNames(
      'export { a } from "./a.js";\nexport {\n  b,\n  c as d,\n} from "./b.js";',
    );
    expect(names).toEqual(['a', 'b', 'd']);
  });

  it('finds the real functions, with no duplicates', () => {
    const src = readFileSync(resolve(process.cwd(), 'src/index.ts'), 'utf8');
    const names: string[] = functionNames(src);
    expect(names).toEqual(
      expect.arrayContaining([
        'deleteAccount', 'submitReport', 'onReportCreated', 'onListingWritten',
        'onProviderWritten', 'cleanupOrphanMedia', 'cleanupDraftListings',
        'moderator_hideListing', 'moderator_restoreListing',
        'moderator_suspendProvider', 'moderator_dismissReport',
      ]),
    );
    expect(new Set(names).size).toBe(names.length);
  });
});
