# Plano — plano-mapa: Plano-mapa + localização

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** a tarefa do plano vira mapa (critério → caso de teste →
`caminho:linha`, com asserção exata quando o critério deixa o valor aberto);
plan, execute e debug ganham a regra de localização por trecho; versão
`0.12.0`; medição A/B contra o 0.11.0 registrada no nó.

**Nó do MEMORY:** `plano-mapa` (MEMORY.md) — escopo no próprio nó, 15
critérios aprovados (commit `a82ff1d`).

**Arquitetura da mudança:** mudança de texto em 3 skills e 1 template, com
guarda num arquivo de teste NOVO, `tests/test-plano-mapa.sh`, que cada
tarefa estende com a sua seção (padrão do `test-corte-sem-uso.sh`). Os
asserts novos rodam sobre texto ACHATADO (`flat`: sem `\r`, uma linha só,
espaços colapsados), então frase que quebra linha no Markdown ainda casa. Os
3 asserts antigos que exigiam o teste completo no plano (`otimizacao-tokens/5`)
e os 2 de versão `0.11.0` são TROCADOS, não apagados. O teto BASE de
`test-carga` (48000; hoje 46575) é o limite duro: cada tarefa que mexe em
arquivo da carga tem orçamento de bytes medido em rascunho. Por último, a
medição A/B numa fixture do scratchpad com `claude -p` (`expandir: sim`).

**Arquivos lidos antes de planejar:**
- `MEMORY.md:18-42` — Constituição: restrições (≤ 250 linhas por SKILL.md,
  executável só em `hooks/`/`tests/`), `como-rodar`, `gate: bash hooks/gate <id>`, `ferramenta-e2e: claude -p`.
- `MEMORY.md:44-83` — aprendizados usados: 53 (`assert_contains` não casa
  frase quebrada), 55 (exit do `tail`), 60 (somar asserts da saída real),
  64 (suíte > 120s → background), 65 (asserir a FRASE dentro da seção),
  67 (`git add` com caminhos), 73 (bytes sem `\r`), 74 (`2>/dev/null` antes
  do `<`), 82 (`--plugin-dir` + `enabledPlugins:false`), 83 (gate compara
  contra HEAD → rodar antes do commit).
- `docs/audora/memory/plano-mapa.md:1-71` — 15 critérios, decisões (tarefa =
  mapa com asserção; 3 leituras; 200 linhas; `test-skills.sh:178` trocado).
- `docs/study/2026-09-30-estudo-leitura-codigo.md:298-428` — partes 3 e 4:
  trecho vence arquivo inteiro; contexto faltante é a falha dominante;
  subagente com pergunta delimitada devolvendo `caminho:linha` conferido.
- `docs/audora/decisoes-vivas.md:1-38` — "impor por teste, não por prosa"
  (base do teste único execute↔debug).
- `templates/plano-template.md:1-58` — header 14-19 (arquivos lidos sem
  trecho), tarefa 26-58 (passo 1 "código do teste no plano, completo").
- `templates/bloco-fechamento-template.md:1-124` — formato do bloco; PARADA.
- `skills/plan/SKILL.md:1-104` — passadas 24-29, escrita 33-47,
  placeholders 48-51, replanejamento 63-73, red flags 81-89.
- `skills/execute/SKILL.md:1-99` — Fluxo 17-59 (RED 27-32), "Quando algo
  dá errado" 61-71.
- `skills/debug/SKILL.md:1-113` — Modo sintoma 19-51 (passo 2 26-30),
  Modo caçada 53-84.
- `tests/lib.sh:1-21` (asserts, `report`), `tests/run.sh:1-10`,
  `tests/test-carga.sh:1-22` (tetos nas linhas 14-15; comentário de
  medição na linha 6), `tests/test-skills.sh:1-205` (bloco
  `otimizacao-tokens/5` 175-181; guardas de "índice de código" 71-74),
  `tests/test-templates.sh:1-33`, `tests/test-docs.sh:1-70` (versão na
  linha 7), `tests/test-corte-sem-uso.sh:1-55` (lista proibida
  `autopilot|motor|…` 18; versão 49-53), `tests/test-contexto-por-fase.sh:1-60`
  (asserts de plan/execute que precisam continuar verdes).
- `hooks/gate:1-70` — anti-fraude: teste apagado, skip, queda de asserts
  (compara contra HEAD).
- `.claude-plugin/plugin.json:1-8`, `.claude-plugin/marketplace.json:1-14` — `"version": "0.11.0"`.
- `README.md:168-202` (plan 177-178 "full TEST code"; execute 190),
  `README.md:245-261` (debug 253-254); `README.pt-BR.md:169-203` (plan
  178-180; execute 191), `README.pt-BR.md:246-262` (debug 255).
- `docs/fundamentos.md:74-105` — P2 regras 1 (duas passadas) e 3 (tarefa
  autossuficiente).
- `PRD.md:1-80`, `PRD.md:205-225`, `PRD.md:515-534` — só leitura (PRD segue a
  main; atualizado no sync da validate, não nesta branch).
- `docs/audora/e2e/e2e-corte-sem-uso.md:1-30` — receita de fixture +
  `claude.exe -p` com `--plugin-dir`.
- `docs/audora/arquivo/2026-09-30-corte-sem-uso.md:50-56` — precedente da
  seção `## medicao` no nó.

**Conflitos MEMORY vs código encontrados:** nenhum. (`PRD.md:50` e `:213`
dizem "código completo do teste" — é o estado da main, não conflito.)

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda: abordagens descartadas
e por quê, estado parcial, próximos passos. Próxima sessão lê isto primeiro. -->

- 2026-09-30 (plan): ensaio a seco numa cópia do HEAD, no scratchpad, com os
  textos exatos de T1–T4. Os blocos de teste de T1–T4 somados deram, no HEAD,
  `PASS=3 FAIL=32` (9 + 6 + 9 + 8, e os 3 que passam são os previstos em
  T1 e T4). Com os textos aplicados, deram `PASS=35 FAIL=0`. Com as trocas de
  `test-skills.sh`: `test-skills` 216/0, `test-contexto-por-fase` 34/0,
  `test-corte-sem-uso` 38/0, `test-templates` 31/0 e `test-carga` com
  base=47702 e full=52942. Os blocos de T5 e T6 não entraram no ensaio.

