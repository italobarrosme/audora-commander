# validate — sync pós-aprovação (item 6)

> Reference da skill `validate`, lida só quando o trabalho aprovado entra na
> main (merge ou commit direto). O roteador (`../SKILL.md`) segue valendo.

**A ordem importa**: o índice e a pasta têm de ficar coerentes a cada passo,
senão `memory-validate` bloqueia a próxima escrita.

1. **Julgamento, primeiro** (só você faz): consolidar o bloco `delta` no
   corpo do nó; promover a `docs/audora/decisoes-vivas.md` as decisões
   aprovadas no portão, só as que passaram no filtro de entrada
   (`decisoes-vivas.md` desta pasta); e consolidar os aprendizados na seção
   Aprendizados do `MEMORY.md` (skill memory, compactar — dedupe por grep).
2. **Estado e movimento**: nó → `delivered` (nó primeiro, índice depois) e
   `git mv docs/audora/memory/<id>.md docs/audora/arquivo/AAAA-MM-DD-<id>.md`.
   Nó com `<id>-historico.md`: mover os DOIS, mesmo prefixo de data, e
   corrigir o ponteiro relativo no corpo. Plano →
   `docs/audora/planos/arquivo/` (LIGHT não tem plano).
3. **`arquivos:` do diff real.** A base da demanda é o **pai do commit que
   CRIOU o arquivo do nó** — nunca por `--grep` na mensagem, que casa
   commit de outra demanda que só CITA o id:
   ```bash
   cria=$(git log --diff-filter=A --format=%H -- "docs/audora/memory/<id>.md" "docs/audora/arquivo/"*"-<id>.md" | tail -1)
   git diff --name-only "$cria^..HEAD"
   ```
   Leia a saída e monte a linha. Três armadilhas:
   - o range vai até HEAD e **pode conter commits de outra demanda** se o
     fluxo não foi sequencial — confira `git log --oneline "$cria^..HEAD"`;
   - o `PRD.md` ainda não foi tocado quando você roda isso (o passo 4 é que
     o toca) — acrescente à lista se for promover;
   - o próprio nó e o `-historico.md` aparecem no caminho ANTIGO, de antes
     do `git mv` — tire os dois da lista.
4. **Promover ao `PRD.md`**: resumo do que foi entregue + data de última
   atualização. Direção única MEMORY → PRD, sempre (vale para toda camada
   derivada: decisoes-vivas e afins fluem DO nó, nunca de volta).
   Tocou o PRD? Acrescente-o à lista `arquivos:`.
5. HOTFIX: regularizar o registro retroativo (nó `hotfix-pending-record`
   → nó completo).
