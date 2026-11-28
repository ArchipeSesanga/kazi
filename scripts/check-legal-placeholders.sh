#!/usr/bin/env bash
# Fails when a public legal page still contains an unfilled {{PLACEHOLDER}}.
# Run before any production Hosting deploy (see docs/11-PROD-RUNBOOK.md).
set -euo pipefail
cd "$(dirname "$0")/.."
if grep -rn "{{[A-Z_]*}}" web/public; then
  echo "ERROR: fill the {{...}} placeholders in web/public before publishing." >&2
  exit 1
fi
echo "Legal pages: no placeholders left."
