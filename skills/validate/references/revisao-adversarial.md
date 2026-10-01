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
