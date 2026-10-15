# Plano — relatorio-entrega: Relatório de entrega

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** decidido o portão final (aprovado, parcial ou reprovado), em
qualquer categoria, a validate fecha o turno com um relatório de entrega em
Markdown por seções — Demanda · Mudanças no caminho · Entregue · Evidência ·
Como conferir · Decisões tomadas pela IA · Arquivos tocados — com fonte lida
na sessão em cada célula.

**Nó do MEMORY:** `relatorio-entrega` (MEMORY.md)

**Arquitetura da mudança:** o formato vive no template canônico do bloco de
fechamento (`templates/bloco-fechamento-template.md`): a seção "Bloco de
entrega (só a validate, após aprovação)" é substituída por "Relatório de
entrega (só a validate, decidido o portão)", com o exemplo das 7 seções e 10
regras curtas. A skill `validate` só aponta (roteador, 2 parágrafos): Próximo
para reprovação/parcial e o relatório como última parte do turno; a reference
LIGHT ganha 1 bullet (relatório sai igual; decisões da IA vêm do nó, sem
plano). Prova por teste de texto em arquivo próprio
(`tests/test-relatorio-entrega.sh`, padrão `flat`/`sec`), e as guardas de
carga pinadas no byte sobem no mesmo commit que as cresce, com nota de
medição. Nenhum hook, README ou PRD muda nesta demanda (PRD e CHANGELOG são
do sync da validate).

