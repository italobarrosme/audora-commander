# Estudo de mercado — GRAFO v2 (travessia rápida)

> Data: 2026-08-24. Insumo da fase de escopo da demanda `grafo-v2` (ALTA).
> Gerado por workflow multi-agente (10 agentes: 5 ângulos de pesquisa, crítico
> de completude, pesquisas de lacuna, síntese).

## Sumário executivo

A dor: uma demanda MÉDIA gasta hoje ~10-25k tokens só de travessia de memória —
5 a 7 leituras integrais do GRAFO.md (a carga seletiva é política sem mecanismo:
a unidade física de leitura é o arquivo inteiro), agravadas pelo `/clear` entre
fases que impede qualquer amortização. Foram estudados 5 ângulos (repo maps de
ferramentas de código, memória de agentes, frameworks spec-driven, anatomia do
GRAFO v1 e travessia de Markdown em texto puro) mais 3 lacunas apontadas pelo
crítico (monorepo/federação, mecânica real dos hooks do Claude Code, benchmark
de validação). O prior art converge: nenhum sistema maduro guarda requisitos num
arquivo único — todos usam índice pequeno sempre em contexto + unidade-por-
arquivo carregada sob demanda. Recomendação em 1 frase: adotar o Candidato C
(v2-híbrido: GRAFO.md como índice mestre + 1 nó = 1 arquivo) como alvo
arquitetural, sequenciado em 3 passos que usam os Candidatos A e B como etapas,
com portão de benchmark (corte ≥50% de tokens na demanda média) antes do split.

## Candidatos de arquitetura

### Candidato A — v1.5: arquivo único endurecido (índice rico + travessia por âncora grep + campos aditivos + hooks de enforcement)

**Resumo.** Mantém GRAFO.md como arquivo único e fonte de verdade, mas
transforma a carga seletiva de política em mecanismo: âncora `### <id>` vira
contrato do schema, o índice ganha metadados de decisão (resumo, keywords,
arquivos) e a leitura de um nó passa a ser "grep -n da âncora + Read
offset/limit até o próximo ###" — 2 operações baratas em vez de leitura
integral. Hooks bash opcionais impõem o limite de linhas e a integridade de
depende-de no momento da escrita (padrão MEMORY.md do Claude Code: erro
devolvido pela ferramenta, não regra que o LLM precisa lembrar).

**Mudanças no grafo:**

- Invariante novo do schema: heading de nó contém SOMENTE o id (âncora
  contratual estável, estilo ctags tagaddress/Zettelkasten); título humano vive
  apenas no índice
- Linha de índice enriquecida (padrão llms.txt):
  `- <id> | <estado> | <título> | <resumo 1 frase> | <keywords> |
  <arquivos-chave>` — decide relevância sem abrir o nó
- Protocolo de leitura na skill grafo: `grep -n '^### <id>' GRAFO.md` →
  `Read offset/limit` até o próximo `^### `; consulta reversa "quem depende de
  X" = `grep -n 'depende-de.*X'` (backlinks por varredura, estilo Foam — zero
  manutenção)
- Campos opcionais aditivos no nó: `arquivos:` (paths/globs, preenchido no sync
  da validar via `git diff --name-only ORIG_HEAD..HEAD` — lição File List do
  BMAD: derivar do diff real, nunca da memória do LLM), `invalidado-em:` +
  `substituido-por:` (invalidação bi-temporal do Zep: decisões nunca são
  apagadas, ganham marcação)
- Ordem de corte e budget de carga explícitos na skill (lição aider): nós
  mencionados na demanda > 1 salto via depende-de > hit de grep por keyword;
  teto numérico de linhas carregadas
- 4 hooks bash opcionais (protótipos prontos no corpus): grafo-guard (aviso
  >300 linhas via PostToolUse exit 2), grafo-validate-deps (dep inexistente +
  ciclo via awk DFS), grafo-inventario (TSV derivado id→linha/estado, async),
  grafo-sync-arquivos (injeta git diff no contexto do sync)
- Regra de compactação corrigida: gatilho por estado (nó entregue) + orçamento
  por seção, e promoção de decisões vivas de nós entregues para camada
  consultável antes do arquivamento

**Prós:**

- Menor esforço e menor risco: zero mudança de topologia de arquivos —
  brownfield não migra nada, só ganha capacidades
- Corte estimado de ~60-68% dos tokens de travessia na demanda média
  (benchmark do corpus: v1.5 ~1,8-2,3k vs v1 ~5,5-6,5k tokens no regime
  pós-compactação), ~60% do ganho do split por ~5% do custo
- Zero artefato que dessincroniza: sem inventário persistido obrigatório —
  offset resolvido em tempo de leitura por grep
- Todas as 5 operações da skill (API consumida pelas outras 7 skills)
  preservadas com assinatura idêntica
- Degradação graciosa total: sem bash/hooks, tudo continua operável por
  instrução de skill pura
- Visão global do produto em 1 Read continua disponível (vence na demanda
  ampla D6, onde o split regride)

**Contras:**

- Não resolve a contenção de merge: índice compartilhado no arquivo único segue
  garantindo conflito entre branches concorrentes com nós disjuntos
  (interrupção humana obrigatória pela regra "nunca auto-resolver")
- Não resolve o beco da compactação: GRAFO >300 linhas com nós ativos grandes
  continua sem ação válida de redução
- Read offset/limit por âncora é frágil se o formato do heading escorregar
  (depende de disciplina + hook de validação de formato)
- O custo de escrita do sync continua uma transação em 3-4 arquivos sem
  atomicidade
- É teto, não caminho: se o produto crescer (muitos nós ativos, monorepo), o
  arquivo único volta a doer e a migração ao split acontece de qualquer jeito,
  mais tarde e com mais nós para mover

**Esforço:** baixo

**Migração do schema v1.** 100% aditiva, sem big-bang: (1) bump para
`versao-schema: 1.1` ou `2-modo-mono` no cabeçalho; (2) normalizar headings
para "id puro" (na prática já é o caso — verificar por grep); (3) enriquecer
linhas do índice na próxima compactação (a skill reescreve o índice ao tocar
cada nó, não em lote); (4) campos novos são opcionais — LLM lendo v1 ignora o
que não conhece, nós antigos sem `arquivos:` seguem válidos; (5) hooks entram
via hooks.json do plugin + .gitattributes (`hooks/* eol=lf`) — projeto sem bash
continua funcionando como hoje. Nenhum GRAFO.md brownfield existente precisa de
qualquer edição no dia 1.

