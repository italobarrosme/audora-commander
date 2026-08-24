---
name: e2e
description: Use quando a execução de uma demanda terminar com testes verdes e for hora de validar de ponta a ponta — levantar o projeto de verdade (docker compose como infra default) e exercitar a demanda como usuário real (Playwright default para web). Opcional, fortemente recomendada.
---

# e2e — a demanda rodando de verdade

```
LEI DE FERRO: EVIDÊNCIA E2E VEM DO PRODUTO RODANDO, NUNCA DE SAÍDA DE TESTE DE UNIDADE
```

**Anuncie ao começar:** "Usando e2e para exercitar [demanda] de ponta a ponta."

Teste de unidade verde prova a peça; não prova o produto. Esta skill levanta o
projeto e percorre a demanda como o usuário final percorreria — a evidência
mais próxima do que o humano vai validar no portão.

Opcional por decisão do humano; recomendada com força. Recusa é registrada no
nó: `e2e: pulado-pelo-humano`. Nada de pular em silêncio.

## Fluxo

1. **Infra do teste — ordem de decisão** (docker compose é o default):
   - Projeto TEM docker compose (`docker-compose*.yml` / `compose*.yml`) →
     usar como infra do e2e. Compose de e2e dedicado existente
     (`docker-compose.e2e.yml`) tem prioridade sobre o compose geral.
   - NÃO tem → **gerar** `docker-compose.e2e.yml` na raiz do projeto a partir
     da stack/Constituição do GRAFO (app + banco + dependências), pelo
     esqueleto de `templates/e2e-infra-template.md` (raiz do plugin). Artefato
     é versionado no projeto — entra no commit da demanda.
   - Docker indisponível na máquina (`docker compose version` falha) →
     avisar o humano EXPLICITAMENTE e cair para o `como-rodar` da
     Constituição. `como-rodar` ausente ou quebrado → perguntar UMA vez e
     registrar na Constituição (skill grafo) — memória durável.
2. **Levantar e confirmar**: subir a infra
   (`docker compose -f docker-compose.e2e.yml up -d --wait`, ou o
   `como-rodar` em background com log capturado). Confirmar que subiu de
   verdade (porta respondendo, healthcheck ok, log de pronto) antes de
   testar. **Falhou ao subir** (porta ocupada, imagem indisponível, serviço
   unhealthy) → reportar o LOG do erro ao humano e perguntar: corrigir,
   fallback para o como-rodar, ou abortar o e2e. NUNCA seguir com infra
   parcial — evidência sobre metade da infra é evidência mentirosa.
3. **Ferramenta de exercício**, pela natureza da demanda:
   - **Web (tem interface no browser)** → **Playwright é o default**: specs
     em `e2e/` no projeto-alvo. Projeto já tem infra de e2e (Playwright,
     Cypress...) → estender o padrão existente, nunca criar paralelo. Sem
     infra → bootstrap mínimo (config + spec da demanda) pelo esqueleto do
     template.
   - **Não-web (API pura, CLI, worker)** → **perguntar ao humano qual
     ferramenta usar** — nunca escolher sozinho. Registrar a escolha na
     Constituição (skill grafo): pergunta única por projeto, sessões futuras
     leem de lá.
4. **Traduzir critérios em passos**: cada critério EARS do nó
   (`QUANDO <condição> O SISTEMA DEVE <comportamento>`) vira um passo
   executável na ferramenta escolhida — navegar/clicar/ler tela (web),
   montar condição/disparar/ler resposta (API), invocar binário com args
   (CLI). Incluir os critérios de ERRO — eles são metade do valor do e2e.
5. **Executar e coletar evidência** por critério: screenshot ou assert de
   tela (web), resposta crua (API), saída de terminal (CLI). Evidência é o
   que foi visto, não o que deveria acontecer.
6. **Relatório** em `docs/audora/e2e/e2e-<id>.md`:

   | Critério (`<id>/<n>` + EARS) | Passo executado | Evidência | Veredito |
   |---|---|---|---|

   Veredito por critério: `passou` / `falhou` / `não-automatizável` (vai para
   validação humana manual). Critério `falhou` → skill depurar (modo sintoma;
   o passo do e2e já é a reprodução pronta), fix via executar.
7. **Persistir como regressão — artefatos são versionados**: o compose de
   e2e e as specs geradas ficam commitados no projeto-alvo junto da demanda.
   Demanda futura estende os artefatos existentes em vez de recriar do zero
   — cada e2e deixa regressão acumulada, não lixo descartável.
8. **Teardown SEMPRE** — sucesso ou falha: derrubar o que foi levantado
   (`docker compose -f docker-compose.e2e.yml down`, ou matar o processo do
   como-rodar). Servidor órfão de sessão anterior é armadilha para a próxima.

## O que esta skill NÃO é

- Não substitui os testes da executar — complementa. Unidade/integração
  provam por dentro; e2e prova por fora.
- Não é suíte completa de regressão do produto — é o corte E2E DA DEMANDA
  atual. Rodar a suíte inteira é decisão do projeto, não desta skill.
- Não instala Docker nem Playwright na máquina do humano — pré-requisitos
  ausentes geram aviso e fallback, nunca instalação silenciosa.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "Unidade verde já prova que funciona" | Prova a peça. Produto é peças montadas. Rode o produto. |
| "Rodo o e2e no final do projeto, junto tudo" | Final = 10 demandas misturadas e bug sem dono. E2e é por demanda. |
| "Testo só o caminho feliz, erro é paranoia" | Critério de erro é critério. Sem evidência, não passou. |
| "Metade da infra subiu, testo o que der" | Infra parcial = evidência mentirosa. Log + pergunta, ou aborta. |
| "Não é web, uso curl que é óbvio" | Óbvio pra você ≠ escolhido por ele. Ferramenta não-web é decisão do humano, registrada. |
| "Recrio o compose/spec, tá mais limpo" | Recriar joga fora regressão acumulada. Estenda o que existe. |
| "Deixo o server rodando pra próxima" | Órfão de porta ocupada quebra a próxima sessão. Teardown sempre. |
| "Pulo o e2e sem avisar, ganho tempo" | Pular é direito do humano, não seu. Ofereça, registre a escolha. |

## PRÓXIMA SKILL

Relatório pronto (ou pulo registrado) → **validar**, com o relatório anexado
ao roteiro de validação.
