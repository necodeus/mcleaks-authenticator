@echo off
cls
set CURR_DIR=%~dp0

:: Install Minecraft Launcher from https://launcher.mojang.com/download/MinecraftInstaller.msi
:: and set your path:
cd "C:\Program Files (x86)\Minecraft Launcher\runtime\jre-x64"

:is_admin
	net session >nul 2>&1
	if %errorLevel% == 0 (
		goto list
	) else (
		echo [101;93m - Administrative permissions required - [0m
		goto quit
	)

:list
	echo ###
	echo # [101;93m 1 [0m Add certs
	echo # [101;93m 2 [0m Remove certs
	echo # [101;93m 3 [0m Show certs
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
	echo [101;93m - Java / authserver.mojang.com - [0m
	bin\keytool -storepass "changeit" -import -alias authserver.mojang.com -file "%CURR_DIR%\authserver.mojang.com.crt" -keystore "lib\security\cacerts"
	
	echo [101;93m - Java / sessionserver.mojang.com - [0m
	bin\keytool -storepass "changeit" -import -alias sessionserver.mojang.com -file "%CURR_DIR%\sessionserver.mojang.com.crt" -keystore "lib\security\cacerts"
	
	echo [101;93m - Windows / Root / authserver.mojang.com - [0m
	certutil -addstore "Root" "%CURR_DIR%\authserver.mojang.com.crt"
	
	goto quit

:uninstall
	echo [101;93m - Java / authserver.mojang.com - [0m
	bin\keytool -storepass "changeit" -delete -alias authserver.mojang.com -keystore "lib\security\cacerts"
	
	echo [101;93m - Java / sessionserver.mojang.com - [0m
	bin\keytool -storepass "changeit" -delete -alias sessionserver.mojang.com -keystore "lib\security\cacerts"
	
	echo [101;93m - Windows / Root / authserver.mojang.com - [0m
	certutil -delstore "Root" authserver.mojang.com
	
	goto quit

:show
	echo [101;93m - Java / authserver.mojang.com - [0m
	bin\keytool -list -storepass "changeit" -alias authserver.mojang.com -v -keystore "lib\security\cacerts"
	
	echo [101;93m - Java / sessionserver.mojang.com - [0m
	bin\keytool -list -storepass "changeit" -alias sessionserver.mojang.com -v -keystore "lib\security\cacerts"
	
	echo [101;93m - Windows / Root / authserver.mojang.com - [0m
	certutil -store "Root" authserver.mojang.com
	
	goto quit

:quit
	pause