### Candidato B — v2-derivado: GRAFO.md canônico + camada de consulta 100% gerada (índice TSV estilo ctags + scripts bash de operação)

**Resumo.** Mantém o GRAFO.md monolítico como única fonte de verdade escrita
pelo LLM, mas acrescenta uma camada de artefatos DERIVADOS e regeneráveis,
gerados por hooks/scripts bash: um inventário ordenado
id→linha/arquivo/estado/deps (análogo ao arquivo tags do ctags e ao objects.inv
do Sphinx), contagem de referências (grau de entrada por nó), e scripts de
consulta nomeados que a skill invoca como comandos canônicos (extrair-no <id>,
deps-reversas <id>, proximo-no, validar-grafo). Paga-se o custo na escrita
(hook determinístico, custo zero de LLM), nunca na leitura — o princípio
GraphRAG de "sumarizar/indexar na escrita" aplicado sem nenhum LLM na
indexação.

**Mudanças no grafo:**

- GRAFO.md permanece formato v1 + campos aditivos do Candidato A (arquivos:,
  invalidado-em, substituido-por) — a mudança está em VOLTA do arquivo, não
  nele
- Artefato derivado docs/audora/GRAFO-INDICE.tsv com header "GERADO — NÃO
  EDITAR": uma linha por nó
  `id \t estado \t linha \t arquivo \t deps \t refs-entrada`, regenerado por
  hook PostToolUse (tmp+mv atômico); gitignorável ou versionado, nunca fonte de
  verdade
- Biblioteca de scripts em hooks/lib/ (awk/sed/grep + perl JSON::PP, tudo
  garantido no Git for Windows — sem jq, sem python/node): extrair-no
  (`awk '/^### id$/,/^### /'`), deps-reversas (grep), proximo-no (único
  pendente com deps entregues, operação `next` do Taskmaster), validar-grafo
  (ids do índice == headings; deps existem; sem ciclo)
- Skill grafo passa a instruir os comandos canônicos em vez de heurística de
  leitura: "consulte o TSV (dezenas de tokens), depois extraia só o nó X" —
  travessia vira O(inventário) + O(nós tocados)
- Marcação de nós hub no índice via contagem de referências (sinal de
  importância do aider sem PageRank): sufixo `[refs: N]` gerado pelo hook
- Detecção de drift barata: hook compara `git log -1 --format=%cs` dos arquivos
  em `arquivos:` vs `atualizado-em` do nó e avisa nó possivelmente obsoleto

**Prós:**

- Melhor razão rigor/custo em consulta: qualquer pergunta estrutural (quem
  depende de X, qual o próximo nó, que nó governa src/auth.ts) vira 1 comando
  bash determinístico, sem gastar token de raciocínio nem correr risco de erro
  de seleção do LLM
- Fonte de verdade intocada: diff, revisão humana e adoção brownfield idênticos
  ao v1; o TSV se regenera do zero a qualquer momento (indexação incremental
  sem custo de sync tipo Merkle)
- Integridade referencial de verdade: validate-deps a cada escrita dá ao GRAFO
  a primeira garantia estrutural mecânica — pré-requisito de qualquer travessia
  confiável
- Alinha com a fronteira ótima identificada no corpus: "GRAFO.md canônico
  escrito por LLM + derivados opcionais por bash hook — nada que dessincroniza
  vira fonte de verdade"
- Compatível com o Candidato A (v1.5 é o subconjunto sem scripts) e com o C
  (os mesmos scripts operam sobre a pasta de nós)

**Contras:**

- Herda os defeitos estruturais do arquivo único: contenção de merge no índice,
  beco da compactação com nós ativos grandes, sync multi-arquivo sem
  atomicidade — nada disso é atacado
- O inventário com números de linha é intrinsecamente volátil: todo Edit
  desloca offsets, então o TSV SÓ é confiável se o hook rodar sempre — máquina
  sem bash degrada para o fluxo v1 (aceitável, mas o ganho some
  silenciosamente)
- Dependência maior de portabilidade Windows (CRLF, spawn cmd→bash ~100-300ms
  por disparo, perl/awk): superfície de manutenção do plugin cresce em bash,
  que é mais difícil de testar que instrução de skill
- Risco de dupla fonte de instrução: skill precisa cobrir os dois modos (com e
  sem scripts), aumentando o tamanho das SKILL.md (limite de 250 linhas)

**Esforço:** médio

**Migração do schema v1.** Zero migração de dados: o GRAFO.md v1 existente já é
entrada válida — o hook roda uma vez e o TSV passa a existir (adoção parcial
dia 1). Entregáveis: 4-5 arquivos novos em hooks/, 1 edição no hooks.json
(bloco PostToolUse com matcher Edit|Write + guarda de file_path),
.gitattributes novo (`hooks/* eol=lf`, `*.cmd eol=crlf` — pré-requisito antes
do merge, o repo não tem e a máquina usa autocrlf=true), e ~10-15 linhas novas
na skill grafo apontando os comandos canônicos com fallback instrucional.
Campos aditivos (arquivos:, invalidado-em) entram como no Candidato A. Rollback
trivial: apagar hooks = voltar ao v1 intacto.

### Candidato C — v2-híbrido: índice mestre + 1 nó = 1 arquivo (sharding estilo BMAD/OpenSpec) com arquivamento por movimento

**Resumo.** Promove os marcadores de carga a topologia física: GRAFO.md vira
índice mestre permanente (Propósito + Constituição + 1 linha rica por nó com
link relativo) e o corpo de cada nó vira docs/audora/nos/<id>.md com
frontmatter YAML grep-ável (id, estado, depende-de, arquivos, keywords,
resumo). A unidade física de leitura passa a coincidir com a unidade lógica de
carga — carregar 1 nó custa 1 Read exato por construção. Arquivar = `git mv`
para docs/audora/arquivo/AAAA-MM-DD-<id>.md + troca de 1 linha no índice
(padrão OpenSpec: diff é pura movimentação, contexto integral preservado). É a
arquitetura para a qual TODO o prior art converge: nenhum dos 5 frameworks
spec-driven pesquisados guarda requisitos num arquivo único.

