<#
.SYNOPSIS
    Kit para bloquear contenido adulto - generador de llaves.

.DESCRIPTION
    Crea una "llave": una contraseña aleatoria y fuerte que tú NO ves ni memorizas.

    Qué hace, en orden:
      1. Guarda cómo tienes el historial y la sincronización del portapapeles de
         Windows y los desactiva mientras dura el proceso.
      2. Genera la llave con el generador criptográfico de Windows.
      3. Copia al portapapeles, SIN mostrarlo, el texto para tu cápsula del tiempo
         (una etiqueta y la llave). Tú lo pegas en la cápsula.
      4. Copia la llave sola para que la pegues donde va la contraseña y te
         propone comprobar que abre.
      5. Vacía el portapapeles y deja el historial y la sincronización como estaban.

    La llave solo existe en la memoria de este programa y en tu cápsula. Nunca se
    escribe en un archivo ni en ningún registro, y no sale en pantalla (salvo con
    -PorTrozos, que la enseña a propósito de 4 en 4 caracteres).
    Todo lo que se copia va marcado para que Windows NO lo guarde en el historial
    del portapapeles (Win+V) ni lo sincronice con otros dispositivos.

    Instrucciones completas: GUIA.md, en esta misma carpeta.

.PARAMETER Para
    Para qué es la llave (por ejemplo "Router"). Va en la etiqueta de la cápsula.
    Si no lo pones, el programa te lo pregunta.

.PARAMETER Longitud
    Número de caracteres. Por defecto, 20 letras y cifras. Usa 16 si el sitio no
    admite 20. Mínimo 8 con letras (4 con -SoloNumeros) y máximo 64.

.PARAMETER ConSimbolo
    Mete un símbolo (- _ o .) para los sitios que lo exigen.

.PARAMETER SoloNumeros
    Genera un PIN de solo cifras.

.PARAMETER PorTrozos
    Para teclear la llave en un aparato donde no se puede pegar. En vez de
    copiarla, la enseña de 4 en 4 caracteres. OJO: en este modo sí la ves.

.EXAMPLE
    PS> .\nueva-llave.ps1

.EXAMPLE
    PS> .\nueva-llave.ps1 -Para "Router" -Longitud 16

.NOTES
    Pensado para Windows PowerShell 5.1. Lánzalo con EJECUTAR-llave.bat.
#>
#requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Para = '',
    [ValidateRange(4, 64)][int]$Longitud = 20,
    [switch]$ConSimbolo,
    [switch]$SoloNumeros,
    [switch]$PorTrozos
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
# Nada de mensajes detallados: Set-Clipboard con -Verbose enseñaría el principio de lo copiado.
$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'

# ---------------------------------------------------------------------------
# Datos fijos
# ---------------------------------------------------------------------------

# 56 caracteres: letras y cifras sin las que se confunden (I, O, l, o, 0, 1).
# Sin comillas, espacios, @, $, % ni otros símbolos que dan guerra en routers,
# formularios web o teclados de otros idiomas.
$script:Alfabeto = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789'
$script:Simbolos = '-_.'
$script:Cifras = '0123456789'

$script:ClaveClip = 'HKCU:\Software\Microsoft\Clipboard'
$script:ValoresClip = @('EnableClipboardHistory', 'EnableCloudClipboard', 'CloudClipboardAutomaticUpload')

$script:FormatoPorParametro = $PSBoundParameters.ContainsKey('Longitud') -or $ConSimbolo.IsPresent -or $SoloNumeros.IsPresent
$script:Llave = $null
$script:HemosCopiado = $false
$script:EsSta = $true
$script:CodigoSalida = 0

# ---------------------------------------------------------------------------
# Pantalla y teclado
# ---------------------------------------------------------------------------

function Mostrar-Titulo {
    param([string]$Texto)
    Write-Host ''
    Write-Host ('=' * 72) -ForegroundColor Cyan
    Write-Host ('  ' + $Texto) -ForegroundColor Cyan
    Write-Host ('=' * 72) -ForegroundColor Cyan
}

function Mostrar-Info {
    param([string]$Texto)
    Write-Host $Texto
}

function Mostrar-Ok {
    param([string]$Texto)
    Write-Host ('[OK] ' + $Texto) -ForegroundColor Green
}

function Mostrar-Aviso {
    param([string]$Texto)
    Write-Host ('[!] ' + $Texto) -ForegroundColor Yellow
}

function Mostrar-Error {
    param([string]$Texto)
    Write-Host ('[ERROR] ' + $Texto) -ForegroundColor Red
}

function Leer-Texto {
    # Solo se usa ANTES de que exista la llave.
    param([string]$Pregunta)
    $r = Read-Host -Prompt $Pregunta
    if ($null -eq $r) { return '' }
    return ([string]$r).Trim()
}

function Convertir-Seguro {
    param([System.Security.SecureString]$Seguro)
    if ($null -eq $Seguro -or $Seguro.Length -eq 0) { return '' }
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Seguro)
    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

