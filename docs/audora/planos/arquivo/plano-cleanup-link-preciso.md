# Plano — cleanup-link-preciso: Link preciso da cleanup

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** a cleanup só trata como link quebrado o link cujo alvo foi versionado e sumiu; link para caminho nunca versionado vira aviso `## nunca existiu` fora do lote; a seção Aprendizados do `MEMORY.md` sai da varredura e da troca; a nota do link quebrado diz "já não existia … (link limpo pela cleanup)".

**Nó do MEMORY:** `cleanup-link-preciso` (MEMORY.md) — 13 critérios, categoria MEDIUM (sem portão de plano).

**Arquitetura da mudança:** tudo no `hooks/cleanup` (perl), reusando o `existiu()` que já existe (pathspec literal, `--full-history`, repo sem HEAD = nunca existiu). (1) `classifica_links` divide o alvo ausente em `item('link quebrado', …)` se `existiu`, senão `@NUNCA`, que o `relatorio` imprime depois de `## não tocado`, fora de `@SECOES` — então `total`/`contar` e o `le_lote` do `aplicar` já o ignoram sem código novo. (2) `linhas_de_link` ganha o nome do arquivo e, para `MEMORY.md`, pula as linhas da seção `## Aprendizados` — vale para `links` (varredura e `%REF`) e `troca_links` (aplicar) de uma vez. (3) `troca_links` recebe a função de nota: `nota` (arquivo apagado, como hoje) ou `nota_quebrado` (link quebrado); `tokens` passa a não ler a nota nova como link; `pre_checa` recusa item de link quebrado cujo alvo nunca foi versionado.

**Arquivos lidos antes de planejar:**
- `hooks/cleanup:1-503` — arquivo inteiro: `existiu` 109-113, `classifica_links` 247-257, `relatorio` 321-333, `tokens` 195-204 (lookahead da nota), `percorre`/`md` 205-223, `linhas_de_link` 224-235, `links` 236-245, `carrega_git`/`%REF` 266-280, `nota` 341, `le_lote` 343-353 (só lê seções de `@SECOES`), `troca_links` 355-367, `apaga_arquivo` 375-380, `aplica_item` 383-399, `pre_checa` 442-460, `aplicar` 476-498.
- `tests/test-skill-cleanup.sh:1-180` — helpers `mkproj`/`addc`/`runc`/`snap`/`assert_line`/`secao`/`nov`/`mkt2`; `corpo_d` 137-159 (L1/L2 apontam alvos nunca versionados); t4 160-176 (/10 detecção, `- z` no índice → alvo nunca versionado).
- `tests/test-skill-cleanup.sh:265-564` — sem commit 265-273; t6 275-307 (link quebrado em arquivo sujo, alvo nunca versionado); `HOJE`/`nota()` 310-311; t7 337 (nota de apagado); t8 370-403 (troca L1/L2, idempotência 402-403); `lote_de` 407; t9a/t9b 409-431; t10d 474-483 (alvo nunca versionado); `mkt11` 488-496 (alvo nunca versionado); t11r 528-535; asserts da skill 537-553.
- `tests/lib.sh:1-21` — `assert_*`, `run_hook`, `$SP`, `$ROOT`.
- `skills/cleanup/SKILL.md:1-97` — tabela 22-30 (linha link quebrado 30), "Fora do lote" 32-35, passo 4 52-53, passo 6 58-66 (nota única).
- `README.pt-BR.md:290-304` e `README.md:287-303` — descrevem só a nota de arquivo apagado (segue verdadeira); não entram no plano.
- `PRD.md:95-110,145-184` — metas 6 e 7 (origem do nó); PRD só muda no sync.
- `MEMORY.md:90-96` — linha 94 (aprendizado 2026-10-02 execute) cita caminho de fixture: é o falso positivo que hoje sai como `MEMORY.md:94` na varredura deste repo.

**Conflitos MEMORY vs código encontrados:** nenhum.

## Notas de sessão

