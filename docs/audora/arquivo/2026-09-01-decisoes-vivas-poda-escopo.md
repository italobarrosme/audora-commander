# Escopo — decisoes-vivas-poda (HIGH)

> Spec dedicada do nó `decisoes-vivas-poda`. Categoria HIGH porque a demanda
> reescreve em bloco um artefato de memória persistida do produto — operação
> com forma de migração.

## Objetivo

`docs/audora/decisoes-vivas.md` tem 17 entradas. Cerca de metade é cópia em
prosa de algo já imposto por teste, hook ou config, ou está morta (fala de uma
migração removida na 0.4.0). O furo está na regra de entrada: o arquivo exige
"decisão que segue VALENDO", mas não exige "decisão que **não** dá para impor
por teste". Prosa duplicada deriva do que ela descreve — e aí passa a mentir.

A demanda acrescenta a regra de entrada e audita as 17 entradas atuais,
marcando as que saem de circulação **sem apagar nenhuma**.

## Tensão resolvida no portão

O humano pediu "pode remover mesmo", e a regra 2 do próprio arquivo diz
"Decisão superada NUNCA é apagada". Decisão do portão: **marcar, não apagar**.
A linha ganha `[invalidado-em: AAAA-MM-DD]` e `[substituido-por: <ref>]`, o que
tira a entrada de circulação, diz ao leitor onde a verdade mora agora, e
preserva a rastreabilidade. Alternativas descartadas: apagar de vez (quebraria
a regra 2 e o git log não explica o sumiço) e mover para arquivo de histórico
(cria um arquivo que ninguém lê).

## Critérios de aceite

- **decisoes-vivas-poda/1** — QUANDO a validate propuser decisões vivas no
  portão O SISTEMA DEVE excluir da proposta toda decisão que já seja imposta
  por teste, hook ou config, dizendo em 1 linha qual artefato a impõe
- **decisoes-vivas-poda/2** — QUANDO uma decisão viva existente for auditada
  como já imposta em outro artefato O SISTEMA DEVE marcar a própria linha com
  `[invalidado-em: AAAA-MM-DD]` e `[substituido-por: <caminho do artefato>]`,
  nunca apagá-la
- **decisoes-vivas-poda/3** — QUANDO a decisão auditada estiver morta (o
  objeto dela não existe mais) O SISTEMA DEVE usar o mesmo par de marcadores,
  com `substituido-por` apontando o que a tornou obsoleta
- **decisoes-vivas-poda/4** — QUANDO a auditoria terminar O SISTEMA DEVE
  deixar intocada toda entrada que segue sendo racional arquitetural não
  imponível por teste — podar o que deriva, não o que só existe em prosa por
  natureza
- **decisoes-vivas-poda/5** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  reprovar se `skills/validate/SKILL.md` não declarar a regra de entrada: só
  entra decisão que NÃO dá para impor por teste, hook ou config
- **decisoes-vivas-poda/6** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  reprovar se alguma linha de `docs/audora/decisoes-vivas.md` tiver
  `[invalidado-em:` sem o `[substituido-por:` correspondente
- **decisoes-vivas-poda/7** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  reprovar se um `substituido-por` citar caminho de arquivo que não existe no
  repositório — ponteiro quebrado é pior que ponteiro nenhum

## Fora de escopo

Apagar qualquer linha do arquivo: o mecanismo é marcar, decidido no portão.
Mudar as regras 1 e 3 do rodapé do arquivo — a 2 é reforçada, a regra de
entrada é acrescentada, e ambas vivem na skill `validate` (decisão do portão),
não no rodapé nem no `templates/decisoes-vivas-template.md`. Podar a seção
`## Aprendizados` do `MEMORY.md`: é outro artefato, com outro teto e outra
regra de compactação — nó próprio se doer. Auditar decisões vivas de outros
projetos que usam o framework. Automatizar a auditoria por script: a
classificação "isto é imponível por teste?" é julgamento, e a Constituição
restringe executável a `hooks/` e `tests/`. Mudar o formato de 1 linha por
decisão.

## Auditoria proposta (a confirmar na execução, artefato por artefato)

Entradas candidatas a marcação — cada `substituido-por` é VERIFICADO contra o
repositório antes de escrever, e o critério /7 guarda isso:

| Entrada | Motivo | substituido-por candidato |
|---|---|---|
| `description` em aspas simples | já imposta por teste | `tests/test-skills.sh` |
| LF em hooks e `.cmd` | já imposta por config | `.gitattributes` |
| Compose de e2e em `docker-compose.e2e.yml` | já normativa na skill | `skills/e2e/SKILL.md` |
| Ferramenta e2e não-web na Constituição | já normativa na skill | `skills/e2e/SKILL.md` |
| Mensagens de hook com caminho absoluto | já imposta por teste | `tests/test-memory-validate.sh` |
| Identificadores EN, prosa PT | já é a Constituição | `MEMORY.md` |
| Estado PT→EN e schema v1→v2 | morta: migração removida na 0.4.0 | `docs/audora/arquivo/2026-08-25-comandos-ingles.md` |
| Corte de tokens é estimativa, medir se doer | cumprida: virou critério /9 | `docs/audora/arquivo/2026-08-31-memory-fatiada.md` |

Entradas que **ficam** (racional arquitetural, não imponível por teste):
`debug é skill-ferramenta`, `índice mestre editado pelo LLM e validado por
hook`, `placeholders em bloco de código traduzem`, `exit /b fora de bloco`,
`fronteira de grep ASCII`, as 3 de `skill-worktree` (comportamento verificado
do git, não do nosso código) e `roteador + references`.
