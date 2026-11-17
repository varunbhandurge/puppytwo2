@echo off
title Two Puppies: The Great Adventure
echo ===============================================================================
echo            TWO PUPPIES: THE GREAT ADVENTURE (v1.0.0)
echo               Vulkan Forward+ - Local 2-Player Split-Screen
echo ===============================================================================
echo.
echo Launching standalone Windows PC release...

if exist "%~dp0dist\TwoPuppies_Windows_x64\TwoPuppiesTheGreatAdventure.exe" (
    cd /d "%~dp0dist\TwoPuppies_Windows_x64"
    start "" "TwoPuppiesTheGreatAdventure.exe"
    exit /b 0
)

echo Standalone binary not found in dist. Launching via Godot Engine...
cd /d "%~dp0"
godot
