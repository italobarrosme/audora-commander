#!/usr/bin/env bash
# hook SessionStart cita memory e as fases; JSON válido.
source "$(dirname "$0")/lib.sh"
o="$(bash "$ROOT/hooks/session-start")"
assert_contains "$o" '"hookEventName": "SessionStart"' "session-start JSON"
assert_contains "$o" 'memory, scope, plan, execute, e2e, validate' "session-start fases"
assert_contains "$o" 'MEMORY.md' "session-start cita MEMORY.md"
printf '%s' "$o" | perl -MJSON::PP -0777 -e 'decode_json(join "", <STDIN>)' 2>/dev/null && ok || ko "session-start JSON inválido"
h="$(cat "$ROOT/hooks/hooks.json")"
assert_contains "$h" 'memory-guard' "hooks.json memory-guard"; assert_contains "$h" 'memory-validate' "hooks.json memory-validate"
assert_not_contains "$o" 'Graphify' "remover-graphify/10 session-start sem Graphify"
assert_empty "$(cd "$ROOT" && grep -li graphify hooks/*)" "corte-sem-uso/5 hooks sem Graphify"
assert_not_contains "$o" 'worktree' "corte-sem-uso/9 session-start sem worktree"
report