- 2026-10-03 (plan): varredura deste repo antes da mudança: só `- MEMORY.md:94 | não tocado: mudança não commitada` + `cleanup: nada a limpar`; `contar` = 0.
- Este plano mora em docs/audora/planos e é varrido: caminho de fixture inexistente só dentro de bloco de código (fence é ignorado). Abaixo, `<D>` = o nó arquivado da fixture (arquivo `2026-01-01-d.md` na pasta `arquivo/` de docs/audora); caminhos curtos como `e2e/nunca.md` são relativos a docs/audora.
- Gate antes de CADA commit (aprendizado 2026-09-30): `bash hooks/gate cleanup-link-preciso`, saída registrada aqui.
- 2026-10-03 (execute) T1: migração das fixtures (helper `sumiu`) verde ANTES do script — `PASS=247 FAIL=0`; red `PASS=251 FAIL=15` (tudo caía em link quebrado; t4 com 6 em vez de 3, total 10); green `PASS=266 FAIL=0`; `run.sh: 0 arquivo(s) de teste com falha`; `GATE: passou` → commit `aa9da91`. Desvio pequeno: o ajuste da idempotência do t8 (última linha em vez da saída inteira) entrou já na T1, senão a T1 não fechava verde.
- T2: red `PASS=274 FAIL=7` (nota antiga em L1/L2/t10d; /6 aplicava com exit 0); /5 já passava sem código (previsto). Green `PASS=281 FAIL=0`. Mutação: lookahead sem "já não existia" → 4 FAIL (idempotência e /7), restaurado. `GATE: passou` → `e567a05`.
- T3: red `PASS=286 FAIL=5` (Aprendizados varrida e reescrita, MEMORY.md no commit); green `PASS=291 FAIL=0`; `GATE: passou` → `9af52ac`.
- T4: red `PASS=292 FAIL=6`; green `PASS=298 FAIL=0`; SKILL.md 100 linhas; `GATE: passou` → `6253833`.
- T5 (dogfood, depois da T4): `bash hooks/cleanup contar` → `0`; `bash hooks/cleanup varrer` → só `cleanup: nada a limpar` (o `MEMORY.md:94` sumiu); `bash tests/run.sh` → `run.sh: 0 arquivo(s) de teste com falha`.

### Decisões tomadas pela IA

- Item de `## nunca existiu`: `- <arquivo>:<linha> | aponta <alvo como escrito> nunca versionado`; seção impressa depois de `## não tocado`, itens ordenados como as demais (`sort`).
- `## nunca existiu` ignora o estado git do arquivo citador (sujo ou fora do git continua listado: é só aviso) e pula arquivo que sai no lote (mesmo `%CANDIDATO` de hoje).
- Caminho resolvido acima da raiz (começa com `..`) = nunca existiu, sem chamar o git (evita `fatal: … outside repository` no relatório).
- Motivo da recusa da /6: `link para caminho nunca versionado: <caminho resolvido da raiz>`.
- Seção Aprendizados = de `## Aprendizados` até o próximo `## `, só no `MEMORY.md` da raiz.
- READMEs não mudam (descrevem só a nota de arquivo apagado, que segue igual).
- (execute) `pre_checa` da /6 só confere quando o item tem `:<linha>` e motivo `aponta … inexistente` (lote à mão malformado segue para o `link não encontrado na linha` de sempre, sem warning do perl).
- (execute) Aviso `nunca existiu` reusa o `%ITEM_VISTO` com chave própria: o mesmo link 2x na linha é 1 aviso.

---

## Tarefa 1: varrer separa `## nunca existiu` do lote

- **depende-de**: []
- **requisito**:
  - `cleanup-link-preciso/1` — QUANDO a varredura acha link para caminho inexistente que nunca foi versionado em commit alcançável do HEAD O SISTEMA DEVE listá-lo na seção `## nunca existiu` do relatório, fora do lote, com `arquivo:linha` e o caminho citado
  - `cleanup-link-preciso/2` — QUANDO a varredura acha link para caminho que já foi versionado em commit alcançável do HEAD e não existe mais O SISTEMA DEVE listá-lo em `## link quebrado`, no lote, como antes
  - `cleanup-link-preciso/3` — QUANDO `contar` roda O SISTEMA DEVE devolver o mesmo total do lote do `varrer`, sem contar itens de `## nunca existiu`
  - `cleanup-link-preciso/4` — QUANDO o lote fica vazio e o relatório só tem itens de `## nunca existiu` (com ou sem `## mantido`/`## não tocado`) O SISTEMA DEVE mostrar os avisos e terminar com `cleanup: nada a limpar`
  - `cleanup-link-preciso/11` — QUANDO o repositório ainda não tem nenhum commit O SISTEMA DEVE listar todo link para caminho inexistente em `## nunca existiu` e terminar a varredura sem erro
