# memory — operação 2: bootstrap (projeto sem MEMORY)

> Reference da skill `memory`, carregada só quando esta operação é usada.
> O roteador (`../SKILL.md`) segue valendo: Lei de Ferro, schema e regra de
> leitura seletiva não se repetem aqui.

1. Projeto novo: copiar `MEMORY-template.md` → `MEMORY.md`, preencher
   Propósito e Constituição perguntando o que faltar (`como-rodar` incluso);
   Aprendizados vazio; zero nós; criar `docs/audora/memory/` vazia.
2. Projeto existente: engenharia reversa MÍNIMA — ler README/PRD/estrutura
   (não a codebase inteira); Propósito, Constituição verificável, e nós das
   funcionalidades visíveis com `origem: inferido` (linha no índice basta —
   expansão sob demanda).
3. Nó `inferido` NÃO vale como verdade: demanda tocando nó inferido →
   confirmar com o humano antes de usar; confirmado → `origem: humano`.
4. **Etapa Graphify** (sempre, ao fim do bootstrap):
   a. Constituição já tem bullet `graphify:` → pular esta etapa, não
      perguntar de novo — só se o humano pedir.
   b. Rodar `bash "<raiz do plugin>/hooks/graphify-status" .` → imprime uma
      de `ausente | sem-indice | sem-codigo | ativo`.
   c. `ausente` → perguntar "Instalar Graphify (índice local do código, sem
      API key)?". Aceitou: `uv tool install graphifyy`; falhou ou `uv`
      ausente: `pipx install graphifyy`; confirmar com `graphify --version`
      e seguir para (d). Instalação falhou (sem uv/pipx, sem rede, Python
      < 3.10): mostrar o erro REAL, seguir degradado avisando, NÃO gravar
      `recusado`, nunca afirmar que instalou. Recusou: Constituição
      `graphify: recusado` + aviso "plan/debug/execute rodam degradadas
      (grep/Read)".
   d. `sem-indice` → `graphify update .` (só código, sem API key), rodar o
      status de novo.
   e. `ativo` → `graphify hook install` (post-commit mantém o índice
      atualizado) e CONFERIR rodando `GIT_DIR=.git bash .git/hooks/post-commit`:
      "could not locate a Python" = hook instalado mas inerte (caminho do
      Python com espaço zera o `_PINNED`) → avisar, pinar `_PINNED` no hook
      e registrar aprendizado; `graphify-out/` no `.gitignore`; Constituição
      `graphify: ativo`.
   f. `sem-codigo` → avisar "nenhuma linguagem suportada indexada"; NÃO
      instalar git hook; Constituição `graphify: sem-codigo`.
5. **Etapa gate** (sempre, após a Graphify):
   a. Constituição já tem bullet `gate:` → pular, não perguntar de novo —
      recusado fica recusado; só reofertar se o humano pedir.
   b. Ausente → perguntar "Gerar o gate mecânico (comando único passou/não
      passou: suíte, lint, typecheck, anti-fraude de teste)?".
   c. Aceitou → instanciar o script de `templates/gate-template.md` (raiz do
      plugin) preenchendo a config pela Constituição (`como-rodar` →
      `GATE_SUITE_CMD`; stack → lint/typecheck/EREs; ferramenta ausente →
      vazio, o gate pula avisando), salvar no projeto-alvo (padrão: `gate` na
      raiz; repo com pasta de scripts, usar a dele) e registrar
      `gate: <comando>` na Constituição.
   d. Recusou → registrar `gate: recusado`.
6. MEMORY parcial desde o dia 1 é o esperado.
