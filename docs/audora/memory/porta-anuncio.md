---
id: porta-anuncio
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [porta, anuncio, categoria, eval]
resumo: Porta de entrada sempre anuncia a categoria com o porquê e o convite à correção, provado pelo eval porta.
atualizado-em: 2026-10-12
---

# porta-anuncio

## objetivo

Fazer a porta de entrada sempre anunciar "Demanda classificada como [X]
porque … — me corrija se discordar" antes de rotear, até o eval `porta`
passar com o plugin e reprovar sem ele. Origem: e2e do
`evals-comportamento` (2026-10-10/11), porta 0/3 com o plugin. Reaberturas
(2026-10-12): hook recusa o registro sem anúncio; a narração (resumo da
prosa que o servidor põe no lugar dela) conta, por sentido.

## criterios-aceite

- **porta-anuncio/1** — QUANDO a porta de entrada classifica uma demanda O
  SISTEMA DEVE escrever ao humano, antes de registrar o nó, uma frase própria
  `Demanda classificada como <CATEGORIA> porque <respostas às perguntas de
  risco> — me corrija se discordar`
- **porta-anuncio/2** — QUANDO o caso `porta` roda O SISTEMA DEVE reprovar se
  nenhum bloco do assistente tiver o anúncio MEDIUM — em texto: `classificada
  como MEDIUM`, `porque` e `me corrija`; em narração: `classific…` seguido de
  `como MEDIUM`, depois `me corrija` ou `me avise` e `discordar` —, ou se o
  anúncio vier depois da primeira escrita no `MEMORY.md` ou no arquivo do nó
- **porta-anuncio/3** — QUANDO o trace do caso `porta` tem o modelo do
  anúncio só no texto da skill carregada (`[X]`, `[respostas às perguntas]`)
  e não numa resposta do assistente O SISTEMA DEVE reprovar o caso
- **porta-anuncio/4** — QUANDO `bash tests/evals.sh --completo --caso porta`
  roda O SISTEMA DEVE aprovar o caso com 3/3 com o plugin e 0/3 sem, e a
  linha do `porta` na calibração do `tests/evals/README.md` DEVE registrar
  essa rodada
- **porta-anuncio/5** — QUANDO `bash tests/evals.sh --mutar porta-anuncio
  --runs 3` roda O SISTEMA DEVE ter o resultado (taxa com e sem a regra)
  registrado no nó, caia a taxa ou não
- **porta-anuncio/6** — QUANDO a rodada rápida roda os casos `escopo-antes`,
  `memoria` e `tdd` depois da mudança O SISTEMA DEVE manter os três `PASSOU`
  (a porta endurecida não quebra o resto do fluxo)
- **porta-anuncio/7** — QUANDO o modelo cria (Write) arquivo de nó novo em
  `docs/audora/memory/` com `estado: in-progress` ou `hotfix-pending-record`,
  num projeto com `MEMORY.md` em `memory-schema: 1`, e nenhum bloco do
  assistente desde a última mensagem do humano tem o anúncio — em texto:
  `classificada como <LIGHT|MEDIUM|HIGH|HOTFIX>`, `porque` e `me corrija`; em
  narração: `classific…` seguido de `como <CATEGORIA>`, depois `me corrija`
  ou `me avise` e `discordar` — O SISTEMA DEVE recusar a escrita (exit 2) com mensagem ao modelo que manda
  escrever o anúncio em texto ao humano antes de registrar o nó, citando a
  frase-modelo
- **porta-anuncio/8** — QUANDO esse anúncio, no contrato do tipo do bloco
  (texto ou narração), está num bloco do assistente desde a última mensagem
  do humano O SISTEMA DEVE deixar a criação do nó passar (exit 0, sem saída)
- **porta-anuncio/9** — QUANDO a escrita é Edit, Write de nó já existente, de
  nó com outro estado, fora de `docs/audora/memory/` ou em projeto sem
  `memory-schema: 1` O SISTEMA DEVE deixar passar sem saída
- **porta-anuncio/10** — QUANDO o anúncio está só em raciocínio que não é
  narração (sem a marca do servidor ou com marca ilegível), em input de
  ferramenta, em skill carregada ou antes da última mensagem do humano (que
  não é resultado de ferramenta nem skill) O SISTEMA DEVE recusar como em /7
- **porta-anuncio/11** — QUANDO o transcript está ausente ou ilegível, ou o
  próprio hook falha O SISTEMA DEVE deixar a escrita passar (exit 0)

## fora-de-escopo

Casos de eval para LIGHT e HIGH; pausar e esperar confirmação depois do
anúncio (porta → 1ª fase segue sem parada); mudar as perguntas de risco ou as
regras de categoria; afrouxar qualquer grader (exceto o ramo narração,
3ª reabertura); anúncio em outras fases;
retomada por comando (`retomada-execute`); juiz LLM no grader; hook julgar
se a categoria está certa; mutação que desligue o hook (a /5 mede o passo 4);
garantir que o humano veja a narração (exibição é do harness).

## decisoes

Decisões do 1º escopo, da carga BASE, da 1ª reabertura (hook, alvo, janela,
falha deixa passar, frase completa), da 2ª (narração conta) e o delta
anterior: `porta-anuncio-historico.md`.

2026-10-12, 3ª reabertura (plan), do humano: na narração o anúncio vale por
sentido — `classific…` + `como <CAT>` + convite (`me corrija`/`me avise`) +
`discordar`, sem exigir `porque` (anunciar e pausar; parar e reverter o
hook; só a categoria). Motivo: a narração é resumo do servidor e parafraseia
(0/6 `classificada como`, 0/6 `porque`, 1/6 `me corrija`; plano, Notas).
IA, plan: `classific…` = radical `classifi(c|qu)` ("Classifiquei" em 6/12).

## delta

- ADICIONADO (2026-10-12, humano, debug T4): passo 6 entra na 1ª fase pela ferramenta
  Skill, nunca lendo o SKILL.md (Read em ~1/12 runs derrubou a /4; anterior: histórico)

## e2e
pendente

## feedback-reprovacao
