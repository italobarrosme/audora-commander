# E2E — memoria-integra (2026-10-08)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.16.0 da
`main` em `fe5298b`, reinstalado com `claude plugin uninstall
audora-commander@audora-commander-dev && ./install.sh`. `diff -r` de
`skills/`, `hooks/` e `templates/` contra `<cache>/0.16.0` → iguais.
Ferramenta: `claude -p` (CLI 2.1.284, Constituição `ferramenta-e2e`).
Gate antes do e2e: `bash hooks/gate memoria-integra` → `GATE: passou`, exit 0.

Caminhos de fixture só aparecem dentro de bloco de código: este relatório
mora em docs/audora e é varrido pela própria cleanup.

## Receita (regressão)

1. **Fixture** — `fixture.sh <dir> <tipo>` (no scratchpad), um diretório por
   cenário, git próprio, `core.autocrlf false`:

```text
vazio  código (package.json, src/cart.js), sem MEMORY                       → /17
apr    MEMORY novo (Aprendizados só com o ponteiro), sem aprendizados.md    → /14
ctx    MEMORY com L1 (execute) e L2 (validate) legados; aprendizados.md com
       A1, A2 [invalidado-em:], A3, A4 (e2e); nó carrinho [carrinho, cupom] → /15
ctx0   como apr: nenhum aprendizado em lugar nenhum                         → /15
sync   nó carrinho in-progress SEM critério; docs/audora/specs/carrinho-escopo.md
       com carrinho/1 (2 linhas) e /2; MEMORY com L1, linha em branco, L2;
       aprendizados.md com A0; plano; 2 commits (escopo, código)            → /2, /16
sync0  igual ao sync, mas a spec não tem critério                           → /3
scope  como apr; demanda nova de cobrança com cartão (HIGH)                 → /1, /7
hook   como apr; passos de TESTE DE HOOK                                    → /5, /6, /20
limpa  nó d delivered só com d/1; docs/audora/specs/d-escopo.md cita d/1 e d/2;
       docs/audora/planos/arquivo/plano-d.md cita d/1; aprendizados.md com link
       para docs/audora/e2e/e2e-velho.md (versionado e removido)           → /4, /12, /19
```

2. **Sessão** — `claude -p "<prompt>" --permission-mode acceptEdits
   --allowedTools "Bash Read Grep Glob Skill Write Edit" --output-format
   stream-json --verbose`, turnos seguintes com `--resume <session_id>`.
   Prova lida do `.jsonl` (ordem das tool calls, mensagens de hook) e do
   disco. Prompts:
   - `vazio`: "Este projeto ainda não tem a memória do framework. Crie a memória do produto (bootstrap)…"
   - `apr`: "…os testes exigem Node 20 ou maior… Registre esse aprendizado" e, no turno 2, um segundo aprendizado.
   - `ctx`/`ctx0`: "Vou começar a fase execute do nó carrinho. Carregue o contexto pela skill memory e me liste… os aprendizados que entram."
   - `sync`/`sync0`: "O portão da demanda carrinho foi APROVADO… Rode só o sync pós-aprovação da skill validate (item 6) e commite."
   - `scope`: "Nova demanda: cobrança real com cartão de crédito no checkout, via gateway Stripe…"; turno 2 com as respostas e o escopo aprovado de antemão.
   - `hook`: "Isto é um TESTE DE HOOK…" — 1) Write de um nó novo antes da linha; 2) Edit do índice com a linha; 3) Write de um nó órfão; 4) Edit do Propósito no MEMORY; 5) Write de aprendizados.md com 322 linhas.
   - `limpa`: "Faz uma faxina nas sobras do processo…"; turno 2 "Aprovo o lote inteiro."
3. **CLI direta** — `hooks/cleanup aplicar` com lote à mão numa cópia da
   `limpa`, um alvo por vez (aprendizados.md, decisoes-vivas.md, nó
   arquivado, MEMORY.md) + 1 item válido; e `grep` no cache para os
   critérios de texto.

