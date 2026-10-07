---
id: cleanup-link-preciso
estado: delivered
origem: humano
depende-de: [skill-cleanup]
arquivos: [CHANGELOG.md, MEMORY.md, PRD.md, hooks/cleanup, skills/cleanup/SKILL.md, tests/test-skill-cleanup.sh, docs/audora/e2e/e2e-cleanup-link-preciso.md, docs/audora/planos/arquivo/plano-cleanup-link-preciso.md]
keywords: [cleanup, link, quebrado, nota, crase, prosa]
resumo: A cleanup só trata como link quebrado o que é link de verdade e só promete "recuperável no git" quando o alvo foi versionado
atualizado-em: 2026-10-03
---

# cleanup-link-preciso

## objetivo

A detecção de link quebrado da cleanup fica precisa: link para caminho que
nunca foi versionado vira aviso fora do lote (nunca trocado), linha da seção
Aprendizados do `MEMORY.md` nunca entra na varredura nem é reescrita, e a nota
de link quebrado diz a verdade — o arquivo já não existia, a cleanup só
limpou o link (metas 6 e 7 do `PRD.md`).

## criterios-aceite

- **cleanup-link-preciso/1** — QUANDO a varredura acha link para caminho inexistente que nunca foi versionado em commit alcançável do HEAD O SISTEMA DEVE listá-lo na seção `## nunca existiu` do relatório, fora do lote, com `arquivo:linha` e o caminho citado
- **cleanup-link-preciso/2** — QUANDO a varredura acha link para caminho que já foi versionado em commit alcançável do HEAD e não existe mais O SISTEMA DEVE listá-lo em `## link quebrado`, no lote, como antes
- **cleanup-link-preciso/3** — QUANDO `contar` roda O SISTEMA DEVE devolver o mesmo total do lote do `varrer`, sem contar itens de `## nunca existiu`
- **cleanup-link-preciso/4** — QUANDO o lote fica vazio e o relatório só tem itens de `## nunca existiu` (com ou sem `## mantido`/`## não tocado`) O SISTEMA DEVE mostrar os avisos e terminar com `cleanup: nada a limpar`
- **cleanup-link-preciso/5** — QUANDO o lote aprovado traz a seção `## nunca existiu` O SISTEMA DEVE ignorá-la no `aplicar`, sem trocar nem commitar nada dela
- **cleanup-link-preciso/6** — QUANDO o lote aprovado traz em `## link quebrado` um link cujo alvo nunca foi versionado (lote montado à mão) O SISTEMA DEVE recusar na pré-checagem, nomeando o item, sem alterar nada
- **cleanup-link-preciso/7** — QUANDO o `aplicar` troca um link quebrado (alvo existiu e sumiu antes do lote) O SISTEMA DEVE escrever a nota `` `<caminho>` já não existia em AAAA-MM-DD (link limpo pela cleanup) — recuperável no git``
- **cleanup-link-preciso/8** — QUANDO o `aplicar` apaga um arquivo do lote O SISTEMA DEVE continuar trocando os links para ele pela nota `` `<caminho>` removido em AAAA-MM-DD pela cleanup — recuperável no git``, como antes
- **cleanup-link-preciso/9** — QUANDO uma linha da seção Aprendizados do `MEMORY.md` cita caminho inexistente (versionado ou não) O SISTEMA DEVE deixá-la fora do relatório inteiro (nem lote, nem `## nunca existiu`)
- **cleanup-link-preciso/10** — QUANDO o lote apaga um arquivo citado numa linha da seção Aprendizados O SISTEMA DEVE deixar essa linha intacta e continuar trocando os links nos demais citadores
- **cleanup-link-preciso/11** — QUANDO o repositório ainda não tem nenhum commit O SISTEMA DEVE listar todo link para caminho inexistente em `## nunca existiu` e terminar a varredura sem erro
- **cleanup-link-preciso/12** — QUANDO a skill cleanup apresenta o relatório O SISTEMA DEVE explicar `## nunca existiu` como aviso fora do lote (erro de digitação, exemplo ou fixture), que o humano corrige à mão se quiser
- **cleanup-link-preciso/13** — QUANDO `contar` roda neste repositório depois da entrega O SISTEMA DEVE devolver 0

## fora-de-escopo

- Caminho entre crases fora da seção Aprendizados continua contando como
  link: citação de arquivo que existiu e sumiu segue virando nota.
- A seção Aprendizados continua contando como referência viva para `## sem
  referência` (só não é varrida nem reescrita).
- Corrigir ou apagar sozinho o link de `## nunca existiu` — o humano decide.
- Reescrever notas já gravadas em commits anteriores (as trocas de
  2026-10-03 ficam como estão).
- Clone raso: caminho removido antes do corte do histórico conta como nunca
  existiu (erro conservador: vira aviso, não troca).

## decisoes

- 2026-10-03 (humano): link para caminho nunca versionado vira aviso numa seção fora do lote (`## nunca existiu`) — descartados "fora do relatório" (typo real passaria calado) e "no lote com nota própria" (ainda estragaria citação em prosa).
- 2026-10-03 (humano): link quebrado ganha nota distinta ("já não existia … link limpo pela cleanup"); arquivo apagado pelo lote mantém a nota atual — descartado manter a mesma nota para os dois (diz que a cleanup removeu o que não removeu).
- 2026-10-03 (humano): seção Aprendizados do `MEMORY.md` fica fora da varredura e nunca é reescrita — descartado varrê-la como hoje (aprendizado cita caminho como exemplo histórico).

## delta

## e2e

passou — 13/13 critérios (`claude -p` em fixture real + CLI direta + dogfood neste repo), relatório em `docs/audora/e2e/e2e-cleanup-link-preciso.md` removido em 2026-10-07 pela cleanup — recuperável no git

## feedback-reprovacao
