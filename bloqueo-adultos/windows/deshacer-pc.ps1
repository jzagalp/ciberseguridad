<#
    deshacer-pc.ps1  -  Revierte la capa Windows del kit de bloqueo.

    Se usa cuando llega la LLAVE desde tu capsula del tiempo. Lo mas sencillo:
    desde TU sesion de siempre, doble clic en EJECUTAR-deshacer.bat; Windows pedira
    usuario y contrasena de administrador: GuardianBloqueo + la llave.

    Revierte, a partir de la copia de seguridad de C:\ProgramData\BloqueoAdultos\copias\:
      - vuelve a dar administrador a tu cuenta original (lo primero);
      - tarea programada y su carpeta en Archivos de programa (antes que el DNS,
        para que no vuelva a poner el filtro mientras se deshace);
      - DNS de cada adaptador (a automatico/DHCP, o al DNS que tuviera puesto a mano);
      - DoH de Windows 11 anadido por el kit (si se uso);
      - reglas del cortafuegos del grupo KitBloqueoAdultos;
      - directivas de navegador (restaura las previas o borra las que puso el kit);
      - bloque del fichero hosts entre marcadores, y vacia la cache DNS;
      - friccion IFEO (si se aplico).

    Al final te pregunta si quieres BORRAR el administrador 'GuardianBloqueo'.
    Solo lo borra si queda OTRO administrador activo: nunca deja el equipo sin administrador.
#>

[CmdletBinding()]
param(
    [switch]$BorrarGuardian,
    [switch]$Elevado          # uso interno: evita bucles al pedir permisos
)

$ErrorActionPreference = 'Continue'

$BaseDatos = Join-Path $env:ProgramData 'BloqueoAdultos'
$DirCopias = Join-Path $BaseDatos 'copias'
$DirLog    = Join-Path $BaseDatos 'log'
$CarpetaTarea = Join-Path $env:ProgramFiles 'KitBloqueo'
$NombreTarea = 'KitBloqueo - Reaplicar DNS'
$RutaTareaSch = '\KitBloqueo\'
$NombreAdmin = 'GuardianBloqueo'
$GrupoFw   = 'KitBloqueoAdultos'
$MarcaIni  = '# >>> KitBloqueo (bloqueo de contenido adulto) - no editar a mano'
$MarcaFin  = '# <<< KitBloqueo'
$Hosts     = Join-Path $env:windir 'System32\drivers\etc\hosts'
$SidAdmins = 'S-1-5-32-544'

$DnsFiltradoV4 = @('185.228.168.168', '185.228.169.168', '1.1.1.3', '1.0.0.3')
$DnsFiltradoV6 = @('2a0d:2a00:1::', '2a0d:2a00:2::', '2606:4700:4700::1113', '2606:4700:4700::1003')