## Decisões tomadas pela IA

1. Guarda num arquivo novo, `tests/test-plano-mapa.sh`, com helper `flat`;
   cada tarefa acrescenta a sua seção antes do `report`.
2. A execute ganha a seção própria `## Localização de código`, entre
   `## Fluxo` e `## Quando algo dá errado`. O debug repete as 4 regras
   (/5, /6, /7, /10) inline no passo 2 do modo sintoma, porque o debug roda
   sozinho sem carregar a execute; um laço de teste único assere as MESMAS
   frases nos dois arquivos, e a deriva vira vermelho.
3. Orçamento de bytes (/14), medido nos textos exatos deste plano aplicados
   numa cópia (`git archive HEAD`) no scratchpad: template 2573 → 2374,
   plan 5445 → 5860, execute 5533 → 6444 → carga BASE 46575 → 47702, FULL
   51815 → 52942. Tetos cumulativos da carga BASE: depois de T1 ≤ 46450, de
   T2 ≤ 46850, de T3 ≤ 47800.
4. READMEs EN/PT e `docs/fundamentos.md` P2 acompanham o formato novo. Não há
   critério próprio, mas a descrição antiga do plano ficaria falsa. `PRD.md`
   não é tocado.
5. Versão: `tests/test-docs.sh:7` e `tests/test-corte-sem-uso.sh:51` são
   trocados para `0.12.0`, não apagados, como fez o `corte-sem-uso`.
6. Medição: o plugin 0.11.0 sai por `git archive c23e00a` para o scratchpad,
   sem worktree e sem tocar o cache global. A fixture fica no scratchpad, sem
   versionar.

## Comandos comuns

- `SCRATCH` = diretório de scratchpad da sessão de execute.
- Teste da demanda (rápido, foreground):
  `bash tests/test-plano-mapa.sh; echo "exit=$?"`
- Gate (passa de 120s → `run_in_background`, ler o log inteiro; nunca `| tail`):
  `bash hooks/gate plano-mapa > "$SCRATCH/gate.log" 2>&1; echo "exit=$?"` →
  esperado `GATE: passou` e `exit=0`. Rodar ANTES do commit de cada tarefa
  (aprendizado 83) e anotar nas notas de sessão.
- Carga: `bash tests/test-carga.sh` → linha `carga MEDIUM (bytes): base=<n> full=<n>`.

---

## Tarefa 1: template do plano vira mapa

- **depende-de**: []
- **requisito**:
  - **plano-mapa/1** — QUANDO o plan escrever uma tarefa O SISTEMA DEVE registrar o requisito (`<id>/<n>`), o ponto de mudança (`caminho:linha`), o arquivo e o caso de teste, os trechos a ler (`caminho:início-fim`) e o done — sem o corpo do teste nem o da implementação.
  - **plano-mapa/2** — QUANDO o critério não fixar o valor exato esperado (formato, ordem, mensagem, código de saída, borda) O SISTEMA DEVE incluir na tarefa a asserção exata `entrada → saída esperada` de cada caso.
  - **plano-mapa/3** — QUANDO o plan ler código antes de planejar O SISTEMA DEVE listar no cabeçalho do plano cada leitura como `caminho:início-fim`, com o que foi relevante nela.
- **decisões relevantes**: tarefa é mapa com asserção (humano, 2026-09-30);
  /1 substitui `otimizacao-tokens/5` e o assert é trocado, não apagado (IA,
  aprovada); orçamento de bytes (Decisão da IA 3).
- **interfaces**:
  - produz: `flat <arquivo> [cabeçalho-exato]` em `tests/test-plano-mapa.sh`
    — imprime o arquivo (ou só a seção do cabeçalho até o próximo `## `) sem
    `\r`, numa linha, espaços colapsados. T2–T6 usam.
  - produz: os campos do template `**requisito**`, `**ponto de mudança**`,
    `**teste**`, `**asserções**`, `**ler**`, `**done quando**` (T2 descreve
    os mesmos).
- **arquivos**:
  - Criar: `tests/test-plano-mapa.sh`
  - Modificar: `templates/plano-template.md` (linhas 14-19 e 26-58), `tests/test-skills.sh:180`
- **done quando**: `test-plano-mapa.sh` exit 0; gate `exit=0`; carga BASE ≤ 46450.

- [ ] **1. Escrever o teste que falha** — criar `tests/test-plano-mapa.sh`:

```bash
#!/usr/bin/env bash
# plano-mapa — plano vira mapa; plan, execute e debug localizam código por trecho.
source "$(dirname "$0")/lib.sh"
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

# --- /1 /2 /3 — template: tarefa é mapa, asserção exata, leitura por trecho ---
pt="$(flat templates/plano-template.md)"
for s in '**requisito**: `<id>/<n>`' '**ponto de mudança**: `caminho/arquivo.ts:42`' \
         '**teste**: `caminho/arquivo.test.ts` — caso' '**ler**: `caminho/arquivo.ts:30-80`' \
         '**done quando**' 'sem o corpo do teste nem o da implementação'; do
  assert_contains "$pt" "$s" "plano-mapa/1 template tem '$s'"
done
assert_not_contains "$pt" 'código do teste no plano, completo' "plano-mapa/1 template sem o teste completo"
assert_contains "$pt" '**asserções**: `entrada → saída esperada`, uma por caso — só quando o critério não fixa o valor (formato, ordem, mensagem, código de saída, borda)' "plano-mapa/2 template pede asserção exata"
assert_contains "$pt" 'Uma linha por leitura, `caminho:início-fim`' "plano-mapa/3 template: leitura por trecho"
assert_contains "$pt" '- `caminho/exato/arquivo1.ts:12-60` — <o que foi relevante nela>' "plano-mapa/3 template: exemplo com trecho"

report
```

  E trocar `tests/test-skills.sh:180` (mesmo nº de asserts):

