# E2E — gate-mecanico

> Data: 2026-09-04. Ferramenta: `claude -p` (Constituição, `ferramenta-e2e`)
> — sessão real do Claude Code com o plugin reinstalado do repo
> (`claude plugin uninstall` + `./install.sh`, cache fresco). Complemento:
> execuções REAIS do `hooks/gate` em repo git de verdade (fixture da suíte e
> dogfood na árvore deste repo) — o produto desta demanda é o próprio script.

## Receita (regressão)

1. Fixture: projeto `calc-cli` em diretório temporário — git init, `calc.sh`,
   `tests/run.sh` verde, `MEMORY.md` schema 1 com Constituição de 3 bullets
   (`stack` bash, `como-rodar: bash tests/run.sh`, `graphify: recusado`) e
   SEM bullet `gate:`.
2. Cache: `claude plugin uninstall audora-commander@audora-commander-dev &&
   ./install.sh`.
3. Sessão: `claude -p "<pedir carregar-contexto para demanda nova; relatar
   Constituição e ofertas; não editar nada>" --max-turns 15 > log 2>&1`
   com cwd na fixture; ler o log INTEIRO.
4. Dogfood: `bash hooks/gate gate-mecanico` na raiz deste repo, árvore limpa.

## Critérios × evidência

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| /1 oferta no bootstrap | etapa gate do bootstrap é a MESMA reutilizada pelo /2; bootstrap completo (projeto sem MEMORY) não exercitado em sessão | asserts de conteúdo na suíte (`Etapa gate`, template, aceite/recusa); sessão real validou a oferta pela via /2 | passou |
| /2 oferta no início de demanda | `claude -p` na fixture pedindo carregar-contexto | transcript: "Detectado ausente: bullet `gate:` na Constituição. Passo 5 do carregar-contexto manda ofertar UMA vez" + config instanciada do como-rodar (`GATE_SUITE_CMD` = `bash tests/run.sh`) + "Se recusado: registra `gate: recusado` e não reoferece". Controle negativo: "NÃO ofertado: Graphify... recusado fica recusado" | passou |
| /3 exit 0/1 com motivo | gate real na fixture git da suíte (suíte verde e `GATE_SUITE_CMD=false`) e dogfood | exit 0 + `GATE: passou`; exit 1 + `GATE: reprovado` + `suite falhou` | passou |
| /4 pula sem ferramenta | dogfood real neste repo (stack sem lint/typecheck) | `GATE: lint pulado (sem ferramenta na stack)` + `GATE: typecheck pulado (...)`, exit 0 | passou |
| /5 teste apagado | `rm tests/test-a.sh` na fixture git, gate real | exit 1, `arquivo de teste apagado: tests/test-a.sh` | passou |
| /6 skip/only | append `xit("burla")`, gate real | exit 1, `skip/only adicionado: tests/test-a.sh:4` (arquivo e linha) | passou |
| /7 queda de asserts | 3 → 2 asserts na fixture, gate real | exit 1, `contagem de asserts caiu: 3 → 2` | passou |
| /8 válvula de justificativa | `gate-asserts: refactor legitimo` no nó da fixture, gate real com id | exit 0, imprime a justificativa e `GATE: passou` | passou |
| /9 execute GREEN = gate | critério de conteúdo de skill — leitura no portão | asserts na suíte; conferência humana do texto do GREEN | não-automatizável |
| /10 validate separa diff de teste | critério de conteúdo de skill — o roteiro desta própria demanda já aplicou a seção | asserts na suíte + roteiro da validate com "Diff de teste" separado | não-automatizável |
| /11 dogfood | `bash hooks/gate gate-mecanico`, árvore limpa deste repo | suíte inteira rodou por dentro; `GATE: passou`, exit 0; Constituição com `**gate**:` | passou |

## Notas

- Teardown: sessão `claude -p` termina sozinha; fixture vive no scratchpad da
  sessão (efêmero); plugin fica instalado (estado normal). Nada órfão.
- O transcript da sessão saiu em caveman (CLAUDE.md global do usuário vale na
  fixture) — cosmético, não afeta o comportamento validado.
