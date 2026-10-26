---
id: gitignore-padrao
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [gitignore, versionamento, bootstrap, repo, depuracao, e2e, evidencia]
resumo: O plugin configura por padrão o .gitignore do projeto para versionar só a memória do produto.
atualizado-em: 2026-10-26
---

# gitignore-padrao

## objetivo

O plugin configura por padrão o `.gitignore` dos projetos que o usam: a
memória do produto segue versionada; spec, plano, e2e (com evidência
binária) e caçada de depuração ficam fora. Origem: levantamento de
2026-10-26 em 20 projetos (vibra-reseller-panel com 15 nós delivered presos
porque o `git mv` falha em arquivo ignorado; highgarden com 115 PNGs de e2e).

## criterios-aceite

Memória versionada = `MEMORY.md`, `PRD.md`, `CHANGELOG.md`,
`docs/audora/memory/`, `docs/audora/arquivo/`, `docs/audora/decisoes-vivas.md`,
`docs/audora/aprendizados.md`. Pastas efêmeras = `docs/audora/specs/`,
`docs/audora/planos/`, `docs/audora/e2e/`, `docs/audora/depuracao/`.

- **gitignore-padrao/1** — QUANDO o bootstrap roda O SISTEMA DEVE escrever no `.gitignore` da raiz, sem perguntar, o bloco do audora que ignora as pastas efêmeras (criando o arquivo se não existir) e registrar `versionamento: aplicado` na Constituição
- **gitignore-padrao/2** — QUANDO o bloco do audora já está no `.gitignore` O SISTEMA DEVE não duplicá-lo nem alterar o resto do arquivo
- **gitignore-padrao/3** — QUANDO o bloco é escrito O SISTEMA DEVE manter versionável a memória versionada e todo caminho de `docs/audora/` fora das pastas efêmeras
- **gitignore-padrao/4** — QUANDO a carga de contexto roda em projeto com MEMORY sem bullet `versionamento:` na Constituição O SISTEMA DEVE oferecer UMA vez aplicar o bloco, mostrando o que passa a ser ignorado
- **gitignore-padrao/5** — QUANDO o humano recusa a oferta O SISTEMA DEVE registrar `versionamento: recusado` e não reofertar, salvo pedido dele
- **gitignore-padrao/6** — QUANDO, no bootstrap ou na oferta, algum caminho da memória versionada está ignorado pelo git O SISTEMA DEVE avisar a regra que o esconde (arquivo e linha) e o que quebra (arquivamento do nó, comando de arquivos do cartão, cleanup) e propor o ajuste, aplicado só com sim
- **gitignore-padrao/7** — QUANDO a regra que esconde a memória vem de fora do `.gitignore` do projeto (ignore global, `.git/info/exclude`) O SISTEMA DEVE nomear a fonte no aviso e não editá-la
- **gitignore-padrao/8** — QUANDO, no bootstrap de projeto existente ou na oferta, há arquivo já versionado nas pastas efêmeras O SISTEMA DEVE listá-los e, com sim, tirá-los do git mantendo-os no disco, num commit só com essas remoções e o `.gitignore`; sem sim, nada sai do git
- **gitignore-padrao/9** — QUANDO o commit do /8 falha O SISTEMA DEVE desfazer as remoções do índice e avisar, deixando o repo como estava
- **gitignore-padrao/10** — QUANDO o projeto não é repositório git O SISTEMA DEVE escrever o bloco mesmo assim e pular o aviso do /6 e a remoção do /8, avisando em 1 linha
- **gitignore-padrao/11** — QUANDO a fase e2e termina O SISTEMA DEVE gravar no campo `## e2e` do nó 1 linha por critério (`<id>/<n>` · passou ou reprovou · evidência em 1 frase) e citar o relatório completo como caminho local, sem link
- **gitignore-padrao/12** — QUANDO a fase e2e coleta evidência binária (screenshot, vídeo, trace) O SISTEMA DEVE salvá-la dentro de `docs/audora/e2e/`
- **gitignore-padrao/13** — QUANDO uma fase escreve em artefato da memória versionada O SISTEMA DEVE citar caminho das pastas efêmeras só como texto marcado `local:`, nunca como link
- **gitignore-padrao/14** — QUANDO o sync da validate arquiva o nó com spec, plano e e2e fora do git O SISTEMA DEVE concluir o arquivamento, o campo `arquivos:` e o comando de arquivos do cartão sem erro
- **gitignore-padrao/15** — QUANDO a cleanup varre o projeto O SISTEMA DEVE listar, em seção própria marcada "sem volta (fora do git)", as sobras locais: spec, plano e e2e de nó delivered ou discarded e caçada de `docs/audora/depuracao/` sem nó vivo
- **gitignore-padrao/16** — QUANDO o humano aprova o lote com sobras locais O SISTEMA DEVE apagá-las do disco respeitando a retirada de itens; sem aprovação, nada é apagado
- **gitignore-padrao/17** — QUANDO o nó está planned, in-progress ou blocked O SISTEMA DEVE nunca listar sua spec, plano ou e2e como sobra local

## fora-de-escopo

- Modo local (memória fora do git): quem recusa o ajuste do /6 segue com o arquivamento quebrado, avisado.
- Reescrever o histórico do git para apagar binários já versionados.
- Artefatos de ferramenta de teste fora de `docs/audora/` (`test-results/`, `playwright-report/`) e o código de teste e2e do projeto (segue versionado).
- Script em lote para os 20 projetos atuais: cada um recebe a oferta do /4 ao rodar o audora.
- Demais itens do `cerimonia-enxuta` (LIGHT sem nó, bloco curto, guardas com folga); este nó absorve só "plano e e2e efêmeros".

## decisoes

- 2026-10-26 (humano): bloco direto no bootstrap; projeto com MEMORY recebe oferta 1x. Descartado: oferta também no bootstrap.
- 2026-10-26 (humano): regra que esconde a memória → avisa e propõe ajuste com sim. Descartado: modo local (escopo bem maior).
- 2026-10-26 (humano): spec, plano e relatório e2e fora do git. Descartado: seguir versionados.
- 2026-10-26 (humano): evidência binária do e2e fora do git. Descartado: versionar (repo cresce).
- 2026-10-26 (humano): já versionado nas pastas efêmeras sai do git com sim, fica no disco. Descartado: deixar como está.
- 2026-10-26 (humano): nó guarda veredito e2e por critério. Descartado: só status geral; link para relatório local.
- 2026-10-26 (humano): cleanup lista e apaga sobras locais com sim. Descartado: ninguém limpa; validate apagar no sync.
- 2026-10-26 (IA, confirmada pelo humano no portão): bloco lista o que ignorar (4 pastas), não o que versionar — legado em `docs/audora/` citado pelo índice (`GRAFO-ARQUIVO.md`, `validacao/`, `nos/`) segue no git.
- 2026-10-26 (IA, confirmada pelo humano no portão): projeto fora do git recebe o bloco mesmo assim (/10).

## delta

## e2e

pendente

## feedback-reprovacao
