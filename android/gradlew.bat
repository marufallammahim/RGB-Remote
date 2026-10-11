@echo off
setlocal
set "APP_HOME=%~dp0"
set "GRADLE_VERSION=8.14.3"
if not defined GRADLE_USER_HOME set "GRADLE_USER_HOME=%USERPROFILE%\.gradle"
set "DIST_ROOT=%GRADLE_USER_HOME%\wrapper\dists\gradle-%GRADLE_VERSION%-all\manual"
set "GRADLE_HOME=%DIST_ROOT%\gradle-%GRADLE_VERSION%"
if not exist "%GRADLE_HOME%\bin\gradle.bat" (
  if not exist "%DIST_ROOT%" mkdir "%DIST_ROOT%"
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $zip=Join-Path $env:DIST_ROOT 'gradle.zip'; Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-8.14.3-all.zip' -OutFile $zip; Expand-Archive -Path $zip -DestinationPath $env:DIST_ROOT -Force; Remove-Item $zip -Force"
  if errorlevel 1 exit /b %ERRORLEVEL%
)
call "%GRADLE_HOME%\bin\gradle.bat" %*
exit /b %ERRORLEVEL%
