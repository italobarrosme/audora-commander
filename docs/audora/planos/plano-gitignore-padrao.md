# Plano — gitignore-padrao: .gitignore padrão

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** o plugin escreve por padrão no `.gitignore` do projeto o bloco
que tira do git spec, plano, e2e e caçada, mantendo versionada a memória do
produto — e as fases (e2e, sync, cleanup) passam a funcionar com essas pastas
fora do git.

**Nó do MEMORY:** `gitignore-padrao` (MEMORY.md) — 17 critérios. Categoria não
registrada no nó; tratado como HIGH no portão do plano (a cleanup passa a
apagar do disco o que não tem volta no git).

**Arquitetura da mudança:** o mecânico (escrever o bloco sem duplicar, achar a
regra que esconde a memória com `git check-ignore -v --no-index`, desligar
regra, tirar do índice + commit + desfazer) mora num script novo
`hooks/versionamento` (mesmo molde do `hooks/cleanup`: wrapper bash + `perl -x`),
provado por teste de integração em repo git real. O julgamento (oferta única,
pedir sim, gravar `versionamento:` na Constituição) mora numa reference nova
`skills/memory/references/versionamento.md`, chamada pelo bootstrap e pelo
item 7 da carregar-contexto. Regra única de citação `local:` (+ nunca no
`git add`) entra no roteador da skill memory, que toda fase carrega. e2e grava
veredito por critério no nó; sync move plano com `git mv` só se rastreado; o
`hooks/cleanup` ganha a seção `## sem volta (fora do git)` e apaga do disco o
que foi aprovado.