- **decisões relevantes**: decisão do humano 2026-10-03 (aviso fora do lote, não fora do relatório); decisões da IA acima (formato, ordem, estado git, `..`).
- **interfaces**: consome `existiu($caminho) → 1|''` (já existe). Produz `my @NUNCA` (linhas prontas), `sub nunca($alvo, $raw)` (push com dedupe por `"$alvo\0$raw"`), `existiu` com guarda `return '' if $_[0] =~ m{^\.\.(/|$)};`.
- **ponto de mudança**:
  - `hooks/cleanup:110` — `existiu`: guarda de `..` antes do `tem_head`.
  - `hooks/cleanup:83` — declarar `@NUNCA` junto de `@AVISOS, @MANTIDO, @NAO_TOCADO`; `nunca()` logo depois de `item()` (86-89).
  - `hooks/cleanup:254` — `classifica_links`: alvo ausente → `existiu($k->[2]) ? item('link quebrado', …) : nunca("$f:$k->[0]", $k->[1])`.
  - `hooks/cleanup:330` — `relatorio`: `push @o, '## nunca existiu', sort @NUNCA if @NUNCA;` depois de `## não tocado`.
- **teste**: `tests/test-skill-cleanup.sh`
  - passo 0 (migração, suíte segue verde ANTES da implementação): helper `sumiu <dir> <caminho>...` ao lado de `addc` (linha 22) — cria cada caminho, `git add`, commit, `git rm -q`, commit; chamado no início de `corpo_d` (alvos L1 e L2), em t4 (alvo da linha `- z` do índice), em t6 (alvo de `[q]`), em t10d (alvo de `[a]`/`[b]`) e no `mkt11` logo após o `mkproj` (alvo do link de `e2e-d.md`). Cabeçalho 2-4 ganha `# cleanup-link-preciso/1..13 — …`.
  - `corpo_d` ganha, depois de L2, as linhas L3 e L4 (fence abaixo). Casos novos: "cleanup-link-preciso/1 …", "/2 …", "/3 …", "/4 …", "/11 …".
- **asserções** (`$L3`/`$L4`/`$LN`/`$LZ` = número da linha, por `grep -n`):

```
corpo_d, depois de L2:
  L3 [n](../e2e/nunca.md) e `docs/audora/specs/nunca-token.md`
  L4 [fora](../../../../fora.md)

t4 varrer (/1,/2,/3):
  secao 'nunca existiu' == exatamente 3 linhas:
    - docs/audora/arquivo/2026-01-01-d.md:$L3 | aponta ../e2e/nunca.md nunca versionado
    - docs/audora/arquivo/2026-01-01-d.md:$L3 | aponta docs/audora/specs/nunca-token.md nunca versionado
    - docs/audora/arquivo/2026-01-01-d.md:$L4 | aponta ../../../../fora.md nunca versionado
  secao 'link quebrado' == exatamente 3 (as de hoje: L1, L2, MEMORY.md:$LZ) e não contém 'nunca'
  cabeçalhos em ordem: '## spec de nó entregue;## plano arquivado;## relatório e2e;## depuração velha;## link quebrado;## nunca existiu;'
  última linha == 'total: 7 item(ns) no lote'; saída não contém 'fatal'
  contar → '7'

/4 (fixture mkproj + `\n[n](../e2e/nunca.md)\n` no <D>, commitado):
  varrer, saída exata (3 linhas):
    ## nunca existiu
    - docs/audora/arquivo/2026-01-01-d.md:$LN | aponta ../e2e/nunca.md nunca versionado
    cleanup: nada a limpar
  contar → '0'
/4 com não tocado (t6: além de [q], anexar `[n](../e2e/nunca.md)` ao <D> sujo):
  secao 'nunca existiu' contém '- docs/audora/arquivo/2026-01-01-d.md:$LN | aponta ../e2e/nunca.md nunca versionado'
  secao 'não tocado' segue com a linha do [q] (alvo agora versionado e removido)
  última linha 'total: 1 item(ns) no lote'; contar → '1'

/11 (repo sem commit, como 265-273, índice com `- z | delivered | Z → docs/audora/arquivo/sumiu.md`):
  varrer exit 0, saída exata:
    ## nunca existiu
    - MEMORY.md:$LZ | aponta docs/audora/arquivo/sumiu.md nunca versionado
    cleanup: nada a limpar
  contar exit 0 → '0'
```

