@echo off
cls
set CURR_DIR=%~dp0

:: Install Minecraft Launcher from https://launcher.mojang.com/download/MinecraftInstaller.msi
:: and set your path:
cd "C:\Program Files (x86)\Minecraft Launcher\runtime\jre-x64"

net session >nul 2>&1
if %errorLevel% == 0 (
	goto list
) else (
	echo [105;30m - Administrative permissions required - [0m
	goto quit
)

:list
	echo ###
	echo # [103;30m 1 [0m Install hosts and certs
	echo # [103;30m 2 [0m Remove hosts and certs
	echo # [103;30m 3 [0m Show certs
	echo ###
	set /p choice="> "
	if %choice% == 1 (
		goto install
	) else if %choice% == 2 (
		goto uninstall
	) else if %choice% == 3 (
		goto show
	) else (
		goto quit
	)

:install
	SET NEWLINE=^& echo.

	FIND /C /I "authserver.mojang.com" %WINDIR%\system32\drivers\etc\hosts >nul 2>&1
	IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^35.156.90.191 authserver.mojang.com>>%WINDIR%\System32\drivers\etc\hosts
	
	FIND /C /I "sessionserver.mojang.com" %WINDIR%\system32\drivers\etc\hosts >nul 2>&1
	IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^35.156.90.191 sessionserver.mojang.com>>%WINDIR%\System32\drivers\etc\hosts
	
	echo [102;30m - Java / authserver.mojang.com - [0m
	bin\keytool -noprompt -storepass "changeit" -import -alias authserver.mojang.com -file "%CURR_DIR%\authserver.mojang.com.crt" -keystore "lib\security\cacerts"
	
	echo [102;30m - Java / sessionserver.mojang.com - [0m
	bin\keytool -noprompt -storepass "changeit" -import -alias sessionserver.mojang.com -file "%CURR_DIR%\sessionserver.mojang.com.crt" -keystore "lib\security\cacerts"
	
	echo [102;30m - Windows / Root / authserver.mojang.com - [0m
	certutil -addstore "Root" "%CURR_DIR%\authserver.mojang.com.crt"
	
	goto quit

:uninstall
	findstr /v "authserver.mojang.com sessionserver.mojang.com" %WINDIR%\system32\drivers\etc\hosts > %temp%\Mv830Ye9uL.hosts.tmp
	move /y %temp%\Mv830Ye9uL.hosts.tmp %WINDIR%\system32\drivers\etc\hosts >nul
	
	echo [101;30m - Java / authserver.mojang.com - [0m
	bin\keytool -storepass "changeit" -delete -alias authserver.mojang.com -keystore "lib\security\cacerts"
	
	echo [101;30m - Java / sessionserver.mojang.com - [0m
	bin\keytool -storepass "changeit" -delete -alias sessionserver.mojang.com -keystore "lib\security\cacerts"
	
	echo [101;30m - Windows / Root / authserver.mojang.com - [0m
	certutil -delstore "Root" authserver.mojang.com
	
	goto quit

:show
	echo [104;30m - Java / authserver.mojang.com - [0m
	bin\keytool -list -storepass "changeit" -alias authserver.mojang.com -v -keystore "lib\security\cacerts"
	
	echo [104;30m - Java / sessionserver.mojang.com - [0m
	bin\keytool -list -storepass "changeit" -alias sessionserver.mojang.com -v -keystore "lib\security\cacerts"
	
	echo [104;30m - Windows / Root / authserver.mojang.com - [0m
	certutil -store "Root" authserver.mojang.com
	
	goto quit

:quit
	pause