<#
    bloquear-pc.ps1  -  Kit para bloquear contenido adulto (capa Windows)

    Aplica, en este orden, varias capas que se refuerzan entre si:
      (a) DNS filtrado (CleanBrowsing Family) en todos los adaptadores de red,
          IPv4 e IPv6, con Cloudflare Families como ultimo recurso, mas una tarea
          programada (SYSTEM) que reaplica el DNS al arrancar / iniciar sesion /
          conectar una red. DoH de Windows 11 solo si lo pides (-DohWindows11).
      (b) Directivas de navegador por registro (Chrome, Chromium, Brave, Vivaldi,
          Edge, Firefox): sin modo incognito, SafeSearch forzado, YouTube
          restringido, sin perfiles invitado, sin extensiones de proxy/VPN,
          sin VPN integradas del navegador, etc.
      (c) Fichero hosts: lista de dominios adultos (comprimida y saneada) mas un
          bloque de nombres de DNS cifrado publico, entre marcadores.
      (d) Reglas del Cortafuegos de Windows que obligan a que TODO el DNS del
          equipo vaya al filtro (fallan en modo cerrado, nunca abierto).
      (e) Mitigaciones opcionales para apps portables (solo si pides -IfeoExtra).
      (f) Cuentas: crea (o renueva) un administrador local con una llave que tu NO
          ves, la copia al portapapeles para que la pegues en tu "capsula del
          tiempo" y SOLO despues convierte tu cuenta en estandar. Nunca deja el
          equipo sin un administrador activo.

    Es idempotente: puedes ejecutarlo varias veces sin duplicar nada.
    Si lo ejecutas con tu cuenta ya estandar (elevando con GuardianBloqueo y la
    llave), el paso (f) te ofrece RENOVAR: poner una llave nueva a GuardianBloqueo.

    Guarda copia de seguridad y registro en C:\ProgramData\BloqueoAdultos\
    (carpeta que el usuario estandar no puede modificar). La llave NUNCA se
    muestra, ni se escribe en disco ni en el registro de actividad.

    Para deshacerlo cuando llegue la llave: EJECUTAR-deshacer.bat (deshacer-pc.ps1)
    Para comprobar el estado (lo puede ejecutar el usuario estandar): EJECUTAR-comprobacion.bat

    NINGUN bloqueo es 100% infalible. Lee GUIA.md: explica los huecos que quedan.
#>