$Script:RutaLog = $null
$Script:Errores = 0
function Write-Log {
    param([string]$Mensaje, [string]$Nivel = 'INFO')
    $linea = ('{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Nivel, $Mensaje)
    switch ($Nivel) { 'ERROR' { Write-Host $linea -ForegroundColor Red } 'AVISO' { Write-Host $linea -ForegroundColor Yellow } 'OK' { Write-Host $linea -ForegroundColor Green } default { Write-Host $linea } }
    if ($Nivel -eq 'ERROR') { $Script:Errores++ }
    if ($Script:RutaLog) { try { Add-Content -LiteralPath $Script:RutaLog -Value $linea -Encoding UTF8 } catch { } }
}

function Test-Si {
    param([string]$Texto)
    if ($null -eq $Texto) { return $false }
    return ($Texto.Trim() -match '^s[i\u00ed]$')
}

function Test-Administrador {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $pr = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $pr.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-SidMiembrosGrupo {
    # SID de los miembros de un grupo local, por ADSI (no depende del idioma de Windows).
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
    # Dueno del explorer.exe de esta sesion = la persona sentada delante.
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

function Get-ArgumentosRelanzar {
    $argu = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-Sta', '-NoExit', '-File', ('"' + $PSCommandPath + '"'))
    if ($BorrarGuardian) { $argu += '-BorrarGuardian' }
    $argu += '-Elevado'
    return $argu
}

# ---- 64 bits y permisos ----
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $native = Join-Path $env:windir 'sysnative\WindowsPowerShell\v1.0\powershell.exe'
    if (Test-Path -LiteralPath $native) {
        Start-Process -FilePath $native -ArgumentList (Get-ArgumentosRelanzar) -Verb RunAs
        return
    }
}

if (-not (Test-Administrador)) {
    if ($Elevado) {
        Write-Host 'No se han podido obtener permisos de administrador. No se ha cambiado nada.' -ForegroundColor Red
        return
    }
    Write-Host 'Hace falta permiso de administrador: Windows te pedira usuario y contrasena.' -ForegroundColor Yellow
    Write-Host 'Elige GuardianBloqueo (o "Mas opciones") y teclea la llave con sus guiones.' -ForegroundColor Yellow
    try {
        Start-Process -FilePath (Join-Path $env:windir 'System32\WindowsPowerShell\v1.0\powershell.exe') -ArgumentList (Get-ArgumentosRelanzar) -Verb RunAs -ErrorAction Stop
    } catch {
        Write-Host 'No se concedio el permiso. No se ha cambiado nada.' -ForegroundColor Red
    }
    return
}

if (-not (Test-Path -LiteralPath $DirLog)) { New-Item -ItemType Directory -Path $DirLog -Force | Out-Null }
$Script:RutaLog = Join-Path $DirLog ('deshacer-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
Write-Log '===== Inicio del deshacer ====='

$yoSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$guardian = Get-LocalUser -Name $NombreAdmin -ErrorAction SilentlyContinue
$guardianSid = $null
if ($guardian) { $guardianSid = $guardian.SID.Value }

# ---- 1) Cuenta: devolver admin a la cuenta original ANTES que nada ----
$sidOriginal = $null
$copiaCuenta = Join-Path $DirCopias 'cuenta-original.xml'
if (Test-Path -LiteralPath $copiaCuenta) {
    try { $sidOriginal = [string](Import-Clixml -LiteralPath $copiaCuenta).UsuarioSid } catch { $sidOriginal = $null }
}
if (-not $sidOriginal -or $sidOriginal -eq $guardianSid) {
    # Sin copia: se usa la persona que tiene la sesion abierta, si no es GuardianBloqueo.
    $sesion = Get-SidSesionInteractiva
    if ($sesion -and $sesion -ne $guardianSid) {
        $r = Read-Host ("No hay copia de tu cuenta. Devolver administrador a '{0}'? (SI / no)" -f (Get-NombreDeSid $sesion))
        if (Test-Si $r) { $sidOriginal = $sesion }
    }
}
if ($sidOriginal) {
    $nombreOriginal = Get-NombreDeSid $sidOriginal
    try {
        if ((Get-SidMiembrosGrupo -SidGrupo $SidAdmins) -contains $sidOriginal) {
            Write-Log ("Tu cuenta ('{0}') ya es administrador." -f $nombreOriginal) 'OK'
        } else {
            $miembro = $null
            try { $miembro = Get-LocalUser -SID $sidOriginal -ErrorAction Stop } catch { $miembro = $sidOriginal }
            Add-LocalGroupMember -SID $SidAdmins -Member $miembro -ErrorAction Stop
            if ((Get-SidMiembrosGrupo -SidGrupo $SidAdmins) -contains $sidOriginal) {
                Write-Log ("Tu cuenta ('{0}') vuelve a ser ADMINISTRADOR (efectivo al cerrar sesion y volver a entrar)." -f $nombreOriginal) 'OK'
            } else {
                Write-Log ("No se pudo confirmar que '{0}' sea administrador." -f $nombreOriginal) 'ERROR'
            }
        }
    } catch {
        Write-Log ("No se pudo devolver el admin a la cuenta original: {0}" -f $_.Exception.Message) 'ERROR'
    }
} else {
    Write-Log 'No se sabe cual es tu cuenta original. Anadela a mano: Add-LocalGroupMember -SID S-1-5-32-544 -Member "EQUIPO\tu-usuario"' 'AVISO'
}

# ---- 2) Tarea programada + carpeta (antes del DNS) ----
try {
    if (Get-ScheduledTask -TaskName $NombreTarea -TaskPath $RutaTareaSch -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $NombreTarea -TaskPath $RutaTareaSch -Confirm:$false -ErrorAction Stop
        Write-Log 'Tarea programada eliminada.' 'OK'
    }
} catch { Write-Log ("No se pudo eliminar la tarea: {0}" -f $_.Exception.Message) 'ERROR' }
if (Test-Path -LiteralPath $CarpetaTarea) {
    try { Remove-Item -LiteralPath $CarpetaTarea -Recurse -Force -ErrorAction Stop } catch { Write-Log ("No se pudo borrar '{0}'." -f $CarpetaTarea) 'AVISO' }
}

# ---- 3) DNS: automatico (DHCP) en todos los adaptadores, salvo el que estuviera puesto a mano ----
$copiaDns = Join-Path $DirCopias 'dns-original.xml'
$porGuid = @{}
if (Test-Path -LiteralPath $copiaDns) {
    try {
        foreach ($e in @(Import-Clixml -LiteralPath $copiaDns)) {
            if ($e.PSObject.Properties['StaticV4'] -and $e.Guid) { $porGuid[[string]$e.Guid] = $e }
        }
    } catch { Write-Log 'La copia del DNS no se pudo leer: se vuelve a automatico en todo.' 'AVISO' }
}
foreach ($a in @(Get-NetAdapter -ErrorAction SilentlyContinue)) {
    try {
        Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction Stop
        $e = $porGuid[[string]$a.InterfaceGuid]
        if ($e) {
            $manual = @(@($e.StaticV4) + @($e.StaticV6) | Where-Object { $_ })
            if ($manual.Count -gt 0) {
                Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $manual -ErrorAction Stop
                Write-Log ("  '{0}': DNS puesto a mano restaurado." -f $a.InterfaceAlias) 'OK'
                continue
            }
        }
        Write-Log ("  '{0}': DNS automatico (DHCP)." -f $a.InterfaceAlias) 'OK'
    } catch {
        if ($a.Status -eq 'Disabled') {
            # Adaptador deshabilitado: se borra del registro el DNS del kit para que vuelva a automatico.
            $limpio = $false
            foreach ($par in @(@('Tcpip', $DnsFiltradoV4), @('Tcpip6', $DnsFiltradoV6))) {
                try {
                    $k = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(("SYSTEM\CurrentControlSet\Services\{0}\Parameters\Interfaces\{1}" -f $par[0], $a.InterfaceGuid), $true)
                    if ($k) {
                        $actual = @(([string]$k.GetValue('NameServer', '')) -split '[\s,]+' | Where-Object { $_ })
                        if (($actual -join ',') -eq ($par[1] -join ',')) { $k.SetValue('NameServer', ''); $limpio = $true }
                        $k.Close()
                    }
                } catch { }
            }
            if ($limpio) { Write-Log ("  '{0}' (deshabilitado): DNS del kit quitado; sera automatico al activarlo." -f $a.InterfaceAlias) 'OK' }
            else { Write-Log ("  '{0}' esta deshabilitado: revisa su DNS cuando lo actives." -f $a.InterfaceAlias) 'AVISO' }
        }
        else { Write-Log ("  No se pudo restaurar el DNS de '{0}': {1}" -f $a.InterfaceAlias, $_.Exception.Message) 'ERROR' }
    }
}
try { Clear-DnsClientCache } catch { }

# ---- 4) DoH de Windows 11 (solo si se uso -DohWindows11) ----
if (Get-Command Remove-DnsClientDohServerAddress -ErrorAction SilentlyContinue) {
    foreach ($ip in ($DnsFiltradoV4 + $DnsFiltradoV6)) {
        try { Remove-DnsClientDohServerAddress -ServerAddress $ip -ErrorAction SilentlyContinue } catch { }
    }
}
try {
    $hklm = [Microsoft.Win32.Registry]::LocalMachine
    $base = 'SYSTEM\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters'
    $kb = $hklm.OpenSubKey($base, $false)
    if ($kb) {
        $interfaces = $kb.GetSubKeyNames()
        $kb.Close()
        foreach ($g in $interfaces) {
            foreach ($par in @(@('Doh', $DnsFiltradoV4), @('Doh6', $DnsFiltradoV6))) {
                foreach ($ip in $par[1]) {
                    try { $hklm.DeleteSubKeyTree(("{0}\{1}\DohInterfaceSettings\{2}\{3}" -f $base, $g, $par[0], $ip), $false) } catch { }
                }
            }
        }
    }
    Write-Log 'Ajustes DoH del kit eliminados (si los habia).' 'OK'
} catch { Write-Log ("No se pudieron limpiar los ajustes DoH: {0}" -f $_.Exception.Message) 'AVISO' }

# ---- 5) Cortafuegos ----
$reglas = Get-NetFirewallRule -Group $GrupoFw -ErrorAction SilentlyContinue
if ($reglas) {
    $reglas | Remove-NetFirewallRule -ErrorAction SilentlyContinue
    if (Get-NetFirewallRule -Group $GrupoFw -ErrorAction SilentlyContinue) { Write-Log 'Quedan reglas del cortafuegos del kit.' 'ERROR' }
    else { Write-Log 'Reglas del cortafuegos del kit eliminadas.' 'OK' }
} else { Write-Log 'No habia reglas del cortafuegos del kit.' }

# ---- 6) Directivas ----
function Restaurar-Directiva {
    param($Entrada)
    $ruta = $Entrada.Path; $nombre = $Entrada.Name
    if ($Entrada.Existed) {
        if (-not (Test-Path -LiteralPath $ruta)) { New-Item -Path $ruta -Force | Out-Null }
        $tipo = switch ($Entrada.Kind) { 'DWord' { 'DWord' } 'QWord' { 'QWord' } 'MultiString' { 'MultiString' } 'ExpandString' { 'ExpandString' } 'Binary' { 'Binary' } default { 'String' } }
        $valor = $Entrada.Value
        if ($tipo -eq 'MultiString') { $valor = [string[]]@($valor) }
        if ($tipo -eq 'Binary') { $valor = [byte[]]@($valor) }
        New-ItemProperty -Path $ruta -Name $nombre -Value $valor -PropertyType $tipo -Force | Out-Null
    } else {
        if (Test-Path -LiteralPath $ruta) { Remove-ItemProperty -LiteralPath $ruta -Name $nombre -ErrorAction SilentlyContinue }
    }
}
# Lista de lo que pone el kit (se usa si no hay copia).
$chromium = @('HKLM:\SOFTWARE\Policies\Google\Chrome', 'HKLM:\SOFTWARE\Policies\Chromium', 'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave', 'HKLM:\SOFTWARE\Policies\Vivaldi')
$valoresKit = @()
foreach ($r in $chromium) {
    foreach ($n in @('IncognitoModeAvailability', 'DnsOverHttpsMode', 'ForceGoogleSafeSearch', 'ForceYouTubeRestrict', 'BrowserGuestModeEnabled', 'BrowserAddPersonEnabled', 'ExtensionSettings', 'ExtensionDeveloperModeSettings', 'ProxySettings')) {
        $valoresKit += [pscustomobject]@{ Path = $r; Name = $n; Existed = $false }
    }
}
foreach ($n in @('TorDisabled', 'BraveVPNDisabled')) { $valoresKit += [pscustomobject]@{ Path = 'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave'; Name = $n; Existed = $false } }
foreach ($n in @('InPrivateModeAvailability', 'DnsOverHttpsMode', 'ForceBingSafeSearch', 'ForceGoogleSafeSearch', 'ForceYouTubeRestrict', 'BrowserGuestModeEnabled', 'BrowserAddProfileEnabled', 'ExtensionSettings', 'ExtensionDeveloperModeSettings', 'ProxySettings')) {
    $valoresKit += [pscustomobject]@{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'; Name = $n; Existed = $false }
}
$ff = 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox'
$valoresKit += [pscustomobject]@{ Path = "$ff\DNSOverHTTPS"; Name = 'Enabled'; Existed = $false }
$valoresKit += [pscustomobject]@{ Path = "$ff\DNSOverHTTPS"; Name = 'Locked'; Existed = $false }
$valoresKit += [pscustomobject]@{ Path = "$ff\Proxy"; Name = 'Mode'; Existed = $false }
$valoresKit += [pscustomobject]@{ Path = "$ff\Proxy"; Name = 'Locked'; Existed = $false }
foreach ($n in @('DisablePrivateBrowsing', 'PrivateBrowsingModeAvailability', 'BlockAboutConfig', 'IPProtectionAvailable')) { $valoresKit += [pscustomobject]@{ Path = $ff; Name = $n; Existed = $false } }

$copiaDir = Join-Path $DirCopias 'directivas-original.xml'
$prev = @()
if (Test-Path -LiteralPath $copiaDir) {
    try { $prev = @(Import-Clixml -LiteralPath $copiaDir) } catch { $prev = @() }
}
$enCopia = @{}
foreach ($e in $prev) {
    $enCopia[($e.Path + '|' + $e.Name)] = $true
    try { Restaurar-Directiva -Entrada $e } catch { Write-Log ("  No se pudo restaurar {0}\{1}" -f $e.Path, $e.Name) 'ERROR' }
}
# Lo que el kit pone y no esta en la copia, se borra.
foreach ($e in $valoresKit) {
    if (-not $enCopia.ContainsKey($e.Path + '|' + $e.Name)) {
        try { Restaurar-Directiva -Entrada $e } catch { }
    }
}
# Borrar claves que hayan quedado vacias (sin valores ni subclaves), de dentro a fuera.
foreach ($r in @("$ff\DNSOverHTTPS", "$ff\Proxy", $ff, 'HKLM:\SOFTWARE\Policies\Mozilla',
                 'HKLM:\SOFTWARE\Policies\Google\Chrome', 'HKLM:\SOFTWARE\Policies\Google', 'HKLM:\SOFTWARE\Policies\Chromium',
                 'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave', 'HKLM:\SOFTWARE\Policies\BraveSoftware',
                 'HKLM:\SOFTWARE\Policies\Vivaldi', 'HKLM:\SOFTWARE\Policies\Microsoft\Edge')) {
    try {
        if (Test-Path -LiteralPath $r) {
            $k = Get-Item -LiteralPath $r
            if ($k.ValueCount -eq 0 -and $k.SubKeyCount -eq 0) { Remove-Item -LiteralPath $r -Force -ErrorAction Stop }
        }
    } catch { }
}
Write-Log 'Directivas de navegador restauradas (reinicia los navegadores).' 'OK'

# ---- 7) hosts ----
if (Test-Path -LiteralPath $Hosts) {
    try {
        $lineas = Get-Content -LiteralPath $Hosts -Encoding UTF8
        if ($lineas -contains $MarcaIni) {
            $salida = New-Object System.Collections.Generic.List[string]
            $dentro = $false
            foreach ($l in $lineas) {
                if ($l -eq $MarcaIni) { $dentro = $true; continue }
                if ($l -eq $MarcaFin) { $dentro = $false; continue }
                if (-not $dentro) { $salida.Add($l) }
            }
            while ($salida.Count -gt 0 -and [string]::IsNullOrWhiteSpace($salida[$salida.Count - 1])) { $salida.RemoveAt($salida.Count - 1) }
            $item = Get-Item -LiteralPath $Hosts -Force
            if ($item.Attributes -band [System.IO.FileAttributes]::ReadOnly) { $item.Attributes = $item.Attributes -bxor [System.IO.FileAttributes]::ReadOnly }
            $utf8 = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllLines($Hosts, $salida.ToArray(), $utf8)
            Write-Log 'Bloque del kit eliminado del fichero hosts.' 'OK'
        } else {
            Write-Log 'El fichero hosts no tenia el bloque del kit.'
        }
    } catch { Write-Log ("No se pudo limpiar el fichero hosts: {0}" -f $_.Exception.Message) 'ERROR' }
    try { Clear-DnsClientCache } catch { }
    try { & ipconfig.exe /flushdns | Out-Null } catch { }
}

# ---- 8) IFEO (friccion extra, solo si se aplico) ----
$ifeoBase = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
foreach ($exe in @('tor.exe', 'opera.exe', 'opera_gx.exe', 'psiphon3.exe')) {
    $r = Join-Path $ifeoBase $exe
    if (Test-Path -LiteralPath $r) {
        try {
            $d = Get-ItemProperty -LiteralPath $r -Name 'Debugger' -ErrorAction SilentlyContinue
            if ($d -and $d.Debugger -match 'cmd\.exe" /c exit$') {
                Remove-ItemProperty -LiteralPath $r -Name 'Debugger' -ErrorAction Stop
                $k = Get-Item -LiteralPath $r
                if ($k.ValueCount -eq 0 -and $k.SubKeyCount -eq 0) { Remove-Item -LiteralPath $r -Force }
                Write-Log ("Friccion IFEO quitada de {0}." -f $exe) 'OK'
            }
        } catch { Write-Log ("No se pudo quitar IFEO de {0}." -f $exe) 'AVISO' }
    }
}

# ---- 9) Copias: se archivan para que un bloqueo futuro guarde copias nuevas ----
if ($Script:Errores -eq 0 -and (Test-Path -LiteralPath $DirCopias)) {
    try {
        Rename-Item -LiteralPath $DirCopias -NewName ('copias-deshecho-{0}' -f (Get-Date -Format 'yyyyMMdd-HHmmss')) -ErrorAction Stop
        Write-Log 'Copias de seguridad archivadas.' 'OK'
    } catch { Write-Log 'No se pudieron archivar las copias (no pasa nada).' 'AVISO' }
} elseif ($Script:Errores -gt 0) {
    Write-Log 'Hubo errores: se conservan las copias para poder repetir el deshacer.' 'AVISO'
}

# ---- 10) Borrar GuardianBloqueo (opcional, nunca si es el unico administrador) ----
if ($guardian) {
    $borrar = [bool]$BorrarGuardian
    if (-not $borrar) {
        $borrar = Test-Si (Read-Host ("Quieres BORRAR el administrador '{0}'? (SI / no)" -f $NombreAdmin))
    }
    if ($borrar) {
        # Tiene que quedar otro administrador local HABILITADO (no vale el integrado deshabilitado).
        $otrosAdmins = @()
        try {
            foreach ($s in (Get-SidMiembrosGrupo -SidGrupo $SidAdmins)) {
                if ($s -eq $guardianSid) { continue }
                $u = Get-LocalUser -ErrorAction SilentlyContinue | Where-Object { $_.SID.Value -eq $s }
                if ($u -and $u.Enabled) { $otrosAdmins += $u.Name }
                elseif (-not $u -and $s -eq $sidOriginal) { $otrosAdmins += (Get-NombreDeSid $s) }   # cuenta Microsoft/Entra
            }
        } catch { }
        if ($otrosAdmins.Count -eq 0) {
            Write-Log ("NO se borra '{0}': es el unico administrador activo. Primero comprueba que tu cuenta vuelve a ser administrador." -f $NombreAdmin) 'AVISO'
        } else {
            try {
                Remove-LocalUser -Name $NombreAdmin -ErrorAction Stop
                Write-Log ("Administrador '{0}' borrado. Quedan como administradores: {1}" -f $NombreAdmin, ($otrosAdmins -join ', ')) 'OK'
                if ($yoSid -eq $guardianSid) { Write-Log 'Esta ventana seguia funcionando como GuardianBloqueo: cierrala al terminar.' 'AVISO' }
                $perfil = Join-Path (Split-Path -Parent $env:PUBLIC) $NombreAdmin
                if (Test-Path -LiteralPath $perfil) { Write-Log ("Puedes borrar a mano la carpeta '{0}' cuando reinicies." -f $perfil) 'AVISO' }
            } catch { Write-Log ("No se pudo borrar '{0}': {1}" -f $NombreAdmin, $_.Exception.Message) 'AVISO' }
        }
    } else {
        Write-Log ("Se conserva el administrador '{0}'." -f $NombreAdmin)
    }
}

Write-Log '===== Fin del deshacer ====='
Write-Host ''
if ($Script:Errores -gt 0) {
    Write-Host ("Terminado con {0} error(es). Revisa el registro: {1}" -f $Script:Errores, $Script:RutaLog) -ForegroundColor Yellow
} else {
    Write-Host 'Listo. Cierra sesion y vuelve a entrar con tu cuenta (ya vuelve a ser administrador).' -ForegroundColor Green
}
Write-Host 'Reinicia los navegadores para que olviden las directivas.' -ForegroundColor Gray
