@echo off
rem -- Run Vim --

set VIM_EXE_DIR=D:\Program Files (x86)\gVimPortable_7.4\vim74
if exist "%VIM%\vim74\vim.exe" set VIM_EXE_DIR=%VIM%\vim74
if exist "%VIMRUNTIME%\vim.exe" set VIM_EXE_DIR=%VIMRUNTIME%

if exist "%VIM_EXE_DIR%\vim.exe" goto havevim
echo "%VIM_EXE_DIR%\vim.exe" not found
goto eof

:havevim
rem collect the arguments in VIMARGS for Win95
set VIMARGS=
:loopstart
if .%1==. goto loopend
set VIMARGS=%VIMARGS% %1
shift
goto loopstart
:loopend

if .%OS%==.Windows_NT goto ntaction

"%VIM_EXE_DIR%\vim.exe"  %VIMARGS%
goto eof

:ntaction
rem for WinNT we can use %*
"%VIM_EXE_DIR%\vim.exe"  %*
goto eof


:eof
set VIMARGS=
