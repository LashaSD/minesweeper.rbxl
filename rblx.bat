@echo off
setlocal EnableDelayedExpansion

set SRC=src
set NAME=minesweeper

if not exist "default.project.json" (
    echo Project not initialized
    exit /b 1
)

if "%1"=="" goto usage

if "%1"=="run" (
    start "Rojo Server" rojo serve default.project.json
    start "Rojo Sourcemap" rojo sourcemap --watch default.project.json --output sourcemap.json --include-non-scripts
    exit /b 0
)

if "%1"=="install" (
    aftman install
    wally install
    rojo sourcemap --output sourcemap.json --include-non-scripts
    wally-package-types --sourcemap sourcemap.json Packages/
    exit /b 0
)

if "%1"=="build" (
    rojo sourcemap --output sourcemap.json --include-non-scripts
    rojo build -o "%NAME%.rbxl" default.project.json
    exit /b 0
)

:usage
echo Usage: %0 [options]
echo.
echo Options:
echo   run           Run Rojo Server
echo   build         Builds the Game
echo   install       Install all Aftman and Wally Packages
echo.
echo Example:
echo   %0 run              Run Rojo Server
echo   %0 install          Install Packages
echo   %0 build            Build to game.rbxl
exit /b 1