**Arquivos lidos antes de planejar:**
- `MEMORY.md:1-44,49-107` — Propósito, Constituição (`como-rodar`: `bash tests/run.sh`; `gate`: `bash hooks/gate <id>`; `ferramenta-e2e`: `claude -p`), índice com a linha do nó (in-progress).
- `docs/audora/memory/relatorio-entrega.md:1-93` — 11 critérios (23-68), fora-de-escopo (69-77), 6 decisões (78-86), `## delta` vazio (87); 93 linhas, teto ~100 do memory-guard.
- `docs/audora/aprendizados.md` (grep plan + keywords) — 2026-08-27 string de `assert_contains` cabe em 1 linha; 2026-09-05 asserir a frase inteira dentro da seção extraída por awk; 2026-09-28 medir bytes sem `\r`; 2026-10-08 guardas de carga pinadas sobem no mesmo commit, com nota de medição; 2026-10-12 prosa ≥ 200 chars entre ferramentas vira narração.
- `docs/audora/decisoes-vivas.md` (grep bloco|fechamento|validate|relat|carga|template) — nada governa o formato do bloco.
- `templates/bloco-fechamento-template.md:1-223` — recursos visuais (13-27), ícones de estado (29-42), bloco de fase (44-101), parada (103-125), LIGHT/HOTFIX (127-153), fase reprovada (155-186), bloco de entrega (188-223 = 1678 B LF, a substituir); arquivo 10214 B LF, só LF.
- `templates/no-template.md:1-72` — `## decisoes` (45-50) e formato do `## delta` (52-58): `ADICIONADO (data)`, `MODIFICADO (data): antes → depois`, `REMOVIDO (data): … + motivo`.
- `templates/plano-template.md:1-50` — formato deste plano.
- `skills/validate/SKILL.md:1-115` — item 4 (69-70): decisões da IA acumuladas no plano; item 5 (71-77): portão aprovou/reprovou/parcial; bloco de fechamento (98-111); linhas 104-111 = 452 B LF, a substituir; arquivo 6124 B LF.
- `skills/validate/references/fechamento-light.md:1-32` — bullets de oferta, roteiro, sync, plano, PRD; linha 30 fecha o bullet PRD, 32 é a frase do HOTFIX; 1770 B; fora de `BASE_LIST`/`FULL_EXTRA`.
- `skills/validate/references/sync.md` (grep bloco|entrega|numstat) — nada sobre o bloco de entrega.
- `skills/execute/SKILL.md:48-60` — item 5: micro-decisão vai à lista "Decisões tomadas pela IA" no plano.
- `skills/memory/SKILL.md:1-138` — carregar-contexto; registrar-delta (decisão de IA → lista, a validate apresenta); registrar-aprendizado.
- `skills/audora-commander/SKILL.md` (grep ategoria: 43, 53, 62-70, 92-95) — categoria é anunciada e vai ao Produzido da porta; `skills/scope/SKILL.md` e `skills/memory/references/registrar-no.md` (grep ategoria): nenhuma ocorrência — a categoria NÃO é persistida no nó pelo framework.
- `tests/lib.sh:1-21` — `assert_contains` (grep -qF), `assert_not_contains`, `assert_eq`, `ok`/`ko`, `report`.
- `tests/run.sh:1-10,23,38` — glob `tests/test-*.sh`, roda em paralelo, exit 1 se algo falha.
- `tests/test-templates.sh:1-32` — 23 pina `#### 🚀 Entrega — <id>`; 24 pina `| critério | veredito  | evidência`.
- `tests/test-skills.sh:70-115,165-182` — 93 pina `git diff --name-only` na validate; 94 pina `**Entrega**`; 180 validate < 7700 B.
- `tests/test-carga.sh:1-23` — `BASE_LIST` inclui `validate/SKILL.md` e o template; nota de medição na linha 7; `TETO_BASE=54900` (15), `TETO_FULL=63000` (16); medido hoje base=54029 full=62857.
- `tests/test-parada-revisao.sh:44-60` — 54 validate ≤ 6139 B; 59 pino BASE ≤ 54029 (sobe junto com `test-carga.sh`, commit `e7b48ad`).
- `tests/test-leitura-por-secao.sh:105-118` — 111 validate ≤ 6139 B ("guarda de parada-revisao/9").
- `tests/test-prd-foto.sh:70-90` — 80-82 strings da validate a manter (`` `PRD.md` atualizado e `CHANGELOG.md` com a linha da entrega ``), < 7700 B; 85-89 strings da LIGHT a manter.
- `tests/test-gate.sh:85-95` — strings `**Diff de teste**` e `arquivos de teste separado(s)` na validate e na LIGHT, a manter.
- `tests/test-contexto-por-fase.sh:1-58` — helper `sec`; pinos só da seção `## Parada entre fases` (intocada).
- `tests/test-porta-anuncio.sh:1-30` — helper `flat <arquivo> [cabeçalho]` (modelo do teste novo).
- `tests/test-corte-sem-uso.sh:29` — extrai só `## Parada entre fases`.
- `hooks/gate:1-12,23-44` — compara contra HEAD; uso `bash hooks/gate <id>`.
- `README.md`, `README.pt-BR.md`, `docs/fundamentos.md` (grep entrega|delivery|bloco de fechamento) — não descrevem o bloco de entrega → sem mudança.
- `PRD.md:1-200` — foto; validate descrita sem o bloco de entrega (sync cuida).
- git: `a440d1e^:docs/audora/planos/arquivo/plano-porta-anuncio.md:1-90` — formato do plano anterior; `git log --merges` vazio: commits vão direto na `main`; escopo e plano foram commitados juntos (`8218c4d docs(porta-anuncio): … escopo e plano`).

**Conflitos MEMORY vs código encontrados:** nenhum. Observação (não é
conflito): /2 pede a categoria na seção Demanda, mas o framework não grava a
categoria no nó (só a anuncia na porta); este nó a tem no `## objetivo` porque
o scope escreveu à mão. Tratado na decisão D4 e como ressalva para o portão.

## Decisões tomadas pela IA

- **D1** — O relatório vem DEPOIS do bloco de fase (depois do `> ▶️ Próximo`),
  como última parte do turno (/11 literal). O bloco de fase (título · trilha ·
  produzido · arquivos · próximo) não muda; a frase "Soma ao bloco de fase,
  entre **Arquivos** e **Próximo**" sai.
- **D2** — Título `#### Relatório de entrega — <id>`, sem 🚀: reprovação
  também imprime (/9) e o foguete mentiria. Seção do template renomeada
  `## Relatório de entrega (só a validate, decidido o portão)`.
- **D3** — Tabela Evidência com 2 colunas (`| critério | evidência |`); o
  veredito mora em Entregue (/3), não se repete.
- **D4** — Fonte da categoria (/2): o nó (quando o scope a escreveu) ou o
  anúncio da porta nesta sessão (LIGHT/HOTFIX, mesma sessão); sem fonte →
  `[SEM FONTE]` (/10). Ressalva para o portão: persistir a categoria no nó é
  candidato a nó (fora desta demanda).
