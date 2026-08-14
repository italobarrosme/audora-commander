# Plano de implementação — audora-commander v0.1.0

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Plugin de Claude Code funcional com 7 skills, hook de SessionStart, templates e marketplace local, instalável e validável.

**Architecture:** Plugin padrão Superpowers (`.claude-plugin/` + `skills/` + `hooks/`), conteúdo em markdown/json puro, sem código executável além dos scripts de hook. Cada skill é autocontida, referencia templates canônicos e encadeia a próxima por nome.

**Tech Stack:** Markdown, JSON, bash (hook), wrapper polyglot .cmd para Windows.

**Spec:** `docs/specs/2026-08-14-audora-commander-design.md` (+ `docs/fundamentos.md` como fonte conceitual — todo conteúdo de skill deriva dessas duas fontes).

## Global Constraints

- Todo conteúdo de skill em português; frontmatter `description` começa com "Use quando".
- Cada SKILL.md ≤ 250 linhas (`wc -l`).
- Estrutura obrigatória por skill: frontmatter `name`+`description`; Lei de Ferro em bloco de código no topo; linha "Anuncie ao começar"; fluxo numerado; formato de saída; tabela de red flags; seção "PRÓXIMA SKILL" (exceções: `validar` termina o fluxo → "PRÓXIMA SKILL: nenhuma — fluxo encerra"; `audora-commander` tem tabela de roteamento no lugar).
- Zero placeholders: proibido `TBD`, `TODO`, seção vazia.
- Schemas (nó do GRAFO, plano) vivem SÓ nos templates; skills referenciam `${CLAUDE_PLUGIN_ROOT}/templates/`.
- Caminhos canônicos nos projetos alvo (spec §3.8): `GRAFO.md` na raiz; `docs/audora/{GRAFO-ARQUIVO.md,planos/,e2e/,specs/}`.
- Versão do plugin: `0.1.0`.
- Commit ao fim de cada tarefa (checkpoint), mensagens `feat:`/`chore:`/`docs:`.

### Verificação estrutural reutilizável (usada nas tarefas 5–11)

```bash
f=skills/<nome>/SKILL.md
test "$(wc -l < "$f")" -le 250 \
  && grep -q "^name: <nome>$" "$f" \
  && grep -q "^description: Use quando" "$f" \
  && grep -q "Lei de Ferro" "$f" \
  && grep -q "Anuncie ao começar" "$f" \
  && grep -qiE "red flags|racionaliza" "$f" \
  && ! grep -qE "\bTBD\b|\bTODO\b" "$f" \
  && echo "ESTRUTURA OK"
```

---

### Task 1: Bootstrap do repositório git

**Files:**
- Create: `.gitignore`
- Já existentes a commitar: `PRD.md`, `docs/fundamentos.md`, `docs/specs/2026-08-14-audora-commander-design.md`, `docs/audora/planos/plano-v0.1.0-bootstrap.md`

- [ ] **Step 1:** `git init -b main` na raiz do projeto.
- [ ] **Step 2:** Criar `.gitignore` com conteúdo exato:

```
.in_use/
*.log
```

- [ ] **Step 3:** Verificar estado limpo esperado: `git status --short` lista somente os 5 arquivos acima como untracked.
- [ ] **Step 4:** `git add -A && git commit -m "chore: bootstrap do projeto — PRD, fundamentos, spec e plano"`.
- [ ] **Step 5:** Verificar: `git log --oneline` mostra 1 commit.

