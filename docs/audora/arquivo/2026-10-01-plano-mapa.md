---
id: plano-mapa
estado: delivered
origem: humano
depende-de: []
arquivos: [.claude-plugin/marketplace.json, .claude-plugin/plugin.json, MEMORY.md, PRD.md, README.md, README.pt-BR.md, docs/audora/decisoes-vivas.md, docs/audora/e2e/e2e-plano-mapa.md, docs/audora/planos/plano-plano-mapa.md, docs/fundamentos.md, docs/study/2026-09-30-estudo-leitura-codigo.md, skills/debug/SKILL.md, skills/execute/SKILL.md, skills/plan/SKILL.md, templates/plano-template.md, tests/test-carga.sh, tests/test-corte-sem-uso.sh, tests/test-docs.sh, tests/test-plano-mapa.sh, tests/test-skills.sh]
keywords: [plano, mapa, localizacao, leitura, trecho, explore, tokens, contexto]
resumo: Plano vira mapa (critério → teste → caminho:linha) e plan, execute e debug ganham regra de localização de código por trecho, com medição antes e depois.
atualizado-em: 2026-10-01
---

# plano-mapa

## objetivo

Reduzir a maior carga de contexto do framework: planos com mediana de 694 linhas (133 planos), relidos em cada execute. A tarefa do plano passa a apontar critério → caso de teste → `caminho:linha`, e o código nasce na execute. plan, execute e debug ganham uma regra de localização por trecho, que substitui o "nunca varrer o repo". Base: [estudo de 2026-09-30](../../study/2026-09-30-estudo-leitura-codigo.md). Ler por trecho vence ler o arquivo inteiro; contexto faltante é a falha dominante; o subagente devolve `caminho:linha`, que o agente principal confere; o índice de código não volta.

## criterios-aceite

**Plano vira mapa (plan)**

- **plano-mapa/1** — QUANDO o plan escrever uma tarefa O SISTEMA DEVE registrar o requisito (`<id>/<n>`), o ponto de mudança (`caminho:linha`), o arquivo e o caso de teste, os trechos a ler (`caminho:início-fim`) e o done — sem o corpo do teste nem o da implementação.
- **plano-mapa/2** — QUANDO o critério não fixar o valor exato esperado (formato, ordem, mensagem, código de saída, borda) O SISTEMA DEVE incluir na tarefa a asserção exata `entrada → saída esperada` de cada caso.
- **plano-mapa/3** — QUANDO o plan ler código antes de planejar O SISTEMA DEVE listar no cabeçalho do plano cada leitura como `caminho:início-fim`, com o que foi relevante nela.
- **plano-mapa/4** — QUANDO o plan precisar responder pergunta ampla sobre código que não conhece O SISTEMA DEVE delegar a um subagente de exploração com pergunta delimitada que devolve `caminho:linha`, e conferir o trecho por leitura própria antes de gravar no mapa.

**Localização de código (execute)**

- **plano-mapa/5** — QUANDO a execute começar uma tarefa O SISTEMA DEVE ler os trechos que o mapa aponta; arquivo com mais de 200 linhas é lido pelo trecho, nunca inteiro.
- **plano-mapa/6** — QUANDO a execute precisar de código fora do mapa O SISTEMA DEVE localizá-lo por busca do símbolo e ler só o trecho apontado.
- **plano-mapa/7** — QUANDO a mudança tocar import, herança, registro ou configuração O SISTEMA DEVE seguir essa ligação e ler o trecho ligado, mesmo fora do mapa.
- **plano-mapa/8** — QUANDO ocorrer a 3ª leitura fora do mapa na mesma tarefa O SISTEMA DEVE acrescentar ao mapa do plano os `caminho:linha` lidos e seguir a tarefa.
- **plano-mapa/9** — QUANDO a execute precisar MODIFICAR arquivo fora do mapa O SISTEMA DEVE parar a tarefa e voltar ao plan para replanejar só aquela etapa.
- **plano-mapa/10** — QUANDO o `caminho:linha` do mapa não bater com o código (arquivo mudou, linha deslocada) O SISTEMA DEVE relocalizar por busca do símbolo e corrigir o mapa, sem ler o arquivo inteiro.
- **plano-mapa/11** — QUANDO a execute receber plano no formato antigo (código completo do teste) O SISTEMA DEVE executá-lo sem pedir conversão.

**debug**

- **plano-mapa/12** — QUANDO o debug rodar em modo sintoma O SISTEMA DEVE seguir a mesma localização da execute (/5, /6, /7, /10); o modo caçada continua sendo varredura por classes.

**Medição e guarda**

- **plano-mapa/13** — QUANDO a demanda fechar O SISTEMA DEVE registrar no nó a medição A/B da mesma demanda numa fixture, planejada com o plugin 0.11.0 e com o novo (`claude -p`): linhas e bytes de cada plano, tokens da sessão de execute de cada um, e a execute do plano novo chegando ao verde da suíte da fixture. Sem meta numérica.
- **plano-mapa/14** — QUANDO a suíte rodar O SISTEMA DEVE manter a carga BASE e FULL do `test-carga` dentro dos tetos atuais (48000 / 53400 bytes).
- **plano-mapa/15** — QUANDO o plugin for reinstalado O SISTEMA DEVE declarar a versão `0.12.0` em `plugin.json` e `marketplace.json`.

