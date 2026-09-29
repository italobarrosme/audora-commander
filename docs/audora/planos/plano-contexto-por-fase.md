# Plano — contexto-por-fase: Contexto zerado por fase

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** fim de scope/plan/execute de MEDIUM/HIGH vira PARADA (`/clear` +
comando de retomada); "segue" roda a fase seguinte em subagente de contexto
zerado; autopilot MEDIUM executa pelo motor, com subagentes se ele recusar.

**Nó do MEMORY:** `contexto-por-fase` (MEMORY.md)

**Arquitetura da mudança:** a regra de parada vive UMA vez, numa seção nova
`## Parada entre fases` de `templates/bloco-fechamento-template.md` (já lido
uma vez por sessão por toda fase); scope, plan e execute só trocam a frase de
fechamento para `PARADA: rode /clear ...`. O protocolo do subagente ("segue" e
fallback do motor) vai para um template próprio,
`templates/fase-subagente-template.md`, lido só quando usado — fica FORA da
carga BASE de `tests/test-carga.sh` (folga medida: 1483 bytes). A execute
ganha a seção `## Autopilot MEDIUM (motor)`. Guardas numa suíte nova,
`tests/test-contexto-por-fase.sh`, asserindo FRASE inteira dentro da seção
extraída (aprendizado de 2026-09-05); os 3 asserts de `otimizacao-tokens/4`
(que exigiam "/clear recomendado") são SUBSTITUÍDOS 1:1, sem queda de contagem.

**Arquivos lidos antes de planejar:** (Graphify fora do PATH do Bash —
aprendizado 2026-09-27 — localização degradada para grep, com aviso)
- `templates/bloco-fechamento-template.md` — regra 4 do Próximo: "/clear recomendado", "Em autopilot, omitir".
- `skills/scope/SKILL.md` — item 8 "Recomendo /clear"; item 7 portão antecipado (autopilot já emenda).
- `skills/plan/SKILL.md` — item 1 contexto; item 9 "Recomendo /clear"; item 8 portão HIGH.
- `skills/execute/SKILL.md` — item 1 "sem plano-arquivo → volte à skill plan"; seção "Volta de loop"; Próximo do bloco.
- `skills/validate/SKILL.md` — chama e2e e volta (e2e ↔ validate já na mesma sessão); `test-skills.sh` cobra < 7700 bytes → NÃO tocar.
- `skills/audora-commander/SKILL.md` — roteamento e seção Autopilot; entrada já emenda na 1ª fase (nada a mudar).
- `skills/e2e/SKILL.md` — PRÓXIMA SKILL volta à validate (nada a mudar).
- `hooks/loop` — uso `loop <id> [...]`; recusa imprime `LOOP: rodada recusada — falta:` e sai 1; exige `autopilot: elegivel`, `gate:`, `sandbox:`, branch própria.
- `templates/loop-prompt-template.md` — modelo de template de prompt (formato do novo template de subagente).
- `tests/test-templates.sh` (linhas 29-32), `tests/test-skills.sh` (linhas 193-199), `tests/test-carga.sh`, `tests/lib.sh`, `tests/run.sh` (descobre `tests/test-*.sh` sozinho), `tests/test-docs.sh` (lê `.claude-plugin/*.json`).
- `README.md` / `README.pt-BR.md` (seções scope, plan, execute: "Next/Próxima"), `docs/fundamentos.md` (P3 regra 6: "/clear é do humano; fim de fase é o gatilho").
- `hooks/gate` — anti-fraude 3: queda de contagem de asserts reprova sem `gate-asserts:` no nó.

**Conflitos MEMORY vs código encontrados:** nenhum. Pré-condição fora do
código: `.claude-plugin/plugin.json` e `marketplace.json` estão APAGADOS no
working tree (não commitado) → linha de base da suíte 736 PASS / 5 FAIL, todas
em `test-docs.sh`. Gate não fica verde sem restaurar — decisão do humano
(`git restore .claude-plugin/`).

## Decisões tomadas pela IA