```bash
assert_contains "$pt" 'sem o corpo do teste nem o da implementação' "plano-mapa/1 template: sem corpo de código (substitui otimizacao-tokens/5)"
```

- [ ] **2. Ver falhar** — `bash tests/test-plano-mapa.sh; echo "exit=$?"` →
  9 linhas `FAIL: plano-mapa/…` (5 do laço — só `**done quando**` passa —,
  o `assert_not_contains`, /2 e os 2 de /3), `PASS=1 FAIL=9`, `exit=1`.
  `bash tests/test-skills.sh` → 1 FAIL `plano-mapa/1 template: sem corpo de código`.
- [ ] **3. Implementar** — `templates/plano-template.md`:
  - Header (14-19) passa a ser exatamente:

```markdown
**Arquivos lidos antes de planejar:** <!-- Lei de Ferro: plano sem leitura do
código atual é plano inválido. Uma linha por leitura, `caminho:início-fim`.
Etapa que toca arquivo fora desta lista invalida o plano naquele ponto. -->
- `caminho/exato/arquivo1.ts:12-60` — <o que foi relevante nela>
- `caminho/exato/arquivo2.ts:1-40` — <o que foi relevante nela>
```

  - Bloco da tarefa (26 até o fim) passa a ser exatamente (rascunho medido:
    1321 bytes):

```markdown
## Tarefa 1: <nome curto>

- **depende-de**: []
- **requisito**: `<id>/<n>` — <critério EARS copiado verbatim do nó>
- **decisões relevantes**: <decisões do nó/constituição que governam esta tarefa>
- **interfaces**: consome <assinatura exata> · produz <assinatura exata>
- **ponto de mudança**: `caminho/arquivo.ts:42` — <símbolo e o que muda>
- **teste**: `caminho/arquivo.test.ts` — caso "<nome citando `<id>/<n>`>"
- **asserções**: `entrada → saída esperada`, uma por caso — só quando o
  critério não fixa o valor (formato, ordem, mensagem, código de saída, borda)
- **ler**: `caminho/arquivo.ts:30-80`, `caminho/outro.ts:10-25`
- **done quando**: <condição objetiva verificável>

- [ ] **red** — `<comando>` falha com `<saída esperada>` (motivo certo)
- [ ] **green** — `<comando>` passa e a suíte toda fica verde
- [ ] **commit** — `git add <arquivos> && git commit -m "<tipo>(<id>/<n>): <msg>"`

<!-- Tarefa é mapa: sem o corpo do teste nem o da implementação — nascem na
execute, UMA vez. Complexa: `expandir: sim`, quebrar só quando chegar a vez.
Proibições: TBD; TODO; "tratar erros adequadamente"; "similar à tarefa N"
(repita a asserção); passo sem arquivo, `caminho:linha` ou comando exatos;
referência a função/tipo não definido em nenhuma tarefa. -->
```

  Checar que `sem o corpo do teste nem o da implementação` ficou numa linha só
  (o assert de `test-skills.sh` usa `cat`, sem `flat`) e que `TBD` continua
  (`test-skills.sh:181`).
- [ ] **4. Ver passar** — `bash tests/test-plano-mapa.sh; echo "exit=$?"` →
  `PASS=10 FAIL=0`, `exit=0`; `bash tests/test-carga.sh` → `base=` ≤ 46450;
  gate → `GATE: passou`, `exit=0`.
- [ ] **5. Commit** — `git add tests/test-plano-mapa.sh templates/plano-template.md tests/test-skills.sh && git commit -m "feat(plano-mapa/1,2,3): template do plano vira mapa — requisito, ponto de mudança, teste, asserção exata, trechos; otimizacao-tokens/5 trocado"`

---

## Tarefa 2: skill plan escreve o mapa

- **depende-de**: [1]
- **requisito**:
  - **plano-mapa/1** — QUANDO o plan escrever uma tarefa O SISTEMA DEVE registrar o requisito (`<id>/<n>`), o ponto de mudança (`caminho:linha`), o arquivo e o caso de teste, os trechos a ler (`caminho:início-fim`) e o done — sem o corpo do teste nem o da implementação.
  - **plano-mapa/2** — QUANDO o critério não fixar o valor exato esperado (formato, ordem, mensagem, código de saída, borda) O SISTEMA DEVE incluir na tarefa a asserção exata `entrada → saída esperada` de cada caso.
  - **plano-mapa/3** — QUANDO o plan ler código antes de planejar O SISTEMA DEVE listar no cabeçalho do plano cada leitura como `caminho:início-fim`, com o que foi relevante nela.
  - **plano-mapa/4** — QUANDO o plan precisar responder pergunta ampla sobre código que não conhece O SISTEMA DEVE delegar a um subagente de exploração com pergunta delimitada que devolve `caminho:linha`, e conferir o trecho por leitura própria antes de gravar no mapa.
  - **plano-mapa/9** (lado do plan) — QUANDO a execute precisar MODIFICAR arquivo fora do mapa O SISTEMA DEVE parar a tarefa e voltar ao plan para replanejar só aquela etapa.
- **decisões relevantes**: a regra vale para plan, execute e debug (humano);
  índice de código fora de escopo (as guardas `test-skills.sh:71-74` seguem
  valendo: nada de "índice de código" no texto); orçamento de bytes: carga
  BASE ≤ 46850 no fim da tarefa.
- **interfaces**: consome `flat` (T1) e os campos do template (T1).
- **arquivos**:
  - Modificar: `skills/plan/SKILL.md` (24-51, 63-73, 81-89), `tests/test-skills.sh:175-178`
  - Teste: `tests/test-plano-mapa.sh` (seção nova antes do `report`)
- **done quando**: `test-plano-mapa.sh` e `test-skills.sh` exit 0; gate `exit=0`; carga BASE ≤ 46850.

