# Plano — grafo-v2: índice mestre + 1 nó = 1 arquivo (Candidato C)

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** GRAFO v2 completo — GRAFO.md como índice mestre, nós em
`docs/audora/nos/<id>.md`, decisões vivas, EARS numerado, migração gradual
dual v1/v2, hooks de validação — nas 8 skills, templates e hooks do plugin.

**Nó do GRAFO:** `grafo-v2` (GRAFO.md) — spec:
`docs/audora/specs/grafo-v2-escopo.md` (critérios grafo-v2/1.1–7.2)

**Arquitetura da mudança:** O template é a fonte do schema; a skill grafo é a
única que instrui leitura/escrita; as demais skills só citam operações e
endereços de critério. Logo: (1) templates primeiro (schema v2), (2) skill
grafo reescrita sobre eles, (3) hooks de validação, (4) edições pontuais nas
outras 7 skills, (5) migração dogfood do GRAFO deste repo, (6) READMEs.
Suporte dual v1/v2 vive na skill grafo (detecção por `versao-schema` na
linha 1); as outras skills ficam agnósticas de versão (falam "nó" e
"operação", nunca formato).

**Arquivos lidos antes de planejar:**
- `templates/GRAFO-template.md` — schema v1 que vira compat + base do v2.
- `templates/plano-template.md` — intacto (só citação de endereço EARS).
- `skills/grafo/SKILL.md` (conteúdo carregado na sessão) — 5 operações a
  portar; referências a "GRAFO-template.md" e "GRAFO-ARQUIVO.md".
- `skills/audora-commander/SKILL.md`, `skills/escopo/SKILL.md`,
  `skills/plano/SKILL.md`, `skills/executar/SKILL.md`,
  `skills/validar/SKILL.md`, `skills/e2e/SKILL.md` (carregados),
  `skills/depurar/SKILL.md` (lido) — pontos de contato mapeados na Tarefa 4.
- `hooks/hooks.json` — só SessionStart hoje; ganha bloco PostToolUse.
- `hooks/run-hook.cmd` — wrapper polyglot pronto, reusado pelos hooks novos.
- `hooks/session-start` — padrão de saída JSON dos hooks.
- `.claude-plugin/plugin.json` — sem mudança (versão sobe na validação, se o
  humano quiser).
- `.gitattributes` — NÃO existe; criar (pré-requisito dos hooks, estudo L2).
- `GRAFO.md` deste repo — objeto da migração dogfood (Tarefa 5).
- `README.md` / `README.pt-BR.md` — seção de artefatos desatualiza com o v2.

**Conflitos GRAFO vs código encontrados:** nenhum.

## Notas de sessão

Rodada adversarial (3 lentes, 2026-08-25): 20 achados, todos verificados e
corrigidos antes do portão, exceto 1 que vira decisão humana (abaixo).
Correções: run-hook.cmd propagava exit 0 (parse-time %ERRORLEVEL% em bloco);
.gitattributes forçava CRLF em *.cmd (bash morre em Linux); validate cego a
CRLF/nós inline/caminho relativo; contagem 14→17 critérios; caminho de
arquivamento no índice; rota v1 morta na validar; promoção de decisões vivas
antes do portão; LEVE sem critérios numerados; exceção de schema no registro;
campos sem fonte na migração on-touch; consolidação de delta sem dono;
proveniência errada em decisoes-vivas.

**Pendência para o humano (portão)**: critério grafo-v2/1.1 diz linha rica
"linkando docs/audora/nos/<id>.md"; a implementação resolve o corpo pelo id
(id = nome do arquivo), sem campo de link — grep-ável e sem redundância.
Proposta: aceitar como delta MODIFICADO do 1.1 ("link implícito por id").

## Decisões tomadas pela IA (revisar na validação)

- Template v1 preservado como `templates/GRAFO-template-v1.md` (git mv) — o
  modo compat precisa do schema v1 documentado; `templates/GRAFO-template.md`
  passa a ser o v2 (índice mestre) e nasce `templates/no-template.md` (arquivo
  de nó).
- Em `.gitattributes`: `hooks/* eol=lf` antes de `*.cmd eol=crlf` (última
  regra vence: run-hook.cmd fica CRLF, scripts bash ficam LF).
- Hooks filtram por caminho DENTRO do script (stdin JSON → file_path), não no
  matcher (matcher só casa nome de ferramenta: `Edit|Write`).