- Protocolo do subagente em template próprio (fora da carga BASE), não inline no template de fechamento — folga de 1483 bytes não comporta.
- Fallback do motor (/11): uma tarefa por subagente, espelhando o motor (contexto zerado por tarefa).
- Asserts de `otimizacao-tokens/4` substituídos 1:1 (critério superado por esta demanda), mantendo a contagem.
- validate e audora-commander não mudam: e2e ↔ validate e entrada → 1ª fase já emendam; validate está no teto de 7700 bytes.
- Retomada inválida (/9) coberta na regra geral do template + plan e execute; validate fica de fora pelo teto de bytes.

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

---

## Tarefa 1: Regra de parada no template de fechamento

- **depende-de**: []
- **requisito**:
  - **contexto-por-fase/1** — QUANDO uma fase scope, plan ou execute de demanda MEDIUM ou HIGH (fora de autopilot) termina, com o portão aprovado quando houver, O SISTEMA DEVE encerrar a resposta com o bloco de fechamento cujo **Próximo** é a PARADA — instrução de `/clear` mais o comando de retomada exato (`<fase> de <id>`) — e NÃO iniciar a fase seguinte na mesma resposta.
  - **contexto-por-fase/2** — QUANDO a porta de entrada termina de classificar a demanda O SISTEMA DEVE emendar na primeira fase na mesma sessão, sem parada.
  - **contexto-por-fase/3** — QUANDO a demanda é LIGHT ou HOTFIX O SISTEMA DEVE percorrer execute → validate na mesma sessão, sem parada.
  - **contexto-por-fase/4** — QUANDO a validate chama o e2e O SISTEMA DEVE voltar à validate com o relatório na mesma sessão, sem parada.
  - **contexto-por-fase/9** — QUANDO o comando de retomada cita id inexistente ou fase fora de ordem (ex.: `execute de <id>` MEDIUM sem plano-arquivo) O SISTEMA DEVE recusar nomeando o artefato que falta e apontar a fase certa.
  - **contexto-por-fase/12** — QUANDO a fase termina interrompida, bloqueada ou com portão reprovado O SISTEMA DEVE manter como **Próximo** a decisão humana pendente, sem comando de retomada de fase seguinte.
  - **contexto-por-fase/13** — QUANDO a suíte roda O SISTEMA DEVE reprovar se scope, plan ou execute deixar de instruir a parada, ou se o template de fechamento voltar a tratar o `/clear` como mera recomendação.
- **decisões relevantes**: parada dura (nó, decisão 1); exceções do lote 1; autopilot pelo motor (lotes 1-2). Frases asseridas ficam em UMA linha no Markdown (aprendizado 2026-08-27: `assert_contains` não casa quebra de linha).
- **interfaces**:
  - consome: nada.
  - produz: seção `## Parada entre fases` no template; função de teste `sec <arquivo> '<cabeçalho>'` em `tests/test-contexto-por-fase.sh` (usada pelas tarefas 2-6).
- **arquivos**:
  - Criar: `tests/test-contexto-por-fase.sh`
  - Modificar: `templates/bloco-fechamento-template.md`, `tests/test-templates.sh` (linhas 29-32)
- **done quando**: bloco `/1 /2 /3 /4 /9 /10 /12 /13` do teste novo verde; `test-templates.sh` verde.

Passos:

- [ ] **1. Escrever teste que falha** — criar `tests/test-contexto-por-fase.sh`:

~~~bash
#!/usr/bin/env bash
# contexto-por-fase — parada entre fases, retomada, "segue" em subagente, autopilot pelo motor.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# sec <arquivo> '<cabeçalho exato>' → corpo da seção, sem \r (checkout CRLF)
sec() { tr -d '\r' < "$1" 2>/dev/null | awk -v h="$2" '$0==h{f=1;next} /^## /{f=0} f'; }

