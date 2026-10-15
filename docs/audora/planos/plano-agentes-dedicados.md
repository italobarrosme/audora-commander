# Plano — agentes-dedicados: Agentes dedicados

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** entregar o agente `revisor` do plugin (só Read, Grep, Glob,
Bash; modelo herdado; trava do shell na própria definição) e fazer a revisão
adversarial da validate e a caçada do debug despacharem ele pelo nome, com
fallback para genérico travado e aviso.

**Nó do MEMORY:** `agentes-dedicados` (MEMORY.md)

**Arquitetura da mudança:** arquivo novo `agents/revisor.md` na raiz do
plugin (pasta `agents/` é descoberta pelo Claude Code sem mexer no
`plugin.json`; agente de plugin é despachado como
`subagent_type: audora-commander:revisor`). As regras de despacho entram só
fora da carga BASE: `skills/validate/references/revisao-adversarial.md` e
`skills/debug/SKILL.md` — `skills/validate/SKILL.md` NÃO é tocado (teto de
6300 bytes e BASE pinada em `tests/test-parada-revisao.sh:53-59`). Uma frase
de trava única (`TRAVA`, abaixo) aparece igual no agente, na reference e no
debug, e uma suíte nova `tests/test-agentes-dedicados.sh` guarda tudo,
inclusive por mutação do agente.

**Arquivos lidos antes de planejar:**
- `MEMORY.md:1-48` — Propósito/Constituição: código executável só em `hooks/` e `tests/`; como-rodar `bash tests/run.sh`; gate `bash hooks/gate <id>`; e2e por `claude -p`.
- `MEMORY.md:49-108` — índice: `agentes-dedicados` in-progress; `review-avulsa` planned depende do `agents/revisor.md`.
- `docs/audora/memory/agentes-dedicados.md:1-94` — critérios /1–/11, fora-de-escopo, 5 decisões do humano.
- `skills/validate/references/revisao-adversarial.md:1-71` — `## Despacho` (6-15) é o ponto da troca; `## No roteiro` (57-65) tem a linha "revisão adversarial não rodou — <motivo>".
- `skills/validate/SKILL.md:20-35,60-75` — roteador só aponta a reference (item 3); não precisa mudar.
- `skills/debug/SKILL.md:1-20` — anúncio e modos.
- `skills/debug/SKILL.md:55-120` — `## Modo caçada` (60-91): classes (67-80), relatório e tabela (82-85), vereditos (87-91); red flags (93-102); bloco de fechamento (104-114).
- `tests/test-parada-revisao.sh:1-115` — frases pinadas da reference (`subagente de contexto limpo`, `Autor não revisa a si mesmo`, `executáveis falsos no PATH`, seção `## No roteiro`); teto 6300 bytes do roteador; BASE ≤ 56406; helper `flat()`.
- `tests/test-carga.sh:1-22` — BASE_LIST não contém `skills/debug/SKILL.md` nem a reference da revisão.
- `tests/test-plano-mapa.sh:50-60` — caçada tem de manter 'Varredura por classes de defeito'.
- `tests/lib.sh:1-21` — `ROOT`, `SP` (mktemp com trap), asserts, `report`.
- `tests/run.sh:1-10` — roda todo `tests/test-*.sh` pelo glob (arquivo novo entra sozinho).
- `tests/test-dogfood.sh:1-25` — só exige a linha do nó no índice.
- `tests/test-skills.sh:71` — conta 9 pastas em `skills/` (agents/ fora, não afeta).
- `tests/test-docs.sh:35-55` — não exige estrutura de `agents/`.
- `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` — sem campo `agents`; `source: "./"` leva a pasta inteira para o cache.
- `install.sh:1-40` — instala pelo marketplace local; nada a mudar.
- `README.md:240-292,359-378` e `README.pt-BR.md:241-286,358-375` — seções `validate` e `debug` e checklist de instalação (5 itens).
- `hooks/gate:1-20` — `gate [<id>]`, suíte via `bash tests/run.sh`.

**Conflitos MEMORY vs código encontrados:** nenhum.

**Constantes compartilhadas (fonte única para todas as tarefas):**

