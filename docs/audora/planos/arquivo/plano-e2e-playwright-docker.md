# Plano — e2e-playwright-docker: Playwright default web + compose como infra

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** Skill e2e passa a usar Playwright como ferramenta default para
projetos web e docker compose como infra default do teste, com artefatos
versionados no projeto-alvo.

**Nó do GRAFO:** `e2e-playwright-docker` (GRAFO.md)

**Arquitetura da mudança:** Reescrever o Fluxo da skill e2e em torno de duas
decisões novas: (1) infra — compose existente > compose gerado > fallback
como-rodar com aviso; (2) ferramenta — Playwright default se web, pergunta
obrigatória se não-web, com escolha registrada na Constituição do projeto-alvo
(mesmo mecanismo durável do como-rodar). Esqueleto do compose de e2e e
convenções de artefatos vão para `templates/e2e-infra-template.md` (constituição:
schemas vivem só em templates/). Nenhuma outra skill muda (fora-de-escopo).

**Arquivos lidos antes de planejar:**
- `skills/e2e/SKILL.md` — 81 linhas; passos 1-2 (como-rodar/levantar), 3
  (ferramenta auto por tipo — muda), 6 (persistência opcional — muda), 7
  (teardown — estende com compose down).
- `GRAFO.md` — nó e2e-playwright-docker (8 critérios EARS) + constituição
  (limite 250 linhas, schemas em templates/, padrões de skill).
- `templates/plano-template.md` e `templates/GRAFO-template.md` — formato;
  confirmam que templates/ é o lugar do esqueleto novo.
- Skills vizinhas (conteúdo carregado nesta sessão): `validar` (oferece o
  e2e — interface intacta), `audora-commander` (roteamento `[e2e]` — intacto).

**Conflitos GRAFO vs código encontrados:** nenhum.

## Notas de sessão

<!-- vazio — demanda executada na mesma sessão do plano -->

## Decisões tomadas pela IA (revisar na validação)

- Compose de e2e no projeto-alvo: arquivo `docker-compose.e2e.yml` na raiz.
- Specs Playwright no projeto-alvo: diretório `e2e/` (padrão Playwright);
  projeto com infra própria (Playwright/Cypress já configurado) → seguir o
  padrão existente (critério "estender, não recriar").
- Escolha de ferramenta não-web registrada na Constituição do GRAFO do
  projeto-alvo (bullet em `padroes`), via skill grafo — pergunta única por
  projeto, mesmo mecanismo do como-rodar.
- Description do frontmatter ganha menção a Playwright/compose (melhora
  discovery da skill sem mudar o gatilho).

---

## Tarefa 1: Reescrever o Fluxo da skill e2e

- **depende-de**: []
- **requisito**: critérios 1-8 do nó (todos moram no texto da skill — o
  "sistema" aqui é a skill instruindo o comportamento do agente).
- **decisões relevantes**: Playwright default SÓ web; não-web pergunta;
  compose existente > gerado > fallback como-rodar com aviso; artefatos
  versionados; falha de infra → log + pergunta; teardown compose down.
- **interfaces**:
  - consome: `templates/e2e-infra-template.md` (Tarefa 2 cria; a skill o
    referencia pelo caminho relativo à raiz do plugin, como grafo/plano fazem)
  - produz: `skills/e2e/SKILL.md` novo
- **arquivos**:
  - Modificar: `skills/e2e/SKILL.md`
- **done quando**: passos de infra (1-2), ferramenta (4), persistência (7) e
  teardown (8) refletem os 8 critérios; ≤ 250 linhas; seções obrigatórias do
  padrão de skill intactas (frontmatter, Lei de Ferro, Anuncie, Fluxo, red
  flags, PRÓXIMA SKILL).

Passos:

- [x] **1. RED** — greps que hoje falham (0 matches):
  `grep -c "compose" skills/e2e/SKILL.md` → 0;
  `grep -ci "perguntar ao humano qual ferramenta" skills/e2e/SKILL.md` → 0.
