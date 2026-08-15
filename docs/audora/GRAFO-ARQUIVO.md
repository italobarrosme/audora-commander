# GRAFO-ARQUIVO — audora-commander

Nós entregues, compactados pela skill validar no sync pós-merge. Leitura
manual — não é carregado automaticamente em contexto.

## skill-depurar (entregue 2026-08-15)

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
