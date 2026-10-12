#requires -Version 5.1
<#
.SYNOPSIS
    Kit para bloquear contenido adulto - capa Android.
    Se ejecuta en un PC con Windows, con el móvil conectado por USB.

.DESCRIPTION
    Sin parámetros muestra un menú. Opciones:

      1) Configurar: pone el DNS privado de CleanBrowsing Family Filter en el
         móvil, lo comprueba leyéndolo de vuelta y te propone quitar o
         desactivar los navegadores (todos menos Chrome) y las apps de riesgo.
         Siempre pregunta antes de tocar una app y nunca toca apps críticas.
      2) Llave: genera una llave aleatoria (PIN o contraseña) que tú no ves,
         la copia al portapapeles para que la pegues en tu cápsula del tiempo,
         vacía el portapapeles y la teclea en el móvil por el cable.
      3) Comprobar: enseña cómo está el móvil, sin cambiar nada.
      4) Terminar: apaga la depuración USB y las opciones para desarrolladores.
      5) Deshacer: revierte lo que hizo este script, a partir del registro.

    Todo lo que cambia queda anotado en "registro-movil.log", en la misma
    carpeta que este script. Las llaves NUNCA se escriben en el registro
    ni en la pantalla.

    Las herramientas oficiales de Google (SDK Platform-Tools) se descargan
    en la subcarpeta "platform-tools" si todavía no están.

.PARAMETER Configurar
    Ejecuta directamente la opción 1 (DNS + navegadores y apps de riesgo).

.PARAMETER Llave
    Ejecuta directamente la opción 2 (meter una llave sin verla).

.PARAMETER Comprobar
    Ejecuta directamente la opción 3 (solo lectura).

.PARAMETER Terminar
    Ejecuta directamente la opción 4 (apagar la depuración USB).

.PARAMETER Deshacer
    Revierte, a partir del registro, lo que hizo la opción 1.

.EXAMPLE
    .\configurar-movil.ps1

.EXAMPLE
    .\configurar-movil.ps1 -Deshacer

.NOTES
    Pensado para Windows PowerShell 5.1. Lánzalo con EJECUTAR-movil.bat.
