# e2e — resumo-de-fase

**Data:** 2026-08-31 · **Versão:** 0.7.0 · **Ambiente:** Windows 11 Home
10.0.22621, Claude Code `2.1.247`.

**Estado do cache:** `claude plugin uninstall audora-commander@audora-commander-dev
&& ./install.sh` antes das corridas. `diff -r skills <cache>/0.7.0/skills`
**vazio**; `<cache>/0.7.0/templates/` contém `bloco-fechamento-template.md`;
`grep -c "Bloco de fechamento" <cache>/0.7.0/skills/scope/SKILL.md` → 1. O que
a sessão exercitou é o que está no repo.

**Ferramenta:** `claude -p` (Constituição, bullet `ferramenta-e2e`).

**Fixture:** repo git descartável com `MEMORY.md` mínimo (`graphify: recusado`),
`src/greet.ts` e um commit base. Duas corridas em sessão limpa.

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| **/1** — bloco com as 5 partes | corridas A e B | As duas imprimiram título (`### <id> · <fase> → <próxima>`), checkbox das fases, `**Produzido**`, `**Arquivos**` e `**Próximo**` | **passou** |
| **/2** — `[x]`/`[ ]`, negrito, resumo ≤8 palavras | corridas A e B | Marcação e resumos corretos (`- [x] execute — red 3 falhas, green 3 passes`). MAS o negrito foi na fase **em foco**, não na recém-concluída — nas duas corridas não HAVIA fase recém-concluída (uma aguardava portão, outra estava bloqueada) | **passou parcialmente** → delta |
| **/3** — execute imprime tarefas só no fim | — | **não exercitado**: nenhuma corrida completou uma execute com plano multi-tarefa. Cobertura segue estrutural ([execute:95](../../../skills/execute/SKILL.md)) | **não-automatizável aqui** |
| **/4** — bloco de Entrega pós-aprovação | — | **não exercitado**: o bloco só sai APÓS aprovação humana no portão, e `claude -p` não tem humano no meio da sessão. Limitação da ferramenta, não do código. Cobertura estrutural ([validate:99-101](../../../skills/validate/SKILL.md)) | **não-automatizável aqui** |
| **/5** — LIGHT omite fases não percorridas | corrida A (LIGHT) vs corrida B (HIGH) | A listou **3** fases (`audora-commander`, `execute`, `validate`) e **zero** ocorrências de `scope`/`plan` na lista. B, classificada HIGH, listou as **5**. Contraste é a prova | **passou** |
| **/6** — caminho real e existente | conferência dos 7 caminhos citados | Corrida A: `src/greet.ts`, `src/greet.test.ts`, `MEMORY.md`, `docs/audora/memory/greet-portugues.md` — todos existem. Corrida B: spec (3.206 bytes, bloco dizia "3.2 KB"), nó, `MEMORY.md` — todos existem, tamanho citado confere | **passou** |
| **/7** — fase interrompida imprime desmarcada + motivo | corrida B | `- [ ] **scope** — BLOQUEADO: `acme-pay` não existe no registry (404)`. Bloco impresso apesar do bloqueio, fase NÃO marcada, motivo em 1 linha, verificado antes (`npm view acme-pay` → E404) | **passou** |
| **/8** — 7 skills de fase declaram | suíte + teste negativo | 7/7 com `bloco=1 ponteiro=1`. Negativo: ponteiro trocado no `scope` → `FAIL: /8 scope aponta o template` | **passou** |
| **/9** — ferramentas não declaram | suíte + teste negativo | `memory=0`, `worktree=0`. Negativo: bloco enxertado em `worktree` → `FAIL: /9 worktree (ferramenta) sem bloco proprio` | **passou** |
| Suíte do plugin | `bash tests/run.sh` | 10 arquivos, **365 asserts**, 0 falhas, exit 0 | **passou** |

## Achado que gerou delta

**/2 e /7 se contradizem na letra.** /2 manda pôr em negrito "a fase
recém-concluída". /7 manda imprimir o bloco quando a fase é interrompida,
bloqueada ou reprovada — situação em que **não existe** fase recém-concluída.
Nas duas corridas as sessões resolveram destacando a fase **em foco** (a que
aguarda portão, a que está bloqueada), que é a informação útil.

Comportamento correto, critério incompleto. Delta refinando /2.

## Observação sobre a cobertura

/3 e /4 não foram exercitados e a razão é estrutural, não preguiça:

- **/4 é inexercitável em `claude -p`**: o bloco de Entrega só existe DEPOIS de
  uma aprovação humana no portão, e a sessão não-interativa não tem esse humano.
  Só uma sessão interativa fecha esse critério.
- **/3** exigiria uma demanda MEDIUM completa com plano multi-tarefa numa
  corrida só — caro, e o valor marginal é baixo perto de /1, /5 e /7 já provados.

Ambos seguem com cobertura estrutural (a skill declara a regra) e entram no
roteiro de validação humana.

## Notas de armadilha

- O bump de versão é pré-condição: sem ele o cache não refaz e a sessão
  exercitaria a versão anterior (falso verde).
- A corrida B classificou a demanda como **HIGH** sozinha e recusou inventar o
  contrato do SDK — efeito colateral bem-vindo, mostra que a porta de entrada e
  a skill scope seguem funcionando com a seção nova no arquivo.

## Teardown

Sem infra levantada. Fixture descartável no scratchpad. Plugin fica instalado
em **0.7.0** — mudança deliberada da demanda.
