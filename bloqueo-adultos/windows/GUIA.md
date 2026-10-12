# Capa Windows: bloquear contenido adulto en tu PC

Esta guía es para tu ordenador con Windows 10 u 11. Está pensada para que la pueda
seguir cualquier persona, sin conocimientos técnicos. Ve con calma y lee cada paso
antes de hacerlo.

La idea es sencilla: montamos **varias capas** que se refuerzan entre sí y, al final,
tu cuenta deja de ser administradora del equipo. La contraseña del nuevo administrador
(la **llave**) la crea el programa, **tú no la ves** y queda guardada en una "cápsula
del tiempo" (se explica en la carpeta `llaves/` del kit). Así no puedes deshacerlo en un impulso. Cuando
pase el tiempo que elijas (30 a 90 días), recuperas la llave y puedes revisarlo o
renovarlo.

> **Ninguna barrera es 100 % infalible.** Más abajo tienes la lista honesta de los
> huecos que quedan y qué capa cubre cada cosa. Esto es una ayuda para tu fuerza de
> voluntad, no una jaula.

---

## Qué hace cada capa

1. **DNS filtrado (CleanBrowsing Family).** Es como cambiar la "guía telefónica" que
   usa el ordenador para encontrar las webs. CleanBrowsing Family no devuelve la
   dirección de las webs para adultos, de proxies/VPN ni de contenido mixto, y además
   obliga a la **búsqueda segura** de Google y Bing y al **modo restringido** de YouTube.
   Se pone en todos los adaptadores de red (wifi y cable) y una tarea automática lo vuelve
   a poner si algo lo cambia (al arrancar, al iniciar sesión o al conectar una red nueva).
   Como respaldo se añade **Cloudflare for Families** (1.1.1.3), que también bloquea
   contenido adulto, para que el PC no se quede sin internet si CleanBrowsing fallara.

2. **Directivas de navegador.** Reglas que se graban en el sistema y que Chrome, Edge,
   Brave, Vivaldi, Chromium y Firefox obedecen aunque tu cuenta no sea administradora:
   - sin modo incógnito / InPrivate / navegación privada;
   - búsqueda segura y YouTube restringido forzados (por si fallara el DNS);
   - sin perfiles "invitado" ni añadir personas/perfiles nuevos;
   - en Chrome, Edge, Brave y Vivaldi se bloquean las extensiones que piden permiso de
     **proxy** (todas las de VPN/proxy);
   - se desactivan el DNS cifrado del navegador, el Tor y la VPN de Brave y la VPN
     integrada de Firefox.
   - **Ojo con Edge:** según Microsoft, desde Edge 116 algunas directivas pueden no
     aplicarse a un perfil con la sesión iniciada con una **cuenta Microsoft**. De las del
     kit, las afectadas son el bloqueo de extensiones de proxy/VPN, el del modo
     desarrollador y el YouTube restringido (este último lo sigue forzando el DNS). Lo
     compruebas en el paso 9. La VPN integrada de Edge ("Secure Network") no tiene
     directiva para apagarla; según Microsoft no está disponible en navegadores
     "administrados" y, según cuentan usuarios, Edge pasa a serlo al recibir directivas
     como estas (compruébalo en Configuración > Privacidad de Edge).

3. **Fichero `hosts`.** Una lista local de unos **76.000 dominios** para adultos que el
   ordenador mira **antes** que cualquier DNS (funciona incluso con VPN o con el DNS
   cifrado del propio navegador). Se añade también un bloque que impide usar los
   servidores de **DNS cifrado público** más conocidos como puerta trasera.

4. **Cortafuegos de Windows.** Obliga a que **todas** las consultas de DNS del equipo
   vayan al filtro. Si una app o una VPN intenta preguntar a otro servidor de DNS, se
   bloquea. Está diseñado para **fallar cerrado**: ante la duda, no resuelve; nunca
   resuelve sin filtro.

5. **Fricción opcional contra apps portables** (solo si lo pides). Un poco de fricción
   extra contra Tor/Opera/Psiphon portables. Se evita renombrando el programa, así que
   lo eficaz para esto es Cold Turkey Pro (más abajo).

6. **Cuentas.** Se crea un administrador nuevo (`GuardianBloqueo`) con una llave que
   **tú no ves**, y tu cuenta pasa a ser **estándar**. Así no puedes cambiar nada de lo
   anterior sin la llave, que estará guardada en tu cápsula del tiempo. El programa
   comprueba que `GuardianBloqueo` funciona **antes** de quitarte nada y nunca deja el
   equipo sin un administrador.

