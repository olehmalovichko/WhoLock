@echo off
rem set FILEPATH=%1
rem powershell -Command "Start-Process powershell -ArgumentList '-File \"wholock.ps1\" -FilePath \"%FILEPATH%\"' -Verb runAs"
rem powershell -Command "Start-Process powershell -ArgumentList '-File \"lockedFile.ps1\"' -Verb runAs"


rem Create exe file
rem ps2exe .\wholock.ps1 .\wholock.exe -noConsole -sta -winform -noOutput