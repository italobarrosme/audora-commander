# Spec de design — plugin audora-commander

Data: 2026-08-14
Status: em revisão pelo usuário
Fundamentos: ver [docs/fundamentos.md](../fundamentos.md) — este documento define
COMO os fundamentos viram um plugin de Claude Code; os fundamentos definem O QUÊ
cada regra significa e por quê.

## 1. Visão

Plugin de Claude Code no padrão Superpowers que implementa um framework de
desenvolvimento de software assistido por IA, guiado pelos 5 Princípios de AI
Coding (fundamentos v2). Público: dev solo/pequeno time, projetos web/mobile/api.

O diferencial competitivo (lacuna nº 1 do gênero): processo proporcional ao
risco da demanda — bug de 1 linha não paga cerimônia de arquitetura, e migração
de banco não passa sem portões.

## 2. Estrutura do repositório

```
audora-commander/
├── .claude-plugin/
│   ├── plugin.json          # name: audora-commander, versão 0.1.0
│   └── marketplace.json     # marketplace local para instalação
├── hooks/
│   └── hooks.json           # SessionStart → injeta ponteiro curto
├── skills/
│   ├── audora-commander/SKILL.md   # porta de entrada + classificação + roteamento
│   ├── grafo/SKILL.md              # GRAFO.md vivo (schema, bootstrap, delta/sync)
│   ├── escopo/SKILL.md             # fase "O Quê"
│   ├── plano/SKILL.md              # fase "Como" just-in-time
│   ├── executar/SKILL.md           # TDD red-green com evidência
│   ├── e2e/SKILL.md                # validação E2E da demanda (opcional, recomendada)
│   └── validar/SKILL.md            # portão humano + sync de docs
├── docs/
│   ├── fundamentos.md              # fundamentos v2 (fonte de verdade conceitual)
│   └── specs/                      # este documento
├── templates/
│   ├── GRAFO-template.md           # esqueleto do GRAFO.md com schema de nó
│   └── plano-template.md           # esqueleto do plano-<id>.md
├── README.md                       # o que é, instalação, uso, exemplo de fluxo
└── PRD.md                          # regra global do usuário
```

Decisões:
- **Conteúdo das skills em português.** Frontmatter `description` também em
  português, com gatilhos explícitos (palavras que o usuário usaria) para o
  disparo automático por descrição funcionar.
- **Templates separados das skills**: GRAFO e plano têm esqueleto canônico em
  `templates/`; as skills referenciam o template em vez de embutir o formato
  duas vezes (uma fonte de verdade para o schema).
- **Skills pequenas**: cada SKILL.md ≤ ~250 linhas. Detalhe conceitual fica em
  fundamentos.md; a skill carrega só o operacional (Lei de Ferro, checklist,
  red flags, formato de saída).

## 3. As 7 skills

Estrutura comum a todas (padrão Superpowers, validado pela comunidade):
- Frontmatter: `name` + `description` ("Use quando...").
- **Lei de Ferro** no topo, em bloco de código.
- "Anuncie ao começar: 'Usando [skill] para [propósito]'".
- Fluxo numerado determinístico + formato de saída exato.
- Tabela de red flags / racionalizações no fim.
- Encadeamento explícito: skill aponta a próxima por nome (PRÓXIMA SKILL).

### 3.1 audora-commander (porta de entrada)

- **Dispara**: início de qualquer demanda de software; ou invocação manual.
- **Lei de Ferro**: `NA DÚVIDA ENTRE DUAS CATEGORIAS, A MAIS PESADA`.
- **Faz**:
  1. Carrega seção `sempre` do GRAFO.md do projeto alvo (propósito +
     constituição + índice de nós). GRAFO ausente → aciona skill grafo
     (bootstrap) antes de qualquer outra coisa.
  2. Verifica nós `em-curso` (máx 3); acima → lista e pergunta:
     pausar/continuar/abandonar.
  3. Classifica a demanda pelas perguntas binárias (fundamentos P4.2) e anuncia:
     "Demanda classificada como X porque Y — me corrija se discordar".
  4. Roteia pela tabela de categorias (P4.1). HOTFIX só se o humano declarar.
  5. Registra/atualiza o nó da demanda no GRAFO (via regras da skill grafo).
- **Não faz**: escopo, plano, código — só classifica, prepara contexto e roteia.
- **PRÓXIMA SKILL**: conforme categoria (escopo | executar).

### 3.2 grafo

- **Dispara**: bootstrap (GRAFO ausente), consulta/atualização de nó, sync.
- **Lei de Ferro**: `REQUISITO NÃO ESCRITO NO GRAFO É REQUISITO QUE NÃO EXISTE`.
- **Formato do GRAFO.md** (template canônico):
  - Seção `sempre`: propósito (3-5 linhas) + constituição (stack, restrições,
    padrões, `como-rodar`) + índice de nós (1 linha por nó: id, estado, título).
  - Seção `nos`: um bloco por nó ativo com schema completo (P1.1).
  - `GRAFO-ARQUIVO.md`: nós entregues compactados (1 linha + link).
