
:: arun.cmd xxfile = 
:: adb push xxfile && && adb chmod 6755 xxfile && adb shell ls xxfile && adb shell xxfile

@SET dstPath=/data/local/tmp
@SET dstFilePath=%dstPath%/%~n1

@set /p="%dstFilePath%: "<nul
@adb push %1 %dstFilePath%
::@echo [OK]push %1 %dstFilePath%

:: @echo chmod 6755 %dstFilePath% ^^^&^^^& ls -l %dstFilePath% ^^^&^^^& %dstFilePath% ^^^&^^^& exit | CALL adb shell

:::: should be call in a console, or auto-exit when dragging a file into this bat file.
:: @CALL adb shell "chmod 6755 %dstFilePath% && ls -l %dstFilePath% && %dstFilePath%"
@adb shell "chmod 6755 %dstFilePath% && ls -l %dstFilePath% && %dstFilePath%"

@goto end

:echo_dont_wrap_example
:: ECHO don't wrap
@echo off
set /p="hello "<nul
set /p="world "<nul
echo again
echo new line
:: Result:
::  hello world again
::  new line

:end