#>
[CmdletBinding()]
param(
    [switch]$Configurar,
    [switch]$Llave,
    [switch]$Comprobar,
    [switch]$Terminar,
    [switch]$Deshacer
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Datos fijos
# ---------------------------------------------------------------------------

$script:Carpeta = $PSScriptRoot
if ([string]::IsNullOrEmpty($script:Carpeta)) {
    $script:Carpeta = Split-Path -Parent $MyInvocation.MyCommand.Path
}

# DNS privado (DNS sobre TLS) de CleanBrowsing Family Filter.
$script:DnsHost = 'family-filter-dns.cleanbrowsing.org'

# Enlace fijo oficial de Google a la última versión de platform-tools.
$script:UrlPlatformTools = 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip'
$script:CarpetaTools     = Join-Path $script:Carpeta 'platform-tools'
$script:Adb              = Join-Path $script:CarpetaTools 'adb.exe'
$script:Registro         = Join-Path $script:Carpeta 'registro-movil.log'

# El único navegador que se deja: Chrome (es el que se puede ajustar y el
# que usan las demás apps para abrir enlaces).
$script:NavegadorQueSeQueda = 'com.android.chrome'

# Estado de la sesión
$script:Serie          = ''
$script:Fabricante     = ''
$script:Modelo         = ''
$script:VersionAndroid = ''
$script:Sdk            = 0
$script:ShowPwAntes    = $null
$script:ProtegidosDinamicos = @{}

# Navegadores conocidos (además, el script detecta cualquier app que abra
# páginas web, aunque no esté en esta lista).
$script:NavegadoresConocidos = [ordered]@{
    'org.mozilla.firefox'              = 'Firefox'
    'org.mozilla.firefox_beta'         = 'Firefox Beta'
    'org.mozilla.fenix'                = 'Firefox Nightly'
    'org.mozilla.focus'                = 'Firefox Focus'
    'org.mozilla.klar'                 = 'Firefox Klar'
    'com.opera.browser'                = 'Opera (trae VPN integrada)'
    'com.opera.browser.beta'           = 'Opera beta'
    'com.opera.mini.native'            = 'Opera Mini'
    'com.opera.gx'                     = 'Opera GX'
    'com.microsoft.emmx'               = 'Microsoft Edge'
    'com.brave.browser'                = 'Brave'
    'com.duckduckgo.mobile.android'    = 'DuckDuckGo'
    'org.torproject.torbrowser'        = 'Tor Browser'
    'com.UCMobile.intl'                = 'UC Browser'
    'com.kiwibrowser.browser'          = 'Kiwi Browser'
    'com.vivaldi.browser'              = 'Vivaldi'
    'com.yandex.browser'               = 'Yandex Browser'
    'com.ecosia.android'               = 'Ecosia'
    'com.aloha.browser'                = 'Aloha (trae VPN integrada)'
    'mark.via.gp'                      = 'Via'
    'org.bromite.bromite'              = 'Bromite'
    'com.cloudmosa.puffinFree'         = 'Puffin'
    'com.huawei.browser'               = 'Huawei Browser'
    'com.sec.android.app.sbrowser'     = 'Samsung Internet'
    'com.sec.android.app.sbrowser.beta' = 'Samsung Internet Beta'
    'com.mi.globalbrowser'             = 'Mi Browser (Xiaomi)'
    'com.android.browser'              = 'Navegador del sistema'
    'com.chrome.beta'                  = 'Chrome Beta'
    'com.chrome.dev'                   = 'Chrome Dev'
    'com.chrome.canary'                = 'Chrome Canary'
}

# Apps cuyo contenido no pasa por el filtro DNS (lo sirven desde sus propios
# servidores). Se proponen una a una; tú decides.
$script:AppsRiesgo = [ordered]@{
    'com.reddit.frontpage'         = 'Reddit'
    'com.twitter.android'          = 'X (Twitter)'
    'org.telegram.messenger'       = 'Telegram'
    'org.telegram.messenger.web'   = 'Telegram (versión web)'
    'org.thunderdog.challegram'    = 'Telegram X'
    'com.tumblr'                   = 'Tumblr'
    'com.discord'                  = 'Discord'
    'xyz.blueskyweb.app'           = 'Bluesky'
    'com.snapchat.android'         = 'Snapchat'
}

# Tiendas de apps alternativas (permiten instalar navegadores sin pasar por
# los controles de Google Play).
$script:TiendasAlternativas = [ordered]@{
    'org.fdroid.fdroid'   = 'F-Droid'
    'com.aurora.store'    = 'Aurora Store'
    'com.apkpure.aegon'   = 'APKPure'
    'com.uptodown'        = 'Uptodown'
}

# Paquetes que el script NO toca nunca, pase lo que pase.
$script:ProtegidosExactos = @(
    'android',
    'com.android.chrome',
    'com.google.android.webview',
    'com.android.webview',
    'com.google.android.trichromelibrary',
    'com.android.settings',
    'com.android.systemui',
    'com.android.shell',
    'com.android.phone',
    'com.android.htmlviewer',
    'com.android.vending',
    'com.google.android.gsf',
    'com.google.android.packageinstaller',
    'com.android.packageinstaller',
    'com.google.android.permissioncontroller',
    'com.android.permissioncontroller',
    'com.android.intentresolver',
    'com.google.android.documentsui',
    'com.android.documentsui',
    'com.google.android.googlequicksearchbox',
    'com.google.android.inputmethod.latin',
    'com.samsung.android.honeyboard',
    'com.sec.android.app.launcher',
    'com.miui.home',
    'com.mi.android.globallauncher',
    'com.google.android.apps.nexuslauncher',
    'com.android.launcher3',
    'com.miui.securitycenter',
    'com.miui.securityadd',
    'com.xiaomi.finddevice',
    'com.sec.android.app.samsungapps',
    'com.xiaomi.mipicks'
)
$script:ProtegidosPrefijos = @(
    'com.android.providers.',
    'com.google.android.gms',
    'com.samsung.android.knox.',
    'com.miui.securit',
    'com.android.server.'
)
# Apps bloqueadoras: nunca se proponen para quitar (aunque usen VPN).
$script:ProtegidosContiene = @('appblock', 'mobilesoft', 'cleanbrowsing')

# ---------------------------------------------------------------------------
# Utilidades de pantalla y preguntas
# ---------------------------------------------------------------------------

function Mostrar-Titulo {
    param([string]$Texto)
    Write-Host ''
    Write-Host ('=' * 72) -ForegroundColor Cyan
    Write-Host (' ' + $Texto) -ForegroundColor Cyan
    Write-Host ('=' * 72) -ForegroundColor Cyan
}

function Mostrar-Ok    { param([string]$Texto) Write-Host ('  [OK] ' + $Texto) -ForegroundColor Green }
function Mostrar-Aviso { param([string]$Texto) Write-Host ('  [!]  ' + $Texto) -ForegroundColor Yellow }
function Mostrar-Error { param([string]$Texto) Write-Host ('  [X]  ' + $Texto) -ForegroundColor Red }
function Mostrar-Info  { param([string]$Texto) Write-Host ('       ' + $Texto) }

function Leer-Respuesta {
    param([string]$Texto)
    $r = Read-Host -Prompt $Texto
    if ($null -eq $r) { $r = '' }
    return $r.Trim()
}

function Preguntar-SiNo {
    # Con -SinDefecto, Intro no vale: hay que escribir S o N (para preguntas delicadas).
    param([string]$Texto, [bool]$PorDefecto = $false, [switch]$SinDefecto)
    if ($SinDefecto) { $sufijo = ' [s/n]' } elseif ($PorDefecto) { $sufijo = ' [S/n]' } else { $sufijo = ' [s/N]' }
    while ($true) {
        $r = (Leer-Respuesta ($Texto + $sufijo)).ToLowerInvariant()
        if ($r -eq '' -and -not $SinDefecto) { return $PorDefecto }
        if ($r -eq 's' -or $r -eq 'si' -or $r -eq 'sí' -or $r -eq 'y') { return $true }
        if ($r -eq 'n' -or $r -eq 'no') { return $false }
        Mostrar-Aviso 'Responde S (sí) o N (no).'
    }
}

function Esperar-Palabra {
    # Espera a que la persona escriba una palabra concreta. Devuelve $false si cancela.
    param([string]$Texto, [string]$Palabra)
    while ($true) {
        $r = Leer-Respuesta $Texto
        if ($r -eq $Palabra) { return $true }
        if ($r -eq 'CANCELAR') { return $false }
        Mostrar-Aviso ('Escribe ' + $Palabra + ' para seguir, o CANCELAR para parar.')
    }
}

# ---------------------------------------------------------------------------
# Registro (log) junto al script
# ---------------------------------------------------------------------------

function Anotar {
    param([string]$Tipo, [string]$Dato1 = '', [string]$Dato2 = '')
    $serie = $script:Serie
    if ([string]::IsNullOrEmpty($serie)) { $serie = '-' }
    # Sin tabuladores ni saltos de línea dentro de los datos (rompen el formato).
    $d1 = ($Dato1 -replace '[\t\r\n]+', ' ')
    $d2 = ($Dato2 -replace '[\t\r\n]+', ' ')
    $linea = "{0}`t{1}`t{2}`t{3}`t{4}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $serie, $Tipo, $d1, $d2
    try {
        Add-Content -LiteralPath $script:Registro -Value $linea -Encoding UTF8
    } catch {
        Mostrar-Aviso ('No he podido escribir en el registro (' + $script:Registro + '): ' + $_.Exception.Message)
    }
}

function Registro-Escribible {
    # Comprueba, sin escribir nada, que se puede guardar el registro junto al script.
    # Sin registro, "Deshacer" no sabría qué apps restaurar: mejor no cambiar nada.
    try {
        $fs = [System.IO.File]::Open($script:Registro, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)
        $fs.Close()
        return $true
    } catch {
        Mostrar-Error ('No puedo escribir el registro en ' + $script:Registro)
        Mostrar-Info 'Sin registro no se podría deshacer después, así que no cambio nada.'
        Mostrar-Info 'Copia la carpeta del kit a un sitio tuyo (por ejemplo, Documentos), descomprimida,'
        Mostrar-Info 'y vuelve a abrir EJECUTAR-movil.bat desde allí.'
        return $false
    }
}

function Leer-Registro {
    $resultado = @()
    if (-not (Test-Path -LiteralPath $script:Registro)) { return $resultado }
    foreach ($l in (Get-Content -LiteralPath $script:Registro -Encoding UTF8)) {
        $p = $l -split "`t"
        if ($p.Count -ge 5) {
            $resultado += New-Object PSObject -Property @{
                Fecha = $p[0]; Serie = $p[1]; Tipo = $p[2]; Dato1 = $p[3]; Dato2 = $p[4]
            }
        }
    }
    return $resultado
}

# ---------------------------------------------------------------------------
# adb
# ---------------------------------------------------------------------------

function Invocar-Adb {
    param(
        [Parameter(Mandatory = $true)][string[]]$Argumentos,
        [switch]$SinDispositivo
    )
    $lista = @()
    if (-not $SinDispositivo -and -not [string]::IsNullOrEmpty($script:Serie)) {
        $lista += '-s'
        $lista += $script:Serie
    }
    $lista += $Argumentos
    $eapAnterior = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $salida = @()
    $codigo = -1
    try {
        $salida = @(& $script:Adb @lista 2>&1 | ForEach-Object { $_.ToString() })
        $codigo = $LASTEXITCODE
    } catch {
        $salida = @($_.Exception.Message)
    } finally {
        $ErrorActionPreference = $eapAnterior
    }
    $texto = ($salida -join "`n").Trim()
    return New-Object PSObject -Property @{ Codigo = $codigo; Texto = $texto; Lineas = $salida }
}

function Invocar-Shell {
    param([Parameter(Mandatory = $true)][string[]]$Comando)
    return (Invocar-Adb -Argumentos (@('shell') + $Comando))
}

function Leer-Prop {
    param([string]$Nombre)
    return (Invocar-Shell @('getprop', $Nombre)).Texto
}

function Leer-Ajuste {
    param([string]$Espacio, [string]$Clave)
    return (Invocar-Shell @('settings', 'get', $Espacio, $Clave)).Texto
}

function Hay-ErrorPermiso {
    param($Resultado)
    return ($Resultado.Texto -match 'Permission denial|SecurityException|WRITE_SECURE_SETTINGS|INJECT_EVENTS|not allowed|java\.lang\.|Exception')
}

function Mostrar-AyudaPermisos {
    Mostrar-Aviso 'El móvil no ha dejado hacer el cambio: falta un permiso de depuración.'
    if ($script:Fabricante -match 'Xiaomi|Redmi|POCO') {
        Mostrar-Info 'En Xiaomi, Redmi y POCO hay que activar una segunda opción:'
        Mostrar-Info '  Ajustes > Ajustes adicionales > Opciones de desarrollador >'
        Mostrar-Info '  "Depuración USB (ajustes de seguridad)".'
        Mostrar-Info 'Suele pedir tener la cuenta Xiaomi iniciada (y a veces una SIM con datos).'
        Mostrar-Info 'Actívala, desconecta y vuelve a conectar el cable, y repite esta opción.'
    } else {
        Mostrar-Info 'Comprueba que "Depuración por USB" sigue activada y que aceptaste el aviso'
        Mostrar-Info 'del móvil. Si no se arregla, haz este paso a mano siguiendo la GUIA.md.'
    }
}

function Asegurar-Adb {
    if (Test-Path -LiteralPath $script:Adb) { return $true }

    Mostrar-Titulo 'Descargar las herramientas oficiales de Android (platform-tools)'
    Mostrar-Info 'Para hablar con el móvil por el cable hace falta "SDK Platform-Tools", de Google.'
    Mostrar-Info ('Se descargará de: ' + $script:UrlPlatformTools)
    Mostrar-Info ('y se guardará en: ' + $script:CarpetaTools)
    Mostrar-Info 'Al descargarlas aceptas las condiciones de Google publicadas en'
    Mostrar-Info 'https://developer.android.com/tools/releases/platform-tools'
    if (-not (Preguntar-SiNo '¿Las descargo ahora?' $true)) { return $false }

    $zip = Join-Path $env:TEMP ('platform-tools-' + [guid]::NewGuid().ToString('N') + '.zip')
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $progresoAnterior = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
        try {
            Mostrar-Info 'Descargando (unos 7 MB)...'
            Invoke-WebRequest -Uri $script:UrlPlatformTools -OutFile $zip -UseBasicParsing
        } finally {
            $ProgressPreference = $progresoAnterior
        }
        Mostrar-Info 'Descomprimiendo...'
        Expand-Archive -LiteralPath $zip -DestinationPath $script:Carpeta -Force
    } catch {
        Mostrar-Error ('No he podido descargar o descomprimir platform-tools: ' + $_.Exception.Message)
        Mostrar-Info 'Comprueba la conexión a internet. Si sigue fallando, descarga a mano el ZIP del enlace'
        Mostrar-Info ('de arriba y descomprímelo aquí: ' + $script:Carpeta)
        return $false
    } finally {
        Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
    }

    if (-not (Test-Path -LiteralPath $script:Adb)) {
        Mostrar-Error ('No encuentro adb.exe en ' + $script:CarpetaTools)
        return $false
    }

    # Comprobación de la firma digital (informativa).
    try {
        $firma = Get-AuthenticodeSignature -LiteralPath $script:Adb
        if ($firma.Status -eq 'Valid' -and $null -ne $firma.SignerCertificate -and $firma.SignerCertificate.Subject -match 'Google') {
            Mostrar-Ok 'adb.exe está firmado digitalmente por Google.'
        } elseif ($firma.Status -eq 'HashMismatch') {
            Mostrar-Error 'La firma de adb.exe no coincide con el archivo: lo borro por seguridad.'
            Remove-Item -LiteralPath $script:CarpetaTools -Recurse -Force -ErrorAction SilentlyContinue
            return $false
        } elseif ($firma.Status -eq 'Valid') {
            Mostrar-Aviso ('adb.exe está firmado por alguien que no es Google: ' + $firma.SignerCertificate.Subject)
            if (-not (Preguntar-SiNo '¿Seguro que quieres seguir?' $false)) { return $false }
        } else {
            Mostrar-Info 'No he podido confirmar la firma digital de adb.exe. La descarga viene directamente'
            Mostrar-Info 'de dl.google.com por HTTPS, así que normalmente es correcta.'
        }
    } catch {
        Mostrar-Info 'No he podido comprobar la firma digital de adb.exe (no es grave).'
    }
    Mostrar-Ok 'Herramientas listas.'
    return $true
}

function Mostrar-AyudaConexion {
    Mostrar-Aviso 'No veo ningún móvil conectado.'
    Mostrar-Info 'Revisa, por orden:'
    Mostrar-Info '  1. Cable USB de DATOS (algunos cables solo cargan). Prueba otro puerto del PC.'
    Mostrar-Info '  2. Opciones para desarrolladores y "Depuración por USB" activadas (GUIA.md, nivel 2).'
    Mostrar-Info '  3. Samsung: Ajustes > Seguridad y privacidad > Bloqueador automático: desactívalo'
    Mostrar-Info '     mientras uses el script (bloquea los comandos por cable). Puede volver a'
    Mostrar-Info '     activarse solo a los 30 minutos.'
    Mostrar-Info '  4. Xiaomi/Redmi/POCO: activa también "Depuración USB (ajustes de seguridad)".'
    Mostrar-Info '  5. Desbloquea la pantalla del móvil. Si aparece un aviso de USB, elige'
    Mostrar-Info '     "Transferencia de archivos".'
    Mostrar-Info '  6. Controlador USB en Windows (Pixel: Google USB Driver; Samsung: Samsung Android'
    Mostrar-Info '     USB Driver). Enlaces en la GUIA.md.'
}