### Task 2: Manifests do plugin

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`

**Interfaces:**
- Produces: nome de plugin `audora-commander`, marketplace `audora-commander-dev` — usados na instalação (Task 13) e no README (Task 12).

- [ ] **Step 1:** Criar `.claude-plugin/plugin.json`:

```json
{
  "name": "audora-commander",
  "description": "Framework de desenvolvimento assistido por IA: 5 princípios, GRAFO vivo, processo proporcional ao risco, TDD e portões humanos",
  "version": "0.1.0",
  "author": { "name": "Italo Barros", "email": "italobarros.me@gmail.com" },
  "license": "MIT",
  "keywords": ["workflow", "tdd", "planning", "best-practices", "grafo"]
}
```

- [ ] **Step 2:** Criar `.claude-plugin/marketplace.json`:

```json
{
  "name": "audora-commander-dev",
  "description": "Marketplace local de desenvolvimento do audora-commander",
  "owner": { "name": "Italo Barros", "email": "italobarros.me@gmail.com" },
  "plugins": [
    {
      "name": "audora-commander",
      "description": "Framework de desenvolvimento assistido por IA: 5 princípios, GRAFO vivo, processo proporcional ao risco, TDD e portões humanos",
      "version": "0.1.0",
      "source": "./",
      "author": { "name": "Italo Barros", "email": "italobarros.me@gmail.com" }
    }
  ]
}
```

- [ ] **Step 3:** Verificar: `python -m json.tool .claude-plugin/plugin.json > /dev/null && python -m json.tool .claude-plugin/marketplace.json > /dev/null && echo JSON-OK` → `JSON-OK`.
- [ ] **Step 4:** Commit: `git add .claude-plugin && git commit -m "feat: manifests do plugin e marketplace local"`.

### Task 3: Hook SessionStart

**Files:**
- Create: `hooks/hooks.json`
- Create: `hooks/run-hook.cmd` (wrapper polyglot copiado/adaptado do padrão Superpowers — batch acha bash no Windows, `:` no-op em unix)
- Create: `hooks/session-start` (bash, sem extensão)

**Interfaces:**
- Produces: injeção de contexto curto que instrui invocar `audora-commander:audora-commander` — o texto exato abaixo.

- [ ] **Step 1:** Criar `hooks/hooks.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "shell": "bash",
            "async": false
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2:** Criar `hooks/run-hook.cmd` no padrão polyglot do Superpowers (batch: tenta `C:\Program Files\Git\bin\bash.exe`, depois `bash` no PATH, executa `%HOOK_DIR%%~1`; unix: bloco cmd vira heredoc no-op e o final chama `exec bash "$(dirname "$0")/$1"`).
- [ ] **Step 3:** Criar `hooks/session-start` que emite (formato Claude Code, `hookSpecificOutput.additionalContext`; escape JSON de `\n`) o texto exato:

> Framework audora-commander ativo. Ao receber demanda de software (criar, alterar, corrigir), invoque a skill `audora-commander:audora-commander` ANTES de agir. Fluxos de fase: grafo, escopo, plano, executar, e2e, validar. Instrução direta do usuário vale mais que o framework.

- [ ] **Step 4:** Verificar red→green: `CLAUDE_PLUGIN_ROOT=. bash hooks/session-start | python -m json.tool > /dev/null && echo HOOK-OK` → `HOOK-OK`; e `bash hooks/session-start | grep -q "audora-commander:audora-commander" && echo CONTEUDO-OK` → `CONTEUDO-OK`.
- [ ] **Step 5:** Commit: `git add hooks && git commit -m "feat: hook SessionStart com ponteiro curto"`.

### Task 4: Templates canônicos

**Files:**
- Create: `templates/GRAFO-template.md`
- Create: `templates/plano-template.md`

**Interfaces:**
- Produces: schema de nó (campos `id`, `estado`, `depende-de`, `criterios-aceite`, `decisoes`, `atualizado-em`, `origem`) e estrutura de seções (`## Constituição`, `## Índice de nós`, `## Nós`) — consumidos pelas skills grafo/escopo/plano/validar; formato de plano (header + tarefa com `depende-de` + passos checkbox) consumido por plano/executar.

