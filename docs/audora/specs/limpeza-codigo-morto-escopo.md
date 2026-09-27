# Escopo — limpeza-codigo-morto (HIGH)

> Nó: `docs/audora/memory/limpeza-codigo-morto.md`. HIGH porque remove a
> sintaxe reservada `chave:id` do schema do MEMORY (contrato consumido pelas
> skills e pelo hook `memory-validate`).

## objetivo

Tirar da superfície do plugin todo resto de compatibilidade com versões
anteriores (legado GRAFO, seções de renomeação, guardas de migração) e todo
código especulativo (federação `chave:id`), fechar os nós que ficaram
`in-progress` depois de entregues, e alinhar `docs/fundamentos.md` e o
`PRD.md` ao estado real. Breaking change aceito SEM comunicação.

## criterios-aceite

- **limpeza-codigo-morto/1** — QUANDO a porta de entrada ou a skill memory
  carregar contexto num projeto sem `MEMORY.md` O SISTEMA DEVE oferecer o
  bootstrap sem mencionar GRAFO, versão anterior do framework ou arquivo de
  memória legado.
- **limpeza-codigo-morto/2** — QUANDO o leitor abrir `README.md` ou
  `README.pt-BR.md` O SISTEMA DEVE não exibir seção de renomeação/breaking
  nem nome de versão anterior (GRAFO, skill `graph`, nomes pré-0.3.0).
- **limpeza-codigo-morto/3** — QUANDO a suíte rodar O SISTEMA DEVE não conter
  guarda anti-GRAFO (`tests/test-no-grafo.sh` removido; nenhum assert de
  ausência de "grafo" nos demais testes) nem assert de migração (GRAFO.md
  ausente, pasta `nos/` ausente, `GRAFO-ARQUIVO` removido); fixture que usava
  nome legado para provar comportamento vivo é reescrita sem o nome.
- **limpeza-codigo-morto/4** — QUANDO um nó declarar em `depende-de` um id
  contendo `:` O SISTEMA DEVE tratá-lo como id comum: `memory-validate` sai
  com exit 2 acusando dependência inexistente se o id não estiver no índice;
  `MEMORY-template.md` e `no-template.md` não reservam mais a sintaxe
  `chave:id`.
- **limpeza-codigo-morto/5** — QUANDO o índice do `MEMORY.md` for lido O
  SISTEMA DEVE mostrar `memory-graphify` e `plugin-v0.1.0` como `delivered`,
  com os nós em `docs/audora/arquivo/` (evidência por critério registrada no
  nó; critério que esta demanda aposenta vira delta REMOVIDO com motivo) e os
  planos `plano-memory-graphify.md` e `plano-v0.1.0-bootstrap.md` em
  `docs/audora/planos/arquivo/`.
- **limpeza-codigo-morto/6** — QUANDO o leitor abrir `docs/fundamentos.md` O
  SISTEMA DEVE usar a nomenclatura atual (MEMORY, skills em inglês,
  LIGHT/MEDIUM/HIGH/HOTFIX, estados em inglês) e descrever só mecânica que
  existe (sem GRAFO-ARQUIVO, estado `validado`, schema v1/v2); princípios e
  tabela de acertos permanecem.
- **limpeza-codigo-morto/7** — QUANDO o leitor abrir o `PRD.md` na `main`
  após o merge O SISTEMA DEVE não citar caminho que não existe no
  repositório (roadmap em `.git/info/exclude`).
- **limpeza-codigo-morto/8** — QUANDO o plugin for reinstalado O SISTEMA DEVE
  declarar a versão `0.8.0` em `plugin.json` e `marketplace.json` (cache do
  plugin só refaz com bump).
- **limpeza-codigo-morto/9** — QUANDO o gate rodar ao fim da demanda O
  SISTEMA DEVE sair 0: comportamento vivo (hooks `memory-guard`,
  `memory-validate`, `graphify-status`, `gate`, `loop`; contagem de 9
  skills; ignorar MEMORY.md sem `memory-schema: 1`) mantém cobertura, e a
  queda de asserts dos guardas removidos passa só com `gate-asserts:`
  justificado no nó.

## fora-de-escopo

Arquivos históricos (`docs/audora/arquivo/`, specs e relatórios e2e de
demandas passadas) — história imutável, ficam como estão; otimização de
tokens (`otimizacao-tokens`) e README por skill (`readme-skills`) — nós
próprios; instalar o Graphify nesta máquina (Constituição `graphify: ativo`
é decisão do projeto, máquina sem o comando degrada como previsto);
comunicar o breaking change; versionar o roadmap de loop engineering.

## decisoes

- 2026-09-26 (humano): guarda anti-GRAFO removida de vez (descartado: grep
  mínimo case-sensitive) — legado sumiu e o guarda reprovava "parágrafo".
- 2026-09-26 (humano): `fundamentos.md` recebe nomes + mecânica atual
  (descartados: só nomes; aposentar o doc).
- 2026-09-26 (humano): roadmap órfão — tirar a referência do PRD
  (descartados: versionar; deixar).
- 2026-09-26 (IA): bump para 0.8.0 nesta demanda (a que quebra); as duas
  seguintes não bumpam de novo antes do merge conjunto — a confirmar no
  portão de escopo.
- 2026-09-26 (IA): contagem "9 skills" migra de `test-no-grafo.sh` para
  `test-skills.sh` (cobertura viva preservada).