- [ ] **1. Escrever o teste que falha** — em `tests/test-plano-mapa.sh`, antes
  do `report`:

```bash
# --- /1 /2 /3 /4 /9 — plan: mapa, asserção exata, header por trecho, subagente conferido ---
pf="$(flat skills/plan/SKILL.md '## Fluxo')"
assert_contains "$pf" 'Tarefa é MAPA, sem o corpo do teste nem o da implementação' "plano-mapa/1 plan: tarefa é mapa"
assert_contains "$pf" 'ponto de mudança `caminho:linha`, arquivo e caso de teste, trechos a ler e done' "plano-mapa/1 plan: campos do mapa"
assert_contains "$pf" 'Critério que não fixa o valor exato (formato, ordem, mensagem, código de saída, borda) → a tarefa traz a asserção exata `entrada → saída esperada` de cada caso' "plano-mapa/2 plan: asserção exata"
assert_contains "$pf" 'Listar no header CADA leitura como `caminho:início-fim`, com o que foi relevante nela' "plano-mapa/3 plan: header por trecho"
assert_contains "$pf" 'subagente de exploração com UMA pergunta delimitada, que devolve `caminho:linha`; confira o trecho com leitura própria antes de gravar no mapa' "plano-mapa/4 plan: subagente conferido"
assert_contains "$(flat skills/plan/SKILL.md '## Replanejamento (durante a execução)')" '(d) a execute precisa modificar arquivo fora do mapa' "plano-mapa/9 plan: gatilho de replanejamento"
```

  E trocar `tests/test-skills.sh:175-178` (mesmo nº de asserts; 179 fica):

```bash
# plano-mapa/1 — tarefa é mapa, sem corpo de código (substitui otimizacao-tokens/5)
pl="$(cat skills/plan/SKILL.md)"; pt="$(cat templates/plano-template.md)"
assert_contains "$pl" 'Tarefa é MAPA, sem o corpo do teste nem o da implementação' "plano-mapa/1 plan: tarefa sem corpo de código"
assert_not_contains "$pl" 'código completo do TESTE' "plano-mapa/1 plan: teste completo fora (substitui otimizacao-tokens/5)"
```

- [ ] **2. Ver falhar** — `bash tests/test-plano-mapa.sh; echo "exit=$?"` →
  6 FAIL `plano-mapa/1..4,9 plan…`, `exit=1`; `bash tests/test-skills.sh` →
  2 FAIL `plano-mapa/1 plan…`.
- [ ] **3. Implementar** — `skills/plan/SKILL.md`:
  - Itens 2-6 do Fluxo (24-51) passam a ser exatamente (rascunho: 2164 bytes):

```markdown
2. **Passada 1 — localizar**: a partir do escopo, achar onde a mudança mora
   (símbolos, rotas, nomes de domínio) pela busca do símbolo — só listar.
   Pergunta ampla sobre código que você não conhece → subagente de exploração
   com UMA pergunta delimitada, que devolve `caminho:linha`; confira
   o trecho com leitura própria antes de gravar no mapa.
3. **Passada 2 — ler**: ler por trecho o que o plano vai tocar (pontos da
   passada 1 + vizinhos de import, herança, registro e configuração).
   Listar no header CADA leitura como `caminho:início-fim`,
   com o que foi relevante nela. Etapa que tocar arquivo fora dessa lista
   invalida o plano naquele ponto → parar, ler, atualizar o header, seguir.
4. **Conflito MEMORY vs código**: leitura contradiz um nó do MEMORY? Parar,
   registrar a divergência no nó (skill memory), apresentar ao humano. Ele
   decide qual é a verdade antes do plano continuar.
5. **Escrever o plano** pelo template:
   - Header: objetivo, nó do MEMORY, arquitetura da mudança, trechos lidos.
   - Tarefa é MAPA, sem o corpo do teste nem o da implementação:
     requisito (critério EARS verbatim, com o endereço `<id>/<n>`),
     decisões, interfaces com assinaturas exatas, ponto de mudança
     `caminho:linha`, arquivo e caso de teste, trechos a ler e done.
   - Critério que não fixa o valor exato (formato, ordem, mensagem, código
     de saída, borda) → a tarefa traz a asserção exata `entrada → saída esperada` de cada caso.
   - `depende-de` explícito entre tarefas: "qual a próxima?" é resposta
     mecânica — nunca uma tarefa bloqueada.
   - Passos com checkbox: red → green → commit, com comandos exatos.
   - Tarefa complexa: marcar `expandir: sim` e quebrar em subtarefas SÓ
     quando chegar a vez dela (just-in-time — não detalhe tudo no dia 1).
6. **Proibição de placeholders** — falhas de plano, nunca escreva: "TBD",
   "tratar erros adequadamente", "adicionar validação", "similar à tarefa N"
   (repita a asserção), passo sem arquivo, `caminho:linha` ou comando exatos,
   referência a função/tipo não definido em nenhuma tarefa.
```

  - Replanejamento: nova linha logo depois do gatilho (c) (linha 70):
    `- (d) a execute precisa modificar arquivo fora do mapa — replanejar só aquela etapa.`
  - Red flags: nova linha no fim da tabela:
    `| "O subagente disse que é em X:42, gravo no mapa" | Resposta de subagente é pista. Leia o trecho antes de gravar. |`
- [ ] **4. Ver passar** — `test-plano-mapa.sh` → `FAIL=0`, `exit=0`;
  `bash tests/test-skills.sh` e `bash tests/test-contexto-por-fase.sh` →
  `FAIL=0`; `bash tests/test-carga.sh` → `base=` ≤ 46850; gate → `exit=0`.
- [ ] **5. Commit** — `git add skills/plan/SKILL.md tests/test-plano-mapa.sh tests/test-skills.sh && git commit -m "feat(plano-mapa/1,2,3,4,9): plan escreve o mapa, lê por trecho e confere o subagente de exploração"`

---

## Tarefa 3: execute localiza código por trecho

