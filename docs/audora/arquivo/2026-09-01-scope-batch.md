---
id: scope-batch
estado: delivered
origem: humano
depende-de: []
arquivos: [MEMORY.md, PRD.md, docs/audora/planos/plano-scope-batch.md, skills/scope/SKILL.md, tests/test-skills.sh]
keywords: [scope, perguntas, wall-clock, latencia, lote]
resumo: Fase scope agrupa até 4 perguntas independentes numa mensagem em vez de uma-por-vez — o gargalo da fase é latência humana, não trabalho.
atualizado-em: 2026-08-31
---

# scope-batch

## objetivo

[scope/SKILL.md:25](../../../skills/scope/SKILL.md) manda "Nunca duas perguntas
na mesma mensagem". O wall-clock da fase vira `N perguntas × tempo de resposta
humana` — é o ponto do framework mais exposto a espera pura, e o harness já
oferece 4 perguntas de múltipla escolha numa tacada. A regra deve passar a
agrupar perguntas INDEPENDENTES, mantendo em série só as que de fato dependem
uma da outra.

## criterios-aceite

- **scope-batch/1** — QUANDO a fase scope tiver 2 ou mais esclarecimentos
  independentes entre si O SISTEMA DEVE apresentá-los num único lote, no
  máximo 4 por vez
- **scope-batch/2** — QUANDO duas perguntas forem dependentes (a resposta de
  uma muda o enunciado, as opções ou a própria existência da outra) O SISTEMA
  DEVE mantê-las em série, nunca no mesmo lote
- **scope-batch/3** — QUANDO um lote for apresentado O SISTEMA DEVE usar
  múltipla escolha com opções enumeradas sempre que as opções forem
  enumeráveis — a regra atual de preferir múltipla escolha continua valendo
- **scope-batch/4** — QUANDO uma pergunta do lote for decisão de formato ou
  layout com alternativas concretas O SISTEMA DEVE mostrar preview de cada
  alternativa em vez de descrevê-las em prosa
- **scope-batch/5** — QUANDO houver mais de 4 lacunas independentes O SISTEMA
  DEVE priorizar as que mais mudam escopo e deixar as demais para o lote
  seguinte, dizendo que há lote seguinte — nunca truncar em silêncio
- **scope-batch/6** — QUANDO o lote for respondido O SISTEMA DEVE registrar
  cada escolha como decisão no nó, uma linha por escolha, incluindo a
  alternativa descartada e por quê
- **scope-batch/7** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  reprovar se `skills/scope/SKILL.md` ainda contiver a regra antiga "Nunca
  duas perguntas na mesma mensagem"
- **scope-batch/8** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  reprovar se `skills/scope/SKILL.md` não declarar o teste de dependência
  entre perguntas (o critério que decide série vs lote)

## fora-de-escopo

Agrupar perguntas em QUALQUER outra fase — esta demanda mexe só na `scope`.
As fases plan, execute, e2e, validate e debug seguem como estão; se doer, nó
próprio. Mudar o portão humano de escopo (continua sendo aprovação explícita,
uma de cada vez). Mudar o marcador `[PRECISA-CLARIFICAR]` ou a regra de que
lacuna nunca vira suposição — o lote muda a CADÊNCIA da pergunta, nunca o
direito de não responder. Perguntar sobre "Como" (arquivos, funções, libs):
segue proibido na scope. Automatizar a escolha das perguntas por heurística
de código.

## decisoes

- 2026-08-31 (IA): teto de 4 por lote vem do limite do harness
  (`AskUserQuestion` aceita 1-4 perguntas), não de preferência — documentar
  como limite da ferramenta para não parecer número mágico.

## delta

## e2e

pulado-pelo-humano (2026-09-01, portão final)

## feedback-reprovacao
