---
id: decisoes-vivas-poda
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [decisoes-vivas, poda, duplicacao, drift, regra-de-entrada]
resumo: Regra de entrada nova para decisoes-vivas.md (so entra o que nao da pra impor por teste/hook/config) e poda das entradas ja impostas ou mortas.
atualizado-em: 2026-09-01
---

# decisoes-vivas-poda

## objetivo

`docs/audora/decisoes-vivas.md` tem 17 entradas e cerca de metade e copia em
prosa de algo ja imposto por teste, hook ou config, ou esta morta (fala de uma
migracao removida na 0.4.0). O furo e a regra de entrada: o arquivo exige
"decisao que segue valendo", mas nao exige "decisao que NAO da pra impor por
teste". Prosa duplicada deriva do que ela descreve.

Escopo em spec dedicada (categoria HIGH): `docs/audora/specs/decisoes-vivas-poda-escopo.md`.

## criterios-aceite

<!-- Em docs/audora/specs/decisoes-vivas-poda-escopo.md (HIGH). -->

## fora-de-escopo

<!-- Na spec. -->

## decisoes

## delta

## e2e

pendente

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
