# Escopo — grafo-v2 (ALTA)

> Nó: `grafo-v2` (GRAFO.md). Insumo técnico:
> docs/specs/2026-08-24-estudo-grafo-mercado.md (estudo de mercado, 10
> agentes). Data: 2026-08-24.

## Objetivo

Implementar o GRAFO v2 no formato do Candidato C do estudo (v2-híbrido):
GRAFO.md vira índice mestre permanente (Propósito + Constituição + índice
rico) e o corpo de cada nó vira arquivo próprio em `docs/audora/nos/<id>.md`
com frontmatter YAML grep-ável; arquivamento por movimento (`git mv`);
decisões vivas promovidas a `docs/audora/decisoes-vivas.md`; critérios EARS
numerados e citáveis; migração gradual com fallback de duas camadas (v1 é
caso degenerado válido, sem prazo de depreciação). Todas as skills do plugin
que leem/escrevem GRAFO passam a operar no substrato novo.

## Critérios de aceite (numerados — endereço citável `grafo-v2/<n>`)

### Estrutura

- **grafo-v2/1.1** — QUANDO um projeto usar o schema v2 O SISTEMA DEVE manter
  GRAFO.md na raiz contendo somente: `versao-schema: 2`, Propósito,
  Constituição e Índice de nós com linha rica por nó
  (`id | estado | título | resumo 1 frase | keywords | arquivos-chave`,
  linkando `docs/audora/nos/<id>.md`).
- **grafo-v2/1.2** — QUANDO um nó for criado no v2 O SISTEMA DEVE gravá-lo em
  `docs/audora/nos/<id>.md` com frontmatter YAML "1 campo = 1 linha" (id,
  estado, origem, depende-de, arquivos, keywords, resumo, atualizado-em) e
  corpo em prosa (objetivo, critérios EARS numerados, decisões, delta
  append-only).
- **grafo-v2/1.3** — QUANDO índice e pasta divergirem (nó sem linha do
  índice, linha sem arquivo, dep inexistente, ciclo) O SISTEMA DEVE acusar a
  divergência e PARAR — nunca operar sobre memória inconsistente.

### Travessia

- **grafo-v2/2.1** — QUANDO carregar-contexto rodar O SISTEMA DEVE ler
  somente o índice mestre + os arquivos dos nós tocados pela demanda — nunca
  a pasta inteira, nunca corpo de nó não relacionado.
- **grafo-v2/2.2** — QUANDO uma consulta estrutural for necessária (nós
  em-curso, quem depende de X, que nó governa o arquivo Y) O SISTEMA DEVE
  resolvê-la por grep no frontmatter/índice, sem carregar corpo de nó.
- **grafo-v2/2.3** — QUANDO o sync da validar rodar O SISTEMA DEVE preencher
  o campo `arquivos:` do nó a partir de `git diff --name-only` da demanda —
  do diff real, nunca da memória do LLM.

### Ciclo de vida

- **grafo-v2/3.1** — QUANDO um nó for entregue O SISTEMA DEVE, ANTES de
  arquivar, propor a promoção das decisões ainda válidas para
  `docs/audora/decisoes-vivas.md` (1 linha por decisão, com nó de origem e
  data; IA propõe no roteiro de validação, humano aprova no portão).
- **grafo-v2/3.2** — QUANDO um nó for arquivado O SISTEMA DEVE movê-lo
  (`git mv`) para `docs/audora/arquivo/AAAA-MM-DD-<id>.md` e trocar a linha
  do índice — movimento, nunca reescrita de conteúdo.
- **grafo-v2/3.3** — QUANDO um requisito ou decisão for invalidado O SISTEMA
  DEVE marcá-lo com `invalidado-em:` + `substituido-por:` em vez de apagar.

### Rastreabilidade

- **grafo-v2/4.1** — QUANDO critérios de aceite forem escritos no v2
  O SISTEMA DEVE numerá-los com endereço estável `<no-id>/<n>`, e QUANDO
  evidência for produzida (teste, commit, relatório e2e, roteiro de
  validação) O SISTEMA DEVE citar o endereço do critério correspondente.

### Migração e compatibilidade

- **grafo-v2/5.1** — QUANDO uma skill tocar um projeto com GRAFO v1
  O SISTEMA DEVE operar em modo compatível (fallback de duas camadas:
  detectar `versao-schema` na linha 1, tentar formato novo, cair para o
  monolito) sem exigir migração.