- **D5** — Guardas pinadas no byte sobem no commit da tarefa que as cresce,
  com nota de medição (aprendizado 2026-10-08): BASE/FULL em
  `tests/test-carga.sh` (linha 7 + tetos) e pino em
  `tests/test-parada-revisao.sh:59` (T1 e T2); validate 6139 → 6300 em
  `tests/test-parada-revisao.sh:54` e `tests/test-leitura-por-secao.sh:111`
  (T2, +134 B de 2 parágrafos-ponteiro). Motivo registrado no `## decisoes`
  do nó (T1).
- **D6** — Teste em arquivo próprio `tests/test-relatorio-entrega.sh` (padrão
  por nó, como `test-porta-anuncio.sh`), não dentro de `test-templates.sh`.
  As 2 asserções antigas de `test-templates.sh:23-24` e a de
  `test-skills.sh:93` são atualizadas em vez de apagadas (critério superado:
  resumo-de-fase/4 → relatorio-entrega/1,/4,/8), mantendo a contagem de
  asserts.
- **D7** — Fonte de "Decisões tomadas pela IA" no relatório (/6): a lista do
  plano (item 4 do fluxo da validate) e as linhas `(IA` do `## decisoes` do
  nó (LIGHT não tem plano). Onde elas são armazenadas segue sendo do nó
  `contratos-de-texto`.
- **D8** (execute, Tarefa 1) — Os tetos e o pino BASE são literais também em
  `tests/test-leitura-por-secao.sh:124-125,129` e `tests/test-plano-mapa.sh:76-77`
  (fora do mapa; o gate da Tarefa 1 reprovou 5 asserts): sobem no mesmo
  commit, pela regra da D5. Na Tarefa 2 o pino BASE de
  `tests/test-leitura-por-secao.sh:129` acompanha o de `test-parada-revisao.sh:59`.

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda: abordagens descartadas
e por quê, estado parcial, próximos passos. Próxima sessão lê isto primeiro. -->

Plan (2026-10-15): nó e índice (`MEMORY.md`) ainda sem commit — o passo 0 da
Tarefa 1 commita escopo + plano juntos (convenção `8218c4d`).

---

## Tarefa 1: Seção "Relatório de entrega" no template + teste novo + guardas de carga

