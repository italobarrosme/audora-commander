# gitignore-padrao — histórico

Decisões do scope (2026-10-26), movidas do nó pela operação compactar (teto ~100 linhas).

- 2026-10-26 (humano): bloco direto no bootstrap; projeto com MEMORY recebe oferta 1x. Descartado: oferta também no bootstrap.
- 2026-10-26 (humano): regra que esconde a memória → avisa e propõe ajuste com sim. Descartado: modo local (escopo bem maior).
- 2026-10-26 (humano): spec, plano e relatório e2e fora do git. Descartado: seguir versionados.
- 2026-10-26 (humano): evidência binária do e2e fora do git. Descartado: versionar (repo cresce).
- 2026-10-26 (humano): já versionado nas pastas efêmeras sai do git com sim, fica no disco. Descartado: deixar como está.
- 2026-10-26 (humano): nó guarda veredito e2e por critério. Descartado: só status geral; link para relatório local.
- 2026-10-26 (humano): cleanup lista e apaga sobras locais com sim. Descartado: ninguém limpa; validate apagar no sync.
- 2026-10-26 (IA, confirmada pelo humano no portão): bloco lista o que ignorar (4 pastas), não o que versionar — legado em `docs/audora/` citado pelo índice (`GRAFO-ARQUIVO.md`, `validacao/`, `nos/`) segue no git.
- 2026-10-26 (IA, confirmada pelo humano no portão): projeto fora do git recebe o bloco mesmo assim (/10).
