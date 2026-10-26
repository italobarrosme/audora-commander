#!/usr/bin/env bash
# gitignore-padrao/1,/4-/16 — contratos de texto das skills e o sync com pastas efêmeras fora do git.
# O mecânico do .gitignore é provado em tests/test-versionamento.sh; a cleanup local em tests/test-cleanup-local.sh.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
achata() { cat "$@" 2>/dev/null | tr -d '\r' | tr '\n' ' ' | tr -s ' '; }

# ===================== T5 — skill memory: bootstrap e oferta única =====================
MS=skills/memory/SKILL.md; MR=skills/memory/references; VR="$MR/versionamento.md"
assert_file "$VR" "gitignore-padrao/4 reference versionamento existe"
[ "$(wc -l < "$VR" 2>/dev/null || echo 999)" -le 250 ] && ok || ko "gitignore-padrao/4 reference ≤ 250 linhas"
v="$(achata "$VR")"
assert_contains "$v" 'bash "<raiz do plugin>/hooks/versionamento"' "gitignore-padrao/4 reference chama o script"
assert_contains "$v" 'Bootstrap: rode `aplicar` sem perguntar e registre `versionamento: aplicado` na Constituição.' "gitignore-padrao/1 bootstrap aplica sem perguntar"
assert_contains "$v" 'Oferta (carregar-contexto, item 7): mostre o que passa a ser ignorado — `docs/audora/specs/`, `docs/audora/planos/`, `docs/audora/e2e/`, `docs/audora/depuracao/` — e a saída do `checar`; pergunte UMA vez.' "gitignore-padrao/4 oferta única mostra o ignorado"
assert_contains "$v" 'Recusou → registre `versionamento: recusado` e não reoferte, salvo pedido do humano.' "gitignore-padrao/5 recusado não reoferta"
assert_contains "$v" 'Linha `memória ignorada:` → mostre a regra, a linha `quebra:` e proponha o ajuste; `--desligar` só com sim.' "gitignore-padrao/6 regra que esconde a memória"
assert_contains "$v" '`fonte fora do projeto — não edito` → nomeie a fonte e não a edite.' "gitignore-padrao/7 fonte externa"
assert_contains "$v" 'Linha `versionado em pasta efêmera:` → liste-os e pergunte; `--remover` só com sim; sem sim, nada sai do git.' "gitignore-padrao/8 versionados com sim"
assert_contains "$v" '`commit falhou` → repasse a linha ao humano: o script já desfez as remoções.' "gitignore-padrao/9 commit falhou"
assert_contains "$v" 'Fora do git → repasse em 1 linha a saída do script.' "gitignore-padrao/10 fora do git"
m="$(achata "$MS")"
assert_contains "$m" '| versionamento | references/versionamento.md |' "gitignore-padrao/4 tabela do roteador"
assert_contains "$m" '7. Constituição sem bullet `versionamento:` → ofertar UMA vez aplicar o bloco do `.gitignore` (`references/versionamento.md`); `versionamento: recusado` → não reofertar, só se o humano pedir.' "gitignore-padrao/4,/5 item 7 da carregar-contexto"
b="$(achata "$MR/bootstrap.md")"
assert_contains "$b" '**Etapa versionamento** (sempre, antes da etapa gate)' "gitignore-padrao/1 bootstrap tem a etapa"
assert_contains "$b" 'references/versionamento.md' "gitignore-padrao/1 bootstrap aponta a reference"
assert_contains "$(achata templates/MEMORY-template.md)" '- **versionamento**: aplicado | recusado (skill memory, `references/versionamento.md`)' "gitignore-padrao/1 template da Constituição"

# ===================== T6 — e2e: veredito por critério no nó, evidência em docs/audora/e2e/ =====================
e="$(achata skills/e2e/SKILL.md)"
assert_contains "$e" '`- <id>/<n> · passou · <evidência em 1 frase>`' "gitignore-padrao/11 linha por critério no nó"
assert_contains "$e" 'no campo `## e2e` do nó' "gitignore-padrao/11 grava no campo ## e2e do nó"
assert_contains "$e" 'relatório: local: docs/audora/e2e/e2e-<id>.md' "gitignore-padrao/11 relatório como local:"
assert_contains "$e" 'screenshot, vídeo ou trace em `docs/audora/e2e/<id>/`' "gitignore-padrao/12 evidência binária em docs/audora/e2e/<id>/"
assert_not_contains "$e" '`falhou`' "gitignore-padrao/11 veredito reprovou, não falhou"
nt="$(achata templates/no-template.md)"
assert_contains "$nt" 'relatório: local: docs/audora/e2e/e2e-<id>.md' "gitignore-padrao/11 no-template: relatório local:"
assert_contains "$nt" '`- <id>/<n> · passou|reprovou|não-automatizável · <evidência em 1 frase>`' "gitignore-padrao/11 no-template: linha por critério"
assert_not_contains "$nt" '../e2e/e2e-<id>.md' "gitignore-padrao/13 no-template sem link relativo ao relatório"
[ "$(wc -l < skills/e2e/SKILL.md)" -le 250 ] && ok || ko "gitignore-padrao/11 e2e ≤ 250 linhas"

report
