#!/usr/bin/env bash
# agentes-dedicados — agente revisor read-only e quem o despacha.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# flat <arquivo> [cabeçalho] → texto (da seção, se dado) sem \r, numa linha só,
# espaços colapsados: frase que quebra linha no Markdown ainda casa.
flat() {
  if [ -n "${2:-}" ]; then
    tr -d '\r' 2>/dev/null < "$1" | awk -v h="$2" '$0==h{f=1;next} /^## /{f=0} f'
  else
    tr -d '\r' 2>/dev/null < "$1"
  fi | tr '\n' ' ' | tr -s ' '
}
A=agents/revisor.md
TRAVA='Trava do shell: não escreva, apague nem mova arquivo no repo; não cause efeito fora dele; script ou comando de efeito externo só roda com executáveis falsos no PATH, sem os reais.'

# frontmatter <arquivo> → linhas entre o 1º e o 2º `---`; corpo <arquivo> → depois do 2º.
frontmatter() { tr -d '\r' 2>/dev/null < "$1" | awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f'; }
corpo() { tr -d '\r' 2>/dev/null < "$1" | awk 'n>=2{print;next} $0=="---"{n++}' | tr '\n' ' ' | tr -s ' '; }

# checar_revisor <arquivo> → 1 violação por linha; vazio = agente read-only com trava.
checar_revisor() {
  local fm tools model item
  fm="$(frontmatter "$1")"
  tools="$(printf '%s\n' "$fm" | grep -m1 '^tools:')"
  if [ -z "$tools" ]; then
    echo 'sem tools: (herda todas)'
  else
    printf '%s\n' "${tools#tools:}" | tr ',' '\n' | while IFS= read -r item; do
      item="$(printf '%s' "$item" | sed 's/([^)]*)//; s/^[[:space:]]*//; s/[[:space:]]*$//')"
      [ -z "$item" ] && continue
      case "$item" in
        Read|Grep|Glob|Bash) ;;
        *) echo "ferramenta proibida: $item" ;;
      esac
    done
  fi
  model="$(printf '%s\n' "$fm" | grep -m1 '^model:' | sed 's/^model:[[:space:]]*//; s/[[:space:]]*$//')"
  [ "$model" = inherit ] || echo 'model não é inherit'
  printf '%s' "$(corpo "$1")" | grep -qF -- "$TRAVA" || echo 'trava ausente'
}

# mutar <nome> <expressão perl> → cópia mutada do agente em $SP (vazia se o agente falta).
mutar() {
  local m="$SP/$1.md"
  if [ -f "$A" ]; then perl -pe "$2" "$A" > "$m"; else : > "$m"; fi
  printf '%s' "$m"
}

# --- /1 — agente existe, nome e descrição ---
assert_file "$A" "agentes-dedicados/1 agente revisor existe"
fm="$(frontmatter "$A")"
assert_contains "$fm" 'name: revisor' "agentes-dedicados/1 frontmatter tem name"
assert_contains "$(printf '%s\n' "$fm" | grep -m1 '^description:')" 'revisa e refuta sem alterar nada' \
  "agentes-dedicados/1 descrição diz que revisa e refuta sem alterar nada"

# --- /2 — só leitura, busca e shell ---
assert_eq 'tools: Read, Grep, Glob, Bash' "$(printf '%s\n' "$fm" | grep -m1 '^tools:')" \
  "agentes-dedicados/2 tools é allowlist de leitura, busca e shell"

# --- /3 — trava do shell na definição do agente ---
c="$(corpo "$A")"
assert_contains "$c" "$TRAVA" "agentes-dedicados/3 corpo carrega a trava do shell"
assert_contains "$c" 'Prova por mutação só numa cópia fora do repo' "agentes-dedicados/3 mutação fora do repo"

# --- /4 — modelo herdado da sessão ---
assert_eq 'model: inherit' "$(printf '%s\n' "$fm" | grep -m1 '^model:')" "agentes-dedicados/4 model herdado"

# --- /11 — guarda da suíte: o arquivo real passa, cada mutação reprova ---
assert_empty "$(checar_revisor "$A")" "agentes-dedicados/11 agente real sem violação"
for t in Write Edit NotebookEdit Agent Task; do
  m="$(mutar "tool-$t" "s/^tools: .*/tools: Read, Grep, Glob, Bash, $t/")"
  assert_contains "$(checar_revisor "$m")" "ferramenta proibida: $t" "agentes-dedicados/11 mutação + $t reprova"
done
m="$(mutar sem-tools 's/^tools:.*\n//')"
assert_contains "$(checar_revisor "$m")" 'sem tools: (herda todas)' "agentes-dedicados/11 mutação sem tools reprova"
m="$(mutar model-sonnet 's/^model: .*/model: sonnet/')"
assert_contains "$(checar_revisor "$m")" 'model não é inherit' "agentes-dedicados/11 mutação model fixo reprova"
m="$(mutar sem-trava 's/Trava do shell: .*/Trava do shell: cuidado./')"
assert_contains "$(checar_revisor "$m")" 'trava ausente' "agentes-dedicados/11 mutação sem trava reprova"
m="$(mutar bash-restrito 's/^tools: .*/tools: Read, Grep, Glob, Bash(git status)/')"
assert_empty "$(checar_revisor "$m")" "agentes-dedicados/11 Bash restrito continua permitido"

# --- /5 /9 /10 — validate: revisão adversarial despacha o revisor pelo nome ---
R=skills/validate/references/revisao-adversarial.md
d="$(flat "$R" '## Despacho')"
assert_contains "$d" 'subagent_type: audora-commander:revisor' "agentes-dedicados/5 validate despacha o revisor pelo nome"
assert_contains "$d" 'A passagem completa e a reverificação usam o mesmo despacho.' "agentes-dedicados/5 mesmo despacho nas 2 passagens"
bash tests/test-parada-revisao.sh > /dev/null 2>&1 && ok || ko "agentes-dedicados/5 regras da revisão intactas (test-parada-revisao reprovou)"
assert_contains "$d" 'Despacho do `revisor` falhou (agente ausente ou não carregado)' "agentes-dedicados/9 validate fallback"
assert_contains "$d" "$TRAVA" "agentes-dedicados/9 validate genérico leva a trava no prompt"
assert_contains "$d" 'revisão adversarial por subagente genérico — read-only não garantido' "agentes-dedicados/9 validate aviso"
q="$(flat "$R" '## No roteiro')"
assert_contains "$q" 'Nem o `revisor` nem o subagente genérico puderam ser despachados' "agentes-dedicados/10 validate nenhum rodou"
assert_contains "$q" 'revisão adversarial não rodou — <motivo>' "agentes-dedicados/10 validate linha de hoje"

report
