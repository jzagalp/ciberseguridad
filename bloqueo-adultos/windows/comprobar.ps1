<#
    comprobar.ps1  -  Comprueba el estado de cada capa del bloqueo.

    Lo puede ejecutar el usuario ESTANDAR (no necesita administrador).
    Muestra OK, FALLO o AVISO (no se pudo comprobar) por capa y un resumen.
    No cambia nada.
#>

$ErrorActionPreference = 'Continue'

$GrupoFw  = 'KitBloqueoAdultos'
$MarcaIni = '# >>> KitBloqueo (bloqueo de contenido adulto) - no editar a mano'
$Hosts    = Join-Path $env:windir 'System32\drivers\etc\hosts'
$SidAdmins = 'S-1-5-32-544'
$DominioPrueba = 'pornhub.com'           # dominio adulto conocido que debe quedar bloqueado
$DominioControl = 'example.com'          # dominio normal que debe funcionar
$IpFiltroCleanBrowsing = '185.228.168.168'
$IpsFiltro = @('185.228.168.168', '185.228.169.168', '1.1.1.3', '1.0.0.3')

$resultados = @()
function Add-Resultado {
    param([string]$Capa, [ValidateSet('OK', 'FALLO', 'AVISO')][string]$Estado, [string]$Detalle)
    $script:resultados += [pscustomobject]@{ Capa = $Capa; Estado = $Estado; Detalle = $Detalle }
    $col = 'Green'
    if ($Estado -eq 'FALLO') { $col = 'Red' }
    if ($Estado -eq 'AVISO') { $col = 'Yellow' }
    Write-Host ("[{0,-5}] {1}" -f $Estado, $Capa) -ForegroundColor $col
    if ($Detalle) { Write-Host ("        {0}" -f $Detalle) -ForegroundColor Gray }
}

function Test-IpRealPublica {
    # True si el texto es una IP que parece un destino real (no bloqueo).
    param([string]$Ip)
    if (-not $Ip) { return $false }
    if ($Ip -eq '0.0.0.0' -or $Ip -eq '::' -or $Ip -eq '127.0.0.1' -or $Ip -eq '::1') { return $false }
    return $true
}

function Resolve-Prueba {
    # Devuelve: Bloqueado (NXDOMAIN o 0.0.0.0), Resuelve (IP real), SinRespuesta (red / cortafuegos).
    param([string]$Nombre, [string]$Servidor)
    $p = @{ Name = $Nombre; Type = 'A'; DnsOnly = $true; QuickTimeout = $true; ErrorAction = 'Stop' }
    if ($Servidor) { $p['Server'] = $Servidor; $p['NoHostsFile'] = $true }
    try {
        $res = Resolve-DnsName @p
        $ips = @($res | Where-Object { $_.IPAddress } | ForEach-Object { $_.IPAddress })
        $real = $false
        foreach ($ip in $ips) { if (Test-IpRealPublica -Ip $ip) { $real = $true } }
        if ($real) { return [pscustomobject]@{ Estado = 'Resuelve'; Ips = ($ips -join ', ') } }
        return [pscustomobject]@{ Estado = 'Bloqueado'; Ips = ($ips -join ', ') }
    } catch {
        $nx = ($_.FullyQualifiedErrorId -like 'DNS_ERROR_RCODE_NAME_ERROR*')
        if (-not $nx -and $_.Exception -is [System.ComponentModel.Win32Exception]) { $nx = ($_.Exception.NativeErrorCode -eq 9003) }
        if ($nx) { return [pscustomobject]@{ Estado = 'Bloqueado'; Ips = 'NXDOMAIN (el nombre no existe)' } }
        return [pscustomobject]@{ Estado = 'SinRespuesta'; Ips = $_.Exception.Message }
    }
}

Write-Host ''
Write-Host '=== Comprobacion del bloqueo de contenido adulto ===' -ForegroundColor Cyan
Write-Host ''

# ---- 0) Hay conexion con el filtro? (si no, las pruebas de DNS no son fiables) ----
$control = Resolve-Prueba -Nombre $DominioControl -Servidor $IpFiltroCleanBrowsing
$hayRed = ($control.Estado -eq 'Resuelve')
if ($hayRed) {
    Add-Resultado -Capa 'Conexion con CleanBrowsing (filtro DNS)' -Estado 'OK' -Detalle ("'{0}' resuelve a traves del filtro." -f $DominioControl)
} else {
    Add-Resultado -Capa 'Conexion con CleanBrowsing (filtro DNS)' -Estado 'AVISO' -Detalle 'Sin conexion o el filtro no responde. Conectate a internet y repite la comprobacion.'
}