- [x] **2. Reescrever o Fluxo** com esta estrutura (texto final na execução,
  sem placeholder — resumo dos passos novos):
  1. Infra do teste — ordem de decisão: compose existente (`docker-compose*.yml`)
     → usar; ausente → GERAR `docker-compose.e2e.yml` pela stack/constituição
     usando `templates/e2e-infra-template.md`, versionado; Docker indisponível
     (`docker compose version` falha) → aviso explícito + fallback como-rodar
     (ausente/quebrado → perguntar UMA vez e registrar, skill grafo).
  2. Levantar e confirmar: `docker compose -f docker-compose.e2e.yml up -d --wait`
     (ou como-rodar em background); confirmar porta/log. Falha ao subir →
     reportar LOG + perguntar corrigir/fallback/abortar. Nunca infra parcial.
  3. Ferramenta: Web → Playwright DEFAULT (specs em `e2e/`, estender config
     existente); não-web → PERGUNTAR ao humano, registrar na Constituição.
  4. Traduzir critérios em passos (mantido, referências ajustadas).
  5. Executar e coletar evidência (mantido).
  6. Relatório (mantido).
  7. Persistir como regressão: artefatos SEMPRE versionados; existentes →
     estender, nunca recriar (substitui o "oferecer bootstrap/ad-hoc").
  8. Teardown SEMPRE: `docker compose ... down` ou matar processo do
     como-rodar — sucesso ou falha.
  Red flags novas: infra parcial; escolher ferramenta não-web sozinho;
  recriar spec/compose em vez de estender.
- [x] **3. GREEN** — greps do passo 1 agora ≥ 1; `wc -l` ≤ 250; seções
  obrigatórias presentes (grep por "LEI DE FERRO", "Anuncie ao começar",
  "## Fluxo", "Red flags", "PRÓXIMA SKILL"); scan de placeholder
  (grep -n "TBD\|TODO" → vazio).

## Tarefa 2: Criar templates/e2e-infra-template.md

- **depende-de**: []
- **requisito**: QUANDO o projeto não tiver docker compose O SISTEMA DEVE
  gerar um compose de e2e a partir da stack/constituição (critério 4) —
  esqueleto canônico vive em templates/ (constituição do plugin).
- **decisões relevantes**: nome `docker-compose.e2e.yml`; specs em `e2e/`.
- **interfaces**:
  - consome: nada
  - produz: template referenciado pela Tarefa 1 (caminho exato
    `templates/e2e-infra-template.md`)
- **arquivos**:
  - Criar: `templates/e2e-infra-template.md`
- **done quando**: template contém esqueleto do compose (app + dependência
  com healthcheck + rede/volumes mínimos), convenções de nome/local dos
  artefatos e esqueleto de spec Playwright, com comentários de preenchimento
  no mesmo estilo dos templates existentes.

Passos:

- [x] **1. Escrever o template** — esqueleto compose com serviço `app`
  (build ou image da stack), serviço de dependência exemplo (`db` com
  healthcheck), `--wait`-friendly; esqueleto `e2e/<id>.spec.ts` mínimo;
  regras de preenchimento em comentário HTML como nos templates atuais.

## Tarefa 3: Verificação final + commit

- **depende-de**: [1, 2]
- **requisito**: todos os 8 critérios do nó com evidência mapeada no texto.
- **decisões relevantes**: commit único (skill + template + plano + GRAFO).
- **interfaces**:
  - consome: Tarefas 1 e 2
  - produz: evidência para o portão de validação
- **arquivos**: nenhum novo.
- **done quando**: mapa critério→trecho da skill completo, checks verdes,
  commit existe.

Passos:

- [x] **1. Mapa 1:1** — para cada critério 1-8, grep do trecho da skill que o
  implementa (saída real anexada ao portão).
- [x] **2. Referência cruzada** — `grep -rn "e2e-infra-template"` retorna a
  skill e o template (sem referência órfã).
- [x] **3. Commit** — `git add skills/e2e/SKILL.md
  templates/e2e-infra-template.md docs/audora/planos/plano-e2e-playwright-docker.md
  GRAFO.md && git commit -m "feat: skill e2e — Playwright default web, docker
  compose como infra default, artefatos versionados"`.