- [ ] **Step 1:** Criar `templates/GRAFO-template.md` com: `versao-schema: 1` na primeira linha; seção `## Propósito` (3-5 linhas, marcada `[carga: sempre]`); `## Constituição` `[carga: sempre]` com subcampos stack, restrições, padrões, `como-rodar`; `## Índice de nós` `[carga: sempre]` (formato: `- <id> | <estado> | <título>`); `## Nós` `[carga: auto]` com um nó de exemplo completo usando o schema e estados válidos (`planejada|em-curso|bloqueada|entregue|descartada`), campo `origem: humano|inferido`, criterios-aceite em EARS, bloco de delta (`ADICIONADO/MODIFICADO/REMOVIDO`); rodapé explicando compactação (>300 linhas → GRAFO-ARQUIVO.md).
- [ ] **Step 2:** Criar `templates/plano-template.md` com: header (objetivo, arquitetura, link para nó do GRAFO, arquivos lidos), seção `## Notas de sessão` (para despejo pré-/clear), tarefa de exemplo com `depende-de`, requisito embutido, interfaces consome/produz, passos checkbox de 2-5 min (teste red → verificar red → implementar → verificar green → commit).
- [ ] **Step 3:** Verificar: `grep -q "versao-schema: 1" templates/GRAFO-template.md && grep -q "como-rodar" templates/GRAFO-template.md && grep -qE "planejada.*em-curso.*bloqueada.*entregue.*descartada" templates/GRAFO-template.md && grep -q "QUANDO" templates/GRAFO-template.md && grep -q "Notas de sessão" templates/plano-template.md && grep -q "depende-de" templates/plano-template.md && echo TEMPLATES-OK` → `TEMPLATES-OK`.
- [ ] **Step 4:** Commit: `git add templates && git commit -m "feat: templates canônicos de GRAFO e plano"`.

### Task 5: Skill grafo

**Files:**
- Create: `skills/grafo/SKILL.md`

**Interfaces:**
- Consumes: schema/caminhos do `templates/GRAFO-template.md` (Task 4).
- Produces: operações nomeadas usadas pelas outras skills: `bootstrap`, `carregar-contexto` (seções `sempre` + nós tocados), `registrar-no`, `registrar-delta`, `compactar`.

- [ ] **Step 1:** Escrever `skills/grafo/SKILL.md` conforme spec §3.2 e fundamentos P1. Frontmatter: `name: grafo`; `description: Use quando precisar criar, consultar ou atualizar o GRAFO.md de um projeto — bootstrap em projeto sem GRAFO, registro de nó/delta de demanda, compactação, ou carga de contexto no início de uma demanda.` Lei de Ferro: `REQUISITO NÃO ESCRITO NO GRAFO É REQUISITO QUE NÃO EXISTE`. Seções: as 5 operações acima (fluxo numerado cada); regras de leitura seletiva (nunca ler GRAFO inteiro; só seções `sempre` + nós da demanda); bootstrap brownfield (nós `origem: inferido`, confirmação ao toque); validação de schema antes de escrever (rejeitar delta que quebra schema); restrição de branch (só nós da demanda); tabela de red flags (mín. 3 linhas: "eu lembro do requisito", "atualizo o GRAFO depois", "carrego o GRAFO inteiro pra garantir").
- [ ] **Step 2:** Rodar verificação estrutural reutilizável com `<nome>=grafo` → `ESTRUTURA OK`.
- [ ] **Step 3:** Verificar conteúdo específico: `grep -q "GRAFO-template.md" skills/grafo/SKILL.md && grep -q "inferido" skills/grafo/SKILL.md && echo OK` → `OK`.
- [ ] **Step 4:** Commit: `git add skills/grafo && git commit -m "feat: skill grafo"`.

### Task 6: Skill escopo

**Files:**
- Create: `skills/escopo/SKILL.md`

**Interfaces:**
- Consumes: operações da skill grafo (registrar-no, registrar-delta).
- Produces: artefato de escopo fechado (nó preenchido ou `docs/audora/specs/<id>-escopo.md` em ALTA) — consumido pela skill plano.