- `decisoes-vivas.md` nasce na migração dogfood já com as decisões vivas dos
  nós entregues deste repo (e2e-playwright-docker; docs-bilingues já está na
  Constituição).
- Terceiro template `decisoes-vivas-template.md` criado (em vez de anexo no
  GRAFO-template) — bootstrap copia arquivo limpo.
- Estado transicional da migração on-touch: primeiro TOQUE em nó de projeto
  v1 faz bump para `versao-schema: 2`; nós não tocados permanecem inline no
  GRAFO.md como legado válido (leitor v2 usa fallback: arquivo ausente em
  nos/ mas `### <id>` presente no GRAFO.md → ler inline). carregar-contexto
  puro em projeto v1 NÃO migra nada (grafo-v2/5.1).

---

## Tarefa 1: Templates v2

- **depende-de**: []
- **requisito**: grafo-v2/1.1, 1.2, 3.3, 7.2 (schema do índice mestre, do
  arquivo de nó, invalidação e tetos — o template é a fonte canônica).
- **decisões relevantes**: caminhos canônicos da spec; EARS numerado
  (grafo-v2/4.1); frontmatter "1 campo = 1 linha".
- **interfaces**:
  - consome: schema v1 atual (base)
  - produz: `templates/GRAFO-template.md` (v2), `templates/no-template.md`,
    `templates/GRAFO-template-v1.md` — nomes exatos que a Tarefa 2 referencia
- **arquivos**:
  - Renomear: `templates/GRAFO-template.md` → `templates/GRAFO-template-v1.md`
  - Criar: `templates/GRAFO-template.md` (novo, v2), `templates/no-template.md`
- **done quando**: os 3 arquivos existem; v2 contém `versao-schema: 2`,
  índice com linha rica, regras de teto (300 índice / 100 nó), seção
  decisoes-vivas e regras de arquivamento por mv; no-template contém
  frontmatter completo + corpo com EARS numerado + delta append-only +
  campos `invalidado-em`/`substituido-por`.

Passos:

- [ ] **1. RED** — `ls templates/no-template.md` → não existe;
  `grep -c "versao-schema: 2" templates/GRAFO-template.md` → 0.
- [ ] **2. git mv + escrever os dois templates novos** (conteúdo integral na
  execução; estrutura fixada no "done quando").
- [ ] **3. GREEN** — greps do passo 1 invertidos; scan TBD/TODO vazio.

## Tarefa 2: Reescrever a skill grafo (dual v1/v2) — `expandir: sim`

- **depende-de**: [1]
- **requisito**: grafo-v2/1.3, 2.1, 2.2, 5.1, 5.2, 5.3, 6.2, 7.1 (operações
  no substrato novo, travessia por grep, dual mode, degradação, limites).
- **decisões relevantes**: skill é fonte normativa (hooks são rede de
  segurança); índice editado pelo LLM na mesma edição do nó; detecção de
  versão pela linha 1; migração on-touch.
- **interfaces**:
  - consome: nomes de template da Tarefa 1
  - produz: as 5 operações com MESMOS nomes (carregar-contexto, bootstrap,
    registrar-no, registrar-delta, compactar) — API que as outras skills citam
- **arquivos**:
  - Modificar: `skills/grafo/SKILL.md`
- **done quando**: 5 operações portadas com dual mode; protocolo de leitura
  v2 (índice → grep frontmatter → Read do nó); migração on-touch descrita;
  ≤ 250 linhas; padrão de skill intacto.

Subtarefas (expandir na execução — chegou a vez, detalhar então):
leitura seletiva v2; operações 1-5; seção "Modo compat v1"; red flags novas
(ler pasta inteira; editar nó sem atualizar índice; migrar sem tocar).

## Tarefa 3: Hooks de validação + .gitattributes

- **depende-de**: [1]
- **requisito**: grafo-v2/1.3, 6.1, 6.2, 7.2.
- **decisões relevantes**: PostToolUse matcher `Edit|Write`; filtro de path
  no script; erro/aviso via exit 2 + stderr; sem jq (awk/grep/perl do Git
  for Windows); falha de hook nunca quebra o fluxo.
- **interfaces**:
  - consome: caminhos canônicos (GRAFO.md, docs/audora/nos/)
  - produz: `hooks/grafo-guard`, `hooks/grafo-validate` (nomes sem extensão,
    padrão session-start), bloco novo em `hooks/hooks.json`
