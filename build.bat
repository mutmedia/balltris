rd /s /q build
xcopy /s "C:\Program Files\LOVE\*.dll" build\
7z a -tzip temp\game.love *.lua
copy /b "C:\Program Files\LOVE\love.exe"+temp\game.love build\game.exe
rd /s /q temp

xcopy /s /e data\*.lua build\data\

7z a -tzip win_game.zip .\build\*