- **depende-de**: []
- **requisito**:
  - `relatorio-entrega/1` — QUANDO o portão final da validate for decidido (aprovado, parcial ou reprovado), em QUALQUER categoria (LIGHT, MEDIUM, HIGH, HOTFIX) O SISTEMA DEVE imprimir no chat o relatório de entrega com as seções nesta ordem: Demanda · Mudanças no caminho · Entregue · Evidência · Como conferir · Decisões tomadas pela IA · Arquivos tocados
  - `relatorio-entrega/2` — QUANDO o relatório for impresso O SISTEMA DEVE abrir com a seção Demanda trazendo categoria, total de critérios e o objetivo copiado do campo `objetivo` do nó (1-2 frases), nunca reescrito de memória
  - `relatorio-entrega/3` — QUANDO o relatório for impresso O SISTEMA DEVE listar em Entregue uma linha por critério do nó (TODOS), com o endereço `<id>/<n>`, o veredito (✅ entregue, ⏳ pendente ou ❌ reprovado) e o comportamento em linguagem de usuário ("o sistema agora ...")
  - `relatorio-entrega/4` — QUANDO o relatório for impresso O SISTEMA DEVE trazer a tabela Evidência com uma linha por critério: comando executado nesta sessão + resultado em 1 linha, ou link para o teste com âncora de linha; critério ⏳ ou ❌ leva o motivo no lugar da evidência
  - `relatorio-entrega/5` — QUANDO o nó tiver entradas em `## delta` O SISTEMA DEVE imprimir Mudanças no caminho com uma linha por entrada (ADICIONADO / MODIFICADO antes → depois / REMOVIDO + motivo); QUANDO não houver delta O SISTEMA DEVE omitir a seção
  - `relatorio-entrega/6` — QUANDO houver decisões de implementação tomadas pela IA na demanda O SISTEMA DEVE listá-las em Decisões tomadas pela IA, uma linha por decisão; QUANDO não houver O SISTEMA DEVE omitir a seção
  - `relatorio-entrega/7` — QUANDO o relatório for impresso O SISTEMA DEVE trazer Como conferir com ≥ 1 item: comando em code block ` ```text ` (botão de copiar) ou tela/rota a abrir, cada um ligado ao critério que confere
  - `relatorio-entrega/8` — QUANDO o relatório for impresso O SISTEMA DEVE fechar com Arquivos tocados tirado do `git diff --numstat` real da demanda (arquivo, +, −, total somado da saída), link clicável para arquivo existente e arquivo removido sem link
  - `relatorio-entrega/9` — QUANDO o portão reprovar ou aprovar parcialmente O SISTEMA DEVE imprimir o relatório mesmo assim, com veredito por critério, e o Próximo do bloco de fase apontando a decisão humana ou a fase de retorno — nunca omitir o relatório
  - `relatorio-entrega/10` — QUANDO um dado do relatório não tiver fonte lida nesta sessão (nó, saída de comando, diff) O SISTEMA DEVE marcar a célula como `[SEM FONTE]` e o critério ligado como ⏳, nunca preencher de memória
  - `relatorio-entrega/11` — QUANDO o relatório for impresso O SISTEMA DEVE ser a última parte da resposta do turno, sem chamada de ferramenta depois (prosa ≥ 200 chars entre ferramentas vira narração — aprendizado 2026-10-12)
- **decisões relevantes**: nó — relatório só após a decisão do portão; layout em seções verticais; parcial e reprovação também imprimem; seções condicionais (Mudanças, Decisões) omitidas quando vazias, Como conferir sempre; carga BASE pinada em `tests/test-carga.sh`. Plano — D1, D2, D3, D4, D5, D6, D7. Template — "todo ícone vem acompanhado de texto"; sem HTML, mermaid, alertas ou checkbox.
- **interfaces**: consome `docs/audora/memory/<id>.md` (campos `objetivo`, `criterios-aceite`, `## delta`, `## decisoes`), a saída de `git diff --numstat <base>..HEAD` e os comandos rodados na sessão · produz a seção `## Relatório de entrega (só a validate, decidido o portão)` do template, com o exemplo numa cerca de 4 crases (como a seção `## Parada entre fases` faz, porque o exemplo contém uma cerca `text` de 3 crases dentro) e a lista `Regras:` numerada 1-10.
- **ponto de mudança**: `templates/bloco-fechamento-template.md:188-223` — substituir a seção inteira `## Bloco de entrega (só a validate, após aprovação)` (até o fim do arquivo) pela seção nova; nada antes da linha 188 muda. Conteúdo-alvo (rascunho medido em 3921 B LF): `C:\Users\ITALOB~1\AppData\Local\Temp\claude\c--Users-Italo-Barros-workspace-audora-commander\c21b5513-5a30-4737-95a2-be8011833f7b\scratchpad\draft-template-relatorio.md` — se o scratchpad não existir mais, reescrever a partir das asserções abaixo (elas são o contrato; o rascunho é só atalho).
- **teste**: `tests/test-relatorio-entrega.sh` (novo; `source lib.sh`, helper `flat <arquivo> [cabeçalho]` copiado de `tests/test-porta-anuncio.sh:10-16` e `sec` de `tests/test-contexto-por-fase.sh:6`, `cd "$ROOT"`, termina em `report`) — casos "relatorio-entrega/1" … "relatorio-entrega/11" sobre a seção `## Relatório de entrega (só a validate, decidido o portão)`; mais a edição de `tests/test-templates.sh:23-24`.
- **asserções** (`r="$(sec templates/bloco-fechamento-template.md '## Relatório de entrega (só a validate, decidido o portão)')"`, `f="$(flat templates/bloco-fechamento-template.md '## Relatório de entrega (só a validate, decidido o portão)')"`, `b="$(flat templates/bloco-fechamento-template.md)"`):
  - /1 seção existe → `[ -n "$r" ]` ok
  - /1 ordem → `printf '%s\n' "$r" | grep -oE '^\*\*[^*]+\*\*' | tr '\n' '|'` = `**Demanda**|**Mudanças no caminho**|**Entregue**|**Evidência**|**Como conferir**|**Decisões tomadas pela IA**|**Arquivos tocados**|` (assert_eq)
  - /1 categorias e decisões → `$f` contém `TODA categoria (LIGHT, MEDIUM, HIGH, HOTFIX)` e `aprovado, parcial ou reprovado`
  - /1 posição → `$f` contém `depois do bloco de fase`
  - /2 → `$f` contém `**Demanda** — <categoria> · <n> critérios`, `` objetivo copiado do campo `objetivo` do nó `` e `nunca reescrito de memória`
  - /3 → `$f` contém `✅ entregue`, `⏳ pendente`, `❌ reprovado`, `TODOS os critérios do nó, um por linha` e `o sistema agora`
  - /4 → `$f` contém `| critério | evidência`, `comando executado nesta sessão + resultado em 1 linha, ou link para o teste com âncora de linha` e `leva o motivo no lugar da evidência`
  - /5 → `$f` contém `` uma linha por entrada de `## delta` do nó `` e `Sem delta, a seção não é impressa`
  - /6 → `$f` contém `uma linha por decisão` e `Sem nenhuma, a seção não é impressa`
  - /7 → `$f` contém `≥ 1 item, cada um ligado ao critério que confere`, `` code block ` ```text ` `` e `tela/rota a abrir`
  - /8 → `$f` contém `git diff --numstat <base>..HEAD`, `total somado dela`, `` arquivo removido sem link (`~~caminho/antigo.ts~~`) `` e `link clicável`
  - /9 → `$f` contém `Portão reprovado ou parcial imprime o relatório do mesmo jeito`, `fase de retorno (scope ou plan)` e `Nunca omitir o relatório`
  - /10 → `$f` contém `[SEM FONTE]` e `nunca preencher de memória`
  - /11 → `$f` contém `última parte da resposta do turno` e `nenhuma chamada de ferramenta depois dele`
  - regressão → `$b` NÃO contém `só a validate, após aprovação`, `entre **Arquivos** e **Próximo**` nem `#### 🚀 Entrega — <id>`; `$b` contém `## Parada entre fases` (seção vizinha intocada)
  - `tests/test-templates.sh:23` → `assert_contains "$b" '#### Relatório de entrega — <id>' "relatorio-entrega/1 template define o relatório de entrega (substitui resumo-de-fase/4)"`; `:24` → `assert_contains "$b" '| critério | evidência' "relatorio-entrega/4 tabela de evidência (substitui resumo-de-fase/4)"`
  - carga → `bash tests/test-carga.sh` imprime `base=<B> full=<F>` com B ≈ 56406 e F ≈ 65234; então `tests/test-carga.sh:15` `TETO_BASE=<ceil(B×1,03 / 100)×100>` (≈ 58100), `:16` `TETO_FULL=<ceil(F×1,03 / 100)×100>` (≈ 67200), `:7` ganha ao fim ` relatorio-entrega/1 (seção Relatório de entrega no template): BASE 54029 → <B> / FULL 62857 → <F>.`; `tests/test-parada-revisao.sh:59` → `[ "$base" -le <B> ]` e mensagem `> <B>`
  - nó → `docs/audora/memory/relatorio-entrega.md` ganha, após a linha 86 (último bullet de `## decisoes`), a linha `- 2026-10-15 (IA, plan): guardas de carga pinadas (BASE/FULL em tests/test-carga.sh e test-parada-revisao.sh; validate 6139 → 6300) sobem no commit que as cresce — o relatório entra no template da BASE por decisão humana de layout em seções.` (arquivo fica com 94 linhas, abaixo do teto ~100)