function Leer-Opcion {
    # Lee una opción mostrando asteriscos en vez de lo que escribes. Así, si pegas
    # la llave aquí sin querer, no aparece en pantalla.
    param([string]$Pregunta, [string[]]$Validas)
    $nombres = @()
    foreach ($v in $Validas) {
        if ($v -eq '') { $nombres += 'Intro' } else { $nombres += $v }
    }
    while ($true) {
        $seguro = Read-Host -Prompt $Pregunta -AsSecureString
        $texto = (Convertir-Seguro $seguro).Trim().ToUpperInvariant()
        $seguro = $null
        if ($Validas -contains $texto) { return $texto }
        if ($texto.Length -gt 2) {
            Mostrar-Aviso 'Parece que has pegado algo aquí. No pasa nada: no se ha mostrado ni guardado.'
        }
        Mostrar-Aviso ('Escribe solo una de estas opciones: ' + ($nombres -join ', ') + '. (Salen asteriscos a propósito.)')
    }
}

function Leer-Numero {
    param([string]$Pregunta, [int]$Minimo, [int]$Maximo)
    while ($true) {
        $r = Leer-Texto $Pregunta
        $n = 0
        if ([int]::TryParse($r, [ref]$n) -and $n -ge $Minimo -and $n -le $Maximo) { return $n }
        Mostrar-Aviso ('Escribe un número entre {0} y {1}.' -f $Minimo, $Maximo)
    }
}

function Limpiar-Pantalla {
    try { Clear-Host } catch { }
    # Borra también lo que queda al desplazarse hacia arriba (Windows Terminal y
    # consolas que entienden secuencias VT).
    $vt = $false
    try { $vt = [bool]$Host.UI.SupportsVirtualTerminal } catch { $vt = $false }
    if ($vt -or $env:WT_SESSION) {
        try { [Console]::Write([string][char]27 + '[3J') } catch { }
    }
}

function Fecha-Dentro {
    param([int]$Dias)
    return (Get-Date).AddDays($Dias).ToString('dd/MM/yyyy', [System.Globalization.CultureInfo]::InvariantCulture)
}

# ---------------------------------------------------------------------------
# Generador de llaves
# ---------------------------------------------------------------------------

function Get-IndiceAleatorio {
    # Número al azar entre 0 y Maximo-1, sin sesgo (se descartan los bytes que
    # sobrarían al repartir 256 valores entre Maximo). Maximo no puede pasar de 256.
    param($Rng, [int]$Maximo)
    $limite = 256 - (256 % $Maximo)
    $byte = New-Object byte[] 1
    do {
        $Rng.GetBytes($byte)
    } while ($byte[0] -ge $limite)
    return ([int]$byte[0] % $Maximo)
}

function Test-LlaveAceptable {
    param([string]$Texto, [string]$Tipo)
    if ($Tipo -eq 'SoloNumeros') {
        # Los móviles y algunas webs rechazan PIN con secuencias (1234, 4321, 7777, 1357...).
        for ($i = 0; $i -le $Texto.Length - 4; $i++) {
            $a = [int][char]$Texto[$i]
            $b = [int][char]$Texto[$i + 1]
            $c = [int][char]$Texto[$i + 2]
            $d = [int][char]$Texto[$i + 3]
            if (($b - $a) -eq ($c - $b) -and ($c - $b) -eq ($d - $c)) { return $false }
        }
        return $true
    }
    # Muchos formularios exigen mayúscula, minúscula y cifra.
    if ($Texto -cnotmatch '[A-Z]') { return $false }
    if ($Texto -cnotmatch '[a-z]') { return $false }
    if ($Texto -notmatch '[0-9]') { return $false }
    return $true
}

function New-Llave {
    param([int]$Longitud, [string]$Tipo)
    if ($Tipo -eq 'SoloNumeros') { $alfabeto = $script:Cifras } else { $alfabeto = $script:Alfabeto }
    $base = $Longitud
    if ($Tipo -eq 'ConSimbolo') { $base = $Longitud - 1 }
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        while ($true) {
            $sb = New-Object System.Text.StringBuilder
            for ($i = 0; $i -lt $base; $i++) {
                [void]$sb.Append($alfabeto[(Get-IndiceAleatorio $rng $alfabeto.Length)])
            }
            $candidata = $sb.ToString()
            [void]$sb.Clear()
            if (Test-LlaveAceptable $candidata $Tipo) {
                if ($Tipo -eq 'ConSimbolo') {
                    # Un solo símbolo, nunca al principio ni al final.
                    $simbolo = [string]$script:Simbolos[(Get-IndiceAleatorio $rng $script:Simbolos.Length)]
                    $posicion = 1 + (Get-IndiceAleatorio $rng ($candidata.Length - 1))
                    $candidata = $candidata.Insert($posicion, $simbolo)
                }
                return $candidata
            }
        }
    } finally {
        $rng.Dispose()
    }
}