- [ ] **Step 1:** Escrever `skills/escopo/SKILL.md` conforme spec §3.3 e fundamentos P3. Frontmatter: `name: escopo`; `description: Use quando uma demanda MÉDIA ou ALTA precisar de definição do "O Quê" — objetivo, critérios de aceite e fora-de-escopo — antes de qualquer código, ou quando outra fase reabrir o escopo.` Lei de Ferro: `NENHUM CÓDIGO ANTES DO ESCOPO FECHADO EM ARTEFATO ESCRITO`. Conteúdo: perguntas uma por vez só sobre comportamento; marcador `[PRECISA-CLARIFICAR]` obrigatório para lacuna (proibido preencher com suposição); critérios em EARS `QUANDO <condição> O SISTEMA DEVE <comportamento observável>`; distinção requisito-de-produto vs decisão-de-implementação (P1.5); teste discriminante de reabertura (P3.7); checklist de auto-revisão (sem marcador aberto? critérios testáveis? fora-de-escopo explícito? sem conflito com constituição?); portão humano de escopo; mensagem de fim de fase ("Fase fechada. Artefatos salvos: [...]. Seguro dar /clear agora."); red flags ("o usuário obviamente quer X", "detalhe depois", "escopo na cabeça já dá"). PRÓXIMA SKILL: plano.
- [ ] **Step 2:** Verificação estrutural com `<nome>=escopo` → `ESTRUTURA OK`.
- [ ] **Step 3:** Conteúdo específico: `grep -q "PRECISA-CLARIFICAR" skills/escopo/SKILL.md && grep -q "QUANDO" skills/escopo/SKILL.md && grep -q "PRÓXIMA SKILL" skills/escopo/SKILL.md && echo OK` → `OK`.
- [ ] **Step 4:** Commit: `git add skills/escopo && git commit -m "feat: skill escopo"`.

### Task 7: Skill plano

**Files:**
- Create: `skills/plano/SKILL.md`

**Interfaces:**
- Consumes: artefato de escopo (Task 6); `templates/plano-template.md` (Task 4).
- Produces: `docs/audora/planos/plano-<id>.md` — consumido pela skill executar.

- [ ] **Step 1:** Escrever `skills/plano/SKILL.md` conforme spec §3.4 e fundamentos P2. Frontmatter: `name: plano`; `description: Use quando o escopo de uma demanda MÉDIA ou ALTA estiver aprovado e for hora de planejar o "Como" — ler o código atual, mapear arquivos e gerar o plano-arquivo com tarefas autossuficientes.` Lei de Ferro: `PLANO SEM LEITURA DO CÓDIGO ATUAL É PLANO INVÁLIDO`. Conteúdo: duas passadas (grep/glob localiza → ler o que o plano toca); listar arquivos lidos no header; detecção de conflito GRAFO vs código durante leitura (sinalizar, humano decide); tarefas autossuficientes (requisito embutido, decisões, interfaces consome/produz, critério de done, `depende-de`); passos checkbox 2-5 min com caminhos exatos e código real; expansão de tarefa complexa só quando chega a vez; proibição de placeholders (lista explícita); gatilhos de replanejamento enumerados (P2.6); self-review (cobertura de critérios, scan de placeholder, consistência de nomes/tipos entre tarefas); portão humano em ALTA; red flags ("planejo de memória, conheço o projeto", "detalho essa tarefa depois", "plano na conversa basta"). PRÓXIMA SKILL: executar.
- [ ] **Step 2:** Verificação estrutural com `<nome>=plano` → `ESTRUTURA OK`.
- [ ] **Step 3:** Conteúdo específico: `grep -q "plano-template.md" skills/plano/SKILL.md && grep -q "depende-de" skills/plano/SKILL.md && echo OK` → `OK`.
- [ ] **Step 4:** Commit: `git add skills/plano && git commit -m "feat: skill plano"`.

### Task 8: Skill executar

**Files:**
- Create: `skills/executar/SKILL.md`

**Interfaces:**
- Consumes: plano-arquivo (Task 7) ou demanda direta (LEVE/HOTFIX).
- Produces: código + testes verdes + commits por etapa + lista "Decisões tomadas pela IA" — consumidos por e2e/validar.

