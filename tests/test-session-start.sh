#!/usr/bin/env bash
# hook SessionStart cita memory e não graph; JSON válido.
source "$(dirname "$0")/lib.sh"
o="$(bash "$ROOT/hooks/session-start")"
assert_contains "$o" '"hookEventName": "SessionStart"' "session-start JSON"
assert_contains "$o" 'memory, scope, plan, execute, e2e, validate' "session-start fases"
assert_contains "$o" 'MEMORY.md' "session-start cita MEMORY.md"
assert_not_contains "$o" 'graph,' "session-start sem graph"
assert_not_contains "$o" 'GRAFO' "session-start sem GRAFO"
printf '%s' "$o" | perl -MJSON::PP -0777 -e 'decode_json(join "", <STDIN>)' 2>/dev/null && ok || ko "session-start JSON inválido"
h="$(cat "$ROOT/hooks/hooks.json")"
assert_contains "$h" 'memory-guard' "hooks.json memory-guard"; assert_contains "$h" 'memory-validate' "hooks.json memory-validate"; assert_not_contains "$h" 'grafo' "hooks.json sem grafo"
report