## Resultado

| Critério (`<id>/<n>` + EARS) | Passo executado | Evidência | Veredito |
|---|---|---|---|
| memoria-integra/1 — scope de HIGH grava critérios no nó; spec, se houver, só contexto | `scope` turnos 1–2 (porta de entrada classificou HIGH → scope) | contagem de `<id>/[0-9]+` em `## criterios-aceite` do nó = 12; nenhuma pasta specs criada | passou |
| memoria-integra/2 — sync copia critérios da spec antes do `git mv` | `sync` | bloco A: os 2 critérios no nó arquivado, `diff` contra a spec → LITERAL; no `.jsonl` o Edit dos critérios vem antes do `git mv` | passou |
| memoria-integra/3 — nó segue sem critério → para sem arquivar, nomeia o nó | `sync0` | resposta: "Nó carrinho sem critério numerado — sync parado, nada arquivado."; `git status` limpo, nó segue em memory/, sem commit novo | passou |
| memoria-integra/4 — spec/plano/e2e que cita critério sem cópia → `## mantido` | `limpa` turnos 1–2 | relatório: spec em `## mantido: cita d/2 sem cópia no nó arquivado`; lote só com o plano arquivado; após aplicar, spec continua no disco | passou |
| memoria-integra/5 — arquivo do nó antes da linha → sem erro | `hook` passos 1 e 3 | nenhuma mensagem de hook nos dois Writes (`.jsonl`) | passou |
| memoria-integra/6 — escrita do MEMORY com órfão → exit 2 | `hook` passo 4 | bloco B: `PostToolUse:Edit hook blocking error … memory-validate: …` acusando o nó órfão "sem linha no índice mestre" | passou |
| memoria-integra/7 — skill memory e references só com "arquivo do nó primeiro, linha do índice logo depois" | grep no cache + ordem real em `scope` turno 1 | `mesma edição`: 0 ocorrências em skills/templates; a regra aparece em `skills/memory/SKILL.md`, `references/registrar-no.md`, `MEMORY-template.md`; sessão real: Write do nó → Edit do índice, sem hook | passou |
| memoria-integra/12 — arquivo lido pelo framework fora do lote; `aplicar` recusa sem alterar nada | CLI `aplicar` em cópia da `limpa` (4 alvos) | bloco C: exit 1, `arquivo lido pelo framework nunca é removido` (aprendizados.md, decisoes-vivas.md, nó arquivado) e `fora de docs/audora/` (MEMORY.md); HEAD/status/md5 iguais nos 4 | passou |
| memoria-integra/13 — princípio "só sai o que não é mais usado…" + red flag | grep no cache | `skills/cleanup/SKILL.md:12` (Princípio) e `:94` (red flag "Ninguém mais abre isso, pode sair") | passou |
| memoria-integra/14 — aprendizado vai para aprendizados.md (criado se faltar), nunca no MEMORY | `apr` turnos 1–2 | turno 1 criou o arquivo pelo template + linha no fim; turno 2 acrescentou a 2ª linha no fim; `git diff MEMORY.md` vazio nos dois | passou |
| memoria-integra/15 — carregar-contexto busca nos dois arquivos, sem invalidados, sem erro se faltar | `ctx` e `ctx0` | `ctx`: comando `grep -shiE … docs/audora/aprendizados.md MEMORY.md \| grep -vF '[invalidado-em:'`; entram L1, A1, A3; A2 (invalidado), A4 e L2 fora. `ctx0`: mesma busca, vazia, sem erro, "Nenhum aprendizado entra" | passou |
| memoria-integra/16 — sync move as linhas do MEMORY, literais e na ordem, para o fim; seção só com ponteiro | `sync` | bloco A: aprendizados.md = A0, L1, L2 (A0 intacta; linha em branco legada não migrou); seção Aprendizados do MEMORY só com o ponteiro | passou |
| memoria-integra/17 — bootstrap: Aprendizados só com ponteiro, sem criar aprendizados.md | `vazio` | seção = linha de ponteiro; `docs/audora/` só com `memory/`; resposta: "nasce no primeiro aprendizado" | passou |
| memoria-integra/18 — este repo sem linha de aprendizado no MEMORY, todas no arquivo próprio | grep neste repo | `grep -cE '^- [0-9]{4}-…\| ' MEMORY.md` → 0; em `docs/audora/aprendizados.md` → 55 | passou |
| memoria-integra/19 — cleanup ignora aprendizados.md na varredura de links | `limpa` turnos 1–2 | link para arquivo versionado e removido, citado só em aprendizados.md: sem `## link quebrado`; commit da cleanup não toca aprendizados.md (`git diff` 0 linhas) | passou |
| memoria-integra/20 — `memory-guard` sai 0 sem aviso para aprendizados.md de qualquer tamanho | `hook` passo 5 | Write de 322 linhas sem nenhuma mensagem de hook | passou |
| memoria-integra/21 — skills/templates/hooks citam só aprendizados.md, sem teto ~40 nem histórico | grep no cache | `grep -rniE 'aprendizados-historico\|~ ?40 linhas\|> ?40'` em skills, templates e hooks → vazio | passou |