# --- /1 /2 /3 /4 /9 /10 /12 /13 — regra de parada no template de fechamento ---
T=templates/bloco-fechamento-template.md
pa="$(sec "$T" '## Parada entre fases')"
assert_contains "$pa" 'PARADA: rode /clear e, na sessão nova,' "/1 Próximo vira PARADA com retomada"
assert_contains "$pa" 'NÃO emenda a fase seguinte na mesma resposta' "/1 fase não emenda a seguinte"
assert_contains "$pa" 'porta de entrada → 1ª fase' "/2 entrada emenda"
assert_contains "$pa" 'LIGHT, HOTFIX' "/3 LIGHT e HOTFIX emendam"
assert_contains "$pa" 'e2e ↔ validate' "/4 e2e e validate na mesma sessão"
assert_contains "$pa" 'autopilot (execute pelo motor' "/10 autopilot sem parada"
assert_contains "$pa" 'templates/fase-subagente-template.md' "/5 segue aponta o template do subagente"
assert_contains "$pa" 'recusar nomeando o que falta e a fase certa' "/9 retomada inválida recusa"
assert_contains "$pa" 'interrompida, bloqueada ou reprovada não tem PARADA' "/12 fase parada sem retomada"
assert_not_contains "$(tr -d '\r' < "$T")" '/clear recomendado' "/13 template não volta a só recomendar"

report
~~~

  E em `tests/test-templates.sh`, trocar as linhas 29-32 (1:1, mesma contagem):

~~~bash
# contexto-por-fase/1,/10 — PARADA substitui a recomendação de /clear (otimizacao-tokens/4)
b2="$(cat templates/bloco-fechamento-template.md)"
assert_contains "$b2" '## Parada entre fases' "contexto-por-fase/1 template tem a seção de parada"
assert_contains "$b2" 'autopilot (execute pelo motor' "contexto-por-fase/10 autopilot sem parada"
~~~

- [ ] **2. Rodar e ver falhar pelo motivo certo** — `bash tests/test-contexto-por-fase.sh; echo "exit=$?"` → 10 `FAIL:` (seção ausente + template ainda contém "/clear recomendado"), `PASS=0 FAIL=10`, `exit=1`. `bash tests/test-templates.sh` → 2 FAIL novos.
- [ ] **3. Implementar o mínimo** — em `templates/bloco-fechamento-template.md`:
  - regra 4, trocar as duas últimas frases ("Próxima fase se reancora … não há pausa entre fases.") por: `Fim de scope, plan ou execute de MEDIUM/HIGH → PARADA (seção Parada entre fases).`
  - acrescentar, antes de `## Categoria LIGHT e HOTFIX`, a seção abaixo (formato exato; cada frase asserida numa linha só):

~~~markdown
## Parada entre fases

Fim de scope, plan ou execute de MEDIUM/HIGH é PARADA: a fase NÃO emenda a fase seguinte na mesma resposta. O **Próximo** do bloco fica:

**Próximo** — PARADA: rode /clear e, na sessão nova, `<fase> de <id>`

Sem parada: porta de entrada → 1ª fase; LIGHT, HOTFIX; e2e ↔ validate; autopilot (execute pelo motor, seção na skill execute).

- Humano diz "segue", "continua" ou "sem clear" → a fase seguinte roda em subagente de contexto zerado pelo `templates/fase-subagente-template.md`; a sessão principal recebe só o bloco dele.
- Retomada (`<fase> de <id>`) com id fora do índice ou artefato da fase ausente → recusar nomeando o que falta e a fase certa.
- Fase interrompida, bloqueada ou reprovada não tem PARADA: o **Próximo** é a decisão humana pendente.
~~~

- [ ] **4. Rodar e ver passar** — `bash tests/test-contexto-por-fase.sh; echo "exit=$?"` → `PASS=10 FAIL=0`, `exit=0`; `bash tests/test-templates.sh` → `FAIL=0`.
- [ ] **5. Commit** — `git add templates/bloco-fechamento-template.md tests/test-contexto-por-fase.sh tests/test-templates.sh && git commit -m "feat(contexto-por-fase/1,2,3,4,9,12,13): PARADA entre fases no template de fechamento"`.

## Tarefa 2: Template do subagente de fase

- **depende-de**: [1]
- **requisito**:
  - **contexto-por-fase/5** — QUANDO, na parada, o humano pede para seguir sem `/clear` ("segue", "continua", "sem clear") O SISTEMA DEVE rodar a fase seguinte num subagente de contexto zerado e devolver à sessão principal só o bloco de fechamento dessa fase.
  - **contexto-por-fase/6** — QUANDO a fase rodada em subagente tem portão humano (plano HIGH, portão final da validate) O SISTEMA DEVE apresentar o portão na sessão principal e esperar a decisão explícita do humano — o subagente prepara, nunca aprova.
  - **contexto-por-fase/7** — QUANDO a fase em subagente precisa de input humano no meio (requisito faltante, `[PRECISA-CLARIFICAR]`, falha irrecuperável) O SISTEMA DEVE encerrar o subagente devolvendo a pergunta ou o diagnóstico à sessão principal, que pergunta ao humano — nunca supor a resposta.
  - **contexto-por-fase/8** — QUANDO uma fase começa em sessão nova (depois do `/clear` ou em subagente) O SISTEMA DEVE se reancorar só pelos artefatos em disco (`MEMORY.md`, nó, plano, relatório), sem depender da conversa anterior.
