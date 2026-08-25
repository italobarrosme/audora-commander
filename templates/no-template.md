---
id: exemplo-login
estado: planned
origem: humano
depende-de: []
arquivos: []
keywords: [auth, login, sessao]
resumo: Usuário entra com e-mail e senha para acessar a área logada.
atualizado-em: 2026-08-24
---

# exemplo-login

<!-- Frontmatter: 1 campo = 1 linha — consultável por grep puro, sem parser.
     estados: planned | in-progress | blocked | delivered | discarded
       (+ hotfix-pending-record, transitório)
     Migração de estado PT→EN (skill graph, primeira escrita no projeto —
       converte TODOS: índice, nos/, arquivo/, GRAFO-ARQUIVO.md, inline):
       planejada→planned | em-curso→in-progress | bloqueada→blocked |
       entregue→delivered | descartada→discarded |
       hotfix-pendente-registro→hotfix-pending-record
     origem: humano | inferido (inferido NÃO vale como verdade até o humano
       confirmar)
     depende-de: lista de ids; sintaxe `chave:id` reservada (federação futura)
     arquivos: paths/globs tocados pela demanda — preenchido no sync da validate
       via `git diff --name-only`, nunca de memória
     keywords + resumo: espelham a linha do índice mestre (mesma edição) -->

## objetivo

Usuário entra no sistema com e-mail e senha para acessar a área logada.

## criterios-aceite

<!-- Numerados: endereço estável `<id>/<n>`, citado em teste, commit,
     relatório e2e e roteiro de validação. Número nunca é reutilizado. -->

- **exemplo-login/1** — QUANDO o usuário submete e-mail e senha válidos O
  SISTEMA DEVE redirecionar para o painel com sessão criada
- **exemplo-login/2** — QUANDO o usuário submete senha incorreta O SISTEMA
  DEVE exibir erro genérico sem revelar qual campo falhou
- **exemplo-login/3** — QUANDO o usuário erra a senha 5 vezes seguidas O
  SISTEMA DEVE bloquear novas tentativas por 15 minutos

## fora-de-escopo

login social; recuperação de senha (nó próprio).

## decisoes

- 2026-08-24 (humano): sessão via cookie httpOnly, não localStorage.

<!-- Decisão superada NUNCA é apagada — anexar à linha:
     `[invalidado-em: AAAA-MM-DD] [substituido-por: <no-id ou decisão nova>]` -->

## delta

<!-- Append-only durante a demanda; consolidado no corpo pela skill validate
     no sync pós-merge — nunca antes:
     - ADICIONADO (AAAA-MM-DD): <novo requisito>
     - MODIFICADO (AAAA-MM-DD): <antes → depois>
     - REMOVIDO (AAAA-MM-DD): <requisito + motivo> -->

## e2e

pendente
<!-- pendente | relatorio: ../e2e/e2e-<id>.md | pulado-pelo-humano -->

## feedback-reprovacao

<!-- preenchido se o portão final reprovar -->

<!-- Teto: ~100 linhas por arquivo de nó. Excedeu por histórico frio (delta e
     decisões antigas consolidados)? Mover o frio para `<id>-historico.md`
     (mesma pasta — caminho relativo a este arquivo) e deixar ponteiro de
     1 linha aqui. -->
