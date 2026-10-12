# Kit para bloquear contenido adulto (Android + Windows + router)

Este kit monta **varias capas de bloqueo** en el móvil Android, en el PC con Windows y en el router de casa. Cada capa tapa los huecos de las demás. El objetivo no es solo bloquear, sino que **quitar los bloqueos en un mal momento cueste tanto tiempo y esfuerzo que lo fácil sea no hacerlo**.

Está pensado para hacerlo **sin ayuda de otra persona**. Las contraseñas que cierran cada capa (las **llaves**) las crea un programa, **tú no las ves** y quedan guardadas en una **cápsula del tiempo** que no se puede abrir hasta la fecha que elijas (de 30 a 90 días). Cuando llega esa fecha, decides con calma si renuevas o lo deshaces.

> **Sé realista:** ningún bloqueo es 100 % infalible. Cada guía termina con una lista honesta de los huecos que quedan y qué capa cubre cada uno. Y todas las capas tienen una vía de recuperación por si pierdes una llave: **nunca te quedas sin poder usar tus aparatos**.

---

## Qué necesitas

- El **PC con Windows** (10 u 11) con tu cuenta de administrador, como hasta ahora.
- El **móvil Android** y un **cable USB de datos** (algunos cables solo cargan).
- Acceso al **router** de casa: la pegatina con su contraseña.
- Tu **correo** y una nube (OneDrive, Google Drive...) o un pendrive para guardar las cápsulas.
- Unas **3 o 4 horas** en total. Puedes repartirlas en dos días: un día el router y las llaves, otro el móvil y el PC.

**De pago (opcional, pero recomendado):**

| Qué | Para qué | Precio aproximado |
|---|---|---|
| **AppBlock Premium** (móvil) | Impide quitar los bloqueos del móvil y desinstalar la app hasta que acabe un temporizador | Unos 30 $/año o 90 $ para siempre |
| **Cold Turkey Pro** (PC) | Bloquea navegadores portables, Tor y VPN que las demás capas no pueden cerrar | Unos 39–45 $, pago único |
| **Router propio** | Solo si el router de tu operador no deja cambiar el DNS | Desde unos 30–60 € |

Todo lo demás es gratuito: el filtro DNS **CleanBrowsing Family Filter**, la cápsula **Timevault** y los programas del kit.

---

## Las capas, de un vistazo

| | Router (wifi de casa) | Móvil Android | PC Windows |
|---|---|---|---|
| **Filtro DNS** (CleanBrowsing Family) | ✅ todos los aparatos de casa | ✅ DNS privado, con wifi y con datos | ✅ en todos los adaptadores y con una tarea que lo repone |
| **Búsqueda segura y YouTube restringido** | ✅ | ✅ | ✅ también por directivas del navegador |
| **Sin incógnito ni DNS propio del navegador** | — | Parcial (DNS seguro de Chrome) | ✅ directivas de Chrome, Edge, Brave y Firefox |
| **Lista local de dominios** | — | — | ✅ fichero `hosts` con unos 76.000 dominios |
| **Cortafuegos** (nadie usa otro DNS) | Opcional avanzado | — | ✅ |
| **Sin navegadores ni apps de riesgo** | — | ✅ script por USB | Cold Turkey Pro |
| **App bloqueadora que no se puede quitar** | — | ✅ AppBlock en modo estricto | ✅ Cold Turkey Pro (opcional) |
| **Cerrado con llave** | ✅ contraseña del router | ✅ PIN de Controles parentales o de Play, y AppBlock | ✅ tu cuenta pasa a ser estándar |

---

## El orden (importante)

El orden importa: algunas capas cierran la puerta a pasos posteriores. Por ejemplo, el móvil necesita que tu cuenta del PC todavía sea administradora (para instalar el controlador USB). Sigue esta lista y ve marcando.

### Paso 0. Preparar (30 minutos)

- [ ] **Descarga el kit en el PC.** En la página del repositorio, pulsa **Code > Download ZIP**. Haz clic derecho en el ZIP > **Extraer todo...** y extráelo en **Documentos**. No ejecutes nada desde dentro del ZIP.
- [ ] **Copia de seguridad del PC** (tus archivos, a OneDrive o a un disco externo) y **del móvil** (fotos, WhatsApp...). Ningún paso borra nada, pero si algún día perdieras una llave, la salida de emergencia sería restablecer el aparato.
- [ ] **Comprueba que sabes tus contraseñas de siempre**: la de tu cuenta de Google (el móvil la pide tras un restablecimiento) y, si tienes, las de tu cuenta Samsung o Xiaomi y tu cuenta de Microsoft. Si tu PC tiene BitLocker, localiza su clave de recuperación. Los detalles están en el apartado "Antes de empezar" de cada guía.

### Paso 1. Entender las llaves (15 minutos)

- [ ] Lee en [`llaves/GUIA.md`](llaves/GUIA.md) los apartados **"Qué es una llave"**, **"Por qué no debes mirarla nunca"** y **"Cuántas llaves hacen falta"**.
- [ ] Haz el apartado **"Antes de crear la primera llave"**: desactiva el historial del portapapeles y Enlace Móvil, y haz que el navegador no guarde contraseñas.

### Paso 2. El router, sin llave todavía (30–60 minutos)

