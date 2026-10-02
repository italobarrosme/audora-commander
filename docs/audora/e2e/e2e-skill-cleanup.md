# E2E — skill-cleanup (2026-10-02)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.16.0 da
`main` em `13aed33`, reinstalado com `claude plugin uninstall
audora-commander@audora-commander-dev && ./install.sh`. `diff -r` de
`skills/`, `hooks/` e `templates/` contra `<cache>/0.16.0` → vazio. A skill
carregou com base em `skills/cleanup` do repo (marketplace dev aponta para o
repo); como cache = repo, o exercitado é o commitado. Ferramenta: `claude -p`
(CLI 2.1.284, Constituição `ferramenta-e2e`), binário
`~/.local/bin/claude.exe`.

## Receita (regressão)

1. **Fixture** (`fixture.sh <dir> [completo|limpo|semmem]`, no scratchpad):
   projeto "loja" com `git init -b main`, `core.excludesFile` inexistente,
   `src/auth/login.js`, `src/carrinho/carrinho.js`.
   - `completo`: delivered `login`, `carrinho`, `perfil`; planned
     `login-email` (absorvido por `login`), `carrinho-v1` (absorvido, mas
     `checkout` in-progress depende dele), `relatorio-pdf`
     (`lib/pdfgen.js`), `busca` (`src/busca/`, feature ainda não feita);
     spec, plano arquivado e e2e de `login`; caçada sem nó vivo e caçada
     ligada a `checkout`; `notas-reuniao.md` sem referência; link quebrado
     em `decisoes-vivas.md:4`; depois do commit, `rascunho.md` untracked e
     `perfil-escopo.md` sujo.
   - `limpo`: só `login` delivered + `busca` planned com `src/` existente.
   - `semmem`: sem `MEMORY.md`.
2. **Sessão**: `claude -p "<prompt>" --permission-mode acceptEdits
   --allowedTools "Bash Read Grep Glob Skill Write Edit" --output-format
   stream-json --verbose`, em background; turno 2 com `--resume
   <session_id>`. Prompt do turno 1 (todas): "Faz uma faxina nas sobras do
   processo deste projeto (nós órfãos, arquivo morto). Me mostra o que
   sairia antes de mexer em qualquer coisa."
   - A (`semmem`), E (`limpo`): 1 turno.
   - B, D, F (`completo`): turno 1 = relatório.
   - B2: "Aprovo o lote sem busca e sem relatorio-pdf (os 7 itens
     restantes). Pode aplicar."
   - D2: "Não, reprovo. Não quero mexer em nada agora."
   - F2: mesmo texto do B2, com `notas-reuniao.md` aberto com
     `FileShare None` por outro processo (PowerShell) durante o turno.