---

## Antes de empezar (importante)

- [ ] **Haz copia de seguridad de tus archivos.** Si algún día pierdes la llave, la
      única salida es restablecer o reinstalar Windows, y eso borra programas y ajustes.
      Copia tus cosas a OneDrive o a un disco externo. Es el paso más importante.
- [ ] **Comprueba que sabes entrar en tu cuenta.** Si usas una **cuenta de Microsoft**,
      asegúrate de recordar su correo y contraseña (o el PIN de Windows Hello), porque la
      vas a seguir usando para iniciar sesión; solo cambia que dejará de ser administradora.
- [ ] **Apunta tu clave de recuperación de BitLocker** si tu equipo tiene el disco
      cifrado. Suele estar en tu cuenta de Microsoft
      (`https://account.microsoft.com/devices/recoverykey`). **No** vamos a tocar
      BitLocker, pero esa clave es la que te podría pedir Windows si algún día tuvieras
      que restablecer el equipo.
- [ ] **Prepara tu cápsula del tiempo** siguiendo la guía de `llaves/`: haz el
      **ensayo** de Timevault y el apartado **"Antes de crear la primera llave"**
      (historial del portapapeles, Enlace Móvil, que el navegador no guarde contraseñas).
      Tenla lista **antes** de llegar al paso de cuentas, porque ahí pegarás la llave y ya
      no la volverás a ver.
- [ ] **Si vas a usar Cold Turkey Pro** (recomendado, ver más abajo), **instálalo y
      configúralo ahora**, mientras tu cuenta todavía es administradora.
- [ ] **Si vas a configurar el móvil con su script** (guía `android/`, nivel 2), hazlo
      **antes** que esta capa: el controlador USB del móvil puede necesitar permisos de
      administrador.
- [ ] **Desinstala Opera / Opera GX** si lo tienes: no obedece las directivas y trae una
      VPN propia. En Windows 11: Configuración > Aplicaciones > Aplicaciones instaladas >
      busca Opera > botón **⋯** > **Desinstalar**. En Windows 10: Configuración >
      Aplicaciones > Aplicaciones y características > Opera > **Desinstalar**.
- [ ] **Instala ahora lo que vayas a necesitar** en las próximas semanas y que pida
      administrador (impresora, programas del trabajo o de clase...): después no podrás
      sin la llave.
- [ ] **Si usas este PC con la VPN de tu trabajo**, es probable que deje de funcionar: el
      cortafuegos del kit solo deja preguntar al DNS del filtro, y esas VPN suelen usar su
      propio DNS. No apliques el kit a un ordenador de empresa.
- [ ] **Cierra los navegadores** antes de empezar, para que lean las directivas nuevas
      al volver a abrirlos. Cuando el programa llegue al paso de cuentas, vuelve a abrir
      el navegador con Timevault para hacer la cápsula.
- [ ] **Descomprime el kit entero** (si lo bajaste en ZIP) en `C:\KitBloqueo`. Evita
      Documentos y el Escritorio: si están en OneDrive y un archivo queda "solo en la
      nube", el programa no podrá leerlo al renovar o deshacer con `GuardianBloqueo`.
      No lo ejecutes desde dentro del ZIP.

Si tu equipo tiene **Windows 10**: el kit funciona, pero Windows 10 ya no recibe
actualizaciones de seguridad normales. Si puedes, pasa a Windows 11.

Cosas que **no** vamos a hacer, a propósito, para no dejarte sin ordenador:
- No ponemos contraseña de BIOS/UEFI (en algunos portátiles es irrecuperable).
- No desactivamos el entorno de recuperación de Windows.
- No usamos BitLocker con la clave metida en la cápsula.

---

## Pasos

1. Abre la carpeta `windows` del kit.
2. Haz **doble clic en `EJECUTAR-bloqueo.bat`**. La primera vez Windows puede decir
   "Windows protegió su PC": pulsa **Más información** > **Ejecutar de todas formas**.
3. Windows te pedirá permiso de administrador (ventana "Control de cuentas de usuario"):
   pulsa **Sí**.
4. Se abrirá una ventana negra con texto. Ve leyendo: aplicará el DNS, las directivas,
   el `hosts` y el cortafuegos casi sin preguntarte nada.
   - Si ves un **AVISO** sobre "otro cortafuegos" (McAfee, Norton...), apúntalo: ese
     antivirus manda sobre el cortafuegos y las reglas de Windows podrían no aplicarse.
     Mira la tabla de huecos.
   - Si alguna capa da **ERROR** (en rojo), el programa te lo dirá antes del paso de
     cuentas y te recomendará no seguir. Lo prudente es responder que no, revisar y
     repetir.