- **arquivos**:
  - Criar: `hooks/grafo-guard`, `hooks/grafo-validate`, `.gitattributes`
  - Modificar: `hooks/hooks.json`
- **done quando**: rodando cada hook com stdin JSON simulado: guard avisa
  índice >300/nó >100 linhas (exit 2, mensagem no stderr) e silencia abaixo;
  validate acusa linha-sem-arquivo, arquivo-sem-linha, dep inexistente e
  ciclo; ambos exit 0 imediato para file_path fora do GRAFO; hooks.json
  válido (`perl -MJSON::PP -e ...` parseia).

Passos:

- [ ] **1. RED** — hooks não existem; hooks.json sem PostToolUse.
- [ ] **2. Escrever guard + validate + .gitattributes + hooks.json.**
- [ ] **3. GREEN** — bateria de execução real com stdin simulado (casos do
  "done quando", incluindo os de erro), saída lida.

## Tarefa 4: Pontos de contato nas outras 7 skills

- **depende-de**: [2]
- **requisito**: grafo-v2/4.1 (endereços citados em evidência), 3.1
  (validar promove decisões vivas), 3.2 (arquivar por mv), 2.3 (arquivos:
  via git diff no sync).
- **decisões relevantes**: skills agnósticas de versão; edições mínimas.
- **interfaces**: consome operações da Tarefa 2 (mesmos nomes).
- **arquivos** (Modificar — ponto exato por skill):
  - `skills/escopo/SKILL.md`: item 4 — critérios nascem numerados
    (`<no-id>/<n>`).
  - `skills/plano/SKILL.md`: tarefa embute critério verbatim + endereço.
  - `skills/executar/SKILL.md`: commit/teste citam endereço do critério.
  - `skills/e2e/SKILL.md`: tabela do relatório ganha coluna do endereço.
  - `skills/validar/SKILL.md`: item 2 evidência por endereço; item 6 sync →
    promoção a decisoes-vivas.md + `git mv` para docs/audora/arquivo/ +
    `arquivos:` via `git diff --name-only`.
  - `skills/audora-commander/SKILL.md`: sem mudança estrutural (opera por
    operação da skill grafo) — só conferir citações.
  - `skills/depurar/SKILL.md`: sem mudança (cita "delta no GRAFO" — segue
    válido) — só conferir.
- **done quando**: greps por skill confirmam a citação nova; nenhuma skill
  passa de 250 linhas; nenhuma referência ao formato interno v1/v2 fora da
  skill grafo.

## Tarefa 5: Migração dogfood do GRAFO deste repo

- **depende-de**: [2, 3]
- **requisito**: grafo-v2/5.2 exercitado de verdade (este repo é o primeiro
  projeto migrado); 1.1-1.3 verificáveis no artefato real.
- **decisões relevantes**: nós `em-curso` migram agora (plugin-v0.1.0,
  grafo-v2); `planejada` ficam só no índice; entregues ficam no
  GRAFO-ARQUIVO.md como estão (não migram).
- **interfaces**: consome templates (T1) e hooks (T3 valida o resultado).
- **arquivos**:
  - Modificar: `GRAFO.md` (vira índice mestre v2)
  - Criar: `docs/audora/nos/plugin-v0.1.0.md`, `docs/audora/nos/grafo-v2.md`,
    `docs/audora/decisoes-vivas.md`
- **done quando**: `hooks/grafo-validate` roda limpo no repo migrado; linha 1
  do GRAFO.md = `versao-schema: 2`; nós ativos em arquivos com frontmatter.

## Tarefa 6: READMEs (seção de artefatos)

- **depende-de**: [5]
- **requisito**: documentação viva coerente com o v2 (paridade EN/PT do nó
  docs-bilingues preservada).
- **arquivos**: Modificar `README.md` e `README.pt-BR.md` — lista de
  artefatos ganha `docs/audora/nos/`, `docs/audora/decisoes-vivas.md`,
  `docs/audora/arquivo/`; nota de compat v1.
- **done quando**: paridade de seções EN/PT mantida (8×8) e blocos de código
  idênticos (checks do plano docs-bilingues re-rodados).

## Tarefa 7: Verificação final + commits

- **depende-de**: [4, 5, 6]
- **requisito**: mapa 1:1 dos 17 critérios → evidência (grep/execução real).
- **done quando**: tabela critério→evidência completa; todas as skills ≤ 250
  linhas; hooks verdes na bateria; commit por tarefa verde feito ao longo do
  caminho (T1-T6), commit final de fechamento.