**Mudanças no grafo:**

- GRAFO.md raiz reduzido a: `versao-schema: 2`, Propósito, Constituição, e
  Índice de nós com linha rica + link relativo `nos/<id>.md` — teto duro de
  linhas vale só para o índice (o limite ~300 deixa de forçar compactação de
  conteúdo)
- docs/audora/nos/<id>.md por nó: frontmatter YAML ("1 campo = 1 linha" →
  `grep -l '^estado: em-curso' nos/*.md` responde consultas sem carregar nada)
  + corpo em prosa (objetivo, critérios EARS intocados, decisões, delta
  append-only)
- Ligação nó↔código de primeira classe: `arquivos:` no frontmatter habilita
  consulta reversa (`grep -l 'src/auth' nos/` = 1 op) e carga condicional
  "demanda toca src/auth/** → carregar o nó" (modo fileMatch do Kiro steering);
  opcionalmente gerar .claude/rules/grafo-<area>.md com `paths:` na compactação
  — nós entram sozinhos no contexto ao tocar o código
- GRAFO-ARQUIVO.md substituído por docs/audora/arquivo/ com mv por nó; decisões
  vivas de nó entregue são promovidas (Constituição ou decisoes-vivas.md
  grep-ável) ANTES do movimento — mata a memória de mão única
- Operações da skill preservadas com mesmo nome, substrato novo:
  carregar-contexto = índice + Read dos arquivos tocados; registrar-no =
  arquivo novo + linha no índice; registrar-delta = append no arquivo do nó
  (zero contato com região compartilhada); compactar = promoção de decisões +
  git mv
- Hooks do Candidato B operando sobre a pasta: validate (ids do índice ==
  arquivos da pasta; deps existem; sem ciclo) mata o risco clássico de
  dessincronização do híbrido
- depende-de reserva a sintaxe `chave:id` para futura federação por pacote
  (monorepo) — não implementada no v2, só não bloqueada

**Prós:**

- Ataca a causa, não o sintoma, dos 3 maiores gargalos: custo de carga cai de
  O(GRAFO inteiro) para O(índice)+O(nós tocados) (corte estimado 65-70% na
  demanda média); conflito de merge entre branches com nós disjuntos
  DESAPARECE (adições de arquivos distintos, git resolve sozinho); compactação
  por movimento elimina a reescrita frágil do GRAFO-ARQUIVO.md
- Argumento técnico decisivo da Anthropic: "contextos mutuamente exclusivos →
  arquivos separados" — duas demandas raramente tocam os mesmos nós
- Diff e blame por nó: o histórico git do arquivo do nó VIRA a trilha de
  auditoria da demanda
- Frontmatter YAML dá busca estruturada por grep puro nos dois sentidos
  (estado, deps, arquivos) sem nenhum parser
- Deixa de existir teto prático de crescimento: nó grande não pressiona nós
  vizinhos nem o índice
- Escala para monorepo/federação (GRAFO raiz + sub-GRAFOs por pacote) sem novo
  redesenho

**Contras:**

- Maior esforço: template novo, reescrita das instruções de leitura/escrita da
  skill grafo + ajustes em escopo/plano/validar (que citam "GRAFO.md na raiz"),
  script de migração, e período de suporte dual v1/v2 nas skills
