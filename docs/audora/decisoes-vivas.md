# Decisões vivas — audora-commander

> Decisões técnicas duráveis promovidas de nós entregues no sync da validar
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

<!-- Regras (skill grafo/validar):
1. Só entra decisão que segue VALENDO para demandas futuras — histórico puro
   fica no nó arquivado.
2. Decisão superada NUNCA é apagada: anexar à linha
   `[invalidado-em: AAAA-MM-DD] [substituido-por: <ref>]`.
3. Consulta: `grep -i '<termo>' docs/audora/decisoes-vivas.md`. -->