function Describir-Formato {
    param([hashtable]$Formato)
    switch ($Formato.Tipo) {
        'SoloNumeros' { return ('PIN de {0} cifras' -f $Formato.Longitud) }
        'ConSimbolo' { return ('{0} caracteres: letras, cifras y un símbolo' -f $Formato.Longitud) }
        default { return ('{0} letras y cifras' -f $Formato.Longitud) }
    }
}

function Nuevo-TextoCapsula {
    param([string]$Etiqueta, [hashtable]$Formato, [string]$Secreto)
    $lineas = @(
        'Kit para bloquear contenido adulto - cápsula de una llave',
        ('Para: ' + $Etiqueta),
        ('Creada el: ' + (Fecha-Dentro 0)),
        ('Tipo: ' + (Describir-Formato $Formato)),
        'La llave es la línea siguiente (cópiala entera, sin espacios):',
        $Secreto
    )
    return ($lineas -join "`r`n")
}

# ---------------------------------------------------------------------------
# Portapapeles
# ---------------------------------------------------------------------------

function Test-EsWindows {
    return ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT)
}

function Test-Sta {
    return ([System.Threading.Thread]::CurrentThread.GetApartmentState() -eq [System.Threading.ApartmentState]::STA)
}

function Cargar-Formularios {
    Add-Type -AssemblyName System.Windows.Forms
}

function Nuevo-FlujoDword {
    param([int]$Valor)
    $bytes = [System.BitConverter]::GetBytes([int32]$Valor)
    return (New-Object System.IO.MemoryStream -ArgumentList (, $bytes))
}

function Copiar-Seguro {
    # Copia el texto marcado con los formatos que Microsoft documenta para que el
    # contenido NO entre en el historial (Win+V), NO se suba a la nube y lo
    # ignoren los programas que vigilan el portapapeles. Devuelve $true si ha
    # podido comprobar que el texto está copiado.
    param([string]$Texto)
    $script:HemosCopiado = $true
    if ($script:EsSta) {
        $datos = New-Object System.Windows.Forms.DataObject
        $datos.SetData([System.Windows.Forms.DataFormats]::UnicodeText, $Texto)
        $datos.SetData('ExcludeClipboardContentFromMonitorProcessing', (Nuevo-FlujoDword 0))
        $datos.SetData('CanIncludeInClipboardHistory', (Nuevo-FlujoDword 0))
        $datos.SetData('CanUploadToCloudClipboard', (Nuevo-FlujoDword 0))
        $datos.SetData('Clipboard Viewer Ignore', (Nuevo-FlujoDword 0))
        # copy = $true (sigue ahí al cerrar el programa); 10 reintentos cada 100 ms.
        [System.Windows.Forms.Clipboard]::SetDataObject($datos, $true, 10, 100)
        try {
            return ([System.Windows.Forms.Clipboard]::GetText() -ceq $Texto)
        } catch {
            return $false
        }
    }
    # Plan B, sin las marcas: depende de que el historial esté desactivado.
    # Nunca con -Verbose ni -WhatIf, que enseñarían el principio del texto.
    Set-Clipboard -Value $Texto -Verbose:$false -WhatIf:$false
    return $true
}

function Vaciar-Portapapeles {
    if (-not $script:HemosCopiado) { return $true }
    for ($intento = 1; $intento -le 5; $intento++) {
        try {
            if ($script:EsSta) {
                [System.Windows.Forms.Clipboard]::Clear()
                if (-not [System.Windows.Forms.Clipboard]::ContainsText()) { return $true }
            } else {
                Set-Clipboard -Value ' ' -Verbose:$false -WhatIf:$false
                return $true
            }
        } catch {
            Start-Sleep -Milliseconds 200
        }
    }
    return $false
}

function Test-PortapapelesIgual {
    # Comprueba, sin mostrar nada, si el portapapeles tiene exactamente este texto.
    param([string]$Texto)
    try {
        if ($script:EsSta) {
            return ([System.Windows.Forms.Clipboard]::GetText() -ceq $Texto)
        }
        return ([string](Get-Clipboard -Raw) -ceq $Texto)
    } catch {
        return $false
    }
}

function Leer-EstadoPortapapeles {
    # Devuelve los valores actuales ($null = no existía) y si existía la clave.
    $estado = @{ ExistiaClave = (Test-Path -Path $script:ClaveClip) }
    foreach ($nombre in $script:ValoresClip) {
        $valor = $null
        if ($estado.ExistiaClave) {
            $p = Get-ItemProperty -Path $script:ClaveClip -Name $nombre -ErrorAction SilentlyContinue
            if ($null -ne $p) { $valor = $p.$nombre }
        }
        $estado[$nombre] = $valor
    }
    return $estado
}

