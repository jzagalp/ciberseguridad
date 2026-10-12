# Capa del router: filtrar toda la wifi de casa

Esta guía forma parte del kit para bloquear contenido adulto. Aquí está todo lo del **router de casa**. Las llaves y las cápsulas del tiempo se explican en [`../llaves/`](../llaves/), el móvil en [`../android/`](../android/) y el PC en [`../windows/`](../windows/).

La idea: el router es la puerta de internet de tu casa. Si le dices que use un **DNS con filtro**, todo lo que se conecte a tu wifi o por cable (el móvil, el PC, una tablet, la tele, una consola...) queda filtrado sin configurar nada en cada aparato. Y si cierras el router con una **llave**, no podrás deshacerlo en un mal momento.

> **Sé realista:** el router es la capa más fácil de "resetear". Tiene un botón que lo devuelve a fábrica, el operador a veces cambia la configuración a distancia y fuera de casa no protege nada. Por eso el kit tiene también capas en el móvil y en el PC. Esta capa suma: cubre los aparatos que no tienen filtro propio y es una red de seguridad si otra capa falla.

---

## Índice

1. [Antes de empezar](#antes-de-empezar)
2. [Primero: ¿tu router te deja cambiar el DNS?](#primero-tu-router-te-deja-cambiar-el-dns)
3. [Datos del filtro](#datos-del-filtro)
4. [Paso 1: entrar en el router](#paso-1-entrar-en-el-router)
5. [Paso 2: cambiar el DNS que reparte el router](#paso-2-cambiar-el-dns-que-reparte-el-router)
6. [Paso 3: IPv6](#paso-3-ipv6)
7. [Paso 4: comprobar que funciona (obligatorio)](#paso-4-comprobar-que-funciona-obligatorio)
8. [Paso 5: WPS, red de invitados y administración remota](#paso-5-wps-red-de-invitados-y-administración-remota)
9. [Paso 6: cerrar el router con una llave](#paso-6-cerrar-el-router-con-una-llave)
10. [Notas por operador](#notas-por-operador)
11. [Si tu router no te deja: router propio en cascada](#si-tu-router-no-te-deja-router-propio-en-cascada)
12. [Opcional avanzado: que nadie se salte el DNS (puertos 53 y 853)](#opcional-avanzado-que-nadie-se-salte-el-dns-puertos-53-y-853)
13. [Opcional avanzado: AdGuard Home en una Raspberry Pi](#opcional-avanzado-adguard-home-en-una-raspberry-pi)
14. [El hueco que no se puede cerrar: el botón de reset](#el-hueco-que-no-se-puede-cerrar-el-botón-de-reset)
15. [Cómo deshacerlo (cuando llegue la llave)](#cómo-deshacerlo-cuando-llegue-la-llave)
16. [Huecos que quedan y qué capa los cubre](#huecos-que-quedan-y-qué-capa-los-cubre)
17. [Lista de verificación final](#lista-de-verificación-final)
18. [Problemas frecuentes](#problemas-frecuentes)
19. [Datos técnicos y fuentes](#datos-técnicos-y-fuentes)

---

## Antes de empezar

**Necesitas:**

- El PC conectado a la wifi de casa (o por cable al router).
- La **pegatina del router**: ahí vienen la dirección de acceso, el usuario y la contraseña de administración. **No la arranques ni la tapes**: es tu vía de recuperación si algún día lo reseteas.
- Entre 30 y 60 minutos en un momento en que nadie de casa necesite internet: al guardar cambios, el router puede reiniciarse.
- El programa de llaves y una cápsula del tiempo preparados para el paso 6 (ver [`../llaves/GUIA.md`](../llaves/GUIA.md)).

**Muy recomendable: monta el router antes que las capas del PC y del móvil.** Cuando el PC y el móvil tengan su propio filtro, ya no servirán para comprobar el router (cada uno usa el suyo). Si ya los tienes montados, en el [paso 4](#paso-4-comprobar-que-funciona-obligatorio) te explico cómo comprobarlo con otro aparato.

**Qué vamos a cambiar:**

| Qué | Para qué | ¿Lleva llave? |
|---|---|---|
| DNS que reparte el router | Todos los aparatos de casa usan CleanBrowsing Family Filter | No |
| IPv6 en la red local | Que no se cuele el DNS del operador por la "otra vía" | No |
| Contraseña de administración | Que no puedas deshacerlo en un impulso | **Sí** |
| WPS, red de invitados, administración remota | Cerrar puertas traseras | No |

---

## Primero: ¿tu router te deja cambiar el DNS?

Depende mucho del operador y del modelo. Lo que sigue viene sobre todo de **foros de usuarios** (no de los operadores) y puede cambiar con cada actualización. La regla es siempre la misma: **pruébalo y compruébalo** (paso 4).

| Operador | ¿Se puede? | Qué hacer |
|---|---|---|
| **Movistar y O2** | Normalmente sí | Pasos 1 a 6. Ruta en [Notas por operador](#movistar-y-o2) |
| **Digi** | Sí, pero su IPv6 se cuela | Pasos 1 a 6 y **desactivar IPv6 en la red local** |
| **Vodafone y Lowi** | Depende del modelo | Primero desactiva "DNS Seguro" ([ver nota](#vodafone-y-lowi)) |
| **Orange, Jazztel y Simyo** (Livebox) | Normalmente **no** | [Router propio en cascada](#si-tu-router-no-te-deja-router-propio-en-cascada) o solo las capas de cada aparato |
| **MásMóvil, Yoigo y Pepephone** | Normalmente **no** (o se deshace solo) | Igual que Orange |
| **Finetwork, Avatel y otros** | No hay datos | Prueba los pasos 1 a 4. Si no funciona, router en cascada |

Si tu router no te deja, **no pasa nada**: el móvil y el PC tienen su propio filtro, que funciona con cualquier operador y también fuera de casa. El router es un extra.

---

## Datos del filtro

El filtro principal de todo el kit es **CleanBrowsing Family Filter**. Es gratuito y no necesita cuenta. Bloquea webs para adultos, webs de proxy y VPN y webs de contenido mixto (por ejemplo, Reddit), y fuerza la búsqueda segura de Google y Bing y el modo restringido de YouTube.

| Dato | CleanBrowsing Family Filter (principal) | Cloudflare 1.1.1.1 for Families, nivel "malware y adultos" (solo respaldo) |
|---|---|---|
| DNS IPv4 (primario y secundario) | `185.228.168.168` y `185.228.169.168` | `1.1.1.3` y `1.0.0.3` |
| DNS IPv6 | `2a0d:2a00:1::` y `2a0d:2a00:2::` | `2606:4700:4700::1113` y `2606:4700:4700::1003` |
| DNS sobre TLS (DoT) | `family-filter-dns.cleanbrowsing.org` | `family.cloudflare-dns.com` |
| DNS sobre HTTPS (DoH) | `https://doh.cleanbrowsing.org/doh/family-filter/` | `https://family.cloudflare-dns.com/dns-query` |

El respaldo de Cloudflare (se llama oficialmente **1.1.1.1 for Families**; usa las direcciones que acaban en 3, no las que acaban en 2, que solo bloquean malware) bloquea adultos y malware, pero **su documentación no dice que fuerce la búsqueda segura ni el modo restringido de YouTube**. Úsalo solo si CleanBrowsing dejara de funcionar.

---

## Paso 1: entrar en el router

1. Conéctate a la wifi de casa (o por cable).
2. Averigua la dirección del router:
   - Pulsa la tecla Windows, escribe `cmd` y pulsa Intro. Se abre una ventana negra (el "Símbolo del sistema").
   - Escribe `ipconfig` y pulsa Intro.
   - Busca la línea **"Puerta de enlace predeterminada"**: esa es la dirección. Casi siempre es `192.168.1.1`. En Vodafone y Lowi suele ser `192.168.0.1`.
3. Abre el navegador y escribe esa dirección en la barra de arriba, por ejemplo `http://192.168.1.1`.
4. Si el navegador avisa de que la conexión "no es segura", es normal en la página de un router de casa: continúa.
5. Entra con el **usuario y la contraseña de administración de la pegatina** (no confundir con la clave de la wifi, aunque en algunos modelos coinciden).
6. Si el navegador te ofrece **guardar la contraseña**, pulsa **"Nunca"**. Esto vale para todo el kit.

**Antes de tocar nada, haz capturas de pantalla** (tecla Windows + Mayús + S) de cada página que vayas a cambiar. Guárdalas en una carpeta. Te servirán para dejarlo todo como estaba. No hagas captura de la página de la clave de la wifi.

---

## Paso 2: cambiar el DNS que reparte el router

Los nombres de los menús cambian de un router a otro. Mira también la [nota de tu operador](#notas-por-operador).

1. Busca la sección de la red local. Suele llamarse **"Red local"**, **"LAN"**, **"Configuración LAN"**, **"DHCP"** o **"Servidor DHCP"**.
2. Dentro, busca los campos **"DNS primario"** y **"DNS secundario"** (o "DNS 1" y "DNS 2", "Servidor DNS"). Si hay una casilla tipo "DNS automático" o "Usar DNS del proveedor", desmárcala o elige **"Manual"**.
3. Escribe:
   - DNS primario: `185.228.168.168`
   - DNS secundario: `185.228.169.168`
4. **Si solo hay campos de DNS en la parte de Internet o WAN** (no en la red local), ponlos ahí. En muchos routers, los aparatos preguntan al propio router y él pregunta a esos DNS, así que también vale. Lo confirmarás en el paso 4.
5. Pulsa **Guardar** o **Aplicar**. Si te pide reiniciar, acepta.
6. Los aparatos tardan unos minutos en recibir el cambio (CleanBrowsing habla de 5 a 10). Para ir más rápido: en el PC, en la ventana negra, escribe `ipconfig /renew`; en el móvil, apaga y enciende la wifi.

> **Si te equivocas en una cifra, te quedarás sin internet en casa.** No pasa nada: vuelve a entrar en el router y corrígelo, o pon lo que tenías (por eso hiciste las capturas).

---

## Paso 3: IPv6

Internet tiene dos "idiomas" de direcciones: el clásico (IPv4) y uno nuevo (IPv6). Si tu router reparte también el DNS del operador por IPv6, los aparatos pueden usarlo y **saltarse el filtro sin que te des cuenta**. CleanBrowsing avisa de esto expresamente.

Tienes dos opciones. **La recomendada para la mayoría es la A**, porque es la más sencilla y en casa no notarás ninguna diferencia.

**Opción A (recomendada): desactivar IPv6 en la red local**

1. Busca en el router algo como **"IPv6"**, **"LAN IPv6"**, **"IPv6 LAN"** o **"Configuración IPv6"**.
2. Desactiva IPv6 **en la red local (LAN)**. Si hay casillas separadas para "DHCPv6" y "RA" o "SLAAC", desactiva las dos.
3. **No toques el IPv6 de la parte de Internet (WAN)** salvo que la LAN no tenga opción. Si lo desactivas ahí y te quedas sin internet, vuelve a activarlo.
4. Guarda.

**Opción B: dejar IPv6 y poner el DNS IPv6 de CleanBrowsing**

1. En la sección IPv6 de la red local, busca los campos de DNS (a veces se llaman "RDNSS" o "DNS DHCPv6").
2. Escribe `2a0d:2a00:1::` y `2a0d:2a00:2::`.
3. Si el router tiene casilla para anunciarlos por "RA" o "RDNSS", actívala: los móviles Android solo hacen caso a esa vía.

Si tu router no tiene ni campos de DNS IPv6 ni forma de apagar IPv6 en la red local (pasa en Digi), la capa del router no puede cerrar del todo esa vía: lo cubren el PC y el móvil con su propio filtro.

---

## Paso 4: comprobar que funciona (obligatorio)

**Hazlo ahora, y repítelo después de cada cambio, de cada reinicio o actualización del router, después de un apagón y una vez al mes.** Algunos operadores devuelven el DNS a lo de fábrica sin avisar. Apunta un recordatorio mensual en tu calendario.

Ninguna prueba necesita abrir webs para adultos.

### Con el PC (si todavía no tiene la capa de Windows)

1. Abre la ventana negra (tecla Windows, escribe `cmd`, Intro).
2. Escribe `ipconfig /all` y pulsa Intro. En el apartado de tu conexión ("Adaptador de LAN inalámbrica Wi-Fi" o "Adaptador de Ethernet"), mira las líneas de **"Servidores DNS"**:
   - **Bien:** solo aparecen `185.228.168.168` y `185.228.169.168` (y, si usaste la opción B de IPv6, `2a0d:2a00:1::` y `2a0d:2a00:2::`).
   - **Vale, pero mira el punto 3:** aparece solo la dirección del router (por ejemplo, `192.168.1.1`). Significa que el router hace de intermediario. Entonces los DNS de CleanBrowsing tienen que estar también en la parte de Internet o WAN del router.
   - **Mal:** aparece cualquier otra dirección, incluidas las IPv6 (por ejemplo, las que empiezan por `fe80`, `2a02` o `2001`). Por ahí se puede colar el DNS del operador: vuelve al [paso 3](#paso-3-ipv6) o mira la [nota de tu operador](#notas-por-operador).
   - **No cuentan** las líneas `fec0:0:0:ffff::1%1`, `fec0:0:0:ffff::2%1` y `fec0:0:0:ffff::3%1`: Windows las pone de relleno cuando no recibe ningún DNS IPv6 (pasa justo después de desactivar IPv6 en la red local) y no se usan para nada.
3. Escribe `nslookup www.google.com` y pulsa Intro. En la respuesta debe aparecer **`forcesafesearch.google.com`** o la dirección **`216.239.38.120`**. Eso significa que la búsqueda segura está forzada: el filtro funciona.
4. Escribe `nslookup reddit.com` y pulsa Intro. **No debe darte una dirección normal**: lo esperado es un error del tipo "Non-existent domain" o "no encuentra", o la dirección `0.0.0.0`. CleanBrowsing Family bloquea Reddit por tener contenido mixto, así que es una prueba neutra. (Si Reddit sí da una dirección pero el punto 3 sale bien, puede que CleanBrowsing haya cambiado su lista: lo importante es el punto 3.)
5. **Prueba de interceptación** (importante en Vodafone y Lowi): escribe `nslookup www.google.com 185.228.168.168`. Esta pregunta va directa a CleanBrowsing. Si la respuesta **no** incluye `forcesafesearch.google.com` ni `216.239.38.120`, algo entre medias (normalmente el router del operador) está respondiendo en su lugar. Mira la [nota de Vodafone y Lowi](#vodafone-y-lowi). Esta prueba también vale con la capa de Windows ya puesta, y conviene hacerla.
6. En el navegador, abre `reddit.com`: no debe cargar. Si quieres, abre también `https://cleanbrowsing.org/dnsleaktest`: debe indicar que usas CleanBrowsing (si esa página no existe, sáltatelo: los puntos 3 a 5 bastan).

### Con otro aparato (si el PC y el móvil ya tienen su propio filtro)

Cuando el PC y el móvil tienen su propia capa, usan su filtro y no el del router, así que no sirven para comprobarlo. Usa un aparato **sin filtro propio** conectado a tu wifi: una tablet, la tele, una consola con navegador o el móvil de una visita.

1. En su navegador, abre `reddit.com`: **no debe cargar**.
2. Si quieres, abre `https://cleanbrowsing.org/dnsleaktest`: debe indicar que usas CleanBrowsing (si esa página no existe, sáltatelo).

Si no tienes otro aparato, este comando del PC te dice qué DNS le está ofreciendo el router aunque el PC use el suyo propio. Cópialo entero (es una sola línea) en la ventana negra y pulsa Intro:

```
powershell -NoProfile -Command "Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object { $p = Get-ItemProperty -Path ('HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\' + $_.InterfaceGuid) -ErrorAction SilentlyContinue; if ($p -and $p.DhcpNameServer) { $_.Name + ': ' + $p.DhcpNameServer } }"
```

En la línea de tu conexión (por ejemplo, `Wi-Fi:`) debe salir `185.228.168.168 185.228.169.168` (o la dirección del router). Si no sale nada, tu conexión no está recibiendo el DNS por el router: usa otro aparato. Este comando solo mira IPv4: para IPv6, fíate del [paso 3](#paso-3-ipv6).

### YouTube

Abre `https://www.youtube.com/check_content_restrictions` desde un aparato que use el filtro del router. Si la página existe, te dirá qué restricción se aplica. Si no, abre YouTube y pulsa tu foto de perfil (o los tres puntos, si no has iniciado sesión): el **modo restringido** debería aparecer activado.

---

## Paso 5: WPS, red de invitados y administración remota

Antes de cerrar el router con la llave, apaga estas tres cosas:

1. **WPS** (suele estar en **"Wi-Fi"** o **"Inalámbrico"** > **"WPS"**): desactívalo. Es un botón o un PIN que deja conectar aparatos sin la clave. Por seguridad general conviene tenerlo apagado, y en el montaje con router en cascada es imprescindible.
2. **Red de invitados** ("Wi-Fi invitados", "Guest"): desactívala. En algunos routers usa otro DHCP o el DNS del operador y se saltaría el filtro. Si la quieres mantener, haz el [paso 4](#paso-4-comprobar-que-funciona-obligatorio) desde un aparato conectado a ella.
3. **Administración remota** ("Acceso remoto", "Gestión desde Internet", "Acceso WAN", "Remote management"): desactívala. Es el acceso a la página del router desde fuera de casa. No tiene nada que ver con la gestión que hace el operador, que no se puede quitar.

---

## Paso 6: cerrar el router con una llave

Cuando el paso 4 salga bien y hayas hecho el paso 5, cambia la contraseña de administración del router por una **llave**: una contraseña al azar que no vas a ver, guardada en una cápsula del tiempo. Así no podrás quitar el filtro en un impulso.

**Lo bueno del router:** es la única capa en la que perder la llave no tiene consecuencias graves. Con el botón de reset vuelve a valer la contraseña de la pegatina (lo malo es que tendrás que volver a configurarlo).

1. Prepara la cápsula del tiempo como explica [`../llaves/GUIA.md`](../llaves/GUIA.md).
2. En el router, busca la página de la contraseña. Suele estar en **"Administración"**, **"Sistema"**, **"Mantenimiento"**, **"Gestión"** o **"Cambiar contraseña"**.
3. Haz doble clic en `../llaves/EJECUTAR-llave.bat` y elige **"1) Router: contraseña de administración"**. Sigue sus tres pasos:
   1. Pega el texto en la cápsula, cífralo y guarda el texto cifrado en tus dos sitios.
   2. En el router, escribe la **contraseña actual** (la de la pegatina) y pega la llave en **"Contraseña nueva"** y en **"Repetir"** o **"Confirmar"**. Guarda. Si el navegador ofrece guardarla: **"Nunca"**.
   3. Sal del router y vuelve a entrar pegando la llave para comprobar que abre.
4. Si el router no acepta la llave (algunos limitan la longitud o piden símbolos), escribe **F** en el programa y elige 16 caracteres o "con un símbolo". La cápsula anterior ya no sirve: bórrala.

Ten en cuenta:

- En algunos routers de operador solo se puede cambiar la contraseña del usuario básico, no la del "superusuario". Cámbiala igualmente: añade fricción.
- Después del cambio, la contraseña de la pegatina deja de valer (hasta que alguien resetee el router).
- Si usas la app del operador o del router (Smart WiFi, Mi Vodafone, la app del fabricante...), puede que te pida la contraseña nueva. No pasa nada si deja de funcionar.

---

## Notas por operador

Todo esto viene de foros y comunidades de usuarios y puede cambiar con cada modelo o actualización. Si algo no coincide, busca por los menús con los nombres del [paso 2](#paso-2-cambiar-el-dns-que-reparte-el-router) genérico, y comprueba siempre con el paso 4.

### Movistar y O2

Routers HGU (Askey, Mitrastar) y Smart WiFi 6.

1. Entra en `http://192.168.1.1` con la contraseña de la pegatina.
2. En el **portal básico** (no en el avanzado): **Menú > Red local > Red local**. Ahí están los campos **DNS1** y **DNS2**.
3. Pon `185.228.168.168` y `185.228.169.168` y guarda.

Ojo:

- En el **modo avanzado** los campos de DNS a menudo no aparecen o no se guardan. Usa el portal básico.
- Algunos firmwares de Mitrastar no conservan el cambio. Por eso el paso 4 es obligatorio.
- **Si tienes Movistar TV, no borres ni toques el "servidor DHCP" de IPTV** del modo avanzado: te quedarías sin televisión.
- La app **Smart WiFi** tiene perfiles, horarios y pausas, pero no filtra por categorías ni cambia el DNS. No sustituye a esta guía.
- Movistar está desplegando IPv6: revisa el [paso 3](#paso-3-ipv6).

### Vodafone y Lowi

Routers H500-s, Wi-Fi 6 Station y otros. La dirección suele ser `192.168.0.1`.

**El problema: "DNS Seguro".** Muchos routers de Vodafone y Lowi traen activada una función llamada **"DNS Seguro"** que **intercepta todas las consultas de DNS normales** (puerto 53) y las responde con los DNS de Vodafone. Consecuencias:

- Un DNS escrito a mano en el router o en un aparato **se ignora sin avisar** y el filtro no actúa.
- **Afecta también a la capa del PC** si Windows usa DNS normal (sin cifrar). Lo detecta la prueba de interceptación del paso 4.
- El DNS cifrado **no se ve afectado**: el DNS privado del móvil (DoT) y el DNS sobre HTTPS (DoH) siguen funcionando.

Qué hacer:

1. Entra en el router y busca **"DNS & DDNS"** (o algo parecido). Si ves **"DNS Seguro"**, **desactívalo** y guarda.
2. Después cambia el DNS que reparte el router ([paso 2](#paso-2-cambiar-el-dns-que-reparte-el-router)).
3. Haz el paso 4, **incluida la prueba de interceptación**.
4. Si tu modelo no muestra esas opciones (en algunos solo aparecen con un usuario administrador que Vodafone no facilita), la capa del router no es posible con ese router. Opciones:
   - [Router propio en cascada](#si-tu-router-no-te-deja-router-propio-en-cascada) **que use DNS cifrado (DoT o DoH)** hacia CleanBrowsing. Con DNS normal, el router de Vodafone también lo interceptaría.
   - O quedarte con las capas del PC y del móvil, comprobando en el PC que el filtro funciona (ver [`../windows/GUIA.md`](../windows/GUIA.md)).
5. Si algún día usas el respaldo de Cloudflare: según los foros, algunos routers Sercomm de Vodafone interceptan las direcciones `1.1.1.x`. Pon `1.0.0.3` como primario.

### Orange, Jazztel y Simyo

Routers Livebox. Los campos de DNS suelen aparecer bloqueados con un mensaje del tipo "los configura el operador". Normalmente **no se pueden cambiar**.

Opciones:

- [Router propio en cascada](#si-tu-router-no-te-deja-router-propio-en-cascada) (recomendado si quieres esta capa).
- O quedarte solo con las capas del PC y del móvil.
- Avanzado: apagar el servidor DHCP del Livebox y repartir las direcciones desde otro equipo ([AdGuard Home](#opcional-avanzado-adguard-home-en-una-raspberry-pi)).

### MásMóvil, Yoigo y Pepephone

Routers ZTE F680, Sercomm FG824CD y otros. En muchos, el DNS no se puede cambiar o, aunque el panel muestre el cambio, el router sigue repartiendo el del operador. Haz el paso 4: si falla, mismas opciones que Orange.

### Digi

Routers ZTE.

1. **Red local > LAN > Servidor DHCP**: pon `185.228.168.168` y `185.228.169.168` y guarda.
2. El **DNS IPv6 de Digi se reparte igualmente y no se puede cambiar**. Desactiva IPv6 en la red local si tu modelo lo permite ([paso 3, opción A](#paso-3-ipv6)). Si no, esa vía la cubren el PC y el móvil.
3. Paso 4 completo, fijándote en que no aparezcan DNS IPv6 en `ipconfig /all`.

### Finetwork, Avatel y otros operadores

No hemos encontrado datos fiables. Prueba los pasos 1 a 4. Si no deja o no funciona, router en cascada o solo las capas de cada aparato. En España tienes derecho a usar un router propio.

---

## Si tu router no te deja: router propio en cascada

Si el router del operador no deja cambiar el DNS, la opción más sencilla es poner **un router tuyo detrás**: el del operador sigue dando internet y el tuyo crea la wifi de casa con el filtro.

### Qué router comprar

No hace falta uno caro. Fíjate en que tenga:

- **Página de administración web local** (que se abra en `192.168...`). Evita los sistemas que solo se manejan con una app y una cuenta en la nube (muchos sistemas "mesh"): esa cuenta se recupera por correo, así que la llave no serviría de mucho.
- **DNS manual** para la red local.
- Opción para **desactivar IPv6**.
- Para **Vodafone o Lowi con "DNS Seguro" sin poder quitarlo: DNS cifrado** ("DNS over TLS", "DNS-over-TLS", "DoT" o "DoH"). Mira la ficha del modelo antes de comprar. Algunos routers ASUS con firmware reciente lo traen en la configuración de Internet o WAN; compruébalo para tu modelo.

### Cómo montarlo

1. Conecta un cable desde un puerto **LAN** (amarillo, numerado) del router del operador al puerto **WAN** o **Internet** del router nuevo.
2. Entra en el router nuevo (la dirección viene en su pegatina o en su manual) y, en el asistente:
   - Tipo de conexión a Internet: **"IP dinámica"**, "DHCP" o "Automática". No hacen falta datos del operador.
   - **DNS manual:** `185.228.168.168` y `185.228.169.168`. Si tiene DNS cifrado, elige DoT con el servidor `family-filter-dns.cleanbrowsing.org` (o DoH con `https://doh.cleanbrowsing.org/doh/family-filter/`).
   - **IPv6:** desactivado.
   - Wifi: un nombre y una clave que tú conozcas (es la wifi de casa, no es una llave).
   - WPS, red de invitados y administración remota: desactivados ([paso 5](#paso-5-wps-red-de-invitados-y-administración-remota)).
3. Haz el [paso 4](#paso-4-comprobar-que-funciona-obligatorio) conectado a la wifi nueva.
4. Pon una llave como contraseña de administración del router nuevo ([paso 6](#paso-6-cerrar-el-router-con-una-llave)).
5. En el **router del operador**:
   - **Apaga su wifi** (2,4 GHz y 5 GHz) y su **WPS**. Si conectarse a su wifi fuera posible, se saltaría el filtro.
   - Si no puedes apagarla, o si tiene un **botón físico** para volver a encenderla, cambia la clave de su wifi por **una llave** (en el programa, opción "2) Router del operador: contraseña de su wifi").
   - **Antes** de apagar o cambiar su wifi, pasa a cable (o a la wifi nueva) lo que dependa de ella: un decodificador de TV por wifi, un amplificador del operador, un enchufe o una alarma conectados... Si no, dejarán de funcionar.
   - Si te deja, cambia también su contraseña de administración por **otra llave** (en el programa, opción "6) Otra cosa", y escribe por ejemplo `Router del operador: administración`).
6. **Decodificadores de TV**, amplificadores wifi y PLC del operador: los decodificadores se quedan conectados al router del operador. Los amplificadores y PLC, o se conectan al router nuevo o se apagan; si no, extienden la red sin filtro.
7. En el móvil y el PC: conéctate a la wifi nueva y **olvida** la del operador (en el móvil: mantén pulsada la red > "Olvidar"; en Windows: Configuración > Red e Internet > Wi-Fi > Administrar redes conocidas > Olvidar).

Lo que queda abierto en este montaje: un aparato conectado **por cable** al router del operador, o la wifi del operador si alguien la vuelve a encender con la contraseña de la pegatina. Lo cubren las capas del PC y del móvil.

Si juegas online, puede que la consola diga "NAT estricto" o "doble NAT". Es normal en este montaje y no afecta a la navegación.

### Si prefieres no comprar nada

Quédate con las capas de cada aparato: el DNS privado del móvil y la capa de Windows. Funcionan con cualquier operador, en cualquier wifi y con datos móviles, y "DNS Seguro" de Vodafone no intercepta el DNS cifrado del móvil.

---

## Opcional avanzado: que nadie se salte el DNS (puertos 53 y 853)

**Solo para routers que permiten reglas de cortafuegos de salida por destino**: OpenWrt, ASUS con firmware Merlin, pfSense, MikroTik y similares. Casi ningún router de operador lo permite. Si el tuyo no, sáltate esta sección: no pasa nada.

Sin estas reglas, un aparato que tenga escrito a mano otro DNS (por ejemplo, `8.8.8.8`) se salta el filtro del router. Con ellas, no. CleanBrowsing recomienda (por orden):

1. **DNS normal (puerto 53, TCP y UDP):** permitir solo hacia `185.228.168.168` y `185.228.169.168` (y hacia el propio router, si reparte su dirección como DNS). Todo lo demás, **redirigirlo** a esas direcciones (DNAT) o bloquearlo. Si usas la capa de Windows, añade a la lista permitida `1.1.1.3` y `1.0.0.3`, que son su respaldo.
2. **DNS sobre TLS (puerto 853, TCP):** primero una regla que **permita** el 853 hacia `185.228.168.168` y `185.228.169.168` (y `1.1.1.3` y `1.0.0.3` si alguna vez pones el respaldo de Cloudflare en el móvil). Si dejaste IPv6 activado (opción B del paso 3), permite también `2a0d:2a00:1::` y `2a0d:2a00:2::` (y `2606:4700:4700::1113` y `2606:4700:4700::1003`). **Después**, bloquear el resto del 853.

> **Atención, es importante:** el móvil del kit usa el DNS privado de CleanBrowsing, que va por el puerto 853. **Si bloqueas el 853 sin la excepción de la regla 2, el móvil se quedará sin internet en la wifi de casa.** Pon siempre la excepción **antes** del bloqueo y comprueba el móvil después.

3. **DNS sobre HTTPS (DoH)** va por el puerto 443, el mismo que cualquier web, y no se puede bloquear por puerto. CleanBrowsing Family bloquea muchos dominios de proxy y VPN, y la capa de Windows bloquea los servidores DoH públicos más conocidos.

Guías oficiales de CleanBrowsing (en inglés): [cómo fijar el DNS](https://cleanbrowsing.org/learn/how-to-lock-dns-settings), [reglas de cortafuegos](https://cleanbrowsing.org/support/troubleshooting/block-dns-bypasses-firewall) y [evitar saltos del filtro](https://cleanbrowsing.org/learn/how-to-prevent-filter-bypass).

La función "DNS Director" de ASUS, que hace esto con un clic, solo existe en el firmware Merlin, no en el oficial (según el foro de ASUS).

---

## Opcional avanzado: AdGuard Home en una Raspberry Pi

Solo si te manejas con la informática. Es útil sobre todo con los routers que no dejan cambiar el DNS (Orange, MásMóvil...).

**La idea:** una Raspberry Pi con [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) reparte las direcciones de la red (DHCP) en lugar del router del operador y filtra el DNS.

1. Instala AdGuard Home en la Raspberry Pi siguiendo su documentación oficial.
2. Como DNS de salida ("Upstream DNS"), pon el DoH de CleanBrowsing: `https://doh.cleanbrowsing.org/doh/family-filter/`.
3. Activa la búsqueda segura forzada ("Safe search") y añade listas que bloqueen DoH, VPN y proxies.
4. Activa su servidor DHCP y, después, **desactiva el servidor DHCP del router del operador**. Desactiva también el IPv6 de la red local del router del operador si te deja ([paso 3](#paso-3-ipv6)): si no, puede seguir anunciando su DNS IPv6.
5. Su contraseña de administración: una llave.

Pi-hole también sirve, pero necesita además `cloudflared` para el DoH y no fuerza la búsqueda segura de serie. Para este caso, mejor AdGuard Home.

**Riesgos y vuelta atrás:**

- **Si la Raspberry falla o se apaga, la casa se queda sin internet** (nadie reparte direcciones). La solución es **volver a activar el servidor DHCP del router del operador** (entrando con un cable y una dirección fija en el PC, o reseteando el router). Apúntalo en papel junto a la Raspberry.
- Requiere actualizaciones de vez en cuando.
- Está al alcance de la mano: desenchufarla y reactivar el DHCP del operador se salta el filtro. Lo cubren, otra vez, las capas de cada aparato.

---

## El hueco que no se puede cerrar: el botón de reset

Todos los routers tienen un **botón de reset** (normalmente un agujerito). Mantenido pulsado entre 10 y 30 segundos con el router encendido, lo devuelve **a fábrica**: DNS del operador, contraseñas de la pegatina, wifi original. Lo mismo pasa si llamas al operador y pides que lo restablezca, y a veces el operador cambia la configuración a distancia sin avisar. Las apps del operador también pueden reiniciar el router o tocar la wifi.

**No hay forma de impedirlo, y está bien que sea así**: ese botón es a la vez el hueco y tu salida de emergencia si pierdes la llave.

Por eso esta capa no va sola. Lo cubren las capas de cada aparato, que funcionan aunque el router esté reseteado, en otra wifi o con datos móviles:

- **Móvil:** DNS privado de CleanBrowsing y app bloqueadora ([`../android/`](../android/)).
- **PC:** la capa de Windows ([`../windows/`](../windows/)).

Si un día notas que el router ha vuelto a fábrica (vuelve a aceptar la contraseña de la pegatina, la wifi tiene el nombre original...), no es un fracaso: repite esta guía cuando puedas.

---

## Cómo deshacerlo (cuando llegue la llave)

1. Abre la cápsula y saca la llave como explica [`../llaves/GUIA.md`](../llaves/GUIA.md).
2. Entra en el router con tu usuario y la llave (pégala).
3. **Decide si renuevas o deshaces.** Si renuevas, haz otra vez el paso 6 con una llave nueva (en "contraseña actual" pega la llave antigua y, después, escribe R en el programa para volver a copiar la nueva). Si deshaces, sigue:
4. **DNS:** deja lo que había antes, mirando tus capturas. Normalmente es marcar "Automático" o "DNS del proveedor", o dejar los campos vacíos.
5. **IPv6:** vuelve a activarlo si estaba activado.
6. **Contraseña de administración:** pon una que conozcas.
7. **WPS, red de invitados y administración remota:** es mejor dejarlas apagadas, pero puedes volver a activarlas.
8. **Montaje en cascada:** enciende la wifi del router del operador (con su contraseña o la llave que le pusiste), conecta tus aparatos a ella y desconecta el router nuevo. O deja el router nuevo y quítale solo el DNS.
9. **AdGuard Home:** vuelve a activar el servidor DHCP del router del operador y apaga la Raspberry.
10. Comprueba que tienes internet en el PC y en el móvil.

**Si se pierde la llave del router** (la cápsula no aparece o no se puede abrir): **resetea el router** con el botón (10 a 30 segundos, con un clip). Espera unos minutos y entra con los datos de la pegatina. La wifi volverá al nombre y la clave de la pegatina: tendrás que reconectar todos los aparatos. Si después del reset no tienes internet o deja de funcionar la TV del operador, espera unos 15 minutos (algunos routers se reconfiguran solos) y, si sigue igual, llama al operador. Después, si quieres, repite esta guía.

---

## Huecos que quedan y qué capa los cubre

| Hueco | Qué pasa | Qué lo cubre |
|---|---|---|
| Botón de reset, el operador o su app | El router vuelve a fábrica o pierde el DNS | Capas del móvil y del PC; comprobación mensual |
| Otra cuenta de administración del router (un "superusuario" del operador cuya contraseña no puedes cambiar, o tu área de cliente) | Se puede entrar al router sin la llave | Capas del móvil y del PC; comprobación mensual |
| Datos móviles u otra wifi | El router de casa no interviene | DNS privado y app bloqueadora del móvil; capa de Windows en el PC |
| Un aparato con DNS escrito a mano (por ejemplo, `8.8.8.8`) | Se salta el DNS del router | Reglas del puerto 53 (avanzado); capas del PC y del móvil, que impiden cambiar el DNS |
| Navegador con su propio DNS cifrado (DoH) o una VPN | Se salta el DNS del router | CleanBrowsing bloquea muchas webs de VPN y proxy; las capas del PC y del móvil bloquean esos navegadores y apps |
| IPv6 del operador | El DNS del operador se cuela | Paso 3; si no se puede, capas del PC y del móvil |
| "DNS Seguro" de Vodafone y Lowi | El router responde con el DNS de Vodafone | Desactivarlo; router en cascada con DNS cifrado; DNS privado del móvil |
| Red de invitados o WPS | Otra puerta a la red | Paso 5 |
| Montaje en cascada: cable o wifi del router del operador | Red sin filtro | Wifi del operador apagada o con llave; capa de Windows |
| Apps con contenido propio (X, Telegram...) | Su contenido no pasa por el filtro de webs | Capas del móvil y del PC |
| Contenido mixto de webs permitidas | CleanBrowsing no ve dentro de cada página | Búsqueda segura y modo restringido de YouTube forzados |

A cambio, el router cubre algo que las otras capas no: **teles, consolas, tablets y cualquier aparato nuevo** que conectes a tu wifi.

---

## Lista de verificación final

- [ ] Hice capturas de la configuración original del router (sin la clave de la wifi).
- [ ] El DNS del router es `185.228.168.168` y `185.228.169.168`.
- [ ] IPv6 de la red local desactivado (o con los DNS IPv6 de CleanBrowsing).
- [ ] `nslookup www.google.com` devuelve `forcesafesearch.google.com` o `216.239.38.120`.
- [ ] `nslookup reddit.com` no devuelve una dirección normal.
- [ ] La prueba de interceptación (`nslookup www.google.com 185.228.168.168`) devuelve `forcesafesearch`.
- [ ] `ipconfig /all` solo muestra los DNS de CleanBrowsing (o la dirección del router).
- [ ] WPS, red de invitados y administración remota, apagados.
- [ ] Contraseña de administración = llave, con la cápsula guardada en dos sitios y probada.
- [ ] En cascada: wifi y WPS del router del operador apagados (o con llave), decodificadores en el router del operador, amplificadores en el router nuevo.
- [ ] Recordatorio mensual en el calendario para repetir el paso 4.

---

## Problemas frecuentes

**Me he quedado sin internet en casa después de cambiar el DNS**
Seguramente hay una cifra mal escrita. Conéctate por cable si hace falta, entra en el router y corrígela, o vuelve a poner lo que tenías (mira tus capturas). En el peor caso, resetea el router.

**Una web normal que necesito no carga**
CleanBrowsing Family bloquea también webs de contenido mixto (como Reddit) y de VPN o proxy, y el filtro gratuito no permite excepciones. Es parte del precio de este filtro. Si es algo que necesitas a menudo, anótalo y valóralo con calma cuando abras la cápsula.

**Guardo el DNS pero vuelve a lo de antes, o el `ipconfig /all` sigue mostrando el del operador**
Tu router no lo permite de verdad (pasa en Orange, MásMóvil, algunos Mitrastar...). Ve al [router en cascada](#si-tu-router-no-te-deja-router-propio-en-cascada) o quédate con las capas de cada aparato.

**La prueba de interceptación falla**
Algo responde en lugar de CleanBrowsing. En Vodafone y Lowi es "DNS Seguro": [ver nota](#vodafone-y-lowi).

**Se ha ido la tele del operador**
En Movistar, no toques el servidor DHCP de IPTV. En el montaje en cascada, los decodificadores van conectados al router del operador, no al nuevo.

**El móvil no tiene internet en la wifi de casa, pero sí con datos**
Si pusiste reglas del puerto 853, falta la excepción para CleanBrowsing ([ver sección](#opcional-avanzado-que-nadie-se-salte-el-dns-puertos-53-y-853)). Quita el bloqueo del 853 hasta arreglarlo.

**No encuentro la dirección del router o la contraseña**
`ipconfig` > "Puerta de enlace predeterminada". La contraseña está en la pegatina; si la cambiaste y no la tienes, mira "Si se pierde la llave del router" en [Cómo deshacerlo](#cómo-deshacerlo-cuando-llegue-la-llave).

---

## Datos técnicos y fuentes

**Datos del filtro** (revisados en octubre de 2026 con las fuentes oficiales de abajo; si algún dato no coincide con lo que veas en ellas, manda lo que digan ellas):

- CleanBrowsing: [filtros y direcciones](https://cleanbrowsing.org/filters), [configuración genérica de routers](https://cleanbrowsing.org/support/routers/generic-router-configuration), [requisitos de cortafuegos](https://cleanbrowsing.org/support/troubleshooting/firewall-dns-requirements), [IPv6 y filtrado](https://blog.cleanbrowsing.org/accounting-for-ipv6-in-your-content-filtering-strategy/), [cómo comprobar la configuración](https://cleanbrowsing.org/learn/verify-dns-configuration), [ASUS Merlin](https://cleanbrowsing.org/support/routers/asus-merlin).
- Cloudflare 1.1.1.1 for Families: [direcciones IP](https://developers.cloudflare.com/1.1.1.1/ip-addresses/) y [configuración](https://developers.cloudflare.com/1.1.1.1/setup/).

**Notas por operador** (foros y comunidades de usuarios; no son información oficial de los operadores):

- Movistar: [DNS en HGU](https://comunidad.movistar.es/t5/Soporte-T%C3%A9cnico-Banda-Ancha/Configurar-servidores-DNS-en-HGU/td-p/3047853), [Mitrastar que no guarda](https://comunidad.movistar.es/t5/Soporte-Fibra-y-ADSL/Router-Mitrastar-no-permite-cambiar-los-DNS/td-p/4059776), [servidores DHCP e IPTV](https://comunidad.movistar.es/discussions/soporte-fibra-optica/hgu-rtf8115vw-%C2%BFpara-qu%C3%A9-sirven-los-servers-dhcp-0-1-2/4631406/replies/4631458), [Smart WiFi y control parental](https://comunidad.movistar.es/discussions/hogar/control-parental-con-smart-wifi/5120986), [INCIBE sobre Movistar](https://www.incibe.es/menores/familias/control-parental/movistar).
- Vodafone y Lowi: [cómo intercepta el DNS el router de Vodafone](https://bandaancha.eu/articulos/asi-hace-pasar-router-vodafone-tu-11226), [Wi-Fi 6 Station](https://bandaancha.eu/foros/cambiar-dns-router-vodafone-wifi-6-1756265), [Lowi](https://bandaancha.eu/foros/cambiar-dns-router-lowi-1742336), [blog de Lowi](https://www.lowi.es/blog/como-cambiar-dns/), [1.1.1.1 en Vodafone](https://bandaancha.eu/foros/como-usar-servidor-dns-1-1-1-1-vodafone-1730353).
- Orange, Jazztel y Simyo: [BandaAncha](https://bandaancha.eu/articulos/orange-impide-usar-servidores-dns-10794), [Simyo](https://bandaancha.eu/foros/no-pueden-cambiar-servidores-dns-router-1750025), [Roams](https://roams.es/companias-telefonicas/orange/guias/internet-fibra/dns/).
- MásMóvil, Yoigo y Pepephone: [ZTE F680](https://bandaancha.eu/foros/router-zte-f680-dns-1737844), [Yoigo](https://bandaancha.eu/foros/yoigo-no-me-deja-cambiar-dns-cloudflare-1734261), [Pepephone](https://roams.es/companias-telefonicas/pepephone/guias/internet-fibra/dns/).
- Digi: [Tecnoloblog](https://www.tecnoloblog.com/como-cambiar-las-dns-en-el-router-de-digi/), [IPv6 de Digi](https://bandaancha.eu/foros/digi-no-deja-cambiar-dns-1735602).
- Router propio: [derecho a usar router neutro](https://bandaancha.eu/articulos/ministerio-obligo-vodafone-digi-10325), [política de los operadores](https://www.xatakamovil.com/conectividad/cual-politica-operadores-a-hora-cambiar-su-router-uno-neutro), [Finetwork](https://bandaancha.eu/foros/cambiar-router-finetwork-uno-neutro-1739251), [ASUS DNS Director](https://rog-forum.asus.com/t5/gaming-routers/gt-axe16000-how-to-enforce-router-s-pihole-dns-on-manually/td-p/984388).
- WPS: [Xataka](https://www.xatakahome.com/la-red-local/que-wps-que-debes-desactivarlo-para-mejorar-seguridad-tu-red-wi-fi-casa).

**Sin comprobar en una fuente oficial** (de conocimiento general; si algo no coincide, fíate de lo que veas): las direcciones típicas de los routers por operador, la respuesta exacta de `nslookup` a un dominio bloqueado, que `forcesafesearch.google.com` corresponda a `216.239.38.120`, la página `youtube.com/check_content_restrictions`, el comando que lee el DNS ofrecido por el router y qué modelos de router traen DNS cifrado.
