# sync-mecanizado — histórico frio

> Duas revisões adversariais. A primeira atacou o PLANO (11 altos, antes de
> virar código); a segunda atacou o DIFF (4 altos + mutation testing).

## 1ª revisão — do plano (2026-09-02)

11 achados altos. Os principais: base do diff por `--grep` trazia 43 arquivos
contra 5 reais; a pré-condição de árvore limpa abortaria 100% das vezes (o
sync é UM commit no fim); `memory-validate`/`memory-guard` saem 0 para nó
arquivado, o que tornava a auto-validação impossível; a fixture commitaria no
repositório REAL se falhasse ao montar; `sed` com `|` no replacement e `&` no
título destruindo a linha.

Resultado: desenho trocado de "escreve direto" para "emite os comandos", base
corrigida para `--diff-filter=A`, fixture blindada. **Todos fechados**,
confirmados por mutação na 2ª revisão.

## 2ª revisão — do diff (2026-09-03)

**Altos, os 3 primeiros reproduzidos por mim:**

- **Seta dupla**: `titulo` é `$3` de `awk -F' | '`, e numa linha já
  `delivered` o `$3` é `Título → caminho`. O script concatena ` → $no` de novo
  e emite `... → caminho → caminho`. Nenhum hook pega. Fere /2 e /6.
- **Idempotência mente**: campo `arquivos:` AUSENTE dá `arq_atual=""`, que é
  `!= "arquivos: []"`, então o script diz "nada a fazer" com o nó vazio.
  `arquivos: []` com espaço à direita idem.
- **Item 6 do SKILL.md com duas ordens**: o parágrafo novo manda `delivered` +
  `git mv` primeiro; a lista de bullets logo abaixo (intocada) manda preencher
  `arquivos:` antes e arquivar por último. Seguindo os bullets depois do mv,
  `memory-validate` BLOQUEIA qualquer Edit no `MEMORY.md` (exit 2).
- **Super-inclusão**: `base..HEAD` pega tudo que entrou depois da abertura do
  nó, inclusive outras demandas. Retro-run real emitiu 17 caminhos contra 5.

**Mutation testing: 24 de 44 mutações passam VERDE.** Não testados de fato: a
derivação da base (`diff-head1` passa), os 3 ramos da idempotência isolados,
quase todos os `die`, o ramo "glob ambíguo", o formato da lista, e escrita
fora do worktree / dentro de `.git/` / escrita-e-desfaz.

**Médio relevante**: a justificativa "é o Edit que faz os hooks dispararem" é
falsa para a linha 1 — ela vai para `docs/audora/arquivo/`, caminho que os
dois hooks IGNORAM. Só o Edit em `MEMORY.md` dispara.

**Baixo**: CR não tratado (clone fresco vem CRLF; `awk` do Git-for-Windows
come, o do Linux não); `-historico.md` não é excluído da lista; a seção
`## Fechamento LIGHT` não cita o gerador; argumento extra ignorado em silêncio.

## 3ª revisão — do diff corrigido (2026-09-04)

Reprovada de novo. **7 das 16 mutações nomeadas fecharam; 9 seguem abertas; 14
NOVAS apareceram.** Placar de mutação: 24/44 verdes (55%) → 30/66 (45%).

**Altos:**

- **Regressão minha**: o corte do título no ` → `, feito para matar a seta
  dupla, mutila título legítimo. `Migrar CSV → Parquet` vira `Migrar CSV`.
  Reproduzido.
- **O guarda estático de /10 é peneira**: 9 escritas reais passam verdes,
  inclusive uma que corrompe o `MEMORY.md` e **desarma os dois hooks para
  sempre** (comentando a linha 1 do schema). Pior, o filtro do próprio caso
  remove linhas que começam com `echo `, então `echo pwn > /tmp/x` escapa.
  Lista negra de string não fecha isso.
- **O aviso de super-inclusão não é testado**: `alheios=1` fixo passa verde, e
  a contagem invertida (`grep -cF` em vez de `grep -vcF`) também.
- **A base do diff segue sem prova**: `$base..HEAD` → `HEAD~1..HEAD` passa
  verde, porque na fixture os dois ranges coincidem.

**Médios:** idempotência ainda mente para `[ ]`, `"[]"`, `null`; a dupla ordem
MIGROU para `## Fechamento LIGHT`, que mantém a ordem antiga e não cita o
gerador — e a correção do item 6 apagou o ponteiro que existia para lá; o
`-historico.md` entra na lista com caminho já morto; 7 dos 11 `die` sem prova,
mascarados em cadeia.

**Diagnóstico:** o script faz cirurgia de string num formato Markdown desenhado
para humano e LLM, não para parser. Cada borda (título com seta, `arquivos:`
com espaço esquisito, id que é substring) vira caso especial novo, e cada
correção abriu buraco em outro lugar — três rodadas seguidas. O retorno
marginal está caindo: a própria sugestão do revisor para provar /10 é snapshot
recursivo de mtime+hash da árvore inteira, incluindo `.git/` e um diretório
sentinela fora do repo, a cada caso de teste.