function Desactivar-HistorialPortapapeles {
    param([hashtable]$Estado)
    $estabaActivo = ($Estado['EnableClipboardHistory'] -eq 1) -or ($Estado['EnableCloudClipboard'] -eq 1) -or ($Estado['CloudClipboardAutomaticUpload'] -eq 1)
    $cambiado = $false
    try {
        if (-not (Test-Path -Path $script:ClaveClip)) { [void](New-Item -Path $script:ClaveClip -Force) }
        foreach ($nombre in $script:ValoresClip) {
            [void](New-ItemProperty -Path $script:ClaveClip -Name $nombre -PropertyType DWord -Value 0 -Force)
        }
        $cambiado = $true
        Mostrar-Ok 'Historial y sincronización del portapapeles desactivados mientras dura esto.'
    } catch {
        Mostrar-Aviso 'No he podido desactivar el historial del portapapeles yo solo.'
    }
    if ($estabaActivo -or -not $cambiado) {
        Mostrar-Info ''
        Mostrar-Info 'Voy a abrir Configuración > Sistema > Portapapeles. Comprueba que:'
        Mostrar-Info '  - "Historial del portapapeles" está Desactivado (si no, desactívalo tú).'
        Mostrar-Info '  - "Compartir entre dispositivos" (o "Sincronizar entre dispositivos") está Desactivado.'
        Mostrar-Info 'Al terminar lo dejo como estaba.'
        try {
            Start-Process 'ms-settings:clipboard'
        } catch {
            Mostrar-Aviso 'No he podido abrir la Configuración: ve tú a Inicio > Configuración > Sistema > Portapapeles.'
        }
        [void](Leer-Texto 'Cuando lo hayas comprobado, vuelve a esta ventana y pulsa Intro')
    }
}

function Restaurar-EstadoPortapapeles {
    param([hashtable]$Estado)
    try {
        if (Test-Path -Path $script:ClaveClip) {
            foreach ($nombre in $script:ValoresClip) {
                if ($null -eq $Estado[$nombre]) {
                    Remove-ItemProperty -Path $script:ClaveClip -Name $nombre -ErrorAction SilentlyContinue
                } else {
                    [void](New-ItemProperty -Path $script:ClaveClip -Name $nombre -PropertyType DWord -Value ([int]$Estado[$nombre]) -Force)
                }
            }
            if (-not $Estado.ExistiaClave) {
                $clave = Get-Item -Path $script:ClaveClip
                if ($clave.ValueCount -eq 0 -and $clave.SubKeyCount -eq 0) {
                    Remove-Item -Path $script:ClaveClip -ErrorAction SilentlyContinue
                }
            }
        }
        return $true
    } catch {
        return $false
    }
}

function Revisar-EnlaceMovil {
    $procesos = @(Get-Process -Name 'PhoneExperienceHost', 'YourPhone', 'PhoneLink' -ErrorAction SilentlyContinue)
    if ($procesos.Count -gt 0) {
        Mostrar-Aviso 'Enlace Móvil (Phone Link) está abierto en este PC.'
        Mostrar-Info '    Su función "Copiar y pegar entre dispositivos" podría mandar la llave a tu móvil.'
        Mostrar-Info '    Desactívala en la app Enlace Móvil > Configuración > Características, o en'
        Mostrar-Info '    Configuración > Bluetooth y dispositivos > Dispositivos móviles.'
        Mostrar-Info '    En Samsung, también en el móvil: Vincular a Windows > "Sincronizar portapapeles".'
    }
}

# ---------------------------------------------------------------------------
# Preguntas iniciales (todavía no existe la llave)
# ---------------------------------------------------------------------------

function Limpiar-Etiqueta {
    param([string]$Texto)
    $t = ($Texto -replace '[\r\n\t]+', ' ').Trim()
    if ($t.Length -gt 80) { $t = $t.Substring(0, 80) }
    return $t
}

function Elegir-Para {
    Mostrar-Info ''
    Mostrar-Info '¿Para qué es esta llave? (sale en la etiqueta de la cápsula)'
    Mostrar-Info '  1) Router: contraseña de administración'
    Mostrar-Info '  2) Router del operador: contraseña de su wifi (montaje con router propio)'
    Mostrar-Info '  3) Programa bloqueador del PC (por ejemplo, Cold Turkey)'
    Mostrar-Info '  4) App bloqueadora del móvil'
    Mostrar-Info '  5) Cuenta del filtro'
    Mostrar-Info '  6) Otra cosa (la escribes tú)'
    while ($true) {
        $r = Leer-Texto 'Elige un número'
        switch ($r) {
            '1' { return 'Router: contraseña de administración' }
            '2' { return 'Router del operador: contraseña de la wifi' }
            '3' { return 'Programa bloqueador del PC' }
            '4' { return 'App bloqueadora del móvil' }
            '5' { return 'Cuenta del filtro' }
            '6' {
                $t = Limpiar-Etiqueta (Leer-Texto 'Escribe para qué es (sin datos personales)')
                if ($t -ne '') { return $t }
            }
        }
        Mostrar-Aviso 'Escribe un número del 1 al 6.'
    }
}

