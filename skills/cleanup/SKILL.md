---
name: cleanup
description: 'Use quando o humano pedir limpeza ou faxina do processo num projeto com MEMORY — nós planned órfãos, spec, plano e relatório e2e de nó entregue, depuração velha, arquivo de docs/audora/ sem referência e link quebrado.'
---

# cleanup — faxina das sobras do processo

```
LEI DE FERRO: NADA SAI SEM APROVAÇÃO EXPLÍCITA DO LOTE — E O LOTE SAI NUM COMMIT SÓ
```

**Anuncie ao começar:** "Usando cleanup para varrer as sobras do processo."

Skill-ferramenta, invocada pelo humano em qualquer projeto com `MEMORY.md`.
O mecânico (classificar, conferir o git, apagar, trocar link, commitar,
desfazer) mora no script `hooks/cleanup` da **raiz do plugin** — dois níveis
acima do diretório base desta skill (o Skill tool imprime esse diretório ao
carregar). O julgamento semântico fica aqui. Rode tudo na raiz do projeto.

## O que a varredura acha

| tipo | o que é |
|---|---|
| planned órfão | nó planned já entregue/absorvido por um delivered, ou que cita alvo que não existe mais |
| spec de nó entregue | `docs/audora/specs/<id>-escopo.md` de nó delivered |
| plano arquivado | `docs/audora/planos/arquivo/plano-<id>.md` de nó delivered |
| relatório e2e | `docs/audora/e2e/e2e-<id>.md` de nó delivered |
| depuração velha | `docs/audora/depuracao/*` sem nó vivo ligado (não citada no índice nem em nó de `docs/audora/memory/`) |
| sem referência | arquivo de `docs/audora/` que nenhum documento vivo cita (índice, nós vivos, decisões vivas, skills, PRD, READMEs) |
| link quebrado | link em `MEMORY.md` ou `docs/audora/` para arquivo inexistente (fora de frontmatter e de bloco de código) |

Nunca entram: nós (`docs/audora/memory/`, `docs/audora/arquivo/`), decisões
vivas, arquivo fora de `docs/audora/`. Fora do lote, com aviso:
- `## mantido` — planned órfão com dependente vivo;
- `## não tocado` — fora do git ou com mudança não commitada.

## Fluxo

1. **Pré-condição.** Sem `MEMORY.md` na raiz → recuse, aponte o bootstrap da skill memory e não altere nada (o script recusa igual, exit 1).
2. **Julgar os planned** (só as linhas do índice; `MEMORY.md` nunca inteiro):
   `grep -E '^- [^|]+ \| (planned|delivered) \|' MEMORY.md`
   Compare cada planned (título, resumo, keywords) com os delivered:
   - objetivo já entregue ou absorvido por um delivered → `--orfao <id>=absorvido por <id-delivered>`;
   - cita skill, arquivo ou feature que não existe mais → confira no repo (Glob/Grep, nunca de memória) e use `--orfao <id>=alvo ausente: <alvo>`.
   Na dúvida, NÃO marque: planned legítimo apagado é requisito perdido.
   Caminho inexistente na coluna arquivos-chave o script já acha sozinho.
3. **Varrer** (só lê, não altera nada):
   `bash "<raiz do plugin>/hooks/cleanup" varrer --orfao <id>=<motivo> --orfao <id>=<motivo>`
   (um `--orfao` por planned julgado; sem nenhum, rode só `varrer`).
   Linha `aviso: --orfao <id> ignorado` = o id não é planned no índice:
   reveja o julgamento.
4. **Apresentar.** Saída `cleanup: nada a limpar` → diga "nada a limpar" ao humano e pare: nada muda, nada é commitado. Senão, mostre o relatório inteiro como saiu, agrupado por tipo,
   e explique `## mantido` e `## não tocado` (ficam fora do lote).
5. **Aprovação.** Espere aprovação explícita do lote. O humano pode tirar itens: apague as linhas dele e mantenha o resto do relatório igual.
   Grave o lote aprovado num arquivo do scratchpad (ex.: `<scratchpad>/lote-cleanup.txt`).
   Humano reprovou ou tirou todos → não rode `aplicar`; nada muda, nada é commitado.
   Silêncio, "talvez" ou pergunta não são aprovação.
6. **Aplicar** o lote aprovado:
   `bash "<raiz do plugin>/hooks/cleanup" aplicar <lote>`
   O script relê o lote, confere de novo cada item (alvo existe, está no
   git, limpo, dentro de `docs/audora/`), apaga arquivos, troca cada link
   para eles pela nota
   `` `<caminho>` removido em AAAA-MM-DD pela cleanup — recuperável no git``,
   apaga a linha do planned órfão do índice (e o arquivo do nó, se houver),
   roda o `memory-validate` e faz 1 commit só com os caminhos do lote. O que
   já estava staged fica fora do commit.
7. **Reportar.**
   - Sucesso (`cleanup: commit <hash> — N item(ns) removido(s)`): diga o
     hash, a contagem e como desfazer: `git revert <hash>`.
   - Falha (`cleanup: falhou em: <item> — <motivo>`): o script já desfez
     tudo (árvore volta ao estado de antes do lote, nada commitado). Mostre
     o item e o motivo ao humano; não tente contornar à mão.

## Exceção registrada

O script apaga linha do índice — exceção aprovada à decisão viva "índice
editado pelo LLM, nunca gerado por script": ele só APAGA a linha planned
aprovada e valida o MEMORY antes do commit. Sem bash, a cleanup fica
indisponível: avise o humano, não faça a limpeza à mão.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "O lote é óbvio, aplico direto" | Sem aprovação explícita do lote não roda `aplicar`. Nunca. |
| "Apago à mão, é mais rápido" | À mão não troca link, não valida o MEMORY, não desfaz na falha. Script. |
| "Esse planned parece velho, marco órfão" | Velho não é órfão. Só absorvido por delivered ou alvo ausente conferido no repo. |
| "O arquivo está sujo, mas incluo assim mesmo" | Mudança não commitada é trabalho em andamento. Fica fora do lote. |
| "Falhou no meio, termino o resto à mão" | O script já desfez o lote. Mostre a falha ao humano e pare. |
| "Leio o MEMORY.md inteiro pra julgar" | Só as linhas planned e delivered do índice, por grep. |

## PRÓXIMA SKILL

Nenhuma fixa. Limpeza aplicada ou "nada a limpar" → devolver ao humano e
perguntar se há demanda a classificar (skill audora-commander). Chamada a
partir de uma sugestão da validate → a demanda dela já terminou; a cleanup
não reabre fase nenhuma.
