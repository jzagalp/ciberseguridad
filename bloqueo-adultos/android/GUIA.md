# Capa Android: bloquear el contenido adulto en el móvil

Esta guía forma parte del kit para bloquear contenido adulto. Aquí está todo lo del **móvil Android**. Las llaves y las cápsulas del tiempo se explican en [`../llaves/`](../llaves/), el router en [`../router/`](../router/) y el PC en [`../windows/`](../windows/).

Vas a montar varias capas, una encima de otra. Ninguna es perfecta por sí sola, pero juntas hacen que saltárselas cueste mucho tiempo y mucho esfuerzo, que es justo lo que buscamos: que en un mal momento lo fácil sea **no** hacerlo.

> **Sé realista:** ningún bloqueo es 100 % infalible. Al final de la guía tienes la lista de huecos que quedan y qué capa cubre cada uno. Esa lista no está para desanimarte: está para que sepas dónde reforzar.

---

## Índice

1. [Antes de empezar](#antes-de-empezar)
2. [Las capas de un vistazo](#las-capas-de-un-vistazo)
3. [El recorrido recomendado, en orden](#el-recorrido-recomendado-en-orden)
4. [Nivel 1: ajustes del móvil (sin PC)](#nivel-1-ajustes-del-móvil-sin-pc)
5. [Nivel 2: con el PC (script)](#nivel-2-con-el-pc-script)
6. [Nivel 3: app bloqueadora (AppBlock en modo estricto)](#nivel-3-app-bloqueadora-appblock-en-modo-estricto)
7. [¿Y el nivel 4? Por qué no está en este kit](#y-el-nivel-4-por-qué-no-está-en-este-kit)
8. [Las llaves del móvil](#las-llaves-del-móvil)
9. [Cómo deshacerlo (cuando llegue la llave)](#cómo-deshacerlo-cuando-llegue-la-llave)
10. [Huecos que quedan y qué capa los cubre](#huecos-que-quedan-y-qué-capa-los-cubre)
11. [Prueba que funciona: lista de verificación final](#prueba-que-funciona-lista-de-verificación-final)
12. [Problemas frecuentes](#problemas-frecuentes)
13. [Datos técnicos y fuentes](#datos-técnicos-y-fuentes)

---

## Antes de empezar

**Necesitas:**

- El móvil cargado (más del 50 %) y desbloqueado.
- Un PC con Windows y un **cable USB de datos** (algunos cables solo cargan).
- Entre 1 hora y media y 2 horas y media sin prisas (incluye comprar y configurar AppBlock y hacer las cápsulas).
- Tus **cápsulas del tiempo preparadas** (ver [`../llaves/`](../llaves/)). Para el móvil necesitarás entre 1 y 3 llaves, y cada una es distinta.
- Si vas a usar AppBlock (nivel 3), una forma de pago para su versión Premium.
- **En Xiaomi, Redmi y POCO:** la **cuenta Xiaomi** iniciada en el móvil (y a veces una SIM con datos). La pide el permiso "Depuración USB (ajustes de seguridad)" del nivel 2; sin él, el script no puede poner el DNS ni teclear las llaves. Si no tienes cuenta Xiaomi, créala antes de empezar.

**Haz esto primero (de verdad):**

1. **Copia de seguridad completa** del móvil: fotos, WhatsApp y lo que sea importante. Ningún paso de esta guía borra el móvil, pero si algún día perdieras una llave, la salida de emergencia es restablecerlo de fábrica.
2. **Comprueba que sabes la contraseña de tu cuenta de Google** (la tuya de siempre, no una llave). Tras un restablecimiento de fábrica el móvil la pide para dejarte entrar. Si no la recuerdas, cámbiala ahora en otro dispositivo (hazlo con unos días de margen: justo después de cambiarla, Google puede no aceptarla para eso). En **Samsung** y **Xiaomi** puede pedir además la contraseña de tu **cuenta Samsung** o **cuenta Xiaomi** (si tienes activado "Encontrar mi móvil" o "Buscar dispositivo"): compruébala también.
3. **Mira qué Android tienes:** Ajustes > **Información del teléfono** > **Versión de Android** (en Samsung: Información del teléfono > **Información de software**). Te hará falta para saber qué pasos te tocan.
4. **Si vas a montar también la capa de Windows** (con la cuenta de administrador cerrada con llave), haz **antes** el nivel 2 de esta guía: instalar el controlador USB del móvil puede pedir permisos de administrador.

> **Truco que vale para todo:** si no encuentras un menú, abre Ajustes y escribe su nombre en el **buscador** de arriba (por ejemplo, "DNS privado"). Los nombres cambian un poco según la marca y la versión.

---

## Las capas de un vistazo

| Capa | Qué hace | ¿La puedes quitar en un mal momento? | Llave |
|---|---|---|---|
| **DNS privado** (CleanBrowsing Family Filter) | Bloquea webs para adultos, de proxy y VPN y de contenido mixto (como Reddit) en todo el móvil, con wifi y con datos. Fuerza SafeSearch en Google y Bing y el modo restringido (moderado) de YouTube | Sí, desde Ajustes, salvo que AppBlock bloquee los Ajustes | No |
| **Chrome con "DNS seguro" = CleanBrowsing** | Redundancia: Chrome sigue filtrando aunque quites el DNS privado | Sí (es solo redundancia) | No |
| **Un solo navegador (Chrome)** y sin apps de riesgo | Quita navegadores con VPN o DNS propio y apps cuyo contenido no pasa por el filtro (X, Reddit, Telegram...) | Reinstalarlas es posible, pero AppBlock bloquea las apps nuevas o reinstaladas | No |
| **Controles parentales de Android 17** (o PIN de Play en Android 16 o anterior) | Bloquea sitios explícitos en Chrome, filtra búsquedas, bloquea apps y limita por edad lo que se instala desde Play | No sin el PIN | **Sí** |
| **AppBlock en modo estricto** | Filtro adulto propio, bloquea apps, impide su desinstalación y el acceso a ciertos ajustes | No hasta que acabe el temporizador (o con el PIN), salvo con su desbloqueo de emergencia (ver nivel 3) | Temporizador o **llave** |
| **Router** (otra carpeta) | Filtra todo lo que pasa por la wifi de casa | Ver [`../router/`](../router/) | Sí |

---

## El recorrido recomendado, en orden

El orden importa: algunas capas cierran la puerta a cambios posteriores. Ve marcando:

- [ ] **0.** Copia de seguridad y cápsulas preparadas ([Antes de empezar](#antes-de-empezar)).
- [ ] **1.** Nivel 1 en el móvil: DNS privado (1.1), Chrome (1.2), SafeSearch y YouTube (1.3), quitar apps de Google Play (1.4), quitar espacios extra (1.5).
- [ ] **2.** Nivel 2 en el PC: activar la depuración USB (2.2) y ejecutar `EJECUTAR-movil.bat`, **opción 1** (2.4).
- [ ] **3.** Instalar y preparar AppBlock (nivel 3, pasos 1 a 4), **sin** activar todavía el modo estricto. Va antes que el paso 4 por si los Controles parentales te pidieran después el PIN para instalar o comprar apps.
- [ ] **4.** Controles parentales de Android 17 (1.6) **o** PIN de Google Play (1.7), metiendo el PIN con la **opción 2** del script (2.5). **No pulses Intro al final del script hasta haber dejado configurado todo** (filtros, edad de Play...): mientras no termine, puede volver a teclear el PIN si el móvil te lo pide otra vez (opción T). Después lo olvida y solo lo recuperarás al abrir la cápsula.
- [ ] **5.** **Opción 3** del script (Comprobar): confirma que solo queda Chrome y que no hay espacios extra.
- [ ] **6.** Cerrar, según la variante de AppBlock que elijas (nivel 3, paso 5):
   - **Variante A (temporizador, recomendada):** primero la **opción 4** del script (apagar la depuración USB, 2.6); en Samsung, vuelve a activar el Bloqueador automático; y por último activa el modo estricto de AppBlock.
   - **Variante B (PIN con llave):** activa el modo estricto de AppBlock metiendo el PIN con la **opción 2** del script y, justo después, la **opción 4**.
   - **Sin AppBlock:** solo la **opción 4** y, en Samsung, vuelve a activar el Bloqueador automático. Ten en cuenta que, sin AppBlock, el DNS privado se puede quitar desde Ajustes.
- [ ] **7.** [Lista de verificación final](#prueba-que-funciona-lista-de-verificación-final).

---

## Nivel 1: ajustes del móvil (sin PC)

### 1.1 DNS privado con CleanBrowsing

El "DNS" es la guía telefónica de internet: traduce nombres de webs a direcciones. Si la guía no tiene una web, el móvil no la encuentra. **CleanBrowsing Family Filter** es una guía que no incluye webs para adultos y es gratuita (no necesita cuenta).

Necesitas **Android 9 o superior**. El nombre que vas a escribir es siempre este, sin `https://` y sin espacios:

```
family-filter-dns.cleanbrowsing.org
```

**Pixel y Android "puro" (Motorola, Nokia y otros):**

1. Ajustes > **Redes e Internet** > **DNS privado**. (En algunos móviles antiguos está dentro de "Avanzado".)
2. Elige **"Nombre de host del proveedor de DNS privado"**.
3. Escribe `family-filter-dns.cleanbrowsing.org`.
4. Pulsa **Guardar**.

**Samsung (One UI):**

1. Ajustes > **Conexiones** > **Más ajustes de conexión** > **DNS privado**.
2. Elige **"Nombre de host del proveedor de DNS privado"** (según la versión pone "de" o "del").
3. Escribe `family-filter-dns.cleanbrowsing.org` y pulsa **Guardar**.

**Xiaomi, Redmi y POCO:**

- HyperOS: Ajustes > **Más opciones de conectividad** > **DNS privado**.
- MIUI: Ajustes > **Conexión y compartir** > **DNS privado**.
- Si no lo ves, usa el buscador de Ajustes: escribe "DNS privado".
- Elige "Nombre de host del proveedor de DNS privado", escribe el nombre y guarda.

**Cualquier otra marca:** busca "DNS privado" en Ajustes.

Qué debes saber:

- Se aplica a todo el móvil: wifi, datos móviles y también los demás usuarios del móvil.
- **Si en una wifi te quedas sin internet** y ves "No se ha podido acceder al servidor DNS privado", esa red bloquea este tipo de DNS (pasa en algunas wifis públicas). Usa los datos móviles mientras estés allí. No quites el DNS. Si te pasa con la **wifi de casa**, revisa que el router no bloquee el puerto 853 (el que usa el DNS privado; ver [`../router/`](../router/)).
- **Respaldo**: si un día CleanBrowsing dejara de funcionar en todas las redes (no solo en una wifi), puedes poner temporalmente `family.cloudflare-dns.com` (Cloudflare for Families). Filtra contenido adulto, pero no bloquea webs de VPN ni fuerza el modo restringido de YouTube, así que vuelve a CleanBrowsing en cuanto puedas.
- Ojo: esta capa **sola** se puede quitar desde la misma pantalla o restableciendo los ajustes de red ("Restablecer Wi-Fi, red móvil y Bluetooth" o, según la versión, "Restablecer ajustes de red móvil" / "Restablecer Bluetooth y Wi-Fi"). Por eso hay más capas.

### 1.2 Chrome: DNS seguro y navegador predeterminado

Chrome será **el único navegador** del móvil. Vamos a decirle que también use CleanBrowsing, por si alguien cambia el DNS privado.

1. Abre **Chrome** > menú **⋮** (arriba a la derecha) > **Configuración**.
2. **Privacidad y seguridad** > **Usar DNS seguro**.
3. Elige **"Elegir otro proveedor"** y, en la lista, **"CleanBrowsing (Family Filter)"**.

Haz que Chrome sea el navegador predeterminado:

- Pixel y Android puro: Ajustes > **Aplicaciones** > **Aplicaciones predeterminadas** > **Aplicación de navegador** > Chrome.
- Samsung: Ajustes > **Aplicaciones** > **Elegir aplicaciones predeterminadas** (o "Aplicaciones predeterminadas") > **Navegador** > Chrome.
- Xiaomi y otras: busca "predeterminadas" en Ajustes.

> Por qué Chrome y no otro: es el navegador que integra mejor los filtros de Android (Controles parentales) y el que usan las demás apps para abrir enlaces. **No lo desinstales.**

Sobre el **modo incógnito**: en Android no se puede desactivar sin herramientas de empresa, pero no pasa nada grave. El incógnito no se salta el DNS: solo evita que quede historial.

### 1.3 SafeSearch y YouTube (redundancia)

CleanBrowsing ya fuerza SafeSearch y el modo restringido de YouTube desde el DNS. Esto es una segunda capa por si acaso:

1. **SafeSearch:** en Chrome, entra en `https://www.google.com/safesearch` y elige **Filtrar**.
2. **YouTube:** en la app, toca tu foto de perfil > **Configuración** > **General** > activa **Modo restringido**.

Una cuenta personal de adulto no puede "bloquear" estos ajustes: los puedes volver a quitar. Lo que de verdad los mantiene es el DNS, los Controles parentales (1.6) y AppBlock.

### 1.4 Quitar navegadores y apps de riesgo (desde Google Play)

Deja **solo Chrome**. Los demás navegadores son un hueco: algunos traen **VPN integrada** (Opera) o permiten un **DNS propio** (Firefox), y así se saltan el filtro.

1. Abre **Play Store** > toca tu foto de perfil > **Gestionar aplicaciones y dispositivo** > pestaña **Gestionar**.
2. Marca y desinstala:
   - **Navegadores:** Firefox, Opera, Opera Mini, Edge, Brave, DuckDuckGo, Tor Browser, UC Browser, Kiwi, Vivaldi, Chrome Beta/Dev/Canary...
   - **Apps de riesgo:** Reddit, X (Twitter), Telegram, Tumblr, Discord. Bluesky y Snapchat, a tu criterio. Su contenido viene de sus propios servidores y el DNS no lo filtra por contenido.
   - **Apps de VPN y "tiendas" alternativas** (F-Droid, APKPure, Uptodown, Aurora Store...).
3. Si alguna app tiene algo que te importa (chats, fotos), guárdalo antes.

Navegadores que vienen de fábrica:

- **Samsung Internet:** Ajustes > **Aplicaciones** > Samsung Internet > **Desactivar**.
- **Mi Browser** (Xiaomi) y otros que no se dejan quitar: el script del nivel 2 los quita por ti.

### 1.5 Quitar espacios extra y usuarios

Las apps bloqueadoras **no funcionan** dentro de otros usuarios o espacios aparte, así que conviene borrarlos. **Antes, saca lo que tengas dentro**: borrarlos borra su contenido.

- **Pixel:** **Espacio privado** (Ajustes > Seguridad y privacidad > Espacio privado > eliminar).
- **Samsung:** **Carpeta Segura** (búscala en Ajustes; dentro de sus ajustes, "Más ajustes" > **Desinstalar**) y **Dual Messenger** (Ajustes > Funciones avanzadas > Dual Messenger: desactívalo para cada app).
- **Xiaomi:** **Segundo espacio** y **Aplicaciones duales** (búscalos en Ajustes y elimínalos).
- **Usuarios e invitado** (todas las marcas): busca "Usuarios" o "Varios usuarios" en Ajustes, borra los usuarios que no sean el tuyo y desactiva "Permitir varios usuarios" si aparece.
- **Perfil de trabajo:** si lo tienes por tu empresa, déjalo; es otro mundo y lo gestiona tu empresa.

Los nombres exactos cambian por versión: si no los ves, usa el buscador de Ajustes. El script del nivel 2 te avisa si quedan espacios extra.

### 1.6 Controles parentales del sistema (Android 17, y Pixel con Android 16)

Es la capa gratuita más sólida que trae Android. **No necesita cuenta de Google ni mentir sobre tu edad**: es un PIN del propio móvil. Si tu móvil todavía no la tiene, salta a 1.7.

> **Importante:** el PIN tiene que ser una **llave** (ver [Las llaves del móvil](#las-llaves-del-móvil)) y se mete con el PC, sin que lo veas (nivel 2, opción 2). **Sin cuenta de recuperación, si pierdes el PIN la única salida es restablecer el móvil de fábrica.** Por eso: guarda la llave en **dos cápsulas**.

1. Ten preparadas las dos cápsulas y el móvil conectado al PC con el script abierto (nivel 2).
2. En el móvil: Ajustes > **Controles parentales** (si no lo ves, búscalo en Ajustes).
3. Empieza la configuración. Cuando te pida **crear un PIN**, usa la **opción 2** del script > "PIN de Controles parentales (10 dígitos)" y sigue sus instrucciones.
4. Si te ofrece una **cuenta de recuperación**, **no la añadas** (elige omitir): con tu propia cuenta podrías quitar el PIN cuando quisieras.
5. Activa:
   - En **Filtros de contenido web**: **"Bloquear sitios explícitos"** y **"Filtrar resultados de la búsqueda explícitos"** (necesita una versión reciente de "Android System WebView": si no aparece, actualízala desde Play Store).
   - El **filtro de Google Play** por edad: **PEGI 12** (más estricto) o PEGI 16 si con 12 se te bloquea alguna app que necesitas. Ojo: casi todos los navegadores y VPN son aptos para todas las edades, así que este filtro **no** impide instalarlos; eso lo hace AppBlock.
   - El **bloqueo de apps**: cualquier navegador o app de riesgo que no hayas podido quitar.
6. Sal y vuelve a entrar en Controles parentales: debe pedirte el PIN. El script te ayuda a comprobarlo.

Haz los puntos 4 y 5 **antes de terminar la opción 2 del script**: si al guardar algún ajuste te vuelve a pedir el PIN, escribe **T** en el script para que lo teclee otra vez.

Ten en cuenta que "Bloquear sitios explícitos" hace que Chrome envíe las direcciones que visitas a Google para clasificarlas.

### 1.7 PIN de Google Play (Android 16 o anterior)

Si no tienes los Controles parentales de 1.6, pon al menos el PIN de Google Play. Es una capa **débil** (más abajo ves por qué), pero suma fricción.

1. Abre **Play Store** > foto de perfil > **Ajustes** > **Familia** > **Controles parentales** (en algunas versiones: "Restricciones de contenido" > "Ir a Controles parentales").
2. Actívalos. Cuando te pida **crear un PIN**, usa la **opción 2** del script > "PIN de Google Play (4 dígitos)".
3. **Aplicaciones y juegos**: elige **PEGI 12** (más estricto) o PEGI 16. Si te pide el PIN, escribe **T** en el script para que lo teclee.
4. **La prueba del script (paso 3):** Play no pide el PIN al volver a entrar, sino al intentar cambiar algo. Toca **Aplicaciones y juegos** como si fueras a cambiar la edad (**no toques el interruptor principal**: con el PIN se apagarían los controles), deja que el script teclee el PIN, deja la misma edad y vuelve atrás. Si los apagas sin querer, actívalos otra vez y usa la opción **T** del script para crear el PIN con la misma llave.

Su punto débil (lo dice Google): **borrar los datos de la app Play Store quita los controles y el PIN**. Además, no oculta apps en las búsquedas y solo tiene 4 dígitos. Lo cubre AppBlock (nivel 3), que impide entrar en esos ajustes.

### Por qué no usamos Family Link

Family Link es para menores: necesita que **otra persona adulta** supervise la cuenta y, a partir de los 14 años en España, la persona supervisada **puede dejar la supervisión cuando quiera**. Además obligaría a poner una edad falsa, cosa que este kit no hace nunca. No protege a un adulto, así que no lo usamos.

---

## Nivel 2: con el PC (script)

### 2.1 Qué hace el script (y qué no)

`EJECUTAR-movil.bat` abre un menú con estas opciones:

| Opción | Qué hace |
|---|---|
| **1) Configurar** | Pone el DNS privado de CleanBrowsing y lo comprueba leyéndolo de vuelta. Busca **todos** los navegadores (aunque no estén en ninguna lista), apps de riesgo, tiendas alternativas y apps de VPN, y te pregunta una por una si quitarlas o desactivarlas. Chrome no se toca nunca, ni tampoco las apps del sistema necesarias (Ajustes, Play, WebView, teclado, pantalla de inicio...). Te avisa si hay espacios extra |
| **2) Meter una llave** | Genera un PIN o una contraseña al azar, te la copia para pegarla en tu cápsula **sin mostrarla**, vacía el portapapeles y la teclea en el móvil por el cable. Después comprueba que la llave abre. Cada vez que la usas crea una llave **nueva** |
| **3) Comprobar** | Te enseña cómo está el móvil. No cambia nada |
| **4) Terminar** | Apaga la depuración USB y las opciones para desarrolladores y, si quieres, borra la autorización de este PC |
| **5) Deshacer** | Revierte lo que hizo la opción 1, usando el registro |

Todo lo que cambia queda anotado en `registro-movil.log`, junto al script. Las llaves **nunca** se escriben en el registro ni salen en pantalla. La primera vez, el script descarga las herramientas oficiales de Google (platform-tools) en una subcarpeta.

Lo que **no** hace: no da permisos especiales a ninguna app, no borra tus datos personales y no instala nada en el móvil.

> El nivel 2 **añade fricción, no es un candado**: lo que quita el script se puede recuperar reinstalando desde la tienda. El candado lo ponen los Controles parentales y AppBlock.

### 2.2 Activar la depuración USB

**Pixel y Android puro:**

1. Ajustes > **Información del teléfono** > toca **Número de compilación** 7 veces (te pedirá tu PIN de pantalla).
2. Ajustes > **Sistema** > **Opciones para desarrolladores** > activa **Depuración por USB**.

**Samsung:**

1. Ajustes > **Información del teléfono** > **Información de software** > toca **Número de compilación** 7 veces.
2. Ajustes > **Opciones de desarrollador** > activa **Depuración de USB**.
3. **Bloqueador automático** (Ajustes > **Seguridad y privacidad** > **Bloqueador automático**): si está activado, bloquea los comandos por cable. **Desactívalo mientras usas el script.** En versiones recientes puede volver a activarse solo a los 30 minutos; si el script deja de ver el móvil, revísalo. Al terminar, **vuelve a activarlo**: también bloquea la instalación de apps desde fuera de las tiendas.

**Xiaomi, Redmi y POCO:**

1. Ajustes > **Sobre el teléfono** > toca 7 veces la versión del sistema: **"Versión de Xiaomi HyperOS"**, "Versión del SO" o "Versión de MIUI", según el modelo (si no la ves ahí, entra antes en "Especificaciones detalladas" o "Todas las especificaciones").
2. Ajustes > **Ajustes adicionales** > **Opciones de desarrollador** > activa **Depuración USB** y también **"Depuración USB (ajustes de seguridad)"**.
3. Esa segunda opción suele pedir tener la **cuenta Xiaomi** iniciada (y a veces una SIM con datos). Sin ella, el script no puede cambiar el DNS ni teclear llaves.

### 2.3 Primera conexión

1. Si descargaste el kit como ZIP, **descomprímelo** antes (no lo ejecutes desde dentro del ZIP).
2. Conecta el móvil al PC con el cable. Si el móvil pregunta qué hacer con el USB, elige **"Transferencia de archivos"**.
3. Haz doble clic en **`EJECUTAR-movil.bat`**. Si Windows muestra "Windows protegió su PC", pulsa **Más información** > **Ejecutar de todas formas**.
4. En el móvil aparecerá **"¿Permitir depuración por USB?"**: pulsa **Permitir**.
5. Si el script no ve el móvil, sigue sus indicaciones. Puede faltar el controlador:
   - Pixel: [Google USB Driver](https://developer.android.com/studio/run/win-usb).
   - Samsung: [Samsung Android USB Driver](https://developer.samsung.com/galaxy/others/android-usb-driver-for-windows).
   - Otras marcas: [lista de controladores de fabricantes](https://developer.android.com/studio/run/oem-usb).

### 2.4 Opción 1: configurar

1. Elige **1** en el menú.
2. Acepta poner el DNS privado. El script lo lee de vuelta para comprobarlo y prueba que el móvil sigue teniendo internet.
3. Te enseña la lista de apps encontradas. Para cada una puedes elegir:
   - **Q (quitar):** recomendado. Se quita para tu usuario. Se recupera con "Deshacer" o reinstalándola desde la tienda.
   - **D (desactivar):** se oculta. Es más fácil de revertir (y de saltarse): desde Ajustes > Aplicaciones > Activar.
   - **N (no tocar).**
4. Si una app de la lista es **tu app bloqueadora** o una VPN que necesitas para trabajar, responde **N**. (El script ya excluye AppBlock y la app de CleanBrowsing, y las apps de VPN te las pregunta una a una aunque elijas "quitar todas".)
5. Si el script dice que no puede escribir el registro, mueve la carpeta del kit, descomprimida, a `C:\KitBloqueo`: sin registro no cambia nada, para que siempre se pueda deshacer.

### 2.5 Opción 2: meter una llave sin verla

Úsala para el PIN de Controles parentales (1.6), el PIN de Play (1.7) y, si eliges esa variante, el PIN de AppBlock (nivel 3).

Antes de empezar, en el PC:

- **Desactiva el historial del portapapeles**: Configuración > Sistema > **Portapapeles** > "Historial del portapapeles" en Desactivado (y "Compartir entre dispositivos" también). El script ya copia la llave marcada como "no guardar en el historial ni sincronizar", pero mejor asegurarse.
- Si usas **Enlace Móvil** (Phone Link), desactiva **"Copiar y pegar entre dispositivos"** (Configuración > Bluetooth y dispositivos > Dispositivos móviles, o en la app Enlace Móvil > Configuración > Características). En Samsung, también en el móvil: **Vincular a Windows** > "Sincronizar portapapeles" desactivado. Si no, la llave podría acabar en el móvil.
- Si usas algún programa que guarda lo que copias (un "gestor de portapapeles"), ciérralo.
- **No cierres la ventana del script con la X** mientras haya una llave en el portapapeles. Si tuvieras que hacerlo, copia antes cualquier palabra para sustituirla.

Los pasos (el script te guía en cada uno):

1. Elige qué llave es: PIN de Controles parentales (10 dígitos), PIN de Play (4 dígitos), PIN de otra longitud o contraseña de letras y números (16 caracteres).
2. **Paso 1, cápsula:** la llave está en el portapapeles. Haz la cápsula en Timevault como explica [`../llaves/GUIA.md`](../llaves/GUIA.md#si-la-llave-la-crea-otro-programa-del-kit): primero la fecha, después tu etiqueta y la llave con **Ctrl+V**, y guarda el texto cifrado en dos sitios. Hazlo sin pararte a leerla. Escribe `LISTO`. Te ofrecerá una **segunda cápsula** (muy recomendable para el PIN de Controles parentales, con la fecha una semana más tarde). Después vacía el portapapeles.
3. **Paso 2, móvil:** abre en el móvil la pantalla donde se crea el PIN y toca el campo. Pulsa Intro en el PC: el script borra lo que hubiera en el campo y teclea la llave. Comprueba que salen **tantos puntos como te dice**. Si en vez de puntos salen números a la vista (por ejemplo, porque el cursor estaba en un buscador), no los mires: responde C, bórralos y vuelve a empezar con una llave nueva. Si salen **menos** puntos, ese campo no admite tantos dígitos: responde C, sal **sin guardar** y vuelve a empezar con "PIN de otra longitud" más corto. Si te pide confirmarla, el script la teclea otra vez. Mientras tanto, el script oculta "Mostrar contraseñas" en el móvil para que no se vea ni el último carácter, y luego lo deja como estaba (si no puede, te avisa: entonces no mires la pantalla del móvil mientras teclea).
4. **Paso 3, prueba:** sal de esa pantalla y vuelve a entrar. Cuando te pida el PIN, el script lo teclea y te pregunta si te ha dejado entrar (tienes que responder S o N). **No te saltes esta prueba.** (En el PIN de Play, la prueba es distinta: mira el punto 4 de 1.7.)
5. **Al final**, el script te deja pedirle que teclee **la misma llave** otra vez (opción T). Sirve, por ejemplo, si el móvil te vuelve a pedir el PIN para guardar un ajuste (filtros, edad de Play) o si al probar el PIN de AppBlock se desactivó el modo estricto y tienes que volver a activarlo. **Antes de pulsar Intro, deja configurado todo lo que protege esa llave**: cuando pulses Intro, el script la olvida para siempre y solo la recuperarás al abrir la cápsula.

### 2.6 Opción 4: terminar

Cuando ya hayas metido todas las llaves:

1. Elige **4**. El script apaga la depuración USB y las opciones para desarrolladores, y te ofrece borrar la autorización de este PC (como "Revocar autorizaciones de depuración USB").
2. En Samsung, vuelve a activar el **Bloqueador automático**.
3. Comprueba en Ajustes que "Opciones para desarrolladores" ya no aparece.

---

## Nivel 3: app bloqueadora (AppBlock en modo estricto)

### Por qué AppBlock

Casi todas las apps "de control" están pensadas para que otra persona tenga la contraseña. Como aquí el bloqueo lo pones tú, necesitas una app que se pueda cerrar **con un temporizador** o **con un PIN que tú no conozcas**. Esta es la comparativa (precios aproximados en dólares; mira el precio en euros en Google Play):

| App | ¿Sirve sin otra persona? | Por qué |
|---|---|---|
| **AppBlock** (MobileSoft) | **Sí, la elegida** | Modo estricto con **temporizador** (la cápsula viene integrada) o con PIN. Premium: unos 30 $/año o 90 $ para siempre |
| App de CleanBrowsing (de pago) | Sí, como alternativa | Vigila que nadie cambie el DNS privado; PIN irrecuperable. Pero su panel web se recupera por email (ese correo tendría que ser también una llave). Unos 9 $/mes o 75 $/año |
| BlockerX, Covenant Eyes | No | Solo se desbloquean con un "compañero" o "aliado" |
| Qustodio, Kaspersky Safe Kids, Norton Family, Canopy | Mal | Son para perfiles infantiles (piden año de nacimiento) y la contraseña se recupera por email |
| Family Link | No | Ver [Por qué no usamos Family Link](#por-qué-no-usamos-family-link) |

No instales **dos apps que usen VPN** a la vez: Android solo permite una VPN activa.

### Pasos

Los nombres exactos de los menús de AppBlock cambian con las versiones; entre paréntesis tienes cómo aparecen en su ayuda en inglés.

1. Instala **AppBlock** (de MobileSoft) desde Google Play y hazte **Premium** (el bloqueo de contenido para adultos y el de apps recién instaladas son de pago).
2. Concede los permisos que pida, sobre todo **Accesibilidad** (Ajustes > Accesibilidad > "Aplicaciones descargadas", "Aplicaciones instaladas" o "Servicios descargados", según la marca > AppBlock > activar). Sin ese permiso no puede leer las direcciones de las webs. Si te pide más permisos (por ejemplo, **batería sin restricciones** o, en Xiaomi, **Inicio automático**), dáselos ahora: sin ellos el sistema puede cerrar AppBlock, y con el modo estricto ya no podrás entrar en Ajustes para darlos.
3. Crea un bloqueo que esté **siempre activo** (todos los días, todo el día) con:
   - en sus **opciones extra** (Extra options), el **bloqueo de contenido para adultos** (Adult content blocking) activado. La primera vez, deja AppBlock abierto hasta que su base de datos cargue al 100 %;
   - en esas mismas opciones extra, **añadir las apps recién instaladas** (Add newly installed apps): así se bloquea cualquier app que instales a partir de ahora;
   - los **navegadores** que no hayas podido quitar (todos menos Chrome);
   - las **apps de riesgo** y las tiendas alternativas que queden;
   - si no las usas, también **Galaxy Store** (Samsung) o **GetApps** (Xiaomi): desde ellas se pueden instalar navegadores sin pasar por los controles de Google Play.
4. Prepara el **modo estricto** (Strict mode) con estas opciones:
   - **Impedir la desinstalación de AppBlock** (Disable AppBlock uninstalling): le pedirá ser "administrador del dispositivo"; acéptalo.
   - **Bloquear los ajustes del dispositivo** (Block device settings). Bloquea la app Ajustes durante todo el plazo. Según su ayuda, AppBlock tiene una opción para dejar accesibles algunos ajustes, como la wifi y el Bluetooth (Show Available Settings), que solo se puede cambiar con el modo estricto apagado. Si la activas, comprueba después que desde ahí no llegas a la pantalla de DNS privado.
   - **Bloquear las apps reinstaladas** (Block reinstalled applications).
5. Elige cómo se desbloquea y actívalo:
   - **Variante A, temporizador (recomendada):** 30 días. No necesitas llave: el propio temporizador es la cápsula. Cuando acabe, lo renuevas. Su punto débil es el desbloqueo de emergencia, rápido la primera vez (ver "Cosas que debes saber", más abajo).
     1. **Antes de activarlo**, haz la **opción 4** del script (2.6) y, en Samsung, vuelve a activar el Bloqueador automático: después puede que AppBlock no te deje entrar en Ajustes, y eso es justo lo que queremos.
     2. Activa el modo estricto con el temporizador.
   - **Variante B, PIN con llave:** guárdalo en una cápsula de 30 a 90 días.
     1. Con el móvil todavía conectado, activa el modo estricto y, cuando AppBlock pida el PIN, usa la **opción 2** del script. Si el teclado del PIN solo tiene números, elige "PIN de otra longitud"; si admite letras, "contraseña de letras y números". En la prueba (paso 3 del script), si al meter el PIN AppBlock **desactiva** el modo estricto, vuelve a activarlo y usa la opción **T** del script para meter la misma llave.
     2. Justo después, haz la **opción 4** del script. Funciona por cable aunque AppBlock ya bloquee los Ajustes.
     3. En Samsung, activa el Bloqueador automático si AppBlock te deja entrar en Ajustes; si no te deja, no pasa nada: la depuración USB ya está apagada.

Cosas que debes saber:

- **No actives la "Protección avanzada"** de Android 17: retira el permiso de Accesibilidad a apps como AppBlock y la deja sin efecto. (Y si un día alguien la activa, esa es una forma de saltársela: AppBlock lo dificulta bloqueando los ajustes.)
- AppBlock tiene un **"desbloqueo de emergencia"** (Emergency unblocking) que no se puede desactivar. Es tu válvula de seguridad si algo sale mal y, a la vez, un hueco, y **depende de la variante**:
  - **Con temporizador (variante A)** se pide desde la propia app (Perfil > Ayuda > Contactar con soporte > Desbloqueo de emergencia; en su ayuda en inglés, Profile > Help > Contact support > Emergency unblocking). Según su ayuda, **la primera vez es un trámite corto** (unas preguntas en la app, sin esperar al soporte); las siguientes, cada vez más difícil (más espera y reescribir un texto largo).
  - **Con PIN (variante B)** hay que escribir al soporte, que manda un código de un solo uso (dicen que responden en hasta 24 horas). Es más lento, así que pone más fricción.
- En **modo seguro** de Android, AppBlock no funciona (el DNS privado sí).
- **Antes de activar el modo estricto, instala y configura lo que vayas a necesitar ese mes** (apps del banco, del trabajo, de transporte...) y deja hechos los ajustes que preveas (wifi del trabajo, emparejar auriculares). Durante el plazo, las apps nuevas quedan bloqueadas y Ajustes también. Según AppBlock, algunas apps de banca o de pago pueden fallar con los ajustes bloqueados: compruébalas nada más activarlo y, si falla una imprescindible, usa el desbloqueo de emergencia (abajo) y vuelve a activarlo sin "Bloquear los ajustes del dispositivo".
- Con los ajustes bloqueados **no podrás cambiar el DNS privado** hasta que acabe el bloqueo. Si un día CleanBrowsing fallara en todas las redes, el móvil se quedaría sin internet (las llamadas y los SMS siguen funcionando) hasta que acabe el temporizador o uses el desbloqueo de emergencia. Por eso conviene empezar con 30 días y no con plazos más largos.

---

## ¿Y el nivel 4? Por qué no está en este kit

Existe un nivel más: convertir una app en **"propietaria del dispositivo"** (Device Owner) por cable. Desde ahí se pueden bloquear de verdad el DNS privado, las VPN, el modo seguro, añadir usuarios, la depuración USB y el restablecimiento desde Ajustes, y forzar ajustes en Chrome (sin incógnito, SafeSearch obligatorio).

**No lo incluimos a propósito**, porque para una persona no técnica el riesgo supera al beneficio:

- Exige **quitar todas las cuentas del móvil** (Google, Samsung, Xiaomi, WhatsApp...) y todos los espacios extra antes de activarlo.
- En **Samsung**, con una app propietaria de terceros algunos servicios de Samsung pueden dejar de funcionar, y la única solución conocida es restablecer de fábrica.
- En **Xiaomi** hay requisitos extra de cuenta y permisos.
- Si bloqueas la depuración USB y pierdes la llave, la **única salida es borrar el móvil** desde el modo recovery.
- Si se quita la app propietaria sin desmontar antes cada restricción, **algunas pueden quedarse puestas** y solo se van restableciendo de fábrica.
- Las apps disponibles o no tienen contraseña (TestDPC, que trae un botón para quitarse a sí misma) o son proyectos de un solo desarrollador con huecos conocidos (OwnDroid) y se instalan fuera de Google Play.

Con los niveles 1 a 3 bien hechos, más el router de casa, la protección es alta y siempre tienes una forma segura de volver atrás. Si en el futuro tienes conocimientos técnicos y quieres ir más allá, la opción menos mala sería OwnDroid en un Pixel, con copia de seguridad completa y después de ensayar cómo deshacerlo.

---

## Las llaves del móvil

Cada capa usa **una llave distinta**. Cómo funcionan las cápsulas y cuál elegir está en [`../llaves/`](../llaves/).

| Capa | Tipo de llave | Cómo se mete | Cápsula | Si la pierdes |
|---|---|---|---|---|
| Controles parentales (Android 17) | PIN de 10 dígitos | Opción 2 del script | **Dos cápsulas**, 30–90 días | Restablecer de fábrica (pierdes los datos que no estén en la copia) |
| PIN de Google Play (Android 16 o anterior) | PIN de 4 dígitos | Opción 2 del script | 30–90 días | Ajustes > Aplicaciones > Google Play Store > Almacenamiento > Borrar datos |
| AppBlock, variante A | Temporizador | En la propia app | El temporizador (30 días) | Esperar a que acabe |
| AppBlock, variante B | PIN o contraseña | Opción 2 del script | 30–90 días | Desbloqueo de emergencia del soporte de AppBlock, o restablecer de fábrica |
| App de CleanBrowsing (si la usas) | Contraseña de letras y números | Opción 2 del script | 30–90 días | Soporte de CleanBrowsing |

Reglas de oro:

- La llave **no se lee ni se memoriza**: se pega en la cápsula y punto.
- Si una app permite **recuperar la contraseña por email**, la llave no sirve de nada salvo que ese correo tenga también su propia llave. Por eso descartamos las apps que funcionan así.
- Cuando llegue la llave y quieras renovar el bloqueo, crea **una llave nueva** (opción 2) y una cápsula nueva.

---

## Cómo deshacerlo (cuando llegue la llave)

Hazlo **en este orden**: si no, una capa vuelve a bloquear lo que quites con otra.

1. **AppBlock:**
   - Variante A: espera a que acabe el temporizador.
   - Variante B: abre AppBlock, desactiva el modo estricto con la llave.
   - Después ya puedes cambiar sus bloqueos o desinstalarla (si hace falta, quita antes su permiso de administrador: busca "administración del dispositivo" en Ajustes y desactiva AppBlock).
2. **Controles parentales (Android 17):** Ajustes > Controles parentales > **Gestionar PIN de controles parentales** > mete el PIN > **Eliminar PIN** (apaga todos los controles a la vez; el nombre exacto puede variar un poco).
   **PIN de Play:** Play Store > Ajustes > Familia > Controles parentales > desactívalos con el PIN.
3. **Lo que hizo el script:** activa otra vez la depuración USB (2.2), conecta el móvil y abre `EJECUTAR-movil.bat` > **opción 5 (Deshacer)**. También puedes lanzarlo así: `EJECUTAR-movil.bat -Deshacer`. Devuelve el DNS privado a como estaba antes y reinstala o reactiva las apps que se quitaron. Las apps que no se puedan recuperar así te las dirá: reinstálalas desde Google Play (o Galaxy Store / GetApps).
4. **Sin PC o sin el registro:**
   - DNS privado: Ajustes > DNS privado > **Automático**.
   - Apps desactivadas: Ajustes > Aplicaciones > (mostrar las del sistema) > la app > **Activar**.
   - Apps quitadas: reinstálalas desde la tienda.
5. **Chrome:** Configuración > Privacidad y seguridad > Usar DNS seguro > **"Usar proveedor de servicios actual"**.
6. SafeSearch y el modo restringido de YouTube: vuelve a las mismas pantallas de 1.3.
7. Al acabar, si no vas a volver a usar el script, apaga otra vez las opciones para desarrolladores.

**Si se pierde una llave** (la cápsula no llega, borraste el correo...):

- **Antes de nada, busca bien**: revisa la carpeta de spam y tu segunda cápsula.
- **AppBlock:** si era el temporizador, solo hay que esperar. Si era el PIN, escribe al soporte de AppBlock y pide el desbloqueo de emergencia.
- **Controles parentales de Android 17 sin cuenta de recuperación:** solo se quitan **restableciendo el móvil de fábrica**, que borra todo lo que no esté en tu copia de seguridad:
  - Si puedes entrar en Ajustes: busca "Restablecer" > **Volver al estado de fábrica (borrar todo)** (según la marca: "Borrar todos los datos" o "Restablecer valores de fábrica").
  - Si no: desde el **modo recovery** (se entra apagando el móvil y pulsando una combinación de botones que depende del modelo; búscala como "modo recovery" más el modelo de tu móvil).
  - Después te pedirá **tu cuenta de Google de siempre** (protección antirrobo). Por eso al principio te pedimos comprobar que sabes esa contraseña.
- **PIN de Play:** Ajustes > Aplicaciones > Google Play Store > Almacenamiento > **Borrar datos**.

Nada de este kit deja el móvil inservible: en el peor caso, el restablecimiento de fábrica siempre funciona.

---

## Huecos que quedan y qué capa los cubre

| Hueco | Qué pasa | Qué lo cubre |
|---|---|---|
| Cambiar el DNS privado o restablecer los ajustes de red ("Restablecer Wi-Fi, red móvil y Bluetooth" o similar) | El DNS vuelve a "Automático" y deja de filtrar | AppBlock (bloquea los ajustes); Chrome sigue con su DNS seguro; Controles parentales ("Bloquear sitios explícitos") |
| Cambiar en Chrome el "DNS seguro" a otro proveedor | Chrome se salta el DNS del móvil | Controles parentales de Android 17; filtro adulto de AppBlock |
| Instalar otro navegador, una VPN o una app de proxy desde Google Play | Pueden saltarse el DNS (Opera trae VPN; Firefox, su propio DNS; Tor...) | CleanBrowsing bloquea muchas webs de VPN y proxy (no todas); AppBlock bloquea las apps nuevas o reinstaladas. El filtro por edad de Play **no** lo impide: casi todos son aptos para todas las edades |
| Instalar apps desde **Galaxy Store**, **GetApps** o un archivo APK descargado de una web | No pasan por los controles de Google Play | AppBlock (apps nuevas bloqueadas; bloquea también esas tiendas si no las usas); en Samsung, el Bloqueador automático impide instalar APK; Android pide el permiso "Instalar aplicaciones desconocidas", que está en los Ajustes que bloquea AppBlock |
| Webs que hacen de "proxy" (traductores web, archivos de páginas, proxies poco conocidos) | Muestran otra web a través de la suya | CleanBrowsing bloquea muchas; "Bloquear sitios explícitos" de los Controles parentales y el filtro de AppBlock miran la dirección real |
| Apps como X, Reddit, Telegram o Discord | Su contenido no pasa por el filtro (Telegram usa su propio sistema) | Desinstalarlas (1.4 y script) y que AppBlock bloquee su reinstalación |
| Redes sociales y mensajería que decidas conservar (Instagram, TikTok, WhatsApp...) | El DNS no ve las fotos y vídeos que circulan **dentro** de esas apps | Solo tu criterio: si alguna es un riesgo para ti, quítala o bloquéala con AppBlock |
| Navegadores dentro de otras apps (enlaces que se abren dentro de una app) | Usan el DNS del móvil, así que **sí** quedan filtrados | DNS privado |
| Otros usuarios, invitado, Espacio privado, Carpeta Segura, Segundo espacio, o un "perfil de trabajo" creado con apps como Island o Shelter | El DNS sigue aplicándose, pero las apps bloqueadoras no | Borrarlos (1.5); el script avisa si existen (opción 3); AppBlock bloquea las apps nuevas que los crean |
| Modo seguro | AppBlock se apaga; el DNS privado sigue | Ninguna capa de este kit lo cierra del todo (solo el nivel 4) |
| Protección avanzada de Android 17 | Quita el permiso de Accesibilidad a AppBlock | AppBlock (bloqueo de ajustes); no la actives |
| Borrar los datos de Play Store | Quita el PIN de Play | Controles parentales de Android 17; AppBlock |
| Cambiar la fecha o la zona horaria | Puede alterar los temporizadores | AppBlock (ajustes bloqueados) |
| Restablecer de fábrica | Lo borra todo, bloqueos incluidos | Nada lo impide, y está bien que sea así: es tu salida de emergencia. Cuesta mucho (pierdes datos y tiempo), y esa fricción es la protección |
| Desbloqueo de emergencia de AppBlock | Quita el modo estricto. Con temporizador, la primera vez es un trámite corto desde la propia app; con PIN, hay que esperar a que el soporte mande un código (hasta 24 h) | Nada lo impide: es tu válvula de seguridad. Cada vez que lo usas es más difícil; la variante B (PIN) da más fricción |
| Wifis que bloquean el DNS privado | Te quedas sin internet en esa red | Usa datos móviles; la app de pago de CleanBrowsing tiene un respaldo |
| Volver a activar la depuración USB y usar "Deshacer" desde un PC | Revierte lo que hizo el script | AppBlock (bloquea los Ajustes, que es donde se activa); en Samsung, el Bloqueador automático |
| Otro dispositivo (tablet, consola, el PC) | Este kit solo cubre el móvil | Router de casa ([`../router/`](../router/)) y la capa de Windows ([`../windows/`](../windows/)) |

---

## Prueba que funciona: lista de verificación final

Ninguna prueba requiere abrir webs para adultos. Hazlas con la wifi de casa **y** también con datos móviles (wifi apagada).

**DNS y navegador**

- [ ] Ajustes > DNS privado muestra `family-filter-dns.cleanbrowsing.org`.
- [ ] En Chrome, abre `reddit.com`: **no debe cargar** (CleanBrowsing Family bloquea las webs de contenido mixto; verás un error tipo "No se puede acceder a este sitio").
- [ ] En Chrome, abre `https://cleanbrowsing.org/dnsleaktest` y pulsa **"Run Extended Test"** (tarda unos 20 segundos): debe indicar que usas CleanBrowsing. Si salen los servidores de tu operador, el filtro no está actuando en Chrome.
- [ ] En Chrome: Configuración > Privacidad y seguridad > Usar DNS seguro = "CleanBrowsing (Family Filter)".
- [ ] En Google, intenta desactivar SafeSearch: no debería quedarse desactivado.
- [ ] En YouTube, el modo restringido debería aparecer activado y, normalmente, sin dejarte quitarlo.
- [ ] Repite la prueba de `reddit.com` con datos móviles.

**Apps**

- [ ] Abre el enlace de una web desde WhatsApp o el correo: solo debe ofrecer Chrome.
- [ ] En Play Store, busca otro navegador (por ejemplo, Firefox) e instálalo: AppBlock debe bloquearlo al intentar abrirlo. Después desinstálalo (si AppBlock no te deja, se quedará bloqueado, que también vale).
- [ ] La **opción 3 (Comprobar)** del script dijo "No quedan otros navegadores ni apps de riesgo activos" y que no hay espacios extra (paso 5 del recorrido).

**Candados**

- [ ] Entra en Ajustes > Controles parentales: **te pide el PIN** (o, en Android 16 o anterior, el PIN de Play en sus ajustes).
- [ ] Intenta desinstalar AppBlock: **no te deja**.
- [ ] Si activaste "Bloquear los ajustes del dispositivo", intenta llegar a la pantalla de DNS privado: AppBlock debe impedirlo.
- [ ] AppBlock sigue con el permiso de Accesibilidad activado (míralo en su propia app o, si puedes entrar, en Ajustes > Accesibilidad).
- [ ] La "Protección avanzada" está desactivada.

**Cierre**

- [ ] "Opciones para desarrolladores" ya no aparece en Ajustes.
- [ ] Samsung: el Bloqueador automático está activado (en la variante B de AppBlock, solo si te dejó entrar en Ajustes).
- [ ] Las cápsulas están programadas (mira la fecha y el destinatario **sin abrir la llave**). Para el PIN de Controles parentales, hay **dos**.
- [ ] Apunta en tu calendario la fecha de renovación (30–90 días).

---

## Problemas frecuentes

**"No se ha podido acceder al servidor DNS privado" / sin internet en una wifi**
Esa red bloquea el DNS privado. Usa los datos móviles mientras estés allí. Si es la wifi de casa, revisa que el router no bloquee el puerto 853. Si te pasa en **todas** las redes, también con datos, puede que CleanBrowsing tenga un problema: pon temporalmente `family.cloudflare-dns.com` (1.1) y vuelve a CleanBrowsing después. Si AppBlock no te deja entrar en Ajustes para cambiarlo: las llamadas y los SMS siguen funcionando; espera unas horas (estas caídas suelen ser cortas) y, si sigue igual, usa el desbloqueo de emergencia de AppBlock o espera a que acabe su temporizador.

**Una web normal que necesito no carga**
CleanBrowsing Family bloquea también webs de contenido mixto y de VPN o proxy. El filtro gratuito no permite excepciones. Si es imprescindible, ábrela desde el PC.

**El script no ve el móvil**
Sigue la lista que te muestra: cable de datos, depuración USB activada, aceptar el aviso en el móvil, Bloqueador automático (Samsung), "ajustes de seguridad" (Xiaomi) y controlador USB (2.3).

**Xiaomi: el script dice que falta un permiso**
Activa "Depuración USB (ajustes de seguridad)" (2.2), desconecta y vuelve a conectar el cable.

**Al teclear la llave no aparece nada en el campo**
Comprueba que tocaste el campo y que el teclado está abierto. Algunos teclados numéricos especiales no aceptan el tecleo por cable. Si no funciona, **cancela** (no guardes el PIN). En AppBlock, usa la variante con temporizador. En los Controles parentales o en Play, no metas el PIN a mano (lo verías): es mejor saltarte esa capa, porque AppBlock cubre casi lo mismo. Si ya habías programado la cápsula, bórrala sin abrirla o déjala: esa llave no se usará.

**La prueba de la llave falla**
No cierres la ventana del script. Responde **N** a "¿Te ha dejado entrar?": el script borra el campo y la vuelve a teclear (hasta 3 veces). Si después de varios intentos sigue sin abrir:

- Si **todavía estás dentro** de la pantalla de configuración (no la has cerrado), busca la opción de cambiar o quitar el PIN y vuelve a empezar.
- Si no, la salida es la de [Si se pierde una llave](#cómo-deshacerlo-cuando-llegue-la-llave).

**AppBlock dejó de bloquear**
Revisa que tenga el permiso de Accesibilidad y que no esté activada la Protección avanzada. Si el móvil se reinició en modo seguro, reinícialo normal.

---

## Datos técnicos y fuentes

Datos comprobados el 11 de octubre de 2026:

| Dato | CleanBrowsing Family Filter (principal) | Cloudflare for Families (respaldo) |
|---|---|---|
| DNS privado de Android (DNS sobre TLS) | `family-filter-dns.cleanbrowsing.org` | `family.cloudflare-dns.com` |
| IPv4 | 185.228.168.168 y 185.228.169.168 | 1.1.1.3 y 1.0.0.3 |
| IPv6 | 2a0d:2a00:1:: y 2a0d:2a00:2:: | 2606:4700:4700::1113 y 2606:4700:4700::1003 |
| DNS sobre HTTPS | `https://doh.cleanbrowsing.org/doh/family-filter/` | `https://family.cloudflare-dns.com/dns-query` |
| Qué bloquea | Adultos, proxies y VPN, contenido mixto; fuerza SafeSearch y el modo restringido moderado de YouTube | Adultos y malware |

Fuentes principales:

- CleanBrowsing: [filtros](https://cleanbrowsing.org/filters), [gratis frente a pago](https://cleanbrowsing.org/learn/free-vs-paid), [SafeSearch y YouTube](https://cleanbrowsing.org/learn/how-to-enforce-safe-search), [bloquear ajustes del móvil](https://cleanbrowsing.org/support/mobile/lock-mobile-settings), [app de Android](https://cleanbrowsing.org/learn/android-app).
- Cloudflare: [1.1.1.1 for Families en Android](https://developers.cloudflare.com/1.1.1.1/setup/android/).
- Google: [DNS privado en Pixel](https://support.google.com/pixelphone/answer/2819583), [Controles parentales de Android](https://support.google.com/android/answer/16766047?hl=es), [controles parentales de Google Play](https://support.google.com/googleplay/answer/1075738?hl=es), [SafeSearch](https://support.google.com/websearch/answer/186669), [modo restringido de YouTube](https://support.google.com/youtube/answer/174084?hl=es), [Family Link y edad de consentimiento](https://support.google.com/families/answer/9055704).
- Android para desarrolladores: [adb](https://developer.android.com/tools/adb), [platform-tools](https://developer.android.com/tools/releases/platform-tools), [UserManager](https://developer.android.com/reference/android/os/UserManager).
- AppBlock: [modo estricto](https://appblock.app/help/android/strict-mode-all/), [desbloqueo de emergencia](https://appblock.app/help/android/strict-mode-and-unblocking/), [apps recién instaladas](https://appblock.app/how-to-block-newly-installed-apps-2/), [contenido para adultos](https://appblock.app/how-to-block-adult-content/), [modo seguro](https://appblock.app/appblock-does-not-work-after-entering-safe-mode-2/), [Protección avanzada](https://appblock.app/androids-new-advanced-protection-affects-appblock-from-blocking/).
- Samsung: [Bloqueador automático](https://www.samsung.com/us/support/answer/ANS10003636/).
- Microsoft: [Enlace Móvil: copiar y pegar entre dispositivos](https://support.microsoft.com/en-us/windows/apps/phonelink/seamlessly-transfer-content-between-your-devices).
- Código fuente de Chromium (lista de proveedores de DNS seguro) y de Android (comandos `settings`, `pm`, `input`).
