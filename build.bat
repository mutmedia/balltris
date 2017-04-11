rd /s /q build
xcopy /s "C:\Program Files\LOVE\*.dll" build\
7z a temp\game.love main.lua
copy /b "C:\Program Files\LOVE\love.exe"+temp\game.love build\game.exe
