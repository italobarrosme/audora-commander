---
id: evals-comportamento
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [eval, plugin-eval, comportamento, mutacao, metrica, custo]
resumo: Provar comportamento das skills com claude plugin eval e mutação de regra, no lugar de guarda de texto.
atualizado-em: 2026-10-09
---

# evals-comportamento

## objetivo

Ter uma suíte de evals de comportamento (`claude plugin eval`, com e sem o
plugin) que prova que as regras críticas das skills mudam o que o modelo faz,
e uma mutação de regra que mostra qual regra é peso morto — régua para
encolher e endurecer o framework sem medir por sensação.

Origem: grupo B do estudo `docs/study/2026-10-09-estudo-aprimoramento.md`
(local). Categoria: MEDIUM (nenhuma pergunta de risco SIM; vários arquivos).

## criterios-aceite

- **evals-comportamento/1** — QUANDO o humano roda o comando de evals em
  modo rápido O SISTEMA DEVE rodar cada caso 1 vez com o plugin e imprimir,
  por caso, passou/reprovou com o motivo, custo e tokens, mais o total da
  rodada
- **evals-comportamento/2** — QUANDO o humano roda em modo completo O SISTEMA
  DEVE rodar cada caso 3 vezes com o plugin e 3 sem, aprovar o caso só se as
  3 com o plugin passarem e mostrar a taxa sem o plugin e a diferença
- **evals-comportamento/3** — QUANDO o caso `porta` roda (pedido de mudança
  num projeto com MEMORY) O SISTEMA DEVE reprovar se a skill de entrada não
  for a primeira skill invocada, se a categoria anunciada não for a esperada
  pelo caso ou se a fase seguinte não for a da tabela de roteamento
- **evals-comportamento/4** — QUANDO o caso `escopo-antes` roda (pedido
  MEDIUM ou HIGH) O SISTEMA DEVE reprovar se algum arquivo fora de
  `MEMORY.md` e `docs/audora/` for criado ou editado antes de o nó ter
  critérios
- **evals-comportamento/5** — QUANDO o caso `memoria` roda O SISTEMA DEVE
  reprovar se o nó da demanda não tiver ao menos 1 critério `<id>/<n>` em
  EARS (`QUANDO … O SISTEMA DEVE …`) ou se um aprendizado for escrito no
  `MEMORY.md` em vez de `docs/audora/aprendizados.md`
- **evals-comportamento/6** — QUANDO o caso `tdd` roda (execute de demanda
  LIGHT numa fixture com suíte) O SISTEMA DEVE reprovar se o transcript não
  mostrar, nesta ordem: teste novo escrito → teste rodado falhando → código
  editado → teste rodado passando
- **evals-comportamento/7** — QUANDO qualquer caso roda O SISTEMA DEVE
  executá-lo numa fixture temporária fora do repo, sem a configuração pessoal
  do usuário (CLAUDE.md global, outros plugins), e deixar o repo do plugin
  com o `git status` idêntico ao de antes; se o isolamento não puder ser
  garantido, DEVE recusar o caso com o motivo
- **evals-comportamento/8** — QUANDO o custo acumulado da rodada passa o teto
  (padrão US$ 10, configurável) O SISTEMA DEVE parar antes do próximo run,
  marcar os casos restantes como `não rodado: teto` e sair com código
  diferente do de reprovação
- **evals-comportamento/9** — QUANDO um run falha por infraestrutura (claude
  ausente ou abaixo da versão mínima, sem autenticação, timeout, erro de API)
  O SISTEMA DEVE marcar `erro de infra` com a causa, separado de reprovado, e
  nunca contar o run como aprovado
- **evals-comportamento/10** — QUANDO o humano pede a mutação de uma regra
  coberta por um caso O SISTEMA DEVE rodar esse caso com uma cópia da skill
  sem a regra, reportar a taxa com e sem a regra e marcar `sem efeito` quando
  a taxa não cair — sem alterar a skill do repo e sem cortar nada
- **evals-comportamento/11** — QUANDO a rodada termina O SISTEMA DEVE sair 0
  só se todos os casos rodados passaram e nenhum ficou em erro de infra
- **evals-comportamento/12** — QUANDO `bash tests/run.sh` roda O SISTEMA DEVE
  terminar sem invocar `claude` nem nenhum caso de eval
- **evals-comportamento/13** — QUANDO a demanda é entregue O SISTEMA DEVE ter,
  para cada caso, uma rodada registrada em que ele REPROVA numa condição
  conhecida como ruim (regra removida ou plugin desligado) — caso que nunca
  reprova não prova nada

## fora-de-escopo

Trocar ou reescrever a suíte bash `tests/` existente; rodar evals em CI ou
dentro de `tests/run.sh`; telemetria nos projetos que usam o plugin
(candidata separada); casos além dos 4 comportamentos escolhidos; corte
automático de regra; juiz LLM como grader (só checagens determinísticas sobre
transcript e arquivos nesta versão); WSL2.

## decisoes

2026-10-09, todas do humano (alternativa descartada entre parênteses):
- cobertura = porta, escopo-antes, memória, TDD (nenhuma descartada);
- manual, comando próprio (dentro de `tests/run.sh`: custo; obrigatório no bump);
- mutação gera relatório, humano corta (reprovar regra; outro nó);
- teto por rodada US$ 10 + custo no relatório (só mostrar; ignorar; 5; 20);
- TDD por harness próprio `claude -p` em fixture (WSL2; pular sem sandbox);
- rápido 1x, completo 3x passa com 3/3 (maioria 2/3; sempre 3x);
- comparação sem plugin só no completo (sempre: dobra custo; nunca).

## delta

## e2e

pendente

## feedback-reprovacao
