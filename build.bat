SET LOVE_ANDROID=C:\Users\gusta\Desktop\games\love-android-sdl2
SET LOVE_PATH=C:\Program Files\LOVE

rd /s /q build
xcopy /s "%LOVE_PATH%\*.dll" build\
pushd game & 7z a -tzip ..\build\game.love *.lua & popd
copy /b "%LOVE_PATH%\love.exe"+build\game.love build\game.exe

copy build\game.love "%LOVE_ANDROID%\assets\"

7z a -tzip build\win_game.zip .\build\*

copy AndroidManifest.xml "%LOVE_ANDROID%\"
pushd "%LOVE_ANDROID%" & ant debug & popd
