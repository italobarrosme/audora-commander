# PRD — audora-commander

> Última atualização: 2026-10-26

## O que é e para que serve

Plugin de Claude Code (padrão Superpowers) que implementa um framework de
desenvolvimento de software assistido por IA, guiado por 5 Princípios de AI
Coding: memória dinâmica do produto (MEMORY vivo), planejamento
just-in-time, separação "O Quê"/"Como",
processo proporcional ao risco da demanda, e IA executa / humano decide.
Público-alvo: dev solo ou time pequeno construindo web/mobile/api com Claude
Code.

## Stack

- Markdown (skills, templates, docs) + JSON (plugin.json, marketplace.json,
  hooks.json) + bash (hooks: `session-start`, `memory-guard`,
  `memory-validate`; scripts auxiliares `gate`, `cleanup` e `versionamento`,
  os dois últimos em perl via `perl -x`; sem jq — awk/sed/grep/perl do
  Git for Windows).
- Suíte de regressão do plugin em bash: `tests/run.sh` + `tests/test-*.sh`
  (fixtures em `mktemp -d`, `tests/lib.sh` com asserts e `run_hook`). O
  `run.sh` roda os arquivos em paralelo (`SUITE_JOBS`, default = núcleos;
  `1` = série) com timeout por arquivo (`SUITE_TIMEOUT`, default 300 s; `0`
  desliga) e imprime em blocos na ordem do glob, com o tempo no resumo.
- Evals de comportamento (manuais, pagos, fora do `run.sh`): `bash tests/evals.sh`
  roda 4 casos com o `claude` real em fixture isolada, teto de custo, modo
  completo com/sem plugin (`--runs`), mutação e `--traces`; em `tests/evals/`.
- Localização de código pela busca do símbolo do harness, leitura por trecho.
- Formato de plugin do Claude Code: `.claude-plugin/` + `skills/` + `hooks/`
  + `agents/` (`revisor`: só Read/Grep/Glob/Bash, `model: inherit`, trava do
  shell na própria definição). Versão 0.16.0.

## Arquitetura

9 skills: 8 encadeadas por um roteador central e 1 skill-ferramenta
(`cleanup`):

- `audora-commander` — porta de entrada: classifica demanda (LIGHT / MEDIUM /
  HIGH / HOTFIX) por perguntas binárias de risco, anuncia a categoria com
  motivo e convite à correção antes de registrar o nó e roteia pelas fases
  (1ª fase pela ferramenta Skill). Sem `MEMORY.md` → oferece bootstrap.
- `memory` — dona do MEMORY (memória externa do produto, `memory-schema: 1`):
  `MEMORY.md` é índice mestre (Propósito, Constituição, ponteiro de
  Aprendizados, linha rica por nó); corpo de cada nó em
  `docs/audora/memory/<id>.md` com frontmatter grep-ável e critérios EARS
  numerados (linha `- **<id>/<n>** — …`, também em HIGH); escrita de nó é
  "arquivo do nó primeiro, linha do índice logo depois", na criação e na
  transição; decisões duráveis em `docs/audora/decisoes-vivas.md`;
  aprendizados em `docs/audora/aprendizados.md`, sem teto nem compactação,
  só por grep; arquivamento por `git mv` para `docs/audora/arquivo/`.
  Operações: carregar-contexto, bootstrap (MEMORY + etapa versionamento +
  etapa gate, sem índice de código; Aprendizados só com o ponteiro),
  registrar-no, registrar-delta, registrar-aprendizado (1 linha
  `data | fase | aprendizado` no fim de `docs/audora/aprendizados.md`, na
  hora, por qualquer fase), compactar e versionamento. A skill é um
  **roteador**: `carregar-contexto`, `registrar-delta` e
  `registrar-aprendizado` ficam inline no `SKILL.md`; `bootstrap`,
  `registrar-no`, `compactar` e `versionamento` vivem em
  `skills/memory/references/`, lidas UMA por operação — reference ausente
  avisa e degrada, sem travar a fase. O `carregar-contexto` lê o
  `MEMORY.md` por seção, nunca inteiro, e as fases o chamam antes de
  qualquer Read:
  - Propósito e Constituição: inteiras, por `offset`/`limit`.
  - Aprendizados: por `grep` (fase + keywords do nó; porta: termos do pedido).
  - Índice de nós: inteiro na porta, scope e plan; execute, e2e, validate e
    debug pegam só a linha do nó e as de `depende-de`.
  - Seção não encontrada → aviso de 1 linha, leitura inteira, a fase segue.
  - Constituição sem `versionamento:` → lê a reference, roda o `checar` e
    oferta UMA vez o bloco do `.gitignore` (recusa registrada não volta).