- **Faz**: bootstrap brownfield (nós `inferido`), validação de schema antes de
  escrever, registro de delta (`ADICIONADO`/`MODIFICADO`/`REMOVIDO`), compactação
  quando GRAFO ativo > 300 linhas, leitura seletiva (nunca o arquivo inteiro).
- **Relação com PRD.md**: direção única GRAFO → PRD, aplicada pela skill validar
  no merge. Compatível com a regra global do usuário (PRD segue a main).

### 3.3 escopo (fase "O Quê")

- **Dispara**: categoria MÉDIA/ALTA; ou reabertura de escopo vinda de outra fase.
- **Lei de Ferro**: `NENHUM CÓDIGO ANTES DO ESCOPO FECHADO EM ARTEFATO ESCRITO`.
- **Faz**: perguntas uma por vez (só sobre comportamento, nunca sobre código);
  lacuna vira `[PRECISA-CLARIFICAR]`; critérios de aceite em EARS ("QUANDO X O
  SISTEMA DEVE Y"); fecha com objetivo + critérios + fora-de-escopo no nó
  (LEVE/MÉDIA: no próprio nó; ALTA: spec dedicada linkada pelo nó); roda
  checklist de auto-revisão (P3.4); apresenta ao humano (portão de escopo).
- **Ao fechar**: "Fase fechada. Artefatos salvos: [...]. Seguro dar /clear
  agora." + PRÓXIMA SKILL: plano.

### 3.4 plano (fase "Como" just-in-time)

- **Dispara**: escopo aprovado (MÉDIA/ALTA).
- **Lei de Ferro**: `PLANO SEM LEITURA DO CÓDIGO ATUAL É PLANO INVÁLIDO`.
- **Faz**: duas passadas (localizar → ler); detecção de conflito GRAFO vs código
  no caminho; gera `plano-<id>.md` pelo template: header (objetivo, arquitetura,
  link pro nó), tarefas autossuficientes com `depende-de`, passos checkbox de
  2-5 min com caminhos exatos e código real (sem placeholders); expansão de
  tarefa complexa só quando chega a vez; self-review (cobertura dos critérios,
  scan de placeholder, consistência de tipos). Categoria ALTA → portão humano
  do plano.
- **PRÓXIMA SKILL**: executar.

### 3.5 executar (TDD)

- **Dispara**: plano existente (MÉDIA/ALTA), ou direto (LEVE/HOTFIX).
- **Lei de Ferro**: `NENHUM CÓDIGO DE PRODUÇÃO SEM TESTE FALHANDO ANTES`.
- **Faz**: por tarefa do plano (ordem por `depende-de`): red (teste falha pelo
  motivo certo, saída real conferida) → green (mínimo pra passar, saída real) →
  refactor; ênfase em integrações + casos de erro (regra global do usuário);
  commit por etapa verde (checkpoint); reancoragem pós-compactação (reler plano
  + nó); micro-decisões registradas em "Decisões tomadas pela IA"; requisito de
  produto faltante → teste discriminante (P3.7): esclarece ou volta ao escopo.
  Falha irrecuperável → nó `bloqueada` + diagnóstico, humano escolhe.
- **PRÓXIMA SKILL**: validar (que oferece e2e).

### 3.6 e2e (validação E2E da demanda — opcional, fortemente recomendada)

- **Dispara**: oferecida SEMPRE pela validar (MÉDIA/ALTA; LEVE se fizer sentido);
  invocável direto. Humano pode recusar → nó registra `e2e: pulado-pelo-humano`.
- **Lei de Ferro**: `EVIDÊNCIA E2E VEM DO PRODUTO RODANDO, NUNCA DE SAÍDA DE
  TESTE DE UNIDADE`.
- **Faz**:
  1. Lê `como-rodar` da constituição; ausente → pergunta uma vez e registra.
  2. Levanta o projeto (dev server / app / API) em background.
  3. Traduz cada critério EARS em passo executável: web → browser (Playwright ou
     ferramentas de browser disponíveis na sessão); API → chamadas HTTP; CLI →
     invocações reais.
  4. Executa e coleta evidência por critério (screenshot, resposta, saída).
  5. Gera `e2e-<id>.md`: tabela critério → passo → evidência → veredito.
  6. Persistência: projeto com infra de e2e → salva cenário como teste
     permanente no padrão do projeto; sem infra → oferece bootstrap mínimo ou
     arquiva script junto ao plano.
  7. Teardown sempre (sucesso ou falha).
- **PRÓXIMA SKILL**: validar (com o relatório anexado).

### 3.7 validar (portão final)

- **Dispara**: fim da execução de qualquer categoria.
- **Lei de Ferro**: `NENHUMA AFIRMAÇÃO DE SUCESSO SEM EVIDÊNCIA FRESCA DE EXECUÇÃO`.
- **Faz**:
  1. Oferece e2e com recomendação forte (se ainda não rodou).
  2. Gate de evidência: mapeia cada critério de aceite → comando + saída (ou
     item de validação humana). Critério descoberto sem cobertura → volta.
  3. Monta roteiro de validação: comportamento sempre; ALTA soma sumário por
     arquivo + trechos sensíveis + revisão adversarial por subagente de contexto
     limpo (resultado condensado no roteiro).
  4. Lista "Decisões tomadas pela IA" para revisão.
  5. Portão humano: aprova / reprova / aprova parcial (fluxos do P5.5).
  6. Pós-aprovação + merge na main: sync do GRAFO (delta consolida, nó
     `entregue` compacta pro arquivo), promoção do resumo ao PRD.md com data,
     arquivamento do plano. Efeito irreversível fora do repo → comando + rollback
     preparados, humano executa/autoriza.

## 3.8 Artefatos nos projetos alvo (caminhos canônicos)

Todo projeto que usa o framework guarda artefatos em lugares fixos — skill nunca
inventa caminho:

- `GRAFO.md` — raiz do projeto (visibilidade máxima; par do PRD.md).
- `docs/audora/GRAFO-ARQUIVO.md` — nós entregues compactados.
- `docs/audora/planos/plano-<id>.md` — planos ativos; arquivados viram
  `docs/audora/planos/arquivo/plano-<id>.md` após validação.
- `docs/audora/e2e/e2e-<id>.md` — relatórios E2E.
- Specs de escopo ALTA: `docs/audora/specs/<id>-escopo.md`.

O template do GRAFO leva campo `versao-schema: 1` no topo — migrações futuras de
formato ficam baratas.

**Override do humano**: instrução direta do usuário vale mais que o framework.
"Sem processo, só responde" é atendido; a porta de entrada não insiste.

## 4. Hook SessionStart

Injeta ponteiro CURTO (não a skill inteira — diferente do Superpowers, alinhado
ao padrão-mãe "contexto é gargalo"):

> Framework audora-commander ativo. Ao receber demanda de software (criar,
> alterar, corrigir), invoque a skill `audora-commander:audora-commander` ANTES
> de agir. Fluxos de fase: grafo, escopo, plano, executar, e2e, validar.

Formato do hooks.json: mesmo mecanismo do Superpowers (SessionStart →
additionalContext).

## 5. Interação com Superpowers e regras globais do usuário

- **Convivência**: audora-commander governa O PROCESSO da demanda (fases,
  portões, GRAFO); skills do Superpowers continuam utilizáveis como ferramentas
  dentro das fases (ex.: systematic-debugging durante executar). Em conflito de
  processo, a porta de entrada do audora-commander prevalece quando o usuário a
  invocou; CLAUDE.md do usuário prevalece sobre tudo.
- **Regra global de testes** do usuário: embutida na executar (rigor red/green,
  integrações, casos de erro) e na e2e.
- **Regra global do PRD.md**: implementada pela validar (promoção GRAFO → PRD
  no merge com data de atualização).

## 6. Validação do plugin (critérios de aceite do projeto)

1. QUANDO o marketplace local for adicionado e o plugin instalado, O SISTEMA
   DEVE listar as 7 skills com prefixo `audora-commander:`.
2. QUANDO uma sessão nova iniciar com o plugin ativo, O SISTEMA DEVE injetar o
   ponteiro do hook no contexto.
3. QUANDO a skill `audora-commander` for invocada num projeto sem GRAFO.md,
   O SISTEMA DEVE oferecer bootstrap em vez de travar ou inventar conteúdo.
4. QUANDO cada skill for invocada isoladamente, O SISTEMA DEVE carregar seu
   conteúdo sem erro e sem placeholders (`TBD`, seções vazias).
5. QUANDO uma demanda simulada (dry-run em projeto de exemplo) percorrer
   LEVE e MÉDIA, O SISTEMA DEVE produzir os artefatos esperados (nó no GRAFO,
   plano-arquivo na MÉDIA, roteiro de validação).

Método: instalação real via marketplace local + teste de fumaça guiado por
checklist no README. Sem framework de teste automatizado — o "código" é
markdown + json; validação é estrutural (checklist por skill: frontmatter
`name`/`description` presentes, Lei de Ferro no topo, tabela de red flags,
PRÓXIMA SKILL definida, zero placeholders) e funcional (dry-run do item 5).

## 6.1 Dogfooding

O próprio repositório audora-commander ganha `GRAFO.md` e é desenvolvido pelo
próprio fluxo (nós por skill, plano-arquivo, portões). Duplo ganho: o framework
é testado de verdade durante a construção, e o repo vira exemplo vivo para quem
instalar. Git: `git init` no início da implementação; commit ao fim de cada
etapa verde (regra transversal do próprio framework).

## 7. Fora de escopo (v0.1.0)

- Suporte a outros harnesses (Codex, Cursor etc.) — estrutura não impede,
  mas não será portado agora.
- Publicação em marketplace público.
- Agentes dedicados (subagent types customizados) — skills usam os agentes
  padrão da sessão.
- Automação de git hooks (pre-commit etc.).
