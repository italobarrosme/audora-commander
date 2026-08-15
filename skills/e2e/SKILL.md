---
name: e2e
description: Use quando a execução de uma demanda terminar com testes verdes e for hora de validar de ponta a ponta — levantar o projeto de verdade e exercitar a demanda como usuário real. Opcional, fortemente recomendada.
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

1. **Como rodar**: ler `como-rodar` na Constituição do GRAFO. Ausente ou
   quebrado → perguntar ao humano UMA vez e registrar na Constituição (skill
   grafo) — memória durável, ninguém pergunta de novo.
2. **Levantar o projeto** em background (dev server, API, app). Confirmar que
   subiu de verdade (porta respondendo, log de pronto) antes de testar.
   Preferir as ferramentas de preview/servidor da sessão quando existirem;
   senão, processo em background com log capturado.
3. **Traduzir critérios em passos**: cada critério EARS do nó
   (`QUANDO <condição> O SISTEMA DEVE <comportamento>`) vira um passo
   executável, conforme o tipo de projeto:
   - **Web** → browser real (Playwright ou ferramentas de browser da sessão):
     navegar, clicar, preencher, ler a tela.
   - **API** → chamadas HTTP reais: montar a condição, disparar, ler resposta
     (status, corpo, headers).
   - **CLI** → invocações reais do binário/script com args da condição.
   Incluir os critérios de ERRO — eles são metade do valor do e2e.
4. **Executar e coletar evidência** por critério: screenshot (web), resposta
   crua (API), saída de terminal (CLI). Evidência é o que foi visto, não o
   que deveria acontecer.
5. **Relatório** em `docs/audora/e2e/e2e-<id>.md`:

   | Critério (EARS) | Passo executado | Evidência | Veredito |
   |---|---|---|---|

   Veredito por critério: `passou` / `falhou` / `não-automatizável` (vai para
   validação humana manual). Critério `falhou` → skill depurar (modo sintoma;
   o passo do e2e já é a reprodução pronta), fix via executar.
6. **Persistir como regressão**:
   - Projeto TEM infra de e2e (Playwright, Cypress, etc.) → salvar o cenário
     como teste permanente no padrão do projeto. Demanda futura ganha
     regressão de graça.
   - NÃO tem → oferecer bootstrap mínimo da infra (decisão do humano); se
     recusado, arquivar o script ad-hoc junto ao plano
     (`docs/audora/planos/arquivo/`).
7. **Teardown SEMPRE**: derrubar o que foi levantado — sucesso ou falha.
   Servidor órfão de sessão anterior é armadilha para a próxima.

## O que esta skill NÃO é

- Não substitui os testes da executar — complementa. Unidade/integração
  provam por dentro; e2e prova por fora.
- Não é suíte completa de regressão do produto — é o corte E2E DA DEMANDA
  atual. Rodar a suíte inteira é decisão do projeto, não desta skill.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "Unidade verde já prova que funciona" | Prova a peça. Produto é peças montadas. Rode o produto. |
| "Rodo o e2e no final do projeto, junto tudo" | Final = 10 demandas misturadas e bug sem dono. E2e é por demanda. |
| "Testo só o caminho feliz, erro é paranoia" | Critério de erro é critério. Sem evidência, não passou. |
| "Deixo o server rodando pra próxima" | Órfão de porta ocupada quebra a próxima sessão. Teardown sempre. |
| "Pulo o e2e sem avisar, ganho tempo" | Pular é direito do humano, não seu. Ofereça, registre a escolha. |

## PRÓXIMA SKILL

Relatório pronto (ou pulo registrado) → **validar**, com o relatório anexado
ao roteiro de validação.
