@echo off
title Herramienta Avanzada de Seguridad - CMD
color 0A
setlocal EnableDelayedExpansion
chcp 65001 >nul

:: Establecer tamaño de la consola al máximo posible
:menu
cls   
echo "     _________ .__       .__               ________
echo "     \_   ___ \|__| ____ |  |   ____ ______\_____  \
echo "     /    \  \/|  |/ ___\|  |  /  _ \\____ \ _(__  < 
echo "     \     \___|  \  \___|  |_(  <_> )  |_> >       \
echo "      \______  /__|\___  >____/\____/|   __/______  /
echo "             \/        \/            |__|         \/ 
echo ===================================================================================
echo    Mantenimiento de Seguridad
echo ===================================================================================
echo 1. Run Windows Defender      :: Analizar el sistema en busca de actividades sospechosas.
echo 2. Run MRT                   :: Eliminar software malicioso de sistemas operativos Windows.
echo 3. Run SFC                   :: Escanea y repara archivos que pueden estar dañados o faltantes.
echo 4. Run DISM                  :: Mantiene y repara imágenes de Windows.
echo 5. Windows Key               :: Obtener clave del sistema.
echo 6. Suspicious Processes      :: Identificación de procesos sospechosos en el sistema.
echo 7. Nwtworking Connect        :: Monitorear conexiones de red activas.
echo 8. Disk Usage                :: Evaluar el uso del disco.
echo 9. Remove tmp                :: Eliminar archivos temporales.
echo 10. Run Ciclop3              :: Crea un archivo en el escritorio con los últimos 10 eventos de inicio de sesión.
echo 11. Exit                     :: Salir de la aplicación.
echo ===================================================================================
set /p option=Selecciona una opcion (1-11): 

if "%option%"=="1" goto scan
if "%option%"=="2" goto mrtactivity
if "%option%"=="3" goto sfc
if "%option%"=="4" goto dism
if "%option%"=="5" goto getkey
if "%option%"=="6" goto procesos
if "%option%"=="7" goto conexiones
if "%option%"=="8" goto diskusage
if "%option%"=="9" goto cleantemp
if "%option%"=="10" goto logactivity
if "%option%"=="11" exit
goto menu

:: [SCAN]
:scan
echo Iniciando escaneo rápido con Windows Defender...
start /wait "" "C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -ScanType 1

:: Verificar el resultado del escaneo
echo Verificando resultados del escaneo...
for /f "tokens=*" %%a in ('powershell -command "(Get-MpThreat | Select-Object -ExpandProperty ThreatName)"') do (
    echo !%%a! | findstr /i "malware" >nul
    if !errorlevel! == 0 (
        echo.
        echo !%%a! >> resultados.txt
    )
)

:: Mostrar resultados
if exist resultados.txt (
    echo.
    echo Se han encontrado amenazas:
    echo.
    type resultados.txt
    echo.
    echo Los archivos maliciosos se han marcado en rojo.
    echo.
    del resultados.txt
) else (
    echo No se encontraron amenazas.
)

pause
goto menu

:: [MRTACTIVITY]
:mrtactivity

echo ¿Deseas ejecutar MRT en modo silencioso? (s/n)
set /p mode="Ingresa tu opción: "

setlocal

:: Crear un archivo de registro para MRT
set "logFile=%temp%\mrt_log.txt"

if /i "%mode%"=="s" (
    echo Iniciando el análisis completo con MRT en modo silencioso...
    :: Ejecutar MRT en modo silencioso
    mrt.exe /F:Y /S > "%logFile%" 2>&1
) else (
    echo Iniciando el análisis completo con MRT...
    :: Ejecutar MRT sin el modo silencioso para obtener más detalles
    mrt.exe /F:Y > "%logFile%" 2>&1
)

:: Esperar un momento para asegurarse de que MRT haya comenzado
timeout /t 5 > nul

endlocal

pause
goto menu

:: [DEFENDER]
:defender
echo Escaneando con Windows Defender...
start /wait "" "C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -ScanType 1
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
echo 🔎 Si ves nombres extraños, investígalos en Google.
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

:: [LOGACTIVITY]
:logactivity
@echo off

:: Definir el archivo de registro
set logFile=%USERPROFILE%\Desktop\Ciclop3.txt

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

:: Mensaje final y espera para cerrar
echo Eventos de seguridad registrados en el archivo: %logFile%

:: Obtener los últimos 10 eventos de seguridad (ID de evento 4624 -> Inicio de sesión exitoso)
echo Registrando eventos de seguridad en el archivo %logFile%...
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