- **ler**: `templates/bloco-fechamento-template.md:103-125,186-223`, `tests/test-porta-anuncio.sh:1-16`, `tests/test-contexto-por-fase.sh:1-9`, `tests/test-templates.sh:17-27`, `tests/test-carga.sh:1-23`, `tests/test-parada-revisao.sh:56-60`, `docs/audora/memory/relatorio-entrega.md:78-87`
- **done quando**: `bash tests/test-relatorio-entrega.sh` sai `PASS=<n> FAIL=0`; `bash tests/test-templates.sh`, `bash tests/test-carga.sh` e `bash tests/test-parada-revisao.sh` saem `FAIL=0`; `bash tests/run.sh` sai 0; `tr -d '\r' < templates/bloco-fechamento-template.md | wc -c` ≈ 12457.

- [x] **passo 0 (escopo + plano)** — `git add MEMORY.md docs/audora/memory/relatorio-entrega.md docs/audora/planos/plano-relatorio-entrega.md && git commit -m "docs(relatorio-entrega): escopo e plano"`
- [x] **red** — criar `tests/test-relatorio-entrega.sh` com os casos /1-/11 e a regressão; editar `tests/test-templates.sh:23-24`; `bash tests/test-relatorio-entrega.sh` sai `PASS=0 FAIL=<n>` com `FAIL: relatorio-entrega/1 …` (seção ausente) e `bash tests/test-templates.sh` falha em `relatorio-entrega/1 template define o relatório de entrega` — motivo certo: o template ainda tem a seção antiga
- [x] **green** — substituir `templates/bloco-fechamento-template.md:188-223`; `bash tests/test-relatorio-entrega.sh` e `bash tests/test-templates.sh` saem `FAIL=0`; `bash tests/test-carga.sh` imprime o novo `base=<B> full=<F>` → subir `TETO_BASE`/`TETO_FULL`, nota da linha 7 e o pino de `tests/test-parada-revisao.sh:59`; acrescentar a linha de decisão ao nó; `bash tests/run.sh` sai 0 (somar os asserts de `grep PASS=`)
- [ ] **commit** — `git add templates/bloco-fechamento-template.md tests/test-relatorio-entrega.sh tests/test-templates.sh tests/test-carga.sh tests/test-parada-revisao.sh tests/test-leitura-por-secao.sh tests/test-plano-mapa.sh docs/audora/memory/relatorio-entrega.md && git commit -m "feat(relatorio-entrega/1): relatorio de entrega no template - 7 secoes, regras e guardas de carga"`

