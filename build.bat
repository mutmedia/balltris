@echo off
:: CONFIG
SET ANDROID_TOOLS=.\android
SET LOVE_ANDROID= %ANDROID_TOOLS%\love_decoded
SET LOVE_PATH=C:\Program Files\LOVE

SET YY=%date:~-2%
SET MM=%date:~0,2%
SET DD=%date:~3,2%
SET dateStr=%YY%.%MM%.%DD%
echo %dateStr%

set /p iteration=<ver.txt
set /a iteration=%iteration%+1
echo %iteration%>ver.txt

set versionName=%date:-=.%.%iteration%

:: BASE BUILD
rd /s /q build
xcopy /s "%LOVE_PATH%\*.dll" build\win\
pushd game & 7z a -tzip ..\build\game.love * & popd

:: WINDOWS
copy /b "%LOVE_PATH%\love.exe"+build\game.love build\win\game.exe

7z a -tzip build\balltris-win-%versionName%.zip .\build\win\

:: ANDROID
echo Starting android build
echo Copying game.love to assets
copy /y /v .\build\game.love %LOVE_ANDROID%\assets\

echo Creating app from apktool
call apktool b -o build\balltris-unsigned.apk %LOVE_ANDROID% 
java -jar %ANDROID_TOOLS%\uber-apk-signer.jar --apks build\balltris-unsigned.apk --out build\ 

move ".\build\balltris-aligned-debugSigned.apk" ".\build\balltris-android-%versionName%.apk"