- **depende-de**: [1]
- **requisito**:
  - **plano-mapa/5** — QUANDO a execute começar uma tarefa O SISTEMA DEVE ler os trechos que o mapa aponta; arquivo com mais de 200 linhas é lido pelo trecho, nunca inteiro.
  - **plano-mapa/6** — QUANDO a execute precisar de código fora do mapa O SISTEMA DEVE localizá-lo por busca do símbolo e ler só o trecho apontado.
  - **plano-mapa/7** — QUANDO a mudança tocar import, herança, registro ou configuração O SISTEMA DEVE seguir essa ligação e ler o trecho ligado, mesmo fora do mapa.
  - **plano-mapa/8** — QUANDO ocorrer a 3ª leitura fora do mapa na mesma tarefa O SISTEMA DEVE acrescentar ao mapa do plano os `caminho:linha` lidos e seguir a tarefa.
  - **plano-mapa/9** — QUANDO a execute precisar MODIFICAR arquivo fora do mapa O SISTEMA DEVE parar a tarefa e voltar ao plan para replanejar só aquela etapa.
  - **plano-mapa/10** — QUANDO o `caminho:linha` do mapa não bater com o código (arquivo mudou, linha deslocada) O SISTEMA DEVE relocalizar por busca do símbolo e corrigir o mapa, sem ler o arquivo inteiro.
  - **plano-mapa/11** — QUANDO a execute receber plano no formato antigo (código completo do teste) O SISTEMA DEVE executá-lo sem pedir conversão.
  - **plano-mapa/1** (lado da execute) — o corpo do teste nasce na execute, a partir do caso e das asserções do mapa.
- **decisões relevantes**: 3 leituras fora do mapa → anota e segue; volta
  ao plan só para MODIFICAR fora do mapa (humano); limiar 200 linhas (IA,
  aprovada); seção própria (Decisão da IA 2); carga BASE ≤ 47800 no fim.
- **interfaces**: consome `flat` (T1). Produz a seção `## Localização de
  código` de `skills/execute/SKILL.md` com as frases que T4 assere também no debug.
- **arquivos**:
  - Modificar: `skills/execute/SKILL.md` (RED na linha 27; seção nova entre 59 e 61)
  - Teste: `tests/test-plano-mapa.sh`
- **done quando**: `test-plano-mapa.sh` exit 0; gate `exit=0`; carga BASE ≤ 47800.

- [ ] **1. Escrever o teste que falha** — em `tests/test-plano-mapa.sh`, antes do `report`:

```bash
# --- /5 /6 /7 /8 /9 /10 /11 — execute: localização por trecho ---
el="$(flat skills/execute/SKILL.md '## Localização de código')"
for s in 'ao começar a tarefa, ler os trechos que o mapa aponta' \
         'Arquivo com mais de 200 linhas é lido pelo trecho, nunca inteiro'; do
  assert_contains "$el" "$s" "plano-mapa/5 execute: '$s'"
done
assert_contains "$el" '**Fora do mapa**: buscar o símbolo e ler só o trecho apontado' "plano-mapa/6 execute: busca do símbolo"
assert_contains "$el" 'a mudança toca import, herança, registro ou configuração → seguir a ligação e ler o trecho ligado, mesmo fora do mapa' "plano-mapa/7 execute: segue ligações"
assert_contains "$el" 'na 3ª leitura fora do mapa na mesma tarefa, acrescentar ao mapa do plano os `caminho:linha` lidos e seguir' "plano-mapa/8 execute: orçamento de 3 leituras"
assert_contains "$el" '**Modificar arquivo fora do mapa** → parar a tarefa e voltar ao plan para replanejar só aquela etapa' "plano-mapa/9 execute: modificar fora volta ao plan"
assert_contains "$el" '(`caminho:linha` não bate): relocalizar pela busca do símbolo e corrigir o mapa, sem ler o arquivo inteiro' "plano-mapa/10 execute: mapa desatualizado"
assert_contains "$el" '**Plano no formato antigo** (código completo do teste): executar como está, sem pedir conversão' "plano-mapa/11 execute: formato antigo aceito"
assert_contains "$(flat skills/execute/SKILL.md '## Fluxo')" 'o caso e as asserções vêm do mapa' "plano-mapa/1 execute: teste nasce do mapa"
```

- [ ] **2. Ver falhar** — `bash tests/test-plano-mapa.sh; echo "exit=$?"` → 9 FAIL
  `plano-mapa/…execute…` (a seção não existe), `exit=1`.
- [ ] **3. Implementar** — `skills/execute/SKILL.md`:
  - Linha 27, RED: `escrever UM teste mínimo do comportamento (nome claro citando o`
    → `escrever UM teste mínimo do comportamento (o caso e as asserções vêm do mapa; nome claro citando o`
    (quebrar a linha longa onde couber — o assert usa `flat`).
  - Seção nova entre o fim do Fluxo (linha 59) e `## Quando algo dá errado`,
    exatamente (rascunho: 873 bytes):

```markdown
## Localização de código

1. **Mapa**: ao começar a tarefa, ler os trechos que o mapa aponta.
   Arquivo com mais de 200 linhas é lido pelo trecho, nunca inteiro.
2. **Fora do mapa**: buscar o símbolo e ler só o trecho apontado.
3. **Ligações**: a mudança toca import, herança, registro ou configuração →
   seguir a ligação e ler o trecho ligado, mesmo fora do mapa.
4. **Orçamento**: na 3ª leitura fora do mapa na mesma tarefa,
   acrescentar ao mapa do plano os `caminho:linha` lidos e seguir.
5. **Modificar arquivo fora do mapa** → parar a tarefa e voltar ao plan
   para replanejar só aquela etapa.
6. **Mapa desatualizado** (`caminho:linha` não bate): relocalizar pela
   busca do símbolo e corrigir o mapa, sem ler o arquivo inteiro.
7. **Plano no formato antigo** (código completo do teste): executar como
   está, sem pedir conversão.
```