[CmdletBinding()]
param(
    [switch]$SinCuentas,      # aplica todo menos el paso de cuentas (f)
    [switch]$IfeoExtra,       # anade bloqueo IFEO de tor.exe/opera.exe/psiphon3.exe (friccion extra, evitable renombrando)
    [switch]$ActualizarLista, # descarga la lista de dominios de StevenBlack y regenera lista-adultos.hosts (solo bloquea, nunca redirige)
    [switch]$DohWindows11,    # OPCIONAL: cifra el DNS con DoH en Windows 11 (evita que el router del operador intercepte el DNS)
    [switch]$Elevado          # uso interno: evita bucles al pedir permisos
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'  # evita que algo muestre la llave

# ======================================================================
#  CONSTANTES
# ======================================================================
$BaseDatos   = Join-Path $env:ProgramData 'BloqueoAdultos'
$DirCopias   = Join-Path $BaseDatos 'copias'
$DirLog      = Join-Path $BaseDatos 'log'
$CarpetaTarea = Join-Path $env:ProgramFiles 'KitBloqueo'
$NombreTarea = 'KitBloqueo - Reaplicar DNS'
$RutaTareaSch = '\KitBloqueo\'
$NombreAdmin = 'GuardianBloqueo'
$GrupoFw     = 'KitBloqueoAdultos'
$MarcaIni    = '# >>> KitBloqueo (bloqueo de contenido adulto) - no editar a mano'
$MarcaFin    = '# <<< KitBloqueo'
$Hosts       = Join-Path $env:windir 'System32\drivers\etc\hosts'
$RutaScript  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ListaHostsOrigen = Join-Path $RutaScript 'lista-adultos.hosts'
$PatronLineaLista = '^0\.0\.0\.0( [A-Za-z0-9.-]+){1,9}$'   # solo bloqueo, max 9 dominios por linea

$SidAdmins = 'S-1-5-32-544'
$SidUsers  = 'S-1-5-32-545'
$SidSystem = 'S-1-5-18'

# DNS filtrado: CleanBrowsing Family primero, Cloudflare Families como respaldo.
# (Verificado en la lista DoH de Chromium y en la documentacion de Cloudflare.)
$DnsFiltradoV4 = @('185.228.168.168','185.228.169.168','1.1.1.3','1.0.0.3')
$DnsFiltradoV6 = @('2a0d:2a00:1::','2a0d:2a00:2::','2606:4700:4700::1113','2606:4700:4700::1003')
$DnsFiltrado   = $DnsFiltradoV4 + $DnsFiltradoV6

# Rangos COMPLEMENTARIOS (todo salvo las IP del filtro) para bloquear el DNS.
$RangosNoFiltro = @(
    '0.0.0.1-1.0.0.2','1.0.0.4-1.1.1.2','1.1.1.4-185.228.168.167',
    '185.228.168.169-185.228.169.167','185.228.169.169-255.255.255.255',
    '::1-2606:4700:4700::1002','2606:4700:4700::1004-2606:4700:4700::1112',
    '2606:4700:4700::1114-2a0d:2a00:0:ffff:ffff:ffff:ffff:ffff',
    '2a0d:2a00:1::1-2a0d:2a00:1:ffff:ffff:ffff:ffff:ffff',
    '2a0d:2a00:2::1-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
)

# IP de servidores de DNS publico (tambien cifrado: DoH/DoT/DoQ) que se bloquean del todo.
$ResolversPublicos = @(
    '8.8.8.8','8.8.4.4','2001:4860:4860::8888','2001:4860:4860::8844','2001:4860:4860::64','2001:4860:4860::6464',
    '1.1.1.1','1.0.0.1','2606:4700:4700::1111','2606:4700:4700::1001',
    '1.1.1.2','1.0.0.2','2606:4700:4700::1112','2606:4700:4700::1002',
    '9.9.9.9','149.112.112.112','2620:fe::fe','2620:fe::9',
    '9.9.9.10','149.112.112.10','2620:fe::10','2620:fe::fe:10',
    '9.9.9.11','149.112.112.11','2620:fe::11','2620:fe::fe:11',
    '208.67.222.222','208.67.220.220','2620:119:35::35','2620:119:53::53',
    '94.140.14.14','94.140.15.15','2a10:50c0::ad1:ff','2a10:50c0::ad2:ff',
    '94.140.14.140','94.140.14.141','2a10:50c0::1:ff','2a10:50c0::2:ff',
    '45.90.28.0/24','45.90.30.0/24',
    '76.76.2.0/24','76.76.10.0/24','2606:1a40::/48','2606:1a40:1::/48',
    '194.242.2.0/24','2a07:e340::/32',
    '185.222.222.222','45.11.45.11','2a09::','2a11::',
    '185.43.135.1','193.17.47.1','2001:148f:fffe::1','2001:148f:ffff::1',
    '86.54.11.0/24','2a13:1001::/32'
)

# Nombres de DNS publico cifrado para el hosts (NUNCA los del filtro).
$NombresDohHosts = @(
    'dns.google','dns.google.com','8888.google',
    'cloudflare-dns.com','mozilla.cloudflare-dns.com','chrome.cloudflare-dns.com',
    'one.one.one.one','1dot1dot1dot1.cloudflare-dns.com','security.cloudflare-dns.com',
    'dns.quad9.net','dns9.quad9.net','dns10.quad9.net','dns11.quad9.net',
    'doh.opendns.com','dns.adguard-dns.com','unfiltered.adguard-dns.com',
    'dns.adguard.com','dns-unfiltered.adguard.com',
    'dns.nextdns.io','firefox.dns.nextdns.io','chromium.dns.nextdns.io',
    'freedns.controld.com','doh.dns.sb','dns.mullvad.net','odvr.nic.cz',
    'protective.joindns4.eu','noads.joindns4.eu','unfiltered.joindns4.eu'
)

# ======================================================================
#  UTILIDADES
# ======================================================================
$Script:RutaLog = $null
$Script:Fallos = New-Object System.Collections.Generic.List[string]

function Write-Log {
    param([string]$Mensaje, [string]$Nivel = 'INFO')
    $linea = ('{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Nivel, $Mensaje)
    switch ($Nivel) {
        'ERROR' { Write-Host $linea -ForegroundColor Red }
        'AVISO' { Write-Host $linea -ForegroundColor Yellow }
        'OK'    { Write-Host $linea -ForegroundColor Green }
        default { Write-Host $linea }
    }
    if ($Script:RutaLog) {
        try { Add-Content -LiteralPath $Script:RutaLog -Value $linea -Encoding UTF8 } catch { }
    }
}

function Invoke-Seccion {
    # Ejecuta una seccion; si falla, lo apunta y sigue con las demas.
    param([string]$Nombre, [scriptblock]$Bloque)
    try { & $Bloque }
    catch {
        $Script:Fallos.Add($Nombre)
        Write-Log ("  ERROR en '{0}': {1}" -f $Nombre, $_.Exception.Message) 'ERROR'
    }
}

function Test-Si {
    # Acepta SI, si, Si o "si" con tilde.
    param([string]$Texto)
    if ($null -eq $Texto) { return $false }
    return ($Texto.Trim() -match '^s[i\u00ed]$')
}

function Test-Administrador {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $pr = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $pr.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Set-CarpetaSoloAdmin {
    param([string]$Ruta)
    # Hereda nada; SYSTEM y Administradores control total; Usuarios solo lectura y ejecucion.
    $ErrorActionPreference = 'Continue'   # en PS 5.1, stderr redirigido con 'Stop' aborta
    & icacls.exe $Ruta /inheritance:r /grant:r ('*{0}:(OI)(CI)F' -f $SidSystem) `
        ('*{0}:(OI)(CI)F' -f $SidAdmins) ('*{0}:(OI)(CI)RX' -f $SidUsers) 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Log ("  No se pudieron ajustar los permisos de '{0}' (icacls devolvio {1})." -f $Ruta, $LASTEXITCODE) 'AVISO'
    }
}

function Leer-Reg {
    # Lee un valor del registro con su tipo, usando .NET (sin depender del proveedor).
    param([string]$Ruta, [string]$Nombre)
    $res = [pscustomobject]@{ Path = $Ruta; Name = $Nombre; Existed = $false; Value = $null; Kind = $null }
    $hive = $null; $sub = $null
    if ($Ruta -like 'HKLM:\*') { $hive = [Microsoft.Win32.Registry]::LocalMachine; $sub = $Ruta.Substring(6) }
    elseif ($Ruta -like 'HKCU:\*') { $hive = [Microsoft.Win32.Registry]::CurrentUser; $sub = $Ruta.Substring(6) }
    else { return $res }
    $k = $hive.OpenSubKey($sub, $false)
    if ($k) {
        if (($k.GetValueNames()) -contains $Nombre) {
            $res.Existed = $true
            $res.Value = $k.GetValue($Nombre, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
            $res.Kind = $k.GetValueKind($Nombre).ToString()
        }
        $k.Close()
    }
    return $res
}

function Set-Pol {
    param([string]$Ruta, [string]$Nombre, $Valor, [string]$Tipo)
    if (-not (Test-Path -LiteralPath $Ruta)) { New-Item -Path $Ruta -Force | Out-Null }
    New-ItemProperty -Path $Ruta -Name $Nombre -Value $Valor -PropertyType $Tipo -Force | Out-Null
}

function Get-SidMiembrosGrupo {
    # Devuelve los SID (texto) de los miembros de un grupo local, por ADSI (idioma-independiente).
    param([string]$SidGrupo)
    $nt = (New-Object System.Security.Principal.SecurityIdentifier($SidGrupo)).Translate([System.Security.Principal.NTAccount]).Value
    $nombre = $nt.Split('\')[-1]
    $grupo = [ADSI]("WinNT://./$nombre,group")
    $sids = @()
    foreach ($m in @($grupo.psbase.Invoke('Members'))) {
        try {
            $bytes = $m.GetType().InvokeMember('objectSid', 'GetProperty', $null, $m, $null)
            $sids += (New-Object System.Security.Principal.SecurityIdentifier($bytes, 0)).Value
        } catch { }
    }
    return $sids
}

function Get-NombreDeSid {
    param([string]$Sid)
    if (-not $Sid) { return '(desconocida)' }
    try { return (New-Object System.Security.Principal.SecurityIdentifier($Sid)).Translate([System.Security.Principal.NTAccount]).Value }
    catch { return $Sid }
}

function Get-SidSesionInteractiva {
    # SID de la persona que tiene abierta la sesion donde corre esta ventana
    # (dueno del explorer.exe de esta sesion). Sirve para distinguirla de la
    # cuenta con la que se ha elevado (por ejemplo GuardianBloqueo).
    try {
        $sesion = (Get-Process -Id $PID).SessionId
        $exp = @(Get-CimInstance -ClassName Win32_Process -Filter ("Name='explorer.exe' AND SessionId={0}" -f $sesion) -ErrorAction Stop)
        foreach ($p in $exp) {
            $r = Invoke-CimMethod -InputObject $p -MethodName GetOwnerSid -ErrorAction Stop
            if ($r -and $r.Sid) { return [string]$r.Sid }
        }
    } catch { }
    return $null
}

function Test-CredencialLocal {
    # Comprueba usuario + llave con un inicio de sesion real (LogonUser, interactivo).
    # No muestra ni guarda la llave. Si no se puede usar LogonUser, prueba ValidateCredentials.
    param([string]$Usuario, [string]$Clave)
    try {
        if (-not ('KitBloqueo.Logon' -as [type])) {
            Add-Type -Namespace KitBloqueo -Name Logon -MemberDefinition @'
[DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern bool LogonUser(string user, string domain, string password, int logonType, int logonProvider, out IntPtr token);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool CloseHandle(IntPtr handle);
'@
        }
        $tok = [IntPtr]::Zero
        $ok = [KitBloqueo.Logon]::LogonUser($Usuario, '.', $Clave, 2, 0, [ref]$tok)
        if ($ok -and $tok -ne [IntPtr]::Zero) { [void][KitBloqueo.Logon]::CloseHandle($tok) }
        return [bool]$ok
    } catch {
        Write-Log '  LogonUser no disponible; se usa ValidateCredentials.' 'AVISO'
    }
    try {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
        try { return [bool]$ctx.ValidateCredentials($Usuario, $Clave) } finally { $ctx.Dispose() }
    } catch {
        return $false
    }
}

# ======================================================================
#  GENERADOR DE LLAVE Y PORTAPAPELES SEGURO
# ======================================================================
function New-Llave {
    # Llave criptografica sin sesgo de modulo, sin caracteres ambiguos (I O l o 0 1),
    # con al menos una mayuscula, una minuscula y una cifra.
    param([ValidateRange(8, 64)][int]$Longitud = 24)
    $mayus = 'ABCDEFGHJKLMNPQRSTUVWXYZ'
    $minus = 'abcdefghijkmnpqrstuvwxyz'
    $cifras = '23456789'
    $alfabeto = $mayus + $minus + $cifras
    $n = $alfabeto.Length
    $limite = 256 - (256 % $n)
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $buf = New-Object byte[] 64
    try {
        while ($true) {
            $sb = New-Object System.Text.StringBuilder
            while ($sb.Length -lt $Longitud) {
                $rng.GetBytes($buf)
                foreach ($b in $buf) {
                    if ($sb.Length -ge $Longitud) { break }
                    if ($b -lt $limite) { [void]$sb.Append($alfabeto[$b % $n]) }
                }
            }
            $llave = $sb.ToString()
            if (($llave -cmatch '[A-Z]') -and ($llave -cmatch '[a-z]') -and ($llave -match '[2-9]')) {
                return $llave
            }
        }
    } finally { $rng.Dispose() }
}

function Format-Llave {
    # Separa la llave en bloques de 4 con guiones, para poder teclearla a mano.
    param([string]$Llave, [int]$Bloque = 4)
    $trozos = @()
    for ($i = 0; $i -lt $Llave.Length; $i += $Bloque) {
        $fin = [math]::Min($Bloque, $Llave.Length - $i)
        $trozos += $Llave.Substring($i, $fin)
    }
    return ($trozos -join '-')
}

$ClaveClip = 'HKCU:\Software\Microsoft\Clipboard'
$ValoresClip = @('EnableClipboardHistory', 'EnableCloudClipboard', 'CloudClipboardAutomaticUpload')

function Get-EstadoPortapapeles {
    $estado = @{}
    foreach ($nombre in $ValoresClip) {
        $r = Leer-Reg -Ruta $ClaveClip -Nombre $nombre
        if ($r.Existed) { $estado[$nombre] = [int]$r.Value } else { $estado[$nombre] = $null }
    }
    return $estado
}

function Disable-HistorialPortapapeles {
    if (-not (Test-Path -LiteralPath $ClaveClip)) { New-Item -Path $ClaveClip -Force | Out-Null }
    foreach ($nombre in $ValoresClip) {
        New-ItemProperty -Path $ClaveClip -Name $nombre -PropertyType DWord -Value 0 -Force | Out-Null
    }
}

function Restore-EstadoPortapapeles {
    param([hashtable]$Estado)
    if (-not $Estado) { return }
    if (-not (Test-Path -LiteralPath $ClaveClip)) { return }
    foreach ($nombre in $ValoresClip) {
        if ($null -eq $Estado[$nombre]) {
            Remove-ItemProperty -Path $ClaveClip -Name $nombre -ErrorAction SilentlyContinue
        } else {
            New-ItemProperty -Path $ClaveClip -Name $nombre -PropertyType DWord -Value ([int]$Estado[$nombre]) -Force | Out-Null
        }
    }
}

function Copy-LlaveSegura {
    # Copia al portapapeles marcando el dato para que NO entre en el historial (Win+V)
    # ni en la sincronizacion en la nube ni en gestores de portapapeles.
    # Devuelve $true solo si la llave quedo copiada (se comprueba sin mostrarla).
    param([Parameter(Mandatory = $true)][string]$Texto)
    $sta = ([System.Threading.Thread]::CurrentThread.GetApartmentState() -eq [System.Threading.ApartmentState]::STA)
    if (-not $sta) { return $false }
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $datos = New-Object System.Windows.Forms.DataObject
        $datos.SetData([System.Windows.Forms.DataFormats]::UnicodeText, $Texto)
        $cero = [System.BitConverter]::GetBytes([int]0)
        $datos.SetData('CanIncludeInClipboardHistory', (New-Object System.IO.MemoryStream (, $cero)))
        $datos.SetData('CanUploadToCloudClipboard', (New-Object System.IO.MemoryStream (, $cero)))
        $datos.SetData('ExcludeClipboardContentFromMonitorProcessing', (New-Object System.IO.MemoryStream (, $cero)))
        $datos.SetData('Clipboard Viewer Ignore', (New-Object System.IO.MemoryStream (, $cero)))
        # 10 reintentos cada 200 ms por si otro programa tiene el portapapeles ocupado.
        [System.Windows.Forms.Clipboard]::SetDataObject($datos, $true, 10, 200)
        $leido = [System.Windows.Forms.Clipboard]::GetText()
        $ok = ($leido -ceq $Texto)
        $leido = $null
        return $ok
    } catch {
        return $false
    }
}

function Clear-Portapapeles {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Clipboard]::Clear()
    } catch {
        try { Set-Clipboard -Value ' ' } catch { }
    }
}

# ======================================================================
#  RANGOS -> CIDR (plan B del cortafuegos si no acepta rangos 'a-b')
# ======================================================================
function ConvertTo-NumeroIp {
    param([string]$Ip)
    $bytes = ([System.Net.IPAddress]::Parse($Ip)).GetAddressBytes()
    $n = [System.Numerics.BigInteger]::Zero
    foreach ($b in $bytes) { $n = [System.Numerics.BigInteger]::Add([System.Numerics.BigInteger]::Multiply($n, 256), $b) }
    return $n
}

function ConvertFrom-NumeroIp {
    param([System.Numerics.BigInteger]$Numero, [int]$Bytes)
    $out = New-Object byte[] $Bytes
    $n = $Numero
    for ($i = $Bytes - 1; $i -ge 0; $i--) {
        $out[$i] = [byte][int]([System.Numerics.BigInteger]::Remainder($n, 256))
        $n = [System.Numerics.BigInteger]::Divide($n, 256)
    }
    return (New-Object System.Net.IPAddress (, $out)).ToString()
}

function ConvertTo-Cidr {
    # Convierte un rango 'a-b' (IPv4 o IPv6) en la lista minima de bloques CIDR.
    param([string]$Rango)
    $partes = $Rango.Split('-')
    $ini = ConvertTo-NumeroIp $partes[0]
    $fin = ConvertTo-NumeroIp $partes[1]
    $bits = 32; $nb = 4
    if ($partes[0].Contains(':')) { $bits = 128; $nb = 16 }
    $res = New-Object System.Collections.Generic.List[string]
    while ([System.Numerics.BigInteger]::Compare($ini, $fin) -le 0) {
        $k = 0
        while ($k -lt $bits) {
            $tam = [System.Numerics.BigInteger]::Pow(2, $k + 1)
            if (-not ([System.Numerics.BigInteger]::Remainder($ini, $tam)).IsZero) { break }
            if ([System.Numerics.BigInteger]::Compare([System.Numerics.BigInteger]::Subtract([System.Numerics.BigInteger]::Add($ini, $tam), 1), $fin) -gt 0) { break }
            $k++
        }
        $res.Add(('{0}/{1}' -f (ConvertFrom-NumeroIp -Numero $ini -Bytes $nb), ($bits - $k)))
        $ini = [System.Numerics.BigInteger]::Add($ini, [System.Numerics.BigInteger]::Pow(2, $k))
    }
    return $res.ToArray()
}

# ======================================================================
#  SECCIONES
# ======================================================================
function Invoke-Preparacion {
    foreach ($d in @($BaseDatos, $DirCopias, $DirLog, $CarpetaTarea)) {
        if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    }
    Set-CarpetaSoloAdmin -Ruta $BaseDatos
    Set-CarpetaSoloAdmin -Ruta $CarpetaTarea
    $Script:RutaLog = Join-Path $DirLog ('bloqueo-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType File -Path $Script:RutaLog -Force | Out-Null
    Write-Log 'Carpetas de datos y registro preparadas (solo administradores pueden modificarlas).' 'OK'
}

function Backup-Hosts {
    $dst = Join-Path $DirCopias 'hosts.original'
    if ((Test-Path -LiteralPath $Hosts) -and -not (Test-Path -LiteralPath $dst)) {
        Copy-Item -LiteralPath $Hosts -Destination $dst -Force
        Write-Log 'Copia de seguridad del fichero hosts original guardada.' 'OK'
    }
}

function Get-DnsEstatico {
    # DNS puesto A MANO en un adaptador (vacio = automatico por DHCP), leido del registro.
    param([string]$Guid)
    $res = [pscustomobject]@{ V4 = @(); V6 = @() }
    $hklm = [Microsoft.Win32.Registry]::LocalMachine
    $rutas = @{
        V4 = "SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$Guid"
        V6 = "SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\Interfaces\$Guid"
    }
    foreach ($fam in @('V4', 'V6')) {
        $k = $hklm.OpenSubKey($rutas[$fam], $false)
        if ($k) {
            $v = [string]$k.GetValue('NameServer', '')
            $k.Close()
            $res.$fam = @($v -split '[\s,]+' | Where-Object { $_ })
        }
    }
    return $res
}

function Backup-Dns {
    # Guarda, por adaptador (GUID), si el DNS era automatico (DHCP) o puesto a mano.
    # Si ya hay copia, solo anade los adaptadores nuevos.
    $dst = Join-Path $DirCopias 'dns-original.xml'
    $previo = @()
    if (Test-Path -LiteralPath $dst) {
        try { $previo = @(Import-Clixml -LiteralPath $dst) } catch { $previo = @() }
        if (@($previo | Where-Object { -not $_.PSObject.Properties['StaticV4'] }).Count -gt 0) {
            Rename-Item -LiteralPath $dst -NewName ('dns-original-formato-antiguo-{0}.xml' -f (Get-Date -Format 'yyyyMMddHHmmss'))
            $previo = @()
        }
    }
    $conocidos = @{}
    $datos = New-Object System.Collections.Generic.List[object]
    foreach ($e in $previo) { $datos.Add($e); $conocidos[[string]$e.Guid] = $true }
    $nuevos = 0
    foreach ($a in @(Get-NetAdapter -ErrorAction SilentlyContinue)) {
        $guid = [string]$a.InterfaceGuid
        if (-not $guid -or $conocidos.ContainsKey($guid)) { continue }
        $st = Get-DnsEstatico -Guid $guid
        $v4 = @($st.V4); $v6 = @($st.V6)
        # Si ya tiene puesto el DNS del kit (copia perdida), se considera automatico.
        if (($v4 -join ',') -eq ($DnsFiltradoV4 -join ',')) { $v4 = @() }
        if (($v6 -join ',') -eq ($DnsFiltradoV6 -join ',')) { $v6 = @() }
        $datos.Add([pscustomobject]@{ Guid = $guid; ifIndex = $a.ifIndex; Alias = $a.InterfaceAlias; StaticV4 = $v4; StaticV6 = $v6 })
        $nuevos++
    }
    if ($nuevos -gt 0) {
        $datos.ToArray() | Export-Clixml -LiteralPath $dst
        Write-Log ("Copia de seguridad de la configuracion DNS guardada ({0} adaptador(es) nuevos)." -f $nuevos) 'OK'
    }
}

function Backup-Directivas {
    # Guarda el estado previo de cada directiva que el kit va a tocar. Si ya hay
    # copia, solo anade las directivas que no estaban (versiones nuevas del kit).
    param([array]$Directivas)
    $dst = Join-Path $DirCopias 'directivas-original.xml'
    $prev = @()
    if (Test-Path -LiteralPath $dst) { try { $prev = @(Import-Clixml -LiteralPath $dst) } catch { $prev = @() } }
    $vistos = @{}
    $lista = New-Object System.Collections.Generic.List[object]
    foreach ($p in $prev) { $lista.Add($p); $vistos[($p.Path + '|' + $p.Name)] = $true }
    $nuevos = 0
    foreach ($d in $Directivas) {
        $clave = $d.Path + '|' + $d.Name
        if ($vistos.ContainsKey($clave)) { continue }
        $vistos[$clave] = $true
        $lista.Add((Leer-Reg -Ruta $d.Path -Nombre $d.Name))
        $nuevos++
    }
    if ($nuevos -gt 0) {
        $lista.ToArray() | Export-Clixml -LiteralPath $dst
        Write-Log ("Copia de seguridad del estado previo de {0} directiva(s) guardada." -f $nuevos) 'OK'
    }
}

function Invoke-Dns {
    Write-Log '(a) Aplicando DNS filtrado en los adaptadores de red...'
    $adaptadores = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -ne 'Disabled' })
    if ($adaptadores.Count -eq 0) { Write-Log 'No se encontraron adaptadores de red activos.' 'AVISO' }
    foreach ($a in $adaptadores) {
        try {
            Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $DnsFiltrado -ErrorAction Stop
            Write-Log ("  DNS (IPv4+IPv6) aplicado en '{0}'." -f $a.InterfaceAlias) 'OK'
        } catch {
            Write-Log ("  No se pudo aplicar IPv4+IPv6 en '{0}'; reintentando solo IPv4." -f $a.InterfaceAlias) 'AVISO'
            try {
                Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $DnsFiltradoV4 -ErrorAction Stop
                Write-Log ("  DNS (solo IPv4) aplicado en '{0}'. El IPv6 lo cubre el cortafuegos." -f $a.InterfaceAlias) 'OK'
            } catch {
                Write-Log ("  No se pudo aplicar DNS en '{0}': {1}" -f $a.InterfaceAlias, $_.Exception.Message) 'AVISO'
            }
        }
    }
    try { Clear-DnsClientCache } catch { }
}

function Invoke-TareaReaplicarDns {
    Write-Log '(a) Registrando la tarea que reaplica el DNS (arranque / inicio de sesion / red conectada)...'
    $scriptTarea = Join-Path $CarpetaTarea 'reaplicar-dns.ps1'
    $lineasV4 = ($DnsFiltradoV4 | ForEach-Object { "'" + $_ + "'" }) -join ','
    $lineasTodos = ($DnsFiltrado | ForEach-Object { "'" + $_ + "'" }) -join ','
    $contenido = @"
# Reaplica el DNS filtrado a todos los adaptadores. Lo ejecuta una tarea programada como SYSTEM.
# Parte del kit para bloquear contenido adulto. Se borra con deshacer-pc.ps1.
`$ErrorActionPreference = 'SilentlyContinue'
`$todos = @($lineasTodos)
`$v4 = @($lineasV4)
foreach (`$a in (Get-NetAdapter)) {
    try { Set-DnsClientServerAddress -InterfaceIndex `$a.ifIndex -ServerAddresses `$todos -ErrorAction Stop }
    catch { try { Set-DnsClientServerAddress -InterfaceIndex `$a.ifIndex -ServerAddresses `$v4 -ErrorAction Stop } catch { } }
}
Clear-DnsClientCache
"@
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($scriptTarea, $contenido, $utf8)
    Set-CarpetaSoloAdmin -Ruta $CarpetaTarea

    $accion = New-ScheduledTaskAction -Execute (Join-Path $env:windir 'System32\WindowsPowerShell\v1.0\powershell.exe') `
        -Argument ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $scriptTarea + '"')
    $t1 = New-ScheduledTaskTrigger -AtStartup
    $t2 = New-ScheduledTaskTrigger -AtLogOn
    $disparadores = @($t1, $t2)
    try {
        $claseEvento = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace 'Root/Microsoft/Windows/TaskScheduler' -ErrorAction Stop
        $t3 = New-CimInstance -CimClass $claseEvento -ClientOnly
        $t3.Subscription = '<QueryList><Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"><Select Path="Microsoft-Windows-NetworkProfile/Operational">*[System[(EventID=10000)]]</Select></Query></QueryList>'
        $t3.Enabled = $true
        $t3.Delay = 'PT15S'
        $disparadores += $t3
    } catch {
        Write-Log '  No se pudo crear el disparador por evento de red; se usan solo arranque e inicio de sesion.' 'AVISO'
    }
    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
    $ajustes = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 5) -MultipleInstances IgnoreNew
    Register-ScheduledTask -TaskName $NombreTarea -TaskPath $RutaTareaSch `
        -Action $accion -Trigger $disparadores -Principal $principal -Settings $ajustes -Force | Out-Null
    Write-Log '  Tarea programada registrada.' 'OK'
}

function Invoke-DohWindows11 {
    # OPCIONAL (-DohWindows11). Cifra las consultas al filtro: no cambia lo que se bloquea, pero
    # impide que un router que intercepta el puerto 53 (p. ej. "DNS Seguro") conteste en su lugar.
    if (-not (Get-Command Add-DnsClientDohServerAddress -ErrorAction SilentlyContinue)) {
        Write-Log '(a) DoH nativo no disponible (Windows 10 o anterior): se omite. El filtrado NO depende de esto.' 'AVISO'
        return
    }
    Write-Log '(a) Configurando DoH opcional (cifra las consultas al filtro)...'
    $plantillas = @{
        '185.228.168.168' = 'https://doh.cleanbrowsing.org/doh/family-filter/'
        '185.228.169.168' = 'https://doh.cleanbrowsing.org/doh/family-filter/'
        '2a0d:2a00:1::'   = 'https://doh.cleanbrowsing.org/doh/family-filter/'
        '2a0d:2a00:2::'   = 'https://doh.cleanbrowsing.org/doh/family-filter/'
        '1.1.1.3'         = 'https://family.cloudflare-dns.com/dns-query'
        '1.0.0.3'         = 'https://family.cloudflare-dns.com/dns-query'
        '2606:4700:4700::1113' = 'https://family.cloudflare-dns.com/dns-query'
        '2606:4700:4700::1003' = 'https://family.cloudflare-dns.com/dns-query'
    }
    foreach ($ip in $plantillas.Keys) {
        $tpl = $plantillas[$ip]
        try {
            $existe = Get-DnsClientDohServerAddress -ServerAddress $ip -ErrorAction SilentlyContinue
            if ($existe) {
                Set-DnsClientDohServerAddress -ServerAddress $ip -DohTemplate $tpl -AllowFallbackToUdp $true -AutoUpgrade $true -ErrorAction Stop | Out-Null
            } else {
                Add-DnsClientDohServerAddress -ServerAddress $ip -DohTemplate $tpl -AllowFallbackToUdp $true -AutoUpgrade $true -ErrorAction Stop | Out-Null
            }
        } catch {
            Write-Log ("  No se pudo registrar DoH para {0}: {1}" -f $ip, $_.Exception.Message) 'AVISO'
        }
    }
    # Marca DohFlags por interfaz (si no, Configuracion puede mostrar "sin cifrar"). Best-effort.
    # Se usa la API .NET del registro porque las claves IPv6 contienen ":" que confunde al proveedor.
    try {
        $hklm = [Microsoft.Win32.Registry]::LocalMachine
        foreach ($a in @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -ne 'Disabled' })) {
            $guid = $a.InterfaceGuid
            $baseInt = "SYSTEM\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\$guid\DohInterfaceSettings"
            foreach ($ip in $DnsFiltradoV4) {
                $k = $hklm.CreateSubKey("$baseInt\Doh\$ip")
                if ($k) { $k.SetValue('DohFlags', [int64]1, [Microsoft.Win32.RegistryValueKind]::QWord); $k.Close() }
            }
            foreach ($ip in $DnsFiltradoV6) {
                $k = $hklm.CreateSubKey("$baseInt\Doh6\$ip")
                if ($k) { $k.SetValue('DohFlags', [int64]1, [Microsoft.Win32.RegistryValueKind]::QWord); $k.Close() }
            }
        }
    } catch {
        Write-Log ("  No se pudo escribir DohFlags por interfaz: {0}" -f $_.Exception.Message) 'AVISO'
    }
    # Autoprueba: si con DoH no se resuelve nada, se quita el DoH (nunca dejar el PC sin internet).
    $resuelve = $false
    for ($i = 0; $i -lt 3 -and -not $resuelve; $i++) {
        try { Clear-DnsClientCache } catch { }
        Start-Sleep -Seconds 3
        try { if (Resolve-DnsName -Name 'example.com' -Type A -DnsOnly -QuickTimeout -ErrorAction Stop) { $resuelve = $true } } catch { }
    }
    if ($resuelve) {
        Write-Log '  DoH activado y funcionando. Compruebalo en Configuracion o con: netsh dns show encryption' 'OK'
    } else {
        Undo-DohWindows11
        Write-Log '  Con DoH no se resolvia ningun nombre (o no hay conexion): se ha quitado el DoH. El filtrado sigue igual.' 'AVISO'
    }
}

function Undo-DohWindows11 {
    foreach ($ip in $DnsFiltrado) {
        try { Remove-DnsClientDohServerAddress -ServerAddress $ip -ErrorAction SilentlyContinue } catch { }
    }
    try {
        $hklm = [Microsoft.Win32.Registry]::LocalMachine
        $base = 'SYSTEM\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters'
        $kb = $hklm.OpenSubKey($base, $false)
        if ($kb) {
            $interfaces = $kb.GetSubKeyNames()
            $kb.Close()
            foreach ($g in $interfaces) {
                foreach ($ip in $DnsFiltradoV4) { try { $hklm.DeleteSubKeyTree(("{0}\{1}\DohInterfaceSettings\Doh\{2}" -f $base, $g, $ip), $false) } catch { } }
                foreach ($ip in $DnsFiltradoV6) { try { $hklm.DeleteSubKeyTree(("{0}\{1}\DohInterfaceSettings\Doh6\{2}" -f $base, $g, $ip), $false) } catch { } }
            }
        }
    } catch { }
    try { Clear-DnsClientCache } catch { }
}

function Get-Directivas {
    $extJson = '{"*":{"blocked_permissions":["proxy"]}}'
    $proxyJson = '{"ProxyMode":"direct"}'
    $d = @()
    $chromium = @(
        'HKLM:\SOFTWARE\Policies\Google\Chrome',
        'HKLM:\SOFTWARE\Policies\Chromium',
        'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave',
        'HKLM:\SOFTWARE\Policies\Vivaldi'
    )
    foreach ($r in $chromium) {
        $d += [pscustomobject]@{ Path = $r; Name = 'IncognitoModeAvailability'; Value = 1; Type = 'DWord' }
        $d += [pscustomobject]@{ Path = $r; Name = 'DnsOverHttpsMode'; Value = 'off'; Type = 'String' }
        $d += [pscustomobject]@{ Path = $r; Name = 'ForceGoogleSafeSearch'; Value = 1; Type = 'DWord' }
        $d += [pscustomobject]@{ Path = $r; Name = 'ForceYouTubeRestrict'; Value = 2; Type = 'DWord' }
        $d += [pscustomobject]@{ Path = $r; Name = 'BrowserGuestModeEnabled'; Value = 0; Type = 'DWord' }
        $d += [pscustomobject]@{ Path = $r; Name = 'BrowserAddPersonEnabled'; Value = 0; Type = 'DWord' }
        $d += [pscustomobject]@{ Path = $r; Name = 'ExtensionSettings'; Value = $extJson; Type = 'String' }
        $d += [pscustomobject]@{ Path = $r; Name = 'ExtensionDeveloperModeSettings'; Value = 1; Type = 'DWord' }
        $d += [pscustomobject]@{ Path = $r; Name = 'ProxySettings'; Value = $proxyJson; Type = 'String' }
    }
    $brave = 'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave'
    $d += [pscustomobject]@{ Path = $brave; Name = 'TorDisabled'; Value = 1; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = $brave; Name = 'BraveVPNDisabled'; Value = 1; Type = 'DWord' }
    $edge = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
    $d += [pscustomobject]@{ Path = $edge; Name = 'InPrivateModeAvailability'; Value = 1; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = $edge; Name = 'DnsOverHttpsMode'; Value = 'off'; Type = 'String' }
    $d += [pscustomobject]@{ Path = $edge; Name = 'ForceBingSafeSearch'; Value = 2; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = $edge; Name = 'ForceGoogleSafeSearch'; Value = 1; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = $edge; Name = 'ForceYouTubeRestrict'; Value = 2; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = $edge; Name = 'BrowserGuestModeEnabled'; Value = 0; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = $edge; Name = 'BrowserAddProfileEnabled'; Value = 0; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = $edge; Name = 'ExtensionSettings'; Value = $extJson; Type = 'String' }
    $d += [pscustomobject]@{ Path = $edge; Name = 'ExtensionDeveloperModeSettings'; Value = 1; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = $edge; Name = 'ProxySettings'; Value = $proxyJson; Type = 'String' }
    $ff = 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox'
    $d += [pscustomobject]@{ Path = "$ff\DNSOverHTTPS"; Name = 'Enabled'; Value = 0; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = "$ff\DNSOverHTTPS"; Name = 'Locked'; Value = 1; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = $ff; Name = 'DisablePrivateBrowsing'; Value = 1; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = $ff; Name = 'PrivateBrowsingModeAvailability'; Value = 1; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = "$ff\Proxy"; Name = 'Mode'; Value = 'none'; Type = 'String' }
    $d += [pscustomobject]@{ Path = "$ff\Proxy"; Name = 'Locked'; Value = 1; Type = 'DWord' }
    $d += [pscustomobject]@{ Path = $ff; Name = 'BlockAboutConfig'; Value = 1; Type = 'DWord' }
    # VPN integrada de Firefox (IP Protection, Firefox 149.0.2+): 0 = no disponible.
    $d += [pscustomobject]@{ Path = $ff; Name = 'IPProtectionAvailable'; Value = 0; Type = 'DWord' }
    return $d
}

function Invoke-Directivas {
    param([array]$Directivas)
    Write-Log '(b) Aplicando directivas de navegador (registro HKLM)...'
    $fallos = 0
    foreach ($d in $Directivas) {
        try { Set-Pol -Ruta $d.Path -Nombre $d.Name -Valor $d.Value -Tipo $d.Type }
        catch { $fallos++; Write-Log ("  No se pudo aplicar {0}\{1}: {2}" -f $d.Path, $d.Name, $_.Exception.Message) 'AVISO' }
    }
    if ($fallos -gt 0) { $Script:Fallos.Add('(b) Directivas') }
    Write-Log '  Directivas aplicadas. Comprueba chrome://policy, edge://policy, brave://policy y about:policies.' 'OK'
}

function Invoke-Hosts {
    Write-Log '(c) Actualizando el fichero hosts...'
    if (-not (Test-Path -LiteralPath $Hosts)) { Set-Content -LiteralPath $Hosts -Value '' -Encoding ASCII }
    # Si alguien lo marco como "solo lectura", se quita esa marca para poder escribir.
    $item = Get-Item -LiteralPath $Hosts -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReadOnly) {
        $item.Attributes = $item.Attributes -bxor [System.IO.FileAttributes]::ReadOnly
    }

    # Quitar un bloque anterior del kit (idempotencia).
    $lineas = Get-Content -LiteralPath $Hosts -Encoding UTF8
    $salida = New-Object System.Collections.Generic.List[string]
    $dentro = $false
    foreach ($l in $lineas) {
        if ($l -eq $MarcaIni) { $dentro = $true; continue }
        if ($l -eq $MarcaFin) { $dentro = $false; continue }
        if (-not $dentro) { $salida.Add($l) }
    }
    # Quitar lineas en blanco finales sobrantes.
    while ($salida.Count -gt 0 -and [string]::IsNullOrWhiteSpace($salida[$salida.Count - 1])) {
        $salida.RemoveAt($salida.Count - 1)
    }

    $bloque = New-Object System.Collections.Generic.List[string]
    $bloque.Add($MarcaIni)
    $bloque.Add('# Nombres de DNS publico cifrado (DoH/DoT) para que no se usen como puerta trasera.')
    foreach ($n in $NombresDohHosts) {
        $bloque.Add('0.0.0.0 ' + $n)
        $bloque.Add(':: ' + $n)
    }
    if (Test-Path -LiteralPath $ListaHostsOrigen) {
        $bloque.Add('# Lista de dominios adultos (StevenBlack porn-only, saneada y comprimida).')
        $descartadas = 0
        foreach ($l in (Get-Content -LiteralPath $ListaHostsOrigen -Encoding UTF8)) {
            $t = $l.Trim()
            if ($t -eq '') { continue }
            # Saneado al aplicar: solo lineas "0.0.0.0 dominio ..." (bloquean, nunca redirigen).
            if ($t -match $PatronLineaLista) { $bloque.Add($t) } else { $descartadas++ }
        }
        if ($descartadas -gt 0) {
            Write-Log ("  Se ignoraron {0} lineas de la lista que no eran de bloqueo (0.0.0.0)." -f $descartadas) 'AVISO'
        }
    } else {
        $Script:Fallos.Add('(c) Lista de dominios no encontrada')
        Write-Log ("  No se encontro '{0}'. Solo se bloquean los nombres de DNS cifrado." -f $ListaHostsOrigen) 'AVISO'
    }
    $bloque.Add($MarcaFin)

    $salida.Add('')
    foreach ($b in $bloque) { $salida.Add($b) }

    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($Hosts, $salida.ToArray(), $utf8)
    try { Clear-DnsClientCache } catch { }
    try { & ipconfig.exe /flushdns | Out-Null } catch { }
    Write-Log ("  hosts actualizado con {0} lineas de bloqueo." -f $bloque.Count) 'OK'
}

function New-ReglaFw {
    param([string]$Nombre, [string]$Proto, [string[]]$Direcciones, [string[]]$Puertos)
    $p = @{
        DisplayName = $Nombre; Group = $GrupoFw; Direction = 'Outbound'; Action = 'Block'
        Protocol = $Proto; RemoteAddress = $Direcciones; Profile = 'Any'; Enabled = 'True'; ErrorAction = 'Stop'
    }
    if ($Puertos) { $p['RemotePort'] = $Puertos }
    New-NetFirewallRule @p | Out-Null
}

function Invoke-Firewall {
    Write-Log '(d) Comprobando cortafuegos de terceros...'
    try {
        $fp = Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName FirewallProduct -ErrorAction SilentlyContinue
        $ajenos = $fp | Where-Object { $_.displayName -and ($_.displayName -notmatch 'Windows') }
        if ($ajenos) {
            foreach ($x in $ajenos) {
                Write-Log ("  AVISO: hay otro cortafuegos instalado ('{0}'). Si esta activo, las reglas de Windows podrian NO aplicarse. Revisalo." -f $x.displayName) 'AVISO'
            }
        }
    } catch { Write-Log '  No se pudo consultar SecurityCenter2 (puede ser normal).' 'AVISO' }

    Write-Log '(d) Aplicando reglas del cortafuegos...'
    Get-NetFirewallRule -Group $GrupoFw -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
    $fallos = 0
    foreach ($proto in @('TCP', 'UDP')) {
        try {
            New-ReglaFw -Nombre ('Kit bloqueo - DNS no filtrado ' + $proto) -Proto $proto -Direcciones $RangosNoFiltro -Puertos @('53', '853')
        } catch {
            Write-Log ("  La regla de DNS ({0}) con rangos fue rechazada ({1}). Probando el plan B con bloques CIDR..." -f $proto, $_.Exception.Message) 'AVISO'
            try {
                try { Add-Type -AssemblyName System.Numerics } catch { }
                $c4 = @(); $c6 = @()
                foreach ($r in $RangosNoFiltro) {
                    if ($r.Contains(':')) { $c6 += ConvertTo-Cidr $r } else { $c4 += ConvertTo-Cidr $r }
                }
                New-ReglaFw -Nombre ('Kit bloqueo - DNS no filtrado IPv4 ' + $proto) -Proto $proto -Direcciones $c4 -Puertos @('53', '853')
                New-ReglaFw -Nombre ('Kit bloqueo - DNS no filtrado IPv6 ' + $proto) -Proto $proto -Direcciones $c6 -Puertos @('53', '853')
                Write-Log ("  Plan B aplicado ({0}): {1} bloques IPv4 y {2} IPv6." -f $proto, $c4.Count, $c6.Count) 'OK'
            } catch {
                $fallos++
                Write-Log ("  No se pudo crear la regla de DNS ({0}): {1}" -f $proto, $_.Exception.Message) 'ERROR'
            }
        }
    }
    try {
        New-ReglaFw -Nombre 'Kit bloqueo - resolvers DNS publicos' -Proto 'Any' -Direcciones $ResolversPublicos
    } catch {
        $fallos++
        Write-Log ("  No se pudo crear la regla de resolvers publicos: {0}" -f $_.Exception.Message) 'ERROR'
    }
    try { Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled True } catch { Write-Log ("  No se pudo activar el perfil del cortafuegos: {0}" -f $_.Exception.Message) 'AVISO' }
    if ($fallos -eq 0) {
        Write-Log '  Reglas del cortafuegos aplicadas (grupo KitBloqueoAdultos).' 'OK'
    } else {
        $Script:Fallos.Add('(d) Cortafuegos')
        Write-Log '  Alguna regla del cortafuegos no se aplico. El DNS fijo y el hosts SIGUEN filtrando; revisa GUIA.md.' 'AVISO'
    }
}

function Invoke-IfeoExtra {
    Write-Log '(e) Aplicando friccion extra IFEO para apps portables (se evita renombrando el .exe)...'
    $ifeoBase = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
    $depurador = ('"{0}" /c exit' -f (Join-Path $env:windir 'System32\cmd.exe'))
    foreach ($exe in @('tor.exe', 'opera.exe', 'opera_gx.exe', 'psiphon3.exe')) {
        $r = Join-Path $ifeoBase $exe
        if (-not (Test-Path -LiteralPath $r)) { New-Item -Path $r -Force | Out-Null }
        New-ItemProperty -Path $r -Name 'Debugger' -Value $depurador -PropertyType String -Force | Out-Null
    }
    Write-Log '  IFEO aplicado (tor.exe, opera.exe, opera_gx.exe, psiphon3.exe). Tu antivirus podria avisar: es esperable.' 'OK'
}

function Invoke-Cuentas {
    Write-Log '(f) Paso de CUENTAS.'
    Write-Host ''
    Write-Host '==================================================================' -ForegroundColor Cyan
    Write-Host ' PASO FINAL: llave del administrador GuardianBloqueo y cuenta' -ForegroundColor Cyan
    Write-Host ' estandar. Despues ya no podras cambiar DNS, cortafuegos, hosts' -ForegroundColor Cyan
    Write-Host ' ni directivas sin la LLAVE que vas a guardar en tu capsula.' -ForegroundColor Cyan
    Write-Host '==================================================================' -ForegroundColor Cyan
    Write-Host ''

    $yoSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $guardian = Get-LocalUser -Name $NombreAdmin -ErrorAction SilentlyContinue
    $guardianSid = $null
    if ($guardian) { $guardianSid = $guardian.SID.Value }
    $sidSesion = Get-SidSesionInteractiva
    $copiaCuenta = Join-Path $DirCopias 'cuenta-original.xml'

    # Cuenta que debe quedar ESTANDAR: la de la persona que tiene la sesion abierta,
    # aunque la ventana se haya elevado con otra cuenta (por ejemplo GuardianBloqueo).
    $objetivo = $null
    if ($sidSesion -and $sidSesion -ne $guardianSid) { $objetivo = $sidSesion }
    elseif ($yoSid -ne $guardianSid) { $objetivo = $yoSid }
    elseif (Test-Path -LiteralPath $copiaCuenta) {
        try { $objetivo = [string](Import-Clixml -LiteralPath $copiaCuenta).UsuarioSid } catch { $objetivo = $null }
    }
    if ($objetivo -and $objetivo -eq $guardianSid) { $objetivo = $null }
    if ($objetivo -and $objetivo -like '*-500') {
        Write-Log '  Estas usando el Administrador integrado de Windows. Usa tu cuenta normal: NO se toca ninguna cuenta.' 'ERROR'
        return
    }

    $admins = Get-SidMiembrosGrupo -SidGrupo $SidAdmins
    $objetivoEsAdmin = $false
    if ($objetivo) { $objetivoEsAdmin = ($admins -contains $objetivo) }
    $nombreObjetivo = Get-NombreDeSid $objetivo

    Write-Host ("Esta ventana se ejecuta como: {0}" -f (Get-NombreDeSid $yoSid)) -ForegroundColor White
    if ($objetivo) { Write-Host ("Tu cuenta (la que debe quedar ESTANDAR): {0}" -f $nombreObjetivo) -ForegroundColor White }
    if ($objetivo -and $objetivo -ne $yoSid -and $yoSid -ne $guardianSid) {
        Write-Host 'OJO: la ventana se ha elevado con OTRA cuenta de administrador distinta de la tuya.' -ForegroundColor Yellow
        Write-Host 'Si alguien sabe la contrasena de esa cuenta, es una puerta trasera: abajo podras pasarla a estandar.' -ForegroundColor Yellow
    }
    Write-Host ''

    $renovar = (-not $objetivoEsAdmin) -and ($null -ne $guardian)
    if ($objetivoEsAdmin) {
        $conf = Read-Host ("Escribe SI para crear la llave de '{0}' y pasar '{1}' a ESTANDAR (otra cosa = no tocar cuentas)" -f $NombreAdmin, $nombreObjetivo)
    } elseif ($renovar) {
        Write-Host 'Tu cuenta ya es estandar (o no se ha podido identificar) y GuardianBloqueo ya existe.' -ForegroundColor White
        $conf = Read-Host ("Escribe SI para RENOVAR: poner una LLAVE NUEVA a '{0}' (otra cosa = no tocar cuentas)" -f $NombreAdmin)
    } else {
        $conf = Read-Host ("Escribe SI para crear el administrador '{0}' con una llave (otra cosa = no tocar cuentas)" -f $NombreAdmin)
    }
    if (-not (Test-Si $conf)) { Write-Log '  Cancelado: NO se toca ninguna cuenta.' 'AVISO'; return }

    # Administrador integrado (-500)
    $integrado = Get-LocalUser -ErrorAction SilentlyContinue | Where-Object { $_.SID.Value -like '*-500' }
    if ($integrado -and $integrado.Enabled) {
        Write-Log ("  AVISO: el Administrador integrado '{0}' esta HABILITADO; es una posible puerta trasera. Deshabilitalo con: Disable-LocalUser -Name '{0}'" -f $integrado.Name) 'AVISO'
    }

    # Otros administradores (se deciden ahora, se cambian DESPUES de verificar GuardianBloqueo)
    $otros = @()
    foreach ($s in $admins) {
        if ($s -eq $objetivo -or $s -eq $guardianSid -or $s -like '*-500') { continue }
        $otros += $s
    }
    $bajarOtros = $false
    if ($otros.Count -gt 0) {
        Write-Host ''
        Write-Host 'Hay OTROS administradores en este equipo:' -ForegroundColor Yellow
        foreach ($s in $otros) { Write-Host ("  - {0}" -f (Get-NombreDeSid $s)) }
        Write-Host 'Si alguien conoce su contrasena, es una via para saltarse el bloqueo.' -ForegroundColor Yellow
        $bajarOtros = Test-Si (Read-Host 'Quieres pasarlos TAMBIEN a estandar al final? (SI / no)')
    }

    # ----- Llave: se genera, se copia sin mostrarla y se guarda en la capsula -----
    $estadoClip = $null
    $llave = $null
    $seguro = $null
    $downgradeHecho = $false
    try {
        try {
            $estadoClip = Get-EstadoPortapapeles
            Disable-HistorialPortapapeles
        } catch {
            Write-Log '  No se pudo desactivar el historial del portapapeles desde el registro: compruebalo tu en Configuracion.' 'AVISO'
        }
        Write-Host ''
        Write-Host 'Antes de seguir, abre Configuracion > Sistema > Portapapeles y comprueba que' -ForegroundColor White
        Write-Host '"Historial del portapapeles" y "Compartir entre dispositivos" estan DESACTIVADOS.' -ForegroundColor White
        if ($sidSesion -and $yoSid -eq $sidSesion) { try { Start-Process 'ms-settings:clipboard' } catch { } }
        [void](Read-Host 'Cuando lo hayas comprobado, pulsa Intro')

        $llave = Format-Llave -Llave (New-Llave -Longitud 24)   # bloques con guiones: se teclea a mano al iniciar sesion
        if (-not (Copy-LlaveSegura -Texto $llave)) {
            Write-Log '  No se pudo copiar la llave al portapapeles de forma segura. NO se cambia ninguna cuenta.' 'ERROR'
            return
        }

        Write-Host ''
        Write-Host 'La LLAVE ya esta en el portapapeles (no se muestra en pantalla).' -ForegroundColor Green
        Write-Host 'Pegala AHORA (Ctrl+V) en tu capsula del tiempo, como explica la guia de llaves/' -ForegroundColor Green
        Write-Host '(apartado "Si la llave la crea otro programa del kit"). Guarda el texto cifrado en dos sitios.' -ForegroundColor Green
        Write-Host 'No cierres esta ventana con la X mientras tanto.' -ForegroundColor Yellow
        Write-Host ''
        Write-Host '  PEGADA   = ya la he guardado en la capsula (sigue)' -ForegroundColor White
        Write-Host '  COPIAR   = vuelve a copiar la llave al portapapeles' -ForegroundColor White
        Write-Host '  CANCELAR = no cambies nada (sigues como estabas)' -ForegroundColor White
        while ($true) {
            $peg = Read-Host 'Escribe PEGADA, COPIAR o CANCELAR'
            if ($null -eq $peg) { $peg = '' }
            $peg = $peg.Trim()
            if ($peg -eq 'PEGADA') { break }
            if ($peg -eq 'CANCELAR') { Write-Log '  Cancelado antes de cambiar ninguna cuenta.' 'AVISO'; return }
            if ($peg -eq 'COPIAR') {
                if (Copy-LlaveSegura -Texto $llave) { Write-Host 'Llave copiada otra vez.' -ForegroundColor Green }
                else { Write-Host 'No se pudo copiar. Cierra otros programas y escribe COPIAR otra vez.' -ForegroundColor Yellow }
            }
        }

        # Crear o renovar el administrador con esa llave (despues de guardarla en la capsula)
        $seguro = ConvertTo-SecureString -String $llave -AsPlainText -Force
        if ($guardian) {
            Set-LocalUser -Name $NombreAdmin -Password $seguro -PasswordNeverExpires $true
            Write-Log "  Contrasena de '$NombreAdmin' cambiada por la llave nueva." 'OK'
        } else {
            New-LocalUser -Name $NombreAdmin -Password $seguro -PasswordNeverExpires -AccountNeverExpires `
                -FullName 'Guardian del bloqueo' -Description 'Administrador con llave (kit de bloqueo)' | Out-Null
            Write-Log "  Administrador '$NombreAdmin' creado." 'OK'
        }
        Enable-LocalUser -Name $NombreAdmin -ErrorAction SilentlyContinue
        try { Add-LocalGroupMember -SID $SidAdmins -Member $NombreAdmin -ErrorAction Stop } catch { }

        # Verificar el administrador: habilitado, en Administradores y la llave abre
        $u = Get-LocalUser -Name $NombreAdmin
        $guardianSid = $u.SID.Value
        $okPwd = Test-CredencialLocal -Usuario $NombreAdmin -Clave $llave
        $esAdmin = (Get-SidMiembrosGrupo -SidGrupo $SidAdmins) -contains $guardianSid
        Write-Log ("  Verificacion: Habilitado={0} EnGrupoAdmins={1} LlaveValida={2}" -f $u.Enabled, $esAdmin, $okPwd)
        if (-not ($u.Enabled -and $esAdmin -and $okPwd)) {
            Write-Log "  El administrador '$NombreAdmin' NO se pudo verificar. NO se cambia tu cuenta. Revisa el registro." 'ERROR'
            if ($renovar) {
                Write-Log '  Como era una renovacion, prueba a elevar con GuardianBloqueo y la llave NUEVA cuando se abra la capsula; si no abre, usa la vieja.' 'AVISO'
            }
            return
        }

        # Copia de la cuenta original (solo la primera vez; sirve para deshacer)
        $escribirCopia = -not (Test-Path -LiteralPath $copiaCuenta)
        if (-not $escribirCopia) {
            try { if ([string](Import-Clixml -LiteralPath $copiaCuenta).UsuarioSid -eq $guardianSid) { $escribirCopia = $true } } catch { $escribirCopia = $true }
        }
        if ($objetivo -and $escribirCopia) {
            [pscustomobject]@{ UsuarioSid = $objetivo; UsuarioNombre = $nombreObjetivo; GuardianNombre = $NombreAdmin } |
                Export-Clixml -LiteralPath $copiaCuenta
        }

        # Pasar tu cuenta a estandar
        if ($objetivoEsAdmin) {
            $miembro = $null
            try { $miembro = Get-LocalUser -SID $objetivo -ErrorAction Stop } catch { $miembro = $objetivo }
            # Asegurar que tu cuenta esta en Usuarios (si no, no podrias iniciar sesion)
            try { Add-LocalGroupMember -SID $SidUsers -Member $miembro -ErrorAction Stop } catch { }
            if (-not ((Get-SidMiembrosGrupo -SidGrupo $SidUsers) -contains $objetivo)) {
                Write-Log '  No se pudo confirmar que tu cuenta este en el grupo Usuarios: NO se te quita el admin (evita dejarte sin acceso).' 'ERROR'
                return
            }
            try {
                Remove-LocalGroupMember -SID $SidAdmins -Member $miembro -ErrorAction Stop
            } catch {
                Write-Log ("  No se pudo quitar el admin a tu cuenta: {0}" -f $_.Exception.Message) 'ERROR'
                return
            }
            if ((Get-SidMiembrosGrupo -SidGrupo $SidAdmins) -contains $objetivo) {
                Write-Log '  Tu cuenta sigue apareciendo como administrador. Revisa el registro.' 'ERROR'
            } else {
                $downgradeHecho = $true
                Write-Log '  Tu cuenta ya es ESTANDAR. El cambio sera completo al cerrar sesion o reiniciar.' 'OK'
            }
        } elseif ($renovar) {
            Write-Log '  Llave de GuardianBloqueo renovada. Tu cuenta sigue siendo estandar.' 'OK'
        } else {
            Write-Log '  GuardianBloqueo listo. Tu cuenta ya era estandar: no se cambia.' 'OK'
        }

        # Otros administradores (GuardianBloqueo ya esta verificado, asi que nunca quedan 0)
        if ($bajarOtros) {
            foreach ($s in $otros) {
                $m = $null
                try { $m = Get-LocalUser -SID $s -ErrorAction Stop } catch { $m = $s }
                try { Remove-LocalGroupMember -SID $SidAdmins -Member $m -ErrorAction Stop; Write-Log ("  '{0}' pasado a estandar." -f (Get-NombreDeSid $s)) 'OK' }
                catch { Write-Log ("  No se pudo cambiar '{0}': {1}" -f (Get-NombreDeSid $s), $_.Exception.Message) 'AVISO' }
            }
        }
    }
    finally {
        Clear-Portapapeles
        try { Restore-EstadoPortapapeles -Estado $estadoClip } catch { }
        $llave = $null
        $seguro = $null
        [System.GC]::Collect()
    }

    if ($downgradeHecho) {
        Write-Host ''
        Write-Host 'IMPORTANTE: cierra sesion o reinicia para que el cambio surta efecto.' -ForegroundColor Green
    }
}

