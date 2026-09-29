---
id: remover-graphify
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [graphify, remocao, indice, consultar-codigo, breaking]
resumo: Remover o Graphify por completo do plugin — oferta, índice, consulta e status.
atualizado-em: 2026-09-29
---

# remover-graphify

## objetivo

Remover o Graphify por completo do audora-commander. Medição de 2026-09-29
nos 12 projetos que usam o plugin: 78 consultas ao índice contra 1.044 Read
e 181 Grep (~6% das buscas de código), e 10 de 41 checagens de status
davam `ausente` por PATH. Custo de reconstrução a cada commit sem retorno
proporcional.

## criterios-aceite

13 critérios EARS (`remover-graphify/1`–`/13`) na spec dedicada:
[../specs/remover-graphify-escopo.md](../specs/remover-graphify-escopo.md).

## fora-de-escopo

Ver a spec: os 12 projetos locais, arquivos históricos, substituto de busca
e gravação da recusa.

## decisoes

- 2026-09-29 (IA): classificada HIGH — remove contrato consumido pelos
  projetos que usam o plugin (bullet `graphify:` da Constituição e
  post-commit instalado pelo bootstrap).
- 2026-09-29: decisões do scope (6 do humano, 4 da IA) na spec.
- 2026-09-29 (humano): autorizada a remoção de `tests/test-graphify-status.sh`
  na T6 (humano: "sim") — o script testado sai; detecção coberta por
  `tests/test-graphify-limpeza.sh`.
- 2026-09-29 (incidente): a revisão adversarial rodou `--remover` com o `uv`
  real no PATH e desinstalou o `graphifyy` da máquina sem autorização.
  Humano: não reinstalar. Teste de `--remover` só com `uv`/`pipx` falsos.
- 2026-09-29 (humano): portão final reprovado; correção A1–A5 aprovada com
  as correções sugeridas pela revisão — dispensa novo portão de plano
  para essa rodada.

gate-asserts: queda aprovada no escopo (/13) — asserts de graphify-status, consultar-codigo, etapa Graphify do bootstrap e dogfood antigo saem com o comportamento; limpeza (/2–/8) coberta por tests/test-graphify-limpeza.sh.

## delta

## e2e

pulado-pelo-humano (2026-09-29: "pula o e2e passa so o validate")

## feedback-reprovacao

- 2026-09-29 (portão final, humano: reprovar e corrigir A1–A5). Gate
  passou (861 asserts), 10/13 critérios passaram; /4, /5, /10 refutados
  pela revisão adversarial, reproduzidos em fixture:
  - A1 (/5): filtro do settings age no GRUPO — apaga hook alheio do mesmo
    grupo; substring `graphify` em comando alheio (`rm -rf
    old-graphify-backup`) dá falso positivo. Filtrar por
    `hooks[].command` casando `^graphify\b`.
  - A2 (/5): seção `## graphify` do CLAUDE.md só termina em `^## ` — H1
    seguinte é apagado. Parar em `^#{1,2} `.
  - A3 (/5): hook de git com marcador start sem end perde tudo até o fim
    do arquivo. Sem end → `falhou` com comando à mão, arquivo intocado.
  - A4 (/4): arquivo versionado removido (pasta `graphify-out/`, hook em
    `core.hooksPath` versionado) não sai como `versionado`. Relatar pelo
    `git status --porcelain`.
  - A5 (/10): `skills/worktree/SKILL.md` item 4 "Índice de código" ainda
    cita reindexar/degradar. Remover e guardar no assert do /9.
  - Menores baratos na mesma rodada: preservar CRLF e newline final; não
    reescrever settings que não tem hook do Graphify e não normalizar
    números; bullet `graphify:` casado só dentro da Constituição;
    diretório inexistente coerente com o cabeçalho do script.
