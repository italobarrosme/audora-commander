---
name: audora-commander
description: 'Use quando chegar qualquer demanda de software (criar, alterar, corrigir, refatorar) — porta de entrada do framework: classifica a demanda por risco e roteia para a fase certa. Invoque ANTES de agir na demanda.'
---

# audora-commander — porta de entrada

```
LEI DE FERRO: NA DÚVIDA ENTRE DUAS CATEGORIAS, A MAIS PESADA
```

**Anuncie ao começar:** "Usando audora-commander para classificar [demanda]."

Processo é proporcional ao RISCO, não ao tamanho do diff. Bug de uma linha não
paga cerimônia de arquitetura; migração de banco não passa sem portões. Esta
skill decide quanto processo a demanda paga — e nada além dela decide isso.

**Override do humano**: instrução direta do usuário vale mais que o framework.
"Sem processo, só responde/faz" é atendido sem insistência e sem culpa.

## Fluxo

1. **Contexto**: skill `memory`, operação carregar-contexto (Constituição +
   Aprendizados + índice de nós). MEMORY ausente → oferecer bootstrap antes
   de qualquer outra coisa (memória de versão anterior do framework sem
   `MEMORY.md` → a skill memory avisa que não é mais lida e oferece o
   bootstrap). Nunca seguir sem MEMORY, nunca inventar um.
2. **Concorrência**: nós `in-progress` no índice ≥ 3 e chegando demanda nova →
   listar os abertos e perguntar: pausar qual, continuar qual, abandonar qual.
   Só então seguir.
3. **Classificar** — perguntas binárias, NESTA ordem:
   1. Toca migração ou dado persistido?
   2. Toca API pública / contrato consumido por terceiros?
   3. Toca auth, segurança ou pagamento?
   4. Tem efeito irreversível fora do repo? (irreversível = `git revert` não
      desfaz: migração executada, e-mail enviado, cobrança, dado apagado,
      deploy público)
   - Qualquer **SIM** → **HIGH**.
   - Nenhum sim, mas múltiplos arquivos OU lógica nova → **MEDIUM**.
   - Resto (ajuste localizado, comportamento existente) → **LIGHT**.
   - **HOTFIX**: SOMENTE se o humano declarar emergência ("produção caiu",
     "hotfix"). Você NUNCA seleciona HOTFIX sozinho.
4. **Anunciar**: "Demanda classificada como [X] porque [respostas às
   perguntas] — me corrija se discordar." Correção do humano vale na hora.
5. **Registrar o nó** da demanda no MEMORY (skill `memory`, registrar-no):
   estado `in-progress`, objetivo em 1 frase. MEDIUM/HIGH: critérios ficam
   para o escopo. LIGHT/HOTFIX (sem escopo): incluir já ≥1 critério EARS
   numerado (`<id>/1`...) derivado da demanda — execute e validate citam
   esses endereços.
6. **Rotear** pela tabela:

| Categoria | Fases (skills, em ordem) | Portões humanos |
|---|---|---|
| LIGHT | execute → validate | resultado |
| MEDIUM | scope → plan → execute → [e2e] → validate | escopo, resultado |
| HIGH | scope → plan → execute → [e2e] → validate | escopo, plano, resultado |
| HOTFIX | execute → validate (registro retroativo) | diff + evidência (único) |

`[e2e]` = opcional, oferecido SEMPRE pela validate com recomendação forte.

## Regras de categoria

- **HOTFIX**: pula scope e plan, mas exige teste que reproduz o defeito
  ANTES do fix (skill execute cobra). Portão único: diff + evidência. Nó
  fica `hotfix-pending-record` até a sessão seguinte regularizar o
  registro no MEMORY — dívida declarada, não esquecida.
- **Catraca de mão única**: complexidade descoberta no meio (a MEDIUM tocou
  migração, a LIGHT virou lógica nova) → SUBIR categoria automaticamente e
  avisar o humano. DESCER categoria → só com aprovação explícita dele.
- **Demanda gigante**: pedido com vários subsistemas independentes → não
  classifique como uma coisa só; proponha decompor em demandas menores e
  classifique cada uma.

## Red flags — pare e reclassifique

| Racionalização | Realidade |
|---|---|
| "É só uma linha" | Uma linha em código de pagamento é HIGH. Risco, não tamanho. |
| "Classifico LIGHT pra ir mais rápido" | Rápido agora, retrabalho depois. As perguntas decidem, não a pressa. |
| "Já entendi o suficiente, pulo o escopo" | Entendeu = hipótese. Escopo escrito = verdade compartilhada. |
| "Processo aqui é exagero" | Se as perguntas deram LIGHT, o processo JÁ é mínimo. Se deram mais, tem motivo. |
| "O humano tá com pressa, declaro HOTFIX por ele" | HOTFIX é declaração DELE. Pressa sua não é emergência dele. |
| "Tá no meio, desce de HIGH pra MEDIUM que anda mais" | Catraca desce só com o humano. Suba sozinho, desça nunca. |

## Bloco de fechamento

Ao terminar, imprima no terminal o bloco de fechamento pelo formato canônico
de `templates/bloco-fechamento-template.md` (raiz do plugin). Nesta fase:

- **Produzido**: a categoria (LIGHT/MEDIUM/HIGH/HOTFIX), as respostas de risco
  que a justificam em 1 linha, e o nó registrado.
- **Arquivos**: o arquivo do nó e a linha do índice em `MEMORY.md`.
- **Próximo**: a primeira fase da tabela de roteamento daquela categoria.

## PRÓXIMA SKILL

Roteamento da tabela acima: LIGHT/HOTFIX → **execute**; MEDIUM/HIGH →
**scope**. Bootstrap pendente → **memory** primeiro.