- **ler**: `hooks/cleanup:83-113,247-257,321-333`; `tests/test-skill-cleanup.sh:20-24,135-176,265-307,472-496`.
- **done quando**: casos /1 /2 /3 /4 /11 verdes, asserts antigos de t4/t6/t8/t9/t10d/t11 verdes com as fixtures migradas, `bash tests/run.sh` exit 0.

- [x] **migra** — passo 0 aplicado; `bash tests/test-skill-cleanup.sh` → `FAIL=0` (prova que a migração não muda o comportamento atual)
- [x] **red** — casos novos escritos; `bash tests/test-skill-cleanup.sh` falha com `sem a linha` na linha de L3 esperada em `## nunca existiu` (asserções acima) (e t4 com 6 links quebrados em vez de 3)
- [x] **green** — `bash tests/test-skill-cleanup.sh` → `FAIL=0`; `bash tests/run.sh` → `run.sh: 0 arquivo(s) de teste com falha`; `bash hooks/gate cleanup-link-preciso` passa (registrar nas notas)
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(cleanup-link-preciso/1-4,11): link para caminho nunca versionado vira aviso fora do lote"`

## Tarefa 2: aplicar — nota de link quebrado, seção ignorada e recusa do nunca versionado

- **depende-de**: [Tarefa 1]
- **requisito**:
  - `cleanup-link-preciso/5` — QUANDO o lote aprovado traz a seção `## nunca existiu` O SISTEMA DEVE ignorá-la no `aplicar`, sem trocar nem commitar nada dela
  - `cleanup-link-preciso/6` — QUANDO o lote aprovado traz em `## link quebrado` um link cujo alvo nunca foi versionado (lote montado à mão) O SISTEMA DEVE recusar na pré-checagem, nomeando o item, sem alterar nada
  - `cleanup-link-preciso/7` — QUANDO o `aplicar` troca um link quebrado (alvo existiu e sumiu antes do lote) O SISTEMA DEVE escrever a nota `` `<caminho>` já não existia em AAAA-MM-DD (link limpo pela cleanup) — recuperável no git``
  - `cleanup-link-preciso/8` — QUANDO o `aplicar` apaga um arquivo do lote O SISTEMA DEVE continuar trocando os links para ele pela nota `` `<caminho>` removido em AAAA-MM-DD pela cleanup — recuperável no git``, como antes
