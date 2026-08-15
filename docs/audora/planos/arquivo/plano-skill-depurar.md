# Plano — skill-depurar: skill de debug com modo caçada

**Objetivo:** Skill `depurar` (dois modos: sintoma e caçada) integrada ao plugin, testada com caçada real no próprio repositório.

**Nó do GRAFO:** `skill-depurar` (GRAFO.md)

**Arquitetura da mudança:** Nova skill-ferramenta (como grafo, não fase do
roteamento). Modo sintoma segue debug sistemático (reproduzir → hipóteses →
causa raiz → fix via TDD). Modo caçada varre classes de defeito com
verificação obrigatória de cada achado. Integração: executar e e2e apontam
para depurar quando algo falha; hook e README ganham a skill.

**Arquivos lidos antes de planejar:** todos os SKILL.md (autorados nesta
sessão), hooks/session-start, README.md, GRAFO.md, templates/ — estado atual
integral conhecido.

**Conflitos GRAFO vs código encontrados:** nenhum.

## Notas de sessão

(vazio)

---

## Tarefa 1: skills/depurar/SKILL.md

- **depende-de**: []
- **requisito**: critérios 1, 2 e 4 do nó (sintoma → causa raiz antes de fix;
  caçada → verificação antes de reporte; verificação estrutural padrão passa)
- **interfaces**: produz skill `depurar` referenciada por nome nas tarefas 2-3
- **arquivos**: Criar `skills/depurar/SKILL.md`
- **done quando**: verificação estrutural padrão imprime ESTRUTURA OK

- [x] 1. Escrever SKILL.md: frontmatter (`name: depurar`; description "Use
  quando..."), Lei de Ferro `NENHUMA CORREÇÃO SEM CAUSA RAIZ DEMONSTRADA`,
  modo sintoma (reproduzir determinístico → evidência completa → hipóteses
  ordenadas, UMA testada por vez → causa raiz explica TODOS os sintomas →
  fix via executar/TDD com teste de regressão), modo caçada (classes de
  defeito: referências cruzadas, contratos/schemas, contagens/documentação,
  bordas de erro, configuração; cada achado verificado contra o artefato real
  antes de entrar no relatório `docs/audora/depuracao/cacada-<data>.md`),
  escalada (3 hipóteses falharam → parar e apresentar evidência ao humano),
  red flags, PRÓXIMA SKILL (fix → executar; achados → validar ou nó).
- [x] 2. Rodar verificação estrutural (`<nome>=depurar`) → `ESTRUTURA OK`.
- [x] 3. Commit `feat: skill depurar`.

## Tarefa 2: integração nas skills vizinhas e no hook

- **depende-de**: [1]
- **requisito**: critério 5 do nó (referências refletem a nova skill)
- **arquivos**: Modificar `skills/executar/SKILL.md` (seção "Quando algo dá
  errado": apontar skill depurar), `skills/e2e/SKILL.md` (critério `falhou` →
  depurar), `hooks/session-start` (lista de fases ganha depurar), `README.md`
  (tabela de skills + contagens "7"→"8"), `docs/fundamentos.md` (linha no
  mapa acerto → skill), `GRAFO.md` constituição (nada a mudar — conferir).
- **done quando**: greps confirmam referências novas e ausência de contagem
  velha; hook re-testado verde
- [x] 1. Aplicar as edições listadas.
- [x] 2. Verificar: `grep -q depurar` em executar, e2e, session-start, README;
  `CLAUDE_PLUGIN_ROOT=. bash hooks/session-start | python -m json.tool` OK;
  `grep -rn "7 skills"` só onde for histórico legítimo (spec/plano antigos).
- [x] 3. Commit `feat: integração da skill depurar no plugin`.

## Tarefa 3: caçada no próprio repositório (o teste da skill)

- **depende-de**: [2]
- **requisito**: critério 3 do nó (relatório com achados verificados +
  correções)
- **arquivos**: Criar `docs/audora/depuracao/cacada-2026-08-14.md`; corrigir o
  que a caçada confirmar
- **done quando**: relatório existe, cada achado tem verificação registrada,
  confirmados corrigidos com re-verificação verde, suíte estrutural completa
  verde
- [x] 1. Executar a caçada seguindo a skill recém-criada, classe por classe.
- [x] 2. Corrigir achados confirmados (um commit por correção).
- [x] 3. Re-rodar varredura estrutural completa + JSONs + hook → tudo verde.
- [x] 4. Commit do relatório.

## Tarefa 4: validar e sincronizar

- **depende-de**: [3]
- **requisito**: portão de resultado (categoria MÉDIA)
- [ ] 1. Evidência 1:1 dos 5 critérios do nó no roteiro de validação.
- [ ] 2. Apresentar ao humano; após aprovação: nó `entregue` → compactar para
  GRAFO-ARQUIVO.md, promover ao PRD.md, arquivar planos.