- **grafo-v2/5.2** — QUANDO um nó v1 for tocado por demanda nova O SISTEMA
  DEVE migrá-lo para arquivo próprio na mesma operação (migração on-touch);
  nós já entregues/arquivados nunca precisam migrar.
- **grafo-v2/5.3** — QUANDO um projeto permanecer no v1 O SISTEMA DEVE
  segui-lo suportando integralmente — v1 é caso degenerado válido do v2, sem
  prazo de depreciação.

### Hooks e degradação

- **grafo-v2/6.1** — QUANDO o plugin estiver instalado com Git Bash
  disponível O SISTEMA DEVE validar escritas do GRAFO por hooks (teto de
  linhas do índice e do nó; deps existentes; sem ciclo; índice↔pasta em
  sincronia), devolvendo o erro/aviso ao modelo no mesmo turno.
- **grafo-v2/6.2** — QUANDO hooks não puderem rodar (sem bash) O SISTEMA
  DEVE manter todas as operações válidas por instrução de skill — a skill é
  a fonte normativa; hook é rede de segurança, nunca dependência.

### Limites

- **grafo-v2/7.1** — QUANDO demanda nova chegar O SISTEMA DEVE continuar
  contando o máximo de 3 nós em-curso GLOBALMENTE, pelo índice mestre.
- **grafo-v2/7.2** — QUANDO o índice mestre passar de ~300 linhas ou um
  arquivo de nó passar de ~100 linhas O SISTEMA DEVE avisar e acionar a ação
  correspondente (compactação de índice; split de histórico frio do nó para
  `nos/<id>-historico.md`).

## Fora de escopo

- Federação/monorepo (Candidato D): fica FORA. Reservado apenas: sintaxe
  `chave:id` em depende-de (proibido `:` em id de nó) e regra de caminhos
  sempre relativos ao arquivo que os contém.
- Benchmark de tokens (decisão humana: ir direto ao C sem medir).
- Geração de `.claude/rules/grafo-<area>.md` com paths (adiado — nó futuro).
- Índice TSV derivado e scripts de consulta do Candidato B além dos hooks de
  validação listados (podem virar nó futuro).
- Prefixo numérico `NNN-` em ids (ids seguem kebab-case semântico).
- Skill MEMORY e reforço grafo-inicio-fim (nós próprios da fila).
- Script de migração mecânica em lote (rota gradual escolhida; script one-shot
  pode virar demanda se algum projeto pedir).

## Decisões

Humanas (portões desta fase):

- 2026-08-24: direção = Candidato C completo direto, sem benchmark, migração
  gradual.
- 2026-08-24: decisões vivas → `docs/audora/decisoes-vivas.md` grep-ável,
  `[carga: auto]`.
- 2026-08-24: EARS numerado citável (`<no-id>/<n>`) adotado.

Defaults da IA (revisar no portão desta spec):

- Índice mestre é EDITADO pelo LLM na mesma edição do nó (regra atual); hook
  VALIDA, não gera — regenerar por script tornaria bash obrigatório e
  quebraria grafo-v2/6.2.
- Hooks fazem parte do pacote v2 (grafo-guard, grafo-validate), com a
  degradação do grafo-v2/6.2.
- Caminhos canônicos: `docs/audora/nos/<id>.md`,
  `docs/audora/arquivo/AAAA-MM-DD-<id>.md`, `docs/audora/decisoes-vivas.md`.
- "Vivo vs histórico" na compactação: IA propõe, humano aprova no portão de
  validação já existente (nenhum portão novo).
- Tetos: ~300 linhas índice mestre; ~100 linhas por arquivo de nó.

## Riscos anotados

- Suporte dual v1/v2 consome linhas de SKILL.md (limite 250 da constituição
  do plugin) — a skill grafo é a mais pressionada; mitigação: mover detalhe
  de formato para os templates (schema canônico já vive lá).
- Sem benchmark, a estimativa de corte (65-70%) segue estimativa — o portão
  de validação do grafo-v2 exige revisão adversarial (ALTA) e o e2e da
  demanda deve exercitar uma travessia real comparada.
- Visão global ("o que o produto entrega?") regride de 1 Read para N Reads —
  mitigação futura: resumos de grupo no índice (fora deste escopo).
