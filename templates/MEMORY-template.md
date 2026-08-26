memory-schema: 1

# MEMORY — <nome do projeto>

> Memória do produto: o que ele faz, regras inegociáveis, o que aprendemos e
> o estado de cada demanda. Requisito não escrito aqui é requisito que não
> existe. Este arquivo é o ÍNDICE MESTRE; o corpo de cada nó vive em
> `docs/audora/memory/<id>.md` (1 nó = 1 arquivo, ver
> templates/no-template.md). O CÓDIGO não vive aqui: é indexado pelo
> Graphify em `graphify-out/` (fora do git) e consultado pela skill memory.

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
- **graphify**: <ativo | recusado | sem-codigo — gravado no bootstrap pela
  skill memory; ausente = ainda não perguntado. `ativo` = índice em
  `graphify-out/` + git hook post-commit instalado>

## Aprendizados [carga: sempre]

O que o projeto ensinou e vale para toda demanda futura: armadilhas,
preferências do humano, como-rodar descoberto, padrões que não estão no
código. Registrado NA HORA por qualquer fase (skill memory,
registrar-aprendizado). 1 linha, grep-ável:
`- AAAA-MM-DD | <fase> | <aprendizado em 1 frase>`

- 2026-08-24 | e2e | Porta 3000 fica ocupada por servidor órfão de sessão anterior — teardown sempre.

## Índice de nós [carga: sempre]

Uma linha rica por nó — decide relevância SEM abrir o corpo; o corpo vive em
`docs/audora/memory/<id>.md` (resolvido pelo id). Formato:
`- <id> | <estado> | <título curto> | <resumo 1 frase> | <keywords> | <arquivos-chave>`

- exemplo-login | planned | Autenticação e-mail/senha | Usuário entra com e-mail e senha para acessar a área logada | auth, login, sessao | src/auth/

<!-- Regras de manutenção (skill memory):
0. Nó `planned` pode viver SÓ na linha do índice (sem arquivo) até ser
   detalhado. A partir de `in-progress`, arquivo docs/audora/memory/<id>.md
   obrigatório (templates/no-template.md).
1. A linha do índice é editada NA MESMA EDIÇÃO que cria/altera o nó — índice
   e pasta divergentes = memória inconsistente, PARAR (hook memory-validate
   acusa; sem hook, a skill verifica).
2. Consulta estrutural via grep, sem carregar corpos: estado →
   `grep -l '^estado: in-progress' docs/audora/memory/*.md`; deps reversas →
   `grep -l 'depende-de:.*<id>' docs/audora/memory/*.md`; nó por arquivo de
   código → `grep -l '<caminho>' docs/audora/memory/*.md`; aprendizado →
   `grep -i '<termo>' MEMORY.md`.
3. Nó delivered (sync da validate): promover decisões ainda válidas para
   docs/audora/decisoes-vivas.md, consolidar aprendizados da demanda aqui,
   depois `git mv docs/audora/memory/<id>.md
   docs/audora/arquivo/AAAA-MM-DD-<id>.md` e trocar a linha do índice para
   `- <id> | delivered | <título> → docs/audora/arquivo/AAAA-MM-DD-<id>.md`.
   Movimento, nunca reescrita.
4. Tetos: este arquivo ~300 linhas (hook memory-guard); Aprendizados ~40
   linhas → mover os antigos para docs/audora/aprendizados-historico.md;
   por nó ver no-template.
5. Máximo 3 nós in-progress, contados globalmente por este índice.
6. `depende-de` reserva a sintaxe `chave:id` para federação futura — `:` é
   PROIBIDO em id de nó. Caminhos sempre relativos ao arquivo que os contém.
7. O corpo do nó é resolvido pelo id (id = nome do arquivo em
   docs/audora/memory/) — link implícito por construção. -->