- `TRAVA` (frase exata, igual nos 3 arquivos; o teste compara depois de
  `flat`, então pode quebrar linha):
  `Trava do shell: não escreva, apague nem mova arquivo no repo; não cause efeito fora dele; script ou comando de efeito externo só roda com executáveis falsos no PATH, sem os reais.`
- `NOME` do despacho: `audora-commander:revisor`.
- Aviso de fallback na validate: `revisão adversarial por subagente genérico — read-only não garantido`.
- Aviso de fallback na caçada: `refutação por subagente genérico — read-only não garantido`.
- Linha de "nenhum rodou" na caçada: `refutação do revisor não rodou — <motivo>`.

## Notas de sessão

- Escopo e nó ainda não commitados no início do plano (working tree com
  `MEMORY.md`, `docs/audora/memory/agentes-dedicados.md` e
  `docs/audora/memory/review-avulsa.md` modificados/novos) — commitar junto
  com este plano antes da Tarefa 1: `git add MEMORY.md docs/audora/memory/agentes-dedicados.md docs/audora/memory/review-avulsa.md docs/audora/planos/plano-agentes-dedicados.md && git commit -m "docs(agentes-dedicados): escopo e plano"`.
- Prova de /1 em sessão real (o agente aparece listado) é do e2e: `claude.exe -p` com `--plugin-dir <repo> --output-format stream-json --verbose` e grep de `audora-commander:revisor` no `system/init` (aprendizado 2026-09-30, e2e de branch não mergeada). A suíte prova arquivo e frontmatter.
- Decisões tomadas pela IA:
  - nome de despacho `audora-commander:revisor` (agente de plugin vem com o prefixo do plugin, como `code-simplifier:code-simplifier` na listagem da sessão);
  - ferramentas por allowlist (`tools: Read, Grep, Glob, Bash`) — sem a linha `tools:` o agente herdaria tudo, então ausência reprova;
  - `model: inherit` explícito em vez de omitir;
  - prova por mutação permitida só em cópia fora do repo (`mktemp -d`);
  - vereditos do revisor: `sustentado`, `refutado`, `inconclusivo`; coluna nova `Revisor` na tabela da caçada;
  - docs EN/PT ganham a menção ao revisor e um item 6 no checklist de instalação.
  - (execute) gate único depois das 4 tarefas, não 1 por tarefa: o 1º gate (Tarefa 1) reprovou só porque o teste foi editado (RED da Tarefa 2) com ele rodando; cada tarefa teve red/green do próprio teste + teste de regressão do plano; gate final `SUITE_TIMEOUT=600` passou (0 falhas, 424 s). Os 4 commits são checkpoints com o teste fatiado até a seção da tarefa, cada um conferido isolado em worktree.
  - (execute) corpo do agente: parágrafo de papel (contexto limpo, não conserta nem alarga o pedido) e "comando que você não sabe se tem efeito externo não roda — leia o código dele".

---

## Tarefa 1: agente `revisor` + guarda da suíte

- **depende-de**: []
- **requisito**:
  - `agentes-dedicados/1` — QUANDO o plugin está instalado O SISTEMA DEVE listar um agente `revisor` entre os agentes do plugin, com descrição que diga que ele revisa e refuta sem alterar nada
  - `agentes-dedicados/2` — QUANDO o revisor é despachado O SISTEMA DEVE dar a ele só leitura de arquivo, busca e shell — nunca editar, escrever arquivo nem despachar outro agente
  - `agentes-dedicados/3` — QUANDO o revisor é despachado O SISTEMA DEVE carregar, na definição do próprio agente e sem depender do prompt de quem despacha, a trava do shell: proibido escrever no repo ou causar efeito fora dele, e script de efeito externo só roda com executáveis falsos no PATH
  - `agentes-dedicados/4` — QUANDO o revisor é despachado O SISTEMA DEVE rodá-lo no mesmo modelo da sessão principal
  - `agentes-dedicados/11` — QUANDO a suíte do plugin roda O SISTEMA DEVE reprovar se o `revisor` ganhar ferramenta de escrita, de edição ou de despacho de agente, ou perder a trava do shell