## fora-de-escopo

Índice de código de qualquer tipo; converter planos antigos já existentes nos projetos; PRD-foto e critério de parada da revisão adversarial (demanda 3 do estudo); a régua de categoria; leitura por seção de PRD e MEMORY (nó `leitura-por-secao`); o modo caçada do debug; as skills scope, e2e e validate (não exploram código cru).

## decisoes

- 2026-09-30 (IA): MEDIUM — sem dado persistido, contrato de terceiros, auth ou efeito irreversível; o formato do plano é artefato interno e o antigo continua executável.
- 2026-09-30 (humano): a regra de localização vale para plan, execute e debug.
- 2026-09-30 (humano): demanda cancelada e retomada no mesmo dia, depois que o estudo virou `docs/study/2026-09-30-estudo-leitura-codigo.md`.
- 2026-09-30 (humano): tarefa é mapa com asserção. Descartados: "mapa puro" (deixa a borda para adivinhar) e "atual + caminho:linha" (ganho pequeno).
- 2026-09-30 (humano): medir por fixture A/B, com plano, tokens da execute e verde. Descartados: "só tamanho" (não prova que a execute aguenta) e "histórico + fixture" (mais caro).
- 2026-09-30 (humano): orçamento de 3 leituras fora do mapa → anota no mapa e segue; volta ao plan só para modificar arquivo fora do mapa. Descartados: voltar ao plan na 3ª leitura; sem número.
- 2026-09-30 (humano): sem meta numérica, só medir e reportar. Descartados: ≥ 40% e ≥ 60%.
- 2026-09-30 (IA): /1 substitui o critério `otimizacao-tokens/5` ("código completo do TESTE" no plano); o assert de `tests/test-skills.sh:178` é trocado, não apagado.
- 2026-09-30 (IA): limiar de "arquivo grande" (/5) = 200 linhas, o dobro da janela de 100 linhas que o SWE-agent mediu como melhor.
- 2026-09-30 (IA): bump para `0.12.0` — o formato do plano muda e o antigo continua aceito (/11).
- 2026-09-30 (humano): escopo aprovado ("aprovado") — confirma as 3 decisões da IA (substituir `otimizacao-tokens/5`, limiar de 200 linhas, `0.12.0`).
- 2026-10-01 (humano): portão final APROVADO ("aprovado"). e2e: 12 critérios passaram, /3 passou com ressalva e /4 e /8 tiveram validação humana pelo texto das skills. Ressalvas aceitas como estão: o plan pode ler arquivo inteiro (/3 exige só o header por trecho), e a execute ficou +3,7% mais cara em n=1. Decisão viva aprovada como proposta: medir por A/B numa fixture `claude -p`, sem meta numérica.

## medicao

Carga estática (blobs LF, test-carga): BASE 46575 → 47719, FULL 51815 → 52959; tetos 48000 / 53400 intactos.

A/B de 2026-09-30 (/13), com a mesma demanda `slug` (4 critérios EARS; `lib/texto.sh` com 232 linhas) em duas cópias da fixture. A = plugin 0.11.0 (`git archive c23e00a`); B = esta branch. As sessões são `claude -p` com `--plugin-dir` e o plugin instalado desligado. Tokens e custo saem do evento `result`.

| | A (0.11.0) | B (mapa) | B/A |
|---|---|---|---|
| plano: linhas / bytes | 200 / 9812 | 145 / 7724 | −27,5% / −21,3% |
| sessões de plan (2 turnos): cache_read / output / US$ | 1.135.265 / 20.696 / 2,14 | 662.364 / 15.832 / 1,81 | −41,7% / −23,5% / −15,4% |
| execute: turnos / cache_read / output / US$ | 30 / 965.958 / 9.285 / 0,80 | 34 / 1.133.634 / 9.949 / 0,83 | +13% / +17,4% / +7,2% / +3,7% |
| leitura de `lib/texto.sh` na execute | arquivo inteiro (232 l.) | 3 trechos (95 l.) | −59% |
| verde da suíte da fixture | 35/35, exit 0 | 36/36, exit 0 | as duas verdes |

Leitura: o plano encolheu e a execute leu por trecho, como pedem /1 e /5. Mas o custo da execute não caiu; subiu um pouco, porque a execute B escreveu os testes que o plano A trazia prontos. É n=1, numa demanda pequena, e a diferença de ±4% está dentro do ruído de uma rodada só. As duas sessões de plan pararam na mesma divergência da fixture (convenção × nó), e as duas escolheram A no 2º turno. Artefatos: scratchpad da sessão (`plan-*.jsonl`, `exec-*.jsonl`, `fx-a`, `fx-b`).

## delta

## e2e

2026-10-01: [relatório](../e2e/e2e-plano-mapa.md). 4 cenários `claude -p` com `--plugin-dir` (E1c formato antigo, E2 mapa deslocado, E3 modificar fora do mapa, E4 debug sintoma). 12 critérios passaram, /3 passou com ressalva e /4 e /8 são não-automatizáveis (validação humana).

## feedback-reprovacao
