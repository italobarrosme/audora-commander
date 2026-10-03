# E2E — cleanup-alvo-ausente (2026-10-02)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.16.0 da
`main` em `4f7498b`, reinstalado com `claude plugin uninstall
audora-commander@audora-commander-dev && ./install.sh`. `diff -r` de
`skills/`, `hooks/` e `templates/` contra `<cache>/0.16.0` → vazio. As
sessões chamaram `hooks/cleanup` pelo caminho do repo (marketplace dev
aponta para o repo); como cache = repo, o exercitado é o commitado.
Ferramenta: `claude -p` (CLI 2.1.284, Constituição `ferramenta-e2e`).

## Receita (regressão)

1. **Fixture** (`fixture.sh <dir> [loja|semcommit]`, no scratchpad):
   - `loja`: `git init -b main`, `core.excludesFile` inexistente; commit
     `init` com `src/auth/login.js`, `src/carrinho/carrinho.js`,
     `lib/pdfgen.js`, `src/legado/cupom.js`, `app/s/page.tsx`, delivered
     `login` e `carrinho` (arquivos do nó em `docs/audora/arquivo/`);
     commit que remove `lib/pdfgen.js`, `src/legado/cupom.js`,
     `app/s/page.tsx`; branch `experimento` (não mergeada) com
     `src/chat/chat.js`; commit com os planned:
     - `relatorio-pdf` → `lib/pdfgen.js` (existiu e sumiu)
     - `busca` → `src/busca/` (nunca existiu)
     - `cupom-v2` → `src/legado/cupom.js, src/cupom/` (misto)
     - `chat` → `src/chat/chat.js` (só em branch não alcançável)
     - `produto` → `app/[slug]/page.tsx` (nunca existiu; como glob casaria
       com `app/s/page.tsx`, que existiu)
     - `carrinho-v2` → `src/carrinho/` (existe no disco)
   - `semcommit`: `git init` sem commit, índice só com o planned
     `relatorio-pdf` → `lib/pdfgen.js` (sem os delivered, que virariam link
     quebrado fora do git).
2. **Sessão**: `claude -p "<prompt>" --permission-mode acceptEdits
   --allowedTools "Bash Read Grep Glob Skill Write Edit" --output-format
   stream-json --verbose`; turno 2 com `--resume <session_id>`. Prompt do
   turno 1: "Faz uma faxina nas sobras do processo deste projeto (nós
   órfãos, arquivo morto). Me mostra o que sairia antes de mexer em
   qualquer coisa."
   - B, C (`loja`): turno 1 = relatório.
   - C2: "Tira o cupom-v2. Aprovo o lote só com o relatorio-pdf. Pode
     aplicar."
   - S (`semcommit`): 1 turno.
3. **Leitura**: `.jsonl` (Skill, Bash com saída, texto final) e o disco da
   fixture antes/depois de cada turno (`git rev-parse HEAD`, `git status
   --short`).

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| cleanup-alvo-ausente/1 — nunca existiu → fora do relatório | B, C | `varrer` não cita `busca` (`src/busca/`) nem `produto` em seção nenhuma; relatório só com `## planned órfão` e `total: 2 item(ns) no lote` | passou |
| cleanup-alvo-ausente/2 — existiu e sumiu → órfão | B, C | `- relatorio-pdf \| alvo ausente: lib/pdfgen.js` | passou |
| cleanup-alvo-ausente/3 — misto cita só o que existiu | B, C | `- cupom-v2 \| alvo ausente: src/legado/cupom.js` (sem `src/cupom/`) | passou |
| cleanup-alvo-ausente/4 — só em branch não alcançável → fora | B, C | `chat` (`src/chat/chat.js`, só em `experimento`) fora do relatório | passou |
| cleanup-alvo-ausente/5 — diretório | B, C | `src/busca/` (nunca versionado) fora. Diretório que existiu e sumiu não exercitado em sessão, só na suíte (`pasta`) | passou |
| cleanup-alvo-ausente/6 — existe no disco → fora | B, C | `carrinho-v2` (`src/carrinho/`) fora | passou |
| cleanup-alvo-ausente/7 — `--orfao` prevalece | B, C | IA passou `--orfao "relatorio-pdf=alvo ausente: lib/pdfgen.js"` → linha com o motivo dado. Caso "caminho que nunca existiu" só na suíte | passou |
| cleanup-alvo-ausente/8 — `contar` = `varrer` | antes de B | `bash <cache>/hooks/cleanup contar` na fixture `loja` → `2`, exit 0; `varrer` → `total: 2` | passou |
| cleanup-alvo-ausente/9 — repo sem commit | S | `cleanup: nada a limpar`, exit 0, sem `fatal:` vindo do script; HEAD/status iguais ao antes | passou |
| cleanup-alvo-ausente/10 — skill confere o histórico antes do `--orfao` | B, C, S | As 3 sessões rodaram `git log -1 --full-history --oneline HEAD -- <alvo>` para cada planned antes de julgar; B e C pegaram sozinhas a armadilha do `[slug]` (glob casa `app/s/page.tsx`) e conferiram com `:(literal)` → nunca existiu → "feature futura, fica" | passou |

Disco: B, C e S com HEAD e status iguais ao antes do turno 1. C2: `aplicar`
→ commit `ac48906` (`chore(cleanup): remove 1 sobra(s) do processo`,
`MEMORY.md | 1 -`), só a linha `relatorio-pdf` saiu; `busca`, `cupom-v2`,
`chat`, `produto`, `carrinho-v2` seguem no índice; árvore limpa.

## Achados

- **Planned misto continua no lote quando o objetivo é substituir o legado**
  (`cupom-v2`): conforme /3 e a decisão humana (misto é listado citando só o
  que sumiu). B e C recomendaram tirar do lote, C2 tirou. C2 notou que o item
  volta em toda varredura enquanto `src/legado/cupom.js` ficar na coluna
  arquivos-chave do nó.
- **A frase da skill (`git log … -- <alvo>`) não traz `--literal-pathspecs`**:
  com `[slug]` a conferência da IA casa por glob. O script usa a flag e acerta;
  a IA acertou porque desconfiou (2/2), não porque a skill mandou.
- Em todas as sessões a IA ofereceu criar `PRD.md` (regra global do usuário,
  não do plugin). Não teve efeito na cleanup.
