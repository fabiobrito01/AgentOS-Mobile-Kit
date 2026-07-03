#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
  "$ROOT/agentos"
  "$ROOT/instalar.sh"
  "$ROOT/lib/ui.sh"
  "$ROOT/lib/config.sh"
  "$ROOT/lib/system.sh"
  "$ROOT/lib/github.sh"
  "$ROOT/modules/termux.sh"
  "$ROOT/modules/github.sh"
  "$ROOT/modules/projects.sh"
  "$ROOT/modules/backup.sh"
  "$ROOT/modules/settings.sh"
  "$ROOT/modules/doctor.sh"
  "$ROOT/modules/help.sh"
)

for file in "${required[@]}"; do
  test -f "$file"
done

for file in "${required[@]}"; do
  bash -n "$file"
done

echo "Smoke test OK"
