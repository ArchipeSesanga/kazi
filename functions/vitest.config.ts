import { defineConfig } from 'vitest/config';

// The emulator-backed test files share one Firestore emulator and the same
// collections, so files must not run in parallel.
export default defineConfig({ test: { fileParallelism: false } });
