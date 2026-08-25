---
name: debug
description: 'Use quando houver bug, teste falhando por motivo desconhecido, comportamento inesperado ou critério de e2e reprovado — antes de propor qualquer correção. Sem sintoma específico, use o modo caçada para varrer o projeto atrás de defeitos.'
---

# debug — causa raiz antes de correção

```
LEI DE FERRO: NENHUMA CORREÇÃO SEM CAUSA RAIZ DEMONSTRADA
```

**Anuncie ao começar:** "Usando debug em modo [sintoma|caçada] para [alvo]."

Chute empilhado vira pântano: cada "mudo isso e vejo se resolve" adiciona uma
variável e esconde a causa. Este fluxo proíbe mexer no código antes de PROVAR
o que está errado. Dois modos: **sintoma** (há um defeito conhecido) e
**caçada** (não há sintoma — procurar defeitos sistematicamente).

## Modo sintoma

1. **Reproduzir determinístico.** Transformar o relato no menor caso que
   dispara o defeito sempre — de preferência um teste automatizado que falha
   (ele vira a regressão de graça). Não reproduz? Não avance: colete mais
   contexto (input exato, ambiente, sequência). "Acontece às vezes" ainda é
   coleta, não investigação.
2. **Evidência completa.** Ler a MENSAGEM DE ERRO INTEIRA e o stack trace até
   o fim. Ler o código do caminho que falha — o que ele faz, não o que você
   lembra que fazia. Diff recente (`git log -p` / `git diff`) se o defeito é
   novo: o que mudou desde que funcionava?
3. **Hipóteses — uma por vez.** Listar hipóteses ordenadas por probabilidade.
   Testar SÓ a mais provável, com o experimento mais barato que a
   distinguiria (log direcionado, teste isolado, bisseção do input, `git
   bisect`). Registrar resultado. Falhou → próxima hipótese. NUNCA testar
   duas mudando o código dos dois jeitos ao mesmo tempo.
4. **Causa raiz demonstrada.** A causa candidata deve explicar TODOS os
   sintomas observados. Sintoma órfão = causa errada ou segunda causa —
   continue. "O bug sumiu" sem explicação não é vitória: você perdeu a
   reprodução, não achou a causa.
5. **Corrigir via TDD** (skill execute): teste que reproduz (red, se ainda
   não existe) → fix mínimo → suíte TODA verde. O teste de reprodução fica
   permanente.
6. **Registrar aprendizado no nó** (skill graph): bug revelou requisito
   ausente → delta no GRAFO; revelou lacuna de teste → anotar a classe de
   lacuna nas decisões.

**Escalada:** 3 hipóteses testadas e refutadas → PARAR. Apresentar ao humano:
reprodução, hipóteses testadas, evidência de cada refutação. Padrão repetido
de fixes que não colam = problema de arquitetura, não de linha — isso sobe
para decisão humana, não para a 4ª tentativa.

## Modo caçada (sem sintoma)

Varredura por classes de defeito. Para CADA classe: enumerar alvos, checar
mecanicamente quando possível (grep, validação, execução real), e — regra de
ouro — **verificar cada achado contra o artefato real antes de reportar**.
Achado não verificado é fofoca, não bug.

Classes (adaptar ao tipo de projeto):

1. **Referências cruzadas**: nomes/caminhos citados existem? (skills citadas
   por nome, imports, rotas, links de docs, env vars usadas vs declaradas).
2. **Contratos e schemas**: artefatos obedecem seus templates/schemas
   declarados? (campos obrigatórios, enums, formatos, assinaturas entre
   produtor e consumidor).
3. **Contagens e documentação viva**: números e listas na documentação batem
   com a realidade? (README diz N itens, existem M; índice vs corpo;
   PRD/GRAFO vs estado real).
4. **Bordas de erro**: caminhos de falha têm tratamento e teste? (entrada
   inválida, ausência de arquivo/config, timeout, estado vazio).
5. **Configuração e execução**: o que é executável roda de verdade? (JSONs
   válidos, scripts executam, comandos documentados funcionam).

Relatório em `docs/audora/depuracao/cacada-<AAAA-MM-DD>.md`:

| # | Classe | Achado | Verificação (comando/leitura) | Veredito | Ação |
|---|---|---|---|---|---|

Veredito: `confirmado` / `falso-positivo` / `melhoria` (não é defeito — vira
nó `planned` se o humano quiser). Confirmados → corrigir via modo sintoma
(passos 4-6; a verificação da caçada já é a reprodução) — um commit por
correção. Caçada limpa = relatório com as classes varridas e zero confirmados,
provando O QUE foi checado.

## Red flags — pare e volte ao fluxo

| Racionalização | Realidade |
|---|---|
| "Sei o que é, nem preciso reproduzir" | Saber é hipótese. Reprodução é fato. Reproduza. |
| "Mudo isso aqui e vejo se resolve" | Isso é chute com deploy. Hipótese → experimento → evidência. |
| "Conserto os três suspeitos de uma vez" | Três variáveis mudadas = zero aprendizado. Um por vez. |
| "O bug sumiu sozinho, seguimos" | Sumiu = reprodução perdida. A causa continua lá, agora escondida. |
| "Trato o sintoma, a causa fica pra depois" | Sintoma tratado volta com outra roupa. Causa raiz ou nada. |
| "Na caçada, reporto tudo que parece estranho" | Achado sem verificação é ruído que queima confiança. Verifique antes. |

## PRÓXIMA SKILL

Causa raiz demonstrada → **execute** (fix via TDD). Achados da caçada
corrigidos/reportados → **validate** (ou registrar nós novos via **graph**).
Escalada → decisão humana.