- Visão global custa N Reads: demanda ampla ("o que o produto entrega na área
  X?") regride vs arquivo único — mitigável com resumos de grupo no índice
  (padrão GraphRAG), mas é custo real (~20% de regressão tolerada no critério
  do corpus)
- Risco de dessincronização índice↔pasta é a fraqueza única do híbrido — exige
  o hook de verificação (ou disciplina de skill) como parte do pacote, não como
  opcional
- Sync pós-merge continua tocando vários arquivos (índice + nó + PRD), embora
  cada toque fique menor
- Para projeto pequeno (GRAFO < ~150 linhas) o overhead de N arquivos +
  indireção não compensa — precisa do modo dual permanente

**Esforço:** alto

**Migração do schema v1.** Duas rotas, ambas sem big-bang, com detecção por
`versao-schema` na linha 1: (a) MECÂNICA — 1 script bash (~30 linhas) fatia o
GRAFO.md por `^### `, promove campos ao frontmatter, gera nos/<id>.md,
reescreve GRAFO.md como índice, mantém GRAFO-ARQUIVO.md intocado; diff
revisável pelo humano num commit único. (b) GRADUAL (recomendada para
brownfield) — fallback de duas camadas do BMAD: skills tentam formato novo
(pasta existe?) e caem para o monolito v1; nó novo nasce em arquivo, nó velho
migra quando tocado (a operação compactar já move corpo de nó entre arquivos —
é a mesma mecânica). Nós entregues/arquivados NÃO precisam mover. Projeto
pequeno pode legitimamente nunca migrar: v1 vira o caso degenerado válido do
v2, com gatilho objetivo de migração (índice >~300 linhas ou 2+ demandas
paralelas). Regra dura importada do BMAD: todo caminho relativo ao arquivo que
o contém, nunca absoluto.

### Candidato D (complementar) — Federação por pacote para monorepo: GRAFO raiz-registro + sub-GRAFOs por pacote

**Resumo.** Extensão ortogonal aos candidatos A-C para o eixo "muitos produtos
no mesmo repo": GRAFO raiz mantém Propósito + Constituição globais + seção nova
`Pacotes [carga: sempre]` (1 linha por sub-GRAFO: chave | caminho relativo |
descrição); cada pacote tem seu GRAFO com cabeçalho `pacote:` + `grafo-raiz:` e
índice/nós locais. Descoberta em duas pernas que se conferem (padrão CLAUDE.md
+ llms.txt): ancestral mais próximo das pastas tocadas como heurística,
registro do raiz como autoridade. Referência cross-pacote `chave:no-id` em
depende-de. O custo por demanda passa a escalar com o pacote tocado, não com o
repo.

**Mudanças no grafo:**

- Seção opcional `## Pacotes [carga: sempre]` no GRAFO raiz; presença da seção
  ativa o modo monorepo (detecção de modo estilo OpenSpec #662
  auto|flat|hierarchical)
- Cabeçalho de sub-GRAFO: `pacote: <chave>` + `grafo-raiz: <caminho relativo>`;
  `## Constituição-local` opcional e ADITIVA (contradição com a global → parar
  e perguntar)
- depende-de aceita `chave:id` cross-pacote (`:` livre — ids v1 são kebab-case
  puro; padrão já praticado em plugin:skill do Claude Code)
- Operação nova `extrair-pacote` na skill grafo (incremental, um pacote por
  vez); compactação e limite de ~300 linhas passam a valer POR ARQUIVO, cada
  sub-GRAFO com seu arquivo morto relativo
- Regra de máx. 3 em-curso contada GLOBALMENTE somando sub-GRAFOs (o registro
  torna a soma barata)
- Hook opcional de conferência: `git ls-files -- '*GRAFO.md'` vs registro;
  sub-GRAFO fora do registro = red flag, nunca erro silencioso

**Prós:**

- Resolve o trade-off nomeado pelo mantenedor do OpenSpec (instância única
  encarece traversal; instâncias soltas quebram cross-app) com registro central
  + namespace de primeira classe
- Diffs e conflitos confinados ao pacote da demanda; dono local por pacote
- v1 é o caso degenerado do v2 federado (mono-produto = sem seção Pacotes) —
  adoção reversível
- Compõe com qualquer um dos candidatos A-C dentro de cada pacote

**Contras:**

- Irrelevante para a maioria dos projetos-alvo atuais (mono-produto) —
  complexidade especulativa se entrar já no v2
- Cross-pacote real (demanda que atravessa fronteiras) continua mais caro e
  mais sujeito a erro de resolução
- Mais superfície nas skills: passo 0 de descoberta, validação de chave,
  resolução chave:id em plano/validar

**Esforço:** médio

**Migração do schema v1.** Passo 1: arquivo v1 já é v2 válido em modo
mono-produto (nenhum campo removido/renomeado) — só o bump de versao-schema.
Passo 2 (só quando doer): extrair-pacote sob demanda; nós não movidos
permanecem válidos no raiz; bootstrap lazy de sub-GRAFO na primeira demanda que
tocar pacote novo (espelha o "GRAFO parcial desde o dia 1"). Recomendo escopar
como v2.1/v3 — reservar apenas a sintaxe `chave:id` e a proibição de caminho
absoluto no schema v2 para não fechar a porta.

## Recomendação

Recomendo o Candidato C (v2-híbrido: índice mestre + 1 nó = 1 arquivo) como
alvo arquitetural do GRAFO v2, sequenciado em três passos que reutilizam os
candidatos A e B como etapas, não como alternativas descartadas.

Passo 1 (imediato, custo baixo): aplicar o núcleo aditivo comum a todas as
rotas — âncora contratual `### <id>`, campo `arquivos:` preenchido via git diff
no sync (pré-requisito de qualquer variante: sem ele a consulta reversa
arquivo→nó é insolúvel em qualquer estrutura), campos
`invalidado-em`/`substituido-por`, índice enriquecido estilo llms.txt, e os
hooks grafo-guard + grafo-validate-deps (o Claude Code prova que limite de
memória só funciona quando a ferramenta devolve erro).

Passo 2: rodar o braço determinístico do benchmark do corpus (corpus sintético
a ~300 linhas, regime pós-compactação — medir no GRAFO real de hoje com 126
linhas daria falso negativo).

Passo 3: se o corte na demanda média confirmar ≥50% (a estimativa mecânica
aponta 65-70%), executar a migração gradual ao split com fallback de duas
camadas do BMAD; se ficar abaixo, o Passo 1 já entregou o v1.5 (~60% do ganho
por ~5% do custo) e o split fica adiado com gatilho objetivo (índice >~300
linhas ou 2+ demandas paralelas).

Justificativa da escolha do C como alvo: é o único candidato que ataca a CAUSA
dos três gargalos estruturais simultaneamente — custo de leitura passa a
escalar com a relevância e não com o tamanho total (a leitura de 1 nó vira 1
Read exato por construção), o conflito de merge espúrio no índice compartilhado
desaparece (benefício qualitativo binário que a métrica de tokens não vê), e o
arquivamento por `git mv` elimina a reescrita frágil do GRAFO-ARQUIVO.md ao
mesmo tempo que a promoção de decisões vivas corrige a memória de mão única. É
também a arquitetura para a qual todo o prior art converge (Kiro, Spec Kit,
OpenSpec, BMAD sharded, Agent Skills da Anthropic: nenhum sistema maduro guarda
requisitos num arquivo único; todos usam unidade-por-arquivo + agregador), e a
deprecação do sharding no BMAD v6 não se aplica aqui porque assume runtime com
subprocessos que um plugin só-de-skills não tem.

O Candidato D (federação) fica fora do escopo v2: reservar apenas a sintaxe
`chave:id` e a regra de caminhos relativos.

Os pontos fortes inegociáveis ficam preservados por construção em todos os
passos: semântica das 3 camadas de carga (promovida de anotação a topologia),
critérios EARS intocados como fio escopo→TDD→e2e→gate 1:1, delta append-only
com consolidação exclusiva no sync pós-merge (fica ainda mais barato no split:
append no próprio arquivo do nó), direção única GRAFO→PRD estendida a toda
camada derivada (TSV, decisoes-vivas, rules geradas — tudo flui do nó para
fora, no sync), schema versionado com validação pré-escrita (é o que torna a
própria migração barata), origem humano/inferido e as 5 operações da skill
grafo com assinaturas idênticas (a API que as outras 7 skills consomem).

## Questões abertas para o escopo

1. Limiar do portão de decisão: o critério "corte >=50% de tokens de travessia
   na demanda média, sem >2x edits de escrita" está adequado, ou o humano quer
   outro limiar/outra demanda de referência? E qual o MODELO_ALVO do benchmark
   (o tokenizer novo de Opus 4.7+/Fable conta ~30% mais tokens — contagens não
   são transferíveis entre tokenizers)?
2. Migração mecânica (1 script, 1 commit, diff revisável) vs gradual (nó novo
   nasce em arquivo, nó velho migra quando tocado, suporte dual v1/v2 nas
   skills): a dual custa linhas de skill (limite de 250 por SKILL.md) por tempo
   indeterminado — quanto tempo de suporte dual é aceitável, e projeto pequeno
   pode ficar no v1 para sempre?
3. Hooks bash: entram como parte integrante do v2 (validate índice↔pasta vira
   quase obrigatório no híbrido) ou permanecem estritamente opcionais com as
   skills como única fonte normativa? Definir o contrato de degradação: máquina
   sem Git Bash perde a rede de segurança silenciosamente — isso é aceitável ou
   precisa de aviso?
4. Destino das decisões vivas de nós entregues: promover para a Constituição
   (arquivo que já é [carga: sempre] — risco de inchar o teto), para um
   decisoes-vivas.md grep-ável novo [carga: auto], ou para o campo do nó
   sucessor? Quem decide o que é "vivo" vs "histórico" no momento da
   compactação — LLM autônomo ou humano no portão?
5. Índice mestre no híbrido: editado à mão pelo LLM na mesma edição do nó
   (regra atual, verificável por hook) ou derivado/regenerado por script a
   partir dos frontmatters (mata o drift na raiz, mas torna o bash obrigatório
   e o índice deixa de ser operável por instrução pura)?
6. Caminhos e nomes canônicos do v2: docs/audora/nos/<id>.md e
   docs/audora/arquivo/AAAA-MM-DD-<id>.md estão bons? Prefixo numérico NNN- nos
   ids (ordenação estável estilo Spec Kit) entra ou fica de fora? Numeração
   hierárquica dos critérios EARS (1.1, 1.2 — endereços citáveis em
   teste/commit, padrão Kiro "_Requirements: 1.1_") entra no v2?
7. Geração de .claude/rules/grafo-<area>.md com `paths:` (nós entram sozinhos
   no contexto ao tocar o código) — incluir no v2 ou adiar? É poderoso mas cria
   artefato derivado a mais para manter em sincronia na compactação.
8. Regra dos 3 em-curso e teto de linhas no mundo multi-arquivo: o limite de 3
   continua global (contado via índice) e o teto de ~300 linhas passa a valer
   só para o índice mestre — confirmar, e definir se nó individual ganha limite
   próprio (ex.: ~80 linhas por arquivo de nó antes de exigir split de
   histórico frio para <id>-historico.md)?
9. Monorepo/federação (Candidato D): fica formalmente fora do v2 com apenas a
   sintaxe `chave:id` reservada, ou há projeto real no horizonte que justifique
   incluir a seção Pacotes já no template v2?
10. Escopo do benchmark: rodar só o braço determinístico (meio dia de agente)
    antes de decidir, ou incluir também o braço LLM (3 réplicas headless por
    célula, mede recall de seleção de nós) antes do portão humano?

## Principais achados por ângulo

### Ângulo 1 — repo-maps (como ferramentas de código mapeiam repositórios)

Key insights:

- Convergência da indústria: Cody, Claude Code e Cursor (parcial) abandonaram
  ou rebaixaram embeddings/vector DB em favor de busca estruturada sob demanda
  (keyword/grep + raciocínio do agente) — o estado da arte não exige
  infraestrutura, exige texto grepável com âncoras estáveis e carga progressiva
- Padrão universal de dois níveis: esqueleto barato sempre em contexto +
  expansão sob demanda por identificador; o ganho do GRAFO está em endurecer o
  protocolo (teto de linhas, budget numérico, ordem de corte)
- Endereçamento por âncora, nunca por linha: números de linha morrem a cada
  edit; formalizar `### <id>` como âncora contratual é o maior ganho imediato
  de tokens sem mudar o schema
- A ligação nó↔código tem dois modelos prontos: campo `arquivos:` (globs,
  estilo Cursor Rules) e/ou índice derivado por hook (estilo ctags) — ambos
  aditivos ao schema v1
- Ranking não precisa de PageRank: menção na demanda + 1 salto de depende-de +
  hit de grep replicam os sinais do aider por instrução de skill
- Custo de manutenção de índice é o critério decisivo: nada que dessincroniza
  pode virar fonte de verdade
- Memória fora do git perde: Memories não-versionadas do Cursor morreram;
  rules versionadas e memórias Markdown commitáveis prosperaram

Findings principais:

- **Aider repo map**: tree-sitter + PageRank personalizado (arquivos no chat
  pesam ~50x, menções ~10x) e busca binária para encher um budget fixo de
  tokens. Lição: rankear a expansão e declarar budget numérico de carga.
- **Sourcegraph Cody**: abandonou embeddings; keyword search + BM25 rankeado
  bastou para um produto comercial — pipeline retrieval→ranking→corte sem
  vetores.
- **Serena MCP**: opera por símbolo (LSP) com leitura progressiva e memórias
  Markdown ("listar nomes primeiro, ler sob demanda") — o modelo mais próximo
  do GRAFO em espírito.
- **Claude Code**: zero índice; busca agêntica (Glob/Grep/Read) venceu RAG com
  folga; CLAUDE.md é carga ingênua total — tudo [carga: sempre] precisa de teto
  duro.
- **ctags**: índice texto derivado, ordenado, regenerável por comando batch;
  tagaddress como padrão de busca (não linha fixa) — o modelo de inventário
  compatível com as restrições do plugin.

### Ângulo 2 — agent-memory (sistemas de memória de agentes)

Key insights:

- Os seis sistemas convergem no mesmo esqueleto: camada pequena sempre-em-
  contexto com LIMITE DURO + camada grande sob demanda + consolidação fora do
  caminho quente — o gap do GRAFO não é arquitetura, é enforcement e
  granularidade de carga
- Maior alavanca de custo (GraphRAG): resumo pré-computado NA ESCRITA; índice
  em 2 níveis (resumo de grupo + 1 linha/nó) responde pergunta ampla com ~10
  linhas
- Invalidação bi-temporal do Zep é o único modelo de obsolescência
  git-friendly: nunca deletar, marcar `invalidado-em` + `substituido-por`
- O loop ADD/UPDATE/DELETE/NOOP do mem0 é 100% portável para instrução de skill
  — antídoto contra o append infinito de duplicatas/contradições
- Sem banco vetorial, busca estruturada = convenção rígida + grep (1 campo = 1
  linha, âncoras previsíveis, BFS manual via depende-de)
- Ligação nó↔código quase grátis com infra nativa: campo de arquivos no nó +
  .claude/rules/grafo-<area>.md com `paths:` gerado na compactação
- Claude Code prova que limite de memória só funciona quando a FERRAMENTA
  devolve erro (200 linhas do MEMORY.md) — impor compactação por hook, não por
  instrução
- Para a futura skill MEMORY: separar PROFILE (preferências, sobrescrito
  in-place) de COLLECTION (aprendizados atômicos datados), padrão LangMem;
  aprendizado repetido é promovido a regra com aprovação humana

Findings principais:

- **Letta/MemGPT**: hierarquia estilo SO (core/recall/archival), blocos com
  limite de caracteres, paginação explícita e warning de pressão de memória —
  o GRAFO já é um MemGPT sem saber; falta formalizar budget e limites por nó.
- **Zep/Graphiti**: grafo bi-temporal; contradição seta invalid_at em vez de
  deletar — transplante direto para `invalidado-em`/`substituido-por` com diff
  de 1-2 linhas.
- **Microsoft GraphRAG**: resumos de comunidade gerados na indexação, não na
  consulta — pagar token na escrita; grupos de nós com resumo de 2-3 linhas no
  índice replicam o global search em Markdown.
- **mem0**: loop ADD/UPDATE/DELETE/NOOP com dedup antes de gravar; fatos
  atômicos de 1 linha (unidade de dedup/diff/grep) — mecanismo central da
  futura skill MEMORY.
- **Claude Code (CLAUDE.md + MEMORY.md)**: o único 100% compatível com as
  restrições; enforcement duro por erro de ferramenta, rules path-scoped e
  frontmatter type/modified são as três peças roubáveis.

### Ângulo 3 — spec-driven (frameworks de desenvolvimento guiado por spec)

Key insights:

- Convergência forte dos 5 frameworks: nenhum guarda requisitos num arquivo
  único; todos usam pasta-por-feature ou arquivo-por-unidade + agregador — o
  GRAFO monolítico é a exceção do ecossistema
- Arquitetura recomendada: híbrido índice+pasta estilo BMAD sharded (GRAFO.md
  índice permanente + docs/audora/nos/{id}.md por nó)
- Carga seletiva deve ser declarativa e viver no próprio nó (front matter
  estilo Kiro steering); o modo fileMatch com glob dá de graça a ligação
  nó↔código
- Rastreabilidade com dois mecanismos de texto puro: a priori
  "_Requisitos: no-x/1.2_" (padrão Kiro, exige EARS numerado) e a posteriori
  campo `arquivos:` via `git diff --name-only` (padrão File List do BMAD:
  derivar do diff real, nunca da memória do LLM)
- Arquivamento por movimento, não por reescrita (padrão OpenSpec): `git mv` +
  troca de 1 linha no índice; delta formalizado como ADDED/MODIFIED/REMOVED
- Busca estruturada sem banco é viável: ids estáveis + front matter + grep;
  operações do Taskmaster (next, validate-dependencies) viram instrução de
  skill + hook
- Migração sem big-bang copiada do fallback de duas camadas do BMAD; projeto
  pequeno pode nunca sair do arquivo único
- Alerta honesto: o BMAD v6 depreciou sharding porque ganhou runtime com
  subprocessos — a deprecação NÃO se aplica a um plugin só de skills

Findings principais:

- **GitHub Spec Kit**: pasta numerada NNN- por feature, constituição com
  princípios não-negociáveis, marcador [NEEDS CLARIFICATION] e passo `analyze`
  de consistência cross-artefato.
- **AWS Kiro (specs)**: análogo mais direto do GRAFO (EARS + markdown puro);
  fragmenta por feature e amarra tarefa→requisito por string grep-ável
  "_Requirements: 1.1_".
- **AWS Kiro (steering)**: front matter `inclusion: always|fileMatch|manual`
  controla a carga de dentro do próprio arquivo — upgrade direto do marcador
  [carga: sempre].
- **BMAD sharding**: documento grande vira pasta com index.md navegador e
  fallback de duas camadas (formato novo → monolito) — o blueprint exato do
  híbrido e da migração.
- **OpenSpec**: specs/ (estado atual) vs changes/ (mudança em voo com delta
  specs); arquivar funde deltas e move a pasta com data — resolve a compactação
  de forma mais limpa que reescrita.

### Ângulo 4 — grafo-atual (anatomia e gargalos do GRAFO v1)

Key insights:

- A carga seletiva do GRAFO é política, não mecanismo: todo carregar-contexto
  paga o arquivo inteiro; o custo escala com o tamanho total, não com a
  relevância
- O passo mais crítico da travessia (matching demanda→nós) é o menos assistido:
  julgamento semântico sobre títulos curtos, e o erro viola a Lei de Ferro em
  silêncio
- O GRAFO é grafo só no nome: 1 tipo de nó, 1 aresta sem tipos, sem travessia
  reversa, sem integridade referencial
- O índice compartilhado no arquivo único converte concorrência normal em
  conflito de merge obrigatório com interrupção humana
- A compactação tem dois defeitos: gatilho por linhas sem ação válida quando o
  excesso vem de nós ativos, e arquivo morto de mão única (decisões vivas de
  nós entregues somem do alcance)
- Custo real da demanda MÉDIA: ~10-25k tokens de travessia (5-7 leituras
  integrais + template cross-repo + sync em 3-4 arquivos), sem amortização por
  causa do /clear entre fases
- Paredes-mestras que não podem cair: 3 camadas de carga, EARS como fio
  escopo→TDD→e2e→gate, delta append-only, direção única GRAFO→PRD, schema
  versionado com validação pré-escrita
- Direção estrutural compatível com as restrições: promover marcador a
  topologia (1 nó = 1 arquivo, frontmatter grep-ável, índice derivado, camada
  de decisões vivas)

Findings principais:

- **Custo da demanda MÉDIA**: passo a passo mostra 5-7 leituras integrais do
  GRAFO + leitura do template no repo do plugin a cada registrar-no; total
  10-25k tokens crescendo linearmente com o GRAFO.
- **Índice sem endereçamento**: carrega só id/estado/título — não diz ONDE o nó
  está nem dá metadados de matching; falso negativo de carga é silencioso.
- **Sem ligação nó↔código**: nenhum campo de arquivos; a ponte GRAFO→código é
  reconstruída do zero pela skill plano a cada demanda e depois descartada.
- **Contenção do arquivo único**: duas branches com nós disjuntos colidem nas
  linhas do índice; sync final é transação em 3-4 arquivos sem atomicidade.
- **Compactação/arquivo morto**: decisões duráveis de nós entregues (ex.:
  "sessão via cookie httpOnly") ficam invisíveis para demandas futuras — a Lei
  de Ferro inverte: o requisito está escrito mas funcionalmente não existe.

### Ângulo 5 — travessia-md (travessia eficiente de Markdown em texto puro)

Key insights:

- Todos os sistemas convergem em duas/três camadas: índice pequeno sempre
  carregado + corpo atrás de ponteiro (llms.txt, Agent Skills, MOC, repo map);
  o ganho está em enriquecer a linha de índice e criar a terceira camada
  (histórico frio fora do nó ativo)
- ID estável como âncora sustenta tudo (Zettelkasten, Sphinx): heading = id já
  dá âncora estável e grep O(1); deve virar invariante explícito do schema
- Grep é o banco de dados viável dentro das restrições: "1 campo = 1 linha com
  prefixo fixo" torna tudo consultável por bash puro; backlinks são computados
  sob demanda (estilo Foam), zero manutenção
- A ligação nó↔código tem solução bash de custo zero manual: `git diff
  --name-only` no sync preenche `arquivos:` no nó
- O critério da Anthropic "contextos mutuamente exclusivos → arquivos
  separados" é o argumento técnico decisivo para o split 1 nó = 1 arquivo
- Ferramentas opcionais devem ser regeneráveis, nunca fonte de verdade; o fluxo
  tem de continuar funcionando sem o hook

Findings principais:

- **Zettelkasten**: ID fixo como endereço permanente; links apontam para o id,
  nunca para o título — pré-requisito de qualquer split sem links quebrados.
- **Foam**: backlinks por varredura de texto, sem banco — "quem depende de X" =
  grep sob demanda com custo de manutenção zero.
- **Obsidian Properties**: o invariante "1 campo = 1 linha" habilita consulta
  por ferramenta burra (`grep -l '^estado: em-curso' nos/*.md`).
- **llms.txt**: índice mínimo cujas linhas carregam título + nota para decidir
  relevância SEM abrir o alvo — receita direta para a linha de índice rica.
- **Agent Skills (Anthropic)**: progressive disclosure em 3 níveis; o GRAFO tem
  os níveis 1-2 mas não o 3 (histórico frio) — e o critério "mutuamente
  exclusivos → arquivos separados" fundamenta o split.

### Lacuna 1 (crítica) — Monorepo e federação por pacote

Key insights:

- Todos os sistemas maduros usam o mesmo par: descoberta por proximidade de
  diretório (mais específico vence, merge aditivo) + índice pequeno sempre
  carregado apontando conteúdo sob demanda — o v2 só precisa compor os dois
- O trade-off do monorepo tem nome (mantenedor do OpenSpec): instância única
  encarece o traversal; instâncias soltas quebram o cross-app — saída é
  sharding por pacote + referência `chave:no-id` resolvida por registro central
- Prefixo de escopo em arquivo único (OpenSpec flat) NÃO resolve a dor: o
  índice [carga: sempre] continuaria crescendo com o repo inteiro
- Namespace com dois-pontos é aditivo e sem ambiguidade (ids v1 são kebab-case
  puro; padrão plugin:skill já existe no ecossistema)
- Descoberta robusta em duas pernas: ancestral mais próximo (heurística) +
  registro do raiz (autoridade); sub-GRAFO fora do registro = red flag
- Migração 100% aditiva: arquivo v1 é v2 válido em modo mono-produto; extração
  de pacote incremental com bootstrap lazy
- Anti-lição do BMAD que vira regra dura: nunca caminho absoluto em artefato
  Markdown — todo caminho relativo ao arquivo que o contém

Findings principais:

- **CLAUDE.md hierárquico**: ancestral carrega sempre, subdiretório carrega
  on-demand; raiz fina + arquivo por pacote — o precedente mais forte para a
  regra de descoberta.
- **Kiro multi-root**: armazenamento descentralizado por pacote + lista
  agregada com rótulo de origem — o que o registro Pacotes do raiz reproduz em
  Markdown puro.
- **OpenSpec flat + issue #662**: prefixo de escopo funciona mas é plano B; a
  detecção auto|flat|hierarchical é o modelo do modo dual do v2.
- **Recomendação (opção C, federação)**: GRAFO raiz com registro `Pacotes
  [carga: sempre]` + sub-GRAFOs com `pacote:`/`grafo-raiz:`; custo por demanda
  escala com o pacote tocado, não com o repo.

### Lacuna 2 (crítica) — Mecânica real dos hooks do Claude Code

Key insights:

- PostToolUse não bloqueia (a ferramenta já rodou), mas exit 2 + stderr injeta
  a mensagem no contexto do modelo no mesmo turno — exatamente o mecanismo do
  padrão "MEMORY.md passou de 200 linhas", o canal certo para aviso de
  compactação e erro de dependência
- Matcher só casa nome de ferramenta; filtragem por arquivo é papel do campo
  `if` (`Edit(GRAFO.md)`, `Bash(git merge *)`), avaliado in-process antes do
  spawn — resolve de graça o custo de rodar em todo Edit
- jq NÃO existe no Git for Windows; perl 5.38 com JSON::PP existe garantido —
  parser/encoder JSON real sem vendorizar nada
- CRLF: a âncora `^### ` nunca é afetada; o risco é campo final com `\r`
  invisível — mitigação de custo zero (`tr -d '\r'`) + .gitattributes
  obrigatório no repo (`hooks/* eol=lf`, `*.cmd eol=crlf`)
- O wrapper hooks/run-hook.cmd existente cobre 100% da necessidade e já
  implementa a degradação graciosa (sem bash → exit 0 silencioso)
- Hooks de feedback precisam ser síncronos; só o inventário (sem saída ao
  modelo) deve ser async; tudo que chega ao modelo trunca em 10.000 chars
- O inventário id→linha/arquivo/estado deve ser artefato DERIVADO (TSV com
  header "NÃO EDITAR", tmp+mv atômico), nunca fonte de verdade

Findings principais:

- **Tabela evento→contrato**: PreToolUse (bloqueia), PostToolUse (feedback
  pós-escrita visível ao modelo), SessionStart (contexto inicial), Stop (rede
  de segurança por turno) — PostToolUse em Edit|Write é o evento certo para o
  GRAFO.
- **Portabilidade Windows**: regra de ouro — perl+JSON::PP para o JSON do
  stdin/stdout, awk/sed/grep só para o texto do GRAFO.md; sem jq, python ou
  node como dependência.
- **4 protótipos prontos**: grafo-guard (contagem de linhas + exit 2),
  grafo-validate-deps (dep inexistente + ciclo via awk DFS), grafo-inventario
  (TSV regenerável, async) e grafo-sync-arquivos (git diff → additionalContext
  no sync), mais o bloco hooks.json consolidado.
- **Limites operacionais**: timeout por handler (15-30s), spawn cmd→bash
  ~100-300ms só quando o GRAFO é tocado, contrato de falha: hook que falha
  nunca quebra o fluxo — as skills seguem sendo a fonte normativa.

### Lacuna 3 (crítica) — Benchmark de validação do ganho de tokens

Key insights:

- Medir com o endpoint count_tokens da Anthropic (gratuito) no MODELO_ALVO: o
  tokenizer de Opus 4.7+/Fable conta ~30% mais tokens; wc/tiktoken só como
  proxy relativo calibrado — o critério usa delta %, nunca valor absoluto
- Prompt caching é ameaça à validade em dobro: não reduz ocupação da janela e
  re-cobra tokens a cada turno — a métrica cache-aware certa é token-turns
- Dois braços matam a maior ameaça: braço determinístico (scripts executam a
  política de acesso exata) compara ESTRUTURAS; braço LLM (3 réplicas headless)
  mede só variância de seleção e recall contra gabarito
- Descoberta de desenho que pode adiar a migração: o inventário de offsets
  persistido é desnecessário e frágil — `grep -n '^### <id>'` resolve o offset
  em tempo de leitura, criando o v1.5 (índice rico + Read por âncora)
- O benchmark precisa rodar no regime pós-compactação (~300 linhas, ~30 nós):
  no GRAFO real de hoje (126 linhas) o resultado seria falso negativo
- A consulta reversa arquivo→nó é insolúvel em QUALQUER variante sem o campo
  `arquivos:` — pré-requisito da migração, não consequência
- 1 nó = 1 arquivo tem benefício invisível à métrica: elimina a classe de
  conflito de merge entre branches — registrar como critério qualitativo
  binário
- Recomendação: braço determinístico primeiro (meio dia de agente); corte ≥50%
  na demanda MÉDIA → prototipar v2-híbrido; <50% → aplicar v1.5

Findings principais:

- **Harness de medição**: count_tokens com o mesmo payload do Messages; modo
  offline calibra fator bytes/token com 3 amostras; overhead fixo por tool call
  (~25-40 tokens/op) somado como constante.
- **Corpus sintético calibrado**: gerador determinístico (seed=42) produz 30
  nós no regime pós-compactação (~300-330 linhas) + 6 demandas com gabarito
  (LEVE, 2 MÉDIAS, ALTA, reversa, ampla).
- **Critério de decisão**: vence quem corta ≥50% na mediana da D2 MÉDIA sem
  >2x edits de escrita nem >1,5x tokens reescritos; desempates: D5 em ≤2 ops,
  D6 não regride >20%, D4 corta ≥40%, migração em 1 script, recall ≥ v1.
- **Magnitudes esperadas (D2, corpus 300 linhas)**: v1 ~5,5-6,5k tokens; v1.5
  ~1,8-2,3k (corte ~62-68%); v2-split/híbrido ~1,6-2,1k (corte ~65-70%); na D6
  ampla o v1 empata ou vence.
- **Prior art convergente**: Agent Skills (progressive disclosure), aider
  (índice 100% derivado com orçamento), OpenSpec (pasta por mudança) — e o
  Cline Memory Bank (ler 6 arquivos inteiros por tarefa) como anti-padrão do
  que o v1 vira sem disciplina.

## Fontes principais

### repo-maps

- https://aider.chat/2023/10/22/repomap.html
- https://aider.chat/docs/repomap.html
- https://sourcegraph.com/blog/how-cody-understands-your-codebase
- https://github.com/oraios/serena
- https://cursor.com/docs/context/rules
- https://cursor.com/blog/secure-codebase-indexing
- https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- https://www.anthropic.com/engineering/claude-code-best-practices
- https://docs.ctags.io/en/latest/man/tags.5.html

### agent-memory

- https://www.letta.com/blog/agent-memory/
- https://arxiv.org/abs/2310.08560 (MemGPT)
- https://arxiv.org/pdf/2501.13956 (Zep)
- https://github.com/getzep/graphiti
- https://microsoft.github.io/graphrag/
- https://arxiv.org/abs/2504.19413 (mem0)
- https://langchain-blog.ghost.io/langmem-sdk-launch/
- https://code.claude.com/docs/en/memory

### spec-driven

- https://github.com/github/spec-kit/blob/main/spec-driven.md
- https://kiro.dev/docs/specs/
- https://kiro.dev/docs/steering/
- https://bmad-code-org-bmad-method-6.mintlify.app/advanced/shard-documents
- https://github.com/bmad-code-org/BMAD-METHOD/issues/1789
- https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md
- https://github.com/eyaltoledano/claude-task-master/blob/main/docs/task-structure.md

### grafo-atual

Fontes locais do repositório (não URLs): templates/GRAFO-template.md,
GRAFO.md, skills/grafo/SKILL.md, skills/validar/SKILL.md,
docs/audora/GRAFO-ARQUIVO.md, docs/fundamentos.md,
docs/specs/2026-08-14-audora-commander-design.md.

### travessia-md

- https://zettelkasten.de/introduction/
- https://github.com/foambubble/foam
- https://obsidian.md/help/properties
- https://llmstxt.org/
- https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- https://docs.readthedocs.com/platform/latest/guides/cross-referencing-with-sphinx.html

### Lacunas (monorepo, hooks, benchmark)

- https://code.claude.com/docs/en/large-codebases
- https://kiro.dev/docs/ide/editor/multi-root-workspaces/
- https://github.com/Fission-AI/OpenSpec/issues/662
- https://code.claude.com/docs/en/hooks
- https://code.claude.com/docs/en/hooks-guide
- https://platform.claude.com/docs/en/build-with-claude/token-counting
- https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- https://docs.cline.bot/prompting/cline-memory-bank
- https://milvus.io/blog/why-im-against-claude-codes-grep-only-retrieval-it-just-burns-too-many-tokens.md