## Tarefa 2: validate aponta o relatório após qualquer decisão do portão

- **depende-de**: [Tarefa 1]
- **requisito**:
  - `relatorio-entrega/1` — QUANDO o portão final da validate for decidido (aprovado, parcial ou reprovado), em QUALQUER categoria (LIGHT, MEDIUM, HIGH, HOTFIX) O SISTEMA DEVE imprimir no chat o relatório de entrega com as seções nesta ordem: Demanda · Mudanças no caminho · Entregue · Evidência · Como conferir · Decisões tomadas pela IA · Arquivos tocados
  - `relatorio-entrega/8` — QUANDO o relatório for impresso O SISTEMA DEVE fechar com Arquivos tocados tirado do `git diff --numstat` real da demanda (arquivo, +, −, total somado da saída), link clicável para arquivo existente e arquivo removido sem link
  - `relatorio-entrega/9` — QUANDO o portão reprovar ou aprovar parcialmente O SISTEMA DEVE imprimir o relatório mesmo assim, com veredito por critério, e o Próximo do bloco de fase apontando a decisão humana ou a fase de retorno — nunca omitir o relatório
  - `relatorio-entrega/11` — QUANDO o relatório for impresso O SISTEMA DEVE ser a última parte da resposta do turno, sem chamada de ferramenta depois (prosa ≥ 200 chars entre ferramentas vira narração — aprendizado 2026-10-12)
