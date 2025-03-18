  
          __________ .__        .__                  ________
          \_    ___ \|__| _____ |  |   ______ _______\_____  \
          /     \  \/|  |/ ____\|  |  /  _   \\____  \ _(__  <
          \      \___|  \  \____|  |_(  <◕>   )  |_>  >       \
           \_______  /__|\____  >____/\______/|   ___/______  /
                   \/         \/              |__|          \/
                  

## Descargar y ejecutrar script (😁 con emogics):

✅ Para instalar el script en tu equipo, copia el código de Ciclop3.bat de GitHub, pegalo en un archivo de tu equipo y cambia su extensión por .bat (o .cmd). (Doble clic)

⚠️ No descargues directamente el archio .bat de GitHub


## 2º forma de ejecutar script (😭 sin emogics):

```powershell
# Descargar el contenido del script
$scriptContent = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/isaacnavajaspozo/Ciclop3/refs/heads/main/Ciclop3.bat"

# Definir la ruta de la carpeta de Descargas
$downloadsFolder = [System.IO.Path]::Combine($env:USERPROFILE, "Downloads")
echo "El archivo se ha descargado en $downloadsFolder"

# Guardar el contenido en la carpeta de Descargas
$scriptPath = [System.IO.Path]::Combine($downloadsFolder, "Ciclop3.bat")
$scriptContent | Out-File -FilePath $scriptPath -Encoding ASCII

# Ejecutar el archivo por lotes
Start-Process -FilePath $scriptPath