- [ ] **4. Ver passar** — `test-plano-mapa.sh` → `FAIL=0`, `exit=0`;
  `bash tests/test-contexto-por-fase.sh` → `FAIL=0` (asserts de execute
  intactos); `bash tests/test-carga.sh` → `base=` ≤ 47800; gate → `exit=0`.
- [ ] **5. Commit** — `git add skills/execute/SKILL.md tests/test-plano-mapa.sh && git commit -m "feat(plano-mapa/5-11): execute localiza código por trecho — mapa, símbolo, ligações, orçamento de 3 leituras, formato antigo aceito"`

---

## Tarefa 4: debug sintoma localiza como a execute

- **depende-de**: [3]
- **requisito**:
  - **plano-mapa/12** — QUANDO o debug rodar em modo sintoma O SISTEMA DEVE seguir a mesma localização da execute (/5, /6, /7, /10); o modo caçada continua sendo varredura por classes.
- **decisões relevantes**: modo caçada fora de escopo (intocado); regras
  inline + teste de mesma frase nos dois arquivos (Decisão da IA 2). O debug
  não está na carga BASE.
- **interfaces**: consome `flat` (T1) e as frases da seção
  `## Localização de código` (T3).
- **arquivos**:
  - Modificar: `skills/debug/SKILL.md:26-30` (passo 2 do modo sintoma)
  - Teste: `tests/test-plano-mapa.sh`
- **done quando**: `test-plano-mapa.sh` exit 0; gate `exit=0`.

- [ ] **1. Escrever o teste que falha** — antes do `report`:

```bash
# --- /12 — debug sintoma localiza como a execute (mesmas frases); caçada segue varredura ---
for par in "skills/execute/SKILL.md|## Localização de código" "skills/debug/SKILL.md|## Modo sintoma"; do
  f="${par%%|*}"; h="${par#*|}"; t="$(flat "$f" "$h")"
  for s in 'mais de 200 linhas é lido pelo trecho, nunca inteiro' 'buscar o símbolo e ler só o trecho apontado' \
           'seguir a ligação e ler o trecho ligado' 'relocalizar pela busca do símbolo'; do
    assert_contains "$t" "$s" "plano-mapa/12 $f ($h) tem '$s'"
  done
done
dc="$(flat skills/debug/SKILL.md '## Modo caçada (sem sintoma)')"
assert_contains "$dc" 'Varredura por classes de defeito' "plano-mapa/12 caçada continua varredura por classes"
assert_not_contains "$dc" 'mais de 200 linhas' "plano-mapa/12 caçada sem regra de trecho"
```

- [ ] **2. Ver falhar** — `bash tests/test-plano-mapa.sh; echo "exit=$?"` →
  4 FAIL `plano-mapa/12 skills/debug/SKILL.md (## Modo sintoma)…`, `exit=1`.
  Os 4 da execute e os 2 da caçada passam de primeira: são guarda de não-
  regressão (a execute já foi feita em T3; a caçada não muda).
- [ ] **3. Implementar** — `skills/debug/SKILL.md`, passo 2 do modo sintoma
  (26-30) passa a ser exatamente:

```markdown
2. **Evidência completa.** Ler a MENSAGEM DE ERRO INTEIRA e o stack trace até
   o fim. Ler o código do caminho que falha — o que ele faz, não o que você
   lembra que fazia — localizando como a execute: arquivo com mais de 200
   linhas é lido pelo trecho, nunca inteiro; fora do plano, buscar o símbolo
   e ler só o trecho apontado; a mudança toca import, herança, registro ou
   configuração → seguir a ligação e ler o trecho ligado; `caminho:linha` que
   não bate → relocalizar pela busca do símbolo. Diff recente
   (`git log -p` / `git diff`) se o defeito é novo: o que mudou desde que
   funcionava?
```

- [ ] **4. Ver passar** — `test-plano-mapa.sh` → `FAIL=0`, `exit=0`; gate → `exit=0`.
- [ ] **5. Commit** — `git add skills/debug/SKILL.md tests/test-plano-mapa.sh && git commit -m "feat(plano-mapa/12): debug em modo sintoma localiza como a execute; caçada intocada"`

---

## Tarefa 5: READMEs e fundamentos descrevem o mapa

- **depende-de**: [2, 3, 4]
- **requisito**: documentação de /1, /5 e /12 (Decisão da IA 4 — sem
  critério próprio; a descrição atual do plano ficaria falsa).
- **decisões relevantes**: README EN é o principal, PT linkado; blocos de
  código idênticos EN/PT (`test-docs.sh`: só blocos cercados — as mudanças
  são prosa com código inline); `PRD.md` não é tocado.
- **interfaces**: consome `flat` (T1).
- **arquivos**:
  - Modificar: `README.md:170-179` (plan), `README.md:189-190` (execute),
    `README.md:253-254` (debug); `README.pt-BR.md:171-180`, `:190-191`,
    `:255`; `docs/fundamentos.md:83-85` (regra 1) e `:93-96` (regra 3).
  - Teste: `tests/test-plano-mapa.sh`
- **done quando**: `test-plano-mapa.sh` e `test-docs.sh` exit 0; gate `exit=0`.

- [ ] **1. Escrever o teste que falha** — antes do `report`:

```bash
# --- /1 /5 /12 — docs descrevem o mapa e a leitura por trecho ---
en="$(flat README.md)"; pt="$(flat README.pt-BR.md)"; fu="$(flat docs/fundamentos.md)"
assert_contains "$en" 'Each task is a map' "plano-mapa/1 README EN: tarefa é mapa"
assert_not_contains "$en" 'full TEST code' "plano-mapa/1 README EN sem teste completo"
assert_contains "$pt" 'Cada tarefa é um mapa' "plano-mapa/1 README PT: tarefa é mapa"
assert_not_contains "$pt" 'código completo do TESTE' "plano-mapa/1 README PT sem teste completo"
assert_contains "$en" 'Reads code by snippet' "plano-mapa/5 README EN: execute lê por trecho"
assert_contains "$pt" 'Lê código por trecho' "plano-mapa/5 README PT: execute lê por trecho"
assert_contains "$en" 'Symptom mode locates code like `execute`' "plano-mapa/12 README EN: debug localiza como execute"
assert_contains "$pt" 'O modo sintoma localiza código como a `execute`' "plano-mapa/12 README PT: debug localiza como execute"
assert_contains "$fu" 'A tarefa é mapa' "plano-mapa/1 fundamentos P2: tarefa é mapa"
```

