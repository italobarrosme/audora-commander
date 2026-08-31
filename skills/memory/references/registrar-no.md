# memory — operação 3: registrar-no (criar/atualizar nó)

> Reference da skill `memory`, carregada só quando esta operação é usada.
> O roteador (`../SKILL.md`) segue valendo: Lei de Ferro, schema e regra de
> leitura seletiva não se repetem aqui.

1. Validar contra `no-template.md` ANTES de escrever: frontmatter completo
   (id, estado, origem, depende-de, arquivos, keywords, resumo,
   atualizado-em), estado no enum (`planned | in-progress | blocked |
   delivered | discarded`, + transitório `hotfix-pending-record`), critérios
   NUMERADOS (`<id>/<n>`, número nunca reutilizado). Escrita que quebra
   schema é rejeitada (`memory-validate`). Exceção declarada: nó recém-aberto
   pela porta de entrada (MEDIUM/HIGH) pode ter `criterios-aceite` vazio ATÉ
   a fase scope; LIGHT/HOTFIX já entram com ≥1 critério numerado.
2. Escrever `docs/audora/memory/<id>.md` E a linha rica do índice NA MESMA
   EDIÇÃO (resumo/keywords espelhados). Índice e pasta divergentes = memória
   inconsistente → PARAR e corrigir.
3. Máximo 3 nós `in-progress` (contagem global pelo índice). Quarto chegando →
   porta de entrada resolve com o humano.
4. Em branch de demanda: editar SOMENTE os arquivos dos nós daquela demanda
   (+ suas linhas de índice). Conflito de merge fora deles → humano decide.