**Arquivos lidos antes de planejar:**
- `docs/audora/memory/gitignore-padrao.md:1-74` — 17 critérios, fora-de-escopo, 9 decisões (bloco lista as 4 pastas; fora do git recebe bloco).
- `MEMORY.md:1-111` — Constituição (≤ 250 linhas por SKILL/reference, prosa PT, código só em `hooks/`/`tests/`, `bash tests/run.sh`, `gate:`), índice inteiro; `cerimonia-enxuta` (planned) absorvido em parte por este nó.
- `skills/memory/SKILL.md:1-138` — schema 14-22; tabela do roteador 35-42; carregar-contexto 73-90 (item 6 = oferta do gate, molde do item 7 novo).
- `skills/memory/references/bootstrap.md:1-30` — passos 1-2 (novo/existente), etapa gate 18-29.
- `skills/validate/references/sync.md:1-73` — passo 2 `git mv` do nó e "Plano → `docs/audora/planos/arquivo/`" 27-31; passo 3 `cria=` 32-46.
- `skills/validate/SKILL.md:1-112` — 6184 B (teto 6300): NÃO tocar.
- `skills/validate/references/fechamento-light.md:1-35` — LIGHT sem plano; sem mudança necessária.
- `skills/e2e/SKILL.md:1-118` — passo 5 evidência 63-65; relatório e vereditos 66-73; bloco 110-113.
- `skills/cleanup/SKILL.md:1-107` — tabela de tipos 23-42; fluxo 44-81.
- `hooks/cleanup:1-568` — `@SECOES` 44-45; `%VIVO` 46; `ligacao` 160-167; `classifica_artefatos` 193-212; `tokens` 226-234; `carrega_git` 302-316; `filtra_git` 344-353; `relatorio` 357-370; `le_lote` 382-391; `aplicar` 541-563.
- `skills/execute/SKILL.md:14-60` — COMMIT `git add <arquivos> && git commit` 42-44 (quebra com caminho ignorado: `git add` sai 1).
- `skills/debug/SKILL.md:85-136` — caçada em `docs/audora/depuracao/cacada-<AAAA-MM-DD>.md`; sem mudança necessária além da regra `local:`.
- `skills/scope/SKILL.md:40-60` — spec dedicada HIGH em `docs/audora/specs/`.
- `skills/audora-commander/SKILL.md:24-40` — perguntas de risco.
- `templates/no-template.md:1-72` — `## e2e` 60-63 (comentário `relatorio: ../e2e/e2e-<id>.md` = link relativo, contraria /13).
- `templates/MEMORY-template.md:1-60` — Constituição 16-26.
- `templates/plano-template.md:1-49`, `templates/bloco-fechamento-template.md:1-301` — formato; comando de arquivos do cartão 276-279.
- `tests/lib.sh:1-21` — `ok/ko/assert_*`, `$SP`, `run_hook`, `report`.
- `tests/test-skill-cleanup.sh:1-80,318-350` — `mkproj/addc/sumiu/runc/snap` 11-40, `assert_line` 76, `secao` 79; skill-cleanup/11 (338 e2e-d untracked → `não tocado: fora do git`; 350 `total: 1`).
- `tests/test-skills.sh:1-50` — roteador memory: toda reference precisa de linha na tabela (44); ≤ 250 linhas (13).
- `tests/test-memoria-integra.sh:10,40-60` — `achata`; extração de comando do sync por perl e execução em fixture.
- `tests/test-entrega-clara.sh:84-89` — extração do bloco ```bash do template.
- `tests/test-carga.sh:1-23` — BASE 57134 / teto 58000 (folga 866 B); FULL 65990 / teto 67100; nota de medição na linha 7.
- `tests/test-parada-revisao.sh:53-59`, `tests/test-leitura-por-secao.sh:110-129` — pino BASE 57134.
- `tests/test-docs.sh:1-30` — blocos de código idênticos EN/PT nos READMEs.
- `README.pt-BR.md:345-358`, `README.md:101,301-304,354-358` — pastas de `docs/audora/` e script da cleanup.
- `.gitignore:1-5`, `.gitattributes` — `hooks/* eol=lf`; `hooks/cleanup` modo 100644 (chamado via `bash`).
- Experimento (git 2.52.0.windows.1, repo descartável): `git check-ignore -v --no-index` reporta a regra da pasta-pai (`.gitignore:1:docs/	docs/audora/memory/_`), caminho inexistente e arquivo rastreado; `.git/info/exclude:1:CHANGELOG.md` sai com essa fonte; negação sai como `.gitignore:2:!keep	keep` (não ignorado — filtrar `!`); `git add ok.txt <ignorado>` adiciona `ok.txt`, imprime "The following paths are ignored" e sai 1.

**Conflitos MEMORY vs código encontrados:** nenhum.

## Notas de sessão

- Commit inicial (fim do plan): nó + linha do índice + este plano, `docs(gitignore-padrao): escopo e plano` — é o commit que CRIA o nó (base do comando de arquivos).
- Carga: folga BASE 866 B. Crescem a BASE: T5 (memory SKILL item 7 + linha da tabela, ~260 B), T6 (no-template `## e2e`, ~150 B), T7 (memory SKILL regra `local:`, ~230 B). Cada tarefa que cresce a BASE sobe os pinos `tests/test-parada-revisao.sh:59` e `tests/test-leitura-por-secao.sh:129` para a medição real e anota em `tests/test-carga.sh:7` no mesmo commit. Estourou 58000 → PARAR e levar ao humano, nunca subir teto sozinho.
- Arquivos com CRLF no checkout? `tr -cd '\r' < f | wc -c` antes de editar; editar com Edit/Write, nunca `sed -i`.
- Regex com barra invertida em teste vai pelo Write, nunca heredoc no Bash (aprendizado 2026-10-12).
- Fixture git: sempre `core.autocrlf false` e `core.excludesFile` apontando arquivo inexistente (isola do ignore global da máquina), como `mkproj`.
- Decisões tomadas pela IA:
  - (plan) Mecânico em script `hooks/versionamento` (molde `hooks/cleanup`), não só texto de skill: /6–/10 viram teste de integração em repo real.
  - (plan) Texto do bloco vive só no script (fonte única); a reference cita o script.
  - (plan) Marcador do bloco em ASCII: `# audora-commander: specs, planos, e2e e depuracao ficam so no disco` — `.gitignore` lido por ferramentas sem UTF-8 no Windows.
  - (plan) Ajuste da regra que esconde a memória (/6) = comentar a linha (`# desligado pelo audora-commander: <original>`); só em `.gitignore` dentro do projeto.
  - (plan) /8 recusa com mudança já staged (o commit só com remoções + `.gitignore` não é garantível com índice sujo).
  - (plan) /9: falhou o commit → `git reset` dos caminhos; o bloco escrito no `.gitignore` fica no disco (é o /1/4, aceito antes).
  - (plan) Evidência binária do e2e em `docs/audora/e2e/<id>/` (pasta por nó: a cleanup liga a pasta ao nó).
  - (plan) Linha do `## e2e` do nó aceita também `não-automatizável` (critério que vai ao roteiro manual); o relatório troca `falhou` → `reprovou` para um só vocabulário. Divergência do verbatim "passou ou reprovou" — apresentar no portão.
  - (plan) Regra `local:` e "pasta efêmera nunca no `git add`" numa frase só no roteador da skill memory (toda fase carrega; cabe na folga da BASE), em vez de tocar execute/validate.
  - (plan) Cleanup: `total:` passa a contar também os itens `sem volta`; pasta de evidência sai como 1 item (`docs/audora/e2e/<id>/`); a trava `## mantido` (critério sem cópia) vale também para o local.
  - (plan) Asserts de skill-cleanup/11 (`tests/test-skill-cleanup.sh:338,350`) mudam por exigência do /15 (e2e-d de nó delivered fora do git vira `sem volta`): troca de assert, não queda — se a contagem cair, `gate-asserts:` no nó.

---

## Interface comum — `hooks/versionamento` (produzido por T1–T4, consumido por T5, T8)

Chamado como `bash "<raiz do plugin>/hooks/versionamento" <sub>` na raiz do projeto. Uso:
`uso: versionamento checar | aplicar [--desligar <arquivo>:<linha>]... [--remover]` (sem sub ou sub desconhecido → essa linha, exit 1).

Bloco (6 linhas, nesta ordem):

```text
# audora-commander: specs, planos, e2e e depuracao ficam so no disco
docs/audora/specs/
docs/audora/planos/
docs/audora/e2e/
docs/audora/depuracao/
# fim audora-commander
```

Bloco presente = alguma linha do `.gitignore` da raiz igual à 1ª linha do bloco (ignorando `\r`).

Memória versionada sondada (rótulo → caminho testado no `check-ignore`): `MEMORY.md`, `PRD.md`, `CHANGELOG.md`, `docs/audora/memory/` → `docs/audora/memory/x.md`, `docs/audora/arquivo/` → `docs/audora/arquivo/x.md`, `docs/audora/decisoes-vivas.md`, `docs/audora/aprendizados.md`.

## Tarefa 1: script — escrever o bloco

- **depende-de**: []
- **requisito**: `gitignore-padrao/1` — QUANDO o bootstrap roda O SISTEMA DEVE escrever no `.gitignore` da raiz, sem perguntar, o bloco do audora que ignora as pastas efêmeras (criando o arquivo se não existir) e registrar `versionamento: aplicado` na Constituição (parte mecânica; Constituição na T5) · `gitignore-padrao/2` — QUANDO o bloco do audora já está no `.gitignore` O SISTEMA DEVE não duplicá-lo nem alterar o resto do arquivo · `gitignore-padrao/3` — QUANDO o bloco é escrito O SISTEMA DEVE manter versionável a memória versionada e todo caminho de `docs/audora/` fora das pastas efêmeras · `gitignore-padrao/10` — QUANDO o projeto não é repositório git O SISTEMA DEVE escrever o bloco mesmo assim e pular o aviso do /6 e a remoção do /8, avisando em 1 linha
- **decisões relevantes**: bloco lista o que ignorar (4 pastas), não o que versionar; projeto fora do git recebe o bloco.
- **interfaces**: produz `hooks/versionamento` com `aplicar` (sem flags nesta tarefa) e a linha de uso.
- **ponto de mudança**: `hooks/versionamento` (novo) — cabeçalho bash 1-11 igual a `hooks/cleanup:1-11` (variável `VERS_DIR`), corpo `#!perl` com `sai`, `ler`, `bloco_presente`, `escreve_bloco`.
- **teste**: `tests/test-versionamento.sh` (novo) — casos "gitignore-padrao/1 cria .gitignore", "/1 acrescenta preservando o resto", "/1 CRLF", "/2 não duplica", "/2 bloco editado pelo humano", "/3 memória segue versionável", "/10 fora do git".
- **asserções**:
  - sem `.gitignore` → arquivo = as 6 linhas do bloco, LF, terminando em `\n`; stdout `versionamento: .gitignore criado com o bloco do audora`; exit 0.
  - `.gitignore` = `node_modules/` sem `\n` final → `node_modules/\n\n` + bloco; stdout `versionamento: bloco do audora acrescentado ao .gitignore`.
  - `.gitignore` = `a\r\nb\r\n` → `a\r\nb\r\n\r\n` + bloco com `\r\n` em cada linha.
  - 2ª execução → md5 igual ao da 1ª; stdout `versionamento: bloco do audora já presente — .gitignore intocado`.
  - bloco com `docs/audora/e2e/` apagado pelo humano (marcador mantido) → md5 inalterado, mesma linha "já presente".
  - repo com bloco aplicado: `git check-ignore -q --no-index <c>` sai 1 para `MEMORY.md PRD.md CHANGELOG.md docs/audora/memory/x.md docs/audora/arquivo/x.md docs/audora/decisoes-vivas.md docs/audora/aprendizados.md docs/audora/GRAFO-ARQUIVO.md docs/audora/validacao/x.md docs/audora/nos/x.md README.md` e sai 0 para `docs/audora/specs/x-escopo.md docs/audora/planos/plano-x.md docs/audora/planos/arquivo/plano-x.md docs/audora/e2e/e2e-x.md docs/audora/e2e/x/shot.png docs/audora/depuracao/cacada-2026-01-01.md`.
  - pasta sem `.git` → bloco escrito; stdout tem `versionamento: .gitignore criado com o bloco do audora` e a linha `versionamento: fora do git — checagem de regra e remoção puladas`; exit 0.
  - `versionamento` sem sub e `versionamento xyz` → stdout `uso: versionamento checar | aplicar [--desligar <arquivo>:<linha>]... [--remover]`, exit 1.
- **ler**: `hooks/cleanup:1-53`
- **done quando**: `bash tests/test-versionamento.sh` verde e `bash tests/run.sh` exit 0.

- [ ] **red** — `bash tests/test-versionamento.sh` falha com `arquivo ausente`/`esperado` por `hooks/versionamento` inexistente
- [ ] **green** — `bash tests/test-versionamento.sh` passa e `bash tests/run.sh` exit 0
- [ ] **commit** — `git add hooks/versionamento tests/test-versionamento.sh && git commit -m "feat(gitignore-padrao/1): hooks/versionamento escreve o bloco sem duplicar (/2, /3, /10)"`

## Tarefa 2: script — `checar`

- **depende-de**: [T1]
- **requisito**: `gitignore-padrao/6` — QUANDO, no bootstrap ou na oferta, algum caminho da memória versionada está ignorado pelo git O SISTEMA DEVE avisar a regra que o esconde (arquivo e linha) e o que quebra (arquivamento do nó, comando de arquivos do cartão, cleanup) e propor o ajuste, aplicado só com sim · `gitignore-padrao/7` — QUANDO a regra que esconde a memória vem de fora do `.gitignore` do projeto (ignore global, `.git/info/exclude`) O SISTEMA DEVE nomear a fonte no aviso e não editá-la · `gitignore-padrao/8` (listagem) — QUANDO, no bootstrap de projeto existente ou na oferta, há arquivo já versionado nas pastas efêmeras O SISTEMA DEVE listá-los … · `gitignore-padrao/10` (pula /6 e /8 fora do git)
- **decisões relevantes**: regra que esconde a memória → avisa e propõe ajuste com sim; fonte externa nunca editada.
- **interfaces**: `checar` só lê (nada muda no disco nem no git). Saída, nesta ordem: `bloco: presente|ausente`; por caminho escondido `memória ignorada: <rótulo> | regra <fonte>:<linha> <padrão> | <sufixo>` com sufixo `ajuste: aplicar --desligar <fonte>:<linha>` (fonte = arquivo `.gitignore` relativo dentro do projeto) ou `fonte fora do projeto — não edito` (global, `.git/info/exclude`); se houve alguma, `quebra: arquivamento do nó, comando de arquivos do cartão e cleanup`; por arquivo rastreado nas 4 pastas `versionado em pasta efêmera: <caminho>` (ordem de `git ls-files`); última linha `versionamento: <a> regra(s) escondendo a memória · <b> versionado(s) em pasta efêmera`. Fora do git: `bloco: …` + `versionamento: fora do git — checagem de regra e remoção puladas`. Exit 0.
- **ponto de mudança**: `hooks/versionamento` — sub `checar`, funções `regras_memoria` (`git check-ignore -v --no-index` por caminho; descarta padrão que começa com `!`) e `efemeros_versionados` (`git ls-files -z -- docs/audora/specs docs/audora/planos docs/audora/e2e docs/audora/depuracao`).
- **teste**: `tests/test-versionamento.sh` — casos "/6 regra do projeto", "/6 regra em .gitignore de subpasta", "/6 negação não conta", "/7 .git/info/exclude", "/7 ignore global", "/8 lista versionados", "/10 checar fora do git", "checar só lê".
- **asserções**:
  - `.gitignore` = `docs/\n` → linhas `memória ignorada: docs/audora/memory/ | regra .gitignore:1 docs/ | ajuste: aplicar --desligar .gitignore:1` (idem `docs/audora/arquivo/`, `docs/audora/decisoes-vivas.md`, `docs/audora/aprendizados.md`), depois `quebra: arquivamento do nó, comando de arquivos do cartão e cleanup`, última `versionamento: 4 regra(s) escondendo a memória · 0 versionado(s) em pasta efêmera`.
  - `docs/.gitignore` = `audora/memory/\n` → `memória ignorada: docs/audora/memory/ | regra docs/.gitignore:1 audora/memory/ | ajuste: aplicar --desligar docs/.gitignore:1`.
  - `.gitignore` = `*.md\n!MEMORY.md\n` → sem linha para `MEMORY.md`; com linha para `PRD.md` (`regra .gitignore:1 *.md`).
  - `.git/info/exclude` = `CHANGELOG.md` → `memória ignorada: CHANGELOG.md | regra .git/info/exclude:1 CHANGELOG.md | fonte fora do projeto — não edito`.
  - `core.excludesFile` = `$p/../global-ign` com `PRD.md` → linha de `PRD.md` com sufixo `fonte fora do projeto — não edito` e a fonte como o git imprime.
  - 2 arquivos rastreados (`docs/audora/specs/a-escopo.md`, `docs/audora/e2e/a/shot.png`) → `versionado em pasta efêmera: <cada um>`; resumo `· 2 versionado(s) em pasta efêmera`.
  - repo limpo com bloco → `bloco: presente` + `versionamento: 0 regra(s) escondendo a memória · 0 versionado(s) em pasta efêmera`, sem `quebra:`.
  - `snap` (HEAD + status + md5 da árvore) igual antes/depois de todo `checar`.
- **ler**: `hooks/cleanup:295-316`
- **done quando**: casos verdes e `bash tests/run.sh` exit 0.

- [ ] **red** — `bash tests/test-versionamento.sh` falha nos casos de `checar` (saída = linha de uso)
- [ ] **green** — `bash tests/test-versionamento.sh` passa e `bash tests/run.sh` exit 0
- [ ] **commit** — `git add hooks/versionamento tests/test-versionamento.sh && git commit -m "feat(gitignore-padrao/6): versionamento checar acha a regra que esconde a memória (/7, /8, /10)"`

## Tarefa 3: script — `aplicar --desligar`

- **depende-de**: [T2]
- **requisito**: `gitignore-padrao/6` (ajuste aplicado só com sim) · `gitignore-padrao/7` (fonte externa não editada)
- **decisões relevantes**: ajuste = comentar a linha; validar todos os argumentos ANTES de escrever qualquer coisa.
- **interfaces**: `aplicar --desligar <arquivo>:<linha>` (repetível). Sucesso: troca a linha por `# desligado pelo audora-commander: <original>` (preserva `\r\n`), stdout `versionamento: regra desligada em <arquivo>:<linha> (<padrão>)`. Recusas (exit 1, nada alterado — nem o bloco): arquivo absoluto, sob `.git/`, fora da raiz ou com nome ≠ `.gitignore` → `versionamento: <arquivo> fica fora do projeto — não edito; nada foi alterado`; linha inexistente, vazia, comentário → `versionamento: <arquivo>:<linha> não é regra ativa — nada foi alterado`.
- **ponto de mudança**: `hooks/versionamento` — parse de flags de `aplicar`, `valida_desligar`, `desliga`.
- **teste**: `tests/test-versionamento.sh` — casos "/6 desligar com sim", "/7 recusa .git/info/exclude", "/7 recusa caminho absoluto", "/6 linha que não é regra".
- **asserções**:
  - `.gitignore` = `docs/\n` + `aplicar --desligar .gitignore:1` → linha 1 vira `# desligado pelo audora-commander: docs/`; bloco acrescentado; `checar` depois → `versionamento: 0 regra(s) escondendo a memória · …`.
  - `--desligar .git/info/exclude:1` → exit 1, stdout `versionamento: .git/info/exclude fica fora do projeto — não edito; nada foi alterado`, `snap` igual (sem bloco escrito).
  - `--desligar .gitignore:9` (arquivo de 1 linha) → exit 1, `versionamento: .gitignore:9 não é regra ativa — nada foi alterado`, `snap` igual.
- **ler**: `hooks/versionamento` (T1-T2)
- **done quando**: casos verdes e `bash tests/run.sh` exit 0.

- [ ] **red** — `bash tests/test-versionamento.sh` falha nos casos `--desligar`
- [ ] **green** — `bash tests/test-versionamento.sh` passa e `bash tests/run.sh` exit 0
- [ ] **commit** — `git add hooks/versionamento tests/test-versionamento.sh && git commit -m "feat(gitignore-padrao/6): versionamento aplicar --desligar comenta a regra do projeto (/7)"`

## Tarefa 4: script — `aplicar --remover` (tirar do git, manter no disco)

- **depende-de**: [T1]
- **requisito**: `gitignore-padrao/8` — QUANDO, no bootstrap de projeto existente ou na oferta, há arquivo já versionado nas pastas efêmeras O SISTEMA DEVE listá-los e, com sim, tirá-los do git mantendo-os no disco, num commit só com essas remoções e o `.gitignore`; sem sim, nada sai do git · `gitignore-padrao/9` — QUANDO o commit do /8 falha O SISTEMA DEVE desfazer as remoções do índice e avisar, deixando o repo como estava · `gitignore-padrao/10` (remoção pulada fora do git)
- **decisões relevantes**: já versionado nas pastas efêmeras sai do git com sim e fica no disco; recusa com índice staged.
- **interfaces**: `aplicar --remover`. Ordem: valida flags → staged? (`git diff --cached --quiet` ≠ 0 → `versionamento: há mudança staged — remoção não feita; nada foi alterado`, exit 1, sem escrever o bloco) → escreve bloco → desliga → `git rm -r --cached -q --` dos versionados → `git add -- .gitignore` (+ cada `.gitignore` desligado) → `git commit -q -F <msg>` com título `chore(audora): tira spec, plano, e2e e caçada do git (ficam no disco)` e corpo `<n> arquivo(s) fora do git, mantidos no disco`. Sucesso: `versionamento: commit <hash7> — <n> arquivo(s) fora do git, mantidos no disco`. Nada versionado: `versionamento: nada versionado nas pastas efêmeras` (exit 0, sem commit). Falha do commit: `git reset -q --` dos mesmos caminhos; stdout `versionamento: commit falhou — remoções desfeitas, nada saiu do git`; exit 1. Fora do git com `--remover`: só a linha `versionamento: fora do git — checagem de regra e remoção puladas` (exit 0).
- **ponto de mudança**: `hooks/versionamento` — `remove_versionados`, `desfaz_indice`.
- **teste**: `tests/test-versionamento.sh` — casos "/8 com sim", "/8 sem --remover nada sai", "/8 staged recusa", "/9 commit falha", "/10 --remover fora do git".
- **asserções**:
  - fixture com `docs/audora/specs/a-escopo.md`, `docs/audora/planos/plano-a.md`, `docs/audora/e2e/a/shot.png` e `src/x.txt` rastreados → `aplicar --remover`: exit 0; `git ls-files docs/audora/specs docs/audora/planos docs/audora/e2e` vazio; os 3 arquivos existem no disco com o md5 de antes; `git show --name-status --format= HEAD` = `A .gitignore` (fixture sem `.gitignore` antes) + `D` dos 3 e nada mais; `git log -1 --format=%s` = `chore(audora): tira spec, plano, e2e e caçada do git (ficam no disco)`; `git status --porcelain` vazio; `src/x.txt` ainda rastreado.
  - só `aplicar` (sem `--remover`) na mesma fixture → `git ls-files` ainda lista os 3; HEAD inalterado.
  - `src/y.txt` staged + `--remover` → exit 1, linha da recusa staged, `snap` igual.
  - `.git/hooks/pre-commit` = `exit 1` → exit 1, `versionamento: commit falhou — remoções desfeitas, nada saiu do git`; HEAD inalterado; `git ls-files` lista os 3; `git diff --cached --name-only` vazio; os 3 no disco.
  - pasta sem `.git` + `--remover` → exit 0, bloco escrito, só a linha "fora do git" como aviso.
- **ler**: `hooks/cleanup:486-498,527-539`
- **done quando**: casos verdes e `bash tests/run.sh` exit 0.

- [ ] **red** — `bash tests/test-versionamento.sh` falha nos casos `--remover`
- [ ] **green** — `bash tests/test-versionamento.sh` passa e `bash tests/run.sh` exit 0
- [ ] **commit** — `git add hooks/versionamento tests/test-versionamento.sh && git commit -m "feat(gitignore-padrao/8): versionamento aplicar --remover tira do git e mantém no disco (/9, /10)"`

## Tarefa 5: skill memory — bootstrap, oferta única e reference `versionamento.md`

- **depende-de**: [T2, T3, T4]
- **requisito**: `gitignore-padrao/1` (sem perguntar + `versionamento: aplicado` na Constituição) · `gitignore-padrao/4` — QUANDO a carga de contexto roda em projeto com MEMORY sem bullet `versionamento:` na Constituição O SISTEMA DEVE oferecer UMA vez aplicar o bloco, mostrando o que passa a ser ignorado · `gitignore-padrao/5` — QUANDO o humano recusa a oferta O SISTEMA DEVE registrar `versionamento: recusado` e não reofertar, salvo pedido dele · fluxo textual de `/6`, `/7`, `/8`, `/9`, `/10` (a skill pede o sim e repassa as linhas do script)
- **decisões relevantes**: bloco direto no bootstrap; projeto com MEMORY recebe oferta 1x (descartado: oferta no bootstrap).
- **interfaces**: consome `hooks/versionamento checar|aplicar [--desligar …] [--remover]`. Produz `skills/memory/references/versionamento.md` (≤ 250 linhas) com as frases:
  - `Bootstrap: rode \`aplicar\` sem perguntar e registre \`versionamento: aplicado\` na Constituição.`
  - `Oferta (carregar-contexto, item 7): mostre o que passa a ser ignorado — \`docs/audora/specs/\`, \`docs/audora/planos/\`, \`docs/audora/e2e/\`, \`docs/audora/depuracao/\` — e a saída do \`checar\`; pergunte UMA vez.`
  - `Recusou → registre \`versionamento: recusado\` e não reoferte, salvo pedido do humano.`
  - `Linha \`memória ignorada:\` → mostre a regra, a linha \`quebra:\` e proponha o ajuste; \`--desligar\` só com sim.`
  - `\`fonte fora do projeto — não edito\` → nomeie a fonte e não a edite.`
  - `Linha \`versionado em pasta efêmera:\` → liste-os e pergunte; \`--remover\` só com sim; sem sim, nada sai do git.`
  - `\`commit falhou\` → repasse a linha ao humano: o script já desfez as remoções.`
  - `Fora do git → repasse em 1 linha a saída do script.`
  Router `skills/memory/SKILL.md`: linha de tabela `| versionamento | references/versionamento.md |`; item 7 da carregar-contexto: `7. Constituição sem bullet \`versionamento:\` → ofertar UMA vez aplicar o bloco do \`.gitignore\` (\`references/versionamento.md\`); \`versionamento: recusado\` → não reofertar, só se o humano pedir.` Bootstrap: etapa nova `**Etapa versionamento** (sempre, antes da etapa gate)` apontando a reference. `templates/MEMORY-template.md`: bullet `- **versionamento**: aplicado | recusado (skill memory, \`references/versionamento.md\`)`.
- **ponto de mudança**: `skills/memory/SKILL.md:42` (tabela) e `:88-90` (item 7 após o 6); `skills/memory/references/bootstrap.md:18` (etapa antes do gate); `templates/MEMORY-template.md:26`; `skills/memory/references/versionamento.md` (novo).
- **teste**: `tests/test-gitignore-padrao.sh` (novo, `achata` como `tests/test-memoria-integra.sh:10`) — casos "gitignore-padrao/1 bootstrap aplica sem perguntar", "/4 oferta única", "/5 recusado não reoferta", "/6–/10 reference repassa o script"; `tests/test-skills.sh:39` já exige a linha da tabela de toda reference.
- **asserções**: cada frase acima presente (achatada) no arquivo dela; `bash hooks/versionamento` citado na reference como `bash "<raiz do plugin>/hooks/versionamento"`; reference ≤ 250 linhas.
- **ler**: `skills/memory/SKILL.md:30-48,73-90`, `skills/memory/references/bootstrap.md:1-30`, `templates/MEMORY-template.md:16-27`
- **done quando**: teste verde; `bash tests/run.sh` exit 0; pinos BASE subidos para a medição (`tests/test-parada-revisao.sh:59`, `tests/test-leitura-por-secao.sh:129`) com nota `gitignore-padrao/4 (item 7 + linha da tabela): BASE 57134 → <medição>` em `tests/test-carga.sh:7`; BASE ≤ 58000.

- [ ] **red** — `bash tests/test-gitignore-padrao.sh` falha com `não contém` nas frases
- [ ] **green** — `bash tests/test-gitignore-padrao.sh` e `bash tests/test-carga.sh` passam; `bash tests/run.sh` exit 0
- [ ] **commit** — `git add skills/memory/SKILL.md skills/memory/references/bootstrap.md skills/memory/references/versionamento.md templates/MEMORY-template.md tests/test-gitignore-padrao.sh tests/test-carga.sh tests/test-parada-revisao.sh tests/test-leitura-por-secao.sh && git commit -m "feat(gitignore-padrao/4): bootstrap aplica o bloco e a carga oferta uma vez (/1, /5)"`

## Tarefa 6: e2e — veredito por critério no nó e evidência em `docs/audora/e2e/`

- **depende-de**: []
- **requisito**: `gitignore-padrao/11` — QUANDO a fase e2e termina O SISTEMA DEVE gravar no campo `## e2e` do nó 1 linha por critério (`<id>/<n>` · passou ou reprovou · evidência em 1 frase) e citar o relatório completo como caminho local, sem link · `gitignore-padrao/12` — QUANDO a fase e2e coleta evidência binária (screenshot, vídeo, trace) O SISTEMA DEVE salvá-la dentro de `docs/audora/e2e/`
- **decisões relevantes**: nó guarda veredito e2e por critério (descartado: só status geral; link para relatório local); evidência binária fora do git.
- **interfaces**: formato da linha no nó: `- <id>/<n> · passou · <evidência em 1 frase>` (`reprovou`, `não-automatizável`); fecho `relatório: local: docs/audora/e2e/e2e-<id>.md`.
- **ponto de mudança**: `skills/e2e/SKILL.md:63-73` (passo 5: evidência binária em `docs/audora/e2e/<id>/`; passo 6: veredito `reprovou` no lugar de `falhou` + gravar no `## e2e` do nó); `templates/no-template.md:62-63` (comentário do `## e2e` troca `relatorio: ../e2e/e2e-<id>.md` pelo formato acima).
- **teste**: `tests/test-gitignore-padrao.sh` — casos "gitignore-padrao/11 linha por critério no nó", "/11 relatório como local:", "/12 evidência binária em docs/audora/e2e/<id>/".
- **asserções**: e2e SKILL achatado contém `` `- <id>/<n> · passou · <evidência em 1 frase>` `` , `relatório: local: docs/audora/e2e/e2e-<id>.md` e `screenshot, vídeo ou trace em \`docs/audora/e2e/<id>/\``; não contém `` `falhou` ``; no-template contém `relatório: local: docs/audora/e2e/e2e-<id>.md` e não contém `../e2e/e2e-<id>.md`.
- **ler**: `skills/e2e/SKILL.md:58-80`, `templates/no-template.md:58-64`
- **done quando**: teste verde; e2e SKILL ≤ 250 linhas; pinos BASE subidos com nota `gitignore-padrao/11 (no-template ## e2e)` em `tests/test-carga.sh:7`; `bash tests/run.sh` exit 0.

- [ ] **red** — `bash tests/test-gitignore-padrao.sh` falha nos casos /11, /12
- [ ] **green** — `bash tests/test-gitignore-padrao.sh` e `bash tests/test-carga.sh` passam; `bash tests/run.sh` exit 0
- [ ] **commit** — `git add skills/e2e/SKILL.md templates/no-template.md tests/test-gitignore-padrao.sh tests/test-carga.sh tests/test-parada-revisao.sh tests/test-leitura-por-secao.sh && git commit -m "feat(gitignore-padrao/11): e2e grava veredito por critério no nó e evidência em docs/audora/e2e (/12)"`

## Tarefa 7: regra `local:` — memória versionada sem link para pasta efêmera

- **depende-de**: []
- **requisito**: `gitignore-padrao/13` — QUANDO uma fase escreve em artefato da memória versionada O SISTEMA DEVE citar caminho das pastas efêmeras só como texto marcado `local:`, nunca como link
- **decisões relevantes**: spec, plano, e2e e caçada fora do git.
- **interfaces**: frase no roteador (schema, após `skills/memory/SKILL.md:22`): `Pastas efêmeras (\`docs/audora/specs/\`, \`planos/\`, \`e2e/\`, \`depuracao/\`) ficam fora do git: em nó, índice, PRD, CHANGELOG, decisões vivas e aprendizados, cite caminho delas só como texto \`local: <caminho>\`, nunca link — e nunca no \`git add\`.` · `hooks/cleanup` `tokens`: token `docs/audora/…\.md` precedido de `local: ` (com ou sem crase) não é link.
- **ponto de mudança**: `skills/memory/SKILL.md:22`; `hooks/cleanup:226-234` (`tokens`).
- **teste**: `tests/test-gitignore-padrao.sh` caso "gitignore-padrao/13 regra local: no roteador"; `tests/test-cleanup-local.sh` (novo; copia `mkproj`, `addc`, `sumiu`, `runc`, `snap`, `assert_line`, `secao` de `tests/test-skill-cleanup.sh:11-40,76-79`) caso "gitignore-padrao/13 local: não é link".
- **asserções**: roteador achatado contém a frase acima; nó arquivado com `relatório: local: docs/audora/e2e/e2e-d.md` (arquivo nunca versionado) → `varrer` sem `## nunca existiu`, saída `cleanup: nada a limpar`; com `` local: `docs/audora/e2e/e2e-d.md` `` e arquivo versionado-e-removido (`sumiu`) → sem `## link quebrado`; regressão: `docs/audora/e2e/nunca.md` solto (sem `local:`) segue em `## nunca existiu`.
- **ler**: `skills/memory/SKILL.md:14-26`, `hooks/cleanup:214-253`
- **done quando**: testes verdes; pinos BASE subidos com nota `gitignore-padrao/13 (regra local: no roteador)` em `tests/test-carga.sh:7`; BASE ≤ 58000; `bash tests/run.sh` exit 0.

- [ ] **red** — `bash tests/test-gitignore-padrao.sh` e `bash tests/test-cleanup-local.sh` falham (frase ausente; `## nunca existiu` presente)
- [ ] **green** — os dois passam; `bash tests/test-carga.sh` e `bash tests/run.sh` exit 0
- [ ] **commit** — `git add skills/memory/SKILL.md hooks/cleanup tests/test-gitignore-padrao.sh tests/test-cleanup-local.sh tests/test-carga.sh tests/test-parada-revisao.sh tests/test-leitura-por-secao.sh && git commit -m "feat(gitignore-padrao/13): memória versionada cita pasta efêmera como local:, nunca link"`

## Tarefa 8: sync arquiva com spec, plano e e2e fora do git

- **depende-de**: [T1]
- **requisito**: `gitignore-padrao/14` — QUANDO o sync da validate arquiva o nó com spec, plano e e2e fora do git O SISTEMA DEVE concluir o arquivamento, o campo `arquivos:` e o comando de arquivos do cartão sem erro
- **decisões relevantes**: plano fora do git (move só no disco quando não rastreado).
- **interfaces**: `skills/validate/references/sync.md` passo 2 troca "Plano → `docs/audora/planos/arquivo/`" por bloco ```bash:
  `p=docs/audora/planos/plano-<id>.md; a=docs/audora/planos/arquivo`
  `if [ ! -f "$p" ]; then :; elif git ls-files --error-unmatch -- "$p" >/dev/null 2>&1; then mkdir -p "$a" && git mv "$p" "$a/"; else mkdir -p "$a" && mv "$p" "$a/"; fi`
  + 1 frase: `O commit do sync leva só a memória versionada.`
- **ponto de mudança**: `skills/validate/references/sync.md:30-31`.
- **teste**: `tests/test-gitignore-padrao.sh` caso "gitignore-padrao/14 sync em repo com bloco": fixture git com `bash hooks/versionamento aplicar`, nó `z` criado em commit `docs(z): escopo`, commit `feat(z/1): x` em `src/a.txt`, spec/plano/e2e `z` só no disco; extrai o bloco ```bash do passo 2 (perl, como `tests/test-memoria-integra.sh:52`) trocando `<id>` por `z`; roda `git mv docs/audora/memory/z.md docs/audora/arquivo/2026-01-01-z.md` + troca da linha `z` no `MEMORY.md` + o bloco + `git add -A && git commit -qm "docs(z): sync"`; roda o `cria=`/numstat do sync e o comando de arquivos extraído de `templates/bloco-fechamento-template.md` (como `tests/test-entrega-clara.sh:89`).
- **asserções**: bloco do plano sai 0 e `docs/audora/planos/arquivo/plano-z.md` existe no disco, fora do `git ls-files`; plano rastreado (2º cenário sem bloco) → `git status --porcelain` mostra `R  docs/audora/planos/plano-z.md -> docs/audora/planos/arquivo/plano-z.md`; sem plano (3º) → exit 0, nada muda; `git add -A` do sync sai 0 e o commit não tem caminho de pasta efêmera; `git diff --name-only "$cria^..HEAD" | sort` = `MEMORY.md`, `docs/audora/arquivo/2026-01-01-z.md`, `src/a.txt` (3 linhas, nenhuma de pasta efêmera); comando de arquivos sai 0, stderr vazio, stdout casa `^[0-9]+ arquivos · \+[0-9]+ −[0-9]+$`.
- **ler**: `skills/validate/references/sync.md:21-46`, `templates/bloco-fechamento-template.md:272-282`, `tests/test-entrega-clara.sh:84-100`
- **done quando**: teste verde; `bash tests/test-carga.sh` (FULL ≤ 67100) e `bash tests/run.sh` exit 0.

- [ ] **red** — `bash tests/test-gitignore-padrao.sh` falha (bloco ```bash do plano ausente no sync)
- [ ] **green** — passa; `bash tests/run.sh` exit 0
- [ ] **commit** — `git add skills/validate/references/sync.md tests/test-gitignore-padrao.sh && git commit -m "feat(gitignore-padrao/14): sync arquiva com plano fora do git"`

## Tarefa 9: cleanup — `varrer` lista sobras locais `sem volta`

- **depende-de**: [T7]
- **requisito**: `gitignore-padrao/15` — QUANDO a cleanup varre o projeto O SISTEMA DEVE listar, em seção própria marcada "sem volta (fora do git)", as sobras locais: spec, plano e e2e de nó delivered ou discarded e caçada de `docs/audora/depuracao/` sem nó vivo · `gitignore-padrao/17` — QUANDO o nó está planned, in-progress ou blocked O SISTEMA DEVE nunca listar sua spec, plano ou e2e como sobra local
- **decisões relevantes**: cleanup lista e apaga sobras locais com sim; princípio da cleanup (só sai o que não é mais usado; critério sem cópia fica).
- **interfaces**: `@SECOES` ganha `sem volta (fora do git)` por último. Item local = arquivo NÃO rastreado com ligação a nó delivered/discarded (`specs/<id>-escopo.md`, `planos/plano-<id>.md`, `planos/arquivo/plano-<id>.md`, `e2e/e2e-<id>.md`) → `- <caminho> | nó <id> <estado>`; pasta `docs/audora/e2e/<id>/` com algum arquivo não rastreado → 1 item `- docs/audora/e2e/<id>/ | nó <id> <estado> (<n> arquivo(s))`; caçada não rastreada em `depuracao/` sem nó vivo → `- <caminho> | caçada sem nó vivo`. Critério sem cópia → `## mantido` (igual ao rastreado). `filtra_git` não manda item local para `não tocado`. `total:` soma o local.
- **ponto de mudança**: `hooks/cleanup:44-46` (`@SECOES`), `:160-167` (`ligacao` + pasta `e2e/<id>/`), `:193-212` (`classifica_artefatos`: ramo local antes do rastreado; `carrega_git` precisa rodar antes — reordenar `varre` em `:372`), `:344-353` (`filtra_git` pula a seção nova).
- **teste**: `tests/test-cleanup-local.sh` — casos "gitignore-padrao/15 delivered", "/15 discarded", "/15 caçada sem nó vivo", "/15 pasta de evidência", "/15 mantido sem cópia", "/17 planned/in-progress/blocked nunca", "/15 rastreado segue no tipo antigo"; `tests/test-skill-cleanup.sh:338,350` (e2e-d untracked de delivered → seção nova; total 2).
- **asserções**: nó `d` delivered com `specs/d-escopo.md`, `planos/arquivo/plano-d.md`, `e2e/e2e-d.md`, `e2e/d/a.png`, `e2e/d/b.png` só no disco (bloco aplicado) → `secao "$out" 'sem volta (fora do git)'` = linhas `- docs/audora/e2e/d/ | nó d delivered (2 arquivo(s))`, `- docs/audora/e2e/e2e-d.md | nó d delivered`, `- docs/audora/planos/arquivo/plano-d.md | nó d delivered`, `- docs/audora/specs/d-escopo.md | nó d delivered` (ordem `sort`); `total: 4 item(ns) no lote`; nada disso em `## não tocado`. Nó `x` discarded → `| nó x discarded`. `depuracao/cacada-2026-01-01.md` local não citada → `| caçada sem nó vivo`; citada em nó vivo → ausente. Cenário à parte: spec local de `d` citando `d/9` sem cópia → `## mantido` `- docs/audora/specs/d-escopo.md | mantido: cita d/9 sem cópia no nó arquivado`. Nós `p` planned, `v` in-progress, `b` blocked com spec, plano, e2e e pasta `e2e/<id>/` locais → nenhum caminho deles em nenhuma seção. Spec rastreada de `d` → segue em `## spec de nó entregue`. `contar` = soma. `snap` igual depois do `varrer`.
- **ler**: `hooks/cleanup:83-212,343-372`, `tests/test-skill-cleanup.sh:80-120,318-360`
- **done quando**: `bash tests/test-cleanup-local.sh` e `bash tests/test-skill-cleanup.sh` verdes; `bash tests/run.sh` exit 0.

- [ ] **red** — `bash tests/test-cleanup-local.sh` falha (seção `sem volta (fora do git)` ausente; itens em `não tocado`)
- [ ] **green** — os dois passam; `bash tests/run.sh` exit 0
- [ ] **commit** — `git add hooks/cleanup tests/test-cleanup-local.sh tests/test-skill-cleanup.sh && git commit -m "feat(gitignore-padrao/15): cleanup lista sobras locais em sem volta (fora do git) (/17)"`

## Tarefa 10: cleanup — `aplicar` apaga sobras locais aprovadas

- **depende-de**: [T9]
- **requisito**: `gitignore-padrao/16` — QUANDO o humano aprova o lote com sobras locais O SISTEMA DEVE apagá-las do disco respeitando a retirada de itens; sem aprovação, nada é apagado
- **decisões relevantes**: cleanup apaga sobras locais com sim.
- **interfaces**: `le_lote` aceita a seção nova. `pre_checa` do item local: dentro de `docs/audora/`, existe, NÃO rastreado (rastreado → `rastreado no git — use o tipo próprio`), não protegido. Ordem: itens git (commit, como hoje) → só depois do commit ok, apaga os locais (`unlink`/remoção recursiva da pasta `e2e/<id>/`). Commit falhou → nada local apagado. Lote só local → sem commit. Saída: com git `cleanup: commit <hash> — N item(ns) removido(s)` + `cleanup: M sobra(s) local(is) apagada(s) do disco — sem volta`; só local → apenas a 2ª linha. Falha ao apagar local → `cleanup: falhou em: <item> — <motivo>` (exit 1) depois do commit já feito, dizendo `cleanup: commit <hash> mantido; sobras locais restantes no disco`.
- **ponto de mudança**: `hooks/cleanup:382-391` (`le_lote`), `:421-437` (`aplica_item`), `:501-525` (`pre_checa`), `:541-563` (`aplicar`).
- **teste**: `tests/test-cleanup-local.sh` — casos "gitignore-padrao/16 apaga o aprovado", "/16 respeita retirada", "/16 sem aprovação nada apagado", "/16 lote misto", "/16 commit falha não apaga local", "/16 recusa rastreado como local".
- **asserções**: lote = relatório inteiro → os 4 itens somem do disco (pasta `e2e/d/` inteira), HEAD inalterado, stdout `cleanup: 4 sobra(s) local(is) apagada(s) do disco — sem volta`; lote sem a linha `- docs/audora/specs/d-escopo.md | nó d delivered` → spec fica, 3 apagados; sem rodar `aplicar` (humano reprovou) → `snap` igual; lote misto (spec rastreada de `d2` em `spec de nó entregue` + local) → 1 commit só com o rastreado e as duas linhas de saída; `.git/hooks/pre-commit` `exit 1` no misto → exit 1, linhas de falha da cleanup, locais seguem no disco; lote à mão com caminho rastreado sob `## sem volta (fora do git)` → exit 1, `cleanup: falhou em: - <linha> — rastreado no git — use o tipo próprio`, nada alterado.
- **ler**: `hooks/cleanup:374-563`
- **done quando**: testes verdes; `bash tests/run.sh` exit 0.

- [ ] **red** — `bash tests/test-cleanup-local.sh` falha nos casos de `aplicar` (`lote vazio` / arquivos ainda no disco)
- [ ] **green** — passa; `bash tests/test-skill-cleanup.sh` e `bash tests/run.sh` exit 0
- [ ] **commit** — `git add hooks/cleanup tests/test-cleanup-local.sh && git commit -m "feat(gitignore-padrao/16): cleanup apaga do disco as sobras locais aprovadas"`

## Tarefa 11: texto — skill cleanup e READMEs

- **depende-de**: [T10, T5]
- **requisito**: `gitignore-padrao/15` e `gitignore-padrao/16` (o que a skill mostra e pede ao humano) · documentação das pastas locais e do `hooks/versionamento`
- **decisões relevantes**: cleanup lista e apaga sobras locais com sim.
- **interfaces**: `skills/cleanup/SKILL.md` tabela de tipos ganha `| sem volta (fora do git) | spec, plano e e2e (com a pasta de evidência) de nó delivered ou discarded e caçada sem nó vivo, só no disco — apagar não tem volta no git |`; fluxo 4 explica a seção; fluxo 7 reporta `cleanup: M sobra(s) local(is) apagada(s) do disco — sem volta` sem oferecer `git revert` para elas. READMEs EN/PT: lista de pastas (`README.pt-BR.md:353-358`, `README.md:354-358`) marca specs/planos/e2e/depuracao como locais (fora do git pelo bloco do `.gitignore`) e cita `hooks/versionamento`; blocos de código idênticos EN/PT.
- **ponto de mudança**: `skills/cleanup/SKILL.md:25-42,59-60,76-81`; `README.md:354-358`; `README.pt-BR.md:353-358`.
- **teste**: `tests/test-gitignore-padrao.sh` caso "gitignore-padrao/15,/16 skill cleanup"; `tests/test-docs.sh` (blocos EN/PT).
- **asserções**: cleanup SKILL achatado contém `sem volta (fora do git)` e `apagar não tem volta no git`; READMEs contêm `hooks/versionamento`; `bash tests/test-docs.sh` verde; cleanup SKILL ≤ 250 linhas.
- **ler**: `skills/cleanup/SKILL.md:1-107`, `README.md:340-360`, `README.pt-BR.md:340-360`
- **done quando**: testes verdes; `bash tests/run.sh` exit 0; gate `bash hooks/gate gitignore-padrao` sai 0.

- [ ] **red** — `bash tests/test-gitignore-padrao.sh` falha no caso da skill cleanup
- [ ] **green** — passa; `bash tests/run.sh` exit 0; `bash hooks/gate gitignore-padrao` exit 0
- [ ] **commit** — `git add skills/cleanup/SKILL.md README.md README.pt-BR.md tests/test-gitignore-padrao.sh && git commit -m "docs(gitignore-padrao/15): skill cleanup e READMEs explicam as sobras locais (/16)"`
