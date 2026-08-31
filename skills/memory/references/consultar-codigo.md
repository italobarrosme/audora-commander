# memory — operação 7: consultar-codigo (plan, debug, execute)

> Reference da skill `memory`, carregada só quando esta operação é usada.
> O roteador (`../SKILL.md`) segue valendo: Lei de Ferro, schema e regra de
> leitura seletiva não se repetem aqui.

Protocolo único de consulta ao índice de código. Chamado por plan, debug e
execute ANTES de abrir qualquer arquivo de código. scope, e2e e validate
NÃO chamam (não exploram código cru).

1. Pré-condição: Constituição com `graphify: ativo`. `graphify: recusado`
   ou `graphify: sem-codigo` → devolver "sem índice de código: grep/Read" e
   seguir — sem oferecer instalação/indexação de novo (só se o humano
   pedir). Bullet ausente → a etapa Graphify do bootstrap nunca rodou:
   executar a operação 2 e voltar aqui.
2. Sanidade: `bash "<raiz do plugin>/hooks/graphify-status" .` ≠ `ativo`
   (`graph.json` sumiu ou corrompeu) → passo 6.
3. Consultar: `graphify query "<símbolo, rota ou domínio da tarefa>"
   --budget 1500` → linhas `NODE <label> [src=<arquivo> loc=L<n>
   community=<c>]` e `EDGE`. Caminho entre dois símbolos: `graphify path
   "A" "B"`. Impacto de mudar X: `graphify affected "X"`.
4. Ler SÓ os arquivos citados em `src=` das linhas `NODE` (Read com offset
   em `loc=` quando o arquivo for grande). Read fora do apontado → só com
   exceção declarada na fase, em 1 linha: "índice não cobre X porque …".
5. Arquivo existe no repo mas não aparece na consulta → `graphify update .`
   UMA única vez e repetir o passo 3; persistindo → passo 6.
6. Degradar: comando falha (exit ≠ 0, `error: graph file not found`,
   `graph.json` corrompido, `graphify` sumiu do PATH) → avisar em 1 linha
   e cair para grep/Read na MESMA fase. Nunca travar a demanda, nunca
   "consertar" o Graphify no meio da fase — registrar aprendizado
   (operação 5) se a causa for do projeto.