- **decisões relevantes**: decisão do humano 2026-10-03 (notas distintas); motivo da /6 fixado nas decisões da IA.
- **interfaces**: produz `sub nota_quebrado { "`$_[0]` já não existia em $DATA (link limpo pela cleanup) — recuperável no git" }`; `troca_links($f, $quer, $nota, $so_linha)` — `$nota` é coderef (`\&nota` ou `\&nota_quebrado`), chamado com o caminho da raiz. `nota` (341) inalterada.
- **ponto de mudança**:
  - `hooks/cleanup:198` — `tokens`: lookahead `(?!` removido em)` → `(?!` (?:removido|já não existia) em)` (a nota nova não pode virar link na varredura seguinte).
  - `hooks/cleanup:341` — `nota_quebrado` ao lado de `nota`.
  - `hooks/cleanup:356-363` — `troca_links` com o parâmetro `$nota` no lugar da chamada fixa `nota($_[1])`.
  - `hooks/cleanup:378` — `apaga_arquivo` passa `\&nota`.
  - `hooks/cleanup:395` — `aplica_item` (link quebrado) passa `\&nota_quebrado`.
  - `hooks/cleanup:448-452` — `pre_checa`, ramo `link quebrado`, depois do `-e $f`: tira `$ln` de `$a` e `$raw` de `aponta (.+) inexistente`; para cada `links($f)` com linha `$ln` e alvo `$raw`, recusa se `!-e` e `!existiu` do caminho resolvido. Link que não está mais na linha não recusa aqui (segue o `link não encontrado na linha` do `aplica_item`, skill-cleanup/14 a).
  - `/5` sem código: `le_lote` (344-353) só lê `@SECOES`; o teste prova.
- **teste**: `tests/test-skill-cleanup.sh` — `notaq()` ao lado de `nota()` (311); t8 (370-403), t7 (337), t10d (483), bloco novo t12 depois de t9 (antes de 472). Casos "cleanup-link-preciso/5 …", "/6 …", "/7 …", "/8 …".
- **asserções**:

```
notaq() { printf '`%s` já não existia em %s (link limpo pela cleanup) — recuperável no git' "$1" "$HOJE"; }

/7 (t8, linhas 393-394 e t10d 483 trocam nota → notaq):
  <D> tem a linha  "L1 $(notaq docs/audora/e2e/nao-existe.md) quebrado"
  <D> tem a linha  "L2 Ver $(notaq docs/audora/specs/sumiu.md) aqui."
  t10d: "Dois: $(notaq docs/audora/e2e/x.md) e $(notaq docs/audora/e2e/x.md)"
/8 (inalterados, com nota): t7 337, t8 392 (v.md → memory/s.md), confere11 511;
  t7: <D> não contém 'já não existia'
/7 idempotência (t8, substitui 402-403): varrer logo após o aplicar →
  última linha 'cleanup: nada a limpar'; secao 'link quebrado' vazia;
  saída não contém 'nao-existe.md' nem 'specs/sumiu.md';
  secao 'nunca existiu' == as 3 linhas de L3/L4 + '- docs/audora/decisoes-vivas.md:<n> | aponta nunca-dv.md nunca versionado' (4 linhas)

/5 (t8: mkt8 anexa `\n- ver [n](nunca-dv.md)\n` ao decisoes-vivas.md antes do commit; lote = saída do varrer, que traz '## nunca existiu'):
  lote salvo contém '## nunca existiu'
  aplicar exit 0; total do lote segue 'total: 4 item(ns) no lote'
  <D> mantém exatamente:  L3 [n](../e2e/nunca.md) e `docs/audora/specs/nunca-token.md`
                          L4 [fora](../../../../fora.md)
  decisoes-vivas.md idêntico ao HEAD~1 e fora de `git show --name-only HEAD`
  corpo do commit não contém 'nunca'

/6 (t12: mkt2 + `\nN [n](../e2e/nunca.md)\n` no <D>, commitado; $LN = linha do N):
  lote_de: '## depuração velha' '- docs/audora/depuracao/cacada-2026-01-01.md | sem nó vivo ligado'
           '## link quebrado'  "- docs/audora/arquivo/2026-01-01-d.md:$LN | aponta ../e2e/nunca.md inexistente"
  aplicar → exit 1
  saída contém "cleanup: falhou em: - docs/audora/arquivo/2026-01-01-d.md:$LN | aponta ../e2e/nunca.md inexistente — link para caminho nunca versionado: docs/audora/e2e/nunca.md"
  saída contém 'cleanup: lote desfeito, nada commitado'
  snap igual ao de antes (cacada-2026-01-01.md segue no disco)
```

- **ler**: `hooks/cleanup:195-204,338-367,375-399,442-460`; `tests/test-skill-cleanup.sh:309-311,335-340,370-403,405-421,472-483,502-513`.
- **done quando**: /5 /6 /7 /8 verdes, skill-cleanup/14 (a)(b) e cleanup-lote-encadeado verdes, `bash tests/run.sh` exit 0.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha com `sem a linha` no L1 com `notaq` (a nota ainda diz "removido em") e com `/6 … → exit 1 — esperado '1', obtido '0'`
- [x] **green** — `bash tests/test-skill-cleanup.sh` → `FAIL=0`; `bash tests/run.sh` → `run.sh: 0 arquivo(s) de teste com falha`; `bash hooks/gate cleanup-link-preciso` passa (registrar)
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(cleanup-link-preciso/5-8): nota própria do link quebrado, nunca existiu fora do aplicar e recusa do alvo nunca versionado"`

## Tarefa 3: seção Aprendizados fora da varredura e da troca

- **depende-de**: [Tarefa 2]
- **requisito**:
  - `cleanup-link-preciso/9` — QUANDO uma linha da seção Aprendizados do `MEMORY.md` cita caminho inexistente (versionado ou não) O SISTEMA DEVE deixá-la fora do relatório inteiro (nem lote, nem `## nunca existiu`)
  - `cleanup-link-preciso/10` — QUANDO o lote apaga um arquivo citado numa linha da seção Aprendizados O SISTEMA DEVE deixar essa linha intacta e continuar trocando os links nos demais citadores
- **decisões relevantes**: decisão do humano 2026-10-03 (Aprendizados fora da varredura); fora-de-escopo: Aprendizados continua contando para `## sem referência` (`texto_vivo`, 147-151, não muda).
- **interfaces**: `linhas_de_link(\@linhas, $arquivo) → índices 0-based`; com `$arquivo eq 'MEMORY.md'`, linha dentro de `^## Aprendizados(\s|$)` até o próximo `^## ` não entra (o próprio cabeçalho também não). Chamadores: `links` (240) e `troca_links` (360) passam `$f`.
- **ponto de mudança**: `hooks/cleanup:225-234` (`linhas_de_link`), `hooks/cleanup:240` e `hooks/cleanup:360` (chamadas).
- **teste**: `tests/test-skill-cleanup.sh` — bloco novo t13 depois de t12. Casos "cleanup-link-preciso/9 …", "/10 …".
- **asserções**:

```
t13: mkproj; sumiu docs/audora/specs/velha.md; inserir em MEMORY.md logo após '## Aprendizados [carga: sempre]' + linha em branco:
  - 2026-01-01 | execute | fixture cita `docs/audora/arquivo/2026-01-01-x.md` e [v](docs/audora/specs/velha.md)
  commit
/9 varrer → saída exata 'cleanup: nada a limpar'; contar → '0'
/10: addc docs/audora/specs/d-escopo.md '# spec d'; anexar à mesma linha de Aprendizados ' e `docs/audora/specs/d-escopo.md`'
     e ao <D> '\nSpec: docs/audora/specs/d-escopo.md\n'; commit
  varrer: secao 'spec de nó entregue' == '- docs/audora/specs/d-escopo.md | nó d delivered'; sem 'MEMORY.md:' na saída
  aplicar (lote = saída do varrer) → exit 0
  a linha de Aprendizados em MEMORY.md é byte a byte a de antes (assert_line com o texto inteiro)
  <D> tem a linha "Spec: $(nota docs/audora/specs/d-escopo.md)"
  git show --name-only --format= HEAD | sort ==
    docs/audora/arquivo/2026-01-01-d.md
    docs/audora/specs/d-escopo.md
  run_hook memory-validate MEMORY.md → code 0
```

- **ler**: `hooks/cleanup:224-245,355-367`; `tests/test-skill-cleanup.sh:9-24`.
- **done quando**: /9 /10 verdes; t4 (`MEMORY.md:$LZ` no índice, depois de Aprendizados) segue verde; `bash tests/run.sh` exit 0.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha em /9 com `esperado 'cleanup: nada a limpar'` (saída traz `## link quebrado` com a linha de Aprendizados apontando `specs/velha.md`, e `## nunca existiu` com `arquivo/2026-01-01-x.md`)
- [x] **green** — `bash tests/test-skill-cleanup.sh` → `FAIL=0`; `bash tests/run.sh` → `run.sh: 0 arquivo(s) de teste com falha`; `bash hooks/gate cleanup-link-preciso` passa (registrar)
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(cleanup-link-preciso/9,10): seção Aprendizados do MEMORY fica fora da varredura e da troca de link"`

## Tarefa 4: skill explica `## nunca existiu` e as duas notas

- **depende-de**: [Tarefa 2]
- **requisito**: `cleanup-link-preciso/12` — QUANDO a skill cleanup apresenta o relatório O SISTEMA DEVE explicar `## nunca existiu` como aviso fora do lote (erro de digitação, exemplo ou fixture), que o humano corrige à mão se quiser
- **decisões relevantes**: Constituição — SKILL.md ≤ 250 linhas, prosa PT; skill-ferramenta sem bloco de fechamento.
- **interfaces**: nenhuma (texto).
- **ponto de mudança**:
  - `skills/cleanup/SKILL.md:30` — linha link quebrado: "link em `MEMORY.md` (fora da seção Aprendizados) ou `docs/audora/` para arquivo que existiu no histórico e não existe mais (fora de frontmatter e de bloco de código)".
  - `skills/cleanup/SKILL.md:33-35` — novo bullet: "`## nunca existiu` — link para caminho nunca versionado (erro de digitação, exemplo ou fixture): aviso fora do lote, o humano corrige à mão se quiser; o `aplicar` ignora a seção."
  - `skills/cleanup/SKILL.md:52-53` — passo 4: saída que termina em `cleanup: nada a limpar` com `## nunca existiu` → mostrar os avisos e dizer "nada a limpar"; explicar `## nunca existiu` junto de `## mantido` e `## não tocado`.
  - `skills/cleanup/SKILL.md:60-63` — passo 6: link quebrado vira `` `<caminho>` já não existia em AAAA-MM-DD (link limpo pela cleanup) — recuperável no git``; link para arquivo apagado pelo lote segue `` `<caminho>` removido em AAAA-MM-DD pela cleanup — recuperável no git``; link quebrado de alvo nunca versionado é recusado na conferência.
- **teste**: `tests/test-skill-cleanup.sh:537-553` — casos "cleanup-link-preciso/12 …".
- **asserções**:

```
sk contém: '## nunca existiu' ; 'erro de digitação, exemplo ou fixture' ; 'corrige à mão'
           'já não existia em AAAA-MM-DD (link limpo pela cleanup) — recuperável no git'
           'removido em AAAA-MM-DD pela cleanup — recuperável no git' ; 'fora da seção Aprendizados'
linha de sk com '`## nunca existiu` —' contém 'fora do lote'
SKILL.md ≤ 250 linhas (assert existente 547)
```

- **ler**: `skills/cleanup/SKILL.md:20-73`; `tests/test-skill-cleanup.sh:537-553`.
- **done quando**: /12 verde, assert ≤ 250 linhas verde, `bash tests/run.sh` exit 0.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha com `skill … — não contém '## nunca existiu'`
- [x] **green** — `bash tests/test-skill-cleanup.sh` → `FAIL=0`; `bash tests/run.sh` → `run.sh: 0 arquivo(s) de teste com falha`; `bash hooks/gate cleanup-link-preciso` passa (registrar)
- [x] **commit** — `git add skills/cleanup/SKILL.md tests/test-skill-cleanup.sh && git commit -m "docs(cleanup-link-preciso/12): skill explica nunca existiu e as duas notas"`

## Tarefa 5: dogfood neste repositório

- **depende-de**: [Tarefa 1, Tarefa 2, Tarefa 3, Tarefa 4]
- **requisito**: `cleanup-link-preciso/13` — QUANDO `contar` roda neste repositório depois da entrega O SISTEMA DEVE devolver 0
- **decisões relevantes**: aprendizado 2026-10-03 (rodar a ferramenta no próprio repo antes do merge). Sem teste na suíte: o repo ganha sobras legítimas entre entregas (plano arquivado até a próxima cleanup) e o assert ficaria instável.
- **interfaces**: nenhuma.
- **ponto de mudança**: nenhum arquivo; achado → debug, não remendo aqui.
- **teste**: execução real, saída colada nas notas de sessão.
- **asserções**:

```
bash hooks/cleanup contar            → 0
bash hooks/cleanup varrer            → nenhuma linha com 'MEMORY.md:' (o falso positivo da linha 94 some);
                                       última linha 'cleanup: nada a limpar'
bash tests/run.sh                    → 'run.sh: 0 arquivo(s) de teste com falha'
```

- **ler**: nada novo.
- **done quando**: as três saídas acima conferidas e registradas nas notas de sessão.

- [x] **roda** — os três comandos acima, na raiz do repo
- [x] **registra** — saídas nas notas de sessão deste plano (sem commit de código)
