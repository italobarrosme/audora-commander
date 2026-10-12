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
`evals-comportamento` (2026-10-10/11), porta 0/3 com o plugin. MEDIUM:
sem risco SIM; vários arquivos e forma de endurecer em aberto.

## criterios-aceite

- **porta-anuncio/1** — QUANDO a porta de entrada classifica uma demanda O
  SISTEMA DEVE escrever ao humano, antes de registrar o nó, uma frase própria
  `Demanda classificada como <CATEGORIA> porque <respostas às perguntas de
  risco> — me corrija se discordar`
- **porta-anuncio/2** — QUANDO o caso `porta` roda O SISTEMA DEVE reprovar se
  o texto do assistente não tiver o anúncio com `classificada como MEDIUM`,
  `porque` e `me corrija`, ou se o anúncio vier depois da primeira escrita no
  `MEMORY.md` ou no arquivo do nó
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

## fora-de-escopo

Casos de eval para LIGHT e HIGH; pausar e esperar confirmação depois do
anúncio (porta → 1ª fase segue sem parada); mudar as perguntas de risco ou as
regras de categoria; afrouxar qualquer grader; anúncio em outras fases;
retomada por comando (`retomada-execute`); juiz LLM no grader.

## decisoes

2026-10-12, todas do humano (alternativa descartada entre parênteses):
- anúncio como frase própria antes do 1º registro (só no bloco de
  fechamento: tarde demais para corrigir barato; nos dois: redundante);
- eval exige categoria + porquê + convite (só a categoria: aceita anúncio
  sem justificativa);
- cobertura só MEDIUM, caso existente (MEDIUM+LIGHT+HIGH: ~3x o custo);
- prova = completo 3/3 com e 0/3 sem (rápido 1/1: não distingue sorte de regra).

2026-10-12 (IA, execute): carga BASE 53752 → 53879 (+127 bytes do passo 4
endurecido, já enxuto); guardas `parada-revisao/9` e `leitura-por-secao/11`
sobem junto.

## delta

## e2e
pendente

## feedback-reprovacao
