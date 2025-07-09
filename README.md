# WhoLock
---
Show who locked the file.<br>
The utility shows who locked the file.<br>
Tested on Windows Server 2022 Standard<br>
Work only with administrator rights.<br>
---
Important<br>
Before using — run the utility .\Sysinternals\handle.exe once.<br>
Edit the path to the file wholock.exe in the .\RegMenu\menu_all.reg file.<br>
Run menu_all.reg — this adds the utility to the right-click context menu (File Explorer).<br>
Or<br>
1. Run wholock.exe  <br>
2. Select the locked file  <br>
---

![app image](Screenshots/wholock.jpg)
<br>

Create EXE file from PS1<br>
ps2exe .\wholock.ps1 .\wholock.exe -noConsole -sta -winform -noOutput


------------------------------------------------------------------------------------

Ukraine<br>
WhoLock<br>
Вивести хто заблокував файл.<br>

Важливо<br>
Перед використанням запустіть утиліту .\Sysinternals\handle.exe один раз.<br>
Відредагуйте шлях до утиліти у файлі .\RegMenu\menu_all.reg.<br>
Запустіть menu_all.reg — це додасть утиліту до контекстного меню, яке викликається  правою кнопкою миші на файлі (File Explorer).<br>
1. Запустити wholock.exe<br>
2. Вибрати заблокований файл файл<br>

Створити EXE file з PS1
ps2exe .\wholock.ps1 .\wholock.exe -noConsole -sta -winform -noOutput
---
Oleh Malovichko