function Leer-InfoDispositivo {
    $script:Fabricante     = Leer-Prop 'ro.product.manufacturer'
    $script:Modelo         = Leer-Prop 'ro.product.model'
    $script:VersionAndroid = Leer-Prop 'ro.build.version.release'
    $n = 0
    [void][int]::TryParse((Leer-Prop 'ro.build.version.sdk'), [ref]$n)
    $script:Sdk = $n
    Mostrar-Ok ('Móvil conectado: ' + $script:Fabricante + ' ' + $script:Modelo + ', Android ' + $script:VersionAndroid + ' (API ' + $script:Sdk + ').')
    $u = (Invocar-Shell @('am', 'get-current-user')).Texto
    if ($u -match '^\d+$' -and $u -ne '0') {
        Mostrar-Aviso ('Ahora mismo estás usando otro usuario o espacio del móvil (número ' + $u + ').')
        Mostrar-Info 'El script trabaja sobre el usuario principal (0). Vuelve al principal si puedes.'
    }
}

function Conectar-Movil {
    if (-not (Asegurar-Adb)) { return $false }
    $null = Invocar-Adb -Argumentos @('start-server') -SinDispositivo
    while ($true) {
        $r = Invocar-Adb -Argumentos @('devices') -SinDispositivo
        $lista = @()
        foreach ($l in $r.Lineas) {
            if ([string]::IsNullOrWhiteSpace($l)) { continue }
            if ($l -match '^List of devices' -or $l -match '^\*') { continue }
            # Formato de "adb devices": SERIE<tab>estado. Otras líneas (avisos de adb) se ignoran.
            if ($l -match '^(\S+)\t+(\S.*?)\s*$') {
                $lista += New-Object PSObject -Property @{ Serie = $Matches[1]; Estado = $Matches[2] }
            }
        }
        $listos     = @($lista | Where-Object { $_.Estado -eq 'device' })
        $sinPermiso = @($lista | Where-Object { $_.Estado -eq 'unauthorized' })

        if ($listos.Count -eq 1) {
            $script:Serie = $listos[0].Serie
            break
        }
        if ($listos.Count -gt 1) {
            Mostrar-Aviso 'Hay varios dispositivos conectados:'
            for ($i = 0; $i -lt $listos.Count; $i++) {
                Mostrar-Info (('{0}) {1}' -f ($i + 1), $listos[$i].Serie))
            }
            $elegido = Leer-Respuesta 'Escribe el número del móvil que quieres usar'
            $n = 0
            if ([int]::TryParse($elegido, [ref]$n) -and $n -ge 1 -and $n -le $listos.Count) {
                $script:Serie = $listos[$n - 1].Serie
                break
            }
            Mostrar-Aviso 'Número no válido. Mejor deja conectado solo el móvil que quieres configurar.'
        } elseif ($sinPermiso.Count -gt 0) {
            Mostrar-Aviso 'El móvil está conectado pero todavía no ha dado permiso a este PC.'
            Mostrar-Info 'Desbloquea el móvil: verás "¿Permitir depuración por USB?". Pulsa "Permitir".'
            Mostrar-Info 'Si no aparece, desconecta y vuelve a conectar el cable.'
        } elseif ($lista.Count -gt 0) {
            Mostrar-Aviso ('El móvil aparece en estado "' + $lista[0].Estado + '". Desconecta y vuelve a conectar el cable.')
        } else {
            Mostrar-AyudaConexion
        }
        $resp = Leer-Respuesta 'Pulsa Intro para volver a comprobar (o escribe S para salir)'
        if ($resp -match '^[sS]') { return $false }
    }
    $prueba = Invocar-Shell @('getprop', 'ro.build.version.sdk')
    if ($prueba.Codigo -ne 0 -or $prueba.Texto -notmatch '^\d+$') {
        Mostrar-Error 'El móvil aparece conectado pero no responde a los comandos.'
        Mostrar-Info 'Desbloquea la pantalla, desconecta y vuelve a conectar el cable, y repite la opción.'
        Mostrar-Info 'Samsung: revisa que el Bloqueador automático siga desactivado (puede volver a'
        Mostrar-Info 'activarse solo). Xiaomi/Redmi/POCO: activa "Depuración USB (ajustes de seguridad)".'
        return $false
    }
    Leer-InfoDispositivo
    return $true
}

# ---------------------------------------------------------------------------
# Detección de apps
# ---------------------------------------------------------------------------

function Paquetes-DeLineas {
    # Saca nombres de paquete de líneas tipo "com.ejemplo/.Actividad" o "packageName=com.ejemplo".
    param([string[]]$Lineas)
    $set = @{}
    foreach ($l in $Lineas) {
        if ($null -eq $l) { continue }
        if ($l -match '^\s*([A-Za-z][A-Za-z0-9_]*(?:\.[A-Za-z0-9_]+)+)/[A-Za-z0-9_.$]+\s*$') {
            $set[$Matches[1]] = $true
        } elseif ($l -match 'packageName=([A-Za-z][A-Za-z0-9_.]+)') {
            $set[$Matches[1]] = $true
        }
    }
    return $set
}

function Obtener-Paquetes {
    # Devuelve un conjunto (hashtable) con los paquetes de "pm list packages" para el usuario 0.
    param([string[]]$Opciones = @())
    $r = Invocar-Shell (@('pm', 'list', 'packages') + $Opciones + @('--user', '0'))
    $set = @{}
    foreach ($l in $r.Lineas) {
        if ($l -match '^package:(\S+)') { $set[$Matches[1]] = $true }
    }
    return $set
}

function Cargar-ProtegidosDinamicos {
    $script:ProtegidosDinamicos = @{}
    # Pantalla de inicio (launcher) actual
    $r = Invocar-Shell @('cmd', 'package', 'resolve-activity', '--brief', '--user', '0', '-a', 'android.intent.action.MAIN', '-c', 'android.intent.category.HOME')
    foreach ($p in (Paquetes-DeLineas $r.Lineas).Keys) { $script:ProtegidosDinamicos[$p] = 'pantalla de inicio' }
    # Teclados activos
    $r = Invocar-Shell @('ime', 'list', '-s')
    foreach ($l in $r.Lineas) {
        if ($l -match '^\s*([A-Za-z][A-Za-z0-9_]*(?:\.[A-Za-z0-9_]+)+)/') { $script:ProtegidosDinamicos[$Matches[1]] = 'teclado' }
    }
    $t = Leer-Ajuste 'secure' 'default_input_method'
    if ($t -match '^([A-Za-z][A-Za-z0-9_]*(?:\.[A-Za-z0-9_]+)+)/') { $script:ProtegidosDinamicos[$Matches[1]] = 'teclado' }
    # Proveedor de WebView (en Android 7-9 puede ser Chrome)
    $r = Invocar-Shell @('dumpsys', 'webviewupdate')
    foreach ($l in $r.Lineas) {
        if ($l -match 'Current WebView package \(name, version\): \(([^,\s]+)') { $script:ProtegidosDinamicos[$Matches[1]] = 'WebView' }
    }
}