- [ ] **2. Ver falhar** — `bash tests/test-plano-mapa.sh; echo "exit=$?"` → 9 FAIL
  `plano-mapa/…README…|fundamentos…`, `exit=1`.
- [ ] **3. Implementar** — textos exatos (quebrar linha livremente; o assert usa `flat`):
  - `README.md` plan: trocar "Steps carry the full TEST code, exact
    signatures and commands; implementation code only when it is not obvious
    (algorithm, regex, SQL, exact format)." por "Each task is a map: criterion
    → test case → `path:line` of the change point, the snippets to read
    (`path:start-end`) and, when the criterion leaves the value open, the
    exact `input → expected output`; test and implementation code are
    written in `execute`. A broad question goes to an exploration subagent
    that returns `path:line`, checked by reading."
  - `README.pt-BR.md` plan: trocar "Os passos levam o código completo do
    TESTE, assinaturas e comandos exatos; código de implementação só quando
    não é óbvio (algoritmo, regex, SQL, formato exato)." por "Cada tarefa é
    um mapa: critério → caso de teste → `caminho:linha` do ponto de mudança,
    os trechos a ler (`caminho:início-fim`) e, quando o critério deixa o
    valor aberto, a asserção exata `entrada → saída esperada`; o código do
    teste e o da implementação nascem na `execute`. Pergunta ampla vai para
    um subagente de exploração que devolve `caminho:linha`, conferido por
    leitura."
  - `README.md` execute, depois de "whose dependencies are done.": "Reads
    code by snippet: what the map points to (a file over 200 lines is never
    read whole), a symbol search outside it, and import, inheritance,
    registration or config links; the 3rd read outside the map is added to
    it, and modifying a file outside the map goes back to `plan`."
  - `README.pt-BR.md` execute, depois de "com as dependências concluídas.":
    "Lê código por trecho: o que o mapa aponta (arquivo com mais de 200
    linhas nunca inteiro), busca do símbolo fora dele e ligações de import,
    herança, registro ou configuração; a 3ª leitura fora do mapa entra nele,
    e modificar arquivo fora do mapa volta ao `plan`."
  - `README.md` debug, depois de "fix via TDD.": "Symptom mode locates code
    like `execute` — by snippet, symbol search and links."
  - `README.pt-BR.md` debug, depois de "fix via TDD.": "O modo sintoma
    localiza código como a `execute` — por trecho, busca do símbolo e ligações."
  - `docs/fundamentos.md` regra 1: "(2) ler os arquivos que o plano vai
    tocar" → "(2) ler por trecho o que o plano vai tocar, listando cada
    leitura como `caminho:início-fim`"; regra 3, ao fim: "A tarefa é mapa
    (critério → caso de teste → `caminho:linha`, com a asserção exata quando
    o critério deixa o valor aberto); o código nasce na execute."
- [ ] **4. Ver passar** — `test-plano-mapa.sh` → `FAIL=0`; `bash tests/test-docs.sh`
  → `FAIL=0` (blocos EN/PT idênticos, 5 rótulos por skill); gate → `exit=0`.
- [ ] **5. Commit** — `git add README.md README.pt-BR.md docs/fundamentos.md tests/test-plano-mapa.sh && git commit -m "docs(plano-mapa/1,5,12): READMEs EN/PT e fundamentos descrevem o plano-mapa e a leitura por trecho"`

---

## Tarefa 6: versão 0.12.0 e carga medida

- **depende-de**: [1, 2, 3, 4, 5]
- **requisito**:
  - **plano-mapa/14** — QUANDO a suíte rodar O SISTEMA DEVE manter a carga BASE e FULL do `test-carga` dentro dos tetos atuais (48000 / 53400 bytes).
  - **plano-mapa/15** — QUANDO o plugin for reinstalado O SISTEMA DEVE declarar a versão `0.12.0` em `plugin.json` e `marketplace.json`.
- **decisões relevantes**: bump `0.12.0` (IA, aprovada); tetos NÃO sobem;
  asserts de versão trocados, não apagados (Decisão da IA 5); medição da
  carga no nó, seção `## medicao` (precedente do `corte-sem-uso`).
- **interfaces**: consome `flat` (T1).
- **arquivos**:
  - Modificar: `.claude-plugin/plugin.json:4`, `.claude-plugin/marketplace.json:9`,
    `tests/test-docs.sh:7`, `tests/test-corte-sem-uso.sh:49,51`,
    `tests/test-carga.sh:6` (comentário), `docs/audora/memory/plano-mapa.md`
    (seção `## medicao` nova, entre `## decisoes` e `## delta`)
  - Teste: `tests/test-plano-mapa.sh`
- **done quando**: `test-plano-mapa.sh` exit 0; gate `exit=0`; `## medicao`
  no nó com a carga BASE/FULL antes → depois.

- [ ] **1. Escrever o teste que falha** — antes do `report`:

```bash
# --- /14 /15 — tetos de carga intactos; versão 0.12.0 ---
tc="$(tr -d '\r' < tests/test-carga.sh)"
assert_contains "$tc" 'TETO_BASE=48000' "plano-mapa/14 teto BASE intacto"
assert_contains "$tc" 'TETO_FULL=53400' "plano-mapa/14 teto FULL intacto"
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  assert_contains "$(tr -d '\r' < "$j")" '"version": "0.12.0"' "plano-mapa/15 $j declara 0.12.0"
  assert_not_contains "$(tr -d '\r' < "$j")" '"version": "0.11.0"' "plano-mapa/15 $j sem 0.11.0"
done
```

  E trocar (mesmo nº de asserts):
  - `tests/test-docs.sh:7` → `  assert_contains "$(cat "$j")" '"version": "0.12.0"' "plano-mapa/15 $j versão 0.12.0"`
  - `tests/test-corte-sem-uso.sh:49` → `# --- /10 versão: 0.11.0 superada pela 0.12.0 (plano-mapa/15); 0.10.0 segue fora ---`
  - `tests/test-corte-sem-uso.sh:51` → `  assert_contains "$(tr -d '\r' < "$j")" '"version": "0.12.0"' "plano-mapa/15 $j declara 0.12.0 (substitui corte-sem-uso/10)"`