- **decisões relevantes**: D1, D5, D6; Constituição — SKILL.md ≤ 250 linhas; parada-revisao/9 — o roteador só aponta, texto mora no template; `test-skills.sh:94` segue exigindo `**Entrega**`; `test-prd-foto.sh:80-81` e `test-gate.sh:88-89` exigem as strings atuais do item 6 e do bloco Arquivos.
- **interfaces**: consome a seção do template produzida na Tarefa 1 · produz o trecho `skills/validate/SKILL.md:104-111` novo (586 B LF, rascunho em `C:\Users\ITALOB~1\AppData\Local\Temp\claude\c--Users-Italo-Barros-workspace-audora-commander\c21b5513-5a30-4737-95a2-be8011833f7b\scratchpad\draft-validate-104-111.md`; sem o scratchpad, reescrever pelas asserções abaixo).
- **ponto de mudança**: `skills/validate/SKILL.md:107` — bullet **Próximo** passa a cobrir reprovação/parcial; `:109-111` — parágrafo "Aprovada, o bloco de fase é seguido do bloco **Entrega** … `git diff --name-only` … Formato no mesmo template." vira o parágrafo do relatório (decidido o portão, toda categoria, última parte da resposta). Linhas 104-106 ficam como estão.
- **teste**: `tests/test-relatorio-entrega.sh` — casos "relatorio-entrega/1 validate", "/8 validate", "/9 validate", "/11 validate" (append ao arquivo da Tarefa 1); edição de `tests/test-skills.sh:93`; guardas de bytes.
- **asserções** (`v="$(flat skills/validate/SKILL.md '## Bloco de fechamento')"`):
  - /9 → `$v` contém `**Próximo**: aprovada, nenhum — o fluxo encerra; reprovada ou parcial, a decisão humana ou a fase de retorno (scope ou plan).`
  - /1 → `$v` contém `Decidido o portão — aprovado, parcial ou reprovado, em toda categoria —, o bloco de fase é seguido do relatório de **Entrega**`
  - /11 → `$v` contém `última parte da resposta: nenhuma ferramenta depois dele`
  - /8 → `$v` contém `` arquivos tocados do `git diff --numstat` ``
  - regressão → `$v` NÃO contém `Aprovada, o bloco de fase é seguido do bloco **Entrega**` nem `git diff --name-only`; `$v` contém `` `PRD.md` atualizado e `CHANGELOG.md` com a linha da entrega `` (mantido)
  - `tests/test-skills.sh:93` → `assert_contains "$v" 'git diff --numstat' "relatorio-entrega/8 validate tira arquivos tocados do diff real (substitui resumo-de-fase/4 name-only)"`; `:94` fica
  - bytes → `tr -d '\r' < skills/validate/SKILL.md | wc -c` = 6258 (± o que a redação mudar), ≤ 6300 e < 7700; `tests/test-parada-revisao.sh:54` → `[ "$bytes" -le 6300 ] … "parada-revisao/9 roteador cresceu: $bytes > 6300 bytes (relatorio-entrega/9,/11 subiu de 6139)"`; `tests/test-leitura-por-secao.sh:111` → `[ "$bv" -le 6300 ] … "> 6300 (guarda de parada-revisao/9; relatorio-entrega/9,/11 subiu de 6139)"`
  - carga → `bash tests/test-carga.sh` imprime `base=<B2>` com B2 = B + 134 (± redação), abaixo de `TETO_BASE`; `tests/test-parada-revisao.sh:59` e `tests/test-leitura-por-secao.sh:129` → pino `<B2>` (D8); `tests/test-carga.sh:7` ganha ` relatorio-entrega/9,/11 (validate aponta o relatório): BASE <B> → <B2> / FULL <F> → <F2>.`
- **ler**: `skills/validate/SKILL.md:98-115`, `tests/test-skills.sh:92-94,180`, `tests/test-parada-revisao.sh:53-59`, `tests/test-leitura-por-secao.sh:110-111`, `tests/test-prd-foto.sh:79-82`, `tests/test-gate.sh:87-89`
- **done quando**: `bash tests/test-relatorio-entrega.sh`, `bash tests/test-skills.sh`, `bash tests/test-parada-revisao.sh`, `bash tests/test-leitura-por-secao.sh`, `bash tests/test-prd-foto.sh`, `bash tests/test-gate.sh` e `bash tests/test-carga.sh` saem `FAIL=0`; `bash tests/run.sh` sai 0.

- [ ] **red** — acrescentar os casos da validate a `tests/test-relatorio-entrega.sh` e editar `tests/test-skills.sh:93`; `bash tests/test-relatorio-entrega.sh` falha em `relatorio-entrega/9 validate` (Próximo antigo) e `bash tests/test-skills.sh` falha em `relatorio-entrega/8 validate` — motivo certo: validate ainda diz `name-only` e "Aprovada"
- [ ] **green** — editar `skills/validate/SKILL.md:104-111`; medir `tr -d '\r' < skills/validate/SKILL.md | wc -c`; subir as duas guardas 6139 → 6300; `bash tests/test-carga.sh` → pino de `test-parada-revisao.sh:59` e nota da linha 7; `bash tests/run.sh` sai 0
- [ ] **commit** — `git add skills/validate/SKILL.md tests/test-relatorio-entrega.sh tests/test-skills.sh tests/test-parada-revisao.sh tests/test-leitura-por-secao.sh tests/test-carga.sh && git commit -m "feat(relatorio-entrega/9): validate imprime o relatorio apos qualquer decisao do portao, ultima parte do turno"`