function Invoke-ActualizarLista {
    Write-Log 'Descargando la lista de dominios de StevenBlack (solo bloquea, nunca redirige)...'
    $url = 'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts'
    $tmp = Join-Path $env:TEMP ('sb-porn-{0}.txt' -f (Get-Date -Format 'yyyyMMddHHmmss'))
    try {
        # Windows PowerShell 5.1 puede no usar TLS 1.2 por defecto.
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Log ("  No se pudo descargar la lista: {0}. Se mantiene la lista incluida en el kit." -f $_.Exception.Message) 'AVISO'
        return
    }
    $protegidos = @('microsoft.com', 'windowsupdate.com', 'google.com', 'bing.com', 'cleanbrowsing.org', 'cloudflare-dns.com')
    $doms = New-Object System.Collections.Generic.HashSet[string]
    foreach ($l in (Get-Content -LiteralPath $tmp)) {
        $t = $l.Trim()
        if ($t -eq '' -or $t.StartsWith('#')) { continue }
        $p = $t -split '\s+'
        if ($p.Count -lt 2 -or $p[0] -ne '0.0.0.0') { continue }
        $d = $p[1].Trim().ToLower()
        if ($d -match '#') { $d = ($d -split '#')[0].Trim() }
        if ($d -eq '' -or ($d -notmatch '^[a-z0-9.-]+$')) { continue }
        if ($d -eq '0.0.0.0' -or $d -eq 'localhost') { continue }
        $salta = $false
        foreach ($pr in $protegidos) { if ($d -eq $pr -or $d.EndsWith('.' + $pr)) { $salta = $true; break } }
        if (-not $salta) { [void]$doms.Add($d) }
    }
    Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
    if ($doms.Count -lt 10000) {
        Write-Log ("  La lista descargada parece incompleta ({0} dominios). Se mantiene la del kit." -f $doms.Count) 'AVISO'
        return
    }
    $ordenados = @(@($doms) | Sort-Object)
    $lineas = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $ordenados.Count; $i += 9) {
        $fin = [math]::Min(9, $ordenados.Count - $i)
        $lineas.Add('0.0.0.0 ' + (($ordenados[$i..($i + $fin - 1)]) -join ' '))
    }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($ListaHostsOrigen, $lineas.ToArray(), $utf8)
    Write-Log ("  Lista regenerada: {0} dominios, {1} lineas." -f $ordenados.Count, $lineas.Count) 'OK'
}

