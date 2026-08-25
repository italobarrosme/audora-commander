# GRAFO-ARQUIVO — audora-commander

Nós entregues, compactados pela skill validar no sync pós-merge. Leitura
manual — não é carregado automaticamente em contexto.

## e2e-playwright-docker (delivered 2026-08-24)

- **origem**: humano | **depende-de**: []
- **objetivo**: Skill e2e com Playwright como ferramenta default para
  projetos web e docker compose como infra default do teste, artefatos
  versionados no projeto-alvo.
- **criterios-aceite** (8/8 mapeados 1:1 em trechos da skill no portão):
  Playwright default web; não-web pergunta ao humano (nunca sozinho);
  compose existente usado; ausente → gerado pela stack/constituição via
  `templates/e2e-infra-template.md`; Docker indisponível → aviso + fallback
  como-rodar; artefatos versionados e estendidos (nunca recriados); falha de
  infra → log + pergunta (nunca infra parcial); teardown sempre (compose
  down).
- **decisoes**:
  - 2026-08-24 (humano): Playwright só para web; não-web pergunta; compose
    gerado quando ausente; artefatos versionados; escopo aprovado no portão.
  - 2026-08-24 (IA): `docker-compose.e2e.yml` na raiz do alvo; specs em
    `e2e/`; escolha não-web registrada na Constituição (pergunta única);
    description do frontmatter menciona os defaults.
- **e2e**: pendente-humano — exercício real exige sessão interativa com o
  plugin instalado (mesmo checklist do nó plugin-v0.1.0).
- **entregue-em**: 2026-08-24 (commit e70b578)

## docs-bilingues (delivered 2026-08-24)

- **origem**: humano | **depende-de**: []
- **objetivo**: README.md principal em inglês (idioma padrão do projeto
  open-source) na raiz, com README.pt-BR.md linkado contendo a versão em
  português.
- **criterios-aceite** (5/5 evidenciados no portão):
  - QUANDO alguém abrir o README.md na raiz O SISTEMA DEVE apresentar todo o
    conteúdo em inglês com paridade completa de seções (evidência: 8×8
    seções, zero resíduo de português na varredura)
  - QUANDO o README.md for aberto O SISTEMA DEVE exibir link visível para
    README.pt-BR.md logo abaixo do título (evidência: linha 3)
  - QUANDO README.pt-BR.md for aberto O SISTEMA DEVE apresentar o mesmo
    conteúdo em português com link de volta (evidência: linha 3 + paridade)
  - QUANDO comando/arquivo/flag/código aparecer O SISTEMA DEVE mantê-lo
    inalterado (evidência: diff de blocos de código vazio, placeholders
    normalizados)
  - QUANDO referenciar outro doc do repo O SISTEMA DEVE preservar link
    funcional (evidência: alvos existem)
- **decisoes**:
  - 2026-08-24 (humano): inglês como idioma principal; exceção da
    constituição aprovada (README em inglês, demais docs em português).
  - 2026-08-24 (IA): nome README.pt-BR.md (convenção GitHub); placeholders
    `<...>` em blocos de código traduzidos (prosa pro leitor, não token).
- **e2e**: pulado-pelo-humano (redundante para demanda de documentação).
- **entregue-em**: 2026-08-24 (commit d62ed98)

## skill-depurar (delivered 2026-08-15)

- **origem**: humano | **depende-de**: [plugin-v0.1.0]
- **objetivo**: Skill `depurar` no plugin: debug sistemático com causa raiz
  demonstrada quando há sintoma, e caçada de bugs por classes de defeito
  quando não há. Testada rodando a caçada no próprio repositório.
- **criterios-aceite** (5/5 evidenciados no portão):
  - QUANDO a skill depurar for invocada com sintoma conhecido O SISTEMA DEVE
    conduzir reprodução → hipóteses → causa raiz demonstrada ANTES de qualquer
    correção
  - QUANDO a skill depurar for invocada sem sintoma (caçada) O SISTEMA DEVE
    varrer classes de defeito definidas e verificar cada achado antes de
    reportar
  - QUANDO a caçada rodar no repositório audora-commander O SISTEMA DEVE
    produzir relatório com achados verificados e correção dos confirmados
  - QUANDO a verificação estrutural padrão rodar O SISTEMA DEVE aprovar a
    skill
  - QUANDO as referências do plugin forem varridas O SISTEMA DEVE refletir a
    nova skill sem menção órfã
- **decisoes**:
  - 2026-08-14 (humano): criar a skill e testá-la rodando no próprio projeto
    (instrução direta = portão de escopo aprovado).
  - 2026-08-14 (IA): nome `depurar`, dois modos (sintoma/caçada), posição de
    skill-ferramenta (como grafo), não fase do roteamento.
- **e2e**: caçada real em `docs/audora/depuracao/cacada-2026-08-15.md` — 6
  achados confirmados e corrigidos, 1 falso-positivo descartado por
  verificação, 1 melhoria aplicada.
- **entregue-em**: 2026-08-15
