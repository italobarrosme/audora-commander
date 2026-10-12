#!/usr/bin/env bash
# porta-anuncio — a porta anuncia categoria, porquê e convite antes do 1º
# registro, e o eval porta prova (grader categoria, calibração).
source "$(dirname "$0")/lib.sh"
. "$ROOT/tests/evals-lib.sh"
. "$ROOT/tests/evals-testlib.sh"
cd "$ROOT" || exit 1
# flat <arquivo> [cabeçalho] → texto (da seção, se dado) sem \r, numa linha só,
# espaços colapsados: frase que quebra linha no Markdown ainda casa.
flat() {
  if [ -n "${2:-}" ]; then
    tr -d '\r' 2>/dev/null < "$1" | awk -v h="$2" '$0==h{f=1;next} /^## /{f=0} f'
  else
    tr -d '\r' 2>/dev/null < "$1"
  fi | tr '\n' ' ' | tr -s ' '
}

# --- /1 — passo 4 da porta é regra dura e cabe inteiro na mutação ---
P=skills/audora-commander/SKILL.md
fl="$(flat "$P" '## Fluxo')"
for s in 'Demanda classificada como <CATEGORIA> porque <respostas às perguntas de risco> — me corrija se discordar.' \
         'ANTES do passo 5' 'frase própria' 'o bloco de fechamento não substitui'; do
  assert_contains "$fl" "$s" "porta-anuncio/1"
done
for s in '[X]' '[respostas às perguntas]'; do
  assert_not_contains "$fl" "$s" "porta-anuncio/1 sem o modelo antigo"
done
resto="${fl#*5. \*\*Registrar o nó\*\*}"
assert_not_contains "$resto" '4. **Anunciar**:' "porta-anuncio/1 passo 4 antes do passo 5"
assert_contains "$fl" '5. **Registrar o nó**' "porta-anuncio/1 passo 5 existe"
assert_eq 1 "$(grep -cF '4. **Anunciar**:' "$P")" "porta-anuncio/1 âncora da mutação única"
cp "$P" "$SP/porta.md"
aplica_mutacao "$SP/porta.md" '4. **Anunciar**:' 'Correção do humano vale na hora.' >/dev/null
mu="$(flat "$SP/porta.md")"
for s in 'classificada como' 'me corrija' 'frase própria' 'ANTES do passo 5'; do
  assert_not_contains "$mu" "$s" "porta-anuncio/1 a mutação corta a regra inteira"
done

report
