---
id: memory-fatiada
estado: in-progress
origem: humano
depende-de: [memory-graphify]
arquivos: []
keywords: [memory, tokens, references, overhead, performance]
resumo: Skill memory vira roteador fino + references carregáveis por operação — corta 45% do custo de carga da skill mais chamada do framework.
atualizado-em: 2026-08-30
---

# memory-fatiada

## objetivo

`skills/memory/SKILL.md` tem 13.331 bytes (226 linhas, 7 operações num arquivo
só) e é chamada por 7 das 9 skills em 18 pontos, recarregada ~5 vezes por
demanda MEDIUM por causa do `/clear` entre fases. A skill deve virar roteador
fino — operações quentes e pequenas inline, operações grandes ou frias em
`references/` lidas só quando usadas — preservando integralmente o contrato
das 7 operações.

## criterios-aceite

- **memory-fatiada/1** — QUANDO uma fase invocar a skill memory para uma
  operação que ficou inline (carregar-contexto, registrar-delta,
  registrar-aprendizado) O SISTEMA DEVE executá-la sem abrir nenhum arquivo de
  reference
- **memory-fatiada/2** — QUANDO uma fase invocar a skill memory para uma
  operação movida (bootstrap, registrar-no, compactar, consultar-codigo) O
  SISTEMA DEVE ler exatamente um arquivo de reference — o daquela operação — e
  nenhum outro
- **memory-fatiada/3** — QUANDO a skill memory for carregada O SISTEMA DEVE
  apresentar uma tabela que mapeia cada uma das 7 operações ao seu local
  (inline, ou caminho do arquivo de reference)
- **memory-fatiada/4** — QUANDO um arquivo de reference apontado pela tabela
  não existir ou não puder ser lido O SISTEMA DEVE avisar em 1 linha qual
  faltou e seguir a operação pelo que o roteador ainda garante (Lei de Ferro,
  schema, regra de leitura seletiva), sem travar a fase
- **memory-fatiada/5** — QUANDO qualquer uma das 7 operações for invocada O
  SISTEMA DEVE produzir o mesmo resultado observável de antes da fatia: nomes,
  entradas, saídas e garantias das operações inalterados
- **memory-fatiada/6** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  reprovar se `skills/memory/SKILL.md` ou qualquer arquivo em
  `skills/memory/references/` passar de 250 linhas
- **memory-fatiada/7** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  reprovar se alguma das 7 operações não for alcançável pela tabela do
  roteador — operação sem entrada na tabela, ou entrada apontando para
  reference inexistente
- **memory-fatiada/8** — QUANDO o plugin for instalado a partir do marketplace
  O SISTEMA DEVE entregar os arquivos de `references/` junto com a skill;
  instalação sem eles é instalação quebrada, não degradação aceitável
- **memory-fatiada/9** — QUANDO a demanda fechar O SISTEMA DEVE registrar no
  nó a medição antes/depois, em bytes, do custo de carga da skill nas 5
  sessões de fase de uma demanda MEDIUM — medida por comando executado com
  saída lida, nunca estimada

## fora-de-escopo

Mudar nome, entrada, saída ou garantia de qualquer uma das 7 operações — o
contrato é preservado; quem muda contrato é outro nó. Fatiar as outras 8
skills (`worktree` tem 207 linhas e é a segunda maior — nó próprio se doer).
Mudar o schema do MEMORY, os templates ou os hooks de validação. Reduzir o
custo do `MEMORY.md` relido a cada fase (~8k tokens/demanda) ou do plano-arquivo
relido pela execute (7,4k-32,6k tokens/demanda) — gargalos vizinhos já medidos,
cada um com nó próprio. Porte da estrutura de references para outros harnesses
(nó `porte-multi-harness`). Benchmark de token de ponta a ponta do framework
inteiro: /9 mede esta skill, não o framework.

## decisoes

- 2026-08-30 (humano): estratégia híbrida — quentes e pequenas inline
  (carregar-contexto, registrar-delta, registrar-aprendizado), grandes ou
  frias em reference (bootstrap, registrar-no, compactar, consultar-codigo).
  Máximo (7 references) foi descartado: toda chamada de fase pagaria um Read.
- 2026-08-30 (humano): reference ausente avisa e degrada, mesmo padrão do
  Graphify — índice é atalho, não portão.
- 2026-08-30 (humano): reference segue o mesmo teto de 250 linhas do SKILL.md,
  um número só para lembrar.
- 2026-08-30 (IA): medição antes/depois vira critério (/9) por causa da
  decisão viva de 2026-08-25 (grafo-v2) que mandou medir se a travessia
  voltasse a doer. Voltou.

## delta

## e2e

pendente

## feedback-reprovacao