function Elegir-Formato {
    Mostrar-Info ''
    Mostrar-Info '¿Qué tipo de llave necesitas?'
    Mostrar-Info '  [Intro] 20 letras y cifras (recomendado)'
    Mostrar-Info '  2) 16 letras y cifras (si el sitio no admite 20)'
    Mostrar-Info '  3) 20 caracteres con un símbolo - _ o . (si el sitio exige un símbolo)'
    Mostrar-Info '  4) Solo cifras (un PIN)'
    Mostrar-Info '  5) Letras y cifras con otra longitud (de 8 a 64)'
    while ($true) {
        $r = Leer-Texto 'Elige una opción'
        switch ($r) {
            '' { return @{ Tipo = 'Normal'; Longitud = 20 } }
            '1' { return @{ Tipo = 'Normal'; Longitud = 20 } }
            '2' { return @{ Tipo = 'Normal'; Longitud = 16 } }
            '3' { return @{ Tipo = 'ConSimbolo'; Longitud = 20 } }
            '4' { return @{ Tipo = 'SoloNumeros'; Longitud = (Leer-Numero '¿Cuántas cifras pide? (de 4 a 64)' 4 64) } }
            '5' { return @{ Tipo = 'Normal'; Longitud = (Leer-Numero '¿Cuántos caracteres? (de 8 a 64)' 8 64) } }
        }
        Mostrar-Aviso 'Pulsa Intro o escribe un número del 2 al 5.'
    }
}

function Formato-DeParametros {
    if ($SoloNumeros -and $ConSimbolo) {
        throw 'No se pueden usar -SoloNumeros y -ConSimbolo a la vez.'
    }
    if ($SoloNumeros) { return @{ Tipo = 'SoloNumeros'; Longitud = $Longitud } }
    if ($Longitud -lt 8) {
        throw 'Con letras, la llave necesita al menos 8 caracteres (mejor 16 o 20). Para un PIN usa -SoloNumeros.'
    }
    if ($ConSimbolo) { return @{ Tipo = 'ConSimbolo'; Longitud = $Longitud } }
    return @{ Tipo = 'Normal'; Longitud = $Longitud }
}

# ---------------------------------------------------------------------------
# Los tres pasos (ya existe la llave)
# ---------------------------------------------------------------------------

function Copiar-YAvisar {
    param([string]$Texto, [string]$Que)
    if (Copiar-Seguro $Texto) {
        Mostrar-Ok ('Copiado al portapapeles: ' + $Que + '. No se muestra.')
    } else {
        Mostrar-Aviso ('Copiado al portapapeles: ' + $Que + ', pero no he podido comprobarlo. Si al pegar no sale nada, escribe R.')
    }
}

function Paso-Capsula {
    param([string]$TextoCapsula)
    Mostrar-Titulo 'Paso 1 de 3: guarda la llave en tu cápsula del tiempo'
    Copiar-YAvisar $TextoCapsula 'el texto para la cápsula (una etiqueta y la llave)'
    Mostrar-Info ''
    Mostrar-Info '  1. Ve a tu cápsula (Timevault: GUIA.md) con la página alejada al 25 % (Ctrl y -).'
    Mostrar-Info '  2. Pega con Ctrl+V en el cuadro de texto. No te pares a leerlo.'
    Mostrar-Info ('  3. Elige la fecha de apertura. Por ejemplo: 30 días = {0} | 60 días = {1} | 90 días = {2}' -f (Fecha-Dentro 30), (Fecha-Dentro 60), (Fecha-Dentro 90))
    Mostrar-Info '  4. Cifra y guarda el texto CIFRADO en dos sitios: un correo a ti y un archivo .txt.'
    Mostrar-Info '     El texto cifrado no es secreto: cópialo sin miedo. Luego vuelvo a copiar la llave.'
    Mostrar-Aviso 'No pegues nada en esta ventana, y no pulses Ctrl+C aquí: cerraría el programa.'
    Mostrar-Info ''
    while ($true) {
        $op = Leer-Opcion '[Intro] Hecho, ya está en los dos sitios | R = volver a copiar | X = cancelar' @('', 'R', 'X')
        if ($op -eq 'R') {
            Copiar-YAvisar $TextoCapsula 'el texto para la cápsula (otra vez)'
            continue
        }
        if ($op -eq '' -and (Test-PortapapelesIgual $TextoCapsula)) {
            # Si el portapapeles sigue teniendo el texto SIN cifrar, lo que se ha pegado
            # en el correo o en el archivo no es el cifrado: es la llave a la vista.
            Mostrar-Aviso 'Ojo: el portapapeles todavía tiene el texto SIN cifrar (con la llave), no el cifrado.'
            Mostrar-Info '  Si lo has pegado en el correo, en el archivo o en FutureMe, bórralo de ahí sin leerlo'
            Mostrar-Info '  (mira también Borradores y Enviados). Después vuelve a Timevault, copia el resultado'
            Mostrar-Info '  CIFRADO (el cuadro que empieza por -----BEGIN AGE...) y pégalo en tus dos sitios.'
            Mostrar-Info '  Si la llave ha llegado a enviarse o a verse, escribe X y empieza de nuevo con otra llave.'
            $op2 = Leer-Opcion '[Intro] Ya lo he corregido | S = seguir (no lo pegué en ningún sitio) | X = cancelar' @('', 'S', 'X')
            if ($op2 -eq 'X') { return 'X' }
            if ($op2 -eq 'S') { return '' }
            continue
        }
        return $op
    }
}