# ---- 1) Resolucion normal del equipo (DNS + hosts) ----
$r1 = Resolve-Prueba -Nombre $DominioPrueba
$capa1 = ("DNS/hosts: '{0}' queda bloqueado" -f $DominioPrueba)
if ($r1.Estado -eq 'Bloqueado') { Add-Resultado -Capa $capa1 -Estado 'OK' -Detalle ('Respuesta: ' + $r1.Ips + ' (sin IP real).') }
elseif ($r1.Estado -eq 'Resuelve') { Add-Resultado -Capa $capa1 -Estado 'FALLO' -Detalle ('Resuelve a una IP real: ' + $r1.Ips + '. El filtrado NO esta activo.') }
else { Add-Resultado -Capa $capa1 -Estado 'AVISO' -Detalle 'No se pudo comprobar (sin respuesta).' }

# ---- 2) El DNS de cada adaptador conectado es el del filtro ----
try {
    $conectados = @(Get-NetAdapter -ErrorAction Stop | Where-Object { $_.Status -eq 'Up' })
    $mal = @(); $bien = @()
    foreach ($a in $conectados) {
        $cfg = Get-DnsClientServerAddress -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
        $lista = @()
        if ($cfg) { $lista = @($cfg.ServerAddresses) }
        if ($lista.Count -gt 0 -and ($IpsFiltro -contains $lista[0])) { $bien += $a.InterfaceAlias }
        else { $mal += ('{0} ({1})' -f $a.InterfaceAlias, ($lista -join ', ')) }
    }
    if ($conectados.Count -eq 0) { Add-Resultado -Capa 'DNS de los adaptadores = filtro' -Estado 'AVISO' -Detalle 'No hay adaptadores conectados.' }
    elseif ($mal.Count -eq 0) { Add-Resultado -Capa 'DNS de los adaptadores = filtro' -Estado 'OK' -Detalle ('Con el filtro: ' + ($bien -join ', ')) }
    else { Add-Resultado -Capa 'DNS de los adaptadores = filtro' -Estado 'FALLO' -Detalle ('Sin el filtro: ' + ($mal -join '; ') + '. Reinicia: la tarea programada lo corrige al arrancar.') }
} catch { Add-Resultado -Capa 'DNS de los adaptadores = filtro' -Estado 'AVISO' -Detalle 'No se pudo leer la configuracion DNS.' }

# ---- 3) CleanBrowsing bloquea el dominio de prueba (consulta directa al servidor) ----
$r3 = Resolve-Prueba -Nombre $DominioPrueba -Servidor $IpFiltroCleanBrowsing
if ($r3.Estado -eq 'Bloqueado') { Add-Resultado -Capa 'CleanBrowsing bloquea el dominio de prueba' -Estado 'OK' -Detalle ('Respuesta del filtro: ' + $r3.Ips) }
elseif ($r3.Estado -eq 'Resuelve') { Add-Resultado -Capa 'CleanBrowsing bloquea el dominio de prueba' -Estado 'FALLO' -Detalle ('Devuelve: ' + $r3.Ips + '. Algo intercepta el DNS antes de llegar al filtro (por ejemplo el "DNS Seguro" de algunos routers de Vodafone/Lowi): mira GUIA.md y la guia del router.') }
else { Add-Resultado -Capa 'CleanBrowsing bloquea el dominio de prueba' -Estado 'AVISO' -Detalle 'El filtro no respondio.' }

# ---- 3b) Busqueda segura forzada por el filtro (misma prueba que la guia del router) ----
if ($hayRed) {
    try {
        $rg = Resolve-DnsName -Name 'www.google.com' -Server $IpFiltroCleanBrowsing -DnsOnly -NoHostsFile -QuickTimeout -ErrorAction Stop
        $txt = (@($rg | ForEach-Object { ('' + $_.NameHost + ' ' + $_.IPAddress) }) -join ' ')
        if ($txt -match 'forcesafesearch\.google\.com|216\.239\.38\.120') { Add-Resultado -Capa 'Busqueda segura de Google forzada por el filtro' -Estado 'OK' -Detalle 'www.google.com apunta a forcesafesearch.google.com.' }
        else { Add-Resultado -Capa 'Busqueda segura de Google forzada por el filtro' -Estado 'AVISO' -Detalle 'No aparece forcesafesearch.google.com: puede que algo intercepte el DNS. Las directivas del navegador la siguen forzando.' }
    } catch { Add-Resultado -Capa 'Busqueda segura de Google forzada por el filtro' -Estado 'AVISO' -Detalle 'No se pudo comprobar.' }
}