5. Al final llega el **paso de cuentas**. El programa te enseña qué cuenta va a pasar a
   estándar (la tuya) y te pide que escribas `SI` para seguir. Si prefieres montar solo
   las capas y dejar las cuentas para otro día, escribe cualquier otra cosa: no se toca
   ninguna cuenta.
6. Si has escrito `SI`:
   - Abre **Configuración > Sistema > Portapapeles** (el programa intenta abrirla solo)
     y comprueba que **"Historial del portapapeles"** y **"Compartir entre dispositivos"**
     (en Windows 10, "Sincronizar entre dispositivos") están en **Desactivado**. Vuelve a
     la ventana negra y pulsa Intro.
   - El programa crea la llave y la copia al portapapeles **sin mostrarla**.
   - **Guárdala en tu cápsula** tal como explica la guía de `llaves/`, apartado
     **"Si la llave la crea otro programa del kit"**: en Timevault elige **primero la
     fecha**, escribe tú la etiqueta (por ejemplo `Windows - administrador GuardianBloqueo`),
     pega la llave debajo con **Ctrl+V** (el cifrado sale solo), guarda el texto cifrado
     en dos sitios y comprueba la fecha en la pestaña **Decrypt**. No la pegues en ningún
     otro lado ni la mires.
   - Vuelve a la ventana negra y escribe `PEGADA`.
     - Si el portapapeles se ha perdido antes de pegarla, escribe `COPIAR` y la vuelve
       a copiar.
     - Si no consigues guardarla, escribe `CANCELAR`: no cambia nada y sigues como antes.
   - **No cierres la ventana con la X** mientras la llave está en el portapapeles.
   - Después de `PEGADA`, el programa pone la llave a `GuardianBloqueo`, **comprueba que
     funciona** y **solo entonces** convierte tu cuenta en estándar. Al final vacía el
     portapapeles.
7. **Cierra sesión** (Inicio > tu nombre > Cerrar sesión) o reinicia, para que el cambio
   de cuenta surta efecto.
8. Abre `EJECUTAR-comprobacion.bat` (no necesita administrador) y revisa que todas las
   capas dan **OK**. Si alguna da **AVISO**, suele ser falta de conexión: conéctate y
   repite. Si alguna da **FALLO**, reinicia y repite; si sigue, mira la tabla de huecos.
9. Comprueba también en el navegador: escribe `chrome://policy` en Chrome (o
   `edge://policy` en Edge, `about:policies` en Firefox) y verás las directivas del kit.
   En Edge, fíjate en el estado de `ExtensionSettings`: si no sale como correcto (por
   ejemplo, "Ignorada" o con un aviso por la cuenta Microsoft), mira la tabla de huecos.

> Puedes volver a ejecutar `EJECUTAR-bloqueo.bat` las veces que quieras: no duplica nada.

**Opciones avanzadas** (casi nunca hacen falta). En la carpeta `windows`, haz clic en la
barra de direcciones de arriba (donde aparece la ruta), escribe `cmd` y pulsa Intro. En la
ventana que se abre, escribe por ejemplo `EJECUTAR-bloqueo.bat -ActualizarLista` y pulsa Intro.

| Opción | Qué hace |
|---|---|
| `-ActualizarLista` | Descarga la lista de dominios más reciente antes de aplicarla. |
| `-SinCuentas` | Aplica todas las capas sin preguntar por las cuentas. |
| `-IfeoExtra` | Añade la fricción contra Tor/Opera/Psiphon portables. Tu antivirus podría avisar. |
| `-DohWindows11` | Solo Windows 11: cifra las consultas DNS hacia el filtro. No bloquea más webs, pero evita que el router del operador conteste en lugar del filtro (ver huecos). El programa comprueba que sigues navegando y, si no, lo quita solo. Úsala antes del paso de cuentas. |

---

## Qué cambia en tu día a día

- Navegas, trabajas y usas tus programas igual que siempre.
- Windows Update y las actualizaciones automáticas de Chrome o Edge siguen funcionando.
- Cuando algo pida permiso de administrador (instalar ciertos programas, cambiar la red,
  tocar el cortafuegos), Windows te pedirá usuario y contraseña de administrador: no la
  tienes, y es justo lo que buscamos. Pulsa **No**.
