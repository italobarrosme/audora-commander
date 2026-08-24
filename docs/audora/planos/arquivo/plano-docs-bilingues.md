# Plano — docs-bilingues: README bilíngue (inglês principal + pt-BR linkado)

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** README.md principal em inglês na raiz, com README.pt-BR.md em
português linkado nos dois sentidos.

**Nó do GRAFO:** `docs-bilingues` (GRAFO.md)

**Arquitetura da mudança:** O conteúdo atual do README.md (português) vira
README.pt-BR.md com banner de idioma no topo; o README.md é reescrito em
inglês com o mesmo banner invertido. Ordem de escrita: pt-BR primeiro (é
cópia + banner, preserva o conteúdo), depois a tradução — e um único commit
atômico no fim, porque commits intermediários deixariam os links de idioma
semanticamente quebrados (banner "English" apontando para arquivo ainda em
português).

**Arquivos lidos antes de planejar:**
- `README.md` — conteúdo integral (143 linhas) que será traduzido/movido;
  fonte única das seções.
- `GRAFO.md` — nó docs-bilingues (critérios EARS) + constituição com exceção
  de idioma aprovada.
- `templates/plano-template.md` — formato canônico deste plano.
- Confirmados por glob (alvos de links do README): `docs/fundamentos.md`,
  `install.sh`, `install.cmd`.

**Conflitos GRAFO vs código encontrados:** nenhum. (Conflito com a
constituição — "conteúdo em português" — foi resolvido no portão de escopo:
exceção aprovada pelo humano em 2026-08-24, registrada na constituição.)

## Notas de sessão

<!-- vazio — demanda executada na mesma sessão do plano -->

## Decisões tomadas pela IA (revisar na validação)

- Placeholders `<...>` dentro de blocos de código são prosa para o leitor
  (o usuário substitui o trecho inteiro), não token literal de comando —
  portanto foram traduzidos (`<pasta-onde-clonou-o-repo>` ↔
  `<folder-where-you-cloned-the-repo>`). O check 3 normaliza `<[^>]*>` para
  `<PLACEHOLDER>` antes do diff; todos os tokens literais permanecem
  byte-idênticos entre os dois READMEs.

---

## Tarefa 1: Criar README.pt-BR.md

- **depende-de**: []
- **requisito**: QUANDO README.pt-BR.md for aberto O SISTEMA DEVE apresentar
  o mesmo conteúdo em português, com paridade ao README.md em inglês, e um
  link de volta para a versão em inglês apontando para README.md
- **decisões relevantes**: nome do arquivo `README.pt-BR.md` (convenção
  GitHub); comandos/código nunca traduzidos.
- **interfaces**:
  - consome: conteúdo atual de `README.md` (HEAD, 143 linhas)
  - produz: `README.pt-BR.md` com banner de idioma que a Tarefa 2 espelha
- **arquivos**:
  - Criar: `README.pt-BR.md`
- **done quando**: arquivo existe; primeira linha após o título é o banner;
  restante idêntico ao README.md atual.

Passos:

- [x] **1. Escrever README.pt-BR.md** — título + banner + conteúdo atual do
  README.md (linhas 2-143) sem alteração. Banner exato, logo após `# audora-commander`:

  ```markdown
  [English](README.md) | **Português (Brasil)**
  ```

## Tarefa 2: Reescrever README.md em inglês

- **depende-de**: [1]
- **requisito**: QUANDO alguém abrir o README.md na raiz O SISTEMA DEVE
  apresentar todo o conteúdo em inglês, com paridade completa (propósito,
  pré-requisitos, instalação, tabela das 8 skills, fluxo de uso, artefatos,
  checklist de validação, desenvolvimento) — nenhuma seção omitida; QUANDO o
  README.md em inglês for aberto O SISTEMA DEVE exibir, logo abaixo do
  título, link visível para README.pt-BR.md; QUANDO um comando, nome de
  arquivo, flag ou trecho de código aparecer O SISTEMA DEVE mantê-lo
  inalterado; QUANDO referenciar outro documento do repositório O SISTEMA
  DEVE preservar o link funcional.
- **decisões relevantes**: nomes de skills (`escopo`, `plano`...) são
  identificadores — não traduzir; categorias mantêm o termo canônico com
  glosa: `LEVE (light)`, `MÉDIA (medium)`, `ALTA (high)`, `HOTFIX`.
- **interfaces**:
  - consome: banner da Tarefa 1 (espelhado)
  - produz: `README.md` em inglês
- **arquivos**:
  - Modificar: `README.md`
- **done quando**: README.md 100% em inglês, banner presente, mesmo conjunto
  de seções do pt-BR, blocos de código byte-idênticos aos do pt-BR.

Passos:

- [x] **1. Reescrever README.md** — banner exato após o título:

  ```markdown
  **English** | [Português (Brasil)](README.pt-BR.md)
  ```

  Mapa de seções (PT → EN), nenhuma omitida:
  - `## Para que serve` → `## What it's for`
  - `## Pré-requisitos` → `## Prerequisites`
  - `## Instalação` → `## Installation`
    - `### Opção A — script automático (recomendado)` →
      `### Option A — install script (recommended)`
    - `### Opção B — manual (sessão interativa do Claude Code)` →
      `### Option B — manual (interactive Claude Code session)`
    - `### Depois de instalar` → `### After installing`
  - `## As 8 skills` → `## The 8 skills`
  - `## Fluxo de uso (exemplo: demanda MÉDIA)` →
    `## Usage flow (example: a MÉDIA demand)`
  - `## Artefatos nos projetos que usam o framework` →
    `## Artifacts in projects using the framework`
  - `## Checklist de validação da instalação` →
    `## Installation validation checklist`
  - `## Desenvolvimento` → `## Development`

  Blocos de código copiados sem tradução (git clone, install.sh,
  install.cmd, claude, /plugin ...).

## Tarefa 3: Verificação mecânica + commit

- **depende-de**: [1, 2]
- **requisito**: todos os 5 critérios EARS do nó (verificação 1:1).
- **decisões relevantes**: commit único atômico (ver Arquitetura da mudança).
- **interfaces**:
  - consome: `README.md` (T2) e `README.pt-BR.md` (T1)
  - produz: evidência para o portão de validação
- **arquivos**:
  - Teste: nenhum arquivo de teste — verificação por comandos abaixo.
- **done quando**: os 4 comandos saem como esperado e o commit existe.

Passos:

- [x] **1. Links cruzados presentes** —
  `grep -c "README.pt-BR.md" README.md` → `≥ 1`;
  `grep -c "(README.md)" README.pt-BR.md` → `≥ 1`.
- [x] **2. Paridade de seções** —
  `grep -c "^## " README.md` e `grep -c "^## " README.pt-BR.md` → números
  iguais (8).
- [x] **3. Blocos de código idênticos** —
  `awk '/^```/{f=!f;next} f' README.md > /tmp/en.txt` idem pt-BR + `diff` →
  saída vazia.
- [x] **4. Alvos de links existem** — `ls docs/fundamentos.md install.sh
  install.cmd` → sem erro.
- [x] **5. Commit** — `git add README.md README.pt-BR.md
  docs/audora/planos/plano-docs-bilingues.md GRAFO.md && git commit -m
  "docs: README bilingue — ingles principal na raiz, pt-BR linkado"`.
