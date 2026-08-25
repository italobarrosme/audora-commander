: << 'CMDBLOCK'
@echo off
REM Wrapper polyglot multiplataforma para scripts de hook.
REM No Windows: cmd.exe roda a parte batch, que acha e chama o bash.
REM No Unix: o shell interpreta este arquivo como script (: e no-op no bash).
REM
REM Scripts de hook usam nome sem extensao (ex.: "session-start", nao
REM "session-start.sh") para a auto-deteccao do Claude Code no Windows --
REM que prefixa "bash" em comandos contendo .sh -- nao interferir.
REM
REM Este arquivo DEVE ficar em LF (.gitattributes): a parte bash quebra com
REM CRLF em Linux/macOS; cmd.exe aceita LF.
REM
REM Uso: run-hook.cmd <nome-do-script> [args...]

if "%~1"=="" (
    echo run-hook.cmd: faltou nome do script >&2
    exit /b 1
)

set "HOOK_DIR=%~dp0"
set "HOOK_BASH="

REM Tenta Git for Windows bash nos caminhos padrao, depois no PATH
if exist "C:\Program Files\Git\bin\bash.exe" set "HOOK_BASH=C:\Program Files\Git\bin\bash.exe"
if not defined HOOK_BASH if exist "C:\Program Files (x86)\Git\bin\bash.exe" set "HOOK_BASH=C:\Program Files (x86)\Git\bin\bash.exe"
if not defined HOOK_BASH (where bash >nul 2>nul && set "HOOK_BASH=bash")

REM Sem bash: sai em silencio em vez de erro
REM (plugin continua funcionando, so sem hooks)
if not defined HOOK_BASH exit /b 0

REM O exit fica FORA de bloco ( ): dentro de parenteses %ERRORLEVEL% expande
REM em parse-time (=0) e engoliria o exit 2 dos hooks -- o aviso nunca
REM chegaria ao modelo.
"%HOOK_BASH%" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %ERRORLEVEL%
CMDBLOCK

# Unix: executa o script nomeado diretamente
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
shift
exec bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
