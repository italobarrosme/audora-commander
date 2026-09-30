# Escopo — corte-sem-uso (HIGH)

> Nó: `docs/audora/memory/corte-sem-uso.md`. HIGH porque remove contrato
> (skill `worktree`, campo `autopilot:` do nó, motor de loop) e tem efeito
> irreversível fora do repo (hooks de git não versionados dos projetos).

## objetivo

Simplificar o audora-commander removendo o que não tem uso medido (112
sessões, 11 projetos, 2026-09-30): autopilot (0 usos), motor de loop (0
execuções) e skill `worktree` (2 invocações). Antes de apagar
`hooks/graphify-limpeza`, limpar de uma vez os projetos locais que ainda
têm restos do Graphify — assim o script e sua cobertura saem junto.

## criterios-aceite

**Limpeza dos projetos locais (antes de apagar o script)**

- **corte-sem-uso/1** — QUANDO a limpeza rodar O SISTEMA DEVE percorrer todo
  projeto sob `C:\Users\Italo Barros\workspace` com `MEMORY.md` iniciado por
  `memory-schema: 1` e, em cada um com resto do Graphify, remover os restos
  pelo `hooks/graphify-limpeza --remover`, deixando a detecção seguinte vazia
  — salvo item que falhou, relatado com o comando à mão.
- **corte-sem-uso/2** — QUANDO um projeto for limpo O SISTEMA DEVE deixar as
  mudanças versionadas SEM commit e alterar apenas arquivos de resto do
  Graphify: o `git status` depois difere do de antes só nesses arquivos.
- **corte-sem-uso/3** — QUANDO o projeto `VTURBO/SellInfoTurbo` for limpo O
  SISTEMA DEVE também tirar a seção do Graphify de `.claude/CLAUDE.md`
  (preservando o resto) e apagar `.claude/skills/graphify/`.
- **corte-sem-uso/4** — QUANDO a limpeza terminar O SISTEMA DEVE registrar um
  relatório por projeto (itens removidos, arquivos versionados alterados,
  falhas) em `docs/audora/e2e/limpeza-graphify-projetos.md`.

**Plugin sem o que não tem uso**

- **corte-sem-uso/5** — QUANDO o leitor abrir skills, templates, hooks,
  manifests, `README.md`, `README.pt-BR.md` e `docs/fundamentos.md` O SISTEMA
  DEVE não citar Graphify; `hooks/graphify-limpeza`, seu teste e a oferta de
  limpeza da carga de contexto não existem mais.
- **corte-sem-uso/6** — QUANDO o leitor abrir skills e templates O SISTEMA
  DEVE não citar autopilot, elegibilidade de autopilot, motor de loop nem
  `hooks/loop`; o template de nó não tem o campo `autopilot:` e todo portão
  do meio volta a ser sempre humano.
- **corte-sem-uso/7** — QUANDO o repositório for listado O SISTEMA DEVE não ter
  `hooks/loop`, `templates/loop-prompt-template.md` e seus testes; a
  Constituição (template e este repo) não tem bullet `loop:`.
- **corte-sem-uso/8** — QUANDO o humano disser "segue" numa PARADA O SISTEMA
  DEVE continuar rodando a fase seguinte em subagente de contexto zerado pelo
  `templates/fase-subagente-template.md`, que deixa de citar o motor.
- **corte-sem-uso/9** — QUANDO o plugin for instalado O SISTEMA DEVE ter 8
  skills (sem `worktree`), com contagem coerente em testes, READMEs,
  manifests e `hooks/session-start`; nenhuma skill cita a skill `worktree`.
- **corte-sem-uso/10** — QUANDO o plugin for reinstalado O SISTEMA DEVE
  declarar a versão `0.11.0` em `plugin.json` e `marketplace.json`.
- **corte-sem-uso/11** — QUANDO o gate rodar ao fim da demanda O SISTEMA DEVE
  sair 0; a queda de asserts passa só com `gate-asserts:` justificado no nó, e
  a remoção de `tests/test-graphify-limpeza.sh`, `tests/test-loop.sh`,
  `tests/test-autopilot.sh` e `tests/test-worktree.sh` está autorizada no nó
  e citada no commit.
- **corte-sem-uso/12** — QUANDO a demanda fechar O SISTEMA DEVE registrar no nó
  a carga estática medida antes e depois (bytes das skills e templates e a
  BASE do `test-carga`), como dado para a demanda seguinte.

## fora-de-escopo

Plano-mapa e regra de localização de código (demanda seguinte); PRD como
foto e critério de parada da revisão adversarial (demanda depois); a régua
"na dúvida, a mais pesada"; arquivos históricos (`docs/audora/arquivo/`,
planos e specs arquivados, `docs/specs/2026-09-02-loop-engineering-roadmap.md`);
commitar nos projetos limpos; desinstalar qualquer coisa da máquina;
qualquer outro conteúdo dos projetos além dos restos do Graphify.

## decisoes

- 2026-09-30 (humano): mudanças nos projetos limpos ficam SEM commit
  (descartados: commitar se árvore limpa; commitar sempre).
- 2026-09-30 (humano): skill `worktree` sai inteira (descartado: virar
  parágrafo na execute).
- 2026-09-30 (humano): autopilot e motor de loop saem inteiros (descartado:
  manter só a declaração de portões antecipados).
- 2026-09-30 (humano): SellInfoTurbo inclui `.claude/CLAUDE.md` e
  `.claude/skills/graphify/` (descartado: humano limpa à mão).
- 2026-09-30 (IA): `paradas humanas: N` do bloco de fechamento sai junto — foi
  criado pelo autopilot para contar portões antecipados; sem autopilot todo
  portão é humano. Confirmada no portão (humano: "aprovado").
- 2026-09-30 (IA): aprovar este escopo autoriza apagar os 4 arquivos de teste
  do /11 — evita parada no meio da execute. Confirmada no portão (humano: "aprovado").
- 2026-09-30 (IA): bump para `0.11.0` (breaking, minor pré-1.0).
- 2026-09-30 (IA): a limpeza dos projetos roda ANTES de apagar o script, na
  execute, a partir deste repo.
