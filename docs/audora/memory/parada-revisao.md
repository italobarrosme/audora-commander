---
id: parada-revisao
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [revisao, adversarial, parada, validate, high, portao]
resumo: Revisão adversarial da validate ganha critério de parada — só bloqueia o que apaga coisa alheia, viola critério ou falha em formato real; borda teórica vira ressalva, não nova passagem.
atualizado-em: 2026-10-01
---

# parada-revisao

## objetivo

A revisão adversarial da validate (HIGH) passa a ter critério de parada: bloqueia o portão só quando o achado apaga coisa alheia, viola um critério de aceite ou falha em formato real; o resto (borda teórica) entra no roteiro como ressalva, sem disparar nova passagem de revisão. Base: item 6 do estudo de 2026-09-30 (`docs/study/2026-09-30-estudo-leitura-codigo.md`, estudo local, não versionado) — numa demanda HIGH foram 3 passagens caçando borda teórica.

## criterios-aceite

**Classe e prova do bloqueante**

- **parada-revisao/1** — QUANDO a validate despachar a revisão adversarial de uma demanda HIGH O SISTEMA DEVE instruir o revisor a marcar como bloqueante só o achado de uma de 3 classes: (a) apaga ou altera coisa fora da demanda, (b) viola um critério de aceite, (c) falha com entrada ou formato real.
- **parada-revisao/2** — QUANDO o revisor apontar um achado bloqueante O SISTEMA DEVE exigir a prova da classe: (a) o arquivo ou trecho alheio no diff, (b) o endereço `<id>/<n>` do critério e como ele é violado, (c) o comando ou a entrada que reproduz a falha; achado sem prova é rebaixado a ressalva.
- **parada-revisao/3** — QUANDO um achado não for bloqueante O SISTEMA DEVE listá-lo no roteiro como ressalva de 1 linha, sem voltar à execute e sem disparar nova passagem de revisão.

**Parada**

- **parada-revisao/4** — QUANDO houver bloqueante e a execute o corrigir O SISTEMA DEVE fazer uma reverificação restrita: o revisor confere só aqueles achados contra o diff da correção, sem caçar achado novo.
- **parada-revisao/5** — QUANDO a passagem completa e a reverificação terminarem O SISTEMA DEVE encerrar a revisão — nunca uma 3ª passagem; achado novo visto na reverificação entra como ressalva e o que restar vai ao portão humano.
- **parada-revisao/6** — QUANDO a revisão terminar O SISTEMA DEVE pôr no roteiro o nº de passagens, cada bloqueante com classe, prova e estado (corrigido ou aberto) e as ressalvas.
- **parada-revisao/7** — QUANDO o subagente revisor não puder ser despachado ou falhar O SISTEMA DEVE avisar em 1 linha no roteiro que a revisão adversarial não rodou, e o portão segue com o humano revisando o diff.

**Ressalva aceita, custo e versão**

- **parada-revisao/8** — QUANDO o humano aceitar ressalvas no portão O SISTEMA DEVE registrá-las no nó e, no sync, levá-las às metas futuras do `PRD.md` como candidato a nó.
- **parada-revisao/9** — QUANDO uma demanda MEDIUM passar pela validate O SISTEMA NÃO DEVE carregar texto desta demanda: a carga BASE de `tests/test-carga.sh` fica ≤ 48000 bytes.
- **parada-revisao/10** — QUANDO o plugin for reinstalado O SISTEMA DEVE declarar a versão `0.14.0` em `plugin.json` e `marketplace.json`.

## fora-de-escopo

Revisão adversarial em MEDIUM/LIGHT (segue só em HIGH); o modo caçada da skill debug (tem verificação própria); mudar a régua de categoria; leitura por seção (nó `leitura-por-secao`); reclassificar as ressalvas antigas já nas metas 4 e 6 do `PRD.md`.

## decisoes

- 2026-10-01 (IA): MEDIUM — sem dado persistido, contrato de terceiros, auth ou efeito irreversível; muda o comportamento da validate (regra nova) em vários arquivos.
- 2026-10-01 (humano): demanda separada do `prd-foto` no scope dele (meta 5 do `PRD.md`).
- 2026-10-01 (humano): bloqueia só as 3 classes do estudo (alheio, critério, formato real). Descartados: "3 classes + segurança como 4ª" (furo de segurança real já cai em formato real; o teórico é a borda que gerou as passagens) e "tudo bloqueia" (comportamento atual).
- 2026-10-01 (humano): 1 passagem completa + reverificação restrita aos bloqueantes corrigidos. Descartados: "teto de 2 completas" (2ª completa volta a caçar borda) e "sem teto" (a classe sozinha não para o loop).
- 2026-10-01 (humano): não bloqueante vira ressalva no roteiro; aceita, vira candidato a nó nas metas do PRD. Descartados: "ressalva sem meta" (some no arquivo) e "descartada" (humano perde a informação).
- 2026-10-01 (humano): bloqueante exige prova; sem prova, rebaixa a ressalva. Descartado: "argumento basta" (resposta confiante e errada do subagente — estudo, 91% das falhas de passagem).
- 2026-10-01 (IA): achado novo visto na reverificação entra como ressalva (/5), nunca dispara 3ª passagem — o gate da suíte segue cobrindo regressão de critério.
- 2026-10-01 (IA): subagente indisponível (/7) não trava o portão: aviso de 1 linha e o humano revisa o diff.
- 2026-10-01 (IA): /9 — a revisão só existe em HIGH, então o caminho MEDIUM não deve pagar o texto novo (folga BASE hoje: 227 bytes).
- 2026-10-01 (IA): bump `0.14.0` — muda o comportamento da validate; sem bump o cache do plugin não atualiza.

## delta

## e2e

pendente

## feedback-reprovacao