- **Versionamento** (`.gitignore` padrão): a memória do produto fica no git
  (`MEMORY.md`, `PRD.md`, `CHANGELOG.md`, `docs/audora/memory/`,
  `arquivo/`, `decisoes-vivas.md`, `aprendizados.md`); spec, plano, e2e e
  caçada (`docs/audora/specs/`, `planos/`, `e2e/`, `depuracao/`) ficam só no
  disco pelo bloco do audora. O mecânico mora em `hooks/versionamento`:
  `checar` (só lê: bloco, regra que esconde a memória com arquivo:linha
  relativo ao projeto, versionados nas pastas efêmeras) e `aplicar` (bloco
  sem duplicar; `--desligar` comenta regra de `.gitignore` do projeto, nunca
  global nem `.git/info/exclude`; `--remover` tira do git, mantém no disco
  e commita só isso, desfazendo se o commit falhar). Fora do git: só o
  bloco. Memória versionada cita pasta efêmera só como `local: <caminho>`,
  nunca link, e nunca no `git add`.
- `scope` — fase "O Quê": critérios EARS, marcador [PRECISA-CLARIFICAR].
  Critérios sempre no nó, também em HIGH; spec dedicada, se criada, só
  traz contexto.
- `plan` — fase "Como" just-in-time: plano-arquivo em que cada tarefa é um
  MAPA, sem corpo de teste nem de implementação. A tarefa traz o requisito
  `<id>/<n>`, o ponto de mudança `caminho:linha`, o arquivo e o caso de
  teste, os trechos a ler, o done e, quando o critério deixa o valor
  aberto, a asserção exata `entrada → saída esperada`. O header lista cada
  leitura como `caminho:início-fim`. Pergunta ampla vai a um subagente de
  exploração que devolve `caminho:linha`, conferido por leitura própria.
- `execute` — TDD red-green com evidência real; commit por etapa verde. O
  código do teste nasce aqui, do caso e das asserções do mapa. Seção
  `## Localização de código`:
  - lê os trechos do mapa, e arquivo com mais de 200 linhas nunca é lido
    inteiro;
  - fora do mapa, busca o símbolo e segue ligações de import, herança,
    registro e configuração;
  - na 3ª leitura fora do mapa, anota no mapa e segue;
  - modificar arquivo fora do mapa volta ao plan;
  - `caminho:linha` desatualizado é relocalizado pelo símbolo;
  - plano no formato antigo é executado como está.
- `e2e` — levanta o projeto e exercita a demanda de ponta a ponta (opcional,
  fortemente recomendada). Grava no `## e2e` do nó 1 linha por critério
  (`<id>/<n> · passou|reprovou · evidência`) e o relatório como `local:`;
  evidência binária em `docs/audora/e2e/<id>/`.
- `validate` — portão humano final: evidência 1:1 com critérios, sync
  MEMORY → PRD no merge (consolida delta e decisões vivas, move os
  aprendizados legados do `MEMORY.md` para `docs/audora/aprendizados.md`;
  nó sem critério numerado copia os da spec antes do `git mv`, sem nenhum
  para sem arquivar; arquiva o nó por movimento e o plano com `git mv` só se
  rastreado; foto do `PRD.md` + 1 linha no `CHANGELOG.md`, toda categoria). Decidido o
  portão, em toda categoria, fecha o turno com o cartão de entrega no lugar
  do bloco de fase (`🏁 DONE`, `❌ NÃO ENTREGUE` ou `⚠️ PARCIAL`): estado,
  o que mudou, trilha, ressalvas, por critério, arquivos em 1 linha do
  numstat da demanda, rodapé Memória; em branch pergunta o merge; formato em
  `templates/bloco-fechamento-template.md`. O `PRD.md` é foto com até 200
  linhas; histórico de entregas no `CHANGELOG.md`, PRD com histórico
  convertido on-touch no próximo sync. Roteador: fluxo até o portão inline;
  sync, decisões vivas, revisão adversarial e LIGHT em
  `skills/validate/references/` (ausente: mantém o portão, não roda o sync).
  A revisão adversarial (só HIGH), pelo agente `revisor`, bloqueia só achado
  provado de 3 classes (alheio, critério, formato real); o resto vira
  ressalva de 1 linha. Para em 1 passagem completa mais a reverificação dos
  bloqueantes corrigidos; ressalva aceita vira candidato a nó nas metas futuras.
- `debug` — causa raiz demonstrada (modo sintoma, localiza como a `execute`)
  ou caçada por classes, cada achado verificado e refutado pelo `revisor`.