function Es-Protegido {
    param([string]$Paquete)
    if ($script:ProtegidosDinamicos.ContainsKey($Paquete)) { return $true }
    foreach ($p in $script:ProtegidosExactos) { if ($Paquete -eq $p) { return $true } }
    foreach ($p in $script:ProtegidosPrefijos) {
        if ($Paquete.StartsWith($p, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    }
    $min = $Paquete.ToLowerInvariant()
    foreach ($p in $script:ProtegidosContiene) { if ($min.Contains($p)) { return $true } }
    return $false
}

function Nombre-App {
    param([string]$Paquete)
    if ($script:NavegadoresConocidos.Contains($Paquete)) { return [string]$script:NavegadoresConocidos[$Paquete] }
    if ($script:AppsRiesgo.Contains($Paquete))           { return [string]$script:AppsRiesgo[$Paquete] }
    if ($script:TiendasAlternativas.Contains($Paquete))  { return [string]$script:TiendasAlternativas[$Paquete] }
    return '(app sin nombre conocido)'
}

function Detectar-Apps {
    # Devuelve un objeto con el estado de Chrome y la lista de apps candidatas a quitar.
    Mostrar-Info 'Buscando navegadores y apps de riesgo en el móvil...'
    Cargar-ProtegidosDinamicos
    $instaladas  = Obtener-Paquetes @()
    $terceros    = Obtener-Paquetes @('-3')
    $desactivadas = Obtener-Paquetes @('-d')
    if ($instaladas.Count -eq 0) {
        # Un móvil siempre tiene apps: si la lista sale vacía, es que no ha respondido.
        Mostrar-Error 'No he podido leer la lista de apps del móvil (¿se ha desconectado el cable?).'
        Mostrar-Info 'No toco ninguna app. Vuelve a conectar el móvil y repite esta opción.'
        return $null
    }

    # 1) Cualquier app que abra páginas web (aunque no esté en la lista).
    $navs = @{}
    $consultas = @(
        @('cmd', 'package', 'query-activities', '--brief', '--user', '0', '-a', 'android.intent.action.VIEW', '-c', 'android.intent.category.BROWSABLE', '-d', 'https://www.example.com'),
        @('cmd', 'package', 'query-activities', '--brief', '--user', '0', '-a', 'android.intent.action.VIEW', '-c', 'android.intent.category.BROWSABLE', '-d', 'http://www.example.com'),
        @('cmd', 'package', 'query-activities', '--brief', '--user', '0', '-a', 'android.intent.action.MAIN', '-c', 'android.intent.category.APP_BROWSER')
    )
    foreach ($c in $consultas) {
        $r = Invocar-Shell $c
        foreach ($p in (Paquetes-DeLineas $r.Lineas).Keys) { $navs[$p] = $true }
    }
    # 2) Navegadores conocidos instalados (incluidos los que ya estén desactivados).
    foreach ($p in $script:NavegadoresConocidos.Keys) {
        if ($instaladas.ContainsKey($p)) { $navs[$p] = $true }
    }

    $candidatas = @()
    foreach ($p in ($navs.Keys | Sort-Object)) {
        if (-not $instaladas.ContainsKey($p)) { continue }
        if (Es-Protegido $p) { continue }
        $candidatas += New-Object PSObject -Property @{
            Paquete = $p; Nombre = (Nombre-App $p); Tipo = 'Navegador'
            Sistema = (-not $terceros.ContainsKey($p)); Desactivada = $desactivadas.ContainsKey($p)
        }
    }
    foreach ($p in $script:AppsRiesgo.Keys) {
        if ($instaladas.ContainsKey($p) -and -not (Es-Protegido $p) -and -not $navs.ContainsKey($p)) {
            $candidatas += New-Object PSObject -Property @{
                Paquete = $p; Nombre = (Nombre-App $p); Tipo = 'App de riesgo'
                Sistema = (-not $terceros.ContainsKey($p)); Desactivada = $desactivadas.ContainsKey($p)
            }
        }
    }
    foreach ($p in $script:TiendasAlternativas.Keys) {
        if ($terceros.ContainsKey($p) -and -not (Es-Protegido $p) -and -not $navs.ContainsKey($p)) {
            $candidatas += New-Object PSObject -Property @{
                Paquete = $p; Nombre = (Nombre-App $p); Tipo = 'Tienda alternativa'
                Sistema = $false; Desactivada = $desactivadas.ContainsKey($p)
            }
        }
    }
    # 3) Apps de VPN instaladas por ti (solo de terceros; nunca las del sistema ni la app bloqueadora).
    $r = Invocar-Shell @('cmd', 'package', 'query-services', '--brief', '--user', '0', '-a', 'android.net.VpnService')
    foreach ($p in ((Paquetes-DeLineas $r.Lineas).Keys | Sort-Object)) {
        if (-not $terceros.ContainsKey($p)) { continue }
        if (Es-Protegido $p) { continue }
        if (@($candidatas | Where-Object { $_.Paquete -eq $p }).Count -gt 0) { continue }
        $candidatas += New-Object PSObject -Property @{
            Paquete = $p; Nombre = '(app que crea una VPN)'; Tipo = 'App de VPN'
            Sistema = $false; Desactivada = $desactivadas.ContainsKey($p)
        }
    }

    $estadoChrome = 'falta'
    if ($instaladas.ContainsKey($script:NavegadorQueSeQueda)) {
        if ($desactivadas.ContainsKey($script:NavegadorQueSeQueda)) { $estadoChrome = 'desactivado' } else { $estadoChrome = 'ok' }
    }
    return New-Object PSObject -Property @{ Chrome = $estadoChrome; Candidatas = $candidatas }
}

function Mostrar-Candidatas {
    param($Candidatas)
    $i = 0
    foreach ($c in $Candidatas) {
        $i++
        if ($c.Sistema) { $origen = 'del sistema' } else { $origen = 'instalada' }
        $extra = ''
        if ($c.Desactivada) { $extra = ', ya desactivada' }
        Mostrar-Info (('{0,2}) {1} - {2}  [{3}, {4}{5}]' -f $i, $c.Tipo, $c.Nombre, $c.Paquete, $origen, $extra))
    }
}

function Revisar-Usuarios {
    param([switch]$SoloMirar)
    $r = Invocar-Shell @('pm', 'list', 'users')
    $otros = @()
    $ids = @()
    foreach ($l in $r.Lineas) {
        if ($l -match 'UserInfo\{(\d+):([^:]*):') {
            if ($Matches[1] -ne '0') {
                $otros += ($Matches[2] + ' (número ' + $Matches[1] + ')')
                $ids += $Matches[1]
            }
        }
    }
    if ($otros.Count -eq 0) {
        Mostrar-Ok 'No hay otros usuarios ni espacios aparte en el móvil.'
        return
    }
    Mostrar-Aviso 'El móvil tiene otros usuarios o espacios aparte:'
    foreach ($o in $otros) { Mostrar-Info ('- ' + $o) }
    Mostrar-Info 'Pueden ser: invitado, otro usuario, Espacio privado (Pixel), Carpeta Segura o'
    Mostrar-Info 'Dual Messenger (Samsung), Segundo espacio o Aplicaciones duales (Xiaomi), perfil de trabajo.'
    Mostrar-Info 'El DNS privado también se aplica ahí, pero las apps bloqueadoras NO, y este script no'
    Mostrar-Info 'toca las apps de esos espacios. Bórralos a mano (GUIA.md, paso 1.5), haciendo antes'
    Mostrar-Info 'copia de lo que tengas dentro. Excepción: si es el perfil de trabajo de tu empresa, déjalo.'
    # En el registro solo se anotan los números, no los nombres.
    if (-not $SoloMirar) { Anotar 'INFO' ('Otros usuarios o espacios (números): ' + ($ids -join ', ')) }
}

# ---------------------------------------------------------------------------
# DNS privado
# ---------------------------------------------------------------------------

function Describir-Modo {
    param([string]$Modo)
    switch ($Modo) {
        'off'           { return 'Desactivado' }
        'opportunistic' { return 'Automático' }
        'hostname'      { return 'Nombre de host del proveedor' }
        default         { return 'Automático (valor de fábrica)' }
    }
}

function Probar-Dns {
    Mostrar-Info 'Compruebo que el móvil sigue teniendo internet con el nuevo DNS (unos segundos)...'
    $ok = $false
    for ($i = 1; $i -le 3; $i++) {
        Start-Sleep -Seconds 3
        $r = Invocar-Shell @('ping', '-c', '1', '-W', '3', 'www.google.com')
        if ($r.Texto -match 'PING\s+\S+\s+\(') { $ok = $true; break }
    }
    if ($ok) {
        Mostrar-Ok 'El móvil resuelve nombres con el DNS filtrado: internet funciona.'
        $r = Invocar-Shell @('ping', '-c', '1', '-W', '2', 'www.reddit.com')
        # Un dominio bloqueado puede no resolverse o resolverse a una dirección "vacía"
        # (0.0.0.0, 127.x, ::) o a una página de bloqueo del propio CleanBrowsing.
        $bloqueado = $true
        if ($r.Texto -match 'PING\s+\S+\s+\(([^)]*)\)') {
            $ip = $Matches[1]
            $bloqueado = ($ip -match '^(0\.0\.0\.0|127\.|::1?$|185\.228\.16[89]\.)')
        }
        if ($bloqueado) {
            Mostrar-Ok 'Prueba orientativa: www.reddit.com (contenido mixto) está bloqueado: el filtro actúa.'
        } else {
            Mostrar-Info 'Prueba orientativa: www.reddit.com (contenido mixto) todavía se resuelve. Puede tardar'
            Mostrar-Info 'un poco en aplicarse; repite la comprobación de la GUIA.md dentro de unos minutos.'
        }
    } else {
        Mostrar-Aviso 'Ahora mismo el móvil no resuelve nombres.'
        Mostrar-Info 'Puede que el móvil no tenga conexión en este momento, o que esta wifi bloquee el DNS'
        Mostrar-Info 'privado (puerto 853). En el móvil verías "No se ha podido acceder al servidor DNS privado".'
        Mostrar-Info 'Prueba con datos móviles. Si con datos funciona, el problema es solo esa wifi.'
    }
}

function Configurar-Dns {
    Mostrar-Titulo 'DNS privado: CleanBrowsing Family Filter'
    if ($script:Sdk -lt 28) {
        Mostrar-Aviso 'Este móvil tiene una versión de Android anterior a la 9: no tiene "DNS privado".'
        Mostrar-Info 'En casa te protege el router (carpeta router/) y fuera, la app bloqueadora (GUIA.md, nivel 3).'
        Anotar 'INFO' 'Android anterior a 9: sin DNS privado'
        return
    }
    $rModo = Invocar-Shell @('settings', 'get', 'global', 'private_dns_mode')
    $rServ = Invocar-Shell @('settings', 'get', 'global', 'private_dns_specifier')
    if ($rModo.Codigo -ne 0 -or $rServ.Codigo -ne 0 -or (Hay-ErrorPermiso $rModo) -or (Hay-ErrorPermiso $rServ)) {
        Mostrar-Error 'No he podido leer el DNS privado actual (¿se ha desconectado el cable?). No cambio nada.'
        Mostrar-Info 'Vuelve a conectar el móvil y repite esta opción, o ponlo a mano (GUIA.md, paso 1.1).'
        return
    }
    $modo     = $rModo.Texto
    $servidor = $rServ.Texto
    $textoServidor = $servidor
    if ($servidor -eq 'null' -or [string]::IsNullOrEmpty($servidor)) { $textoServidor = '(ninguno)' }
    Mostrar-Info ('Ahora mismo: modo = ' + (Describir-Modo $modo) + '; servidor = ' + $textoServidor)

    if ($modo -eq 'hostname' -and $servidor -eq $script:DnsHost) {
        Mostrar-Ok 'El DNS privado de CleanBrowsing ya estaba puesto.'
        Probar-Dns
        return
    }
    if (-not (Preguntar-SiNo ('¿Pongo el DNS privado "' + $script:DnsHost + '"?') $true)) {
        Mostrar-Info 'De acuerdo, no lo toco.'
        return
    }

    Anotar 'DNS_ANTES' $modo $servidor
    $r = Invocar-Shell @('settings', 'put', 'global', 'private_dns_specifier', $script:DnsHost)
    if (Hay-ErrorPermiso $r) { Mostrar-AyudaPermisos; return }
    $r = Invocar-Shell @('settings', 'put', 'global', 'private_dns_mode', 'hostname')
    if (Hay-ErrorPermiso $r) { Mostrar-AyudaPermisos; return }

    # Verificación leyendo de vuelta
    $modo2     = Leer-Ajuste 'global' 'private_dns_mode'
    $servidor2 = Leer-Ajuste 'global' 'private_dns_specifier'
    if ($modo2 -eq 'hostname' -and $servidor2 -eq $script:DnsHost) {
        Mostrar-Ok ('Comprobado: el móvil tiene ahora el DNS privado "' + $servidor2 + '".')
        Anotar 'DNS_PUESTO' $modo2 $servidor2
        Probar-Dns
    } else {
        Mostrar-Error ('Al leerlo de vuelta no coincide (modo = ' + $modo2 + ', servidor = ' + $servidor2 + ').')
        Mostrar-Info 'Ponlo a mano siguiendo la GUIA.md (paso 1.1).'
        Anotar 'INFO' ('DNS no verificado: ' + $modo2 + ' ' + $servidor2)
    }
}

# ---------------------------------------------------------------------------
# Quitar o desactivar apps
# ---------------------------------------------------------------------------

function Quitar-App {
    param($App)
    $r = Invocar-Shell @('pm', 'uninstall', '-k', '--user', '0', $App.Paquete)
    if ($r.Texto -match 'Success') {
        if ($App.Sistema) { $origen = 'sistema' } else { $origen = 'tercero' }
        Anotar 'QUITADO' $App.Paquete $origen
        Mostrar-Ok ('Quitada: ' + $App.Nombre + ' (' + $App.Paquete + ')')
        return 'quitada'
    }
    Mostrar-Error ('No se ha podido quitar ' + $App.Paquete + ': ' + $r.Texto)
    return ''
}

function Desactivar-App {
    param($App)
    if ($App.Desactivada) {
        Mostrar-Info ('Ya estaba desactivada: ' + $App.Paquete)
        return 'desactivada'
    }
    $r = Invocar-Shell @('pm', 'disable-user', '--user', '0', $App.Paquete)
    if ($r.Texto -match 'new state:\s*disabled') {
        Anotar 'DESACTIVADO' $App.Paquete ''
        Mostrar-Ok ('Desactivada: ' + $App.Nombre + ' (' + $App.Paquete + ')')
        return 'desactivada'
    }
    Mostrar-Aviso ('El móvil no deja desactivar ' + $App.Paquete + ' (pasa, por ejemplo, en Xiaomi con HyperOS).')
    if (Preguntar-SiNo '¿Pruebo a quitarla en su lugar?' $true) { return (Quitar-App $App) }
    return ''
}

function Revisar-Apps {
    Mostrar-Titulo 'Navegadores y apps de riesgo'
    $det = Detectar-Apps
    if ($null -eq $det) { return }
    $candidatas = @($det.Candidatas)

    if ($det.Chrome -ne 'ok') {
        if ($det.Chrome -eq 'desactivado') {
            Mostrar-Aviso 'Chrome está desactivado en este móvil.'
            Mostrar-Info 'Actívalo en Ajustes > Aplicaciones > Chrome > Activar, y vuelve a usar esta opción.'
        } else {
            Mostrar-Aviso 'Chrome no está instalado en este móvil.'
            Mostrar-Info 'Instálalo desde Google Play y vuelve a usar esta opción.'
        }
        Mostrar-Info 'Para no dejarte sin navegador, esta vez no te propongo quitar ningún navegador.'
        $candidatas = @($candidatas | Where-Object { $_.Tipo -ne 'Navegador' })
    } else {
        Mostrar-Ok 'Chrome está instalado y activo: será el único navegador que se quede.'
    }

    if ($candidatas.Count -eq 0) {
        Mostrar-Ok 'No he encontrado otros navegadores ni apps de riesgo.'
        return
    }

    Write-Host ''
    Mostrar-Info 'He encontrado estas apps:'
    Mostrar-Candidatas $candidatas
    Write-Host ''
    Mostrar-Info 'Opciones para cada una:'
    Mostrar-Info '  Q = Quitar para tu usuario (recomendado). Se puede recuperar con "Deshacer" o'
    Mostrar-Info '      reinstalándola desde la tienda. Si es una app instalada por ti, se borran sus'
    Mostrar-Info '      datos del móvil: si tienes algo importante dentro, haz copia antes o responde N.'
    Mostrar-Info '  D = Desactivar (se oculta; es más fácil de revertir desde Ajustes).'
    Mostrar-Info '  N = No tocar.'
    Mostrar-Info 'Si una app VPN es tu app bloqueadora o la necesitas para trabajar, responde N.'
    Write-Host ''

    $todas = Preguntar-SiNo '¿Quieres QUITAR todas las de la lista de una vez? (las apps de VPN te las pregunto igualmente)' $false
    $quitadas = 0
    $desact = 0
    $intactas = @()
    foreach ($c in $candidatas) {
        if ($todas -and $c.Tipo -ne 'App de VPN') {
            $op = 'Q'
        } else {
            $op = ''
            while ($op -ne 'Q' -and $op -ne 'D' -and $op -ne 'N') {
                $op = (Leer-Respuesta ('  ' + $c.Nombre + ' [' + $c.Paquete + ']  ¿Q (quitar), D (desactivar) o N (no tocar)?')).ToUpperInvariant()
                if ($op -eq '') { $op = 'N' }
            }
        }
        $hecho = ''
        if ($op -eq 'Q') { $hecho = Quitar-App $c }
        elseif ($op -eq 'D') { $hecho = Desactivar-App $c }
        if ($hecho -eq 'quitada') { $quitadas++ }
        elseif ($hecho -eq 'desactivada') { $desact++ }
        else { $intactas += $c }
    }

    Write-Host ''
    Mostrar-Ok ('Quitadas: ' + $quitadas + '. Desactivadas: ' + $desact + '.')
    if ($intactas.Count -gt 0) {
        Mostrar-Aviso 'Se quedan en el móvil (bloquéalas con AppBlock o con los Controles parentales):'
        foreach ($c in $intactas) { Mostrar-Info ('- ' + $c.Nombre + ' [' + $c.Paquete + ']') }
    }
}

# ---------------------------------------------------------------------------
# Opción 1: configurar
# ---------------------------------------------------------------------------

function Invoke-Configurar {
    Mostrar-Titulo '1) Configurar el móvil'
    Mostrar-Info 'Voy a hacer dos cosas, y te pediré permiso en cada paso:'
    Mostrar-Info '  a) Poner el DNS privado de CleanBrowsing Family Filter y comprobarlo.'
    Mostrar-Info '  b) Buscar navegadores (todos menos Chrome) y apps de riesgo, y proponerte quitarlos.'
    Mostrar-Info ('Todo queda anotado en ' + $script:Registro + ' para poder deshacerlo.')
    if (-not (Registro-Escribible)) { return }
    if (-not (Conectar-Movil)) { return }
    Anotar 'INICIO' 'configurar' ($script:Fabricante + ' ' + $script:Modelo + ' / Android ' + $script:VersionAndroid)
    Revisar-Usuarios
    Configurar-Dns
    Revisar-Apps
    Anotar 'FIN' 'configurar' ''
    Write-Host ''
    Mostrar-Titulo 'Siguientes pasos (están en la GUIA.md)'
    Mostrar-Info '1. En Chrome: Configuración > Privacidad y seguridad > Usar DNS seguro >'
    Mostrar-Info '   "Elegir otro proveedor" > "CleanBrowsing (Family Filter)".'
    Mostrar-Info '2. Instala y prepara AppBlock, SIN activar todavía el modo estricto (GUIA.md, nivel 3).'
    Mostrar-Info '3. Controles parentales de Android (o PIN de Google Play): usa la opción 2 de este'
    Mostrar-Info '   menú para meter el PIN sin verlo.'
    Mostrar-Info '4. Opción 3 (Comprobar) y, para cerrar, el modo estricto de AppBlock y la opción 4'
    Mostrar-Info '   (Terminar) en el orden que indica la GUIA.md para tu variante.'
}

# ---------------------------------------------------------------------------
# Opción 2: llave sin verla
# ---------------------------------------------------------------------------

function Llave-Aceptable {
    param([string]$Texto, [bool]$SoloNumeros)
    if (-not $SoloNumeros) {
        if ($Texto -cnotmatch '[A-Za-z]') { return $false }
        if ($Texto -notmatch '[0-9]') { return $false }
    }
    # Android rechaza a veces PIN con secuencias (1234, 1111, 9753...). Las evitamos.
    for ($i = 0; $i -le $Texto.Length - 4; $i++) {
        $a = [int][char]$Texto[$i]; $b = [int][char]$Texto[$i + 1]
        $c = [int][char]$Texto[$i + 2]; $d = [int][char]$Texto[$i + 3]
        $d1 = $b - $a; $d2 = $c - $b; $d3 = $d - $c
        if ($d1 -eq $d2 -and $d2 -eq $d3) {
            $ventana = $Texto.Substring($i, 4)
            if ($ventana -match '^[0-9]{4}$') { return $false }
            if ([Math]::Abs($d1) -le 1) { return $false }
        }
    }
    return $true
}

function Nueva-Llave {
    param([int]$Longitud, [bool]$SoloNumeros)
    if ($SoloNumeros) {
        $alfabeto = '0123456789'
    } else {
        # Sin caracteres que se confunden (0/O, 1/l/I) por si algún día hay que teclearla a mano.
        $alfabeto = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789'
    }
    $limite = 256 - (256 % $alfabeto.Length)
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $byte = New-Object byte[] 1
    try {
        do {
            $sb = New-Object System.Text.StringBuilder
            while ($sb.Length -lt $Longitud) {
                $rng.GetBytes($byte)
                if ($byte[0] -lt $limite) { [void]$sb.Append($alfabeto[$byte[0] % $alfabeto.Length]) }
            }
            $resultado = $sb.ToString()
        } while (-not (Llave-Aceptable $resultado $SoloNumeros))
    } finally {
        $rng.Dispose()
    }
    return $resultado
}

function Nuevo-FlujoDword {
    param([int]$Valor)
    $bytes = [BitConverter]::GetBytes([int32]$Valor)
    return (New-Object System.IO.MemoryStream -ArgumentList (,$bytes))
}

function Copiar-Llave {
    # Copia al portapapeles marcando el contenido como "no guardar en el historial (Win+V)"
    # y "no sincronizar con otros dispositivos".
    param([string]$Texto)
    Add-Type -AssemblyName System.Windows.Forms
    $datos = New-Object System.Windows.Forms.DataObject
    $datos.SetData([System.Windows.Forms.DataFormats]::UnicodeText, $Texto)
    $datos.SetData('ExcludeClipboardContentFromMonitorProcessing', (Nuevo-FlujoDword 0))
    $datos.SetData('CanIncludeInClipboardHistory', (Nuevo-FlujoDword 0))
    $datos.SetData('CanUploadToCloudClipboard', (Nuevo-FlujoDword 0))
    # copy = $true; 10 reintentos cada 100 ms por si otra app tiene el portapapeles ocupado.
    [System.Windows.Forms.Clipboard]::SetDataObject($datos, $true, 10, 100)
}

function Limpiar-Portapapeles {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Clipboard]::Clear()
    } catch {
        Mostrar-Aviso 'No he podido vaciar el portapapeles: copia cualquier palabra para sustituir la llave.'
    }
}

