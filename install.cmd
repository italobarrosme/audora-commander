: << 'CMDBLOCK'
@echo off
REM Wrapper polyglot multiplataforma do instalador do audora-commander.
REM No Windows: cmd.exe roda a parte batch, que acha e chama o bash.
REM No Unix: o shell interpreta este arquivo como script (: e no-op no bash).
REM
REM Uso: install.cmd  (equivalente a rodar ./install.sh em Unix/Git Bash)

set "SCRIPT_DIR=%~dp0"

if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%SCRIPT_DIR%install.sh"
    exit /b %ERRORLEVEL%
)
if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    "C:\Program Files (x86)\Git\bin\bash.exe" "%SCRIPT_DIR%install.sh"
    exit /b %ERRORLEVEL%
)

where bash >nul 2>nul
if %ERRORLEVEL% equ 0 (
    bash "%SCRIPT_DIR%install.sh"
    exit /b %ERRORLEVEL%
)

echo Nao encontrei o Git Bash nem o bash no PATH. >&2
echo Instale o Git for Windows (inclui bash) e rode install.cmd de novo: >&2
echo https://git-scm.com/download/win >&2
exit /b 1
CMDBLOCK

# Unix: delega para o instalador bash real
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec bash "${SCRIPT_DIR}/install.sh"