- `cleanup` — skill-ferramenta, invocada pelo humano em projeto com
  `MEMORY.md`: varre as sobras do processo (planned órfão, spec, plano
  arquivado e e2e de nó delivered, depuração sem nó vivo, arquivo de
  `docs/audora/` sem referência viva, link quebrado) e, com aprovação
  explícita do lote (com retirada de itens), aplica num commit só, pelo
  `hooks/cleanup` (`varrer`/`contar` só leem; `aplicar` apaga, troca link
  para arquivo apagado pela nota "removido … recuperável no git" e link
  quebrado pela nota "já não existia …", apaga a linha do planned aprovado,
  roda o `memory-validate` e desfaz tudo se algo falhar). Link quebrado é
  só o que aponta caminho que existiu em commit alcançável do HEAD; nunca
  versionado vira aviso `## nunca existiu`; `local: <caminho>` não é link.
  Princípio: só sai o que não é mais usado — arquivo que o framework lê
  nunca entra, e spec, plano ou e2e que cita `<id>/<n>` sem cópia no nó
  arquivado vai para `## mantido`. Sujo fica em `## não tocado`. Sobra
  local (fora do git) de nó delivered ou discarded e caçada sem nó vivo vai
  para `## sem volta (fora do git)` — a pasta `e2e/<id>/` sai inteira só se
  nada nela é mantido ou rastreado — e é apagada do disco só depois do
  commit da parte versionada; nó vivo nunca é listado. O julgamento de
  planned órfão é da skill (`--orfao`), que confere o histórico antes de
  marcar alvo ausente. O sync da validate só sugere a contagem no rodapé
  Memória do cartão de entrega.

Fronteira de fase: fim de scope, plan ou execute de MEDIUM/HIGH é PARADA —
a fase não emenda a seguinte e imprime `/clear` + o comando de retomada
`<fase> de <id>`; a fase nova se reancora só pelos artefatos em disco.
"Agente" sem `/clear` roda a fase seguinte num subagente de contexto zerado
(`templates/fase-subagente-template.md`), que nunca aprova portão e devolve
pergunta humana à sessão principal. Sem parada: entrada → 1ª fase, LIGHT,
HOTFIX e e2e ↔ validate. Regra única no `templates/bloco-fechamento-template.md`.

Hook SessionStart injeta ponteiro curto para a porta de entrada. Hooks
PostToolUse (Edit|Write) validam escritas no MEMORY: `memory-guard` (tetos
de ~300 linhas no índice e ~100 por nó, e 200 linhas no `PRD.md` irmão de
um `MEMORY.md` com schema) e `memory-validate` (seções obrigatórias do
índice, depende-de existente, ciclo, estado dentro do enum EN no índice E
no frontmatter de cada nó, nó sem `estado:`, e — só na escrita do índice —
arquivo de nó sem linha e estado índice ≠ nó) — erro volta ao modelo via
exit 2; arquivo sem `memory-schema: 1` na linha 1 é ignorado. Hook
PreToolUse (Write) `anuncio-guard` recusa nó novo `in-progress`/
`hotfix-pending-record` sem o anúncio da porta; falha passa.

Documentos de referência: `docs/fundamentos.md` (fundamentos v2 dos princípios)
e `docs/specs/2026-08-14-audora-commander-design.md` (spec de design).

## Metas futuras de implementação

1. Futuro: porte multi-harness, marketplace público.
2. Candidato a nó: acabamento da PARADA (`contexto-por-fase`) — pontuação
   única, recusa de retomada imprimindo o bloco bloqueado, folga na carga BASE.
3. Candidato a nó: ressalvas da revisão adversarial do `corte-sem-uso`.
   - Guardas de ausência deixam passar variações ("loop engine", "nove
     skills", tabela com espaço extra, bullet `**loop:**`).
   - `hooks/gate` compara contra HEAD: depois do commit não prova
     `gate-asserts:` nem teste apagado.
4. Candidato a nó: ressalvas do `plano-mapa`.
   - /4 e /8 só têm guarda de texto; plan ainda pode ler arquivo grande
     inteiro; custo da execute +3,7% (n=1) — medir numa demanda maior.
5. Candidato a nó: observações do `evals-comportamento` (achado restante:
   `retomada-execute`): mutação `scope-lei-de-ferro` sem efeito em 1 run
   (`--runs 3`); `test-evals*.sh` ~400 s acima do `SUITE_TIMEOUT` padrão.
6. Candidato a nó: ressalvas do `gitignore-padrao` aceitas no portão.
   - `.gitignore` fica modificado no disco quando o commit do `--remover` falha.
   - Lote à mão com `docs/audora/./decisoes-vivas.md` escapa do `protegido`.
   - Nó discarded não arquivado deixa plano/e2e sempre em `## mantido`.
   - Contrato do skill-cleanup/11 no nó arquivado ficou desatualizado.
   - `contar` inclui sobras locais: quase todo sync sugere a cleanup.
   - `local:` só na forma exata; `checar` não sonda nó específico.
   - `--remover` leva edições não staged do `.gitignore`.
   - /11 aceita `não-automatizável`; "nunca no `git add`" só em texto.
   - Teto de carga quase cheio: BASE 57885/58000, FULL 67075/67100.
