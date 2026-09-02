#!/usr/bin/env bash
# sync-mecanizado/8,/10,/11 — hooks/memory-sync em fixture git real.
# O script e um GERADOR: le, imprime os comandos e NAO escreve. Quem aplica e
# o modelo, via Edit (o que faz memory-validate/memory-guard dispararem no
# PostToolUse — um script escrevendo por fora sairia do alcance deles).
source "$(dirname "$0")/lib.sh"
SYNC="$ROOT/hooks/memory-sync"
REAL_HEAD="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo sem-git)"

# Fixture com armadilha embutida: titulo com &, resumo com | no meio, e uma
# linha vizinha (no-x-historico) que um sed com ancora frouxa destruiria.
fixture() {
  F="$SP/fx_$RANDOM$RANDOM"
  mkdir -p "$F/docs/audora/arquivo" "$F/docs/audora/planos/arquivo" "$F/docs/audora/memory" || return 1
  cd "$F" || return 1
  git init -q || return 1
  git config user.email e2e@x || return 1
  git config user.name e2e || return 1
  cat > MEMORY.md <<'M'
memory-schema: 1

# MEMORY — fixture

## Propósito [carga: sempre]

Fixture.

## Constituição [carga: sempre]

- **graphify**: recusado

## Aprendizados [carga: sempre]

## Índice de nós [carga: sempre]

- no-x | in-progress | Titulo & Co | resumo com | pipe dentro | k1, k2 | src/
- no-x-historico | planned | Vizinho | nao pode ser tocado | k | s/
M
  printf 'a\n' > alfa.txt
  # A mensagem cita 'no-x' DE PROPOSITO, num commit ANTERIOR a criacao do no.
  # E o cenario do achado 1: no repo real, 7aaec1e ('registra 4 nos') cita os
  # quatro ids. Derivar a base por --grep pegaria ESTE commit e traria
  # alfa.txt para a lista. Sem isto, o teste nao distingue a derivacao certa
  # da errada — verificado por mutacao.
  git add -A >/dev/null 2>&1 && git commit -qm "chore(memory): registra os nos no-x e no-x-historico" >/dev/null 2>&1 || return 1
  # commit que CRIA o arquivo do no — daqui sai a base do diff
  printf -- '---\nid: no-x\nestado: in-progress\norigem: humano\ndepende-de: []\narquivos: []\nkeywords: [k1]\nresumo: r\natualizado-em: 2026-09-02\n---\n\n# no-x\n' > docs/audora/memory/no-x.md
  git add -A >/dev/null 2>&1 && git commit -qm "docs(no-x): abre o no" >/dev/null 2>&1 || return 1
  printf 'b\n' > beta.txt
  printf '# plano\n' > docs/audora/planos/plano-no-x.md
  git add -A >/dev/null 2>&1 && git commit -qm "feat(no-x/1): trabalho" >/dev/null 2>&1 || return 1
  # o modelo ja arquivou o no (passo 1 do fluxo do escopo)
  git mv docs/audora/memory/no-x.md docs/audora/arquivo/2026-09-02-no-x.md >/dev/null 2>&1 || return 1
  return 0
}

# /11 — fixture que falha ao montar ABORTA o arquivo de teste. Sem isto, os
# casos com git commit rodariam com cwd na raiz e commitariam no repo real.
fx() { fixture || { ko "/11 fixture falhou ao montar — abortando"; cd "$ROOT" || true; report; exit 1; }; }

# CASO 1 — caminho feliz: emite as 3 coisas e DISCRIMINA
fx
st_antes="$(git status --porcelain)"
bash "$SYNC" no-x > "$SP/o1" 2>&1; c1=$?
o1="$(cat "$SP/o1")"
assert_eq 0 "$c1" "/1 caminho feliz sai 0"
assert_contains "$o1" 'beta.txt' "/1 arquivos: pega o arquivo da demanda"
assert_not_contains "$o1" 'alfa.txt' "/1 arquivos: NAO pega commit anterior a demanda"
assert_not_contains "$o1" 'docs/audora/memory/no-x.md' "/1b exclui o proprio no"
assert_contains "$o1" '- no-x | delivered | Titulo & Co → docs/audora/arquivo/2026-09-02-no-x.md' "/2 linha do indice com & preservado"
assert_contains "$o1" 'git mv docs/audora/planos/plano-no-x.md docs/audora/planos/arquivo/' "/3 comando de arquivar o plano"
assert_not_contains "$o1" 'no-x-historico' "/2 nao encosta na linha vizinha"

# CASO 2 — /10: o script NAO escreve
assert_eq "$st_antes" "$(git status --porcelain)" "/10 repositorio inalterado apos rodar"

