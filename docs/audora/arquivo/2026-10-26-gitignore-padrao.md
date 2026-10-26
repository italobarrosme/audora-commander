---
id: gitignore-padrao
estado: delivered
origem: humano
depende-de: []
arquivos: [CHANGELOG.md, MEMORY.md, PRD.md, README.md, README.pt-BR.md, docs/audora/aprendizados.md, docs/audora/decisoes-vivas.md, docs/audora/e2e/e2e-gitignore-padrao.md, docs/audora/planos/arquivo/plano-gitignore-padrao.md, hooks/cleanup, hooks/versionamento, skills/cleanup/SKILL.md, skills/e2e/SKILL.md, skills/memory/SKILL.md, skills/memory/references/bootstrap.md, skills/memory/references/versionamento.md, skills/validate/references/sync.md, templates/MEMORY-template.md, templates/no-template.md, tests/test-carga.sh, tests/test-cleanup-local.sh, tests/test-gitignore-padrao.sh, tests/test-leitura-por-secao.sh, tests/test-parada-revisao.sh, tests/test-skill-cleanup.sh, tests/test-versionamento.sh]
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

- Decisões do scope (9, 2026-10-26): em [2026-10-26-gitignore-padrao-historico.md](2026-10-26-gitignore-padrao-historico.md).
- 2026-10-26 (IA, debug do e2e): lacuna de teste — o teste de texto da reference não provava que a oferta a lê; o item 7 passou a mandar ler a reference e rodar o `checar` ANTES de ofertar, e a prova é o e2e (C e D, turno 1).
- 2026-10-26 (humano): ressalva aceita — `.gitignore` fica modificado no disco (bloco e linha desligada) quando o commit do /8 falha.
- 2026-10-26 (humano): ressalva aceita — lote da cleanup montado à mão com `docs/audora/./decisoes-vivas.md` em `sem volta` escapa do `protegido` e apaga do disco.
- 2026-10-26 (humano): ressalva aceita — nó discarded não arquivado (em `docs/audora/memory/`) deixa plano e e2e sempre em `## mantido`.
- 2026-10-26 (humano): ressalva aceita — contrato do skill-cleanup/11 no nó arquivado ficou desatualizado (arquivo local de nó entregue agora é `sem volta`).
- 2026-10-26 (humano): ressalva aceita — `contar` inclui as sobras locais; quase todo sync vai sugerir a cleanup.
- 2026-10-26 (humano): ressalva aceita — `local:` só é reconhecido na forma exata `local: <caminho>`.
- 2026-10-26 (humano): ressalva aceita — `checar` sonda só `memory/x.md` e `arquivo/x.md`; regra que esconde um nó específico passa sem aviso.
- 2026-10-26 (humano): ressalva aceita — `--remover` faz `git add .gitignore` inteiro e leva edições não staged que já estavam nele.
- 2026-10-26 (humano): ressalva aceita — /11 aceita também `não-automatizável`, além de passou/reprovou.
- 2026-10-26 (humano): ressalva aceita — "pasta efêmera nunca no `git add`" existe só em texto, sem guarda mecânica.
- 2026-10-26 (humano): ressalva aceita — teto de carga quase cheio: BASE 57885/58000, FULL 67075/67100.

## delta

## e2e

- gitignore-padrao/1 · passou · bootstrap (A, B) escreveu o bloco sem perguntar e gravou `versionamento: aplicado`
- gitignore-padrao/2 · passou · 2º `aplicar` → `já presente — .gitignore intocado`, md5 igual
- gitignore-padrao/3 · passou · `git check-ignore` deixa a memória e `validacao/` versionáveis, ignora só as 4 pastas
- gitignore-padrao/4 · passou · rodada 2 (depois do fix `041892f`): oferta (C, D) leu a reference, rodou o `checar` e mostrou as 4 pastas + a saída, 1 vez
- gitignore-padrao/5 · passou · recusa gravou `versionamento: recusado`; sessão nova não reofertou
- gitignore-padrao/6 · passou · rodada 2: a própria oferta (D) avisou a regra `docs/` da linha 1 e o que quebra; comentou a linha só com sim (rodada 1, t3)
- gitignore-padrao/7 · passou · nomeou `.git/info/exclude:1` e não o editou
- gitignore-padrao/8 · passou · listou 3 versionados; com sim, commit só com `A .gitignore` + `D` dos 3, que seguem no disco
- gitignore-padrao/9 · passou · pre-commit recusou; remoções desfeitas, HEAD e índice como antes, humano avisado
- gitignore-padrao/10 · passou · sem git: bloco escrito e aviso de 1 linha
- gitignore-padrao/11 · passou · e2e gravou 1 linha por critério + `relatório: local:` no nó
- gitignore-padrao/12 · passou · PNG de evidência em `docs/audora/e2e/grafico/`
- gitignore-padrao/13 · passou · nó, nó arquivado e CHANGELOG sem link para pasta efêmera
- gitignore-padrao/14 · passou · sync arquivou com `git mv`, plano movido só no disco, cartão `6 arquivos · +51 −2`
- gitignore-padrao/15 · passou · cleanup listou as 5 sobras locais em `sem volta (fora do git)` com aviso
- gitignore-padrao/16 · passou · lote sem a spec retirada → 4 apagados do disco, spec mantida, sem commit
- gitignore-padrao/17 · passou · spec, plano, e2e e evidência do nó in-progress nunca listados nem apagados
relatório: local: docs/audora/e2e/e2e-gitignore-padrao.md

## feedback-reprovacao
