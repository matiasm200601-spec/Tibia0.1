@echo off
title GitHub Manager - Tibia0.1
cd /d "%~dp0"

:MENU
cls
echo ============================================
echo      GITHUB MANAGER - TIBIA 0.1
echo ============================================
echo.
echo    Repositorio: Tibia0.1
echo    Usuario: matiasm200601@gmail.com
echo.
echo --------------------------------------------
echo.
echo    [1] CARGAR - Subir cambios a GitHub
echo.
echo    [2] CARGAR TODO - Subir TODOS los archivos
echo.
echo    [3] DESCARGAR - Bajar archivos de GitHub
echo.
echo    [4] Salir
echo.
echo --------------------------------------------
echo.
set /p opcion="    Selecciona una opcion (1, 2, 3 o 4): "

if "%opcion%"=="1" goto CARGAR
if "%opcion%"=="2" goto CARGAR_TODO
if "%opcion%"=="3" goto DESCARGAR
if "%opcion%"=="4" goto SALIR
echo.
echo    Opcion no valida. Intenta de nuevo.
timeout /t 2 >nul
goto MENU

:CARGAR
cls
echo ============================================
echo      CARGANDO ARCHIVOS A GITHUB
echo ============================================
echo.

echo [1/6] Configurando usuario Git...
git config user.email "matiasm200601@gmail.com"
git config user.name "matiasm200601-spec"

if not exist ".git" (
    echo [2/6] Inicializando repositorio Git...
    git init
    git remote add origin https://github.com/matiasm200601-spec/Tibia0.1.git
) else (
    echo [2/6] Repositorio Git ya existe
    git remote set-url origin https://github.com/matiasm200601-spec/Tibia0.1.git
)

echo [3/6] Eliminando archivo .gitignore si existe...
if exist ".gitignore" (
    del /f /q ".gitignore"
    echo    .gitignore eliminado
) else (
    echo    No hay .gitignore
)

echo [4/6] Agregando TODOS los archivos...
git add -A --force

git diff --staged --quiet
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo    No hay cambios para subir
    echo ============================================
    echo.
    pause
    goto MENU
)

echo [5/6] Creando commit...
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set FECHA=%datetime:~6,2%-%datetime:~4,2%-%datetime:~0,4%
set HORA=%datetime:~8,2%:%datetime:~10,2%
git commit -m "Update %FECHA% %HORA%"

echo [6/6] Subiendo TODOS los archivos a GitHub...
git branch -M main
git push -u origin main --force

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo    TODOS LOS ARCHIVOS SUBIDOS EXITOSAMENTE
    echo ============================================
    echo.
    echo    Ver en: https://github.com/matiasm200601-spec/Tibia0.1
    echo.
) else (
    echo.
    echo ============================================
    echo    ERROR AL SUBIR ARCHIVOS
    echo ============================================
    echo.
    echo    Verifica tu conexion a internet y
    echo    tus credenciales de GitHub.
    echo.
)
pause
goto MENU

:CARGAR_TODO
cls
echo ============================================
echo    SUBIR TODOS LOS ARCHIVOS A GITHUB
echo ============================================
echo.
echo ADVERTENCIA: Esto eliminara el historial de Git
echo y subira TODOS los archivos como nuevos.
echo.
set /p confirmar="Estas seguro? (S/N): "
if /i not "%confirmar%"=="S" (
    echo Operacion cancelada.
    pause
    goto MENU
)

echo.
echo [1/8] Eliminando repositorio Git local...
if exist ".git" (
    rmdir /s /q ".git"
    echo    Repositorio eliminado
)

echo [2/8] Eliminando .gitignore...
if exist ".gitignore" (
    del /f /q ".gitignore"
    echo    .gitignore eliminado
)

echo [3/8] Inicializando nuevo repositorio...
git init

echo [4/8] Configurando usuario...
git config user.email "matiasm200601@gmail.com"
git config user.name "matiasm200601-spec"