function Revisar-PortapapelesWindows {
    $historial = $null
    try {
        $historial = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name 'EnableClipboardHistory' -ErrorAction Stop).EnableClipboardHistory
    } catch {
        $historial = $null
    }
    if ($historial -eq 1) {
        Mostrar-Aviso 'Tienes activado el historial del portapapeles de Windows (Win+V).'
        Mostrar-Info 'La llave se copia marcada para que NO entre en el historial ni se sincronice, pero'
        Mostrar-Info 'por si acaso, desactívalo: Configuración > Sistema > Portapapeles >'
        Mostrar-Info '"Historial del portapapeles" (y también "Compartir entre dispositivos").'
    }
    $enlace = @(Get-Process -Name 'PhoneExperienceHost', 'YourPhone', 'CrossDeviceService' -ErrorAction SilentlyContinue)
    if ($enlace.Count -gt 0) {
        Mostrar-Aviso 'Enlace Móvil (Phone Link) o la conexión con dispositivos móviles está activa en este PC.'
        Mostrar-Info 'Su función "Copiar y pegar entre dispositivos" podría mandar la llave al móvil.'
        Mostrar-Info 'Desactívala: Configuración > Bluetooth y dispositivos > Dispositivos móviles, o en'
        Mostrar-Info 'la app Enlace Móvil > Configuración > Características. En Samsung, también en el'
        Mostrar-Info 'móvil: Vincular a Windows > "Sincronizar portapapeles" desactivado.'
    }
    Mostrar-Info 'Si usas un programa que guarda lo que copias (Ditto, ClipClip u otro gestor de'
    Mostrar-Info 'portapapeles), ciérralo antes de seguir.'
    if ($historial -eq 1 -or $enlace.Count -gt 0) {
        return (Preguntar-SiNo '¿Lo has revisado y seguimos?' $true)
    }
    return $true
}

