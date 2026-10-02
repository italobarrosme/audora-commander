# E2E — parada-revisao (2026-10-01)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.14.0 da
branch `parada-revisao` em `21766ac`, carregado por sessão com
`--plugin-dir <repo>` e o plugin instalado desligado só naquela sessão
(`--settings '{"enabledPlugins":{"audora-commander@audora-commander-dev":false}}'`;
o `system/init` mostra só `audora-commander` apontando o repo). O cache global
não foi tocado. Ferramenta: `claude -p` (CLI 2.1.284, Constituição
`ferramenta-e2e`), binário `~/.local/bin/claude.exe`.

## Receita (regressão)

1. **Fixture** (`mkfx.sh <dir> HIGH|MEDIUM`, gerada em `mktemp`): CLI bash
   `notas.sh` (`add`, `listar`) com notas em `NOTAS_ARQ`; MEMORY, PRD e
   CHANGELOG na `main`; nó `apagar-nota` com 3 critérios (remove só a linha
   do id; id inexistente sai 2 sem tocar no arquivo; `.bak` antes) e
   categoria na decisão `(IA): HIGH|MEDIUM`; plano de 1 tarefa marcado. Na
   branch `feat/apagar-nota`, o `apagar` correto (filtro `awk` por `$1`) e um
   defeito plantado fora da demanda: `listar` troca `sort -n` por `cat`
   (o nó põe "mudar o comando `listar`" no fora-de-escopo). Suíte da fixture
   7/7.
   - **E2**: E1b depois da passagem 1 + execute simulada das Tarefas 2 e 3
     (`listar` volta ao `sort -n`; comparação de texto no `awk`), com um
     achado novo plantado no diff da correção: a mensagem do `add` sem texto
     muda (fora da demanda, a suíte só olha o exit). Suíte 10/10.
2. **Sessão**:
   `claude.exe -p "<prompt>" --plugin-dir <repo> --settings '<acima>' --permission-mode acceptEdits --allowedTools Bash --output-format stream-json --verbose > X.jsonl 2> X.err`.
   Prompt: `validate de apagar-nota. O humano já decidiu: e2e pulado-pelo-humano — não pergunte sobre e2e, siga o fluxo da validate.`
   E3b soma `--disallowedTools "Agent,Task"`. E4 é `--resume` da sessão do E2
   com "Aprovado. Aceito as ressalvas 1 a 7 … Pode fazer o merge na main
   (local, sem push) e rodar o sync."
3. **Leitura**: `resumo.pl` extrai do `.jsonl` cada `tool_use` (Read, Bash,
   Skill, Agent com o prompt), o relatório do subagente (tool_result do
   Agent), os textos e o `result`; depois o disco da fixture (`git log`,
   plano, nó arquivado, `PRD.md`, `CHANGELOG.md`).

Rodada descartada: a 1ª fixture plantava também `grep -v "^$id"` sem âncora
(`apagar 1` levava 10 e 11). E1, E3 e E5 pararam no gate 1:1 da própria
validate, que sondou a borda e reprovou `apagar-nota/1` — comportamento
certo, mas a revisão adversarial nunca rodou. Refeitas como E1b/E3b/E5b com
só o defeito fora da demanda.