## Tarefa 3: fechamento LIGHT imprime o relatório

- **depende-de**: [Tarefa 1]
- **requisito**:
  - `relatorio-entrega/1` — QUANDO o portão final da validate for decidido (aprovado, parcial ou reprovado), em QUALQUER categoria (LIGHT, MEDIUM, HIGH, HOTFIX) O SISTEMA DEVE imprimir no chat o relatório de entrega com as seções nesta ordem: Demanda · Mudanças no caminho · Entregue · Evidência · Como conferir · Decisões tomadas pela IA · Arquivos tocados
  - `relatorio-entrega/6` — QUANDO houver decisões de implementação tomadas pela IA na demanda O SISTEMA DEVE listá-las em Decisões tomadas pela IA, uma linha por decisão; QUANDO não houver O SISTEMA DEVE omitir a seção
- **decisões relevantes**: D7; fechamento LIGHT "enxugar é tirar material de revisão, nunca tirar a revisão"; `test-skills.sh:102-110`, `test-prd-foto.sh:85-89` e `test-gate.sh:90-91` exigem as strings atuais da reference (nada sai, só entra 1 bullet); reference fora de `BASE_LIST`/`FULL_EXTRA` → carga não muda (conferir: `grep -c fechamento-light tests/test-carga.sh` = 0).
- **interfaces**: consome a seção do template (Tarefa 1) · produz 1 bullet em `skills/validate/references/fechamento-light.md`.
- **ponto de mudança**: `skills/validate/references/fechamento-light.md:30` — após o bullet **PRD** (termina na linha 30, antes da linha em branco 31 e da frase do HOTFIX na 32), inserir o bullet (texto exato, uma linha lógica quebrada em ≤ 80 colunas como os vizinhos): ``- **Relatório de entrega** (bloco de fechamento): sai igual, com todas as seções, em LIGHT; sem plano, as Decisões tomadas pela IA vêm só das linhas `(IA` do `## decisoes` do nó.``
- **teste**: `tests/test-relatorio-entrega.sh` — casos "relatorio-entrega/1 LIGHT" e "/6 LIGHT" (append).
- **asserções** (`l="$(flat skills/validate/references/fechamento-light.md)"`):
  - /1 LIGHT → `$l` contém `**Relatório de entrega**` e `sai igual, com todas as seções, em LIGHT`
  - /6 LIGHT → `$l` contém `` vêm só das linhas `(IA` do `## decisoes` do nó ``
  - regressão → `$l` contém `HOTFIX não usa este caminho` (frase final preservada) e `silêncio sobre o PRD é proibido`
  - carga → `bash tests/test-carga.sh` imprime o mesmo `base=<B2>` da Tarefa 2 (reference fora da carga)
- **ler**: `skills/validate/references/fechamento-light.md:26-32`, `tests/test-skills.sh:102-110`, `tests/test-prd-foto.sh:85-89`
- **done quando**: `bash tests/test-relatorio-entrega.sh` sai `FAIL=0`; `bash tests/test-skills.sh`, `bash tests/test-prd-foto.sh` e `bash tests/test-gate.sh` saem `FAIL=0`; `bash tests/run.sh` sai 0; `bash hooks/gate relatorio-entrega` sai `GATE: passou`.

- [ ] **red** — acrescentar os 2 casos a `tests/test-relatorio-entrega.sh`; `bash tests/test-relatorio-entrega.sh` falha em `relatorio-entrega/1 LIGHT` — motivo certo: a reference não cita o relatório
- [ ] **green** — inserir o bullet em `skills/validate/references/fechamento-light.md:30`; `bash tests/test-relatorio-entrega.sh` sai `FAIL=0`; `bash tests/run.sh` sai 0; `bash hooks/gate relatorio-entrega` sai `GATE: passou`
- [ ] **commit** — `git add skills/validate/references/fechamento-light.md tests/test-relatorio-entrega.sh && git commit -m "feat(relatorio-entrega/1): fechamento LIGHT imprime o relatorio de entrega"`