- **decisões relevantes**: schemas vivem só em `templates/` (Constituição); formato espelha `templates/loop-prompt-template.md`; template fora da carga BASE (decisão IA).
- **interfaces**:
  - consome: `sec` da Tarefa 1; caminho `templates/fase-subagente-template.md` já citado pela seção de parada.
  - produz: template com placeholders `{{FASE}}`, `{{ID}}`, `{{TAREFA}}` — usado pela Tarefa 4 (fallback do motor).
- **arquivos**:
  - Criar: `templates/fase-subagente-template.md`
  - Teste: `tests/test-contexto-por-fase.sh` (inserir antes de `report`)
- **done quando**: bloco `/5 /6 /7 /8 /11` verde.

Passos:

- [ ] **1. Escrever teste que falha** — inserir antes da linha `report`:

~~~bash
# --- /5 /6 /7 /8 /11 — template do subagente de fase ---
F=templates/fase-subagente-template.md
assert_file "$F" "/5 template do subagente existe"
fs="$(tr -d '\r' < "$F" 2>/dev/null)"
assert_contains "$fs" '{{FASE}} de {{ID}}' "/5 prompt cita fase e id"
assert_contains "$fs" 'contexto zerado' "/5 subagente começa limpo"
assert_contains "$fs" 'devolva SÓ o bloco de fechamento' "/5 principal recebe só o bloco"
assert_contains "$fs" 'NUNCA aprove portão' "/6 subagente não aprova"
assert_contains "$fs" 'portão é apresentado na sessão principal' "/6 portão na principal"
assert_contains "$fs" 'devolva a pergunta' "/7 input humano volta à principal"
assert_contains "$fs" '[PRECISA-CLARIFICAR' "/7 marcador aberto interrompe"
assert_contains "$fs" 'reancore só pelos artefatos em disco' "/8 reancoragem pelos artefatos"
assert_contains "$fs" 'uma tarefa por subagente' "/11 fallback do motor: uma tarefa por subagente"
~~~

- [ ] **2. Rodar e ver falhar** — `bash tests/test-contexto-por-fase.sh; echo "exit=$?"` → 10 FAIL novos (arquivo ausente), `PASS=10 FAIL=10`, `exit=1`.
- [ ] **3. Implementar** — criar `templates/fase-subagente-template.md` (formato exato do prompt; cada frase asserida numa linha):

~~~markdown
# Template — prompt do subagente de fase

> Usado quando o humano diz "segue" na PARADA (seção Parada entre fases de
> `templates/bloco-fechamento-template.md`) e no autopilot quando o motor
> recusa a rodada. A sessão principal preenche `{{FASE}}`, `{{ID}}` e
> `{{TAREFA}}` e despacha UM subagente (ferramenta Agent) com o texto abaixo.

```text
Você é um subagente de contexto zerado rodando {{FASE}} de {{ID}} no framework audora-commander.
1. Invoque a skill {{FASE}} e reancore só pelos artefatos em disco: MEMORY.md, docs/audora/memory/{{ID}}.md, docs/audora/planos/plano-{{ID}}.md e os relatórios citados no nó. Nada da conversa anterior existe para você.
2. Faça só {{FASE}}{{TAREFA}}. Não emende outra fase.
3. NUNCA aprove portão: prepare o material; o portão é apresentado na sessão principal, ao humano.
4. Precisa de input humano (requisito faltante, [PRECISA-CLARIFICAR: ...], falha irrecuperável) → pare e devolva a pergunta ou o diagnóstico. Nunca suponha a resposta.
5. Ao terminar, devolva SÓ o bloco de fechamento da fase (formato de templates/bloco-fechamento-template.md).
```

