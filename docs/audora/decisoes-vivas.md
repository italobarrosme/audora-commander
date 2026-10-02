# Decisões vivas — audora-commander

> Decisões técnicas duráveis promovidas de nós entregues no sync da validate
> (IA propõe no roteiro, humano aprova no portão). 1 linha por decisão —
> grep-ável. [carga: auto — consultar quando a demanda tocar a área.]

Formato: `- AAAA-MM-DD | <no-de-origem> | <decisão em 1 frase>`

- 2026-08-15 | skill-depurar | depurar é skill-ferramenta (como grafo), não fase do roteamento; dois modos: sintoma e caçada.
- 2026-08-24 | docs-bilingues | Placeholders `<...>` em blocos de código são prosa do leitor — traduzem; tokens literais de comando nunca.
- 2026-08-24 | e2e-playwright-docker | Compose de e2e vive em docker-compose.e2e.yml na raiz do projeto-alvo; specs Playwright em e2e/.
- 2026-08-24 | e2e-playwright-docker | Escolha de ferramenta e2e não-web é registrada na Constituição do projeto-alvo (pergunta única por projeto).
- 2026-08-25 | grafo-v2 | Hooks e wrappers .cmd ficam em LF (.gitattributes): cmd.exe aceita LF, bash quebra com CRLF em Linux/macOS.
- 2026-08-25 | grafo-v2 | No batch do wrapper, exit /b %ERRORLEVEL% nunca dentro de bloco ( ) — expande em parse-time e engole o exit 2 dos hooks.
- 2026-08-25 | grafo-v2 | Índice mestre é editado pelo LLM e VALIDADO por hook, nunca gerado por script — mantém o GRAFO operável sem bash.
- 2026-08-25 | grafo-v2 | Corte de tokens do v2 (65-70%) é estimativa do estudo — benchmark pulado por decisão humana; medir se a travessia voltar a doer.
- 2026-08-25 | comandos-ingles | Identificadores do framework (nomes de skills, categorias de risco, enum de estado) são em inglês; prosa segue em português.
- 2026-08-25 | comandos-ingles | Fronteira de palavra em grep = classe ASCII `(^|[^A-Za-z0-9_])` + `LC_ALL=C.UTF-8` — o grep 3.0 do Git for Windows ignora `\b` antes de `→`/`—`.
- 2026-08-25 | comandos-ingles | `description` de skill sempre entre aspas simples no YAML — `: ` sem aspas quebra o loader (skill carrega com metadata vazia).
- 2026-08-25 | comandos-ingles | Mensagens de hook citam caminho ABSOLUTO do plugin (resolvido de `$0`), nunca relativo ao projeto-alvo.
- 2026-08-25 | comandos-ingles | Estado PT→EN converte TODOS na primeira escrita; schema v1→v2 é on-touch — sempre nomear o substantivo (estado vs schema) ao falar de migração.
- 2026-08-27 | skill-worktree | `git worktree remove` apaga o conteudo do ALVO atraves de junction/symlink de diretorio — desconectar o link ANTES de remover. [invalidado-em: 2026-09-30] [substituido-por: docs/audora/arquivo/2026-09-30-corte-sem-uso.md]
- 2026-08-27 | skill-worktree | Arquivo ignorado nao bloqueia `git worktree remove` (exit 0, apaga em silencio) e nao aparece em `status --porcelain` — checar ignorados a parte. [invalidado-em: 2026-09-30] [substituido-por: docs/audora/arquivo/2026-09-30-corte-sem-uso.md]
- 2026-08-27 | skill-worktree | Commit nao integrado se detecta com `rev-list --count HEAD --not --remotes`; `@{u}..HEAD` sai 128 em branch sem upstream. [invalidado-em: 2026-09-30] [substituido-por: docs/audora/arquivo/2026-09-30-corte-sem-uso.md]
- 2026-08-31 | memory-fatiada | Skill grande vira roteador + `references/`: operações quentes e curtas inline, grandes ou raras em arquivo próprio, lidas UMA por operação; reference ausente avisa e degrada.
- 2026-09-01 | decisoes-vivas-poda | Decisão que dá para impor por teste, hook ou config não entra em decisoes-vivas.md — o lugar dela é o teste; prosa duplicada deriva do que descreve.
- 2026-09-27 | limpeza-codigo-morto | Mudança incompatível não ganha seção de renomeação nem aviso de versão anterior enquanto a adesão for pequena — o custo aceito é projeto com arquivo antigo ficar sem orientação do framework.
- 2026-09-29 | contexto-por-fase | Retomada de fase é pelo comando impresso `<fase> de <id>` digitado pelo humano — sem SessionStart sugerindo a retomada e sem campo `fase:` no nó.
- 2026-09-29 | remover-graphify | Script com efeito fora do repo (desinstalar pacote, mexer na máquina) só roda em teste ou revisão com executáveis falsos e PATH sem os reais — e o prompt do subagente revisor diz isso.
- 2026-09-30 | corte-sem-uso | Mecanismo do framework sem uso medido (sessões reais) sai inteiro — sem parágrafo residual nem declaração-stub; a medição fundamenta o corte.
- 2026-09-30 | corte-sem-uso | Apagar arquivo de teste exige autorização do humano no portão do scope, com o nome do arquivo no nó e a autorização citada no commit.
- 2026-10-01 | plano-mapa | Mudança que altera o custo de contexto das fases é medida por A/B numa fixture `claude -p` (mesma demanda, plugin antes × depois: artefato, tokens e verde) e reportada sem meta numérica.
- 2026-10-02 | leitura-por-secao | Toda skill de fase, inclusive as futuras, carrega o `MEMORY.md` pelo carregar-contexto da skill memory com "antes de qualquer Read; `MEMORY.md` nunca inteiro" — a regra do recorte mora só no memory, a fase só aponta.
- 2026-10-02 | skill-cleanup | Exceção à regra "índice nunca gerado por script" (grafo-v2): o `hooks/cleanup` só APAGA a linha planned que o humano aprovou no lote e roda o `memory-validate` antes do commit — gerar ou editar linha do índice por script segue proibido.

<!-- Regras (skill memory/validate):
1. Só entra decisão que segue VALENDO para demandas futuras — histórico puro
   fica no nó arquivado.
2. Decisão superada NUNCA é apagada: anexar à linha
   `[invalidado-em: AAAA-MM-DD] [substituido-por: <ref>]`.
3. Consulta: `grep -i '<termo>' docs/audora/decisoes-vivas.md`. -->