function Ocultar-Contrasenas {
    $previo = Leer-Ajuste 'system' 'show_password'
    if ($previo -eq '0') { return }
    if ($previo -ne '1' -and $previo -ne 'null') { $previo = '1' }
    $r = Invocar-Shell @('settings', 'put', 'system', 'show_password', '0')
    if ($r.Codigo -eq 0 -and -not (Hay-ErrorPermiso $r) -and (Leer-Ajuste 'system' 'show_password') -eq '0') {
        Anotar 'SHOWPW_ANTES' $previo ''
        $script:ShowPwAntes = $previo
        return
    }
    Mostrar-Aviso 'No he podido ocultar "Mostrar contraseñas" en el móvil: al teclear podría verse un'
    Mostrar-Info  'instante el último carácter. Desactívalo a mano (busca "Mostrar contraseñas" en Ajustes)'
    Mostrar-Info  'o, mientras el script teclea, NO mires la pantalla del móvil.'
}

function Restaurar-Contrasenas {
    if ($null -eq $script:ShowPwAntes) { return }
    $valor = $script:ShowPwAntes
    if ($valor -ne '0') { $valor = '1' }
    $null = Invocar-Shell @('settings', 'put', 'system', 'show_password', $valor)
    Anotar 'SHOWPW_RESTAURADO' $valor ''
    $script:ShowPwAntes = $null
}

function Vaciar-Campo {
    # Borra lo que haya en el campo con el foco: tecla "Fin" (123) y varias veces "Borrar" (67).
    # En un campo vacío no hace nada; así un intento repetido no se suma al anterior.
    param([int]$Veces)
    $teclas = @('input', 'keyevent', '123')
    for ($i = 0; $i -lt $Veces; $i++) { $teclas += '67' }
    $null = Invocar-Shell $teclas
}

function Teclear-Llave {
    param([string]$Texto)
    Vaciar-Campo ($Texto.Length + 8)
    $r = Invocar-Shell @('input', 'text', $Texto)
    if (Hay-ErrorPermiso $r) {
        Mostrar-Error 'El móvil no ha aceptado el tecleo por cable.'
        Mostrar-AyudaPermisos
        return $false
    }
    if ($r.Codigo -ne 0) {
        # Nunca se muestra $r.Texto aquí, por si acaso.
        Mostrar-Error 'No he podido teclear en el móvil. ¿Se ha desconectado el cable o se ha bloqueado la pantalla?'
        return $false
    }
    return $true
}

function Teclear-ConComprobacion {
    # Teclea la llave y pregunta si se ve bien. Devuelve $false si la persona cancela.
    param([string]$Texto, [string]$Momento)
    while ($true) {
        $r = Leer-Respuesta ('Toca el campo en el móvil (que esté VACÍO) y pulsa Intro aquí para teclear ' + $Momento + ' (o escribe C para cancelar)')
        if ($r -match '^[cC]') { return $false }
        if (-not (Teclear-Llave $Texto)) { return $false }
        Mostrar-Info ('Deberías ver ' + $Texto.Length + ' puntos o caracteres ocultos en el campo.')
        Mostrar-Info 'Si ves MENOS, ese campo no admite tantos caracteres: responde C, sal sin guardar y'
        Mostrar-Info 'vuelve a empezar eligiendo "PIN de otra longitud" con menos dígitos.'
        $ok = Leer-Respuesta '¿Se ve bien? S (sí) / R (repetir) / C (cancelar)'
        if ($ok -match '^[sS]' -or $ok -eq '') { return $true }
        if ($ok -match '^[cC]') { return $false }
    }
}