- **decisões relevantes**: shell com trava (humano 2026-10-15); modelo herdado (humano 2026-10-15); código executável só em `hooks/` e `tests/` — o agente é Markdown.
- **interfaces**: produz `agents/revisor.md` com frontmatter
  `name: revisor` · `description: '<texto abaixo>'` · `tools: Read, Grep, Glob, Bash` · `model: inherit`;
  corpo com `# revisor`, `## Trava do shell` (contém `TRAVA` + `Prova por mutação só numa cópia fora do repo (`mktemp -d`).`) e `## Resposta` (contém `Devolva, por item pedido, o veredito — `sustentado`, `refutado` ou `inconclusivo` — e a prova: comando rodado com a saída, ou `caminho:linha`.` e `Sem prova, o veredito é `inconclusivo`.`).
  Description exata: `Revisor do audora-commander: revisa e refuta sem alterar nada — ataca os critérios na revisão adversarial da validate e tenta refutar os achados da caçada do debug. Só lê, busca e roda comando sem efeito.`
  Produz também, em `tests/test-agentes-dedicados.sh`, a função `checar_revisor <arquivo>` que imprime 1 violação por linha (vazio = ok) e as variáveis `A=agents/revisor.md` e `TRAVA='<frase>'` — consumidas pelas Tarefas 2, 3 e 4.
- **ponto de mudança**: `agents/revisor.md` (novo, raiz do plugin); `tests/test-agentes-dedicados.sh` (novo; cabeçalho `# agentes-dedicados — agente revisor read-only e quem o despacha.`, `source "$(dirname "$0")/lib.sh"`, `cd "$ROOT"`, `flat()` copiado de `tests/test-parada-revisao.sh:8-14`, `report` no fim).
- **teste**: `tests/test-agentes-dedicados.sh` — casos `agentes-dedicados/1 …`, `/2 …`, `/3 …`, `/4 …`, `/11 …`
- **asserções**:
  - `checar_revisor` lê só o frontmatter (entre os dois `---`) para `tools:`/`model:` e o corpo `flat` para a trava; regras:
    sem linha `tools:` → `sem tools: (herda todas)`;
    cada item de `tools:` (separado por vírgula, espaços cortados, `Bash(...)` conta como `Bash`) fora de {Read, Grep, Glob, Bash} → `ferramenta proibida: <item>`;
    `model:` diferente de `inherit` (ou ausente) → `model não é inherit`;
    `TRAVA` ausente no corpo → `trava ausente`.
  - `/1`: `assert_file agents/revisor.md`; `name: revisor` no frontmatter; description contém `revisa e refuta sem alterar nada`.
  - `/2`: linha de `tools:` do frontmatter `== 'tools: Read, Grep, Glob, Bash'`.
  - `/3`: corpo `flat` contém `TRAVA` e `Prova por mutação só numa cópia fora do repo`.
  - `/4`: linha `model:` do frontmatter `== 'model: inherit'`.
  - `/11` arquivo real: `checar_revisor agents/revisor.md` → vazio.
  - `/11` mutações (cópias em `$SP`, uma por caso, cada uma → saída contém a violação):
    `tools: Read, Grep, Glob, Bash, Write` → `ferramenta proibida: Write`;
    `…, Edit` → `ferramenta proibida: Edit`;
    `…, NotebookEdit` → `ferramenta proibida: NotebookEdit`;
    `…, Agent` → `ferramenta proibida: Agent`;
    `…, Task` → `ferramenta proibida: Task`;
    linha `tools:` removida → `sem tools: (herda todas)`;
    `model: sonnet` → `model não é inherit`;
    `TRAVA` trocada por `Trava do shell: cuidado.` → `trava ausente`;
    `tools: Read, Grep, Glob, Bash(git status)` → vazio (Bash restrito continua permitido).
- **ler**: `tests/test-parada-revisao.sh:6-15`, `tests/lib.sh:1-21`
- **done quando**: `bash tests/test-agentes-dedicados.sh` sai 0 com os casos acima e `bash hooks/gate agentes-dedicados` passa.

- [x] **red** — `bash tests/test-agentes-dedicados.sh` (com `agents/revisor.md` ainda inexistente) sai ≠ 0 com `FAIL: agentes-dedicados/1 … arquivo ausente: agents/revisor.md`; as mutações reprovam por arquivo-base ausente, não por erro de sintaxe do teste
- [x] **green** — criar `agents/revisor.md`; `bash tests/test-agentes-dedicados.sh` sai 0; `bash hooks/gate agentes-dedicados` passa (suíte toda verde)
- [x] **commit** — `git add agents/revisor.md tests/test-agentes-dedicados.sh && git commit -m "feat(agentes-dedicados/1): agente revisor read-only com trava do shell e guarda por mutação"`