function Mostrar-PorTrozos {
    param([string]$Texto, [int]$Trozo = 4)
    $total = [int][Math]::Ceiling($Texto.Length / $Trozo)
    for ($i = 0; $i -lt $total; $i++) {
        Limpiar-Pantalla
        $inicio = $i * $Trozo
        $largo = [Math]::Min($Trozo, $Texto.Length - $inicio)
        Write-Host ''
        Write-Host ('  Trozo {0} de {1}. Distingue mayúsculas y minúsculas.' -f ($i + 1), $total)
        Write-Host ''
        Write-Host ('          ' + $Texto.Substring($inicio, $largo)) -ForegroundColor Yellow
        Write-Host ''
        [void](Read-Host -Prompt '  Escríbelo en el otro aparato y pulsa Intro' -AsSecureString)
    }
    Limpiar-Pantalla
}

function Paso-Contrasena {
    Mostrar-Titulo 'Paso 2 de 3: pon la llave como contraseña'
    if ($PorTrozos) {
        if (-not (Vaciar-Portapapeles)) { Mostrar-Aviso 'No he podido vaciar el portapapeles: copia cualquier palabra para sustituir la llave.' }
        Mostrar-Aviso 'En este modo SÍ vas a ver la llave, de 4 en 4 caracteres. No intentes recordarla.'
        Mostrar-Info '  - Abre en el otro aparato la pantalla de la contraseña y toca el campo vacío.'
        Mostrar-Info '  - Vigila que el teclado no ponga sola la primera letra en mayúscula.'
        Mostrar-Info '  - Si te pide repetirla, al terminar escribe T para ver los trozos otra vez.'
        Mostrar-Info ('  - Antes de guardar, comprueba que el campo tiene {0} caracteres (o {0} puntos).' -f $script:Llave.Length)
        [void](Leer-Opcion 'Pulsa Intro para empezar' @(''))
        Mostrar-PorTrozos $script:Llave
        $pregunta = '[Intro] Hecho, guardada | T = ver los trozos otra vez | F = el sitio no la acepta | X = cancelar'
        $validas = @('', 'T', 'F', 'X')
    } else {
        Copiar-YAvisar $script:Llave 'la llave sola'
        Mostrar-Info ''
        Mostrar-Info '  1. Ve a la pantalla donde se cambia la contraseña (router, programa, app...).'
        Mostrar-Info '  2. Pega con Ctrl+V en "Contraseña nueva" y otra vez en "Repetir" o "Confirmar".'
        Mostrar-Info ('     Si el campo muestra puntos, cuéntalos: deben ser {0}. Si hay menos, el campo la ha' -f $script:Llave.Length)
        Mostrar-Info '     recortado: NO guardes y escribe F para elegir una llave más corta.'
        Mostrar-Info '  3. Guarda. Si el navegador ofrece guardar la contraseña, pulsa "Nunca".'
        Mostrar-Info '  Si antes tienes que copiar otra cosa (por ejemplo, la contraseña actual), hazlo'
        Mostrar-Info '  y después escribe R aquí para volver a copiar la llave.'
        Mostrar-Info '  Si el sitio no acepta la llave (demasiado larga, pide un símbolo...), escribe F.'
        Mostrar-Info ''
        $pregunta = '[Intro] Hecho, guardada | R = volver a copiar | F = el sitio no la acepta | X = cancelar'
        $validas = @('', 'R', 'F', 'X')
    }
    while ($true) {
        $op = Leer-Opcion $pregunta $validas
        if ($op -eq 'R') {
            Copiar-YAvisar $script:Llave 'la llave sola (otra vez)'
            continue
        }
        if ($op -eq 'T') {
            Mostrar-PorTrozos $script:Llave
            continue
        }
        return $op
    }
}

function Mostrar-AyudaPrueba {
    param([int]$Longitud)
    Mostrar-Aviso 'Con calma: la llave sigue aquí y también está en tu cápsula.'
    Mostrar-Info '  - Borra el campo de la contraseña y vuelve a pegarla (R la copia otra vez; T enseña los trozos).'
    Mostrar-Info ('  - Si al guardarla el campo tenía menos de {0} puntos, el sitio la recortó: pon la llave' -f $Longitud)
    Mostrar-Info '    y pulsa Retroceso hasta dejar los mismos puntos que tenía. Luego prueba a entrar.'
    Mostrar-Info '  - Comprueba el nombre de usuario (en muchos routers es "admin", "1234" o el de la pegatina).'
    Mostrar-Info '  - Algunos aparatos tardan un minuto en aplicar la contraseña nueva: espera y repite.'
    Mostrar-Info '  - Si aún tienes la sesión abierta en otra pestaña, puedes volver a poner allí la'
    Mostrar-Info '    contraseña de antes y empezar de nuevo.'
    Mostrar-Info '  - Si no hay manera, mira "Si una llave se pierde" en GUIA.md (en el router: el botón de reset).'
}