# ======================================================================
#  FLUJO PRINCIPAL
# ======================================================================
function Get-ArgumentosRelanzar {
    $argu = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-Sta', '-NoExit', '-File', ('"' + $PSCommandPath + '"'))
    if ($SinCuentas) { $argu += '-SinCuentas' }
    if ($IfeoExtra) { $argu += '-IfeoExtra' }
    if ($ActualizarLista) { $argu += '-ActualizarLista' }
    if ($DohWindows11) { $argu += '-DohWindows11' }
    $argu += '-Elevado'
    return $argu
}

# Relanzar en 64 bits si hace falta (LocalAccounts no existe en PS de 32 bits).
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $native = Join-Path $env:windir 'sysnative\WindowsPowerShell\v1.0\powershell.exe'
    if (Test-Path -LiteralPath $native) {
        Write-Host 'Relanzando en PowerShell de 64 bits...' -ForegroundColor Yellow
        Start-Process -FilePath $native -ArgumentList (Get-ArgumentosRelanzar) -Verb RunAs
        return
    } else {
        Write-Host 'Ejecuta este script con PowerShell de 64 bits.' -ForegroundColor Red
        return
    }
}

if (-not (Test-Administrador)) {
    if ($Elevado) {
        Write-Host 'No se han podido obtener permisos de administrador. No se ha cambiado nada.' -ForegroundColor Red
        return
    }
    Write-Host 'Hace falta permiso de administrador. Windows te lo va a pedir...' -ForegroundColor Yellow
    try {
        Start-Process -FilePath (Join-Path $env:windir 'System32\WindowsPowerShell\v1.0\powershell.exe') -ArgumentList (Get-ArgumentosRelanzar) -Verb RunAs
    } catch {
        Write-Host 'No se concedio el permiso. No se ha cambiado nada.' -ForegroundColor Red
    }
    return
}