## Tarefa 2: validate despacha o `revisor` pelo nome

- **depende-de**: [1]
- **requisito**:
  - `agentes-dedicados/5` — QUANDO a validate roda a revisão adversarial de uma demanda HIGH O SISTEMA DEVE despachar o `revisor` pelo nome, mantendo as regras atuais da revisão (3 classes de bloqueante com prova, ressalva, 1 passagem + reverificação)
  - `agentes-dedicados/9` (lado validate) — QUANDO o despacho do `revisor` pelo nome falha (agente ausente ou não carregado) O SISTEMA DEVE despachar subagente genérico com a mesma trava no prompt e escrever 1 linha avisando que o read-only não está garantido — no roteiro da validate ou no relatório da caçada
  - `agentes-dedicados/10` (lado validate) — QUANDO nem o `revisor` nem o genérico podem ser despachados O SISTEMA DEVE manter o comportamento de hoje: a validate escreve "revisão adversarial não rodou — <motivo>" e segue para o portão; a caçada verifica pela própria sessão e escreve 1 linha no relatório
- **decisões relevantes**: fallback genérico com trava e aviso (humano 2026-10-15); fora-de-escopo: mudar classes, parada e ressalva. `skills/validate/SKILL.md` não muda (teto 6300 bytes).
- **interfaces**: consome `NOME`, `TRAVA` e o aviso da validate (constantes do header); consome `flat` e `TRAVA` de `tests/test-agentes-dedicados.sh` (Tarefa 1).
- **ponto de mudança**: `skills/validate/references/revisao-adversarial.md:6-15` (`## Despacho`): 1º parágrafo passa a mandar despachar o agente `revisor` do plugin (`subagent_type: audora-commander:revisor`), mantendo `subagente de contexto limpo` e `Autor não revisa a si mesmo`; frase `A passagem completa e a reverificação usam o mesmo despacho.`; parágrafo novo de fallback com a `TRAVA` no prompt do genérico e o aviso. Parágrafo dos executáveis falsos (13-15) fica. `skills/validate/references/revisao-adversarial.md:63-65` (`## No roteiro`): "Subagente revisor que não pôde ser despachado ou falhou" vira "Nem o `revisor` nem o subagente genérico puderam ser despachados, ou falharam", mantendo `revisão adversarial não rodou — <motivo>` e `o portão segue com o humano revisando o diff`.
- **teste**: `tests/test-agentes-dedicados.sh` — casos `agentes-dedicados/5 …`, `/9 validate …`, `/10 validate …`
- **asserções** (sobre `flat "$R" '## Despacho'`, `R=skills/validate/references/revisao-adversarial.md`):
  - `/5`: contém `subagent_type: audora-commander:revisor`; contém `A passagem completa e a reverificação usam o mesmo despacho.`; `bash tests/test-parada-revisao.sh` sai 0 (regras atuais intactas).
  - `/9`: contém `Despacho do `revisor` falhou (agente ausente ou não carregado)`; contém `TRAVA`; contém `revisão adversarial por subagente genérico — read-only não garantido`.
  - `/10` (sobre `flat "$R" '## No roteiro'`): contém `Nem o `revisor` nem o subagente genérico puderam ser despachados`; contém `revisão adversarial não rodou — <motivo>`.
  - `skills/validate/SKILL.md` inalterado: `git diff --quiet 2c98aba -- skills/validate/SKILL.md` (2c98aba = HEAD antes da demanda) no done (não vira assert — o teto de bytes já guarda).
- **ler**: `skills/validate/references/revisao-adversarial.md:1-71` (reler — pode ter mudado), `tests/test-parada-revisao.sh:18-26,71-78`
- **done quando**: casos acima verdes, `bash tests/test-parada-revisao.sh` sai 0, reference ≤ 250 linhas e `bash hooks/gate agentes-dedicados` passa.

