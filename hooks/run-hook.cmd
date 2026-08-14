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
REM Uso: run-hook.cmd <nome-do-script> [args...]

if "%~1"=="" (
    echo run-hook.cmd: faltou nome do script >&2
    exit /b 1
)

set "HOOK_DIR=%~dp0"

REM Tenta Git for Windows bash nos caminhos padrao
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    "C:\Program Files (x86)\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

REM Tenta bash no PATH (Git Bash instalado pelo usuario, MSYS2, Cygwin)
where bash >nul 2>nul
if %ERRORLEVEL% equ 0 (
    bash "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

REM Sem bash: sai em silencio em vez de erro
REM (plugin continua funcionando, so sem a injecao de contexto)
exit /b 0
CMDBLOCK

# Unix: executa o script nomeado diretamente
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
shift
exec bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
