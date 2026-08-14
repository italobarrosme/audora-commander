versao-schema: 1

# GRAFO — <nome do projeto>

> Memória externa do produto. Requisito não escrito aqui é requisito que não
> existe. Atualizado por delta durante a demanda; sincronizado na validação.

## Propósito [carga: sempre]

<3-5 linhas: o que o produto faz, para quem, e o que o torna diferente.
Nada de detalhe técnico aqui — isso é a constituição.>

## Constituição [carga: sempre]

Princípios inegociáveis do projeto. Toda fase valida contra esta seção:
cumpre, ou documenta exceção no nó.

- **stack**: <linguagens, frameworks, banco — só o que é decisão firme>
- **restricoes**: <limites duros: versões mínimas, dependências proibidas,
  requisitos de plataforma>
- **padroes**: <convenções que o código segue: estilo, nomenclatura, camadas>
- **como-rodar**: <comando(s) exatos para subir o projeto localmente — usado
  pela skill e2e. Ex.: `npm run dev` na porta 3000>

## Índice de nós [carga: sempre]

Uma linha por nó ativo. Formato: `- <id> | <estado> | <título curto>`

- exemplo-login | planejada | Autenticação de usuário por e-mail e senha

## Nós [carga: auto — carregar somente os nós tocados pela demanda]

### exemplo-login

- **id**: exemplo-login
- **estado**: planejada
  <!-- estados válidos: planejada | em-curso | bloqueada | entregue | descartada
       (+ hotfix-pendente-registro, transitório) -->
- **origem**: humano
  <!-- humano = requisito confirmado pelo humano; inferido = deduzido no
       bootstrap brownfield, NÃO vale como verdade até humano confirmar -->
- **depende-de**: []
- **objetivo**: Usuário entra no sistema com e-mail e senha para acessar a
  área logada.
- **criterios-aceite**:
  - QUANDO o usuário submete e-mail e senha válidos O SISTEMA DEVE redirecionar
    para o painel com sessão criada
  - QUANDO o usuário submete senha incorreta O SISTEMA DEVE exibir erro genérico
    sem revelar qual campo falhou
  - QUANDO o usuário erra a senha 5 vezes seguidas O SISTEMA DEVE bloquear
    novas tentativas por 15 minutos
- **fora-de-escopo**: login social; recuperação de senha (nó próprio).
- **decisoes**:
  - 2026-08-14 (humano): sessão via cookie httpOnly, não localStorage.
- **delta**: <!-- preenchido durante a demanda; consolidado no sync da validação
  - ADICIONADO: <novo requisito + data>
  - MODIFICADO: <requisito alterado: antes → depois + data>
  - REMOVIDO: <requisito removido + motivo + data> -->
- **e2e**: <!-- pendente | relatorio: docs/audora/e2e/e2e-<id>.md | pulado-pelo-humano -->
- **feedback-reprovacao**: <!-- preenchido se portão final reprovar -->
- **atualizado-em**: 2026-08-14

<!-- Regras de manutenção (skill grafo):
1. Validar schema antes de escrever — delta que quebra schema é rejeitado.
2. Nó `entregue` no sync: compactar para 1 linha e mover para
   docs/audora/GRAFO-ARQUIVO.md; promover resumo ao PRD.md.
3. GRAFO ativo acima de ~300 linhas → compactação obrigatória.
4. Em branch: editar somente nós da demanda daquela branch.
5. Máximo 3 nós em-curso simultâneos. -->
