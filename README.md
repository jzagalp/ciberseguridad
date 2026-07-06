# 🛡️ CyberPath — Tu manager de aprendizaje en ciberseguridad

Un programa que **te enseña ciberseguridad desde cero** y se ocupa de toda la
organización por ti: te arma la ruta completa, te dice **qué hacer cada día y
cómo hacerlo**, y **monitoriza tu progreso** automáticamente. Tú solo te dedicas
a aprender la habilidad.

No necesitas instalar nada ni saber programar. Es una aplicación web que se abre
en tu navegador y guarda todo tu progreso en tu propio equipo.

---

## ▶️ Cómo empezar

**Opción A — abrir directamente (la más fácil):**

1. Descarga o clona esta carpeta.
2. Haz doble clic en **`index.html`**. Se abrirá en tu navegador.
3. Completa la bienvenida (nombre, minutos al día y días de estudio) y listo.

**Opción B — con un servidor local (opcional):**

```bash
# dentro de la carpeta del proyecto
python3 -m http.server 8000
# luego abre http://localhost:8000 en el navegador
```

**Opción C — publicarlo en la web (GitHub Pages):**
activa Pages en el repositorio (rama principal, carpeta raíz) y tendrás tu
manager accesible desde cualquier dispositivo.

---

## 🧭 Qué hace cada sección

| Sección | Para qué sirve |
|---|---|
| **🏠 Inicio** | Tu panel de mando: progreso global, racha, horas, fase actual y la misión de hoy, con gráficas. |
| **🎯 Hoy** | Lo único que tienes que mirar cada día: las tareas que te tocan, con instrucciones paso a paso y recursos. Marca lo que completas. |
| **🗺️ Ruta** | El temario completo (6 fases). Explora, marca, salta o expande cualquier tarea. |
| **📈 Progreso** | Tus estadísticas y gráficas: avance por fase, minutos por día, horas acumuladas y fecha estimada de fin. |
| **⚙️ Ajustes** | Ajusta tu ritmo, añade tus propias tareas, cambia el tema y exporta/importa tu progreso. |

---

## 🤖 Cómo te organiza (el "manager")

- Le dices **cuántos minutos** puedes estudiar al día y **qué días**.
- El programa reparte automáticamente todo el temario en tu calendario y te
  muestra en **Hoy** justo lo que cabe en tu tiempo diario.
- Cuando completas una tarea, **se reorganiza solo**: recalcula tu progreso, tu
  racha, tus horas y tu **fecha estimada de finalización**.
- ¿Terminaste antes? Pulsa **"Hacer más"**. ¿Quieres cambiar algo? Puedes
  **saltar** tareas, **añadir las tuyas** o registrar minutos de estudio a mano.

---

## 📚 La ruta de aprendizaje

De cero a nivel junior, con base **ofensiva y defensiva**:

0. **Fundamentos de informática y redes** — hardware, sistemas operativos, redes, laboratorio virtual.
1. **Linux y scripting** — terminal, administración, Bash y Python.
2. **Fundamentos de seguridad** — CIA, criptografía, identidad, ética y ley.
3. **Hacking ético ofensivo (Red Team)** — recon, Nmap, OWASP Top 10, explotación, escalada.
4. **Defensa (Blue Team)** — hardening, SIEM, respuesta a incidentes, malware.
5. **Especialización, práctica y certificaciones** — TryHackMe, HTB, certis y portafolio.

Cada tarea incluye **cómo hacerla** y **recursos gratuitos** (OverTheWire,
PortSwigger, TryHackMe, Professor Messer, OWASP, etc.).

---

## 💾 Tus datos

Todo tu progreso se guarda **localmente en tu navegador** (`localStorage`); nada
se envía a ningún servidor. Desde **Ajustes → Copia de seguridad** puedes
**exportar** un archivo `.json` para no perderlo o llevarlo a otro equipo, e
**importarlo** cuando quieras.

> ⚠️ Si borras los datos del navegador o usas modo incógnito, perderás el
> progreso no exportado. Exporta de vez en cuando.

---

## ⚖️ Uso responsable

Practica **solo** en tu propio laboratorio o en plataformas pensadas para ello
(TryHackMe, Hack The Box, OverTheWire, `scanme.nmap.org`, OWASP Juice Shop…).
Probar sistemas sin autorización es ilegal. La Fase 2 incluye un módulo de ética
y aspectos legales: léelo antes de la parte ofensiva.

---

## 🛠️ Estructura del proyecto

```
ciberseguridad/
├─ index.html          # la aplicación
├─ css/styles.css      # diseño (claro/oscuro, responsive)
└─ js/
   ├─ curriculum.js    # todo el temario (puedes ampliarlo)
   ├─ store.js         # guardado local del progreso
   ├─ scheduler.js     # el "manager": plan diario y estadísticas
   ├─ charts.js        # gráficas en SVG
   └─ app.js           # interfaz y navegación
```

¿Quieres añadir contenido? Edita `js/curriculum.js`: cada tarea es un objeto con
`title`, `type`, `minutes`, `summary`, `steps[]` y `resources[]`.

Hecho para que solo te preocupes de una cosa: **aprender**. 🚀
