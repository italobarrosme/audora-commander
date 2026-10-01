# validate — revisão adversarial (HIGH)

> Reference da skill `validate`, lida só em demanda HIGH, ao montar o roteiro
> (item 3). O roteador (`../SKILL.md`) segue valendo.

## Despacho

Despache um subagente de contexto limpo com o diff da demanda, os critérios
de aceite do nó (`<id>/<n>`) e as regras deste arquivo, instruído a ATACAR:
refutar que cada critério foi atendido e procurar o que quebra. Autor não
revisa a si mesmo.

Demanda com script ou comando de efeito fora do repo (desinstalar pacote,
mexer na máquina): o revisor só o roda com executáveis falsos no PATH e sem
os reais — e o prompt do subagente diz isso.

## Bloqueante: só 3 classes, com prova

O revisor marca como bloqueante só o achado de uma de 3 classes:

- (a) apaga ou altera coisa fora da demanda;
- (b) viola um critério de aceite;
- (c) falha com entrada ou formato real.

Para cada bloqueante, a prova da classe:

- (a) o arquivo ou trecho alheio no diff;
- (b) o endereço `<id>/<n>` do critério e como ele é violado;
- (c) o comando ou a entrada que reproduz a falha.

Borda teórica, estilo, melhoria e risco sem reprodução não bloqueiam. O
achado sem prova é rebaixado a ressalva. Resposta do subagente é pista, não
veredito: confira a prova você mesmo (rode o comando, abra o trecho, leia o
critério) — prova que não se sustenta também é rebaixada a ressalva.

## Ressalva

Todo achado não bloqueante entra no roteiro como ressalva de 1 linha, sem
voltar à execute e sem disparar nova passagem de revisão.

## Parada

Uma passagem completa e, no máximo, uma reverificação:

1. **Passagem completa.** Sem bloqueante → a revisão termina. Com
   bloqueante: cada bloqueante vira uma tarefa nova no plano (como na
   aprovação parcial) e registre nas Notas de sessão do plano
   `revisão adversarial: passagem 1` com cada bloqueante, sua classe e sua
   prova. A correção é da execute: imprima `/clear` e `execute de <id>`.
2. **Reverificação.** Na validate seguinte, Notas com a passagem 1 e as
   tarefas dos bloqueantes concluídas → reverificação restrita: o revisor confere só aqueles achados contra o diff da correção, sem caçar achado novo.
   Registre o resultado nas Notas de sessão do plano.
3. **Fim.** Passagem completa e reverificação encerram a revisão — nunca uma
   3ª passagem. O achado novo visto na reverificação entra como ressalva;
   bloqueante ainda aberto e o que restar vai ao portão humano.

## No roteiro

Ao terminar, a revisão entra no roteiro com o nº de passagens (1, ou 1 +
reverificação), cada bloqueante com classe, prova e estado (corrigido ou
aberto) e as ressalvas, 1 linha cada.

Subagente revisor que não pôde ser despachado ou falhou → 1 linha no
roteiro: "revisão adversarial não rodou — <motivo>"; o portão segue com o
humano revisando o diff.
