# Decisões vivas — audora-commander

> Decisões técnicas duráveis promovidas de nós entregues no sync da validar
> (IA propõe no roteiro, humano aprova no portão). 1 linha por decisão —
> grep-ável. [carga: auto — consultar quando a demanda tocar a área.]

Formato: `- AAAA-MM-DD | <no-de-origem> | <decisão em 1 frase>`

- 2026-08-15 | skill-depurar | depurar é skill-ferramenta (como grafo), não fase do roteamento; dois modos: sintoma e caçada.
- 2026-08-15 | skill-depurar | Verificação de placeholder é case-sensitive com exceção para listas de proibição (falso positivo com "todo" em português).
- 2026-08-24 | docs-bilingues | Placeholders `<...>` em blocos de código são prosa do leitor — traduzem; tokens literais de comando nunca.
- 2026-08-24 | e2e-playwright-docker | Compose de e2e vive em docker-compose.e2e.yml na raiz do projeto-alvo; specs Playwright em e2e/.
- 2026-08-24 | e2e-playwright-docker | Escolha de ferramenta e2e não-web é registrada na Constituição do projeto-alvo (pergunta única por projeto).

<!-- Regras (skill grafo/validar):
1. Só entra decisão que segue VALENDO para demandas futuras — histórico puro
   fica no nó arquivado.
2. Decisão superada NUNCA é apagada: anexar à linha
   `[invalidado-em: AAAA-MM-DD] [substituido-por: <ref>]`.
3. Consulta: `grep -i '<termo>' docs/audora/decisoes-vivas.md`. -->
