#!/usr/bin/env bash
# Estrutura das 8 skills + contratos de conteúdo (memory: /2,/3,/6,/10-17; fases: /14,/18).
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
for s in audora-commander memory scope plan execute e2e validate debug; do
  f="skills/$s/SKILL.md"
  assert_file "$f" "skill $s existe"
  [ -f "$f" ] || continue
  [ "$(wc -l < "$f")" -le 250 ] && ok || ko "$s > 250 linhas"
  grep -q "^name: $s\$" "$f" && ok || ko "$s name:"
  grep -q "^description: 'Use quando" "$f" && ok || ko "$s description entre aspas simples"
  grep -q 'LEI DE FERRO' "$f" && ok || ko "$s Lei de Ferro"
  grep -q 'Anuncie ao começar' "$f" && ok || ko "$s Anuncie"
  grep -q '^## PRÓXIMA SKILL' "$f" && ok || ko "$s PRÓXIMA SKILL"
  if [ "$s" = memory ]; then
    [ "$(grep -ci 'grafo' "$f")" -le 1 ] && ok || ko "memory cita grafo além do aviso /3"
  else
    grep -qi 'grafo' "$f" && ko "$s cita grafo" || ok
  fi
  grep -qE 'skill graph|`graph`|graph, scope|skill `graph`' "$f" && ko "$s cita skill graph" || ok
done
m="$(cat skills/memory/SKILL.md 2>/dev/null)"
for op in '### 1. carregar-contexto' '### 2. bootstrap' '### 3. registrar-no' '### 4. registrar-delta' '### 5. registrar-aprendizado' '### 6. compactar' '### 7. consultar-codigo'; do
  assert_contains "$m" "$op" "memory op $op"
done
assert_contains "$m" 'GRAFO.md' "/3 memory avisa sobre GRAFO.md antigo"   # única menção permitida: o aviso
assert_eq "1" "$(grep -c 'GRAFO.md' skills/memory/SKILL.md 2>/dev/null)" "/3 GRAFO.md aparece só no aviso"
for s in 'hooks/graphify-status' 'uv tool install graphifyy' 'pipx install graphifyy' 'graphify --version' 'graphify update .' 'graphify hook install' 'graphify-out/' '.gitignore' 'graphify: ativo' 'graphify: recusado' 'graphify: sem-codigo' 'graphify query' 'graphify path' 'graphify affected' '--budget' 'src=' 'Aprendizados' '| <fase> |' 'docs/audora/memory/' 'docs/audora/arquivo/' 'aprendizados-historico.md' 'memory-validate' 'memory-guard'; do
  assert_contains "$m" "$s" "memory cita '$s'"
done
assert_not_contains "$m" 'PT→EN' "memory sem migração PT→EN"
assert_not_contains "$m" 'versao-schema' "memory sem schema v1/v2"
for s in plan execute debug; do
  f="$(cat skills/$s/SKILL.md)"
  assert_contains "$f" 'consultar-codigo' "/14 $s consulta o índice de código"
  assert_contains "$f" 'graphify: ativo' "/14 $s condiciona ao estado ativo"
done
for s in scope e2e validate audora-commander; do
  grep -qi 'graphify' "skills/$s/SKILL.md" && ko "/18 $s não deve citar graphify" || ok
done
for s in scope execute debug e2e; do
  assert_contains "$(cat skills/$s/SKILL.md)" 'registrar-aprendizado' "/6 $s registra aprendizado"
done
a="$(cat skills/audora-commander/SKILL.md)"
assert_contains "$a" 'skill `memory`' "/2 porta de entrada usa skill memory"
assert_contains "$a" 'MEMORY ausente' "/2 porta de entrada oferece bootstrap"
v="$(cat skills/validate/SKILL.md)"
assert_contains "$v" 'docs/audora/memory/<id>.md docs/audora/arquivo/' "/7 validate arquiva por git mv"
assert_contains "$v" 'aprendizados' "/7 validate consolida aprendizados"
assert_contains "$v" 'MEMORY → PRD' "/7 direção única"
report
