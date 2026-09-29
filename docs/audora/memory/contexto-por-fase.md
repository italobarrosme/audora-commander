---
id: contexto-por-fase
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [contexto, clear, fase, tokens, parada]
resumo: Toda fase termina e para, mandando /clear e o comando de retomada, sem emendar a fase seguinte na mesma sessão.
atualizado-em: 2026-09-28
---

# contexto-por-fase

## objetivo

Cortar o custo de token dominante: a demanda inteira numa sessão só (medido
em 2026-09-28: contexto 60k → 450–705k, 56–116M de cache read por demanda).
Nas fronteiras de fase MEDIUM/HIGH a fase PARA com `/clear` + comando de
retomada; "segue" roda a fase seguinte em subagente de contexto zerado.

## criterios-aceite

- **contexto-por-fase/1** — QUANDO uma fase scope, plan ou execute de demanda
  MEDIUM ou HIGH (fora de autopilot) termina, com o portão aprovado quando
  houver, O SISTEMA DEVE encerrar a resposta com o bloco de fechamento cujo
  **Próximo** é a PARADA — instrução de `/clear` mais o comando de retomada
  exato (`<fase> de <id>`) — e NÃO iniciar a fase seguinte na mesma resposta.
- **contexto-por-fase/2** — QUANDO a porta de entrada termina de classificar
  a demanda O SISTEMA DEVE emendar na primeira fase na mesma sessão, sem
  parada.
- **contexto-por-fase/3** — QUANDO a demanda é LIGHT ou HOTFIX O SISTEMA DEVE
  percorrer execute → validate na mesma sessão, sem parada.
- **contexto-por-fase/4** — QUANDO a validate chama o e2e O SISTEMA DEVE
  voltar à validate com o relatório na mesma sessão, sem parada.
- **contexto-por-fase/5** — QUANDO, na parada, o humano pede para seguir sem
  `/clear` ("segue", "continua", "sem clear") O SISTEMA DEVE rodar a fase
  seguinte num subagente de contexto zerado e devolver à sessão principal só
  o bloco de fechamento dessa fase.
- **contexto-por-fase/6** — QUANDO a fase rodada em subagente tem portão
  humano (plano HIGH, portão final da validate) O SISTEMA DEVE apresentar o
  portão na sessão principal e esperar a decisão explícita do humano — o
  subagente prepara, nunca aprova.
- **contexto-por-fase/7** — QUANDO a fase em subagente precisa de input
  humano no meio (requisito faltante, `[PRECISA-CLARIFICAR]`, falha
  irrecuperável) O SISTEMA DEVE encerrar o subagente devolvendo a pergunta ou
  o diagnóstico à sessão principal, que pergunta ao humano — nunca supor a
  resposta.
- **contexto-por-fase/8** — QUANDO uma fase começa em sessão nova (depois do
  `/clear` ou em subagente) O SISTEMA DEVE se reancorar só pelos artefatos em
  disco (`MEMORY.md`, nó, plano, relatório), sem depender da conversa
  anterior.
- **contexto-por-fase/9** — QUANDO o comando de retomada cita id inexistente
  ou fase fora de ordem (ex.: `execute de <id>` MEDIUM sem plano-arquivo) O
  SISTEMA DEVE recusar nomeando o artefato que falta e apontar a fase certa.
- **contexto-por-fase/10** — QUANDO a demanda MEDIUM está em autopilot
  elegível O SISTEMA DEVE percorrer scope → plan → execute → validate sem
  parada, rodando a execute pelo motor de loop (`hooks/loop <id>`).
- **contexto-por-fase/11** — QUANDO, em autopilot, o motor recusa a rodada
  por pré-condição faltando O SISTEMA DEVE avisar em 1 linha o que faltou e
  rodar a execute em subagente(s) de contexto zerado, seguindo o autopilot
  sem parada.
- **contexto-por-fase/12** — QUANDO a fase termina interrompida, bloqueada ou
  com portão reprovado O SISTEMA DEVE manter como **Próximo** a decisão
  humana pendente, sem comando de retomada de fase seguinte.
- **contexto-por-fase/13** — QUANDO a suíte roda O SISTEMA DEVE reprovar se
  scope, plan ou execute deixar de instruir a parada, ou se o template de
  fechamento voltar a tratar o `/clear` como mera recomendação.

## fora-de-escopo

`/clear` automático literal (o Claude Code não expõe esse primitivo a hook,
skill ou ferramenta — confirmado na doc em 2026-09-28); retomada automática
pelo SessionStart e campo novo `fase:` no nó; mudar o motor de loop em si (só
passa a ser invocado); skills-ferramenta (`memory`, `worktree`) e `debug`, que
devolvem à fase chamadora; leitura por seção (`leitura-por-secao`) e limpeza
(`skill-cleanup`), cada uma com nó próprio.

## decisoes

- 2026-09-28 (humano): 3 demandas — esta, `leitura-por-secao` e
  `skill-cleanup`; mecanismo = parada dura por fase. Descartados: uma
  demanda só, fases sempre em subagente, execute sempre pelo motor.
- 2026-09-28 (humano, lote 1 do scope): sem parada em entrada → 1ª fase,
  LIGHT, HOTFIX e e2e ↔ validate; retomada pelo comando impresso
  (descartado: SessionStart sugerir, exigiria campo `fase:`).
- 2026-09-28 (humano, lotes 1-2): "segue" → fase seguinte em subagente
  limpo (o /clear automático pedido não existe no Claude Code; descartados:
  seguir na mesma sessão, recusar). Autopilot MEDIUM executa pelo motor;
  motor recusando → subagente(s) limpos (descartados: emendar inline, parar).
- 2026-09-28 (IA): MEDIUM — só comportamento das skills, sem mudar formato
  de artefato persistido.

## delta

## e2e

pendente

## feedback-reprovacao