Regras da sessão principal:
- `{{TAREFA}}` vazio para a fase inteira; no fallback do motor, ` — tarefa <n>`: uma tarefa por subagente, em ordem de `depende-de`.
- Subagente devolveu pergunta → perguntar ao humano, registrar a resposta no nó e redespachar.
- Bloco devolvido com portão (plano HIGH, portão final da validate) → apresentar aqui e ESPERAR a decisão explícita.
~~~

- [ ] **4. Rodar e ver passar** — `bash tests/test-contexto-por-fase.sh; echo "exit=$?"` → `PASS=20 FAIL=0`, `exit=0`.
- [ ] **5. Commit** — `git add templates/fase-subagente-template.md tests/test-contexto-por-fase.sh && git commit -m "feat(contexto-por-fase/5,6,7,8): template do subagente de fase"`.

## Tarefa 3: scope e plan param; plan recusa retomada sem escopo

- **depende-de**: [1]
- **requisito**: **contexto-por-fase/1** e **/13** (verbatim na Tarefa 1); **contexto-por-fase/9** — QUANDO o comando de retomada cita id inexistente ou fase fora de ordem (ex.: `execute de <id>` MEDIUM sem plano-arquivo) O SISTEMA DEVE recusar nomeando o artefato que falta e apontar a fase certa.
- **decisões relevantes**: retomada pelo comando impresso (lote 1); autopilot emenda (scope item 7 já cobre; plan item 9 ganha a exceção).
- **interfaces**: consome `sec` (Tarefa 1) e a seção de parada; produz frases `PARADA: rode /clear` em scope e plan.
- **arquivos**:
  - Modificar: `skills/scope/SKILL.md` (item 8), `skills/plan/SKILL.md` (itens 1 e 9), `tests/test-skills.sh` (linha 199)
  - Teste: `tests/test-contexto-por-fase.sh`
- **done quando**: bloco `/1 /9 /13` de scope/plan verde; `test-skills.sh` verde.

Passos:

- [ ] **1. Escrever teste que falha** — inserir antes de `report`:

~~~bash
# --- /1 /9 /13 — scope e plan param; plan recusa retomada sem escopo ---
for s in scope plan; do
  k="$(tr -d '\r' < skills/$s/SKILL.md)"
  assert_contains "$k" 'PARADA: rode /clear' "/1 $s instrui a parada"
  assert_not_contains "$k" 'Recomendo /clear' "/13 $s não volta a só recomendar"
done
assert_contains "$(tr -d '\r' < skills/scope/SKILL.md)" 'na sessão nova: `plan de <id>`' "/1 scope imprime a retomada"
assert_contains "$(tr -d '\r' < skills/plan/SKILL.md)" 'na sessão nova: `execute de <id>`' "/1 plan imprime a retomada"
assert_contains "$(tr -d '\r' < skills/plan/SKILL.md)" 'recusar nomeando o que falta' "/9 plan recusa retomada sem escopo"
~~~

  E em `tests/test-skills.sh`, linha 199 (1:1):

~~~bash
for s in scope plan; do assert_contains "$(cat skills/$s/SKILL.md)" 'PARADA: rode /clear' "contexto-por-fase/1 $s para (substitui otimizacao-tokens/4)"; done
~~~

- [ ] **2. Rodar e ver falhar** — `bash tests/test-contexto-por-fase.sh; echo "exit=$?"` → 7 FAIL novos, `exit=1`; `bash tests/test-skills.sh` → 2 FAIL.
- [ ] **3. Implementar** —
  - `skills/scope/SKILL.md` item 8, citação vira (3 linhas):
    `> Fase de escopo fechada. Artefatos salvos: [nó/spec].` /
    `> PARADA: rode /clear e, na sessão nova: \`plan de <id>\`.` /
    `> Não comece o plano nesta resposta (seção Parada entre fases do template de fechamento).`
  - `skills/plan/SKILL.md` item 9, citação vira:
    `> Fase de plano fechada. Artefato salvo: docs/audora/planos/plano-<id>.md.` /
    `> PARADA: rode /clear e, na sessão nova: \`execute de <id>\`.` /
    `> Em autopilot, sem parada: seguir para a execute (motor).`
  - `skills/plan/SKILL.md` item 1, somar a frase: `Retomada (\`plan de <id>\`) com id fora do índice ou nó sem critérios aprovados → recusar nomeando o que falta e voltar ao scope.`