- Algunas búsquedas o vídeos de YouTube normales aparecerán ocultos por el modo estricto.
  Es el precio de forzarlo.

---

## Capa extra recomendada: Cold Turkey Pro

El filtro por DNS y el `hosts` bloquean **webs**, pero no miran la URL completa ni
bloquean **programas**. Para tapar los huecos de apps portables (Tor, navegadores
portables) y de proxies/VPN dentro del navegador, lo más eficaz es **Cold Turkey**:

- **Gratis** ya bloquea webs con temporizador (no se puede cancelar a mitad).
- **Pro** (pago único para todos tus ordenadores) añade: bloqueo de **aplicaciones**,
  horarios, contraseña de la app y todas las opciones de bloqueo "locked" que no se
  pueden desactivar mientras están activas; según sus notas de versión, también tiene
  opciones contra navegadores no compatibles (como Tor Browser).
- **Instálalo antes del paso de cuentas** (necesita administrador para instalarse).
  Como contraseña de Cold Turkey usa una **llave distinta**, creada con
  `EJECUTAR-llave.bat` de la carpeta `llaves/` (opción 3), en su propia cápsula. Como
  después tu cuenta será estándar, no podrás desinstalarlo: doble candado.
- Precio: compruébalo en `https://getcoldturkey.com/pricing` (las fuentes que
  consultamos daban entre 39 y 45 USD de pago único; confírmalo antes de pagar).
- En sus ajustes, activa las opciones que impiden **desinstalarlo o saltárselo** y las
  que bloquean las ventanas de incógnito, invitado y Tor (los nombres cambian entre
  versiones; no hemos podido confirmarlos). Guía oficial:
  `https://getcoldturkey.com/support/user-guide/`.
- Si bloqueas aplicaciones, **no bloquees** `powershell.exe`, `cmd.exe` ni `adb.exe`:
  los programas del kit (comprobación, llaves y móvil) los necesitan.
- **No uses "Frozen Turkey"** (te deja fuera del ordenador entero): demasiado riesgo.

Alternativa **gratis** si no quieres pagar: **Microsoft Family Safety**. Puede filtrar
a una persona adulta si su cuenta es "miembro" de una familia cuyo "organizador" es otra
cuenta de Microsoft (crea una segunda cuenta como organizador y usa una llave como su
contraseña). Es más frágil: el filtro de webs **solo funciona en Edge**, bloquea los demás
navegadores por el nombre del programa (se esquiva renombrándolo) y ha tenido fallos. Y
como la contraseña de esa cuenta se puede recuperar por correo, la llave solo añade
fricción.

---

## Cómo deshacerlo (cuando llegue la llave)

Cuando tu cápsula del tiempo te devuelva la llave y quieras quitar el bloqueo:

1. Con la llave delante (ahora sí puedes verla), entra en **tu sesión de siempre**.
2. Abre la carpeta `windows` del kit y haz **doble clic en `EJECUTAR-deshacer.bat`**.
3. Windows te pedirá **usuario y contraseña de administrador** (ventana "Control de
   cuentas de usuario"). Elige **GuardianBloqueo** (si no aparece, pulsa **Más opciones**;
   si pide nombre de usuario, escribe `GuardianBloqueo`) y **teclea la llave** tal cual,
   con sus guiones. Las mayúsculas y minúsculas importan. Pulsa **Sí**.
   - Si te equivocas muchas veces seguidas, Windows bloquea la cuenta unos minutos
     (normalmente 10). Espera y vuelve a probar.