# ---- 4) DNS publico directo DEBE fallar (cortafuegos) ----
$r4 = Resolve-Prueba -Nombre $DominioControl -Servidor '8.8.8.8'
if (-not $hayRed) { Add-Resultado -Capa 'Cortafuegos bloquea DNS publico (8.8.8.8)' -Estado 'AVISO' -Detalle 'Sin conexion: no se puede comprobar.' }
elseif ($r4.Estado -eq 'SinRespuesta') { Add-Resultado -Capa 'Cortafuegos bloquea DNS publico (8.8.8.8)' -Estado 'OK' -Detalle 'La consulta a 8.8.8.8 no pasa: bloqueada.' }
else { Add-Resultado -Capa 'Cortafuegos bloquea DNS publico (8.8.8.8)' -Estado 'FALLO' -Detalle 'Se pudo consultar a 8.8.8.8: el cortafuegos NO esta bloqueando.' }

# ---- 5) Reglas y perfiles del cortafuegos ----
try {
    $fw = @(Get-NetFirewallRule -Group $GrupoFw -ErrorAction Stop | Where-Object { ('' + $_.Enabled) -eq 'True' })
    if ($fw.Count -ge 3) { Add-Resultado -Capa 'Reglas del cortafuegos del kit presentes' -Estado 'OK' -Detalle ("{0} reglas activas en el grupo {1}." -f $fw.Count, $GrupoFw) }
    else { Add-Resultado -Capa 'Reglas del cortafuegos del kit presentes' -Estado 'FALLO' -Detalle ("Solo {0} reglas activas (se esperaban 3 o mas)." -f $fw.Count) }
} catch { Add-Resultado -Capa 'Reglas del cortafuegos del kit presentes' -Estado 'AVISO' -Detalle 'No se pudieron leer las reglas.' }
try {
    $apagados = @(Get-NetFirewallProfile -ErrorAction Stop | Where-Object { ('' + $_.Enabled) -ne 'True' })
    if ($apagados.Count -eq 0) { Add-Resultado -Capa 'Cortafuegos de Windows activado' -Estado 'OK' -Detalle 'Los tres perfiles estan activados.' }
    else { Add-Resultado -Capa 'Cortafuegos de Windows activado' -Estado 'FALLO' -Detalle ('Desactivado en: ' + (($apagados | ForEach-Object { $_.Name }) -join ', ')) }
} catch { Add-Resultado -Capa 'Cortafuegos de Windows activado' -Estado 'AVISO' -Detalle 'No se pudo leer el estado del cortafuegos.' }
try {
    $ajenos = @(Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName FirewallProduct -ErrorAction Stop | Where-Object { $_.displayName -and $_.displayName -notmatch 'Windows' })
    if ($ajenos.Count -gt 0) {
        Add-Resultado -Capa 'Otro cortafuegos instalado' -Estado 'AVISO' -Detalle ('Hay otro cortafuegos (' + (($ajenos | ForEach-Object { $_.displayName }) -join ', ') + '): las reglas de Windows podrian no aplicarse. Mira GUIA.md.')
    }
} catch { }