- [ ] **4. Rodar e ver passar** — `bash tests/test-contexto-por-fase.sh` → `FAIL=0`; `bash tests/test-skills.sh` → `FAIL=0`.
- [ ] **5. Commit** — `git add skills/scope/SKILL.md skills/plan/SKILL.md tests/test-skills.sh tests/test-contexto-por-fase.sh && git commit -m "feat(contexto-por-fase/1,9,13): scope e plan fecham com PARADA"`.

## Tarefa 4: execute — parada, LIGHT emenda, autopilot pelo motor

- **depende-de**: [1, 2]
- **requisito**: **contexto-por-fase/1**, **/3**, **/9** (verbatim acima) e:
  - **contexto-por-fase/10** — QUANDO a demanda MEDIUM está em autopilot elegível O SISTEMA DEVE percorrer scope → plan → execute → validate sem parada, rodando a execute pelo motor de loop (`hooks/loop <id>`).
  - **contexto-por-fase/11** — QUANDO, em autopilot, o motor recusa a rodada por pré-condição faltando O SISTEMA DEVE avisar em 1 linha o que faltou e rodar a execute em subagente(s) de contexto zerado, seguindo o autopilot sem parada.
- **decisões relevantes**: fallback = uma tarefa por subagente (decisão IA); só a recusa de pré-condição (`LOOP: rodada recusada`, exit 1) cai no fallback — parada normal do motor (DONE, vermelhos, teto) segue o fluxo do motor.
- **interfaces**: consome o template da Tarefa 2 e a frase `LOOP: rodada recusada` de `hooks/loop` (linha 73); produz a seção `## Autopilot MEDIUM (motor)`.
- **arquivos**:
  - Modificar: `skills/execute/SKILL.md` (item 1, seção nova após "Volta de loop", Próximo do bloco)
  - Teste: `tests/test-contexto-por-fase.sh`
- **done quando**: bloco `/1 /3 /9 /10 /11` da execute verde.

Passos:

- [ ] **1. Escrever teste que falha** — inserir antes de `report`:

~~~bash
# --- /1 /3 /9 /10 /11 — execute: parada, LIGHT emenda, autopilot pelo motor ---
ex="$(tr -d '\r' < skills/execute/SKILL.md)"
bf="$(sec skills/execute/SKILL.md '## Bloco de fechamento')"
assert_contains "$bf" 'PARADA: rode /clear e, na sessão nova: `validate de <id>`' "/1 execute MEDIUM/HIGH para"
assert_contains "$bf" 'LIGHT/HOTFIX → validate na mesma sessão' "/3 LIGHT/HOTFIX emendam"
ap="$(sec skills/execute/SKILL.md '## Autopilot MEDIUM (motor)')"
assert_contains "$ap" 'hooks/loop" <id>' "/10 autopilot roda o motor"
assert_contains "$ap" 'LOOP: rodada recusada' "/11 reconhece a recusa do motor"
assert_contains "$ap" 'uma tarefa por subagente' "/11 fallback em subagentes limpos"
assert_contains "$ex" 'sem plano-arquivo → recusar nomeando o que falta' "/9 execute recusa retomada sem plano"
# contrato: a frase que a skill espera existe no motor (passa já no red)
assert_contains "$(tr -d '\r' < hooks/loop)" 'LOOP: rodada recusada' "/11 motor imprime a recusa esperada"
~~~

- [ ] **2. Rodar e ver falhar** — `bash tests/test-contexto-por-fase.sh; echo "exit=$?"` → 6 FAIL novos (o assert de contrato passa), `exit=1`.
- [ ] **3. Implementar** — em `skills/execute/SKILL.md`:
  - item 1: `MEDIUM/HIGH sem plano-arquivo → volte à skill plan.` → `MEDIUM/HIGH sem plano-arquivo → recusar nomeando o que falta e voltar à skill plan.`
  - após a seção `## Volta de loop (motor \`hooks/loop\`)`, seção nova:

~~~markdown
## Autopilot MEDIUM (motor)