## Critérios × evidência

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| parada-revisao/1: revisor marca bloqueante só nas 3 classes | E1b | Leu `references/revisao-adversarial.md`; prompt do `Agent`: "Bloqueante: SÓ 3 classes, cada uma com prova: (a) apaga ou altera coisa fora da demanda … (b) viola um critério de aceite … (c) falha com entrada ou formato real … Borda teórica, estilo, melhoria e risco sem reprodução NÃO bloqueiam" | passou |
| parada-revisao/2: bloqueante exige prova; sem prova rebaixa | E1b | Revisor devolveu B1 (a) com o trecho `-sort -n` / `+cat` do diff e a reprodução `3 c/1 a/2 b`, B2 (b) `apagar-nota/2` com `apagar 1.0` → `apagada: 1.0`, rc=0. Validate: "Resposta do revisor é pista. Confiro as provas eu mesmo" e reroda as duas provas antes de aceitar. CRLF "não confirmado" e escrita não atômica (sem reprodução) ficaram como ressalva | passou |
| parada-revisao/3: não bloqueante vira ressalva de 1 linha, sem voltar à execute | E1b | 5 ressalvas de 1 linha nas Notas de sessão e no texto final; nenhuma virou tarefa nem disparou outra passagem — só B1 e B2 viraram Tarefas 2 e 3 | passou |
| parada-revisao/4: com bloqueante corrigido, reverificação restrita | E1b → E2 | E1b: Notas "revisão adversarial: passagem 1" com classe e prova; Próximo "PARADA: rode `/clear` … `execute de apagar-nota`. Depois, `validate de apagar-nota` faz só a reverificação". E2: "passagem 1 já feita"; prompt do `Agent`: "REVERIFICAÇÃO RESTRITA … confira SOMENTE se os dois bloqueantes … NÃO cace achados novos" | passou |
| parada-revisao/5: nunca 3ª passagem; achado novo vira ressalva | E2 | Achado novo plantado (mensagem do `add`) confirmado pela validate: "reverificação não abre 3ª passagem: entra como ressalva" → ressalva 1 do roteiro; Notas: "reverificação (fim da revisão)"; foi ao portão humano | passou |
| parada-revisao/6: roteiro com nº de passagens, bloqueante com classe/prova/estado, ressalvas | E2 | Seção "Revisão adversarial: passagem 1 + reverificação (encerrada)": B1 (classe a) **corrigido**, B2 (classe b) **corrigido**, provas reproduzidas na tabela de critérios; 7 ressalvas de 1 linha | passou |
| parada-revisao/7: revisor indisponível → aviso de 1 linha, portão segue | E3b (`--disallowedTools Agent,Task`) | Leu a reference; roteiro: "Revisão adversarial — Não rodou. Esta sessão não tem ferramenta de subagente … Você precisa revisar o diff você mesmo." Portão apresentado ao humano | passou |
| parada-revisao/8: ressalva aceita vai ao nó e, no sync, às metas do PRD | E4 | Nó arquivado `docs/audora/arquivo/2026-10-01-apagar-nota.md:34-40`: 7 linhas `- 2026-10-01 (humano): ressalva aceita — …`. `PRD.md` Metas futuras: "2. Candidato a nó: ressalvas do `apagar-nota` aceitas no portão." com 7 sub-itens; meta entregue saiu; 1 linha no `CHANGELOG.md` | passou |
| parada-revisao/9: MEDIUM não carrega o texto da demanda | E5b + gate | E5b (MEDIUM): nenhum `Read` de `revisao-adversarial.md`, nenhum `Agent`; a única ocorrência no `.jsonl` é a linha-ponteiro do roteador. Gate: `carga MEDIUM (bytes): base=47723 full=55350 — tetos 48000 / 56900` | passou |
| parada-revisao/10: versão 0.14.0 nos 2 manifests | leitura + suíte | `"version": "0.14.0"` em `plugin.json` e `marketplace.json` (`test-parada-revisao.sh` 61/61); reinstalar pelo cache ficou fora (branch não mergeada) | passou (sem reinstalar) |

## Custo

| sessão | turnos | US$ |
|---|---|---|
| E1, E3, E5 (descartadas) | 14 / 15 / 30 | 0,47 / 0,62 / 0,83 |
| E1b (passagem 1) | 22 | 0,99 |
| E3b (revisor indisponível) | 12 | 0,53 |
| E5b (MEDIUM) | 14 | 0,50 |
| E2 (reverificação) | 15 | 0,78 |
| E4 (aprovação + sync) | 25 | 1,40 |

As 8 sessões terminaram com exit 0.
