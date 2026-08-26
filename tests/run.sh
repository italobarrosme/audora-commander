#!/usr/bin/env bash
# Roda todos os testes do plugin. Exit 1 se qualquer um falhar.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
falhas=0
for t in tests/test-*.sh; do
  bash "$t" || falhas=$((falhas+1))
done
echo "run.sh: $falhas arquivo(s) de teste com falha"
[ "$falhas" -eq 0 ]
