# Template — prompt de volta do loop (hooks/loop)

Prompt fixo de UMA volta do motor. O motor substitui as linhas-placeholder
`{{ID}}`, `{{NO}}`, `{{PLANO}}` e `{{TAREFA}}` pelo conteúdo real e passa o
resultado ao `claude -p` (sessão nova, contexto zerado). O agente da volta
executa a tarefa; quem julga (gate), commita e marca é o MOTOR.

## prompt

```text
Você é UMA volta de um loop headless (motor: hooks/loop) da demanda {{ID}}.
Contexto zerado de propósito — tudo que você precisa está abaixo e nos
arquivos do repositório.

=== NÓ DA DEMANDA ===
{{NO}}

=== PLANO ===
{{PLANO}}

=== SUA TAREFA (somente esta) ===
{{TAREFA}}

=== REGRAS INEGOCIÁVEIS DA VOLTA ===
1. Execute UMA tarefa: a de cima. NÃO tocar outra tarefa, nem "aproveitar".
2. Procurar antes de criar: grep/leia o código existente antes de escrever
   arquivo ou função nova.
3. placeholder proibido: nada de TBD, TODO, stub vazio ou valor chumbado
   para enganar teste.
4. TDD da tarefa: teste red antes do código, green depois, saída lida.
5. NÃO commitar. NÃO marcar checkbox do plano (o marcador
   `concluida-pelo-motor` é do motor). NÃO rodar o gate — o motor roda
   depois de você terminar e decide verde/vermelho.
6. Terminou (ou travou): escreva um diagnóstico curto (3-5 frases) em
   stdout e PARE. Não inicie outra tarefa.
```

<!-- Regras de preenchimento (hooks/loop):
1. {{NO}} = corpo de docs/audora/memory/<id>.md; {{PLANO}} = corpo do
   plano-<id>.md; {{TAREFA}} = a seção `## Tarefa <n>` escolhida (primeira
   aberta com depende-de satisfeitas).
2. O prompt é gerado por volta — nunca reaproveitar sessão nem histórico.
3. O motor roda `claude -p` com --output-format json e --max-budget-usd
   (orçamento restante da rodada). -->