- [ ] **Step 1:** Escrever `skills/executar/SKILL.md` conforme spec §3.5, fundamentos P5/transversais e regra global de testes do usuário. Frontmatter: `name: executar`; `description: Use quando houver plano aprovado (MÉDIA/ALTA) ou demanda LEVE/HOTFIX pronta para código — implementação TDD red-green com evidência real de execução.` Lei de Ferro: `NENHUM CÓDIGO DE PRODUÇÃO SEM TESTE FALHANDO ANTES`. Conteúdo: ordem por `depende-de`; ciclo por tarefa: red (teste falha pelo motivo certo, saída real conferida) → green (mínimo, saída real) → refactor; ênfase em integrações reais + casos de erro/borda (entradas inválidas, timeouts, estados parciais, retries) sobre caminho feliz; cobertura significativa, não numérica; commit por etapa verde (checkpoint); reancoragem pós-compactação (reler plano + nó); micro-decisões → "Decisões tomadas pela IA"; requisito de produto faltante → teste discriminante (esclarece ou volta a escopo); HOTFIX: teste que reproduz o defeito ANTES do fix; falha irrecuperável → nó `bloqueada` + diagnóstico + opções ao humano (reverter/replanejar/abandonar); red flags (tabela de racionalizações do TDD: "simples demais pra testar", "testo depois", "já testei manual", "só dessa vez"). PRÓXIMA SKILL: validar (que oferece e2e).
- [ ] **Step 2:** Verificação estrutural com `<nome>=executar` → `ESTRUTURA OK`.
- [ ] **Step 3:** Conteúdo específico: `grep -qi "red" skills/executar/SKILL.md && grep -qi "integraç" skills/executar/SKILL.md && grep -q "Decisões tomadas pela IA" skills/executar/SKILL.md && echo OK` → `OK`.
- [ ] **Step 4:** Commit: `git add skills/executar && git commit -m "feat: skill executar"`.

### Task 9: Skill e2e

**Files:**
- Create: `skills/e2e/SKILL.md`

**Interfaces:**
- Consumes: critérios EARS do nó; `como-rodar` da constituição do GRAFO.
- Produces: `docs/audora/e2e/e2e-<id>.md` (tabela critério → passo → evidência → veredito) — consumido pela skill validar.

- [ ] **Step 1:** Escrever `skills/e2e/SKILL.md` conforme spec §3.6 e fundamentos P5.x. Frontmatter: `name: e2e`; `description: Use quando a execução de uma demanda terminar com testes verdes e for hora de validar de ponta a ponta — levantar o projeto de verdade e exercitar a demanda como usuário real. Opcional, fortemente recomendada.` Lei de Ferro: `EVIDÊNCIA E2E VEM DO PRODUTO RODANDO, NUNCA DE SAÍDA DE TESTE DE UNIDADE`. Conteúdo: fluxo dos 7 passos da spec (ler como-rodar → perguntar uma vez se ausente e registrar na constituição → levantar em background → traduzir cada critério EARS em passo executável por tipo de projeto: web=browser, API=HTTP, CLI=invocação → executar coletando evidência por critério → gerar relatório → persistir cenário como regressão se houver infra (senão oferecer bootstrap mínimo ou arquivar junto ao plano) → teardown SEMPRE, sucesso ou falha); recusa do humano registrada no nó (`e2e: pulado-pelo-humano`); red flags ("teste de unidade verde já prova", "rodo o e2e só no final do projeto", "deixo o server rodando"). PRÓXIMA SKILL: validar.
- [ ] **Step 2:** Verificação estrutural com `<nome>=e2e` → `ESTRUTURA OK`.
- [ ] **Step 3:** Conteúdo específico: `grep -q "como-rodar" skills/e2e/SKILL.md && grep -qi "teardown" skills/e2e/SKILL.md && grep -q "pulado-pelo-humano" skills/e2e/SKILL.md && echo OK` → `OK`.
- [ ] **Step 4:** Commit: `git add skills/e2e && git commit -m "feat: skill e2e"`.

### Task 10: Skill validar

**Files:**
- Create: `skills/validar/SKILL.md`

**Interfaces:**
- Consumes: critérios do nó, evidências da executar, relatório da e2e.
- Produces: roteiro de validação; sync GRAFO→PRD pós-merge; arquivamento do plano.

