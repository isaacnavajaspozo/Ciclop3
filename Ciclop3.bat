@echo off
title Herramienta Avanzada de Seguridad - CMD
color 0A
setlocal EnableDelayedExpansion
chcp 65001 >nul


:: Establecer tamaño de la consola al máximo posible
:menu
cls   
echo "      __________ .__        .__                  ________
echo "      \_    ___ \|__| _____ |  |   ______ _______\_____  \
echo "      /     \  \/|  |/ ____\|  |  /  _   \\____  \ _(__  <
echo "      \      \___|  \  \____|  |_(  <◕>   )  |_>  >       \
echo "       \_______  /__|\____  >____/\______/|   ___/______  /
echo "               \/         \/              |__|          \/
echo ===================================================================================
echo    Mantenimiento de Seguridad
echo ===================================================================================
echo 1.  Run Windows Defender       :: Analizar el sistema en busca de actividades sospechosas.
echo 2.  Run MRT                    :: Eliminar software malicioso de sistemas operativos Windows.
echo 3.  Run SFC                    :: Escanea y repara archivos que pueden estar dañados o faltantes.
echo 4.  Run DISM                   :: Mantiene y repara imágenes de Windows.
echo 5.  Windows Key                :: Obtener clave del sistema, perfecto para obtener claves OEM.
echo 6.  Suspicious Processes       :: Identificación de procesos sospechosos en el sistema.
echo 7.  Nwtworking Connect         :: Monitorear conexiones de red activas.
echo 8.  Disk Usage                 :: Evaluar el uso del disco.
echo 9.  Remove tmp                 :: Eliminar archivos temporales.
echo 10. Login Tracker              :: Crea un archivo en el escritorio con los últimos 10 eventos de inicio de sesión.
echo 11. Change Networking          :: Cambiar la configuración del tipo de red.
echo 12. Windows Update             :: Comprobar actualizaciones de Windows.
echo 13. MAS ~ [GitHub]             :: Script para activar claves de Windows (recomendado solo para laboratoríos).
echo 14. Manual de recomendaciones  :: Enumera reglas de acción para una ciberseguridad útil en Windows.
echo 15. Exit                       :: Salir de la aplicación.
echo ===================================================================================
set /p option=Selecciona una opcion (1-15): 

if "%option%"=="1" goto scan
if "%option%"=="2" goto mrtactivity
if "%option%"=="3" goto sfc
if "%option%"=="4" goto dism
if "%option%"=="5" goto getkey
if "%option%"=="6" goto procesos
if "%option%"=="7" goto conexiones
if "%option%"=="8" goto diskusage
if "%option%"=="9" goto cleantemp
if "%option%"=="10" goto logintracker
if "%option%"=="11" goto changenetworking
if "%option%"=="12" goto windowsupdate
if "%option%"=="12" goto mas
if "%option%"=="13" goto manual
if "%option%"=="14" exit
goto menu


:: [SCAN]
:scan
echo 📌 "Comprueba:: Seguridad de Windows > Protección antivirus y contra amenazas > Protección en tiempo real > Activado"
echo 📌 "Comprueba:: Seguridad de Windows > Control de aplicaciones y navegador > Protección basada en reputación > Activar"
echo 📌 "Comprueba:: Seguridad de Windows > Seguridad del dispositivo > Integridad de memoria > Activado"
echo Iniciando escaneo rápido con Windows Defender...
start /wait "" "C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -ScanType 1

:: Verificar el resultado del escaneo
echo Verificando resultados del escaneo...
powershell -command "Get-MpThreat | Format-Table -AutoSize" > resultados.txt

:: Mostrar resultados
if %errorlevel% == 0 (
    for /f "tokens=*" %%a in (resultados.txt) do set encontrado=1
) else (
    set encontrado=0
)

if defined encontrado (
    echo.
    echo Se han encontrado amenazas:
    echo.
    type resultados.txt
    echo.
    echo Revisa los detalles arriba.
    echo.
) else (
    echo No se encontraron amenazas.
)

del resultados.txt
pause
goto menu


:: [MRTACTIVITY]
:mrtactivity
echo ¿Deseas ejecutar MRT en modo silencioso? (s/n)
set /p mode="Ingresa tu opción: "

:: Ejecutar MRT en segundo plano
if /i "%mode%"=="s" (
    echo Iniciando el análisis completo con MRT en modo silencioso...
    start "" /b cmd /c "mrt.exe /F:Y /Q"
    echo Para comprobar los archivos encontrados como sospechosos:: C:\Windows\Debug\mrt.log
) else (
    echo Iniciando el análisis completo con MRT...
    start "" /b cmd /c "mrt.exe /F:Y"
)

:: Mostrar el contenido del archivo mrt.log
echo Mostrando los archivos escaneados y las acciones de MRT...

pause
goto menu


:: [SFD]
:sfc
echo Ejecutando Comprobador de Archivos de Sistema (SFC)...
sfc /scannow
pause
goto menu


:: [DISM]
:dism
echo Ejecutando DISM para reparar la imagen de Windows...
dism /Online /Cleanup-Image /RestoreHealth
pause
goto menu


:: [SCANVULNERABILITIES]
:scanvulnerabilities
echo Escaneando vulnerabilidades del sistema...
echo.

:: Usar PowerShell para escanear vulnerabilidades
powershell -Command "
    $vulnerabilities = Get-WindowsUpdate | Where-Object { $_.IsInstalled -eq $false }
    if ($vulnerabilities) {
        Write-Host 'Actualizaciones de seguridad pendientes:'
        $vulnerabilities | Select-Object -Property Title, Description
    } else {
        Write-Host 'No se encontraron vulnerabilidades conocidas.'
    }
"
pause
goto menu


:: [PROCESS] 
:procesos
cls
echo 🕵️‍♂️ Procesos en ejecución:
echo ==================================================================================
tasklist /v | findstr /i "exe"
echo ==================================================================================
echo 🔎 Si ves nombres extraños, investígalos en DuckDuckGo.
pause
goto menu


:: [GETKEY]
:getkey
@echo off
echo Obteniendo clave de producto de Windows...
for /f "tokens=* delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$key=(Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey; if ($key) { Write-Output $key } else { Write-Output 'No se encontró clave' }"') do set "productKey=%%i"

echo La clave de producto de Windows es: %productKey%
pause
goto menu


:: [CONECTION]
:conexiones
cls
echo 🌐 Conexiones de red activas:
echo ==================================================================================
netstat -ano
echo ==================================================================================
echo 🛑 Si ves una IP desconocida conectada a un puerto extraño, investígala.
pause
goto menu


:: [DISKUSAGE]
:diskusage
echo Verificando uso del disco...
echo.

powershell -Command "Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name='FreeSpace(GB)';Expression={[math]::round($_.Free/1GB,2)}}, @{Name='UsedSpace(GB)';Expression={[math]::round(($_.Used)/1GB,2)}}, @{Name='TotalSize(GB)';Expression={[math]::round(($_.Used + $_.Free)/1GB,2)}}"

pause
goto menu


:: [CLEANTMP]
:cleantemp
@echo off
echo Limpiando archivos temporales...
echo.

:: Eliminar archivos dentro de la carpeta TEMP
del /s /q "%temp%\*.*"

:: Eliminar carpetas vacías dentro de TEMP
for /d %%x in ("%temp%\*") do rd /s /q "%%x"

:: Confirmar la limpieza
echo Archivos temporales eliminados.
pause
goto menu


:: [logintracker]
:logintracker
@echo off

:: Definir el archivo de registro
set logFile=%USERPROFILE%\Desktop\Ciclop3_login_tracker.txt

:: Verificar si el archivo de registro existe, si no, crearlo
if not exist "%logFile%" (
    echo Creando archivo de registro en el escritorio...
    echo. > "%logFile%"  :: Crea el archivo vacío si no existe
)

:: Registrar el timestamp y el mensaje de instalación
set timestamp=%date% %time%
echo %timestamp% - Instalando Ciclop3... >> "%logFile%"

:: Ejecutar el bucle para registrar eventos de seguridad controlados
for /L %%i in (1,1,5) do (
    echo Registro de evento %%i... >> "%logFile%"
    call :LogSecurityEvents %%i
)

:: Obtener los últimos 10 eventos de seguridad (ID de evento 4624 -> Inicio de sesión exitoso)
echo Registrando eventos de seguridad en el archivo: %logFile%
wevtutil qe Security "/q:*[System[(EventID=4624)]]" /f:text /c:10 >> "%logFile%"
echo Evento(s) registrado(s) exitosamente.

pause
goto menu


:: Función para registrar eventos de seguridad
:LogSecurityEvents
setlocal
set eventID=%1

:: Aquí puedes agregar la lógica para personalizar los eventos según el número del evento
:: En este ejemplo, simplemente se registra el evento con el número correspondiente
set timestamp=%date% %time%
echo. >> "%logFile%"
echo ------------------------------------------------------ >> "%logFile%"
echo Evento de inicio de sesión (ID: 4624) - Evento %%eventID%% >> "%logFile%"
echo ------------------------------------------------------ >> "%logFile%"
echo. >> "%logFile%"

:: Aquí agregamos la información del evento de inicio de sesión
echo Firmante: >> "%logFile%"
echo   Id. de seguridad:     S-1-5-18 >> "%logFile%"
echo   Nombre de cuenta:     WIN-PLFA3OEH6IF$ >> "%logFile%"
echo   Dominio de cuenta:    WORKGROUP >> "%logFile%"
echo   Id. de inicio de sesión: 0x3E7 >> "%logFile%"

echo. >> "%logFile%"
echo Información de inicio de sesión: >> "%logFile%"
echo   Tipo de inicio de sesión: 5 >> "%logFile%"
echo   Modo de administrador restringido: - >> "%logFile%"
echo   Credential Guard remota: - >> "%logFile%"
echo   Cuenta virtual: No >> "%logFile%"
echo   Token elevado: Sí >> "%logFile%"

echo. >> "%logFile%"
echo Nivel de suplantación: Suplantación >> "%logFile%"

echo. >> "%logFile%"
echo Nuevo inicio de sesión: >> "%logFile%"
echo   Id. de seguridad:     S-1-5-18 >> "%logFile%"
echo   Nombre de cuenta:     SYSTEM >> "%logFile%"
echo   Dominio de cuenta:    NT AUTHORITY >> "%logFile%"
echo   Id. de inicio de sesión: 0x3E7 >> "%logFile%"
echo   Inicio de sesión vinculado: 0x0 >> "%logFile%"

echo. >> "%logFile%"
echo Información de proceso: >> "%logFile%"
echo   Id. de proceso: 0x350 >> "%logFile%"
echo   Nombre de proceso: C:\Windows\System32\services.exe >> "%logFile%"

echo. >> "%logFile%"
echo Información de red: >> "%logFile%"
echo   Nombre de estación de trabajo: - >> "%logFile%"
echo   Dirección de red de origen: - >> "%logFile%"
echo   Puerto de origen: - >> "%logFile%"

echo. >> "%logFile%"
echo Información de autenticación detallada: >> "%logFile%"
echo   Proceso de inicio de sesión: Advapi >> "%logFile%"
echo   Paquete de autenticación: Negotiate >> "%logFile%"
echo   Servicios transitados: - >> "%logFile%"
echo   Nombre de paquete (solo NTLM): - >> "%logFile%"
echo   Longitud de clave: 0 >> "%logFile%"

echo. >> "%logFile%"
echo Este evento se genera cuando se crea una sesión de inicio. >> "%logFile%"
echo ------------------------------------------------------ >> "%logFile%"
echo. >> "%logFile%"

endlocal
goto :eof


:: [changenetworking]
:changenetworking
@echo off
cls
echo =========================================
echo      Cambiar Tipo de Red en Windows
echo =========================================
echo.
echo # Ejecutar como Administrador
echo.
for /f "tokens=1,2 delims=," %%A in ('powershell -Command "& {(Get-NetConnectionProfile | Where-Object {$_.NetworkCategory -ne 'NotConnected'} | Select-Object -First 1 -Property Name, NetworkCategory | ConvertTo-Csv -NoTypeInformation)}"') do (
    set "networkName=%%A"
    set "networkCategory=%%B"
)

rem Eliminar comillas y espacios adicionales
set "networkName=%networkName:"=%"
set "networkCategory=%networkCategory:"=%"
set "networkCategory=%networkCategory: =%"

echo Nombre de red      : %networkName%
echo Tipo de red actual : %networkCategory%

:: Verificar si se obtuvo un nombre válido
if "%networkName%"=="" (
    echo No se pudo detectar la red activa. Asegúrate de estar conectado a una red.
    pause
    exit
)

echo.

echo Selecciona el tipo de red:
echo 1. Privada
echo 2. Publica
echo 3. Dominio
set /p option=Ingresa el numero de tu eleccion: 

:: Cambiar tipo de red
if "%option%"=="1" (
    echo Cambiando la red a PRIVADA...
    PowerShell -Command "& {Set-NetConnectionProfile -Name '%networkName%' -NetworkCategory Private}"
    echo Cambio exitoso a Privada.
) 

if "%option%"=="2" (
    echo Cambiando la red a PUBLICA...
    PowerShell -Command "& {Set-NetConnectionProfile -Name '%networkName%' -NetworkCategory Public}"
    echo Cambio exitoso a Publica.
) 

if "%option%"=="3" (
    set /p domainName=Ingresa el nombre del dominio: 
    echo Uniendo al dominio %domainName%...
    PowerShell -Command "& {Add-Computer -DomainName '%domainName%' -Credential (Get-Credential) -Restart}"
    echo Intentando unir al dominio %domainName%.
)

echo.
echo Operacion completada.
pause
goto menu


:: [windowsupdate]
:windowsupdate
@echo off
echo Verificando actualizaciones de Windows...

:: Comprobar la versión actual de Windows
echo.
for /f "tokens=*" %%a in ('wmic os get version') do set version=%%a
echo Versión actual de Windows: %version%

:: Verificar si hay actualizaciones disponibles
echo Verificando actualizaciones disponibles...
wmic qfe list brief /format:table

:: Consultar el historial de actualizaciones
echo.
echo Verificando las actualizaciones instaladas:
wmic /namespace:\\root\cimv2 path Win32_QuickFixEngineering get HotFixID,Description,InstalledOn

:: Verificando si las actualizaciones instaladas son más recientes
echo.
echo Verificando si hay actualizaciones pendientes...
wmic qfe list brief | findstr /i "HotFix" >nul
if %errorlevel% neq 0 (
    echo No hay actualizaciones instaladas o disponibles para la versión de tu sistema.
) else (
    echo Hay actualizaciones instaladas o disponibles para la versión de tu sistema.

setlocal enabledelayedexpansion

echo Verificando la fecha de la última actualización instalada...

:: Obtener la fecha en formato para comparación (yyyyMMdd)
for /f "tokens=*" %%I in ('powershell -command "Get-WmiObject -Class Win32_QuickFixEngineering | Sort-Object InstalledOn -Descending | Select-Object -First 1 InstalledOn | ForEach-Object { $_.InstalledOn.ToString('yyyyMMdd') }"') do set lastInstalledDateCompare=%%I

:: Obtener la fecha en formato para mostrar (M/d/yyyy)
for /f "tokens=*" %%I in ('powershell -command "Get-WmiObject -Class Win32_QuickFixEngineering | Sort-Object InstalledOn -Descending | Select-Object -First 1 InstalledOn | ForEach-Object { $_.InstalledOn.ToString('M/d/yyyy') }"') do set lastInstalledDateDisplay=%%I

echo Fecha de la última actualización instalada: !lastInstalledDateDisplay!

:: Verificar las actualizaciones posteriores a la fecha de comparación
wmic /namespace:\\root\cimv2 path Win32_QuickFixEngineering where "InstalledOn > '!lastInstalledDateCompare!'" get HotFixID, InstalledOn > temp_updates.txt

set updatesAvailable=false
for /f "skip=1 tokens=*" %%A in (temp_updates.txt) do (
    set updatesAvailable=true
)

if !updatesAvailable! == true (
    echo 🚀 Hay actualizaciones programadas para ser instaladas en el futuro.
) else (
    echo 🚀 No hay actualizaciones pendientes por instalar.
)

del temp_updates.txt
)

pause
goto menu


:: [mas]
:mas
@echo off
echo ⚠️ Tienes que saber que instalaciones de este tipo que usan KMS para activar Windows son ilegales.
echo ⚠️ En este script la opción (MAS) es solo para trabajar en entornos de laboratorío controlados.
echo ⚠️ Instalar claves de Windows de sitios no-oficiales puede descargar y ejecutar contenido malicioso.
echo 🔔 Considera comprar una licencia OEM (vinculadas al hardware), suelen ser economicas y seguras.
echo 🔔 Comprueba antes la opción (5. Windows Key) para conservar tu clave actual.
echo.
set /p decision_licencia="🦧 ¿Quieres comprobar la validez de tu licencia? (s/n): "
if /i "%decision_licencia%"=="s" (
    echo Comprobando la licencia...
    powershell -Command "slmgr /dli"
) else (
    echo Operación cancelada.
)

echo.
echo ⚠️ Microsoft-Activation-Scripts::
echo 😺 https://github.com/massgravel/Microsoft-Activation-Scripts
set /p decision="¿Quieres descargar y ejecutar el activador de Windows? (s/n): "

if /i "%decision%"=="s" (
    echo Descargando y ejecutando el activador...
    powershell -Command "Invoke-RestMethod https://get.activated.win | Invoke-Expression"
) else (
    echo Operación cancelada.
)

pause
goto menu


:: [manual]
:manual
@echo off
@echo off
cls
echo =========================================
echo        📂 Manula virtual Ciclop3
echo =========================================
echo.
echo 📑 Recomendaciones para garantizar una óptima seguridad en Windows.
echo.
echo.
echo 🔥 Configuración por defecto::
echo *****************************************
echo.
echo [🔐 RDP]:
echo 📌 "Configuración > Sistema > Escritorio remoto > Desactivar"
echo.
echo [🔐 Pantalla de bloqueo]:
echo 📌 "Configuración > Personalización  > Pantalla de bloqueo >> Mostrar detalles de estado en la pantalla de bloqueo > Desactivar "
echo.
echo [🔐 UAC]:
echo 📌 "Cambiar configuración de Control de cuentas de usuario > ajústalo al máximo"
echo.
echo [🔐 Deshabilitar el uso compartido de archivos]:
echo 📌 "Panel de control > Centro de redes y recursos compartidos > Configuración avanzada de uso compartido > desactiva el uso compartido de archivos e impresoras"
echo.
echo [🔐 Permisos de aplicaciones]:
echo 📌 "Configuración > Privacidad y seguridad >  Permisos de Windows > revisar aplicaciones que tiengan acceso a la cámara, el micrófono, la ubicación..."
echo.
echo.
echo 🔥 Mejoras para mayor seguridad::
echo *****************************************
echo.
echo [🔐 Windows Defender]:
echo 📌 "Panel de control > Sistema y seguridad > Firewall de Windows Defender > Cambiar la configuración de notificaciones > Activar"
echo 📌 "Seguridad del dispositivo > Seguridad del dispositivo > Aislamiento del núcleo > Integridad de memoría > Activado."
echo 📌 "Seguridad de Windows > Protección antivirus y contra amenazas > Protección en tiempo real > Activado"
echo 📌 "Seguridad de Windows > Control de aplicaciones y navegador > Protección basada en reputación > Activar"
echo 📌 "Seguridad de Windows > Seguridad del dispositivo > Integridad de memoria > Activado"
echo.
echo [🔐 Windows Update]:
echo 📌 "Configuración  > Windows Update > asegúrate de que las actualizaciones automáticas están activadas."
echo.
echo [🔐 Servicios]:
echo 📌 "services.msc > Desactiva servicios que no uses."
echo.
echo [🔐 Evitar ancho de banda]:
echo 📌 "Configuración  > Windows Update > Opciones avanzadas > Optimización de entrega > Permitir descargas desde otros PC >> Desactiva"
echo.
echo [🔐 Usuario sin privilegios]:
echo 📌 "Crea una cuenta estándar para uso diario y usa la de administrador solo cuando sea necesario."
echo.
echo [🔐 Activar BitLocker]:
echo 📌 "Panel de control > Cifrado de unidad BitLocker"
echo.
echo [🔐 Deshabilitar macros en Office]:
echo 📌 "Archivo  > Opciones  > Centro de confianza > Configuración de macros >> Deshabilitar macros con notificación"
echo.
echo [🔐 Administrador de contraseñas]:
echo 📌 "Usa contraseñas largas y únicas para cada servicio."
echo 📌 "Utiliza KeePass o KeePassXC para tener acceso a claves 2FA y guarda su base de datos en el OneDrive una cuenta exclusiva "
echo.
echo [🔐 Administrador de contraseñas]:
echo 📌 "Usa contraseñas largas y únicas para cada servicio."
echo 📌 "Activa 2FA en tu cuenta de Microssoft."
echo 📌 "Utiliza KeePass o KeePassXC para tener acceso a claves 2FA."
echo.
echo [🔑 ¿Donde guardar base de datos del archivo KeePass?]:
echo 📌 "Guarda el archivo en OneDrive o Google Drive en una cuenta con 2FA."
echo 📌 "El archivo tiene que estar cifrado con Cryptomator."
echo 📌 "Puedes utilizar un YubiKey o un Trezor económico en vez de la solución anterior."
echo.
echo.
pause
goto menu