echo [5/8] Agregando TODOS los archivos...
git add -A --force

echo [6/8] Creando commit inicial...
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set FECHA=%datetime:~6,2%-%datetime:~4,2%-%datetime:~0,4%
set HORA=%datetime:~8,2%:%datetime:~10,2%
git commit -m "Full upload %FECHA% %HORA%"

echo [7/8] Configurando repositorio remoto...
git remote add origin https://github.com/matiasm200601-spec/Tibia0.1.git
git branch -M main

echo [8/8] Subiendo TODO a GitHub (forzado)...
git push -u origin main --force

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo    TODOS LOS ARCHIVOS SUBIDOS
    echo ============================================
    echo.
    echo    Se subieron TODOS los archivos del servidor.
    echo    Ver en: https://github.com/matiasm200601-spec/Tibia0.1
    echo.
) else (
    echo.
    echo ============================================
    echo    ERROR AL SUBIR ARCHIVOS
    echo ============================================
    echo.
    echo    Verifica tu conexion y credenciales.
    echo.
)
pause
goto MENU

:DESCARGAR
cls
echo ============================================
echo      DESCARGANDO ARCHIVOS DE GITHUB
echo ============================================
echo.

if not exist ".git" (
    echo ADVERTENCIA: No hay repositorio Git local.
    echo.
    echo Opciones:
    echo   [1] Inicializar y descargar archivos
    echo   [2] Cancelar
    echo.
    set /p init_opt="Selecciona (1 o 2): "
    
    if not "!init_opt!"=="1" (
        echo Operacion cancelada.
        pause
        goto MENU
    )
    
    echo.
    echo [1/5] Inicializando repositorio Git...
    git init
    
    echo [2/5] Configurando usuario...
    git config user.email "matiasm200601@gmail.com"
    git config user.name "matiasm200601-spec"
    
    echo [3/5] Agregando repositorio remoto...
    git remote add origin https://github.com/matiasm200601-spec/Tibia0.1.git
    
    echo [4/5] Descargando archivos de GitHub...
    git fetch origin main
    
    echo [5/5] Aplicando archivos descargados...
    git reset --hard origin/main
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo ============================================
        echo    ARCHIVOS DESCARGADOS EXITOSAMENTE
        echo ============================================
        echo.
        echo    Todos los archivos fueron descargados
        echo    desde GitHub a esta carpeta.
        echo.
    ) else (
        echo.
        echo ============================================
        echo    ERROR AL DESCARGAR ARCHIVOS
        echo ============================================
        echo.
        echo    Verifica tu conexion a internet.
        echo.
    )
) else (
    echo [1/5] Configurando usuario Git...
    git config user.email "matiasm200601@gmail.com"
    git config user.name "matiasm200601-spec"
    
    echo [2/5] Eliminando archivo .gitignore si existe...
    if exist ".gitignore" (
        del /f /q ".gitignore"
        echo    .gitignore eliminado
    ) else (
        echo    No hay .gitignore
    )
    
    echo [3/5] Descartando TODOS los cambios locales...
    git reset --hard HEAD
    git clean -fd
    
    echo [4/5] Descargando actualizaciones de GitHub...
    git fetch origin main
    
    echo [5/5] Aplicando version de GitHub...
    git reset --hard origin/main
    git clean -fd
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo ============================================
        echo    ARCHIVOS DESCARGADOS EXITOSAMENTE
        echo ============================================
        echo.
        echo    Todos los archivos locales fueron
        echo    actualizados con la version de GitHub.
        echo.
    ) else (
        echo.
        echo ============================================
        echo    ERROR AL DESCARGAR ARCHIVOS
        echo ============================================
        echo.
        echo    Verifica tu conexion a internet.
        echo.
    )
)
pause
goto MENU

:SALIR
cls
echo.
echo    Saliendo...
echo.
timeout /t 1 >nul
exit