4. El programa lo revierte todo a partir de la copia de seguridad guardada en
   `C:\ProgramData\BloqueoAdultos\copias\`:
   - **tu cuenta vuelve a ser administradora** (lo primero de todo);
   - se elimina la **tarea programada**;
   - el **DNS** vuelve a automático (o al que tuvieras puesto a mano antes del kit);
   - se quitan los ajustes de **DNS cifrado** que hubiera puesto el kit;
   - se borran las **reglas del cortafuegos** del grupo `KitBloqueoAdultos`;
   - se **restauran las directivas** de navegador a como estaban;
   - se quita el **bloque del `hosts`** y se vacía la caché de DNS;
   - al final te pregunta si quieres **borrar** la cuenta `GuardianBloqueo`. Solo la
     borra si queda otro administrador activo (tu cuenta).
5. **Cierra sesión y vuelve a entrar** con tu cuenta: ya es administradora. Reinicia los
   navegadores.

### Renovar en vez de quitar

Para otra temporada con una **llave nueva**:

1. (Opcional) Actualiza la lista de dominios: abre `cmd` en la carpeta `windows` como se
   explica en "Opciones avanzadas" y escribe `EJECUTAR-bloqueo.bat -ActualizarLista`.
   Si no, haz doble clic en `EJECUTAR-bloqueo.bat`.
2. Cuando Windows pida administrador, elige **GuardianBloqueo** y teclea la llave vieja.
3. El programa vuelve a aplicar todas las capas. En el paso de cuentas verá que tu cuenta
   ya es estándar y te ofrecerá **RENOVAR**: escribe `SI`, guarda la llave nueva en una
   cápsula nueva y escribe `PEGADA`. Desde ese momento la llave vieja ya no sirve.

### Comandos sueltos por si algo falla (solo con administrador)

Abre **Windows PowerShell como administrador** (clic derecho en Inicio > Terminal
(administrador) o Windows PowerShell (administrador), y usa GuardianBloqueo y la llave):

```powershell
# DNS a automático en todos los adaptadores
Get-NetAdapter | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ResetServerAddresses }
# Quitar las reglas del cortafuegos del kit
Get-NetFirewallRule -Group 'KitBloqueoAdultos' | Remove-NetFirewallRule
# Quitar la tarea programada
Unregister-ScheduledTask -TaskName 'KitBloqueo - Reaplicar DNS' -TaskPath '\KitBloqueo\' -Confirm:$false
# Volver a poner el fichero hosts como estaba antes del kit
Copy-Item 'C:\ProgramData\BloqueoAdultos\copias\hosts.original' "$env:windir\System32\drivers\etc\hosts" -Force
ipconfig /flushdns
# Volver a ser administrador: cambia NOMBRE por tu usuario
# (para verlo, en tu sesión normal abre PowerShell y escribe: whoami)
Add-LocalGroupMember -SID S-1-5-32-544 -Member 'NOMBRE'
```

### Si pierdes la llave

Mira primero el apartado "Si una llave se pierde" de la guía de `llaves/`. Si de verdad
no hay forma de recuperarla, la salida de emergencia es **restablecer Windows**, que borra
programas y ajustes (por eso la copia de seguridad del principio):

- En la pantalla de inicio de sesión, pulsa el botón de apagado (abajo a la derecha),
  mantén pulsada **Mayús** y elige **Reiniciar**. Después: **Solucionar problemas** >
  **Restablecer este PC** > **Quitar todo**. Según Microsoft, por defecto "Quitar todo"
  no pide administrador ("Mantener mis archivos" sí). Si tu disco está cifrado, puede
  que te pida la clave de recuperación de BitLocker: tenla a mano.
- Si aun así te pide un administrador o no arranca, reinstala Windows desde un USB de instalación
  (en `https://www.microsoft.com/software-download/windows11` está la herramienta para
  crearlo desde otro ordenador).

---

## Huecos residuales (la parte honesta)

Esto es lo que esta capa de Windows **no** cierra del todo, y qué lo cubre:

| Hueco | Qué pasa | Qué lo cubre |
|---|---|---|
| **Tor Browser portable** | Resuelve el DNS por la red Tor e ignora las directivas del registro. | Cold Turkey Pro (bloqueo de apps y de navegadores no compatibles). La fricción IFEO opcional ayuda poco. |
| **Opera / navegadores portables con VPN** | No obedecen directivas y se instalan sin administrador. | Desinstalar Opera + Cold Turkey Pro. |
| **Extensiones de proxy/VPN en Firefox** | Firefox no permite bloquear extensiones por permiso como Chrome o Edge, así que una extensión de VPN podría funcionar en Firefox. | Cold Turkey Pro mira la URL en el navegador. Si no usas Firefox, desinstálalo. |
| **Webs proxy nuevas** | CleanBrowsing bloquea la categoría de proxies, pero aparecen webs nuevas. | Cold Turkey Pro. |
| **VPN que añadas en Configuración** | Una cuenta estándar puede añadir una VPN integrada de Windows. | El cortafuegos hace que su DNS siga yendo al filtro, así que **el filtrado sigue**; pero una VPN puede dar acceso a webs por IP. Cold Turkey mira la URL en el navegador. |
| **Apps con su propio DNS cifrado** | Una app puede llevar su propio DNS cifrado hacia un servidor que no está en la lista del cortafuegos. | CleanBrowsing bloquea los nombres de los servicios de DNS cifrado conocidos. Para apps concretas, Cold Turkey Pro. |
| **Apps de la Microsoft Store y de mensajería** (Telegram, Discord, X...) | Una cuenta estándar puede instalar apps de la Store, y algunas muestran contenido que no pasa por el filtro web. | No lo cubre Windows. Si es un problema, bloquéalas con Cold Turkey Pro. |
| **Reiniciar en modo seguro** | Tu cuenta sigue siendo estándar y el DNS/hosts/directivas se mantienen, pero Cold Turkey podría no arrancar. Que el cortafuegos funcione en "modo seguro con funciones de red" no está garantizado. | Cuenta estándar + DNS + router. |
| **Reinstalar Windows, arrancar desde un USB o "Restablecer este PC > Quitar todo"** | Windows no protege nada ante una reinstalación limpia. Y, según Microsoft, "Quitar todo" desde el menú de recuperación (Mayús + Reiniciar) **no pide administrador** por defecto. Es tu salida de emergencia, pero borra todos tus programas y archivos del equipo. | En casa, el **router** (otra capa del kit). Fuera de casa, nada. Lo que más frena es el coste: tendrías que reinstalarlo todo. |
| **Edge con la sesión de tu cuenta Microsoft** | Según Microsoft, algunas directivas pueden no aplicarse a ese perfil: el bloqueo de extensiones de proxy/VPN, el del modo desarrollador y el YouTube restringido de la directiva. | Compruébalo en `edge://policy` (paso 9). Si salen ignoradas: usa Chrome o Edge sin iniciar sesión con la cuenta Microsoft. El DNS sigue forzando YouTube restringido y bloqueando webs de VPN/proxy; Cold Turkey Pro mira la URL en el navegador. |
| **Antivirus de terceros con cortafuegos** (McAfee, Norton) | Desactiva el Cortafuegos de Windows: **las reglas del cortafuegos no se aplican**. | Revisa el aviso del programa y de la comprobación. Las demás capas (DNS, hosts, directivas, cuenta) siguen funcionando. |
| **Router del operador que intercepta el DNS** (por ejemplo el "DNS Seguro" de algunos routers de Vodafone y Lowi) | El PC pregunta a CleanBrowsing, pero contesta el router del operador sin filtro. La comprobación lo detecta: sale **FALLO** en "CleanBrowsing bloquea el dominio de prueba". | Desactivar esa función en el router (guía `router/`). En Windows 11, la opción `-DohWindows11` cifra el DNS y el router ya no puede contestar en su lugar. Mientras tanto, el `hosts` y las directivas siguen funcionando. |
| **Wifi pública con "portal cautivo"** (hoteles, trenes) o redes que bloquean DNS externos | Con el DNS fijo y el puerto 53 bloqueado, puede que la página de acceso no cargue o que no haya internet. | Usa el punto de acceso de tu móvil, que ya va filtrado. |
| **Otros aparatos** (tablet, consola, tele) | Esta capa solo protege este PC. | El router y la capa del móvil. |
| **Búsqueda/YouTube estrictos** | A veces ocultan contenido legítimo. | Es el precio de forzarlo; lo puedes revisar al renovar. |

Y recuerda: **si pierdes la llave** solo queda restablecer o reinstalar (de ahí la copia
de seguridad del principio).

---

## Lista de verificación final

- [ ] Hice copia de seguridad de mis archivos.
- [ ] Sé entrar en mi cuenta (contraseña de Microsoft o PIN).
- [ ] Tengo apuntada la clave de recuperación de BitLocker (si aplica).
- [ ] Hice el ensayo de la cápsula (carpeta `llaves/`).
- [ ] (Recomendado) Instalé y configuré **Cold Turkey Pro** con su propia llave, antes
      del paso de cuentas.
- [ ] Ejecuté `EJECUTAR-bloqueo.bat` y llegó hasta el final sin errores en rojo.
- [ ] Guardé la **llave de Windows** en la cápsula (texto cifrado en dos sitios) antes de
      escribir `PEGADA`.
- [ ] Cerré sesión y `EJECUTAR-comprobacion.bat` da **OK** en todas las capas.
- [ ] Apunté en mi nota de cápsulas qué llave abre qué y cuándo llega (sin escribir las
      llaves).

> Si en algún momento te agobias, recuerda: esto lo has montado para ayudarte. La salida
> de emergencia existe (restablecer el equipo) y las llaves llegan solas cuando toca.
> No es una jaula: solo has puesto distancia entre un impulso y un clic.