try {
    Invoke-Preparacion
} catch {
    Write-Host ("No se pudo preparar la carpeta de copias ({0}). No se ha cambiado nada." -f $_.Exception.Message) -ForegroundColor Red
    return
}
Write-Log '===== Inicio del bloqueo ====='

if ($ActualizarLista) { Invoke-Seccion 'Actualizar lista' { Invoke-ActualizarLista } }

# (a) DNS + tarea (+ DoH opcional)
Invoke-Seccion '(a) Copia del DNS' { Backup-Dns }
Invoke-Seccion '(a) DNS' { Invoke-Dns }
Invoke-Seccion '(a) Tarea programada' { Invoke-TareaReaplicarDns }
if ($DohWindows11) { Invoke-Seccion '(a) DoH Windows 11' { Invoke-DohWindows11 } }

# (b) Directivas
$directivas = Get-Directivas
Invoke-Seccion '(b) Copia de directivas' { Backup-Directivas -Directivas $directivas }
Invoke-Seccion '(b) Directivas' { Invoke-Directivas -Directivas $directivas }

# (c) hosts
Invoke-Seccion '(c) Copia del hosts' { Backup-Hosts }
Invoke-Seccion '(c) hosts' { Invoke-Hosts }

# (d) Cortafuegos
Invoke-Seccion '(d) Cortafuegos' { Invoke-Firewall }