Nó MEDIUM com `autopilot: elegivel` → a execute roda pelo motor, sem parada: `bash "<raiz do plugin>/hooks/loop" <id>` (em background; ler a saída inteira). Saída com `LOOP: rodada recusada` → avisar em 1 linha o que faltou e rodar as tarefas em subagentes de contexto zerado, uma tarefa por subagente, pelo `templates/fase-subagente-template.md` — o autopilot segue. Rodada terminada → validate na mesma sessão.
~~~

  - bloco de fechamento, `- **Próximo**: validate (que oferece o e2e antes do portão).` → `- **Próximo**: MEDIUM/HIGH → PARADA: rode /clear e, na sessão nova: \`validate de <id>\`; LIGHT/HOTFIX → validate na mesma sessão (sem parada).`
- [ ] **4. Rodar e ver passar** — `bash tests/test-contexto-por-fase.sh` → `FAIL=0`; `bash tests/test-skills.sh` → `FAIL=0` (execute ≤ 250 linhas).
- [ ] **5. Commit** — `git add skills/execute/SKILL.md tests/test-contexto-por-fase.sh && git commit -m "feat(contexto-por-fase/1,3,9,10,11): execute para, LIGHT emenda, autopilot pelo motor"`.

## Tarefa 5: Carga BASE dentro do teto

- **depende-de**: [1, 3, 4]
- **requisito**: guarda de `otimizacao-tokens/7` (teto de bytes da carga MEDIUM) segue verde — texto novo não incha a carga em silêncio.
- **decisões relevantes**: "Subir teto só com motivo no nó" (`tests/test-carga.sh`).
- **interfaces**: consome as edições das Tarefas 1, 3 e 4.
- **arquivos**: Modificar (só se preciso): `tests/test-carga.sh`, `templates/bloco-fechamento-template.md`.
- **done quando**: `bash tests/test-carga.sh` → `FAIL=0`.

Passos:

- [ ] **1. Medir** — `bash tests/test-carga.sh; echo "exit=$?"` → ler `carga MEDIUM (bytes): base=… full=…`. `base ≤ 54900` → pular para o passo 4.
- [ ] **2. Enxugar primeiro** — acima do teto: cortar redundância no template de fechamento (prosa que repete a seção de parada) e medir de novo.
- [ ] **3. Subir teto só com motivo** — ainda acima: `TETO_BASE` = `base` medido + 3%, arredondado para cima em centenas; comentário no `tests/test-carga.sh` citando `contexto-por-fase` e o motivo (texto de parada troca ~bytes estáticos por corte de contexto por fase); registrar em "Decisões tomadas pela IA" deste plano para o portão.
- [ ] **4. Verde** — `bash tests/test-carga.sh; echo "exit=$?"` → `FAIL=0`, `exit=0`.
- [ ] **5. Commit** (se algo mudou) — `git add tests/test-carga.sh templates/bloco-fechamento-template.md && git commit -m "chore(contexto-por-fase): carga BASE medida após a parada"`.

## Tarefa 6: Docs descrevem a parada (READMEs EN/PT, fundamentos)

- **depende-de**: [1]
- **requisito**: **contexto-por-fase/1** e **/13** (verbatim na Tarefa 1) — a documentação viva não pode continuar prometendo "/clear recomendado".
- **decisões relevantes**: README principal em inglês, PT linkado; blocos de código idênticos EN/PT (`test-docs.sh`) — só prosa muda.
- **interfaces**: nenhuma.
- **arquivos**:
  - Modificar: `README.md`, `README.pt-BR.md` (Next/Próxima de scope, plan, execute), `docs/fundamentos.md` (P3 regra 6)
  - Teste: `tests/test-contexto-por-fase.sh`
- **done quando**: bloco de docs verde; `test-docs.sh` sem FAIL novo.

Passos:

- [ ] **1. Escrever teste que falha** — inserir antes de `report`:

~~~bash
# --- /1 /13 — docs descrevem a parada (READMEs EN/PT e fundamentos) ---
en="$(tr -d '\r' < README.md)"; pt="$(tr -d '\r' < README.pt-BR.md)"
assert_contains "$en" 'after a STOP' "/1 README EN descreve a parada"
assert_contains "$pt" 'depois de uma PARADA' "/1 README PT descreve a parada"
assert_not_contains "$en" '`/clear` recommended' "/13 README EN sem recomendação solta"
assert_not_contains "$pt" '`/clear` recomendado' "/13 README PT sem recomendação solta"
assert_contains "$(tr -d '\r' < docs/fundamentos.md)" 'a skill PARA e não emenda a fase seguinte' "/1 fundamentos P3 regra 6"
~~~