# ---- 6) Directivas de navegador presentes ----
$chk = @(
    @{ Path = 'HKLM:\SOFTWARE\Policies\Google\Chrome'; Name = 'IncognitoModeAvailability'; Esperado = 1; Etiqueta = 'Chrome sin incognito' },
    @{ Path = 'HKLM:\SOFTWARE\Policies\Google\Chrome'; Name = 'ProxySettings'; Esperado = '{"ProxyMode":"direct"}'; Etiqueta = 'Chrome sin proxy' },
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'; Name = 'InPrivateModeAvailability'; Esperado = 1; Etiqueta = 'Edge sin InPrivate' },
    @{ Path = 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS'; Name = 'Locked'; Esperado = 1; Etiqueta = 'Firefox DoH bloqueado' },
    @{ Path = 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox'; Name = 'IPProtectionAvailable'; Esperado = 0; Etiqueta = 'Firefox sin VPN integrada' }
)
foreach ($c in $chk) {
    $val = $null
    try { $p = Get-ItemProperty -Path $c.Path -Name $c.Name -ErrorAction Stop; $val = $p.($c.Name) } catch { }
    if ($null -ne $val -and "$val" -eq "$($c.Esperado)") { Add-Resultado -Capa ("Directiva: {0}" -f $c.Etiqueta) -Estado 'OK' -Detalle ("{0}\{1} = {2}" -f $c.Path, $c.Name, $val) }
    else { Add-Resultado -Capa ("Directiva: {0}" -f $c.Etiqueta) -Estado 'FALLO' -Detalle ("Esperado {0}, encontrado '{1}'." -f $c.Esperado, $val) }
}

# ---- 7) Bloque en el fichero hosts ----
try {
    $h = Get-Content -LiteralPath $Hosts -Encoding UTF8 -ErrorAction Stop
    if ($h -contains $MarcaIni) {
        $lineasBloqueo = @($h | Where-Object { $_ -match '^0\.0\.0\.0\s' }).Count
        Add-Resultado -Capa 'Bloque del kit en el fichero hosts' -Estado 'OK' -Detalle ("Marcador presente; {0} lineas 0.0.0.0." -f $lineasBloqueo)
    } else { Add-Resultado -Capa 'Bloque del kit en el fichero hosts' -Estado 'FALLO' -Detalle 'No se encontro el marcador del kit.' }
} catch { Add-Resultado -Capa 'Bloque del kit en el fichero hosts' -Estado 'AVISO' -Detalle 'No se pudo leer el fichero hosts.' }

# ---- 8) La cuenta actual es ESTANDAR (tambien detecta un admin con UAC sin elevar) ----
try {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $pr = New-Object System.Security.Principal.WindowsPrincipal($id)
    $esAdmin = $pr.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    $comprobado = $false
    if (-not $esAdmin) {
        # Con UAC, un administrador sin elevar tiene el grupo Administradores "solo para denegar":
        # whoami /groups lo sigue mostrando por su SID (no depende del idioma).
        try {
            $grupos = (& whoami.exe /groups /fo csv 2>$null) -join "`n"
            if ($grupos) { $comprobado = $true; if ($grupos -match [regex]::Escape($SidAdmins)) { $esAdmin = $true } }
        } catch { }
        if (-not $comprobado) {
            try {
                $nt = (New-Object System.Security.Principal.SecurityIdentifier($SidAdmins)).Translate([System.Security.Principal.NTAccount]).Value
                $grupo = [ADSI]("WinNT://./{0},group" -f $nt.Split('\')[-1])
                foreach ($m in @($grupo.psbase.Invoke('Members'))) {
                    $bytes = $m.GetType().InvokeMember('objectSid', 'GetProperty', $null, $m, $null)
                    if ((New-Object System.Security.Principal.SecurityIdentifier($bytes, 0)).Value -eq $id.User.Value) { $esAdmin = $true }
                }
                $comprobado = $true
            } catch { }
        }
    } else { $comprobado = $true }
    if (-not $comprobado) { Add-Resultado -Capa 'Tu cuenta es ESTANDAR (sin admin)' -Estado 'AVISO' -Detalle 'No se pudo comprobar.' }
    elseif (-not $esAdmin) { Add-Resultado -Capa 'Tu cuenta es ESTANDAR (sin admin)' -Estado 'OK' -Detalle $id.Name }
    else { Add-Resultado -Capa 'Tu cuenta es ESTANDAR (sin admin)' -Estado 'FALLO' -Detalle ('Tu cuenta AUN es administrador: ' + $id.Name + '. Si acabas de hacer el paso de cuentas, cierra sesion y vuelve a entrar.') }
} catch { Add-Resultado -Capa 'Tu cuenta es ESTANDAR (sin admin)' -Estado 'AVISO' -Detalle 'No se pudo comprobar.' }

# ---- Resumen ----
Write-Host ''
$ok = @($resultados | Where-Object { $_.Estado -eq 'OK' }).Count
$fallos = @($resultados | Where-Object { $_.Estado -eq 'FALLO' }).Count
$avisos = @($resultados | Where-Object { $_.Estado -eq 'AVISO' }).Count
Write-Host ("Resumen: {0} OK, {1} FALLO, {2} AVISO (de {3} comprobaciones)." -f $ok, $fallos, $avisos, $resultados.Count) -ForegroundColor Cyan
if ($fallos -gt 0 -or $avisos -gt 0) {
    Write-Host 'Si acabas de ejecutar el bloqueo, cierra sesion (o reinicia), conectate a internet y repite.' -ForegroundColor Yellow
}
Write-Host 'Recuerda: ningun bloqueo es 100% infalible. Lee los "huecos residuales" en GUIA.md.' -ForegroundColor Yellow
Write-Host ''
