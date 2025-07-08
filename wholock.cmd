@echo off
set FILEPATH=%1

powershell -Command "Start-Process powershell -ArgumentList '-File \"wholock.ps1\" -FilePath \"%FILEPATH%\"' -Verb runAs"


rem powershell -Command "Start-Process powershell -ArgumentList '-File \"lockedFile.ps1\"' -Verb runAs"

