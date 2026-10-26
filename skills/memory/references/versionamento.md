# memory — versionamento (o `.gitignore` padrão do audora)

> Reference da skill `memory`, lida no bootstrap (etapa versionamento) e na
> oferta do item 7 da carregar-contexto. O roteador (`../SKILL.md`) segue
> valendo.

**Memória versionada** (fica no git): `MEMORY.md`, `PRD.md`, `CHANGELOG.md`,
`docs/audora/memory/`, `docs/audora/arquivo/`, `docs/audora/decisoes-vivas.md`,
`docs/audora/aprendizados.md`. **Pastas efêmeras** (só no disco):
`docs/audora/specs/`, `docs/audora/planos/`, `docs/audora/e2e/`,
`docs/audora/depuracao/`.

O mecânico mora no script `hooks/versionamento` da raiz do plugin. Rode na
raiz do projeto:

```bash
bash "<raiz do plugin>/hooks/versionamento" checar
bash "<raiz do plugin>/hooks/versionamento" aplicar [--desligar <arquivo>:<linha>]... [--remover]
```

`checar` só lê. `aplicar` escreve o bloco no `.gitignore` da raiz sem
duplicar e sem mexer no resto; `--desligar` comenta uma regra de `.gitignore`
do projeto; `--remover` tira do git o que já está nas pastas efêmeras, mantém
no disco e commita só isso com o `.gitignore`. Mostre ao humano as linhas
do script como saíram.

## Fluxo

1. Bootstrap: rode `aplicar` sem perguntar e registre `versionamento: aplicado` na Constituição.
2. Oferta (carregar-contexto, item 7): mostre o que passa a ser ignorado — `docs/audora/specs/`, `docs/audora/planos/`, `docs/audora/e2e/`, `docs/audora/depuracao/` — e a saída do `checar`; pergunte UMA vez.
   Aceitou → `aplicar` e registre `versionamento: aplicado` na Constituição.
   Recusou → registre `versionamento: recusado` e não reoferte, salvo pedido do humano.
3. Depois do `aplicar` (bootstrap ou oferta aceita), rode `checar`:
   - Linha `memória ignorada:` → mostre a regra, a linha `quebra:` e proponha o ajuste; `--desligar` só com sim.
   - `fonte fora do projeto — não edito` → nomeie a fonte e não a edite.
   - Linha `versionado em pasta efêmera:` → liste-os e pergunte; `--remover` só com sim; sem sim, nada sai do git.
     No bootstrap, só em projeto existente (projeto novo não tem histórico).
   - `há mudança staged` → peça ao humano para commitar ou tirar do índice antes; nada mudou.
   - `commit falhou` → repasse a linha ao humano: o script já desfez as remoções.
4. Fora do git → repasse em 1 linha a saída do script.
