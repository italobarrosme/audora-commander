# E2E — autopilot

> Data: 2026-09-05. Ferramenta: `claude -p` (Constituição, `ferramenta-e2e`),
> plugin reinstalado do repo (cache fresco) e fixture `calc-cli` (repo git com
> MEMORY schema 1, `graphify: recusado`, `gate: recusado` — recusa que gruda
> também exercitada: nenhuma das duas foi reofertada).

## Receita (regressão)

1. Fixture calc-cli (mesma do e2e-gate-mecanico) + bullet `gate: recusado`.
2. Cache: `claude plugin uninstall audora-commander@audora-commander-dev && ./install.sh`.
3. Cenário A: `claude -p "<demanda MEDIUM + 'roda em autopilot até o validate'; registrar o nó e parar>" --permission-mode acceptEdits`.
4. Cenário B: `claude -p "<demanda de migração de dado + autopilot; só classificar e relatar>"`.
5. Ler os logs INTEIROS; conferir o nó da fixture com grep.

## Critérios × evidência

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| /1 declaração LIGHT/MEDIUM | Cenário A, sessão real com escrita | nó `calc-verbose` gravado: frontmatter `autopilot: declarado` (linha 6, conferido por grep), linha da declaração em `## decisoes`, índice consistente, hook do cache calado; transcript: "portão de escopo fica antecipado ... final da validate NUNCA antecipa" | passou |
| /2 HIGH recusa | Cenário B | "Decisão do framework sobre autopilot: RECUSADO ... P4 — portão nunca escala para baixo. Fluxo segue HIGH normal" com os 3 portões nomeados | passou |
| /3 tardia | não exercitado em sessão (exigiria demanda em andamento real) | asserts de conteúdo na suíte ("checada e gravada na hora", "ainda não cruzados") | não-automatizável |
| /4 LIGHT | não exercitado em sessão | asserts dentro da seção Fechamento LIGHT (awk) | não-automatizável |
| /5 elegibilidade | Cenário A relatou o contrato certo: "Em MEDIUM, elegibilidade não checa na entrada — auto-revisão do scope grava elegivel/inelegivel depois" | transcript + asserts da suíte | passou |
| /6-/11 | conteúdo de skill exercitável só numa demanda autopilot completa | 36 asserts em `tests/test-autopilot.sh` (seções via awk; frase inteira do invariante) | não-automatizável |
| /12 schema | Cenário A gravou o campo e o hook real (do cache) validou a escrita sem exit 2 | nó da fixture + fixture da suíte (declarado, elegivel, inelegivel) | passou |
| /13 invariante | os DOIS cenários declararam espontaneamente o portão final intocado | "final da validate NUNCA antecipa" (A); "tu aprovando escopo, plano e resultado" (B) + guarda de frase inteira na suíte | passou |
| /14 fundamentos | leitura direta | tabela P4 com coluna, regra 8 no P5 (asserts de linha exata) | passou |

## Notas

- A primeira demanda REAL em autopilot fecha o ciclo dos critérios /6-/11 ao
  vivo — candidata: qualquer MEDIUM futura deste repo declarada na entrada.
- Controle negativo de recusa persistente: Graphify E gate recusados na
  fixture, nenhum reofertado nos dois cenários.
- Teardown: sessões terminam sozinhas; fixture no scratchpad; plugin instalado
  é o estado normal.
