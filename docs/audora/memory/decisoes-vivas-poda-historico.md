# decisoes-vivas-poda — histórico frio

> Achados completos da revisão adversarial de 2026-09-01, movidos do nó
> pelo teto de ~100 linhas (`memory-guard`). O delta do nó tem a ação; aqui
> fica o diagnóstico.

## feedback-reprovacao

Revisão adversarial (2026-09-01, subagente de contexto limpo) reprovou. Os 4
achados verificados de novo por mim, um a um:

**Execução — guardas fajutos (/6, /7):**
- D1: `grep '^- 20' "$dv" || true` sem `assert_file` — o arquivo inteiro pode
  SUMIR e os guardas dão `PASS=203 FAIL=0`. Reproduzido.
- D2: `[substituido-por: ]` vazio escapa dos dois: /6 grepa a palavra nua, e o
  `for ref in $(...)` descarta token vazio. Reproduzido.
- D3: /6 grepa `invalidado-em`/`substituido-por` como palavra solta, não o
  marcador entre colchetes.
- D5: `[ -e "$ref" ]` aceita diretório; devia ser `[ -f ]`.
- D6: `$(...)` sem aspas quebra em caminho com espaço.

**Execução — ponteiros errados (/3):**
- B1: `corte de tokens é estimativa, medir se doer` foi marcada como cumprida
  apontando o nó `memory-fatiada` — mas ele diz, na linha 68, "/9 mede esta
  skill, NÃO o framework". O item segue ABERTO; a marcação o enterrou.
- B2: PT→EN aponta `comandos-ingles`, que é quem CRIOU a regra. /3 exige
  apontar o que a tornou obsoleta (a remoção do GRAFO na 0.4.0).

**Execução — /4 quebrado:**
- C1: `debug é skill-ferramenta (como grafo)` está morta e contradita
  (`test-skills.sh:99` lista `debug` entre as 7 skills de FASE; `debug/SKILL.md`
  tem bloco de fechamento; "como grafo" cita skill deletada). Devia ter sido
  marcada e ficou intocada.

**Escopo — reabertura necessária:**
- B3: /1 diz "teste, hook ou config", mas 2 entradas foram marcadas apontando
  `skills/e2e/SKILL.md`, que é PROSA sem teste que a cubra. Ou o critério
  admite "skill normativa", ou essas 2 não podiam ser marcadas.
- C2: seletividade — `roteador + references` tem MAIS superfície de teste
  (`test-skills.sh:11-13` e `:76-77`) que `description em aspas simples`, que
  foi marcada. O critério precisa dizer onde é a linha.
- E1: a regra nova diz "o lugar dela é o teste" e não manda ESCREVER o teste —
  decisão que poderia virar teste some da memória e não cai em lugar nenhum.

**Frente A limpa:** `diff` do original contra a versão atual com os sufixos
removidos deu VAZIO — nenhuma linha apagada, reordenada ou alterada. /2 está
atendido.


## Segunda revisão adversarial (2026-09-01) — reprovada de novo

**Fechados da 1ª rodada, confirmados por mutação:** D1, D2, D3, D4, D5, D6,
B1, C2, E1, /2. Baseline `PASS=210 FAIL=0`.

**Achados altos novos:**
- **N1 (regressão minha)**: a âncora `[invalidado-em: 20` que fechou o D4 abriu
  este — marcador com data não-`20xx` escapa do guarda INTEIRO.
  `[invalidado-em: hoje]` sem `substituido-por` → `PASS=210 FAIL=0`. A linha do
  próprio rodapé, copiada literal, também passa.
- **N2**: as 3 decisões de `skill-worktree` ficaram intocadas, mas têm 6 asserts
  em `tests/test-worktree.sh` — MAIS cobertura que o par `e2e` que foi marcado.
  A regra de "mesmo escopo" não discrimina os dois grupos.
- **N3**: `Placeholders <...> traduzem` está morta e contradita e ficou
  intocada — `tests/test-docs.sh:23` força os blocos EN/PT byte-idênticos (md5
  confirmado igual), e o único placeholder aparece não-traduzido nos dois.
  Traduzir deixaria a suíte vermelha. Mesma classe do C1.

**Médios:** N5 (asserts do e2e cortam antes da parte que sustenta a decisão),
N6 (ponteiro da `debug` cobre só metade — "dois modos" segue vivo e sem teste),
N7 (ponteiro do PT→EN não declara nada e o rabo da decisão vale além),
N4 (troquei o ponteiro dos identificadores EN por um mais fraco).

**Diagnóstico:** o critério "já declarada normativamente" não é operável —
duas rodadas, dois conjuntos diferentes de erro de classificação. A
infraestrutura (regra na validate + guardas) fechou; a AUDITORIA não.