- [ ] **Step 1:** Escrever `skills/validar/SKILL.md` conforme spec §3.7 e fundamentos P5. Frontmatter: `name: validar`; `description: Use quando a execução (e o e2e, se rodado) de uma demanda terminar — portão humano final com evidência mapeada aos critérios, e sync de GRAFO e PRD após o merge.` Lei de Ferro: `NENHUMA AFIRMAÇÃO DE SUCESSO SEM EVIDÊNCIA FRESCA DE EXECUÇÃO`. Conteúdo: oferecer e2e com recomendação forte se não rodou (recusa → registrar no nó); gate de evidência 1:1 (cada critério → comando + saída, OU item de validação humana; critério sem nenhum → não está pronto); roteiro de validação (comportamento sempre: comandos, telas, rotas, casos de erro; ALTA soma sumário por arquivo + trechos sensíveis + revisão adversarial por subagente de contexto limpo com resumo condensado); lista "Decisões tomadas pela IA"; portão: aprova/reprova/parcial com fluxos exatos (reprova por escopo → skill escopo; por execução → skill plano da etapa; parcial → aceito vira `entregue`, resto vira etapas novas); pós-aprovação+merge: sync delta, nó `entregue` compacta para GRAFO-ARQUIVO.md, promoção do resumo ao PRD.md com data, arquivamento do plano em `docs/audora/planos/arquivo/`; efeito irreversível fora do repo → comando + rollback preparados, humano executa/autoriza; red flags ("evidência de um critério basta", "o humano confia, pulo o roteiro", "atualizo o PRD outro dia"). PRÓXIMA SKILL: nenhuma — fluxo encerra.
- [ ] **Step 2:** Verificação estrutural com `<nome>=validar` → `ESTRUTURA OK`.
- [ ] **Step 3:** Conteúdo específico: `grep -q "1:1" skills/validar/SKILL.md && grep -qi "adversarial" skills/validar/SKILL.md && grep -q "PRD" skills/validar/SKILL.md && echo OK` → `OK`.
- [ ] **Step 4:** Commit: `git add skills/validar && git commit -m "feat: skill validar"`.

### Task 11: Skill audora-commander (porta de entrada)

**Files:**
- Create: `skills/audora-commander/SKILL.md`

**Interfaces:**
- Consumes: nomes exatos das 6 skills anteriores (grafo, escopo, plano, executar, e2e, validar) — escrita por último por isso.
- Produces: classificação + roteamento; é o alvo do ponteiro do hook (Task 3).

- [ ] **Step 1:** Escrever `skills/audora-commander/SKILL.md` conforme spec §3.1 e fundamentos P4. Frontmatter: `name: audora-commander`; `description: Use quando chegar qualquer demanda de software (criar, alterar, corrigir, refatorar) — porta de entrada do framework: classifica a demanda por risco e roteia para a fase certa. Invoque ANTES de agir na demanda.` Lei de Ferro: `NA DÚVIDA ENTRE DUAS CATEGORIAS, A MAIS PESADA`. Conteúdo: fluxo (1. carregar seção `sempre` do GRAFO via skill grafo — ausente → oferecer bootstrap; 2. checar nós `em-curso` (máx 3; acima → listar e perguntar pausar/continuar/abandonar); 3. classificar por perguntas binárias EM ORDEM: migração/dado persistido? API pública/contrato? auth/segurança/pagamento? efeito irreversível fora do repo? qualquer SIM → ALTA; múltiplos arquivos ou lógica nova → MÉDIA; resto → LEVE; 4. anunciar "Demanda classificada como X porque Y — me corrija se discordar"; 5. rotear); tabela de roteamento completa (a do P4.1, com portões e `[e2e]` recomendado); HOTFIX só por declaração explícita do humano, com regras (teste reproduz defeito, portão único, nó `hotfix-pendente-registro`); catraca (subir automático com aviso, descer só com humano); override do humano ("sem processo" é atendido sem insistência); registro do nó da demanda; red flags ("é só uma linha", "classifico LEVE pra ir rápido", "já entendi o suficiente", "processo aqui é exagero").
- [ ] **Step 2:** Verificação estrutural com `<nome>=audora-commander` (sem exigência de "PRÓXIMA SKILL"; exigir tabela: `grep -q "LEVE" && grep -q "HOTFIX"`) → `ESTRUTURA OK`.
- [ ] **Step 3:** Conteúdo específico: `grep -q "hotfix-pendente-registro" skills/audora-commander/SKILL.md && grep -qE "escopo|executar" skills/audora-commander/SKILL.md && echo OK` → `OK`.
- [ ] **Step 4:** Commit: `git add skills/audora-commander && git commit -m "feat: skill porta de entrada audora-commander"`.