- [x] **red** — `bash tests/test-agentes-dedicados.sh` sai ≠ 0 com `FAIL: agentes-dedicados/5 … não contém 'subagent_type: audora-commander:revisor'`
- [x] **green** — editar a reference; `bash tests/test-agentes-dedicados.sh` e `bash tests/test-parada-revisao.sh` saem 0; `bash hooks/gate agentes-dedicados` passa
- [x] **commit** — `git add skills/validate/references/revisao-adversarial.md tests/test-agentes-dedicados.sh && git commit -m "feat(agentes-dedicados/5): revisão adversarial despacha o revisor pelo nome, com fallback travado"`

## Tarefa 3: caçada despacha o `revisor` para refutar os achados

- **depende-de**: [1]
- **requisito**:
  - `agentes-dedicados/6` — QUANDO o modo caçada do debug termina a varredura com ≥1 achado O SISTEMA DEVE despachar o `revisor` uma única vez com a lista de achados para tentar refutar cada um, antes de escrever o relatório
  - `agentes-dedicados/7` — QUANDO o revisor devolve a refutação de um achado da caçada O SISTEMA DEVE dar o veredito só depois de a sessão conferir a prova contra o artefato real, e registrar no relatório o que o revisor disse de cada achado
  - `agentes-dedicados/8` — QUANDO o modo caçada termina com zero achados O SISTEMA DEVE não despachar o revisor
  - `agentes-dedicados/9` (lado caçada) — QUANDO o despacho do `revisor` pelo nome falha (agente ausente ou não carregado) O SISTEMA DEVE despachar subagente genérico com a mesma trava no prompt e escrever 1 linha avisando que o read-only não está garantido — no roteiro da validate ou no relatório da caçada
  - `agentes-dedicados/10` (lado caçada) — QUANDO nem o `revisor` nem o genérico podem ser despachados O SISTEMA DEVE manter o comportamento de hoje: a validate escreve "revisão adversarial não rodou — <motivo>" e segue para o portão; a caçada verifica pela própria sessão e escreve 1 linha no relatório
- **decisões relevantes**: revisor refuta, não caça — autor e verificador separados (humano 2026-10-15); modo sintoma fora de escopo.
- **interfaces**: consome `NOME`, `TRAVA`, os avisos da caçada e os vereditos `sustentado`/`refutado`/`inconclusivo` (Tarefa 1).
- **ponto de mudança**: `skills/debug/SKILL.md:81` — entre a lista de classes (termina na 80) e `Relatório em …` (82), bloco novo `**Refutação pelo revisor.**` com as frases das asserções; `skills/debug/SKILL.md:84-85` — tabela ganha a coluna `Revisor` entre `Verificação (comando/leitura)` e `Veredito`; `skills/debug/SKILL.md:102` — linha nova na tabela de red flags.
- **teste**: `tests/test-agentes-dedicados.sh` — casos `agentes-dedicados/6 …` a `/10 caçada …`
- **asserções** (sobre `flat skills/debug/SKILL.md '## Modo caçada (sem sintoma)'`):
  - `/6`: contém `Varredura terminou com ≥1 achado → despache o agente `revisor` do plugin (`subagent_type: audora-commander:revisor`) UMA vez, com a lista de achados, para tentar refutar cada um — antes de escrever o relatório.`
  - `/7`: contém `Resposta do revisor é pista: o veredito sai só depois de você conferir a prova dele contra o artefato real.`; contém a linha de cabeçalho `| # | Classe | Achado | Verificação (comando/leitura) | Revisor | Veredito | Ação |`; contém `Revisor = o que ele disse do achado (`sustentado`, `refutado` ou `inconclusivo`) e a prova dele, 1 linha.`
  - `/8`: contém `Zero achados → não despache o revisor.`
  - `/9`: contém `Despacho do `revisor` falhou (agente ausente ou não carregado)`; contém `TRAVA`; contém `refutação por subagente genérico — read-only não garantido`.
  - `/10`: contém `verifique pela própria sessão`; contém `refutação do revisor não rodou — <motivo>`.
  - regressão: `bash tests/test-plano-mapa.sh` sai 0 (`Varredura por classes de defeito` intacta); `skills/debug/SKILL.md` ≤ 250 linhas.
  - red flag (sobre `flat skills/debug/SKILL.md '## Red flags — pare e volte ao fluxo'`): contém `| "O revisor refutou, marco falso-positivo" | Refutação é pista. Confira a prova dele no artefato antes do veredito. |`
