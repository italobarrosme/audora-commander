# e2e — memory-fatiada

**Data:** 2026-08-31 · **Versão:** 0.6.0 · **Ambiente:** Windows 11 Home
10.0.22621, Claude Code `2.1.247`.

**Estado do cache no momento das corridas:** `claude plugin uninstall
audora-commander@audora-commander-dev && ./install.sh` rodado ANTES das
corridas; `diff -r skills <cache>/0.6.0/skills` e `diff -r hooks
<cache>/0.6.0/hooks` **vazios** (exit 0). O que a sessão exercitou é o que
está no repo. `claude plugin list` → `Version: 0.6.0`.

**Ferramenta:** `claude -p` (projeto não-web, sem docker). A escolha já vinha
sendo usada em 3 e2e anteriores sem estar registrada — registrada na
Constituição nesta demanda.

**Fixture:** repo git descartável no scratchpad, com `MEMORY.md` mínimo
(`graphify: recusado`) para as corridas que não devem encadear operações, e
sem `MEMORY.md` para a corrida que testa o encadeamento.

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| **/1** — operação inline não abre reference | `claude -p` "execute registrar-aprendizado com 'porta 5432 já ocupada'", captura `stream-json` | Comandos reais da sessão: `cat MEMORY.md`, `grep -i -n -E '5432\|porta\|ocupad' MEMORY.md` (dedupe, passo 3 do protocolo), `Read MEMORY.md`, escrita. **Zero `cat` de `references/`.** Linha gravada: `- 2026-08-31 \| e2e \| Porta 5432 já ocupada na máquina local — …` | **passou** |
| **/2** — operação movida lê exatamente uma reference | `claude -p` "execute consultar-codigo para 'foo'" em fixture SEM `MEMORY.md`, captura `stream-json` | Leu **duas**: `cat …/references/consultar-codigo.md` e, após `test -f MEMORY.md` → ausente, `cat …/references/bootstrap.md`. O encadeamento é o passo 1 do próprio protocolo ("Bullet ausente → executar a operação 2 e voltar aqui"). Comportamento correto; o critério é que está absoluto demais | **falhou como escrito** → delta |
| **/3** — tabela mapeia as 7 operações | `claude -p` "responda só com a tabela: as 7 operações e onde cada uma mora" | Devolveu as 7 linhas corretas: 1/4/5 `inline`, 2/3/6/7 em `skills/memory/references/<nome>.md` | **passou** |
| **/4** — reference ausente avisa e degrada | `mv` de `references/compactar.md` para fora (restauração por `trap EXIT`), `claude -p` "execute a operação compactar" | Resposta: *"**Aviso**: `references/compactar.md` não existe na instalação (`skills/memory/references/` tem só bootstrap, consultar-codigo, registrar-no). Segui pelo roteador + regras de manutenção do `templates/MEMORY-template.md`. Plugin precisa reinstalar."* — avisou em 1 linha, **nomeou o arquivo**, executou a operação, não travou. Reference restaurada, suíte exit 0 | **passou** |
| **/5** — contrato das 7 operações preservado | Comparação `git show 7e86d9d:skills/memory/SKILL.md` vs estado atual + a corrida de /3 | Antes: 7 cabeçalhos `### 1..7`. Depois: `### 1, 4, 5` inline + `# memory — operação 2/3/6/7` nas references. Numeração 1-7 intacta, nomes idênticos, corpos movidos verbatim. Sessão real reproduz o roteamento sem ambiguidade | **passou** |
| **/6** — teto de 250 em SKILL.md e references | `wc -l` + **teste negativo**: `seq 251 > references/gorda.md` com linha na tabela | `143/39/29/31/21` linhas. Negativo: `FAIL: memory-fatiada/6 skills/memory/references/gorda.md > 250 linhas` — **o guarda mordeu** | **passou** |
| **/7** — sem operação órfã nem reference órfã | **Teste negativo**: `references/orfa.md` criada fora da tabela | `FAIL: /7 sem órfã: orfa.md — não contém 'references/orfa.md'` — **o guarda mordeu**. Repo restaurado, suíte exit 0 | **passou** |
| **/8** — instalação entrega os `references/` | `uninstall` + `./install.sh`, inspeção do cache | `<cache>/0.6.0/skills/memory/references/` com os 4 arquivos (2441/1799/1909/1329 bytes). `diff -r` de `skills` e `hooks` contra o repo: **vazio**. Cache 0.5.0 tinha só `SKILL.md` — o delta é a entrega desta demanda | **passou** |
| **/9** — medição antes/depois em bytes | Comando no plano (Tarefa 4, passo 2), saída lida | `66.655 → 46.841` bytes por demanda MEDIUM (**−29%**, ~4.953 tokens). `SKILL.md` `13.331 → 7.979` (−40% por carga) | **passou** |
| Suíte do plugin | `bash tests/run.sh` | 10 arquivos, **364 asserts, 0 falhas**, exit 0 | **passou** |

## Achado que gerou delta

**/2 falhou como escrito, com o comportamento correto.** O critério diz "lê
exatamente um arquivo de reference — o daquela operação — **e nenhum outro**".
Mas o passo 1 de `consultar-codigo` manda, quando o bullet `graphify:` não
existe, "executar a operação 2 e voltar aqui" — ou seja, o próprio protocolo
encadeia `bootstrap`. A sessão seguiu o protocolo à risca e violou o critério.

Critério absoluto demais, não implementação errada. Delta registrado no nó
refinando /2 para permitir o encadeamento que o protocolo declara.

## Notas de armadilha

- `claude -p` passa de 120s e o Bash tool joga para background — se o comando
  tiver a restauração de um arquivo no fim, o repo fica quebrado enquanto isso.
  Padrão seguro: script com `trap restore EXIT INT TERM` **antes** do `mv`.
- Capturar `claude -p` com `| tail -N` corta a evidência. Redirecionar para
  arquivo e ler inteiro.
- `SKILL.md` no cache tem 8.122 bytes contra 7.979 no repo: são os 143 CRLF do
  checkout (1 por linha). Não é divergência — `diff -r` sai vazio.

## Teardown

Sem infra levantada (projeto não-web, sem docker). Fixture descartável no
scratchpad da sessão. Plugin fica instalado em **0.6.0** — mudança deliberada
da demanda, não órfã. `references/compactar.md` e `references/orfa.md`/
`gorda.md` restaurados/removidos; `git status` limpo e suíte exit 0 conferidos
após cada teste negativo.