# CASO 3 — /6: com o sync ja aplicado, diz que nao ha o que fazer
perl -0pi -e 's#^- no-x \| in-progress \|.*$#- no-x | delivered | Titulo \& Co → docs/audora/arquivo/2026-09-02-no-x.md#m' MEMORY.md
perl -0pi -e 's#^arquivos: \[\]$#arquivos: [beta.txt]#m' docs/audora/arquivo/2026-09-02-no-x.md
git mv docs/audora/planos/plano-no-x.md docs/audora/planos/arquivo/ >/dev/null 2>&1
bash "$SYNC" no-x > "$SP/o3" 2>&1; c3=$?
assert_eq 0 "$c3" "/6 idempotente sai 0"
assert_contains "$(cat "$SP/o3")" 'nada a fazer' "/6 diz que ja esta feito"

# CASO 4 — /5: no ainda em memory/, nao arquivado
fx
git mv docs/audora/arquivo/2026-09-02-no-x.md docs/audora/memory/no-x.md >/dev/null 2>&1
bash "$SYNC" no-x > "$SP/o4" 2>&1; c4=$?
[ "$c4" -ne 0 ] && ok || ko "/5 no nao arquivado deve abortar"
assert_contains "$(cat "$SP/o4")" 'docs/audora/arquivo' "/5 aborto explica o que espera"
assert_not_contains "$(cat "$SP/o4")" 'arquivos:' "/5 aborto NAO emite comando nenhum"

# CASO 5 — /5: id ausente do indice
fx
perl -0pi -e 's#^- no-x \|.*\n##m' MEMORY.md
bash "$SYNC" no-x > "$SP/o5" 2>&1; c5=$?
[ "$c5" -ne 0 ] && ok || ko "/5 id fora do indice deve abortar"

# CASO 6 — /3: sem plano (caso LIGHT) nao e erro
fx
rm -f docs/audora/planos/plano-no-x.md
bash "$SYNC" no-x > "$SP/o6" 2>&1; c6=$?
assert_eq 0 "$c6" "/3 ausencia de plano nao e erro"
assert_not_contains "$(cat "$SP/o6")" 'git mv docs/audora/planos/plano-no-x.md' "/3 sem plano, sem comando de plano"
assert_contains "$(cat "$SP/o6")" '- no-x | delivered |' "/3 indice sai mesmo sem plano"

# CASO 7 — /7: nao e repositorio git
naogit="$SP/naogit_$RANDOM"
mkdir -p "$naogit" && cd "$naogit" || { ko "/7 nao montou o dir sem git"; cd "$ROOT" || true; report; exit 1; }
bash "$SYNC" no-x > "$SP/o7" 2>&1; c7=$?
[ "$c7" -ne 0 ] && ok || ko "/7 fora de repo git deve abortar"
assert_not_contains "$(cat "$SP/o7")" 'arquivos: []' "/7 nunca emite lista vazia"

# CASO 8 — glob ambiguo: no + historico + spec na mesma pasta
fx
printf -- '---\nid: no-x\n---\n' > docs/audora/arquivo/2026-09-02-no-x-historico.md
printf -- '# spec\n' > docs/audora/arquivo/2026-09-02-no-x-escopo.md
git add -A >/dev/null 2>&1; git commit -qm irmaos >/dev/null 2>&1
bash "$SYNC" no-x > "$SP/o8" 2>&1; c8=$?
assert_eq 0 "$c8" "/2 glob ambiguo nao confunde o script"
assert_contains "$(cat "$SP/o8")" '→ docs/audora/arquivo/2026-09-02-no-x.md' "/2 aponta o NO, nao o historico nem a spec"

# CASO 9 — o commit do sync toca arquivos que o script NAO pode ver ainda
# (PRD.md promovido depois, e o proprio no no caminho novo). O script tem que
# AVISAR com todas as letras, senao a lista sai incompleta em silencio.
# Descoberto reproduzindo o sync real do light-enxuto num clone: a lista do
# script perdia PRD.md contra a que eu tinha escrito a mao.
# ATENCAO: nao assere so 'PRD.md' — ele ja aparece no diff da fixture e o
# assert passaria por vacuidade, sem provar aviso nenhum.
fx
bash "$SYNC" no-x > "$SP/o9" 2>&1
o9="$(cat "$SP/o9")"
assert_contains "$o9" 'acrescente à lista' "/1 avisa que a lista nao ve o commit do sync"
assert_contains "$o9" 'PRD.md (se houver promoção)' "/1 nomeia o PRD como candidato"

cd "$ROOT" || exit 1
assert_eq "$REAL_HEAD" "$(git rev-parse HEAD 2>/dev/null || echo sem-git)" "/11 repositorio real intocado pelos testes"
report