### Task 12: README, GRAFO dogfood e PRD

**Files:**
- Create: `README.md`
- Create: `GRAFO.md` (do próprio repo, via template)
- Create: `docs/audora/GRAFO-ARQUIVO.md`
- Modify: `PRD.md` (seção "Estado atual")

- [ ] **Step 1:** Criar `README.md`: o que é (5 princípios em 5 linhas), instalação em sessão interativa do Claude Code (comandos exatos: `/plugin marketplace add C:\Users\Italo Barros\workspace\audora-commander` e `/plugin install audora-commander@audora-commander-dev`), fluxo de uso com exemplo de demanda MÉDIA, tabela das 7 skills, checklist de validação (os 5 critérios EARS da spec §6 como itens verificáveis pelo usuário).
- [ ] **Step 2:** Criar `GRAFO.md` do próprio repo a partir de `templates/GRAFO-template.md`: propósito, constituição (stack markdown+json, `como-rodar`: "plugin — validação via instalação em sessão interativa, ver README"), nós reais: `plugin-v0.1.0` (estado: `em-curso`, critérios = os 5 da spec §6) e nós `planejada` para metas futuras do PRD.
- [ ] **Step 3:** Atualizar `PRD.md` seção "Estado atual": "v0.1.0 implementada — 7 skills, hook, templates, marketplace local. Aguardando validação de instalação pelo usuário (checklist no README)." + data.
- [ ] **Step 4:** Verificar: `grep -q "plugin install audora-commander@audora-commander-dev" README.md && grep -q "versao-schema: 1" GRAFO.md && grep -q "em-curso" GRAFO.md && echo DOCS-OK` → `DOCS-OK`.
- [ ] **Step 5:** Commit: `git add README.md GRAFO.md docs/audora/GRAFO-ARQUIVO.md PRD.md && git commit -m "docs: README, GRAFO dogfood e estado do PRD"`.

### Task 13: Varredura final + instruções de instalação

**Files:**
- Nenhum novo; verificação global.

- [ ] **Step 1:** Varredura estrutural das 7 skills num loop:

```bash
for s in audora-commander grafo escopo plano executar e2e validar; do
  f="skills/$s/SKILL.md"
  ok=1
  test "$(wc -l < "$f")" -le 250 || ok=0
  grep -q "^name: $s$" "$f" || ok=0
  grep -q "^description: Use quando" "$f" || ok=0
  grep -q "Lei de Ferro" "$f" || ok=0
  grep -qiE "red flags|racionaliza" "$f" || ok=0
  grep -qE "\bTBD\b|\bTODO\b" "$f" && ok=0
  test $ok -eq 1 && echo "$s: OK" || echo "$s: FALHOU"
done
```

Expected: 7 linhas `OK`, zero `FALHOU`.

- [ ] **Step 2:** Validar todos os JSON: `for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do python -m json.tool "$j" > /dev/null || echo "FALHOU: $j"; done; echo FIM` → só `FIM`.
- [ ] **Step 3:** Re-testar hook: `CLAUDE_PLUGIN_ROOT=. bash hooks/session-start | python -m json.tool > /dev/null && echo HOOK-OK` → `HOOK-OK`.
- [ ] **Step 4:** `git status --short` vazio (tudo commitado); `git log --oneline` mostra os commits das tasks 1–12.
- [ ] **Step 5:** Entregar ao usuário os comandos de instalação (sessão interativa) e o checklist de validação do README — critérios 1, 2 e 5 da spec §6 dependem de sessão interativa e ficam com o humano (portão de resultado do próprio framework).
