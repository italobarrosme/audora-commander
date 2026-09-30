---
id: plano-mapa
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [plano, mapa, localizacao, leitura, trecho, explore, tokens, contexto]
resumo: Plano vira mapa (critério → teste → caminho:linha) e plan, execute e debug ganham regra de localização de código por trecho, com medição antes e depois.
atualizado-em: 2026-09-30
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

## delta

## e2e

pendente

## feedback-reprovacao