function Invoke-Llave {
    Mostrar-Titulo '2) Meter una llave en el móvil sin verla'
    Mostrar-Info 'Así funciona:'
    Mostrar-Info '  1. El script crea una llave al azar. Nunca sale en pantalla ni se guarda en ningún archivo.'
    Mostrar-Info '  2. La copia al portapapeles: la pegas (Ctrl+V) en tu cápsula del tiempo y la programas'
    Mostrar-Info '     (carpeta llaves/). Mejor en DOS cápsulas.'
    Mostrar-Info '  3. Vacía el portapapeles y teclea la llave en el móvil por el cable.'
    Mostrar-Info '  4. Comprobamos que la llave abre antes de terminar.'
    Mostrar-Aviso 'Si la llave es el PIN de "Controles parentales" y la pierdes, solo podrás quitarlos'
    Mostrar-Info  'restableciendo el móvil de fábrica. Ten la cápsula preparada antes de empezar.'
    Write-Host ''

    $apartamento = [System.Threading.Thread]::CurrentThread.GetApartmentState()
    if ($apartamento -ne [System.Threading.ApartmentState]::STA) {
        Mostrar-Error 'Para usar el portapapeles, abre el script con EJECUTAR-movil.bat.'
        return
    }
    if (-not (Revisar-PortapapelesWindows)) { return }

    Write-Host ''
    Mostrar-Info '¿Para qué es la llave?'
    Mostrar-Info '  1) PIN de "Controles parentales" de Android (10 dígitos)'
    Mostrar-Info '  2) PIN de Google Play (4 dígitos)'
    Mostrar-Info '  3) PIN de otra longitud (por ejemplo, el de AppBlock si su teclado solo tiene números)'
    Mostrar-Info '  4) Contraseña de letras y números (16 caracteres, para campos que admiten letras)'
    Mostrar-Info '  0) Volver'
    $op = Leer-Respuesta 'Elige una opción'
    $soloNumeros = $true
    $longitud = 0
    $descripcion = ''
    switch ($op) {
        '1' { $longitud = 10; $descripcion = 'PIN de Controles parentales' }
        '2' { $longitud = 4;  $descripcion = 'PIN de Google Play' }
        '3' {
            $descripcion = 'PIN numérico'
            while ($longitud -lt 4 -or $longitud -gt 16) {
                $t = Leer-Respuesta '¿Cuántos dígitos? (entre 4 y 16; 0 para volver)'
                $n = 0
                if ([int]::TryParse($t, [ref]$n)) { $longitud = $n }
                if ($t -eq '0') { return }
            }
        }
        '4' { $longitud = 16; $soloNumeros = $false; $descripcion = 'Contraseña alfanumérica' }
        default { return }
    }

    if (-not (Conectar-Movil)) { return }

    $secreto = Nueva-Llave $longitud $soloNumeros
    $exito = $false
    try {
        # Paso 1: cápsula
        Mostrar-Titulo 'Paso 1 de 3: guarda la llave en tu cápsula del tiempo'
        Copiar-Llave $secreto
        Mostrar-Ok 'La llave está en el portapapeles. NO la pegues en esta ventana.'
        Mostrar-Info 'Abre tu cápsula (correo programado, caja con temporizador...: carpeta llaves/),'
        Mostrar-Info 'pega con Ctrl+V, programa la fecha de apertura y guarda. Hazlo sin pararte a leerla.'
        Mostrar-Info 'No cierres esta ventana con la X: si tuvieras que hacerlo, copia antes cualquier'
        Mostrar-Info 'palabra para que la llave no se quede en el portapapeles.'
        if (-not (Esperar-Palabra 'Cuando esté guardada y programada, escribe LISTO (o CANCELAR)' 'LISTO')) {
            Mostrar-Info 'Cancelado. Si llegaste a programar la cápsula, bórrala sin abrirla (o déjala: esa llave no se usará).'
            return
        }
        $segunda = Preguntar-SiNo '¿La guardas también en una segunda cápsula? (muy recomendable)' ($op -eq '1')
        if ($segunda) {
            Copiar-Llave $secreto
            Mostrar-Ok 'Copiada otra vez. Pégala en la segunda cápsula y prográmala.'
            if (-not (Esperar-Palabra 'Cuando esté guardada, escribe LISTO (o CANCELAR)' 'LISTO')) {
                Mostrar-Info 'Cancelado. Si programaste alguna cápsula, bórrala sin abrirla (o déjala: esa llave no se usará).'
                return
            }
        }
        Limpiar-Portapapeles
        Mostrar-Ok 'Portapapeles vaciado.'

        # Paso 2: móvil
        Mostrar-Titulo 'Paso 2 de 3: teclear la llave en el móvil'
        Ocultar-Contrasenas
        Mostrar-Info ('En el móvil, abre la pantalla donde se crea el ' + $descripcion + '.')
        Mostrar-Info 'Ejemplos: Ajustes > Controles parentales; Play Store > Ajustes > Familia >'
        Mostrar-Info 'Controles parentales; AppBlock > Modo estricto > PIN.'
        if (-not (Teclear-ConComprobacion $secreto 'la llave')) {
            Mostrar-Info 'Cancelado. En el móvil, sal de esa pantalla SIN guardar.'
            return
        }
        Mostrar-Info 'Ahora pulsa "Siguiente" o "Continuar" en el móvil.'
        if (Preguntar-SiNo '¿Te pide repetir (confirmar) la llave?' $true) {
            if (-not (Teclear-ConComprobacion $secreto 'la confirmación')) {
                Mostrar-Info 'Cancelado. En el móvil, sal de esa pantalla SIN guardar.'
                return
            }
        }
        Mostrar-Info 'Pulsa "Confirmar", "Guardar" o "Siguiente" en el móvil para terminar de crearla.'

        # Paso 3: prueba
        Mostrar-Titulo 'Paso 3 de 3: comprobar que la llave abre'
        Mostrar-Info 'Sal de esa pantalla y vuelve a entrar (por ejemplo, abre otra vez Ajustes > Controles'
        Mostrar-Info 'parentales). Cuando el móvil te pida el PIN o la contraseña, haz lo siguiente.'
        Mostrar-Info '(En AppBlock, meter el PIN puede desactivar el modo estricto. Si pasa, actívalo otra vez'
        Mostrar-Info 'y, cuando te pida el PIN, usa la opción T del final para meter esta MISMA llave.)'
        $intentos = 0
        $omitida = $false
        while ($intentos -lt 3) {
            $r = Leer-Respuesta 'Toca el campo y pulsa Intro para teclear la llave (o escribe O para omitir la prueba)'
            if ($r -match '^[oO]') {
                Mostrar-Aviso 'Prueba omitida. Hazla cuanto antes: si la llave no abriera, mejor saberlo ahora.'
                $omitida = $true
                break
            }
            if (-not (Teclear-Llave $secreto)) { break }
            $intentos++
            Mostrar-Info 'Si el móvil no entra solo, pulsa "Aceptar" o la tecla de confirmar.'
            if (Preguntar-SiNo '¿Te ha dejado entrar? Escribe S o N' $false -SinDefecto) {
                Mostrar-Ok 'La llave funciona.'
                $exito = $true
                break
            }
            if ($intentos -lt 3) { Mostrar-Aviso 'Vamos a repetir (el script borra antes el campo).' }
        }
        if (-not $exito -and -not $omitida) {
            Mostrar-Error 'No se ha podido comprobar que la llave abre.'
            Mostrar-Info 'No cierres esta ventana todavía. Mira "La prueba de la llave falla" en la GUIA.md'
            Mostrar-Info '(Problemas frecuentes). Si sigues dentro de la pantalla de configuración, cambia o'
            Mostrar-Info 'quita el PIN desde ahí; si no, la salida es la que explica la guía.'
        }

        # Más tecleos con la misma llave (por ejemplo, para volver a activar algo que la prueba desactivó).
        while ($true) {
            $r = Leer-Respuesta 'Escribe T si necesitas que vuelva a teclear esta misma llave; pulsa Intro para terminar'
            if ($r -notmatch '^[tT]') { break }
            if (-not (Teclear-ConComprobacion $secreto 'la llave')) { continue }
            Mostrar-Info 'Si te pide repetirla, escribe T otra vez.'
        }
        Anotar 'LLAVE' $descripcion ('longitud ' + $longitud + '; prueba superada: ' + $exito)
    } finally {
        Limpiar-Portapapeles
        try { Restaurar-Contrasenas } catch { Mostrar-Aviso 'No he podido volver a dejar "Mostrar contraseñas" como estaba.' }
        $secreto = $null
        [System.GC]::Collect()
    }
}

# ---------------------------------------------------------------------------
# Opción 3: comprobar (solo lectura)
# ---------------------------------------------------------------------------

function Invoke-Comprobar {
    Mostrar-Titulo '3) Comprobar cómo está el móvil (no cambia nada)'
    if (-not (Conectar-Movil)) { return }
    Write-Host ''
    if ($script:Sdk -ge 28) {
        $modo = Leer-Ajuste 'global' 'private_dns_mode'
        $servidor = Leer-Ajuste 'global' 'private_dns_specifier'
        if ($modo -eq 'hostname' -and $servidor -eq $script:DnsHost) {
            Mostrar-Ok ('DNS privado: ' + $servidor)
        } else {
            if ($servidor -eq 'null' -or [string]::IsNullOrEmpty($servidor)) { $servidor = '(ninguno)' }
            Mostrar-Aviso ('DNS privado: modo = ' + (Describir-Modo $modo) + '; servidor = ' + $servidor + ' (no es CleanBrowsing)')
        }
    } else {
        Mostrar-Aviso 'Android anterior al 9: sin DNS privado.'
    }
    Revisar-Usuarios -SoloMirar
    $det = Detectar-Apps
    if ($null -eq $det) { return }
    switch ($det.Chrome) {
        'ok'          { Mostrar-Ok 'Chrome: instalado y activo.' }
        'desactivado' { Mostrar-Aviso 'Chrome: desactivado.' }
        default       { Mostrar-Aviso 'Chrome: no instalado.' }
    }
    $pendientes = @($det.Candidatas | Where-Object { -not $_.Desactivada })
    if ($pendientes.Count -eq 0) {
        Mostrar-Ok 'No quedan otros navegadores ni apps de riesgo activos.'
    } else {
        Mostrar-Aviso 'Siguen activas estas apps:'
        Mostrar-Candidatas $pendientes
    }
    $dev = Leer-Ajuste 'global' 'development_settings_enabled'
    if ($dev -eq '1') {
        Mostrar-Info 'Opciones para desarrolladores: activadas (cuando acabes, usa la opción 4).'
    }
}

# ---------------------------------------------------------------------------
# Opción 4: terminar (apagar la depuración)
# ---------------------------------------------------------------------------

function Invoke-Terminar {
    Mostrar-Titulo '4) Terminar: apagar la depuración USB y las opciones para desarrolladores'
    Mostrar-Info 'Hazlo cuando ya hayas metido todas las llaves que necesites por cable.'
    Mostrar-Info 'Para volver a usar este script tendrás que activar otra vez la depuración en el móvil.'
    if (-not (Preguntar-SiNo '¿Lo apago ahora?' $true)) { return }
    if (-not (Conectar-Movil)) { return }

    Restaurar-Contrasenas
    $r = Invocar-Shell @('settings', 'put', 'global', 'development_settings_enabled', '0')
    if (Hay-ErrorPermiso $r) {
        Mostrar-AyudaPermisos
        Mostrar-Info 'Hazlo a mano: Opciones para desarrolladores > interruptor de arriba en "Desactivado".'
        return
    }
    Anotar 'DEPURACION_APAGADA' '' ''
    # Esto corta la conexión: es lo último que se hace por cable.
    $null = Invocar-Shell @('settings', 'put', 'global', 'adb_enabled', '0')
    Start-Sleep -Seconds 2
    $null = Invocar-Adb -Argumentos @('kill-server') -SinDispositivo
    Mostrar-Ok 'Depuración USB y opciones para desarrolladores apagadas.'

    Write-Host ''
    Mostrar-Info 'Además puedo borrar la autorización de ESTE PC (equivale a "Revocar autorizaciones de'
    Mostrar-Info 'depuración USB" para este ordenador): la próxima vez el móvil volverá a pedir permiso.'
    if (Preguntar-SiNo '¿La borro?' $true) {
        $carpetaClaves = Join-Path $env:USERPROFILE '.android'
        if (-not [string]::IsNullOrEmpty($env:ANDROID_USER_HOME)) { $carpetaClaves = $env:ANDROID_USER_HOME }
        foreach ($f in @('adbkey', 'adbkey.pub')) {
            $ruta = Join-Path $carpetaClaves $f
            if (Test-Path -LiteralPath $ruta) { Remove-Item -LiteralPath $ruta -Force -ErrorAction SilentlyContinue }
        }
        Mostrar-Ok 'Autorización de este PC borrada.'
        Anotar 'INFO' 'Autorización adb del PC borrada' ''
    }
    Write-Host ''
    Mostrar-Info 'Últimos toques en el móvil:'
    Mostrar-Info '  - Comprueba que "Opciones para desarrolladores" ya no aparece en Ajustes.'
    Mostrar-Info '  - Samsung: vuelve a activar Ajustes > Seguridad y privacidad > Bloqueador automático.'
    Mostrar-Info '  - Desconecta el cable.'
}

