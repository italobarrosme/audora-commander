# audora-commander

Plugin de Claude Code: framework de desenvolvimento de software assistido por
IA, guiado por 5 princípios:

1. **Mapa Dinâmico** — GRAFO.md é a memória viva do produto; requisito não
   escrito não existe.
2. **Planejamento Just-in-Time** — plano nasce lendo o código atual, cobre uma
   demanda, morre depois dela.
3. **"O Quê" separado do "Como"** — escopo fecha em artefato escrito antes de
   qualquer código.
4. **Processo proporcional ao risco** — LEVE, MÉDIA, ALTA e HOTFIX pagam
   cerimônias diferentes; portão de aprovação nunca escala para baixo.
5. **IA executa, humano decide** — portões explícitos, evidência fresca antes
   de qualquer "pronto".

## Para que serve

`audora-commander` transforma o Claude Code num processo de desenvolvimento
guiado, não só um autocomplete poderoso. Ele ataca um problema comum de codar
com IA sem estrutura: requisito que se perde entre conversas, plano que vira
código sem ninguém aprovar o escopo antes, e "pronto" que ninguém verificou
de verdade.

Instalado num projeto, o plugin adiciona 8 skills encadeadas — da
classificação de risco da demanda até o portão de validação final — que
mantêm um mapa vivo do produto (`GRAFO.md`), transformam escopo em artefato
escrito antes do código, e cobram evidência real (testes rodados, e2e
exercitado) antes de qualquer coisa ser dada como concluída.

Público-alvo: dev solo ou time pequeno construindo web/mobile/api com Claude
Code, que quer rigor de processo sem a burocracia de um processo pesado.

Fundamentos completos: [docs/fundamentos.md](docs/fundamentos.md).

## Pré-requisitos

- Claude Code CLI instalada (comando `claude` disponível no PATH).
- Git, para clonar o repositório. No Windows, use o
  [Git for Windows](https://git-scm.com/download/win) — ele fornece o bash
  usado pelo instalador e pelos hooks do plugin.

## Instalação

### Opção A — script automático (recomendado)

Clone o repositório e rode o instalador de dentro da pasta clonada:

```bash
git clone https://github.com/italobarrosme/audora-commander.git
cd audora-commander
./install.sh
```

No Windows, sem precisar abrir o Git Bash manualmente, dá pra rodar
`install.cmd` direto (ele mesmo acha o Git Bash e delega para o
`install.sh`):

```
install.cmd
```

O script adiciona esta pasta como marketplace local
(`audora-commander-dev`) e instala o plugin `audora-commander`, tudo via CLI
não-interativa — sem precisar abrir uma sessão do Claude Code antes. Rodar
de novo depois de já instalado é seguro (idempotente).

### Opção B — manual (sessão interativa do Claude Code)

```bash
claude
```

Dentro da sessão:

```
/plugin marketplace add <pasta-onde-clonou-o-repo>
/plugin install audora-commander@audora-commander-dev
```

### Depois de instalar

Reinicie a sessão (ou rode `/clear`) — o hook de SessionStart passa a
injetar o ponteiro do framework. Em seguida, rode o "Checklist de validação
da instalação" mais abaixo neste README.

## As 8 skills

| Skill | Papel |
|---|---|
| `audora-commander` | Porta de entrada: classifica a demanda por risco (LEVE/MÉDIA/ALTA/HOTFIX) e roteia |
| `grafo` | Cria e mantém o GRAFO.md (bootstrap, nós, deltas, compactação) |
| `escopo` | Fase "O Quê": critérios EARS, marcador [PRECISA-CLARIFICAR], portão de escopo |
| `plano` | Fase "Como" just-in-time: plano-arquivo com tarefas autossuficientes |
| `executar` | TDD red-green com evidência real; commit por etapa verde |
| `e2e` | Levanta o projeto e exercita a demanda de ponta a ponta (opcional, fortemente recomendada) |
| `validar` | Portão humano final: evidência 1:1 com critérios, sync GRAFO → PRD |
| `depurar` | Debug com causa raiz demonstrada (modo sintoma) ou caçada de defeitos por classes (modo caçada) |

## Fluxo de uso (exemplo: demanda MÉDIA)

1. Você pede: "adiciona filtro por data na listagem de pedidos".
2. `audora-commander` classifica: MÉDIA (lógica nova, sem dado/auth/contrato).
3. `escopo` pergunta o que falta, fecha critérios EARS, você aprova (portão).
4. `plano` lê o código atual e gera `docs/audora/planos/plano-<id>.md`.
5. `executar` implementa por TDD, commit a cada etapa verde.
6. `validar` oferece o `e2e` (recomendado): projeto sobe, critérios são
   exercitados de verdade, relatório sai em `docs/audora/e2e/`.
7. Portão final: roteiro de validação com evidência por critério. Você aprova;
   GRAFO sincroniza e PRD.md recebe o resumo.

## Artefatos nos projetos que usam o framework

- `GRAFO.md` — raiz do projeto (memória viva).
- `docs/audora/GRAFO-ARQUIVO.md` — nós entregues, compactados.
- `docs/audora/planos/` — planos ativos; `arquivo/` para os encerrados.
- `docs/audora/e2e/` — relatórios E2E por demanda.
- `docs/audora/specs/` — specs de escopo de demandas ALTA.
- `docs/audora/depuracao/` — relatórios de caçada de defeitos (skill depurar).

## Checklist de validação da instalação

Rode na sessão interativa após instalar:

- [ ] 1. QUANDO o marketplace for adicionado e o plugin instalado, o Claude
  Code DEVE listar as 8 skills com prefixo `audora-commander:` (verifique com
  a listagem de skills da sessão).
- [ ] 2. QUANDO uma sessão nova iniciar, o contexto DEVE conter o ponteiro
  "Framework audora-commander ativo" (pergunte ao Claude o que o hook
  injetou).
- [ ] 3. QUANDO a skill `audora-commander` for invocada num projeto sem
  GRAFO.md, ela DEVE oferecer bootstrap em vez de travar ou inventar conteúdo.
- [ ] 4. QUANDO cada skill for invocada isoladamente, ela DEVE carregar sem
  erro e sem placeholders.
- [ ] 5. QUANDO uma demanda LEVE e uma MÉDIA forem simuladas num projeto de
  exemplo, o fluxo DEVE produzir os artefatos esperados (nó no GRAFO;
  plano-arquivo na MÉDIA; roteiro de validação).

## Desenvolvimento

Este repositório usa o próprio framework (dogfooding): veja `GRAFO.md`,
`docs/audora/planos/` e a spec em `docs/specs/`.
