# Escopo — remover-graphify (HIGH)

> Nó: `docs/audora/memory/remover-graphify.md`. HIGH porque remove contrato
> consumido pelos projetos que usam o plugin: o bullet `graphify:` da
> Constituição e o post-commit que o bootstrap instalava.

## objetivo

Tirar o Graphify por completo do audora-commander: o plugin deixa de
oferecer, instalar, consultar e mencionar o índice de código. Em projeto que
ainda carrega restos do Graphify, a carga de contexto oferece a limpeza —
inclusive a desinstalação do pacote —, porque o Graphify não será mais
usado. Motivo medido em 2026-09-29 nos 12 projetos que usam o plugin: 78
consultas ao índice contra 1.044 Read e 181 Grep (~6% das buscas de
código), 10 de 41 checagens de status dando `ausente` por PATH, e uma
reconstrução por commit em todos eles.

## criterios-aceite

**Projeto novo**

- **remover-graphify/1** — QUANDO o bootstrap rodar num projeto sem
  `MEMORY.md` O SISTEMA DEVE criar o MEMORY sem oferecer nem instalar o
  Graphify: nenhum bullet `graphify:` na Constituição, nenhum hook de git do
  Graphify, nenhuma linha `graphify-out/` no `.gitignore`.

**Projeto com restos do Graphify**

- **remover-graphify/2** — QUANDO a carga de contexto encontrar no projeto
  qualquer resto do Graphify — bullet `graphify:` na Constituição (qualquer
  valor), bloco do Graphify em `.git/hooks/post-commit` ou
  `.git/hooks/post-checkout`, pasta `graphify-out/`, linha `graphify-out/`
  no `.gitignore`, hook do Graphify em `.claude/settings.json` ou
  `.claude/settings.local.json`, ou seção do Graphify no `CLAUDE.md` — O
  SISTEMA DEVE oferecer a limpeza listando SÓ os itens encontrados, antes de
  seguir a demanda.
- **remover-graphify/3** — QUANDO a oferta do /2 for feita e o pacote
  `graphifyy` estiver instalado na máquina O SISTEMA DEVE incluir na lista a
  desinstalação do pacote.
- **remover-graphify/4** — QUANDO o humano aprovar a limpeza O SISTEMA DEVE
  remover cada item listado e relatar, item a item, o que saiu e os arquivos
  versionados que mudaram, sem commitar por conta própria.
- **remover-graphify/5** — QUANDO um hook de git, o `.gitignore`, o
  `settings.json` ou o `CLAUDE.md` tiver conteúdo além do Graphify O SISTEMA
  DEVE remover só a parte do Graphify e preservar o resto (JSON continua
  válido); arquivo de hook que só continha o Graphify sai inteiro.
- **remover-graphify/6** — QUANDO a remoção de um item falhar (arquivo
  bloqueado, desinstalação com erro, sem permissão) O SISTEMA DEVE seguir
  com os demais, relatar o que falhou com o comando para fazer à mão, e não
  travar a demanda.
- **remover-graphify/7** — QUANDO o humano recusar a limpeza O SISTEMA DEVE
  não alterar nada, não gravar a recusa e seguir a demanda; a próxima carga
  de contexto oferece de novo enquanto houver resto.
- **remover-graphify/8** — QUANDO o projeto não tiver nenhum resto do
  Graphify O SISTEMA DEVE não mencionar o Graphify nem fazer a oferta —
  pacote instalado na máquina sozinho não dispara a oferta.

**Fases e superfície do plugin**

- **remover-graphify/9** — QUANDO as fases plan, execute e debug precisarem
  localizar código O SISTEMA DEVE usar a busca normal do harness, sem
  operação `consultar-codigo`, sem índice e sem regra substituta; a skill
  `memory` fica com as operações de memória, sem a de código.
- **remover-graphify/10** — QUANDO o leitor abrir skills, templates, hooks,
  manifests, `README.md`, `README.pt-BR.md` e `docs/fundamentos.md` O
  SISTEMA DEVE não apresentar o Graphify como recurso do framework; a
  palavra só aparece no que descreve a oferta de limpeza (/2–/8). O princípio
  da memória dinâmica deixa de citar índice de código.
- **remover-graphify/11** — QUANDO o plugin for reinstalado O SISTEMA DEVE
  declarar a versão `0.10.0` em `plugin.json` e `marketplace.json`.

**Este repositório (dogfood) e suíte**

- **remover-graphify/12** — QUANDO a demanda fechar O SISTEMA DEVE ter este
  repositório sem resto do Graphify: Constituição sem bullet `graphify:`,
  sem hooks de git do Graphify, sem `graphify-out/` e sem a linha no
  `.gitignore`; aprendizados sobre o Graphify marcados `[invalidado-em:]`
  com motivo, nunca apagados.
- **remover-graphify/13** — QUANDO o gate rodar ao fim da demanda O SISTEMA
  DEVE sair 0: o comportamento da limpeza (/2–/8) tem cobertura na suíte, e
  a queda de asserts de `graphify-status` passa só com `gate-asserts:`
  justificado no nó e a remoção do arquivo de teste autorizada no commit.

## fora-de-escopo

Limpar os 12 projetos desta máquina nesta demanda (cada um recebe a oferta
na próxima demanda que rodar lá, ou o humano limpa à mão); arquivos
históricos (`docs/audora/arquivo/`, planos arquivados, specs e relatórios
e2e de demandas passadas) — história imutável; parágrafos históricos do
`PRD.md` sobre entregas passadas; substituto para o índice de código ou
regra nova de busca; gravar a recusa da limpeza.

## decisoes

- 2026-09-29 (humano): em projeto com restos, o plugin oferece limpar
  (descartados: ignorar em silêncio com nota no README; avisar uma vez sem
  mexer).
- 2026-09-29 (humano): sem regra substituta para localizar código
  (descartado: regra curta "Grep antes de Read") — o modelo já usa busca
  normal em ~94% dos casos.
- 2026-09-29 (humano): os 12 projetos locais ficam fora desta demanda
  (descartado: limpar cada um depois do merge).
- 2026-09-29 (humano): a limpeza cobre hooks de git, `graphify-out/` +
  `.gitignore` e a integração Claude do próprio Graphify ("graphify em geral
  não vai ser mais usado").
- 2026-09-29 (humano): recusa não é gravada, a oferta volta a cada demanda
  (descartado: gravar `graphify: limpeza-recusada` como o `gate: recusado`).
- 2026-09-29 (humano): a oferta inclui desinstalar o pacote `graphifyy`
  (descartado: só o projeto, pacote à mão).
- 2026-09-29 (IA): pacote instalado sozinho não dispara oferta (/8) — sem
  isso todo projeto da máquina ofertaria desinstalar, até os que nunca
  usaram Graphify. Confirmada no portão (humano: "segue").
- 2026-09-29 (IA): a limpeza não commita (/4) — a carga de contexto roda no
  início da demanda, às vezes na `main`; o commit fica com a fase ou o
  humano. Confirmada no portão (humano: "segue").
- 2026-09-29 (IA): aprovação é da lista inteira, sem escolha item a item —
  menos texto na skill. Confirmada no portão (humano: "segue").
- 2026-09-29 (IA): bump para `0.10.0` (breaking, minor pré-1.0).
