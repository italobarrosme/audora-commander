# validate — filtro de entrada das decisões vivas (roteiro, item 3)

> Reference da skill `validate`, lida ao montar a seção "Decisões vivas
> propostas" do roteiro. O roteador (`../SKILL.md`) segue valendo.

Candidata a `docs/audora/decisoes-vivas.md` é decisão do nó que segue
valendo para demandas futuras E passa no filtro:

- **Filtro de entrada**: só é candidata a decisão que NÃO dá para
  impor por teste, hook ou config, nem já esteja declarada
  normativamente — para o **mesmo escopo de aplicação** — em artefato
  que o framework lê (teste, hook, config, template, Constituição ou
  SKILL.md). Escopo importa: regra que vale para skills FUTURAS não é
  duplicata de um SKILL.md que só a aplica a si mesmo.
- Dá para escrever um teste que a imponha, mas ele ainda não existe?
  Então **escreva o teste** nesta demanda, ou mantenha a entrada até que
  ele exista — nunca deixe a decisão sumir em silêncio.
- Descartou por já estar declarada? Diga em 1 linha qual artefato a
  declara. Artefato que trata a matéria como FORA do próprio escopo não
  serve de ponteiro.

O humano aprova/corta no portão; o sync (`sync.md`, passo 1) só executa.