- [ ] **2. Ver falhar** — `bash tests/test-plano-mapa.sh; echo "exit=$?"` → 4 FAIL
  `plano-mapa/15 …` (os 2 de /14 passam: guarda de teto), `exit=1`;
  `test-docs.sh` e `test-corte-sem-uso.sh` → 2 FAIL cada.
- [ ] **3. Implementar** — `"version": "0.11.0"` → `"version": "0.12.0"` nos 2
  manifests. Rodar `bash tests/test-carga.sh`, anotar `base`/`full` e:
  - `tests/test-carga.sh:6`: acrescentar ao fim da linha de medição
    `; plano-mapa: BASE 46575 → <base> / FULL 51815 → <full>`.
  - Nó `plano-mapa.md`, seção nova `## medicao` (entre `## decisoes` e
    `## delta`): `Carga estática (blobs LF, test-carga): BASE 46575 → <base>, FULL 51815 → <full>; tetos 48000 / 53400 intactos.`
    (o hook `memory-validate` roda na escrita — ler a saída; exit 2 = corrigir).
- [ ] **4. Ver passar** — gate completo:
  `bash hooks/gate plano-mapa > "$SCRATCH/gate.log" 2>&1; echo "exit=$?"` →
  `GATE: passou`, `exit=0`. Somar asserts da saída real:
  `grep -o 'PASS=[0-9]*' "$SCRATCH/gate.log" | cut -d= -f2 | paste -sd+ | bc`
  e anotar nas notas de sessão (sem total de cabeça — aprendizado 60).
- [ ] **5. Commit** — `git add .claude-plugin/plugin.json .claude-plugin/marketplace.json tests/test-docs.sh tests/test-corte-sem-uso.sh tests/test-carga.sh tests/test-plano-mapa.sh docs/audora/memory/plano-mapa.md && git commit -m "chore(plano-mapa/14,15): versão 0.12.0; carga BASE/FULL medida dentro dos tetos"`

---

## Tarefa 7: medição A/B numa fixture

- **depende-de**: [6]
- **expandir: sim** — quebrar em subtarefas quando chegar a vez (fixture,
  4 sessões `claude -p`, extração, registro).
- **requisito**:
  - **plano-mapa/13** — QUANDO a demanda fechar O SISTEMA DEVE registrar no nó a medição A/B da mesma demanda numa fixture, planejada com o plugin 0.11.0 e com o novo (`claude -p`): linhas e bytes de cada plano, tokens da sessão de execute de cada um, e a execute do plano novo chegando ao verde da suíte da fixture. Sem meta numérica.
- **decisões relevantes**: sem meta numérica, só medir e reportar (humano);
  medir por fixture A/B, com plano, tokens da execute e verde (humano);
  Decisão da IA 6 (0.11.0 por `git archive`, fixture no scratchpad).
- **o que já está decidido para a expansão**:
  - Plugin A: `mkdir -p "$SCRATCH/plugin-0.11.0" && git archive c23e00a | tar -x -C "$SCRATCH/plugin-0.11.0"`.
    Plugin B: este repo no HEAD da branch `plano-mapa` depois de T6.
  - Fixture: script `fixture-mapa.sh <dir>` no scratchpad (não versionado;
    receita-base em `docs/audora/e2e/e2e-corte-sem-uso.md:13-20`): `git init -b main`,
    `core.excludesFile` inexistente, projeto bash com um arquivo de mais de
    200 linhas (para a leitura por trecho contar), `tests/run.sh` verde,
    `MEMORY.md` `memory-schema: 1` com `gate: recusado`, e um nó `in-progress`
    MEDIUM com escopo aprovado — ≥ 1 critério de erro que deixa o valor
    aberto (exercita /2). Duas cópias idênticas: `fx-a`, `fx-b`.
  - Sessões (`~/.local/bin/claude.exe`, em background, saída para arquivo
    lido inteiro, nunca `| tail`), cada uma com
    `--plugin-dir <A|B> --settings '{"enabledPlugins":{"audora-commander@audora-commander-dev":false}}' --permission-mode acceptEdits --output-format stream-json --verbose > X.jsonl 2> X.err`:
    `plan de <id>` em `fx-a` com A e em `fx-b` com B; commit do plano na
    fixture; depois `execute de <id>` em sessão NOVA (sem `--resume`) em cada uma.
  - Tokens: do evento `"type":"result"` de cada `.jsonl` da execute:
    `usage.input_tokens`, `usage.cache_creation_input_tokens`,
    `usage.cache_read_input_tokens`, `usage.output_tokens` e `total_cost_usd`.
  - Plano: `wc -l` e `tr -d '\r' < plano | wc -c` de
    `docs/audora/planos/plano-<id>.md` em cada fixture.
  - Verde: `bash tests/run.sh; echo "exit=$?"` em `fx-b` depois da execute → `exit=0`
    (em `fx-a` também é registrado, sem exigência).
- **arquivos**: Modificar `docs/audora/memory/plano-mapa.md` (`## medicao`:
  tabela A/B e a receita em 3-5 linhas). Nenhum arquivo do plugin muda.
- **done quando**: `## medicao` do nó tem linhas e bytes dos 2 planos, os
  tokens das 2 execute e o `exit=0` da suíte de `fx-b`; gate `exit=0`;
  commit `docs(plano-mapa/13): medição A/B …`.