# ---------------------------------------------------------------------------
# Opción 5: deshacer
# ---------------------------------------------------------------------------

function Restaurar-Dns {
    param($Entrada)
    if ($script:Sdk -lt 28) { return }
    $modo = 'opportunistic'
    $servidor = ''
    if ($null -ne $Entrada) {
        if (@('off', 'opportunistic', 'hostname') -contains $Entrada.Dato1) { $modo = $Entrada.Dato1 }
        $servidor = $Entrada.Dato2
    }
    # Solo se restaura un servidor anterior si parece un nombre de host válido.
    if ($servidor -notmatch '^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)+$') { $servidor = '' }
    if ($modo -eq 'hostname' -and ($servidor -eq '' -or $servidor -eq 'null' -or $servidor -eq $script:DnsHost)) {
        # No tiene sentido "volver" a CleanBrowsing: se deja en Automático.
        $modo = 'opportunistic'
    }
    if ($servidor -ne '' -and $servidor -ne 'null' -and $servidor -ne $script:DnsHost) {
        $null = Invocar-Shell @('settings', 'put', 'global', 'private_dns_specifier', $servidor)
    } else {
        $null = Invocar-Shell @('settings', 'delete', 'global', 'private_dns_specifier')
    }
    $r = Invocar-Shell @('settings', 'put', 'global', 'private_dns_mode', $modo)
    if (Hay-ErrorPermiso $r) { Mostrar-AyudaPermisos; return }
    $leido = Leer-Ajuste 'global' 'private_dns_mode'
    if ($leido -eq $modo) {
        Mostrar-Ok ('DNS privado vuelto a: ' + (Describir-Modo $modo))
        Anotar 'DNS_RESTAURADO' $modo $servidor
    } else {
        Mostrar-Error 'No he podido comprobar el cambio del DNS. Hazlo a mano: Ajustes > DNS privado > Automático.'
    }
}

function Invoke-Deshacer {
    Mostrar-Titulo '5) Deshacer lo que hizo este script'
    Mostrar-Info 'Antes de esto, quita el modo estricto de AppBlock y los Controles parentales con sus'
    Mostrar-Info 'llaves (GUIA.md, "Cómo deshacerlo"). Si no, pueden volver a bloquear lo que restaure.'
    if (-not (Conectar-Movil)) { return }

    $todas = @(Leer-Registro)
    $mias = @($todas | Where-Object { $_.Serie -eq $script:Serie })
    if ($mias.Count -eq 0 -and $todas.Count -gt 0) {
        $series = @($todas | Where-Object { $_.Serie -ne '-' } | ForEach-Object { $_.Serie } | Sort-Object -Unique)
        if ($series.Count -gt 0) {
            Mostrar-Aviso ('El registro es de otro móvil (número de serie: ' + ($series -join ', ') + ').')
            if (Preguntar-SiNo '¿Aplico ese registro a este móvil de todas formas?' $false) {
                $mias = @($todas | Where-Object { $_.Serie -ne '-' })
            }
        }
    }

    # Qué queda pendiente de deshacer
    $pendientes = New-Object System.Collections.Specialized.OrderedDictionary
    $dnsAntes = $null
    $showPw = $null
    foreach ($e in $mias) {
        switch ($e.Tipo) {
            'QUITADO'           { if ($pendientes.Contains($e.Dato1)) { $pendientes.Remove($e.Dato1) }; $pendientes.Add($e.Dato1, $e) }
            'DESACTIVADO'       { if ($pendientes.Contains($e.Dato1)) { $pendientes.Remove($e.Dato1) }; $pendientes.Add($e.Dato1, $e) }
            'RESTAURADO'        { if ($pendientes.Contains($e.Dato1)) { $pendientes.Remove($e.Dato1) } }
            'DNS_ANTES'         { if ($null -eq $dnsAntes) { $dnsAntes = $e } }
            'DNS_RESTAURADO'    { $dnsAntes = $null }
            'SHOWPW_ANTES'      { if ($null -eq $showPw) { $showPw = $e } }
            'SHOWPW_RESTAURADO' { $showPw = $null }
        }
    }

    $dnsActual = ''
    if ($script:Sdk -ge 28) { $dnsActual = Leer-Ajuste 'global' 'private_dns_specifier' }
    $hayDns = ($null -ne $dnsAntes) -or ($dnsActual -eq $script:DnsHost)

    if ($pendientes.Count -eq 0 -and -not $hayDns -and $null -eq $showPw) {
        Mostrar-Ok 'No hay nada pendiente de deshacer en el registro para este móvil.'
        return
    }

    Write-Host ''
    Mostrar-Info 'Esto es lo que voy a deshacer:'
    if ($hayDns) { Mostrar-Info '- DNS privado: volver a como estaba antes (o a "Automático").' }
    $claves = @($pendientes.Keys)
    [array]::Reverse($claves)
    foreach ($k in $claves) {
        $e = $pendientes[$k]
        if ($e.Tipo -eq 'QUITADO') { $verbo = 'reinstalar' } else { $verbo = 'volver a activar' }
        Mostrar-Info ('- ' + $verbo + ': ' + $k)
    }
    if (-not (Preguntar-SiNo '¿Sigo?' $true)) { return }
    Anotar 'INICIO' 'deshacer' ''

    $aMano = @()
    foreach ($k in $claves) {
        $e = $pendientes[$k]
        if ($e.Tipo -eq 'DESACTIVADO') {
            $r = Invocar-Shell @('pm', 'enable', '--user', '0', $k)
            if ($r.Texto -match 'new state:\s*enabled') {
                Mostrar-Ok ('Activada de nuevo: ' + $k); Anotar 'RESTAURADO' $k 'activada'
            } else {
                Mostrar-Aviso ('No he podido activar ' + $k + ': ' + $r.Texto); $aMano += $k
            }
        } else {
            $r = Invocar-Shell @('cmd', 'package', 'install-existing', '--user', '0', $k)
            if ($r.Texto -match 'installed for user') {
                Mostrar-Ok ('Reinstalada: ' + $k); Anotar 'RESTAURADO' $k 'reinstalada'
            } else {
                Mostrar-Aviso ('No se puede reinstalar ' + $k + ' desde el propio móvil.'); $aMano += $k
            }
        }
    }

    if ($hayDns) { Restaurar-Dns $dnsAntes }

    if ($null -ne $showPw) {
        $script:ShowPwAntes = $showPw.Dato1
        Restaurar-Contrasenas
    }

    if ($aMano.Count -gt 0) {
        Write-Host ''
        Mostrar-Aviso 'Estas apps tienes que volver a instalarlas tú desde Google Play (o Galaxy Store / GetApps):'
        foreach ($k in $aMano) { Mostrar-Info ('- ' + (Nombre-App $k) + ' [' + $k + ']') }
    }
    Anotar 'FIN' 'deshacer' ''
    Write-Host ''
    Mostrar-Info 'Si quieres, quita también a mano: en Chrome, "Usar DNS seguro" > "Usar proveedor de'
    Mostrar-Info 'servicios actual"; SafeSearch y el modo restringido de YouTube.'
}

# ---------------------------------------------------------------------------
# Menú
# ---------------------------------------------------------------------------

function Mostrar-Menu {
    while ($true) {
        Mostrar-Titulo 'Kit para bloquear contenido adulto - móvil Android'
        Mostrar-Info '1) Configurar el móvil (DNS de CleanBrowsing + quitar navegadores y apps de riesgo)'
        Mostrar-Info '2) Meter una llave (PIN o contraseña) en el móvil sin verla'
        Mostrar-Info '3) Comprobar cómo está el móvil (no cambia nada)'
        Mostrar-Info '4) Terminar: apagar la depuración USB y las opciones para desarrolladores'
        Mostrar-Info '5) Deshacer lo que hizo este script (cuando llegue la llave)'
        Mostrar-Info '0) Salir'
        $op = Leer-Respuesta 'Elige una opción'
        $valida = $true
        switch ($op) {
            '1' { Invoke-Configurar }
            '2' { Invoke-Llave }
            '3' { Invoke-Comprobar }
            '4' { Invoke-Terminar }
            '5' { Invoke-Deshacer }
            '0' { return }
            default { Mostrar-Aviso 'Opción no válida.'; $valida = $false }
        }
        if ($valida) {
            Write-Host ''
            $null = Leer-Respuesta 'Pulsa Intro para volver al menú'
        }
    }
}

# ---------------------------------------------------------------------------
# Inicio
# ---------------------------------------------------------------------------

if ($env:OS -ne 'Windows_NT') {
    Write-Host 'Este script es para Windows.' -ForegroundColor Red
    exit 1
}

try {
    if ($Deshacer)       { Invoke-Deshacer }
    elseif ($Configurar) { Invoke-Configurar }
    elseif ($Llave)      { Invoke-Llave }
    elseif ($Comprobar)  { Invoke-Comprobar }
    elseif ($Terminar)   { Invoke-Terminar }
    else                 { Mostrar-Menu }
} catch {
    Mostrar-Error ('Ha ocurrido un error inesperado: ' + $_.Exception.Message)
    Mostrar-Info 'No se ha hecho nada más. Lo que ya estuviera hecho está anotado en el registro.'
    Anotar 'ERROR' $_.Exception.Message ''
} finally {
    if (Test-Path -LiteralPath $script:Adb) {
        $null = Invocar-Adb -Argumentos @('kill-server') -SinDispositivo
    }
}
