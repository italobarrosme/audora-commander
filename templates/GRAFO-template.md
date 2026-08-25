versao-schema: 2

# GRAFO — <nome do projeto>

> Memória externa do produto. Requisito não escrito aqui é requisito que não
> existe. Schema v2: este arquivo é o ÍNDICE MESTRE; o corpo de cada nó vive
> em `docs/audora/nos/<id>.md` (1 nó = 1 arquivo, ver
> templates/no-template.md).

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

Uma linha rica por nó — decide relevância SEM abrir o corpo; o corpo vive em
`docs/audora/nos/<id>.md` (resolvido pelo id). Formato:
`- <id> | <estado> | <título curto> | <resumo 1 frase> | <keywords> | <arquivos-chave>`

- exemplo-login | planned | Autenticação e-mail/senha | Usuário entra com e-mail e senha para acessar a área logada | auth, login, sessao | src/auth/

<!-- Regras de manutenção (skill graph):
0. Nó `planned` pode viver SÓ na linha do índice (sem arquivo) até ser
   detalhado. A partir de `in-progress`, arquivo docs/audora/nos/<id>.md
   obrigatório (templates/no-template.md).
1. A linha do índice é editada NA MESMA EDIÇÃO que cria/altera o nó — índice
   e pasta divergentes = memória inconsistente, PARAR (hook grafo-validate
   acusa; sem hook, a skill verifica).
2. Consulta estrutural via grep, sem carregar corpos: estado →
   `grep -l '^estado: in-progress' docs/audora/nos/*.md`; deps reversas →
   `grep -l 'depende-de:.*<id>' docs/audora/nos/*.md`; nó por arquivo de
   código → `grep -l '<caminho>' docs/audora/nos/*.md`.
3. Nó delivered (sync da validate): promover decisões ainda válidas para
   docs/audora/decisoes-vivas.md (templates/decisoes-vivas-template.md),
   depois `git mv docs/audora/nos/<id>.md
   docs/audora/arquivo/AAAA-MM-DD-<id>.md` e trocar a linha do índice para
   `- <id> | delivered | <título> → docs/audora/arquivo/AAAA-MM-DD-<id>.md`
   (caminho a partir da raiz, onde este arquivo vive). Movimento, nunca
   reescrita. Entregas anteriores ao v2 usam a linha legada
   `- <id> | delivered | <título> → ver docs/audora/GRAFO-ARQUIVO.md` e nunca
   migram de SCHEMA (a coluna de estado converte PT→EN com o resto — regra 7).
4. Teto do índice mestre: ~300 linhas → compactar (arquivar entregues,
   encurtar resumos). Teto por nó: ver no-template.
5. Máximo 3 nós in-progress, contados globalmente por este índice.
6. `depende-de` reserva a sintaxe `chave:id` para federação futura — `:` é
   PROIBIDO em id de nó. Caminhos sempre relativos ao arquivo que os contém.
7. Schema v1 (arquivo único, templates/GRAFO-template-v1.md) é caso
   degenerado VÁLIDO: detecção por `versao-schema` na linha 1 (linha ausente
   = v1); migração de SCHEMA on-touch pela skill graph, nunca em lote
   forçado. Estados em português (enum antigo) são o contrário: a skill
   graph converte TODOS de uma vez na primeira escrita (tabela em
   templates/no-template.md).
8. O corpo do nó é resolvido pelo id (id = nome do arquivo em
   docs/audora/nos/) — link implícito por construção, sem campo extra. -->
