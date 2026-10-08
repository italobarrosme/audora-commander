# validate — sync pós-aprovação (item 6)

> Reference da skill `validate`, lida só quando o trabalho aprovado entra na
> main (merge ou commit direto). O roteador (`../SKILL.md`) segue valendo.

**A ordem importa**: o índice e a pasta têm de ficar coerentes a cada passo,
senão `memory-validate` bloqueia a próxima escrita.

1. **Julgamento, primeiro** (só você faz): consolidar o bloco `delta` no
   corpo do nó; promover a `docs/audora/decisoes-vivas.md` as decisões
   aprovadas no portão, só as que passaram no filtro de entrada
   (`decisoes-vivas.md` desta pasta); e, se a seção Aprendizados do
   `MEMORY.md` tem linha de aprendizado, movê-las — literal, na mesma ordem,
   para o fim de `docs/audora/aprendizados.md`, sem tocar as que já estão lá:
   ```bash
   [ -f docs/audora/aprendizados.md ] || cp "<raiz do plugin>/templates/aprendizados-template.md" docs/audora/aprendizados.md
   [ -z "$(tail -c1 docs/audora/aprendizados.md)" ] || echo >> docs/audora/aprendizados.md
   perl -ne 'if (/^## /) { $s = /^## Aprendizados/ } print if $s && /^- \d{4}-\d{2}-\d{2} \| /' MEMORY.md >> docs/audora/aprendizados.md
   ```
   e deixar na seção só a linha de ponteiro de `templates/MEMORY-template.md`.
2. **Antes do `git mv`**: conte os critérios do nó com
   `awk '/^## criterios-aceite/{f=1;next} /^## /{f=0} f' docs/audora/memory/<id>.md | grep -cE '^- \*\*<id>/[0-9]+'`.
   Zero e a spec `docs/audora/specs/<id>-escopo.md` tem linha de critério `- **<id>/<n>** — …`
   → copie literalmente cada um (a linha e suas continuações) para
   `## criterios-aceite` do nó. Segue zero → PARE sem arquivar e avise o
   humano: "Nó <id> sem critério numerado — sync parado, nada arquivado."
   **Estado e movimento**: nó → `delivered` (nó primeiro, índice depois) e
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
     o toca) — acrescente-o à lista se for atualizar a foto, e acrescente o
     `CHANGELOG.md` sempre;
   - o próprio nó e o `-historico.md` aparecem no caminho ANTIGO, de antes
     do `git mv` — tire os dois da lista.
4. **Foto do `PRD.md` + linha do `CHANGELOG.md`** (depois do `git mv`: a
   linha cita o caminho arquivado). Direção única MEMORY → PRD, sempre (vale
   para toda camada derivada: decisoes-vivas e afins fluem DO nó, nunca de
   volta).
   - **Foto**: atualize só as seções da foto (o que é, stack, arquitetura,
     metas futuras) que a entrega mudou, e a data de última atualização;
     nunca acrescente parágrafo de histórico de entrega. Meta futura
     entregue sai das metas futuras — a entrega fica só na linha do
     `CHANGELOG.md`.
   - **Ressalva aceita no portão** (linhas `(humano): ressalva aceita —` em
     `## decisoes` do nó) → 1 meta futura "Candidato a nó: ressalvas do `<id>` aceitas no portão.",
     com 1 sub-item por ressalva.
   - **CHANGELOG**: exatamente uma linha no `CHANGELOG.md` da raiz, em toda
     categoria, no formato de `templates/changelog-template.md` (raiz do
     plugin); sem o arquivo, crie-o pelo template.
   - **Conversão** (on-touch): `PRD.md` com histórico de entregas ou com
     mais de 200 linhas → mova o histórico, literal e sem reescrita, para
     `## Histórico até AAAA-MM-DD` do `CHANGELOG.md` (data deste sync) e
     deixe o `PRD.md` como foto com até 200 linhas. O `memory-guard` avisa a
     cada Edit acima do teto: escreva a foto num Write só.
   Tocou o PRD ou o CHANGELOG? Acrescente-os à lista `arquivos:`.
5. HOTFIX: regularizar o registro retroativo (nó `hotfix-pending-record`
   → nó completo).
6. **Sugestão de limpeza**, depois do commit do sync (item sujo não conta):
   `bash "<raiz do plugin>/hooks/cleanup" contar`. N > 0 → 1 linha ao
   humano: "Sobras do processo: N — rode a skill cleanup quando quiser."
   N = 0 → nada. Nunca rode `aplicar` daqui: a limpeza é manual.
