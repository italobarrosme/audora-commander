---
id: plugin-v0.1.0
estado: in-progress
origem: humano
depende-de: []
arquivos: [skills/, hooks/, templates/, .claude-plugin/, README.md]
keywords: [plugin, skills, marketplace, hook, instalacao]
resumo: Plugin instalável com 8 skills, hook SessionStart, templates e marketplace local.
atualizado-em: 2026-08-25
---

# plugin-v0.1.0

## objetivo

Plugin instalável do Claude Code com as skills do framework, hook de
SessionStart, templates canônicos e marketplace local de desenvolvimento.

## criterios-aceite

- **plugin-v0.1.0/1** — QUANDO o marketplace local for adicionado e o plugin
  instalado O SISTEMA DEVE listar as 8 skills com prefixo `audora-commander:`
- **plugin-v0.1.0/2** — QUANDO uma sessão nova iniciar com o plugin ativo
  O SISTEMA DEVE injetar o ponteiro do hook no contexto
- **plugin-v0.1.0/3** — QUANDO a skill audora-commander for invocada num
  projeto sem GRAFO.md O SISTEMA DEVE oferecer bootstrap em vez de travar ou
  inventar conteúdo
- **plugin-v0.1.0/4** — QUANDO cada skill for invocada isoladamente O SISTEMA
  DEVE carregar seu conteúdo sem erro e sem placeholders
- **plugin-v0.1.0/5** — QUANDO uma demanda LEVE e uma MÉDIA forem simuladas
  O SISTEMA DEVE produzir os artefatos esperados (nó no GRAFO, plano-arquivo
  na MÉDIA, roteiro de validação)

## fora-de-escopo

porte multi-harness; marketplace público; agentes dedicados; automação de
git hooks (nós próprios ou versão futura).

## decisoes

- 2026-08-14 (humano): formato plugin padrão Superpowers; 6→7 skills com
  adição do e2e opcional-recomendado; nomes em português
  [invalidado-em: 2026-08-25] [substituido-por: comandos-ingles — nomes de
  skills, categorias e enum de estado em inglês].
- 2026-08-14 (humano): fundamentos v2 aprovados (crítica adversarial +
  acertos do gênero integrados).
- 2026-08-14 (IA): verificação de placeholder case-sensitive com exceção
  para listas de proibição (falso positivo com "todo" em português).

## delta

- MODIFICADO (2026-08-15): critério 1 — "listar as 7 skills" → "listar as
  8 skills" (skill de debug adicionada pelo nó skill-depurar). Motivo: caçada
  A3, divergência nó vs README.
- MODIFICADO (2026-08-25): critério 5 — "uma demanda LEVE e uma MÉDIA" →
  "uma demanda LIGHT e uma MEDIUM"; "plano-arquivo na MÉDIA" → "na MEDIUM".
  Motivo: nó comandos-ingles (categorias de risco em inglês).

## e2e

pendente — critérios 1, 2 e 5 dependem de sessão interativa do humano
(checklist do README).

## feedback-reprovacao