- **ler**: `skills/debug/SKILL.md:55-120` (reler), `tests/test-plano-mapa.sh:50-60`
- **done quando**: casos acima verdes, `bash tests/test-plano-mapa.sh` sai 0 e `bash hooks/gate agentes-dedicados` passa.

- [x] **red** — `bash tests/test-agentes-dedicados.sh` sai ≠ 0 com `FAIL: agentes-dedicados/6 … não contém 'Varredura terminou com ≥1 achado`
- [x] **green** — editar `skills/debug/SKILL.md`; `bash tests/test-agentes-dedicados.sh` e `bash tests/test-plano-mapa.sh` saem 0; `bash hooks/gate agentes-dedicados` passa
- [x] **commit** — `git add skills/debug/SKILL.md tests/test-agentes-dedicados.sh && git commit -m "feat(agentes-dedicados/6): caçada despacha o revisor para refutar os achados"`

## Tarefa 4: READMEs e checklist citam o revisor

- **depende-de**: [2, 3]
- **requisito**: `agentes-dedicados/1` — QUANDO o plugin está instalado O SISTEMA DEVE listar um agente `revisor` entre os agentes do plugin, com descrição que diga que ele revisa e refuta sem alterar nada (o checklist manual de instalação passa a conferir a listagem)
- **decisões relevantes**: README.md em inglês e README.pt-BR.md em português (Constituição, exceção 2026-08-24).
- **interfaces**: consome `NOME` e o comportamento das Tarefas 2 e 3.
- **ponto de mudança**:
  - `README.md:247-248` — "an adversarial review by a clean-context subagent" vira "an adversarial review by the plugin's read-only `revisor` agent (clean context)".
  - `README.md:285-286` — fim da frase do hunt mode ganha "; the read-only `revisor` agent then tries to refute each finding once before the report".
  - após o item 5 (`README.md:374-376`) — item novo `- [ ] 6. WHEN the plugin is installed, Claude Code MUST list the agent `audora-commander:revisor` (check the session's agent listing).`
  - `README.pt-BR.md:248-249` — "revisão adversarial por subagente de contexto limpo" vira "revisão adversarial pelo agente `revisor` do plugin (read-only, contexto limpo)".
  - `README.pt-BR.md:285-286` — fim da frase da caçada ganha "; depois o agente `revisor`, read-only, tenta refutar cada achado uma vez antes do relatório".
  - após o item 5 (`README.pt-BR.md:372-374`) — item novo `- [ ] 6. QUANDO o plugin estiver instalado, o Claude Code DEVE listar o agente `audora-commander:revisor` (verifique na listagem de agentes da sessão).`
- **teste**: `tests/test-agentes-dedicados.sh` — casos `agentes-dedicados/1 docs EN …`, `/1 docs PT …`
- **asserções**: `flat README.md` contém `adversarial review by the plugin's read-only `revisor` agent`, `the read-only `revisor` agent then tries to refute each finding once` e `MUST list the agent `audora-commander:revisor``; `flat README.pt-BR.md` contém `revisão adversarial pelo agente `revisor` do plugin`, `o agente `revisor`, read-only, tenta refutar cada achado uma vez` e `DEVE listar o agente `audora-commander:revisor``; `bash tests/test-parada-revisao.sh` sai 0 (frases de docs pinadas em `tests/test-parada-revisao.sh:90-104` intactas) e `bash tests/test-docs.sh` sai 0.
- **ler**: `README.md:240-292,359-378`, `README.pt-BR.md:241-286,358-375` (reler — linhas podem ter andado), `tests/test-parada-revisao.sh:90-104`
- **done quando**: casos acima verdes e `bash hooks/gate agentes-dedicados` passa.

- [x] **red** — `bash tests/test-agentes-dedicados.sh` sai ≠ 0 com `FAIL: agentes-dedicados/1 docs EN … não contém 'adversarial review by the plugin's read-only`
- [x] **green** — editar os dois READMEs; `bash tests/test-agentes-dedicados.sh`, `bash tests/test-parada-revisao.sh` e `bash tests/test-docs.sh` saem 0; `bash hooks/gate agentes-dedicados` passa
- [x] **commit** — `git add README.md README.pt-BR.md tests/test-agentes-dedicados.sh && git commit -m "docs(agentes-dedicados/1): READMEs e checklist citam o agente revisor"`
