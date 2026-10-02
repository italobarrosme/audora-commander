---
id: leitura-por-secao
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [leitura, prd, memory, secao, tokens]
resumo: Fases leem só o recorte do MEMORY.md de que precisam em vez do arquivo inteiro, sem mudar o formato.
atualizado-em: 2026-10-01
---

# leitura-por-secao

## objetivo

Cada fase passa a carregar do `MEMORY.md` só as seções e linhas de que precisa, em vez do arquivo inteiro, sem mudar o formato do `MEMORY.md`. Medido neste repo: 18,8 KB lidos em toda fase, dos quais 11,9 KB são Aprendizados e 4,7 KB o Índice de nós. Base: estudo de 2026-09-30 (`docs/study/2026-09-30-estudo-leitura-codigo.md`, local, não versionado), princípio "contexto é orçamento".

## criterios-aceite

**Seções fixas**

- **leitura-por-secao/1** — QUANDO qualquer fase (porta de entrada, scope, plan, execute, e2e, validate, debug) carregar o contexto do `MEMORY.md` O SISTEMA DEVE ler as seções Propósito e Constituição inteiras e, de Aprendizados e Índice de nós, só o recorte dos critérios /2 a /6 — nunca o arquivo inteiro, salvo o fallback de /8.

**Aprendizados**

- **leitura-por-secao/2** — QUANDO scope, plan, execute, e2e, validate ou debug carregar Aprendizados O SISTEMA DEVE carregar só as linhas cujo campo de fase é a própria fase mais as linhas que casam as keywords ou os arquivos-chave do nó da demanda.
- **leitura-por-secao/3** — QUANDO a porta de entrada carregar Aprendizados O SISTEMA DEVE carregar só as linhas que casam os termos do pedido do humano.
- **leitura-por-secao/4** — QUANDO uma linha de Aprendizados estiver marcada `[invalidado-em: …]` O SISTEMA NÃO DEVE carregá-la em nenhuma fase.
- **leitura-por-secao/5** — QUANDO nenhuma linha de Aprendizados casar o filtro O SISTEMA DEVE seguir a fase sem aprendizados, sem ler a seção inteira.

**Índice de nós**

- **leitura-por-secao/6** — QUANDO a porta de entrada, scope ou plan carregar o Índice de nós O SISTEMA DEVE ler a seção inteira; QUANDO execute, e2e, validate ou debug carregar O SISTEMA DEVE pegar por busca só a linha do nó da demanda e as dos nós em `depende-de`, sem ler a seção.

**Reuso, falta de seção e formato**

- **leitura-por-secao/7** — QUANDO o recorte já tiver sido carregado nesta sessão (sem `/clear` nem compactação depois) O SISTEMA DEVE reusá-lo do contexto, sem reler.
- **leitura-por-secao/8** — QUANDO uma seção esperada (`## Propósito`, `## Constituição`, `## Aprendizados`, `## Índice de nós`) não for encontrada no `MEMORY.md` O SISTEMA DEVE avisar em 1 linha qual seção faltou, ler o arquivo inteiro e seguir a fase.
- **leitura-por-secao/9** — QUANDO um projeto tiver `MEMORY.md` no formato atual (`memory-schema: 1`, marcadores `[carga: sempre]`) O SISTEMA NÃO DEVE exigir nenhuma edição nele: template e marcadores ficam como estão e o `memory-validate` segue aceitando o arquivo.

**Medição, custo e versão**

- **leitura-por-secao/10** — QUANDO a demanda for medida O SISTEMA DEVE registrar em `## medicao` do nó, para a mesma demanda MEDIUM numa fixture rodada com `claude -p` antes × depois (n=1), os bytes lidos do `MEMORY.md` por fase e o custo de cada sessão; o depois lê menos bytes do `MEMORY.md` que o antes em toda fase.
- **leitura-por-secao/11** — QUANDO as skills mudarem O SISTEMA DEVE manter a carga BASE e FULL de `tests/test-carga.sh` dentro dos tetos vigentes (48000 / 56900); subir teto só com o motivo registrado no nó.
- **leitura-por-secao/12** — QUANDO o plugin for reinstalado O SISTEMA DEVE declarar a versão `0.15.0` em `plugin.json` e `marketplace.json`.

## fora-de-escopo

Ler por seção o `PRD.md`, o `templates/bloco-fechamento-template.md` e os templates de nó e de plano (seguem inteiros); mudar o formato do `MEMORY.md`, os marcadores `[carga: …]` ou o `templates/MEMORY-template.md`; compactar ou mover Aprendizados (meta 5 do `PRD.md`); a leitura de corpos de nó, do plano e de `docs/audora/decisoes-vivas.md` (já seletiva ou por grep); hooks; a instrução global do humano de ler o `PRD.md`.

## decisoes

- 2026-10-01 (IA): MEDIUM — sem dado persistido, contrato de terceiros, auth ou efeito irreversível; muda o comportamento de leitura de várias skills (múltiplos arquivos, regra nova).
- 2026-10-02 (humano): só o `MEMORY.md` lê por seção. Descartados no lote: `bloco-fechamento-template` (4,7 KB/fase), `PRD.md` (só o sync lê) e templates de nó/plano.
- 2026-10-02 (humano): Aprendizados = linhas da própria fase + as que casam keywords/arquivos do nó, sem as invalidadas. Descartados: "só termos da demanda" (perde o aprendizado de fase que não cita a keyword) e "todos" (mantém 63% do arquivo).
- 2026-10-02 (humano): Índice inteiro só na porta, scope e plan (acham nós relacionados e `depende-de`); execute/e2e/validate/debug pegam a própria linha por busca. Descartado: todas as fases leem inteiro.
- 2026-10-02 (humano): seção não encontrada → aviso de 1 linha + leitura inteira, a fase segue. Descartados: ler inteiro calado; parar e perguntar.
- 2026-10-02 (humano): prova = A/B real com `claude -p` + guarda estática. Descartado: só guarda estática (sem número de economia).
- 2026-10-02 (humano): porta de entrada filtra Aprendizados pelos termos do pedido. Descartados: nenhum aprendizado; todos.
- 2026-10-02 (humano): marcadores `[carga: sempre]` ficam como estão; a regra mora nas skills. Descartado: trocar o texto (muda o template).
- 2026-10-02 (IA): Propósito e Constituição seguem inteiros em toda fase (1,9 KB juntos; Constituição traz stack, como-rodar e gate que toda fase usa).
- 2026-10-02 (IA): debug segue a regra de execute (Aprendizados da fase `debug` + termos do nó; Índice só a própria linha). Sem nó, o filtro usa os termos do sintoma, como a porta usa os do pedido.
- 2026-10-02 (IA): filtro vazio não cai para a seção inteira (/5) — cair anularia o corte nos projetos com poucos aprendizados por fase.
- 2026-10-02 (IA): tetos de carga mantidos (folga BASE hoje: 277 bytes); o plan acomoda o texto novo, e subir teto exige motivo no nó (/11).
- 2026-10-02 (IA): bump `0.15.0` — muda o comportamento das skills; sem bump o cache do plugin não atualiza.

## delta

## e2e

pendente

## feedback-reprovacao