/8–/11: removidos no delta (sem passo).

### Bloco A — `sync`, disco depois do commit do sync

```text
-- docs/audora/aprendizados.md
# Aprendizados

- 2026-01-01 | plan | A0 Projeto sem dependências: só node:test.
- 2026-01-02 | execute | L1 Carrinho: preço em centavos (inteiro), nunca float.
- 2026-01-03 | validate | L2 Frete: CEP vai sem hífen na API de frete.
-- MEMORY.md, seção Aprendizados
Aprendizados vivem em `docs/audora/aprendizados.md` (1 linha cada, só por grep — skill memory, registrar-aprendizado).
-- critérios do nó arquivado docs/audora/arquivo/2026-10-08-carrinho.md
- **carrinho/1** — QUANDO o cliente aplica cupom válido O SISTEMA DEVE
  descontar o valor do total, sem deixar o total negativo.
- **carrinho/2** — QUANDO o cupom está expirado O SISTEMA DEVE recusar com
  a mensagem "cupom expirado".
-- diff contra a spec → LITERAL
```

### Bloco B — `hook`, mensagem do passo 4

```text
PostToolUse:Edit hook blocking error from command: ""C:\Users\Italo Barros\workspace\audora-commander/hooks/run-hook.cmd" memory-validate": […]: memory-validate: memória inconsistente — PARE e corrija antes de seguir:
- arquivo docs/audora/memory/orfao.md sem linha no índice mestre
```

### Bloco C — `aplicar` com lote à mão

```text
cleanup: falhou em: - docs/audora/aprendizados.md | x — arquivo lido pelo framework nunca é removido
cleanup: lote desfeito, nada commitado        exit=1  nada mudou
cleanup: falhou em: - docs/audora/decisoes-vivas.md | x — arquivo lido pelo framework nunca é removido
cleanup: lote desfeito, nada commitado        exit=1  nada mudou
cleanup: falhou em: - docs/audora/arquivo/2026-01-01-d.md | x — arquivo lido pelo framework nunca é removido
cleanup: lote desfeito, nada commitado        exit=1  nada mudou
cleanup: falhou em: - MEMORY.md | x — fora de docs/audora/
cleanup: lote desfeito, nada commitado        exit=1  nada mudou
```

## Observações (fora dos critérios)

- `sync0`: a sessão segurou também o passo 1 (migração dos aprendizados) para
  o sync sair num commit só. O critério /3 só exige não arquivar e avisar —
  atendido; a migração ocorre no sync seguinte.
- Prompt do `scope` turno 2 disse "não quero spec dedicada além do
  necessário"; o caminho "spec criada só com contexto" do /1 ficou coberto
  pela suíte, não por sessão real.
- Teardown: nenhum processo levantado; fixtures só no scratchpad.
