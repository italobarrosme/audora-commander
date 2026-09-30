# audora-commander

[English](README.md) | **Português (Brasil)**

Plugin de Claude Code: framework de desenvolvimento de software assistido por
IA, guiado por 5 princípios:

1. **Memória Dinâmica** — MEMORY.md é a memória viva do produto (requisitos,
   decisões, aprendizados). Requisito não escrito não existe.
2. **Planejamento Just-in-Time** — plano nasce lendo o código atual, cobre uma
   demanda, morre depois dela.
3. **"O Quê" separado do "Como"** — escopo fecha em artefato escrito antes de
   qualquer código.
4. **Processo proporcional ao risco** — LIGHT, MEDIUM, HIGH e HOTFIX pagam
   cerimônias diferentes; portão de aprovação nunca escala para baixo.
5. **IA executa, humano decide** — portões explícitos, evidência fresca antes
   de qualquer "pronto".

## Para que serve

`audora-commander` transforma o Claude Code num processo de desenvolvimento
guiado, não só um autocomplete poderoso. Ele ataca um problema comum de codar
com IA sem estrutura: requisito que se perde entre conversas, plano que vira
código sem ninguém aprovar o escopo antes, e "pronto" que ninguém verificou
de verdade.

Instalado num projeto, o plugin adiciona 9 skills encadeadas — da
classificação de risco da demanda até o portão de validação final — que
mantêm uma memória viva do produto (`MEMORY.md`), transformam escopo em
artefato escrito antes do código, e cobram evidência real (testes rodados,
e2e exercitado) antes de qualquer coisa ser dada como concluída.

Público-alvo: dev solo ou time pequeno construindo web/mobile/api com Claude
Code, que quer rigor de processo sem a burocracia de um processo pesado.

Fundamentos completos: [docs/fundamentos.md](docs/fundamentos.md).

## Pré-requisitos

