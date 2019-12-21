@echo off

set CURR_DIR=%~dp0
set MINECRAFT_PATH=C:\Program Files (x86)\Minecraft Launcher\runtime\jre-x64

cd %MINECRAFT_PATH% >nul 2>&1
if %errorLevel% NEQ 0 (
	echo [105;30m - Install Minecraft or fix the path - [0m
	echo https://launcher.mojang.com/download/MinecraftInstaller.msi
	goto quit
)

net session >nul 2>&1
if %errorLevel% NEQ 0 (
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
	set NEWLINE=^& echo.

	:: It brokes the hosts file. I'll fix it soon.
	find /C /I "authserver.mojang.com" %WINDIR%\system32\drivers\etc\hosts >nul 2>&1
	if %ERRORLEVEL% NEQ 0 (
		echo %NEWLINE%^35.156.90.191 authserver.mojang.com>>%WINDIR%\system32\drivers\etc\hosts
	)
	find /C /I "sessionserver.mojang.com" %WINDIR%\system32\drivers\etc\hosts >nul 2>&1
	if %ERRORLEVEL% NEQ 0 (
		echo %NEWLINE%^35.156.90.191 sessionserver.mojang.com>>%WINDIR%\system32\drivers\etc\hosts
	)
	
	echo [102;30m - Java / authserver.mojang.com - [0m
	bin\keytool -noprompt -storepass "changeit" -import -alias authserver.mojang.com -file "%CURR_DIR%\authserver.mojang.com.crt" -keystore "lib\security\cacerts"
	echo [102;30m - Java / sessionserver.mojang.com - [0m
	bin\keytool -noprompt -storepass "changeit" -import -alias sessionserver.mojang.com -file "%CURR_DIR%\sessionserver.mojang.com.crt" -keystore "lib\security\cacerts"
	
	echo [102;30m - Windows / Root / authserver.mojang.com - [0m
	certutil -addstore "Root" "%CURR_DIR%\authserver.mojang.com.crt"
	
	goto quit

:uninstall
	:: Or mb this one brokes. Dunno yet. ;P
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