function Paso-Prueba {
    Mostrar-Titulo 'Paso 3 de 3: comprueba que la llave abre'
    if ($PorTrozos) {
        Mostrar-Info '  Sal de esa pantalla y vuelve a entrar tecleando la llave. Escribe T para ver los trozos.'
        $pregunta = '[Intro] Ha funcionado | T = ver los trozos | P = no me deja entrar | O = omitir la prueba'
        $validas = @('', 'T', 'P', 'O')
    } else {
        Copiar-YAvisar $script:Llave 'la llave sola (otra vez)'
        Mostrar-Info '  Cierra la sesión (o sal de esa pantalla) y vuelve a entrar pegando la llave con Ctrl+V.'
        Mostrar-Info '  Si te deja entrar, la llave funciona.'
        $pregunta = '[Intro] Ha funcionado | R = volver a copiar | P = no me deja entrar | O = omitir la prueba'
        $validas = @('', 'R', 'P', 'O')
    }
    Mostrar-Info ''
    while ($true) {
        $op = Leer-Opcion $pregunta $validas
        switch ($op) {
            'R' { Copiar-YAvisar $script:Llave 'la llave sola (otra vez)' }
            'T' { Mostrar-PorTrozos $script:Llave }
            'P' { Mostrar-AyudaPrueba $script:Llave.Length }
            'O' {
                Mostrar-Aviso 'Prueba omitida. Sin ella no sabrás si la llave abre hasta que abras la cápsula.'
                return
            }
            default {
                Mostrar-Ok 'La llave funciona.'
                return
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Programa principal
# ---------------------------------------------------------------------------

function Invoke-NuevaLlave {
    try { $Host.UI.RawUI.WindowTitle = 'Nueva llave - kit para bloquear contenido adulto' } catch { }

    Mostrar-Titulo 'Nueva llave - kit para bloquear contenido adulto'
    Mostrar-Info 'Este programa crea una llave: una contraseña al azar que NO vas a ver.'
    Mostrar-Info '  1. Copia al portapapeles el texto para tu cápsula del tiempo, sin enseñarlo.'
    Mostrar-Info '  2. Copia la llave sola para que la pongas como contraseña, y te ayuda a probarla.'
    Mostrar-Info '  3. Al terminar, vacía el portapapeles y deja Windows como estaba.'
    Mostrar-Info 'La llave no se guarda en ningún archivo: si cierras esta ventana, desaparece.'
    Mostrar-Info 'Instrucciones completas: GUIA.md, en la carpeta llaves.'

    if (-not (Test-EsWindows)) {
        Mostrar-Error 'Este programa es para Windows.'
        $script:CodigoSalida = 1
        return
    }

    $script:EsSta = Test-Sta
    try {
        Cargar-Formularios
    } catch {
        $script:EsSta = $false
    }
    if (-not $script:EsSta) {
        Mostrar-Aviso 'No puedo marcar la llave como "no guardar en el historial". Para eso, abre el programa'
        Mostrar-Aviso 'con EJECUTAR-llave.bat. Si sigues, depende de que el historial esté desactivado.'
    }

    try {
        $formato = $null
        if ($script:FormatoPorParametro) { $formato = Formato-DeParametros }
    } catch {
        Mostrar-Error $_.Exception.Message
        $script:CodigoSalida = 2
        return
    }

    $etiqueta = Limpiar-Etiqueta $Para
    if ($etiqueta -eq '') { $etiqueta = Elegir-Para }
    if ($null -eq $formato) { $formato = Elegir-Formato }

    Mostrar-Titulo 'Antes de empezar'
    Mostrar-Info '  - Ten abierta tu cápsula (Timevault, GUIA.md) con la página alejada al 25 % (Ctrl y -).'
    Mostrar-Info '    Si tu navegador te deja, mejor en una ventana InPrivate o de incógnito.'
    Mostrar-Info '  - Ten abierta la pantalla donde vas a poner la contraseña.'
    Mostrar-Info '  - Nadie compartiendo o grabando la pantalla.'
    Revisar-EnlaceMovil
    Mostrar-Info ''
    Mostrar-Info ('Llave para: ' + $etiqueta + ' | Tipo: ' + (Describir-Formato $formato))
    $r = Leer-Texto '[Intro] Empezar | X = salir sin hacer nada'
    if ($r.ToUpperInvariant() -eq 'X') {
        Mostrar-Info 'No se ha creado ninguna llave.'
        return
    }

    $estado = Leer-EstadoPortapapeles
    try {
        Desactivar-HistorialPortapapeles $estado

        while ($true) {
            $script:Llave = New-Llave $formato.Longitud $formato.Tipo
            $textoCapsula = Nuevo-TextoCapsula $etiqueta $formato $script:Llave

            $op = Paso-Capsula $textoCapsula
            $textoCapsula = $null
            if ($op -eq 'X') {
                Mostrar-Info 'Cancelado. No has puesto esta llave en ningún sitio, así que no pasa nada.'
                Mostrar-Info 'Si llegaste a crear la cápsula, bórrala o déjala: esa llave no se usará.'
                $script:CodigoSalida = 3
                return
            }

            $op = Paso-Contrasena
            if ($op -eq 'F') {
                if (-not (Vaciar-Portapapeles)) { Mostrar-Aviso 'No he podido vaciar el portapapeles: copia cualquier palabra para sustituir la llave.' }
                Mostrar-Aviso 'La cápsula que acabas de hacer ya no sirve: borra ese correo y ese archivo (o déjalos;'
                Mostrar-Aviso 'esa llave no se usará). Vamos a crear otra llave con otro formato.'
                $formato = Elegir-Formato
                continue
            }
            if ($op -eq 'X') {
                Mostrar-Info 'Cancelado.'
                Mostrar-Aviso 'Si YA habías guardado esta llave como contraseña, la buena es la de la cápsula'
                Mostrar-Aviso 'que acabas de hacer: no la borres.'
                $script:CodigoSalida = 3
                return
            }

            Paso-Prueba
            break
        }

        Mostrar-Titulo 'Listo'
    } finally {
        # Primero, solo con llamadas directas a .NET (sin comandos ni funciones de
        # PowerShell): si se ha pulsado Ctrl+C, Windows PowerShell podría no ejecutar
        # comandos aquí, pero esto sí. Así el portapapeles se vacía y el registro
        # vuelve a como estaba aunque el programa se esté cerrando.
        $script:Llave = $null
        if ($script:HemosCopiado -and $script:EsSta) {
            try { [System.Windows.Forms.Clipboard]::Clear() } catch { }
        }
        try {
            $rk = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Software\Microsoft\Clipboard', $true)
            if ($null -ne $rk) {
                try {
                    foreach ($nombre in $script:ValoresClip) {
                        if ($null -eq $estado[$nombre]) {
                            $rk.DeleteValue($nombre, $false)
                        } else {
                            $rk.SetValue($nombre, [int]$estado[$nombre], [Microsoft.Win32.RegistryValueKind]::DWord)
                        }
                    }
                } finally {
                    $rk.Close()
                }
            }
        } catch { }
        # Después, lo mismo con comprobación y mensajes.
        $vaciado = Vaciar-Portapapeles
        $restaurado = Restaurar-EstadoPortapapeles $estado
        [System.GC]::Collect()
        if ($vaciado) {
            Mostrar-Ok 'Portapapeles vacío.'
        } else {
            Mostrar-Aviso 'No he podido vaciar el portapapeles: copia cualquier palabra para sustituir la llave.'
        }
        if ($restaurado) {
            Mostrar-Ok 'El historial y la sincronización del portapapeles quedan como estaban.'
        } else {
            Mostrar-Aviso 'No he podido dejar el portapapeles como estaba: revísalo en Configuración > Sistema > Portapapeles.'
        }
    }

    Mostrar-Info ''
    Mostrar-Info 'Para terminar:'
    Mostrar-Info '  1. En Timevault, borra el cuadro donde pegaste (clic dentro, Ctrl+A y Supr) y cierra esa'
    Mostrar-Info '     pestaña. Así el navegador no lo guarda para "volver a abrir la pestaña".'
    Mostrar-Info '  2. Comprueba que el texto CIFRADO está en tus dos sitios (correo y archivo .txt).'
    Mostrar-Info '  3. Si quieres, haz la cápsula de respaldo en FutureMe con el texto cifrado (nunca la llave).'
    Mostrar-Info '  4. Apunta en tu calendario el día de apertura.'
    if ($PorTrozos) {
        Mostrar-Aviso 'Cierra también esta ventana: así desaparece lo que pudiera quedar más arriba.'
    }
    Mostrar-Info 'Si usabas el historial del portapapeles y lo ves desactivado, actívalo de nuevo en'
    Mostrar-Info 'Configuración > Sistema > Portapapeles.'
}

# Todo lo que no sea texto en pantalla se descarta, para que nada pueda sacar la llave por error.
try {
    $null = Invoke-NuevaLlave
} catch {
    Mostrar-Error ('Algo ha fallado: ' + $_.Exception.Message)
    Mostrar-Info 'No se ha guardado ninguna llave en ningún archivo. Puedes volver a empezar.'
    $script:CodigoSalida = 9
}
exit $script:CodigoSalida
