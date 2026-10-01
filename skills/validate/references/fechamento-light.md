# validate — Fechamento LIGHT

> Reference da skill `validate`, lida só em demanda LIGHT. O roteador
> (`../SKILL.md`) segue valendo.

Demanda LIGHT percorre `execute → validate` e não tem plano-arquivo, escopo
escrito nem, quase sempre, delta ou decisão durável. O fechamento acompanha o
risco — mas o que ele NUNCA corta é o **portão humano** com aprovação
explícita e a **evidência 1:1** por critério. Enxugar é tirar material de
revisão, nunca tirar a revisão.

- **Oferta de e2e** (item 1): só quando a demanda toca
  **caminho percorrido pelo usuário** — tela, rota, fluxo, saída de CLI.
  LIGHT interno (refactor,
  doc, config, teste) não recebe a oferta. Pedido explícito do humano roda
  sempre, em qualquer caso.
- **Roteiro** (item 3): versão curta — evidência 1:1 por critério, o diff
  (arquivos de teste separados), e 1 linha de como conferir. Sem sumário por arquivo; sem seção de decisões
  vivas quando não há nenhuma.
- **Sync** (item 6, `sync.md`): rode só os passos com conteúdo real, e NA
  ORDEM — julgamento, depois `delivered` + `git mv`, e só então `arquivos:`
  (a lista cita o caminho NOVO do nó, então o mv vem antes). Consolidar delta
  e promover decisões vivas rodam SOMENTE se houver delta ou decisão.
  A linha do `CHANGELOG.md` entra sempre, também em LIGHT (passo 4 do
  `sync.md`, depois do `git mv`).
- **Plano**: LIGHT **não tem plano** para arquivar. Pule a etapa sem listá-la
  como pendência.
- **PRD**: o `PRD.md` é foto — atualize a foto só se o ajuste mudar o que ela
  descreve. Não mudando, registre no nó e diga em 1 linha que o PRD não
  mudou e por quê — silêncio sobre o PRD é proibido.

HOTFIX não usa este caminho: tem o dele, com registro retroativo.