# (e) Mitigaciones opcionales
if ($IfeoExtra) { Invoke-Seccion '(e) IFEO' { Invoke-IfeoExtra } }
else { Write-Log '(e) Apps portables (Tor, Opera portable, etc.): la capa Windows NO las cubre del todo. Lo cubre Cold Turkey Pro (ver GUIA.md).' 'AVISO' }

# (f) Cuentas (lo ultimo, con confirmacion)
if ($SinCuentas) {
    Write-Log '(f) Paso de cuentas OMITIDO por -SinCuentas. Tus permisos no cambian.' 'AVISO'
} else {
    $seguir = $true
    if ($Script:Fallos.Count -gt 0) {
        Write-Host ''
        Write-Host ('Hubo ERRORES en: ' + ($Script:Fallos -join ', ')) -ForegroundColor Red
        Write-Host 'Lo prudente es revisar el registro y repetir antes de quitarte el administrador.' -ForegroundColor Yellow
        $seguir = Test-Si (Read-Host 'Escribe SI para seguir igualmente con el paso de cuentas (otra cosa = omitirlo)')
    }
    if ($seguir) {
        try { Invoke-Cuentas }
        catch { Write-Log ("(f) ERROR en el paso de cuentas: {0}. Revisa que GuardianBloqueo y tu cuenta esten como esperas." -f $_.Exception.Message) 'ERROR' }
    } else {
        Write-Log '(f) Paso de cuentas omitido por errores previos. Tus permisos no cambian.' 'AVISO'
    }
}

Write-Log '===== Fin ====='
Write-Host ''
Write-Host 'Hecho. Ejecuta EJECUTAR-comprobacion.bat para ver el estado de cada capa.' -ForegroundColor Green
Write-Host ("Registro guardado en: {0}" -f $Script:RutaLog) -ForegroundColor Gray
