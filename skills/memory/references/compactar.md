# memory — operação 6: compactar (manutenção)

> Reference da skill `memory`, carregada só quando esta operação é usada.
> O roteador (`../SKILL.md`) segue valendo: Lei de Ferro, schema e regra de
> leitura seletiva não se repetem aqui.

0. **Consolidar delta** (sync da validate): aplicar cada ADICIONADO /
   MODIFICADO / REMOVIDO no corpo (criterios-aceite, decisoes,
   fora-de-escopo), critério novo recebe o próximo `<id>/<n>`, e esvaziar
   `## delta`.
1. Gatilhos: nó virou `delivered` (sync da validate); `MEMORY.md` > ~300
   linhas (`memory-guard` acusa); arquivo de nó > ~100 linhas; seção
   Aprendizados > ~40 linhas.
2. Nó `delivered`: (a) promover as decisões AINDA VÁLIDAS aprovadas no portão
   para `docs/audora/decisoes-vivas.md` (1 linha: data | nó | decisão);
   (b) consolidar os aprendizados da demanda na seção Aprendizados (dedupe
   pelo grep da operação 5); (c) `git mv docs/audora/memory/<id>.md
   docs/audora/arquivo/AAAA-MM-DD-<id>.md`; (d) linha do índice vira
   `- <id> | delivered | <título> → docs/audora/arquivo/AAAA-MM-DD-<id>.md`.
   Movimento, nunca reescrita. Nó com `<id>-historico.md`: mover os DOIS
   arquivos (mesmo prefixo de data) e corrigir o ponteiro relativo no corpo.
3. Requisito/decisão/aprendizado superado: NUNCA apagar — anexar
   `[invalidado-em: data] [substituido-por: <ref>]`.
4. Nó ativo > ~100 linhas: mover histórico frio (delta consolidado, decisões
   antigas) para `docs/audora/memory/<id>-historico.md` + ponteiro de 1
   linha. Aprendizados > ~40 linhas: mover os mais antigos para
   `docs/audora/aprendizados-historico.md` + ponteiro de 1 linha.
5. A promoção do resumo ao PRD.md é responsabilidade da skill validate
   (direção única MEMORY → PRD; o PRD nunca alimenta o MEMORY).
