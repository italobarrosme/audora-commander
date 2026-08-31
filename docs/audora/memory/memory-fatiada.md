---
id: memory-fatiada
estado: in-progress
origem: humano
depende-de: [memory-graphify]
arquivos: []
keywords: [memory, tokens, references, overhead, performance]
resumo: Skill memory vira roteador fino + references carregáveis por operação — medido: -40% por carga da skill, -29% do custo por demanda MEDIUM.
atualizado-em: 2026-08-31
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

Ver `memory-fatiada-historico.md` (mesma pasta).

## medicao (/9)

Base `7e86d9d` (pré-fatia) vs `ab3b310`. `SKILL.md` 13.331 → 7.979 bytes
(-40% por carga). Custo por sessão de fase de uma demanda MEDIUM, somando as
references que cada fase de fato lê:

| sessão | operações usadas | antes | depois |
|---|---|---|---|
| S1 commander+scope | carregar-contexto, registrar-no, registrar-aprendizado | 13.331 | 9.308 |
| S2 plan | carregar-contexto, consultar-codigo | 13.331 | 9.888 |
| S3 execute | consultar-codigo, registrar-delta, registrar-aprendizado | 13.331 | 9.888 |
| S4 e2e | carregar-contexto, registrar-aprendizado | 13.331 | 7.979 |
| S5 validate | compactar, registrar-delta | 13.331 | 9.778 |
| **total** | | **66.655** | **46.841** |

**Corte 29%** — economia de 19.814 bytes (~4.953 tokens) por demanda MEDIUM.
A estimativa da fase de escopo era ~6k tokens; o medido é 4,95k. Comando em
`docs/audora/planos/plano-memory-fatiada.md`, Tarefa 4, passo 2.

## delta

## e2e

pendente

## feedback-reprovacao