- [ ] [`router/GUIA.md`](router/GUIA.md): mira primero si tu operador deja cambiar el DNS. Después haz los **pasos 1 a 5** (DNS, IPv6, comprobación obligatoria, WPS, red de invitados y administración remota).
- [ ] Si tu router no te deja cambiar el DNS, sáltate el router de momento: el móvil y el PC tienen su propio filtro. El router en cascada lo puedes montar otro día.

> Va primero porque, cuando el móvil y el PC tengan su propio filtro, ya no servirán para comprobar el del router.

### Paso 3. Ensayo de la cápsula (10 minutos)

- [ ] En [`llaves/GUIA.md`](llaves/GUIA.md), haz el **"Ensayo"** de Timevault con una palabra de prueba y una fecha 5 minutos en el futuro. Así compruebas que sabes usarla y que la web carga con el filtro puesto.

### Paso 4. Cerrar el router con su llave (15 minutos)

- [ ] [`router/GUIA.md`](router/GUIA.md), **paso 6**: `llaves/EJECUTAR-llave.bat`, opción **1**.

### Paso 5. El móvil (1–2 horas)

- [ ] Sigue en [`android/GUIA.md`](android/GUIA.md) el apartado **"El recorrido recomendado, en orden"**, de principio a fin: ajustes del móvil, el script `android/EJECUTAR-movil.bat` por USB, AppBlock, el PIN de Controles parentales o de Play y el cierre.
- [ ] Hazlo **antes** del paso 6: el script del móvil necesita el controlador USB, que puede pedir permisos de administrador del PC.

### Paso 6. El PC (30–45 minutos)

- [ ] Lee [`windows/GUIA.md`](windows/GUIA.md) y haz su lista **"Antes de empezar"**: desinstala Opera si lo tienes y, si vas a usar **Cold Turkey Pro**, instálalo y configúralo **ahora**, con su propia llave (`llaves/EJECUTAR-llave.bat`, opción **3**).
- [ ] Doble clic en **`windows/EJECUTAR-bloqueo.bat`**. Al final llega el **paso de cuentas**: el programa crea el administrador `GuardianBloqueo` con una llave que no ves, la guardas en tu cápsula y tu cuenta pasa a ser estándar. Esto va lo **último** a propósito.
- [ ] Cierra sesión y vuelve a entrar.

### Paso 7. Comprobar que todo funciona (15 minutos)

- [ ] En el PC: doble clic en **`windows/EJECUTAR-comprobacion.bat`**. Todo debe salir **OK**.
- [ ] Repasa la **lista de verificación final** de cada guía: [móvil](android/GUIA.md#prueba-que-funciona-lista-de-verificación-final), [PC](windows/GUIA.md#lista-de-verificación-final) y [router](router/GUIA.md#lista-de-verificación-final).
- [ ] Apunta en tu calendario la **fecha de apertura** de cada cápsula. **Escalona las fechas** para que nunca se abran todas a la vez (por ejemplo: móvil a 30 días, PC a 60 y router a 90).

### Paso 8. Lo que no es técnico

- [ ] Lee [`APOYO.md`](APOYO.md): un plan corto para los momentos de impulso y dónde pedir ayuda en España. Los bloqueos dan tiempo; ese tiempo sirve más si sabes qué hacer con él.

---

## Otros aparatos de casa

Si tienes **tablet, otro portátil, consola o smart TV**, el router los filtra mientras estén en la wifi de casa. Si alguno sale de casa o usa datos móviles, aplícale también la guía del móvil o del PC, o plantéate guardarlo o deshacerte de él durante un tiempo.

---

## Cuando llega una cápsula

Cada guía tiene su apartado **"Cómo deshacerlo (cuando llegue la llave)"**, y la de llaves explica cómo **renovar** (llave nueva y cápsula nueva). Renovar suele ser buena idea: lo que funcionó en frío sigue funcionando.

- PC: `windows/EJECUTAR-deshacer.bat` (con `GuardianBloqueo` y su llave) o volver a ejecutar `EJECUTAR-bloqueo.bat` para renovar la llave.
- Móvil: `android/EJECUTAR-movil.bat`, opción **5** (Deshacer), además de los ajustes de la guía.
- Router: entrar con la llave y volver a poner el DNS automático, o renovar la contraseña.

**Si pierdes una llave**, mira el apartado **"Si una llave se pierde"** de [`llaves/GUIA.md`](llaves/GUIA.md): cada capa tiene su vía de recuperación.

---

## Qué hay en cada carpeta

| Carpeta | Contenido |
|---|---|
| [`llaves/`](llaves/) | Guía de llaves y cápsulas del tiempo, y el programa `EJECUTAR-llave.bat` |
| [`router/`](router/) | Guía del router, con notas por operador español |
| [`android/`](android/) | Guía del móvil y el script por USB `EJECUTAR-movil.bat` |
| [`windows/`](windows/) | Guía del PC y los programas `EJECUTAR-bloqueo.bat`, `EJECUTAR-comprobacion.bat` y `EJECUTAR-deshacer.bat` |
| [`APOYO.md`](APOYO.md) | Plan para los momentos de impulso y recursos de ayuda en España |

**Nota técnica:** los programas son scripts de PowerShell (`.ps1`) que se abren con los `.bat`. No necesitan instalar nada: usan el PowerShell que ya trae Windows. Puedes leer su código antes de ejecutarlos. Ninguno guarda las llaves en el disco.
