# Llaves y cápsulas del tiempo

Esta guía forma parte del kit para bloquear contenido adulto. Explica cómo cerrar cada capa del kit **sin que nadie tenga que guardarte las contraseñas**: cierras la puerta por tu cuenta y la llave queda guardada donde no puedes alcanzarla hasta una fecha.

- Una **llave** es una contraseña larga y aleatoria que crea un programa. **No la lees ni la memorizas.**
- Una **cápsula del tiempo** es un sitio donde guardas la llave y que **no se puede abrir hasta una fecha** (de 30 a 90 días).
- Cuando llega la fecha, decides con calma si renuevas o deshaces el bloqueo.

El router está en [`../router/`](../router/), el móvil en [`../android/`](../android/) y el PC en [`../windows/`](../windows/).

> **Sé realista:** ninguna cápsula es perfecta. Cada capa tiene una vía de recuperación por si pierdes la llave (resetear el router, restablecer el móvil...) y esa vía también es un hueco. Está hecho así a propósito: nunca te quedas sin salida, pero la salida cuesta tiempo y esfuerzo, que es justo lo que ayuda en un mal momento.

---

## Índice

1. [Qué es una llave](#qué-es-una-llave)
2. [Por qué no debes mirarla nunca](#por-qué-no-debes-mirarla-nunca)
3. [Cuántas llaves hacen falta](#cuántas-llaves-hacen-falta)
4. [Antes de crear la primera llave](#antes-de-crear-la-primera-llave)
5. [La cápsula recomendada: Timevault](#la-cápsula-recomendada-timevault)
6. [La cápsula de respaldo: FutureMe con el texto cifrado](#la-cápsula-de-respaldo-futureme-con-el-texto-cifrado)
7. [Si la llave la crea otro programa del kit](#si-la-llave-la-crea-otro-programa-del-kit)
8. [El programa de llaves, en detalle](#el-programa-de-llaves-en-detalle)
9. [Otras cápsulas y por qué no las recomendamos](#otras-cápsulas-y-por-qué-no-las-recomendamos)
10. [Renovar cuando llega la fecha](#renovar-cuando-llega-la-fecha)
11. [Cómo deshacerlo (cuando llegue la llave)](#cómo-deshacerlo-cuando-llegue-la-llave)
12. [Si una llave se pierde](#si-una-llave-se-pierde)
13. [Fugas que hay que evitar](#fugas-que-hay-que-evitar)
14. [Preguntas frecuentes](#preguntas-frecuentes)
15. [Detalles técnicos y fuentes](#detalles-técnicos-y-fuentes)

---

## Qué es una llave

Una llave se parece a esto: `Hq7mTz3KpW9xRbN4cJ2e` (es un ejemplo inventado: no lo uses nunca). La diferencia es que **la tuya no la ves nunca**. La crea un programa con el generador de números aleatorios de Windows, la copia al portapapeles sin enseñarla y tú la pegas en dos sitios:

1. En la **cápsula del tiempo**.
2. Donde va la **contraseña** (el router, el programa bloqueador...).

Después, el programa vacía el portapapeles y la llave desaparece del PC. Solo queda dentro de la cápsula.

Reglas de oro:

- **Una llave distinta para cada capa**, cada una en su cápsula. Así, si un día abres una, las demás siguen cerradas.
- **Nunca** la escribas a mano, la fotografíes, la guardes en el navegador o en un gestor de contraseñas, ni se la mandes a nadie.
- Las llaves no se reutilizan: cada vez que renuevas, llave nueva.

---

## Por qué no debes mirarla nunca

No es una cuestión de fuerza de voluntad. Es que el sistema funciona **porque la llave no está en tu cabeza**.

- Si la ves, aunque sea un segundo, tu memoria puede quedarse con un trozo. En un mal momento, intentarías reconstruirla, y eso ya es una puerta entreabierta.
- Si no la has visto nunca, no hay nada que recordar ni que intentar. La única forma de abrir es esperar a la fecha o usar la vía de recuperación, que es lenta a propósito.
- La protección no es contra otra persona, es contra el "yo" de un mal momento. Ese "yo" no puede adivinar 20 caracteres al azar.

**Si la ves sin querer**, no pasa nada grave: crea otra llave con el programa y cambia la contraseña. Son cinco minutos.

Hay dos momentos en que la llave se ve y es inevitable: **cuando llega la fecha** y abres la cápsula (para eso está), y si usas el modo **"por trozos"** para teclearla en un aparato donde no se puede pegar (más abajo).

---

## Cuántas llaves hacen falta

Lo normal son **entre 3 y 5 llaves**. Esta tabla las reúne todas:

| Capa | ¿Llave? | Quién la crea | Dónde se explica | Si se pierde |
|---|---|---|---|---|
| **Router: contraseña de administración** | Sí | `EJECUTAR-llave.bat`, opción 1 | [`../router/GUIA.md`](../router/GUIA.md), paso 6 | Botón de reset: vuelve la contraseña de la pegatina |
| **Router del operador** (solo en el montaje con router propio en cascada): clave de su wifi y, si se puede, su administración | Sí, una para cada cosa | `EJECUTAR-llave.bat`, opción 2 (wifi) y opción 6 (administración) | [`../router/GUIA.md`](../router/GUIA.md) | Reset del router del operador |
| **Administrador de Windows** | Sí | El propio programa de Windows (`EJECUTAR-bloqueo.bat`) | [`../windows/GUIA.md`](../windows/GUIA.md) | Restablecer o reinstalar Windows (por eso la copia de seguridad) |
| **Programa bloqueador del PC** (por ejemplo, Cold Turkey Pro), si lo usas | Sí | `EJECUTAR-llave.bat`, opción 3 | [`../windows/GUIA.md`](../windows/GUIA.md) | Lo que diga su soporte; si no, con el administrador de Windows |
| **PIN de Controles parentales** del móvil (Android 17; en Pixel, también Android 16) | Sí, 10 cifras | El programa del móvil (`EJECUTAR-movil.bat`, opción 2), que lo teclea por cable sin que lo veas | [`../android/GUIA.md`](../android/GUIA.md) | Restablecer el móvil de fábrica. Por eso, **dos cápsulas** |
| **PIN de Google Play** (Android 16 o anterior) | Sí, 4 cifras | El programa del móvil, opción 2 | [`../android/GUIA.md`](../android/GUIA.md) | Borrar los datos de Play Store |
| **AppBlock** (app bloqueadora del móvil) | Con temporizador, no. Con PIN, sí | El programa del móvil, opción 2 | [`../android/GUIA.md`](../android/GUIA.md) | Desbloqueo de emergencia de su soporte, o restablecer el móvil |
| **Cuenta del filtro** | Normalmente **no**: CleanBrowsing Family Filter es gratuito y no tiene cuenta. Solo si contratas un plan de pago | `EJECUTAR-llave.bat`, opción 5 | — | "He olvidado mi contraseña" por correo |

Sobre las cuentas que se recuperan **por correo** (un plan de pago del filtro, apps con cuenta, Microsoft Family Safety...): como el correo es tuyo, puedes restablecer la contraseña cuando quieras. La llave ahí solo añade algo de fricción. Lo decimos con honestidad para que no confíes en ellas más de la cuenta.

**Apunta tus cápsulas** en una nota (sin las llaves, claro). Por ejemplo:

| Capa | Creada | Se abre | Dónde está el texto cifrado |
|---|---|---|---|
| Router | 11/10/2026 | 09/01/2027 | Correo "Cápsula Router..." y Drive > capsulas |
| Windows | 11/10/2026 | 10/12/2026 | Correo "Cápsula Windows..." y pendrive |

**Escalona las fechas** (por ejemplo, el router a 90 días, Windows a 60 y el móvil a 30): así nunca se abren todas a la vez.

---

## Antes de crear la primera llave

Prepara el PC una sola vez. Son cinco minutos y tapan las fugas más comunes:

1. **Historial del portapapeles.** Configuración > Sistema > **Portapapeles**: pon "Historial del portapapeles" y "Compartir entre dispositivos" en **Desactivado**. El programa ya lo hace mientras trabaja y marca la llave para que no entre en el historial, pero mejor asegurarse.
2. **Enlace Móvil (Phone Link).** Si lo usas, desactiva **"Copiar y pegar entre dispositivos"**: en la app Enlace Móvil > Configuración > Características, o en Configuración > Bluetooth y dispositivos > Dispositivos móviles. En Samsung, también en el móvil: Vincular a Windows > "Sincronizar portapapeles". Si no, la llave podría acabar en el móvil.
3. **El navegador no debe guardar contraseñas.** Cuando te ofrezca guardar una, pulsa siempre **"Nunca"**. Si quieres, desactiva la oferta: en Chrome, Gestor de contraseñas de Google > Configuración > "Ofrecer guardar contraseñas"; en Edge, en la sección de contraseñas de su Configuración, "Ofrecer guardar contraseñas" (el nombre exacto del menú cambia según la versión).
4. **Recall** (solo en algunos PC Copilot+, y solo si lo activaste): páusalo mientras creas llaves. Las ventanas InPrivate o de incógnito no se guardan en Recall.
5. **Descomprime el kit** si lo descargaste en ZIP. La primera vez que abras un `.bat`, Windows puede decir "Windows protegió su PC": pulsa **Más información** > **Ejecutar de todas formas**.

---

## La cápsula recomendada: Timevault

### Qué es

[Timevault](https://timevault.drand.love) es una web gratuita y sin registro del proyecto **drand** (la "League of Entropy", un grupo de universidades y empresas que mantiene un servicio público de números aleatorios desde 2019). Cifra un texto de forma que **nadie puede descifrarlo antes de la fecha que elijas: ni tú, ni la web, ni pagando**. Cuando llega la fecha, cualquiera con el texto cifrado puede abrirlo.

- Según sus autores, el cifrado se hace **dentro de tu navegador**: lo que pegas no se envía a ningún sitio.
- El texto cifrado **no es secreto**: puedes guardarlo en tantos sitios como quieras. Antes de la fecha no sirve para nada.
- Técnicamente, solo se podría abrir antes si se pusiera de acuerdo la mayoría de las organizaciones que mantienen la red drand.
- Depende de que la red drand siga funcionando en la fecha de apertura. Lleva años en marcha, pero no es imposible que falle. Por eso guardas el cifrado en varios sitios y por eso cada capa tiene una vía de recuperación.
- La web está en inglés. Los nombres de los botones de esta guía pueden variar un poco.

### Ensayo (la primera vez, 10 minutos)

Antes de guardar una llave de verdad, haz una prueba. **Hazla con los filtros del kit ya puestos** (por ejemplo, después del router), para comprobar que la web carga con el filtro.

1. Abre [https://timevault.drand.love](https://timevault.drand.love).
2. En el cuadro de texto grande escribe `prueba`.
3. Elige como fecha y hora de apertura **dentro de 5 minutos**.
4. Pulsa el botón de cifrar ("Encrypt").
5. Copia el resultado (un bloque de texto largo) y pégalo en el Bloc de notas.
6. Espera a que pase la hora. Vuelve a Timevault, cambia al modo de descifrar ("Decrypt"), pega el texto cifrado y pulsa el botón de descifrar.
7. Debe aparecer `prueba`. Si antes de la hora te da un error, es lo esperado: todavía no se puede abrir.

### Paso a paso con una llave de verdad

**Prepáralo todo antes de abrir el programa:**

1. Abre el navegador. Si te deja, en una ventana **InPrivate** o **de incógnito** (Ctrl + Mayús + N). Si la capa de Windows ya está puesta, el modo privado estará desactivado: usa una ventana normal, no pasa nada.
2. Ve a [https://timevault.drand.love](https://timevault.drand.love).
3. **Aleja la página al 25 %**: pulsa Ctrl y la tecla "-" varias veces. Así, al pegar, el texto será tan pequeño que no se podrá leer. (Para volver al tamaño normal: Ctrl + 0.)
4. Ten preparados:
   - Tu correo, con un mensaje nuevo **para ti**.
   - El **Bloc de notas** abierto.
5. Ten abierta, en otra pestaña o ventana, la pantalla donde vas a poner la contraseña (la del router, por ejemplo).

**Ahora, con el programa:**

6. Haz doble clic en `EJECUTAR-llave.bat` y responde a sus dos preguntas (para qué es la llave y qué tipo). Cuando diga **"Paso 1 de 3"**, el texto para la cápsula ya está copiado: una etiqueta (para qué es y cuándo se creó) y la llave.
7. En Timevault, haz clic en el cuadro de texto grande y pega con **Ctrl+V**. No te pares a mirarlo.
8. Elige la **fecha y hora de apertura**. El programa te sugiere fechas a 30, 60 y 90 días. Elige una hora en la que sueles estar en casa y con calma, por ejemplo por la tarde.
9. Pulsa el botón de cifrar.
10. Copia el **resultado cifrado**, que aparece en otro cuadro: usa su botón de copiar si lo tiene o haz clic dentro de **ese** cuadro y pulsa Ctrl+A y Ctrl+C. Cuidado de no copiar el cuadro donde pegaste.
11. **Sitio 1, correo:** aleja también la ventana del correo (Ctrl y "-") y pega el texto cifrado en el mensaje para ti. **Comprueba que es un bloque largo de caracteres sin sentido que empieza por algo como `-----BEGIN AGE ENCRYPTED FILE-----`.** Si en cambio empieza por "Kit para bloquear contenido adulto", has copiado el cuadro equivocado: bórralo del correo sin leerlo (mira también en Borradores) y vuelve al punto 10. El programa también te avisa si, al pulsar Intro en el paso 1, el portapapeles sigue teniendo el texto sin cifrar. Asunto, por ejemplo: `Cápsula Router - abrir el 09/01/2027`. Debajo del texto cifrado, añade: `Para abrirla: https://timevault.drand.love > Decrypt > pegar este texto`. Envíalo.
12. **Sitio 2, archivo:** pega el texto cifrado en el Bloc de notas y guárdalo como `capsula-router-2027-01-09.txt` en tu nube (OneDrive, Google Drive...) o en un pendrive.
13. Vuelve a la ventana del programa y pulsa **Intro**. Sigue con el paso 2 (poner la llave como contraseña) y el paso 3 (comprobar que abre). El programa vuelve a copiar la llave sola cuando hace falta, así que no importa que hayas copiado el texto cifrado entre medias.
14. Cuando el programa diga **"Listo"**, **borra el cuadro de Timevault donde pegaste** (haz clic dentro, Ctrl+A y Supr) y después cierra la pestaña. Si no lo borras, el navegador puede guardar lo que había en él para "volver a abrir la pestaña cerrada", y con él la llave. Luego vuelve a poner el zoom normal (Ctrl + 0).
15. Comprueba que el correo ha llegado (o está en "Enviados") y que el archivo se abre.
16. Apunta la fecha de apertura en tu calendario y en tu nota de cápsulas.

### Cómo se abre cuando llega la fecha

1. Abre tu correo (o el archivo .txt) y copia el texto cifrado entero.
2. Ve a [https://timevault.drand.love](https://timevault.drand.love), cambia al modo de descifrar ("Decrypt"), pega y pulsa el botón de descifrar.
3. Aparece el texto de la cápsula. **La llave es la última línea.** Selecciónala (con tres clics seguidos sobre ella se selecciona la línea entera) y cópiala.
4. Úsala para entrar donde toque. Las llaves que hay que teclear a mano (por ejemplo, la de Windows en la pantalla de inicio de sesión) las tendrás que escribir: ahora sí puedes verlas.
5. Si tienes **varias cápsulas de la misma capa** (por ejemplo, porque cancelaste una vez a mitad), prueba primero la de fecha de creación más reciente (sale en la etiqueta) y, si no abre, las demás.

Si Timevault no funciona ese día, mira [Si una llave se pierde](#si-una-llave-se-pierde).

---

## La cápsula de respaldo: FutureMe con el texto cifrado

[FutureMe](https://www.futureme.org) es una web que envía cartas a tu correo en una fecha futura. Funciona desde hace más de 20 años. **No es una cápsula segura para la llave a la vista**: según su propio soporte, durante las primeras 48 horas puedes leer y cambiar la carta, la fecha y el destinatario, y con la suscripción de pago (Premium) se pueden **leer, editar o borrar cartas ya selladas**.

Por eso la usamos solo como **respaldo y recordatorio, con el texto cifrado de Timevault dentro, nunca con la llave**. Si un día la abres antes de tiempo, solo verás un texto cifrado que no sirve hasta la fecha.

Sirve para dos cosas: te recuerda el día de apertura y guarda una copia del cifrado fuera de tu correo (si borras tu copia, FutureMe te la manda igualmente ese día).

1. Ve a [https://www.futureme.org](https://www.futureme.org) y empieza una carta nueva. Puede pedirte crear una cuenta gratuita o confirmar tu correo.
2. En la carta pega **el texto cifrado** (no la llave) y añade debajo:
   `Esto es una cápsula de Timevault. Ábrela en https://timevault.drand.love (Decrypt) a partir del 09/01/2027. Si la web no existe, busca la herramienta "tle" de drand: github.com/drand/tlock`
3. Fecha de entrega: **la misma** que pusiste en Timevault, o el día siguiente.
4. Destinatario: tu correo.
5. Si te pregunta si la carta es pública o privada, elige **privada**.
6. Envíala. Cuando llegue la fecha, revisa también la carpeta de spam.

---

## Si la llave la crea otro programa del kit

Los programas de **Windows** y del **móvil** crean sus propias llaves y las copian sin mostrarlas. Solo copian la llave, sin etiqueta, así que en Timevault:

1. Haz clic en el cuadro de texto y **escribe tú la etiqueta** en la primera línea, por ejemplo `Windows - administrador GuardianBloqueo` o `Móvil - PIN de Controles parentales`, y pulsa Intro.
2. Pega la llave con Ctrl+V en la línea de abajo.
3. Sigue desde el punto 8 del paso a paso (fecha, cifrar y guardar el cifrado en dos sitios). Al terminar, borra el cuadro donde pegaste antes de cerrar la pestaña (punto 14).
4. Ojo: cuando copies el texto cifrado, el portapapeles ya no tendrá la llave. Si el programa necesita que la pegues en otro sitio después, búscale la opción de volver a copiarla; si no la tiene, **pega la llave donde haga falta antes de copiar el texto cifrado** (deja Timevault abierto con el cifrado hecho mientras tanto).

**PIN de Controles parentales del móvil:** si se pierde, la única salida es restablecer el móvil de fábrica. Por eso la guía del móvil pide **dos cápsulas**. Haz dos cápsulas Timevault independientes: la segunda con la fecha **una semana más tarde** y guardada en sitios distintos (otro correo, otra nube). Si la primera falla, la segunda llega a los pocos días.

---

## El programa de llaves, en detalle

`EJECUTAR-llave.bat` abre `nueva-llave.ps1` con el PowerShell que trae Windows. No necesita permisos de administrador.

**Lo que hace:**

1. Te pregunta para qué es la llave (va en la etiqueta de la cápsula) y qué tipo necesitas.
2. Guarda cómo tienes el historial y la sincronización del portapapeles y los desactiva mientras trabaja. Si los tenías activados, abre Configuración > Sistema > Portapapeles para que lo compruebes.
3. Crea la llave.
4. **Paso 1:** copia el texto para la cápsula (etiqueta y llave).
5. **Paso 2:** copia la llave sola para que la pongas como contraseña.
6. **Paso 3:** la vuelve a copiar para que compruebes que abre.
7. Vacía el portapapeles y deja el historial y la sincronización como estaban.

En cualquier paso puedes escribir **R** para volver a copiar. En los pasos 1 y 2, **X** cancela. En el paso 2, **F** significa que el sitio no acepta la llave (te deja elegir otro tipo y empieza de nuevo con una llave nueva; la cápsula anterior ya no vale). En el paso 3, **P** te da consejos si la llave no abre y **O** omite la prueba.

Cuando el programa te pide una opción, **salen asteriscos** en vez de lo que escribes. Es a propósito: si pegas la llave ahí sin querer, no aparece en pantalla.

**Dos avisos que te da el programa:**

- Si en el paso 1 pulsas Intro y el portapapeles **sigue teniendo el texto sin cifrar**, te avisa: significa que lo que pegaste en el correo o en el archivo no es el cifrado, sino la llave a la vista.
- En el paso 2 te dice **cuántos caracteres tiene la llave**. Algunos campos de contraseña cortan sin avisar lo que pegas: si ves menos puntos de los que debería haber, no guardes y escribe **F**.

**No pulses Ctrl+C en la ventana del programa**: en esa ventana, Ctrl+C no copia, sino que cierra el programa. Copia siempre en el navegador.

**Para volver a la ventana del programa, haz clic en su barra de título** (la franja de arriba), no dentro del texto. Un clic dentro puede dejarla en modo "Seleccionar" (lo pone en el título): entonces la primera pulsación de Intro no responde y cambia lo que hay en el portapapeles. Si te pasa, pulsa Esc y escribe **R** para volver a copiar.

**Tipos de llave:**

| Tipo | Cuándo | Seguridad |
|---|---|---|
| 20 letras y cifras (por defecto) | Casi siempre | Unos 116 bits: imposible de adivinar |
| 16 letras y cifras | Si el sitio no admite 20 | Unos 93 bits: igual de imposible en la práctica |
| Con un símbolo (`-`, `_` o `.`) | Si el sitio exige un símbolo | Igual que sin él |
| Solo cifras (PIN) | Si el sitio solo admite números | Depende de la longitud; evita secuencias como 1234 |
| Otra longitud (8 a 64) | Si el sitio tiene un límite raro | Cuanto más larga, mejor |

Las llaves no llevan letras que se confunden (`I`, `O`, `l`, `o`, `0`, `1`), ni espacios, comillas, `@`, `$`, `%` u otros símbolos que dan problemas en routers, formularios o teclados de otros idiomas.

**Opciones para usuarios avanzados.** Abre la carpeta `llaves`, haz clic en la barra de direcciones del Explorador, escribe `cmd` y pulsa Intro. En la ventana negra puedes escribir, por ejemplo:

- `EJECUTAR-llave.bat -Para "Router" -Longitud 16`
- `EJECUTAR-llave.bat -ConSimbolo`
- `EJECUTAR-llave.bat -SoloNumeros -Longitud 6`
- `EJECUTAR-llave.bat -PorTrozos`

**Modo "por trozos" (`-PorTrozos`).** Solo para teclear la llave en un aparato donde no se puede pegar y que no tenga su propio programa en el kit (el del móvil la teclea por cable sin que la veas, y eso es mejor). En este modo el programa **te enseña la llave de 4 en 4 caracteres**, borrando la pantalla entre trozo y trozo. La vas a ver: no intentes recordarla y usa este modo solo si no hay otra forma. Distingue mayúsculas y minúsculas, y vigila que el teclado del móvil no ponga sola la primera letra en mayúscula. Al terminar, **cierra la ventana del programa**: así desaparece cualquier trozo que pudiera quedar más arriba.

**Si cierras la ventana a mitad** (o pulsas Ctrl+C en ella): la llave desaparece (no está en ningún archivo). Si ya la habías puesto como contraseña, la buena es la de la cápsula que acabas de hacer. Copia cualquier palabra para sustituir lo que quedara en el portapapeles y revisa Configuración > Sistema > Portapapeles para dejarlo como te guste.

---

## Otras cápsulas y por qué no las recomendamos

| Opción | ¿Aguanta un mal momento? | Riesgo de perder la llave | Coste | ¿La usamos? |
|---|---|---|---|---|
| **Timevault** | Muy bien: nadie puede abrirla antes | Bajo-medio: depende de drand; se compensa guardando el cifrado en varios sitios | Gratis | **Sí, la principal** |
| **FutureMe con el texto cifrado** | No hay llave dentro | — | Gratis | **Sí, de respaldo** |
| FutureMe con la llave a la vista | Poco: editable 48 horas y Premium abre las cartas selladas | Bajo-medio | Gratis (Premium de pago) | No |
| Correo programado (Gmail, Outlook) | Muy poco: el mensaje está en "Programados" y se abre o se cancela al momento | Bajo | Gratis | No con la llave. Sí como recordatorio con el texto cifrado |
| Caja fuerte con temporizador | Regular, y suelen admitir plazos cortos (comprueba el máximo antes de comprar) | Medio: pilas, mecanismo; algunas se pueden romper | Variable | No: la llave tendría que estar en papel |
| Notaría (acta de depósito) o un profesional de confianza | Bien | Muy bajo | Por confirmar con la notaría o el profesional | No encaja: la llave tendría que estar en papel. Si lo valoras, pregunta antes si te la devolverían si la pides antes de la fecha |

**¿Por qué no en papel?** Para imprimir la llave, Windows la escribe en la cola de impresión del disco, y al doblar el papel la verías. Este kit nunca escribe la llave en disco. Una caja con temporizador sí puede servir para otra cosa: guardar el móvil por la noche (ver [`../APOYO.md`](../APOYO.md)).

---

## Renovar cuando llega la fecha

El día que se abre una cápsula, **no hace falta decidir nada en el momento**. Elige un rato tranquilo (mejor de día y no cuando estés con el bajón o con cansancio).

Tus opciones:

- **Renovar igual** (lo más habitual las primeras veces).
- **Renovar con más o menos plazo.**
- **Aflojar alguna capa** que te esté dando problemas en el día a día.
- **Deshacerlo** (cada guía tiene su sección "Cómo deshacerlo").

**Para renovar una capa:**

1. Abre la cápsula y copia la llave antigua ([Cómo se abre](#cómo-se-abre-cuando-llega-la-fecha)).
2. Entra con ella donde toque (el router, por ejemplo) y ve a la página de cambiar la contraseña.
3. Ejecuta `EJECUTAR-llave.bat` y haz la cápsula nueva (paso 1).
4. En el paso 2, pega en "Contraseña actual" la **llave antigua** (cópiala de nuevo de Timevault) y, después, escribe **R** en el programa para volver a copiar la **nueva** y pégala en "Contraseña nueva" y "Repetir".
5. Comprueba que abre (paso 3).
6. Actualiza tu nota de cápsulas. Las cápsulas antiguas puedes borrarlas: su llave ya no vale.

Para Windows y el móvil, sus guías explican cómo poner una llave nueva con sus propios programas.

---

## Cómo deshacerlo (cuando llegue la llave)

El programa de llaves **no deja nada cambiado**: solo toca el historial y la sincronización del portapapeles mientras trabaja y los deja como estaban al terminar. Si se cerró a mitad, revisa Configuración > Sistema > Portapapeles y déjalo a tu gusto.

Para deshacer el bloqueo de una capa:

1. Abre su cápsula ([Cómo se abre](#cómo-se-abre-cuando-llega-la-fecha)).
2. Sigue la sección "Cómo deshacerlo" de su guía:
   - Router: [`../router/GUIA.md`](../router/GUIA.md)
   - PC: [`../windows/GUIA.md`](../windows/GUIA.md)
   - Móvil: [`../android/GUIA.md`](../android/GUIA.md)

---

## Si una llave se pierde

**1. Busca bien antes de nada:**

- El correo: bandeja de entrada, **spam**, "Enviados" y la búsqueda por "Cápsula".
- El archivo .txt en tu nube o tu pendrive.
- La carta de FutureMe, que llega el día de apertura.
- La segunda cápsula, si hiciste dos.

**2. Si Timevault no funciona ese día:**

- Espera un día y vuelve a probar.
- El texto cifrado también se abre con **`tle`**, la herramienta oficial de drand para la línea de comandos ([github.com/drand/tlock](https://github.com/drand/tlock)). Alguien con conocimientos técnicos puede instalarla (`go install github.com/drand/tlock/cmd/tle@latest`), guardar el texto cifrado en un archivo y ejecutar `tle -d capsula.txt`. Existe también una versión en Rust (tlock-rs).

**3. Si no hay manera, usa la vía de recuperación de esa capa:**

| Capa | Vía de recuperación |
|---|---|
| Router | Botón de reset (10 a 30 segundos): vuelve la contraseña de la pegatina. Ver [`../router/GUIA.md`](../router/GUIA.md) |
| Administrador de Windows | Restablecer o reinstalar Windows, con tu copia de seguridad y, si el disco está cifrado, la clave de recuperación de BitLocker. Ver [`../windows/GUIA.md`](../windows/GUIA.md) |
| Programa bloqueador del PC | Su soporte o la guía de Windows |
| PIN de Controles parentales del móvil | Restablecer el móvil de fábrica (te pedirá tu cuenta de Google de siempre). Ver [`../android/GUIA.md`](../android/GUIA.md) |
| PIN de Google Play | Borrar los datos de la app Play Store |
| AppBlock con PIN | Desbloqueo de emergencia de su soporte, o restablecer el móvil |
| Cuentas con recuperación por correo | "He olvidado mi contraseña" |

Estas vías son también huecos: el sistema es tan fuerte como su salida más fácil. Están ahí para que **nunca** te quedes con un aparato inservible, y cuestan tiempo y esfuerzo, que es justo lo que te protege.

---

## Fugas que hay que evitar

- [ ] **Historial del portapapeles** (Win+V) y "Compartir entre dispositivos": desactivados. El programa además marca la llave para que no entre.
- [ ] **Enlace Móvil:** "Copiar y pegar entre dispositivos" desactivado.
- [ ] **Navegador o gestor de contraseñas** (Chrome, Edge, Gestor de contraseñas de Google, Samsung Pass): siempre **"Nunca"**. Si guardó una llave por error, bórrala del gestor y crea una llave nueva.
- [ ] **Página al 25 %** al pegar en la cápsula. Al terminar, **borra el cuadro donde pegaste** (Ctrl+A y Supr) y cierra la pestaña de Timevault.
- [ ] **Recall** en pausa (si tu PC lo tiene y lo activaste).
- [ ] Nadie compartiendo ni grabando la pantalla. Ni fotos ni capturas.
- [ ] **Nunca** mandes la llave por correo, mensajería ni a FutureMe: solo el texto cifrado.
- [ ] Si copias algo en el móvil, el teclado (Gboard, Samsung Keyboard) guarda un historial del portapapeles: bórralo.

---

## Preguntas frecuentes

**¿Y si de verdad la necesito antes de tiempo, por una urgencia?**
Siempre hay una salida: la vía de recuperación de cada capa ([tabla de arriba](#si-una-llave-se-pierde)). En el router, por ejemplo, el reset tarda cinco minutos. Lo que no hay es un atajo cómodo, y de eso se trata.

**¿Puedo usar la misma llave para dos cosas?**
No. Si abres una cápsula, se abrirían las dos capas a la vez.

**¿Por qué la cápsula lleva una etiqueta?**
Para que, cuando se abra dentro de dos meses, sepas de qué capa es y cuándo la creaste.

**El sitio no acepta la llave.**
Escribe **F** en el paso 2 del programa y elige 16 caracteres, "con un símbolo" u otra longitud. La cápsula que habías hecho ya no vale: bórrala. Haz lo mismo si el campo muestra **menos puntos** de los que tiene la llave: algunos campos la cortan sin avisar.

**La llave no abre en la prueba (paso 3).**
Escribe **P** en el programa y sigue sus consejos. Si al guardarla el campo tenía menos puntos de los debidos, el sitio la cortó: pega la llave en el inicio de sesión y pulsa Retroceso hasta dejar los mismos puntos que había. Si no hay manera, usa la vía de recuperación de esa capa ([Si una llave se pierde](#si-una-llave-se-pierde)).

**¿Y si con los filtros puestos Timevault no carga?**
Por eso el ensayo se hace con los filtros ya puestos. Si no carga, no guardes llaves de verdad en ella hasta resolverlo: busca ayuda técnica para usar `tle`, o usa de forma provisional otra cápsula sabiendo que es más débil.

**¿El programa guarda algo en el PC?**
No. La llave solo vive en la memoria mientras el programa está abierto. No hay archivos ni registros. Lo único que toca son tres ajustes del portapapeles, que deja como estaban.

**Me dice "Windows protegió su PC".**
Pulsa **Más información** > **Ejecutar de todas formas**. Pasa con los programas descargados de internet.

---

## Detalles técnicos y fuentes

Para quien quiera revisar el programa:

- **Generador:** `System.Security.Cryptography.RandomNumberGenerator` de .NET, con descarte de bytes para que no haya sesgo. Alfabeto de 56 caracteres (`A-Z` sin `I` ni `O`, `a-z` sin `l` ni `o`, `2-9`): unos 5,8 bits por carácter, 116 bits con 20 caracteres y 93 con 16. Exige mayúscula, minúscula y cifra. El modo con símbolo mete uno de `- _ .` en una posición al azar que nunca es la primera ni la última. El modo PIN descarta secuencias de cuatro cifras en progresión (1234, 7777, 1357...).
- **Portapapeles:** copia con `System.Windows.Forms.DataObject` y añade los formatos que Microsoft documenta para excluir el contenido del historial y de la nube (`CanIncludeInClipboardHistory` = 0, `CanUploadToCloudClipboard` = 0, `ExcludeClipboardContentFromMonitorProcessing`) y el formato `Clipboard Viewer Ignore`, que respetan muchos gestores de portapapeles. Comprueba la copia leyéndola sin mostrarla. Al pulsar Intro en el paso 1, compara el portapapeles con el texto sin cifrar (sin mostrarlo) para avisar si no se ha copiado el cifrado. Al final la borra con `Clipboard.Clear()`; por si el programa se corta con Ctrl+C, el bloque final vacía el portapapeles y restaura el registro primero con llamadas directas a .NET.
- **Registro:** guarda, pone a 0 y restaura `EnableClipboardHistory`, `EnableCloudClipboard` y `CloudClipboardAutomaticUpload` en `HKCU\Software\Microsoft\Clipboard` (sin permisos de administrador). Microsoft no documenta si ese cambio se aplica al momento; por eso los formatos de exclusión son la protección principal y el programa abre Configuración para que lo compruebes.
- **Qué evita:** nunca usa `Set-Clipboard` con `-Verbose` o `-WhatIf` (enseñarían los primeros caracteres) ni `clip.exe` (añade un salto de línea). Descarta toda la salida del programa que no sea texto de pantalla, lee las opciones como texto protegido (asteriscos) y no escribe nada en disco.
- **Probado** con PowerShell 7 en Linux (sintaxis compatible con Windows PowerShell 5.1 y flujo completo con el portapapeles simulado). Pendiente de probar en un Windows real.

Fuentes:

- Microsoft: [formatos del portapapeles](https://learn.microsoft.com/windows/win32/dataxchg/clipboard-formats), [Set-Clipboard en PowerShell 5.1](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/set-clipboard?view=powershell-5.1).
- drand: [tlock y la herramienta tle](https://github.com/drand/tlock), [Timevault](https://github.com/drand/timevault), [tlock-js](https://github.com/drand/tlock-js), [artículo científico](https://eprint.iacr.org/2023/189).
- FutureMe: [desbloquear una carta futura](https://support.futureme.org/hc/en-us/articles/4485416462095-How-can-I-unlock-a-future-letter-to-edit-read-in-advance), [cambiar la fecha de entrega](https://support.futureme.org/hc/en-us/articles/4566491124751-How-do-I-edit-the-delivery-date-of-my-letter), [ventana de 48 horas](https://support.futureme.org/hc/en-us/articles/5147874987407-How-can-I-edit-a-future-letter-within-the-48-hour-window-after-sending-it-FutureMe-website), [condiciones](https://www.futureme.org/pages/tos).