- [ ] **2. Rodar e ver falhar** — `bash tests/test-contexto-por-fase.sh; echo "exit=$?"` → 5 FAIL novos, `exit=1`.
- [ ] **3. Implementar** —
  - README.md, scope: `- **Next**: \`plan\`, after a STOP — you run \`/clear\` and type \`plan de <id>\`; saying "segue" runs it in a clean-context subagent instead.` · plan: `- **Next**: \`execute\`, after a STOP (\`execute de <id>\`).` · execute: `- **Next**: \`validate\`, which offers the e2e — after a STOP in MEDIUM/HIGH; LIGHT/HOTFIX go straight on.`
  - README.pt-BR.md, scope: `- **Próxima**: \`plan\`, depois de uma PARADA — você roda \`/clear\` e digita \`plan de <id>\`; dizer "segue" roda a fase num subagente de contexto limpo.` · plan: `- **Próxima**: \`execute\`, depois de uma PARADA (\`execute de <id>\`).` · execute: `- **Próxima**: \`validate\`, que oferece o e2e — depois de uma PARADA em MEDIUM/HIGH; LIGHT/HOTFIX seguem direto.`
  - docs/fundamentos.md, P3 regra 6 vira: `6. **Fim de fase é PARADA; \`/clear\` é do humano**: ao fechar scope, plan ou execute de MEDIUM/HIGH, a skill PARA e não emenda a fase seguinte — imprime "PARADA: rode /clear e, na sessão nova: \`<fase> de <id>\`". "Segue" sem /clear roda a fase seguinte em subagente de contexto zerado.` (mantém a frase seguinte sobre notas de sessão).
- [ ] **4. Rodar e ver passar** — `bash tests/test-contexto-por-fase.sh` → `FAIL=0`; `bash tests/test-docs.sh` → só os 5 FAIL pré-existentes do `.claude-plugin/` (ou 0, se restaurado).
- [ ] **5. Commit** — `git add README.md README.pt-BR.md docs/fundamentos.md tests/test-contexto-por-fase.sh && git commit -m "docs(contexto-por-fase/1,13): READMEs e fundamentos descrevem a PARADA"`.

## Tarefa 7: Gate da demanda e prova por mutação

- **depende-de**: [1, 2, 3, 4, 5, 6]
- **requisito**: **contexto-por-fase/13** (verbatim na Tarefa 1) — o guarda morde de verdade.
- **decisões relevantes**: gate da Constituição; aprendizados 2026-08-31 (exit real, não do `tail`; commitar antes do teste negativo).
- **interfaces**: nenhuma.
- **arquivos**: nenhum novo (mutação é temporária, restaurada do commit).
- **done quando**: mutação reprova; gate sai 0.

Passos:

- [ ] **1. Mutação** — `sed -i 's/PARADA: rode \/clear/Recomendo \/clear/' skills/plan/SKILL.md; bash tests/test-contexto-por-fase.sh > "$TEMP/mut.log" 2>&1; echo "exit=$?"` → `exit=1` com `FAIL: /1 plan instrui a parada` e `FAIL: /13 plan não volta a só recomendar`.
- [ ] **2. Restaurar** — `git checkout skills/plan/SKILL.md` (já commitado na Tarefa 3) e rodar de novo → `FAIL=0`.
- [ ] **3. Gate** — `bash hooks/gate contexto-por-fase > "$TEMP/gate.log" 2>&1; echo "exit=$?"` → `exit=0` e `GATE: passou` (exige `.claude-plugin/` restaurado).
- [ ] **4. Total de asserts somado da saída real** — `bash tests/run.sh 2>&1 | grep -o 'PASS=[0-9]*' | cut -d= -f2 | awk '{s+=$1} END{print s}'` → linha de base 741 + 39 do arquivo novo = 780 (mesma contagem nos arquivos antigos).
- [ ] **5. Sem commit** — só evidência para a validate.