3. **Leitura**: `.jsonl` inteiro (textos, `tool_use`, resultados) e o disco
   da fixture depois de cada turno (`git log`, `git status --short
   --untracked-files=all`).

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| skill-cleanup/1 — relatório agrupado, nada alterado antes da aprovação | B, D, F turno 1 | Script `varrer` → 7 seções + `## mantido` + `## não tocado`, `total: 9 item(ns) no lote`; cada item com caminho e motivo. HEAD `init` e status idênticos depois do turno nas 3 | passou |
| skill-cleanup/2 — sem MEMORY recusa | A | "Não fiz nenhuma faxina: este projeto não tem `MEMORY.md`… Não mexi em nada"; aponta a skill memory. HEAD/status iguais | passou |
| skill-cleanup/3 — absorvido por delivered | B, D, F | IA julgou e passou `--orfao login-email=absorvido por login` → `- login-email \| absorvido por login` (3/3) | passou |
| skill-cleanup/4 — alvo ausente | B, D, F | `- relatorio-pdf \| alvo ausente: lib/pdfgen.js`. **Defeito:** `- busca \| alvo ausente: src/busca/` também entra, e nenhum dos dois caminhos existiu (D conferiu `git log --all -- lib/pdfgen.js src/busca` → vazio). O script marca todo planned cujo arquivo-chave ainda não foi criado. A IA pegou nas 3 sessões e recomendou tirar os dois; aprovar "como está" apagaria requisito legítimo | passou com defeito |
| skill-cleanup/5 — mantido com dependente vivo | B, D, F | `- carrinho-v1 \| mantido: checkout depende dele`, fora do lote; B2 conferiu a linha ainda no índice | passou |
| skill-cleanup/6 — apaga linha do planned aprovado | B2 | Commit `3f79621`: `MEMORY.md \| 1 -`; `grep login-email` → só restam `carrinho-v1`, `relatorio-pdf`, `busca`. Caso "arquivo do nó existe" não exercitado em sessão (só na suíte) | passou |
| skill-cleanup/7 — artefatos de delivered e depuração velha | B, D, F | spec, plano arquivado e e2e de `login` + `cacada-2026-04-01.md`; `cacada-2026-09-01.md` (ligada a `checkout`) e `checkout-escopo.md` fora | passou |
| skill-cleanup/8 — sem referência | B, D, F | `- docs/audora/notas-reuniao.md \| nenhum documento vivo o cita` | passou |
| skill-cleanup/9 — apaga e troca link pela nota | B2 | `arquivo/2026-05-01-login.md:14` → "Escopo: `` `docs/audora/specs/login-escopo.md` `` removido em 2026-10-02 pela cleanup — recuperável no git." | passou |
| skill-cleanup/10 — link quebrado listado e trocado | B, B2 | `- docs/audora/decisoes-vivas.md:4 \| aponta specs/pagamento-escopo.md inexistente`; aplicado → mesma nota. **Ressalva:** a nota diz "recuperável no git" para arquivo que nunca existiu (a própria sessão B2 apontou) | passou |
| skill-cleanup/11 — fora do git / sujo não tocado | B, D, F, B2 | `rascunho.md \| não tocado: fora do git`, `perfil-escopo.md \| não tocado: mudança não commitada`; depois do B2 os dois seguem `??` e ` M`, fora do commit | passou |
| skill-cleanup/12 — aprovação explícita, tirar itens, reprovar | B2, D2 | B2 tirou 2 itens → commit com 7. D2 "reprovo" → "Não rodei o `aplicar`"; HEAD `f8babfd init` e status iguais | passou |
| skill-cleanup/13 — 1 commit, mensagem por tipo, MEMORY válido | B2 | `git show --stat 3f79621`: 8 arquivos, só os do lote; mensagem lista 1 linha por tipo; `memory-validate` no MEMORY resultante → exit 0 (mesmo hook com estado inválido injetado → exit 2) | passou |
| skill-cleanup/14 — falha no meio desfaz e nomeia | F2 | `cleanup: falhou em: - docs/audora/notas-reuniao.md \| nenhum documento vivo o cita — git rm falhou` + `lote desfeito, nada commitado`, exit 1. HEAD `487673b` e status iguais ao antes; `login-escopo.md`, `e2e-login.md` e a linha `login-email` de volta. IA não contornou à mão e ofereceu 3 opções | passou |
| skill-cleanup/15 — nada a limpar | E | `cleanup: nada a limpar`, exit 0; "Nada a limpar. Nenhum arquivo mexido, nenhum commit." | passou |
| skill-cleanup/16 — sugestão no sync da validate | não exercitado em fixture | `bash hooks/cleanup contar` neste repo → `96`, `git status` igual antes/depois; a prova de sessão é o sync da validate desta demanda | não-automatizável |

## Achados

- **Falso positivo do /4 mecânico** (`hooks/cleanup`, `classifica_orfaos`):
  `-e` cru na coluna arquivos-chave confunde "ainda não criado" com "não
  existe mais". Planned costuma citar arquivo futuro, então quase todo
  planned real entra no lote. A suíte não pega: a fixture usa
  `src/sumiu.ts`, que também nunca existiu. Rede de segurança hoje: o
  julgamento da IA (3/3 sessões recomendaram tirar).
- **Nota enganosa no link que já nasceu quebrado** (/10): "recuperável no
  git" para alvo que nunca foi versionado. Conforme o critério aprovado
  ("trocá-lo pela mesma nota"), mas o texto mente.
- Em todas as sessões a IA ofereceu criar `PRD.md` (regra global do
  usuário, não do plugin) — sem efeito na cleanup.