- Claude Code CLI instalada (comando `claude` disponível no PATH).
- Git, para clonar o repositório. No Windows, use o
  [Git for Windows](https://git-scm.com/download/win) — ele fornece o bash
  usado pelo instalador e pelos hooks do plugin.

## Instalação

### Opção A — script automático (recomendado)

Clone o repositório e rode o instalador de dentro da pasta clonada:

```bash
git clone https://github.com/italobarrosme/audora-commander.git
cd audora-commander
./install.sh
```

No Windows, sem precisar abrir o Git Bash manualmente, dá pra rodar
`install.cmd` direto (ele mesmo acha o Git Bash e delega para o
`install.sh`):

```
install.cmd
```

O script adiciona esta pasta como marketplace local
(`audora-commander-dev`) e instala o plugin `audora-commander`, tudo via CLI
não-interativa — sem precisar abrir uma sessão do Claude Code antes. Rodar
de novo depois de já instalado é seguro (idempotente).

### Opção B — manual (sessão interativa do Claude Code)

```bash
claude
```

Dentro da sessão (troque o placeholder pela pasta onde clonou o repositório):

```
/plugin marketplace add <folder-where-you-cloned-the-repo>
/plugin install audora-commander@audora-commander-dev
```

### Depois de instalar

Reinicie a sessão (ou rode `/clear`) — o hook de SessionStart passa a
injetar o ponteiro do framework. Em seguida, rode o "Checklist de validação
da instalação" mais abaixo neste README.

## As 9 skills

| Skill | Papel |
|---|---|
| `audora-commander` | Porta de entrada: classifica a demanda por risco (LIGHT/MEDIUM/HIGH/HOTFIX) e roteia |
| `memory` | Cria e mantém o MEMORY.md (bootstrap, nós, deltas, aprendizados, compactação). Roteador: operações quentes inline, o resto em `skills/memory/references/`, lidas uma por operação. Os hooks `memory-guard` e `memory-validate` conferem toda escrita no MEMORY |
| `scope` | Fase "O Quê": critérios EARS, marcador [PRECISA-CLARIFICAR], portão de escopo |
| `plan` | Fase "Como" just-in-time: plano-arquivo com tarefas autossuficientes |
| `execute` | TDD red-green com evidência real; commit por etapa verde |
| `e2e` | Levanta o projeto e exercita a demanda de ponta a ponta (opcional, fortemente recomendada) |
| `validate` | Portão humano final: evidência 1:1 com critérios, sync MEMORY → PRD |
| `debug` | Debug com causa raiz demonstrada (modo sintoma) ou caçada de defeitos por classes (modo caçada) |
| `worktree` | Isolamento sob demanda em git worktree: ciclo de vida de uma demanda, fan-out de N agentes, integração em série, portão humano na remoção |

Detalhe por skill: [As skills em detalhe](#as-skills-em-detalhe).

## As skills em detalhe

### `audora-commander`

- **Quando dispara**: no início de qualquer demanda de software (criar,
  alterar, corrigir, refatorar) — o hook de SessionStart aponta para cá.
- **O que faz**: carrega o contexto (skill `memory`: Constituição,
  Aprendizados e índice de nós; sem `MEMORY.md` → oferece bootstrap antes de
  tudo); com 3 ou mais nós `in-progress`, pergunta o que pausar antes de
  aceitar outro; classifica a demanda por quatro perguntas binárias de risco
  — dado persistido ou migração? API pública/contrato? auth, segurança ou
  pagamento? efeito irreversível fora do repo? Qualquer sim → HIGH; vários
  arquivos ou lógica nova → MEDIUM; o resto → LIGHT. HOTFIX só quando você
  declara. Anuncia a categoria (você pode corrigir), registra o nó e roteia.
  Aceita "autopilot" / "roda até o validate" em LIGHT e MEDIUM (HIGH recusa).
  Catraca de mão única: sobe a categoria sozinha no meio do caminho, desce só
  com a sua aprovação. Demanda gigante é quebrada em menores.
- **O que deixa no disco**: o nó `docs/audora/memory/<id>.md`
  (`in-progress`) e a linha dele no `MEMORY.md`; nó LIGHT/HOTFIX já nasce
  com critérios EARS numerados.
- **Portões humanos**: nenhum próprio — você pode corrigir a classificação.
- **Próxima**: LIGHT/HOTFIX → `execute`; MEDIUM/HIGH → `scope`; sem MEMORY →
  `memory` (bootstrap).

### `memory`

- **Quando dispara**: chamada pelas outras skills (carregar contexto,
  registrar nó, delta ou aprendizado) ou direto por você.
- **O que faz**: é dona do MEMORY — o índice mestre `MEMORY.md` (Propósito,
  Constituição, Aprendizados, uma linha rica por nó) mais um arquivo por nó.
  Seis operações: `carregar-contexto`, `bootstrap`, `registrar-no`,
  `registrar-delta`, `registrar-aprendizado`, `compactar`.
  Roteador: operações quentes inline, o resto em
  `skills/memory/references/`, lidas uma por operação. Leitura seletiva
  (índice + só os nós que a demanda toca; grep para consulta estrutural); o
  que já foi carregado na sessão não é relido. O bootstrap oferece gerar
  o gate mecânico — uma vez; recusa fica registrada. Os hooks
  `memory-guard` (tetos de linhas) e `memory-validate` (schema, índice ↔
  pasta, enum, ciclos, estado em cada arquivo de nó) bloqueiam escrita
  quebrada.
- **O que deixa no disco**: `MEMORY.md`, `docs/audora/memory/<id>.md`,
  `docs/audora/decisoes-vivas.md`, nós arquivados em `docs/audora/arquivo/`
  e, se aceito, o script `gate` do projeto.
- **Portões humanos**: gerar o gate é decisão sua; conflito de merge no
  MEMORY fora dos nós da demanda é seu.
- **Próxima**: devolve à fase que chamou; invocada direto → oferece
  classificar uma demanda.

### `scope`

- **Quando dispara**: demanda MEDIUM/HIGH logo após a classificação, ou
  quando uma fase posterior reabre o escopo.
- **O que faz**: fala só de comportamento observável (nada de arquivo ou
  biblioteca). Pergunta em lotes de até 4 perguntas independentes — as
  dependentes vão em série, escolha de layout vai com preview. Lacuna vira
  `[PRECISA-CLARIFICAR: …]`, nunca suposição. Escreve o objetivo, critérios
  EARS numerados (`<id>/<n>`, "QUANDO … O SISTEMA DEVE …", com erro e borda)
  e o fora-de-escopo explícito, e faz auto-revisão (sem marcador aberto, tudo
  testável, sem conflito com a Constituição). Em autopilot, registra se todo
  critério é automatizável.
- **O que deixa no disco**: MEDIUM → os três campos no nó; HIGH → spec
  dedicada `docs/audora/specs/<id>-escopo.md`; uma linha por decisão
  respondida no nó.
- **Portões humanos**: o portão de escopo — espera sua aprovação explícita
  (antecipado só em autopilot elegível, ratificado no portão final).
- **Próxima**: `plan`, depois de uma PARADA — você roda `/clear` e digita
  `plan de <id>`; dizer "segue" roda a fase num subagente de contexto limpo.

### `plan`

- **Quando dispara**: depois do escopo aprovado (MEDIUM/HIGH).
- **O que faz**: duas passadas — localizar e depois ler
  os arquivos que o plano vai tocar,
  listados no cabeçalho. Conflito MEMORY vs código para e vai para você.
  Escreve tarefas autossuficientes: critérios EARS copiados verbatim,
  decisões relevantes, interfaces com assinatura exata, caminhos exatos,
  `depende-de` e passos de 2–5 minutos (red → verificar → implementar →
  green → commit). Os passos levam o código completo do TESTE, assinaturas e
  comandos exatos; código de implementação só quando não é óbvio (algoritmo,
  regex, SQL, formato exato). Zero placeholder. Tarefa complexa marcada
  `expandir: sim` só é detalhada quando chega a vez dela.
- **O que deixa no disco**: `docs/audora/planos/plano-<id>.md`.
- **Portões humanos**: HIGH → portão de plano; MEDIUM segue direto.
- **Próxima**: `execute`, depois de uma PARADA (`execute de <id>`).

### `execute`

- **Quando dispara**: plano aprovado (MEDIUM/HIGH) ou demanda LIGHT/HOTFIX
  pronta para código.
- **O que faz**: relê o plano e o nó no início de toda sessão; a próxima
  tarefa é a primeira com as dependências concluídas. Por tarefa: RED — um teste mínimo citando `<id>/<n>`,
  visto falhando pelo motivo certo; GREEN — o mínimo, com a suíte toda verde
  (ou o `gate:` da Constituição saindo 0); REFACTOR; COMMIT citando o
  critério. Os testes cobrem integração real e caminhos de erro e borda.
  Micro-decisões vão para o plano, aprendizados para o MEMORY na hora.
  HOTFIX: teste de reprodução antes do fix. Falha desconhecida → `debug`;
  beco sem saída → nó `blocked` e você decide. Como volta do motor de loop
  (`hooks/loop`), faz UMA tarefa e nunca commita — o motor roda o gate,
  commita a volta verde e guarda a vermelha como patch.
- **O que deixa no disco**: código e testes, um commit por etapa verde, a
  lista "Decisões tomadas pela IA" no plano.
- **Portões humanos**: nenhum no meio; você decide sobre nó `blocked`.
- **Próxima**: `validate`, que oferece o e2e — depois de uma PARADA em
  MEDIUM/HIGH; LIGHT/HOTFIX seguem direto.

### `e2e`

- **Quando dispara**: oferecida pela `validate` quando a execução está
  verde — opcional, fortemente recomendada.
- **O que faz**: sobe o produto de verdade. docker compose é o default: usa
  o compose do projeto ou gera `docker-compose.e2e.yml` a partir da stack;
  sem Docker, cai para o `como-rodar` da Constituição. Espera ficar saudável
  e nunca testa com infra parcial. Web → specs Playwright em `e2e/`; não-web
  → pergunta qual ferramenta usar e registra na Constituição. Todo critério
  EARS, inclusive os de erro, vira passo executado com evidência real.
  Teardown sempre.
- **O que deixa no disco**: `docs/audora/e2e/e2e-<id>.md` (critério →
  passo → evidência → veredito); o compose e as specs, versionados como
  regressão acumulada.
- **Portões humanos**: rodar é decisão sua (pulo fica registrado como
  `e2e: pulado-pelo-humano`); a ferramenta não-web é escolha sua.
- **Próxima**: `validate` com o relatório; critério reprovado → `debug`.

### `validate`

- **Quando dispara**: execução (e e2e, se rodado) terminada.
- **O que faz**: oferece o e2e; exige evidência 1:1 por critério — comando
  rodado agora com a saída, ou item explícito para conferência humana; monta
  o roteiro de validação: comportamento, diff de teste separado, premissas do
  autopilot, relatório da rodada do loop, decisões vivas propostas (filtro de
  entrada em `references/decisoes-vivas.md`) e, em HIGH, sumário por arquivo
  mais revisão adversarial por subagente de contexto limpo. Efeito
  irreversível fora do repo nunca é disparado pela IA. Depois da aprovação,
  quando o trabalho entra na main, roda o sync de `references/sync.md`:
  consolida o delta, promove decisões vivas e aprendizados, nó →
  `delivered`, `git mv` para o arquivo, `arquivos:` do diff real, resumo
  promovido ao `PRD.md`. LIGHT fecha pelo caminho curto de
  `references/fechamento-light.md`. Reference ausente mantém o portão e não
  roda o sync.
- **O que deixa no disco**: nó arquivado
  `docs/audora/arquivo/AAAA-MM-DD-<id>.md`, plano arquivado,
  `docs/audora/decisoes-vivas.md`, `PRD.md` atualizado.
- **Portões humanos**: o portão final — nunca antecipado, em toda categoria
  (aprovar, reprovar ou aprovar em parte).
- **Próxima**: nenhuma — a demanda termina; a próxima começa em
  `audora-commander`.

### `debug`

- **Quando dispara**: bug, teste falhando por motivo desconhecido,
  comportamento inesperado ou critério de e2e reprovado; sem sintoma
  nenhum, como caçada de defeitos.
- **O que faz**: modo sintoma — reprodução determinística (de preferência
  um teste que falha), evidência completa (erro inteiro, caminho que falha,
  diff recente), uma hipótese por vez testada pelo
  experimento mais barato que a distingue, causa raiz que explica todos os
  sintomas, fix via TDD. Três hipóteses refutadas → para e escala para você.
  Modo caçada — varre classes de defeito (referências cruzadas, contratos e
  schemas, documentação viva e contagens, bordas de erro, configuração e
  execução) e verifica cada achado antes de reportar.
- **O que deixa no disco**: teste de reprodução permanente; relatório de
  caçada em `docs/audora/depuracao/cacada-<AAAA-MM-DD>.md`; deltas e
  aprendizados no MEMORY.
- **Portões humanos**: escalada após 3 hipóteses refutadas; na caçada, quais
  melhorias viram nó é decisão sua.
- **Próxima**: `execute` (fix via TDD), `validate` ou decisão sua.

### `worktree`

- **Quando dispara**: só quando você pede explicitamente para isolar uma
  demanda, listar worktrees, despachar agentes em paralelo, integrar ou
  limpar — nunca por iniciativa própria.
- **O que faz**: isola a demanda com o worktree nativo do harness
  (`EnterWorktree` / `ExitWorktree`), com o nome do id do nó; prepara o
  ambiente (arquivos ignorados via `.worktreeinclude`, dependências, aviso de
  que os hooks do git são compartilhados — nunca copia segredo em
  silêncio); lista cada worktree com caminho, branch, nó, limpo? e commits
  não integrados; despacha N agentes em domínios de arquivo não-sobrepostos,
  criados e integrados um de cada vez; antes de remover, confere sujo, não
  integrado, arquivo ignorado e junction apontando para fora.
- **O que deixa no disco**: `.claude/worktrees/<id>/` e uma branch por
  demanda; caminho e branch registrados no nó.
- **Portões humanos**: descartar worktree que ainda tem trabalho
  (`discard_changes`) é sempre seu; limpeza de órfãos é oferecida, nunca
  executada.
- **Próxima**: a fase que a demanda pedia (`execute`, ou `scope`/`plan`);
  trabalho integrado → `validate`.

## Fluxo de uso (exemplo: demanda MEDIUM)

1. Você pede: "adiciona filtro por data na listagem de pedidos".
2. `audora-commander` classifica: MEDIUM (lógica nova, sem dado/auth/contrato).
3. `scope` pergunta o que falta, fecha critérios EARS, você aprova (portão).
4. `plan` lê o código atual que a demanda toca e gera `docs/audora/planos/plano-<id>.md`.
5. `execute` implementa por TDD, commit a cada etapa verde.
6. `validate` oferece o `e2e` (recomendado): projeto sobe, critérios são
   exercitados de verdade, relatório sai em `docs/audora/e2e/`.
7. Portão final: roteiro de validação com evidência por critério. Você aprova;
   o MEMORY sincroniza (decisões, aprendizados, arquivo) e PRD.md recebe o
   resumo.

## Reduzindo prompts de permissão

Os prompts de permissão (Bash, Edit, Write) vêm do harness do Claude Code, não
deste framework — reduzi-los não remove nenhum portão humano. Três opções, da
mais segura à mais arriscada:

| Opção | O que faz | Risco |
|---|---|---|
| `permissions.allow` em `.claude/settings.json` | Allowlist de ferramentas e comandos específicos; o resto continua perguntando | **Baixo** — restrito ao que você listar |
| `claude --permission-mode acceptEdits` | Edições de arquivo param de perguntar; Bash ainda pergunta | **Médio** — o agente pode reescrever qualquer arquivo do projeto |
| `claude --permission-mode bypassPermissions` | Nada pergunta | **Alto** — só em sandbox ou worktree descartável, nunca com credencial de produção no ambiente |

Aviso do loop engineering: regra no prompt é pedido; bloqueio real é permissão
mais sandbox. Configure o harness — não conte com prosa para segurar o agente.

## Artefatos nos projetos que usam o framework

- `MEMORY.md` — raiz do projeto: índice mestre da memória viva (propósito,
  constituição, aprendizados, uma linha rica por nó).
- `docs/audora/memory/` — um arquivo por nó (requisitos, critérios EARS
  numerados, decisões, delta).
- `docs/audora/decisoes-vivas.md` — decisões duráveis promovidas de nós
  entregues.
- `docs/audora/arquivo/` — nós entregues, arquivados por movimento.
- `docs/audora/planos/` — planos ativos; `arquivo/` para os encerrados.
- `docs/audora/e2e/` — relatórios E2E por demanda.
- `docs/audora/specs/` — specs de escopo de demandas HIGH.
- `docs/audora/depuracao/` — relatórios de caçada de defeitos (skill debug).

## Checklist de validação da instalação

Rode na sessão interativa após instalar:

- [ ] 1. QUANDO o marketplace for adicionado e o plugin instalado, o Claude
  Code DEVE listar as 9 skills com prefixo `audora-commander:` (verifique com
  a listagem de skills da sessão).
- [ ] 2. QUANDO uma sessão nova iniciar, o contexto DEVE conter o ponteiro
  "Framework audora-commander ativo" (pergunte ao Claude o que o hook
  injetou).
- [ ] 3. QUANDO a skill `audora-commander` for invocada num projeto sem
  MEMORY.md, ela DEVE oferecer bootstrap em vez de travar ou inventar conteúdo.
- [ ] 4. QUANDO cada skill for invocada isoladamente, ela DEVE carregar sem
  erro e sem placeholders.
- [ ] 5. QUANDO uma demanda LIGHT e uma MEDIUM forem simuladas num projeto de
  exemplo, o fluxo DEVE produzir os artefatos esperados (nó no MEMORY;
  plano-arquivo na MEDIUM; roteiro de validação).

## Desenvolvimento

Este repositório usa o próprio framework (dogfooding): veja `MEMORY.md`,
`docs/audora/planos/` e a spec em `docs/specs/`. Suíte de regressão:
`bash tests/run.sh` (bash puro, fixtures em `mktemp -d`).
