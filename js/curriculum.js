/* ============================================================================
 *  CURRÍCULO DE CIBERSEGURIDAD — de cero a competente
 *  ---------------------------------------------------------------------------
 *  Este archivo define TODO el temario. La app lo lee para generar tu plan
 *  diario, tu hoja de ruta y tu progreso. Puedes ampliarlo o modificarlo:
 *  cada tarea es un objeto con { id, title, type, minutes, summary, steps[],
 *  resources[] }.
 *
 *  Tipos de tarea (type):
 *    lectura     — leer / estudiar un concepto
 *    video       — ver un curso o explicación en video
 *    laboratorio — montar o practicar en un entorno controlado
 *    practica    — resolver ejercicios / máquinas / retos
 *    proyecto    — construir algo propio y documentarlo
 *    quiz        — autoevaluación para consolidar
 * ==========================================================================*/

const CURRICULUM = {
  meta: {
    version: '1.0.0',
    title: 'Ruta completa de Ciberseguridad',
    subtitle: 'De cero a nivel junior con base ofensiva y defensiva',
  },

  phases: [
    /* =====================================================================
     * FASE 0 — FUNDAMENTOS DE INFORMÁTICA Y REDES
     * ===================================================================*/
    {
      id: 'f0',
      title: 'Fundamentos de informática y redes',
      subtitle: 'Cómo funcionan de verdad los computadores, los sistemas y las redes.',
      icon: '🧱',
      goal: 'Entender qué pasa por dentro de una máquina y de una red antes de tocar seguridad.',
      modules: [
        {
          id: 'f0-m1',
          title: 'Cómo funciona un computador',
          objective: 'Comprender hardware, binario y qué hace un sistema operativo.',
          tasks: [
            {
              id: 'f0-m1-t1', type: 'lectura', minutes: 40,
              title: 'Partes de un computador y qué hace cada una',
              summary: 'CPU, RAM, almacenamiento, placa base y cómo colaboran para ejecutar un programa.',
              steps: [
                'Lee sobre CPU, memoria RAM, disco (HDD/SSD), placa base y GPU.',
                'Dibuja en papel el flujo: encender → BIOS/UEFI → cargar SO → ejecutar programa.',
                'Anota en tus notas qué componente guarda datos de forma temporal y cuál de forma permanente.',
              ],
              resources: [
                { label: 'CS50 - Cómo funciona un ordenador (video)', url: 'https://cs50.harvard.edu/x/' },
                { label: 'Khan Academy: dentro del ordenador', url: 'https://es.khanacademy.org/computing/computers-and-internet' },
              ],
            },
            {
              id: 'f0-m1-t2', type: 'lectura', minutes: 35,
              title: 'Sistemas de numeración: binario y hexadecimal',
              summary: 'Por qué los computadores usan 0 y 1, y cómo convertir a decimal y hexadecimal.',
              steps: [
                'Aprende a convertir decimal ↔ binario ↔ hexadecimal.',
                'Practica convirtiendo 5 números a mano.',
                'Entiende qué es un bit, un byte y por qué una IP se escribe en 4 bytes.',
              ],
              resources: [
                { label: 'Binario para principiantes (Khan Academy)', url: 'https://es.khanacademy.org/computing/computer-science' },
              ],
            },
            {
              id: 'f0-m1-t3', type: 'quiz', minutes: 15,
              title: 'Autoevaluación: fundamentos de hardware',
              summary: 'Comprueba que puedes explicar sin mirar qué hace la RAM, la CPU y el disco.',
              steps: [
                'Explica en voz alta la diferencia entre RAM y disco.',
                'Convierte 173 a binario y a hexadecimal sin ayuda.',
                'Si fallas algo, vuelve a la tarea correspondiente.',
              ],
              resources: [],
            },
          ],
        },
        {
          id: 'f0-m2',
          title: 'Sistemas operativos',
          objective: 'Saber qué hace un SO y moverte con soltura por Windows y Linux.',
          tasks: [
            {
              id: 'f0-m2-t1', type: 'lectura', minutes: 40,
              title: 'Qué es un sistema operativo',
              summary: 'Procesos, memoria, archivos, permisos y usuarios: las 4 cosas que gestiona todo SO.',
              steps: [
                'Lee sobre procesos, gestión de memoria, sistema de archivos y usuarios/permisos.',
                'Compara a alto nivel Windows, Linux y macOS.',
                'Anota qué es un "proceso" y qué es un "servicio".',
              ],
              resources: [
                { label: 'OverTheWire (prepara el terreno para practicar)', url: 'https://overthewire.org/wargames/' },
              ],
            },
            {
              id: 'f0-m2-t2', type: 'laboratorio', minutes: 30,
              title: 'Explora tu propio sistema de archivos',
              summary: 'Navega carpetas, mira procesos en ejecución y usuarios de tu equipo actual.',
              steps: [
                'En Windows abre el Administrador de tareas; en Linux/mac abre el monitor del sistema.',
                'Identifica 3 procesos y busca en internet para qué sirven.',
                'Localiza dónde se guardan tus documentos y la carpeta de tu usuario.',
              ],
              resources: [],
            },
          ],
        },
        {
          id: 'f0-m3',
          title: 'Redes desde cero',
          objective: 'Entender cómo viaja la información por internet: la base de casi toda la ciberseguridad.',
          tasks: [
            {
              id: 'f0-m3-t1', type: 'video', minutes: 60,
              title: 'Modelo OSI y TCP/IP',
              summary: 'Las 7 capas del modelo OSI y cómo se relacionan con TCP/IP.',
              steps: [
                'Mira una explicación de las 7 capas OSI con ejemplos reales.',
                'Aprende qué capa usa: un cable, una IP, un puerto, HTTP.',
                'Haz una tabla propia OSI ↔ TCP/IP.',
              ],
              resources: [
                { label: 'Professor Messer - Network+ (gratis, en inglés)', url: 'https://www.professormesser.com/network-plus/n10-008/n10-008-video/n10-008-training-course/' },
              ],
            },
            {
              id: 'f0-m3-t2', type: 'lectura', minutes: 50,
              title: 'IP, subredes, puertos, DNS y HTTP',
              summary: 'Direcciones IP públicas y privadas, puertos comunes, cómo un dominio se convierte en IP.',
              steps: [
                'Aprende IPv4, IP privada vs pública y qué es una subred (CIDR /24).',
                'Memoriza puertos clave: 80, 443, 22, 53, 25, 3389.',
                'Entiende el flujo DNS: escribes una web → se resuelve a IP → se conecta.',
              ],
              resources: [
                { label: 'Cloudflare Learning - DNS', url: 'https://www.cloudflare.com/learning/dns/what-is-dns/' },
              ],
            },
            {
              id: 'f0-m3-t3', type: 'practica', minutes: 40,
              title: 'Practica redes con comandos reales',
              summary: 'Usa ping, tracert/traceroute, nslookup e ipconfig/ifconfig en tu equipo.',
              steps: [
                'Ejecuta ping a google.com y observa el tiempo de respuesta.',
                'Usa tracert (Windows) o traceroute (Linux) hacia una web y observa los saltos.',
                'Usa nslookup para ver a qué IP resuelve un dominio.',
                'Con ipconfig/ifconfig encuentra tu IP privada.',
              ],
              resources: [],
            },
          ],
        },
        {
          id: 'f0-m4',
          title: 'Monta tu laboratorio',
          objective: 'Crear un entorno seguro y aislado para practicar hacking sin riesgo legal ni técnico.',
          tasks: [
            {
              id: 'f0-m4-t1', type: 'laboratorio', minutes: 60,
              title: 'Instala VirtualBox y crea tu primera máquina virtual',
              summary: 'Un laboratorio virtual te deja romper y experimentar sin dañar tu equipo real.',
              steps: [
                'Descarga e instala VirtualBox (o VMware Workstation Player).',
                'Aprende qué es una máquina virtual y por qué aísla tus pruebas.',
                'Crea una VM vacía para familiarizarte con la configuración de CPU/RAM/red.',
              ],
              resources: [
                { label: 'VirtualBox (descarga oficial)', url: 'https://www.virtualbox.org/' },
              ],
            },
            {
              id: 'f0-m4-t2', type: 'laboratorio', minutes: 70,
              title: 'Instala Kali Linux en una VM',
              summary: 'Kali es la distribución con herramientas de seguridad ya integradas.',
              steps: [
                'Descarga la imagen de Kali Linux para VirtualBox.',
                'Impórtala o instálala en una máquina virtual.',
                'Configura la red en modo NAT o Host-Only para mantenerla aislada.',
                'Actualiza el sistema con sudo apt update && sudo apt upgrade.',
              ],
              resources: [
                { label: 'Kali Linux (descargas)', url: 'https://www.kali.org/get-kali/' },
              ],
            },
            {
              id: 'f0-m4-t3', type: 'proyecto', minutes: 40,
              title: 'Crea tu sistema de notas',
              summary: 'Los profesionales documentan TODO. Empieza tu segundo cerebro desde el día uno.',
              steps: [
                'Elige una herramienta de notas (Obsidian, Notion, CherryTree o Markdown en carpetas).',
                'Crea secciones: Comandos, Conceptos, Máquinas resueltas, Errores y soluciones.',
                'Apunta hoy 3 cosas que aprendiste esta fase.',
              ],
              resources: [
                { label: 'Obsidian (notas en Markdown)', url: 'https://obsidian.md/' },
              ],
            },
          ],
        },
      ],
    },

    /* =====================================================================
     * FASE 1 — LINUX Y SCRIPTING
     * ===================================================================*/
    {
      id: 'f1',
      title: 'Linux y scripting',
      subtitle: 'Domina la terminal de Linux y automatiza con Bash y Python.',
      icon: '🐧',
      goal: 'Moverte por Linux como en casa y escribir tus propios scripts.',
      modules: [
        {
          id: 'f1-m1',
          title: 'Linux esencial',
          objective: 'Sobrevivir y prosperar en la línea de comandos de Linux.',
          tasks: [
            {
              id: 'f1-m1-t1', type: 'lectura', minutes: 45,
              title: 'Comandos básicos de navegación y archivos',
              summary: 'ls, cd, pwd, cp, mv, rm, mkdir, cat, less, find, grep.',
              steps: [
                'Aprende a moverte (cd, ls, pwd) y a manipular archivos (cp, mv, rm, mkdir).',
                'Aprende a ver contenido (cat, less, head, tail) y buscar (find, grep).',
                'Anota cada comando nuevo en tu sistema de notas con un ejemplo.',
              ],
              resources: [
                { label: 'Linux Journey (interactivo, gratis)', url: 'https://linuxjourney.com/' },
              ],
            },
            {
              id: 'f1-m1-t2', type: 'lectura', minutes: 40,
              title: 'Permisos, usuarios y propietarios',
              summary: 'chmod, chown, el sistema rwx y por qué es la base de la seguridad en Linux.',
              steps: [
                'Entiende los permisos rwx para usuario, grupo y otros.',
                'Aprende a leer y cambiar permisos con chmod (numérico 755 y simbólico).',
                'Entiende root, sudo y por qué no debes trabajar siempre como root.',
              ],
              resources: [
                { label: 'Linux permissions explained', url: 'https://linuxjourney.com/lesson/file-permissions' },
              ],
            },
            {
              id: 'f1-m1-t3', type: 'practica', minutes: 90,
              title: 'OverTheWire: Bandit (niveles 0 a 10)',
              summary: 'El mejor wargame para aprender la terminal jugando a "capturar la contraseña".',
              steps: [
                'Conéctate por SSH al reto Bandit nivel 0.',
                'Resuelve del nivel 0 al 10, apuntando cada comando nuevo.',
                'Si te atascas, lee la pista pero intenta entender el porqué.',
              ],
              resources: [
                { label: 'OverTheWire: Bandit', url: 'https://overthewire.org/wargames/bandit/' },
              ],
            },
          ],
        },
        {
          id: 'f1-m2',
          title: 'Administración de Linux',
          objective: 'Gestionar procesos, servicios, paquetes y red desde la terminal.',
          tasks: [
            {
              id: 'f1-m2-t1', type: 'lectura', minutes: 40,
              title: 'Procesos, servicios y paquetes',
              summary: 'ps, top, kill, systemctl, apt: controlar qué se ejecuta en la máquina.',
              steps: [
                'Aprende a ver procesos (ps aux, top/htop) y a terminarlos (kill).',
                'Gestiona servicios con systemctl (start, stop, status, enable).',
                'Instala y elimina software con apt.',
              ],
              resources: [],
            },
            {
              id: 'f1-m2-t2', type: 'practica', minutes: 60,
              title: 'OverTheWire: Bandit (niveles 11 a 20)',
              summary: 'Sube de nivel con SSH, cron, redes y manipulación de datos.',
              steps: [
                'Continúa Bandit desde el nivel 11.',
                'Presta atención a los niveles con nc (netcat) y SSH: se usan mucho en seguridad.',
                'Documenta las técnicas nuevas.',
              ],
              resources: [
                { label: 'OverTheWire: Bandit', url: 'https://overthewire.org/wargames/bandit/' },
              ],
            },
          ],
        },
        {
          id: 'f1-m3',
          title: 'Scripting con Bash',
          objective: 'Automatizar tareas repetitivas con tus propios scripts.',
          tasks: [
            {
              id: 'f1-m3-t1', type: 'lectura', minutes: 50,
              title: 'Fundamentos de Bash',
              summary: 'Variables, condicionales, bucles, argumentos y tuberías (pipes).',
              steps: [
                'Aprende variables, if/else, for/while y a leer argumentos ($1, $2).',
                'Entiende las tuberías | y la redirección > >> < para encadenar comandos.',
                'Escribe un script que salude con el nombre que le pases.',
              ],
              resources: [
                { label: 'Bash scripting cheatsheet', url: 'https://devhints.io/bash' },
              ],
            },
            {
              id: 'f1-m3-t2', type: 'proyecto', minutes: 60,
              title: 'Proyecto: script de reconocimiento básico',
              summary: 'Un script que reciba una IP y ejecute ping, y guarde el resultado en un archivo.',
              steps: [
                'Crea un script que reciba una IP como argumento.',
                'Que haga ping y guarde si la máquina responde en un log con fecha.',
                'Añade comentarios y súbelo a tu carpeta de proyectos (o a GitHub).',
              ],
              resources: [],
            },
          ],
        },
        {
          id: 'f1-m4',
          title: 'Python para seguridad',
          objective: 'Leer y escribir scripts en Python, el lenguaje rey en ciberseguridad.',
          tasks: [
            {
              id: 'f1-m4-t1', type: 'video', minutes: 90,
              title: 'Python desde cero',
              summary: 'Tipos, variables, listas, diccionarios, funciones, bucles y archivos.',
              steps: [
                'Sigue un curso introductorio de Python (variables, listas, dicts, funciones).',
                'Aprende a leer/escribir archivos y a usar librerías (import).',
                'Escribe un programa que cuente las líneas de un archivo de texto.',
              ],
              resources: [
                { label: 'Python.org - tutorial oficial', url: 'https://docs.python.org/es/3/tutorial/' },
                { label: 'freeCodeCamp: Python (video)', url: 'https://www.youtube.com/watch?v=rfscVS0vtbw' },
              ],
            },
            {
              id: 'f1-m4-t2', type: 'proyecto', minutes: 70,
              title: 'Proyecto: escáner de puertos en Python',
              summary: 'Construye un mini escáner que compruebe qué puertos están abiertos en una IP.',
              steps: [
                'Usa la librería socket para intentar conectar a una lista de puertos.',
                'Prueba SOLO contra tu propia VM o localhost (nunca contra sistemas ajenos).',
                'Imprime qué puertos están abiertos y guarda el resultado.',
              ],
              resources: [
                { label: 'Python socket docs', url: 'https://docs.python.org/es/3/library/socket.html' },
              ],
            },
          ],
        },
      ],
    },

    /* =====================================================================
     * FASE 2 — FUNDAMENTOS DE SEGURIDAD
     * ===================================================================*/
    {
      id: 'f2',
      title: 'Fundamentos de seguridad',
      subtitle: 'Los conceptos que sostienen toda la ciberseguridad: CIA, cripto e identidad.',
      icon: '🛡️',
      goal: 'Hablar el idioma de la seguridad y entender por qué existen los ataques.',
      modules: [
        {
          id: 'f2-m1',
          title: 'Conceptos de seguridad',
          objective: 'Entender la tríada CIA, amenazas, vulnerabilidades y riesgo.',
          tasks: [
            {
              id: 'f2-m1-t1', type: 'lectura', minutes: 45,
              title: 'Tríada CIA y terminología esencial',
              summary: 'Confidencialidad, Integridad, Disponibilidad; amenaza, vulnerabilidad, riesgo, exploit.',
              steps: [
                'Aprende la tríada CIA con un ejemplo real de cada una.',
                'Diferencia amenaza vs vulnerabilidad vs riesgo vs exploit.',
                'Entiende defensa en profundidad y superficie de ataque.',
              ],
              resources: [
                { label: 'Professor Messer - Security+ (gratis)', url: 'https://www.professormesser.com/security-plus/sy0-701/sy0-701-video/sy0-701-comptia-security-plus-course/' },
              ],
            },
            {
              id: 'f2-m1-t2', type: 'lectura', minutes: 40,
              title: 'Tipos de atacantes e ingeniería social',
              summary: 'Quién ataca y por qué; phishing como el vector nº1.',
              steps: [
                'Conoce los perfiles: script kiddies, insiders, hacktivistas, APTs.',
                'Estudia phishing, pretexting, baiting y por qué el humano es el eslabón débil.',
                'Anota 5 señales para detectar un correo de phishing.',
              ],
              resources: [],
            },
          ],
        },
        {
          id: 'f2-m2',
          title: 'Criptografía práctica',
          objective: 'Entender hashing, cifrado simétrico/asimétrico y TLS sin ser matemático.',
          tasks: [
            {
              id: 'f2-m2-t1', type: 'lectura', minutes: 55,
              title: 'Hashing vs cifrado vs codificación',
              summary: 'MD5/SHA, AES, RSA: qué es cada uno y cuándo se usa.',
              steps: [
                'Entiende que el hashing es de una sola vía (para contraseñas e integridad).',
                'Diferencia cifrado simétrico (AES) y asimétrico (RSA, clave pública/privada).',
                'Entiende por qué Base64 NO es cifrado (solo codificación).',
              ],
              resources: [
                { label: 'Cloudflare - qué es el cifrado', url: 'https://www.cloudflare.com/learning/ssl/what-is-encryption/' },
              ],
            },
            {
              id: 'f2-m2-t2', type: 'practica', minutes: 45,
              title: 'Practica hashing y cifrado',
              summary: 'Genera hashes, identifícalos y prueba cifrar/descifrar.',
              steps: [
                'Genera un hash SHA-256 de una palabra con sha256sum o Python.',
                'Usa CyberChef para pasar texto por Base64, hex y hashes.',
                'Identifica un hash con hash-identifier o herramientas online.',
              ],
              resources: [
                { label: 'CyberChef (navaja suiza del cifrado)', url: 'https://gchq.github.io/CyberChef/' },
              ],
            },
            {
              id: 'f2-m2-t3', type: 'lectura', minutes: 40,
              title: 'TLS, HTTPS y certificados',
              summary: 'Cómo tu navegador establece una conexión segura y qué garantiza el candado.',
              steps: [
                'Entiende el handshake TLS a alto nivel.',
                'Aprende qué es un certificado y una Autoridad Certificadora (CA).',
                'Inspecciona el certificado de una web real en tu navegador.',
              ],
              resources: [],
            },
          ],
        },
        {
          id: 'f2-m3',
          title: 'Identidad y contraseñas',
          objective: 'Entender autenticación, autorización y por qué caen las contraseñas.',
          tasks: [
            {
              id: 'f2-m3-t1', type: 'lectura', minutes: 40,
              title: 'Autenticación, autorización y MFA',
              summary: 'Algo que sabes/tienes/eres; el papel del segundo factor.',
              steps: [
                'Diferencia autenticación (quién eres) de autorización (qué puedes hacer).',
                'Aprende los factores de autenticación y por qué MFA es clave.',
                'Entiende SSO y la gestión de sesiones y tokens.',
              ],
              resources: [],
            },
            {
              id: 'f2-m3-t2', type: 'practica', minutes: 50,
              title: 'Cómo se rompen las contraseñas (concepto)',
              summary: 'Fuerza bruta, diccionario y por qué el salting protege los hashes.',
              steps: [
                'Entiende ataques de diccionario y fuerza bruta a nivel conceptual.',
                'Aprende qué es un "salt" y por qué frustra las rainbow tables.',
                'Prueba John the Ripper contra un hash de ejemplo TUYO en tu laboratorio.',
              ],
              resources: [
                { label: 'John the Ripper', url: 'https://www.openwall.com/john/' },
              ],
            },
          ],
        },
        {
          id: 'f2-m4',
          title: 'Ética y aspectos legales',
          objective: 'Saber qué es legal, qué no, y cómo actuar de forma responsable.',
          tasks: [
            {
              id: 'f2-m4-t1', type: 'lectura', minutes: 35,
              title: 'Hacking ético y marco legal',
              summary: 'Autorización, alcance, divulgación responsable y consecuencias legales.',
              steps: [
                'Entiende que probar sistemas sin permiso es delito, aunque sea "para aprender".',
                'Aprende qué es un contrato de pentest, el alcance (scope) y el consentimiento.',
                'Conoce la divulgación responsable de vulnerabilidades y los programas bug bounty.',
              ],
              resources: [
                { label: 'HackerOne - divulgación responsable', url: 'https://www.hackerone.com/' },
              ],
            },
          ],
        },
      ],
    },

    /* =====================================================================
     * FASE 3 — HACKING ÉTICO OFENSIVO
     * ===================================================================*/
    {
      id: 'f3',
      title: 'Hacking ético ofensivo (Red Team)',
      subtitle: 'Reconocimiento, escaneo, explotación web y de sistemas — siempre con permiso.',
      icon: '⚔️',
      goal: 'Ejecutar un ciclo completo de pentest contra máquinas de práctica.',
      modules: [
        {
          id: 'f3-m1',
          title: 'Reconocimiento y OSINT',
          objective: 'Recopilar información del objetivo antes de tocar nada.',
          tasks: [
            {
              id: 'f3-m1-t1', type: 'lectura', minutes: 40,
              title: 'Las fases de un pentest',
              summary: 'Recon → escaneo → explotación → post-explotación → informe.',
              steps: [
                'Aprende las 5 fases de una prueba de penetración.',
                'Diferencia reconocimiento pasivo (sin tocar el objetivo) y activo.',
                'Entiende por qué el informe final es tan importante como el ataque.',
              ],
              resources: [
                { label: 'TryHackMe - Pentesting Fundamentals', url: 'https://tryhackme.com/' },
              ],
            },
            {
              id: 'f3-m1-t2', type: 'practica', minutes: 60,
              title: 'OSINT: información pública',
              summary: 'whois, Google dorks, redes sociales y metadatos.',
              steps: [
                'Practica whois y consultas DNS sobre un dominio que controles.',
                'Aprende Google dorks (site:, filetype:, intitle:).',
                'Entiende cómo los metadatos de fotos/documentos filtran información.',
              ],
              resources: [
                { label: 'OSINT Framework', url: 'https://osintframework.com/' },
              ],
            },
          ],
        },
        {
          id: 'f3-m2',
          title: 'Escaneo y enumeración',
          objective: 'Descubrir hosts, puertos y servicios con Nmap.',
          tasks: [
            {
              id: 'f3-m2-t1', type: 'laboratorio', minutes: 70,
              title: 'Nmap de principio a fin',
              summary: 'Descubrir hosts, escanear puertos, detectar servicios y versiones.',
              steps: [
                'Aprende escaneo de host (-sn), de puertos (-p), y detección de versión (-sV).',
                'Prueba Nmap SOLO contra tus propias VMs o scanme.nmap.org.',
                'Interpreta el resultado: qué servicios corren y en qué versión.',
              ],
              resources: [
                { label: 'Nmap - guía de referencia', url: 'https://nmap.org/book/man.html' },
                { label: 'scanme.nmap.org (permitido para practicar)', url: 'http://scanme.nmap.org/' },
              ],
            },
            {
              id: 'f3-m2-t2', type: 'practica', minutes: 60,
              title: 'Enumeración de servicios',
              summary: 'Sacar información de servicios comunes: web, SMB, FTP, SSH.',
              steps: [
                'Aprende a enumerar un servidor web (directorios, tecnologías).',
                'Enumera SMB y FTP en una VM vulnerable de práctica.',
                'Registra todo hallazgo en tu plantilla de notas de máquina.',
              ],
              resources: [
                { label: 'TryHackMe - Network Services', url: 'https://tryhackme.com/' },
              ],
            },
          ],
        },
        {
          id: 'f3-m3',
          title: 'Seguridad web y OWASP Top 10',
          objective: 'Encontrar y entender las vulnerabilidades web más frecuentes.',
          tasks: [
            {
              id: 'f3-m3-t1', type: 'lectura', minutes: 60,
              title: 'OWASP Top 10 explicado',
              summary: 'Las 10 vulnerabilidades web más críticas y cómo funcionan.',
              steps: [
                'Estudia cada categoría: inyección, autenticación rota, XSS, etc.',
                'Para cada una anota: qué es, ejemplo y cómo se mitiga.',
                'Entiende especialmente inyección SQL y XSS.',
              ],
              resources: [
                { label: 'OWASP Top 10 (oficial)', url: 'https://owasp.org/www-project-top-ten/' },
              ],
            },
            {
              id: 'f3-m3-t2', type: 'laboratorio', minutes: 90,
              title: 'Practica en OWASP Juice Shop / DVWA',
              summary: 'Aplicaciones deliberadamente vulnerables para practicar legalmente.',
              steps: [
                'Instala OWASP Juice Shop o DVWA en tu laboratorio.',
                'Resuelve retos de inyección SQL y XSS.',
                'Usa Burp Suite (Community) para interceptar y modificar peticiones.',
              ],
              resources: [
                { label: 'OWASP Juice Shop', url: 'https://owasp.org/www-project-juice-shop/' },
                { label: 'Burp Suite Community', url: 'https://portswigger.net/burp/communitydownload' },
                { label: 'PortSwigger Web Security Academy (gratis)', url: 'https://portswigger.net/web-security' },
              ],
            },
            {
              id: 'f3-m3-t3', type: 'practica', minutes: 120,
              title: 'PortSwigger Web Security Academy',
              summary: 'El mejor entrenamiento gratuito de seguridad web, con laboratorios reales.',
              steps: [
                'Crea una cuenta gratuita en PortSwigger Academy.',
                'Completa los laboratorios de SQL injection (nivel apprentice).',
                'Completa los laboratorios de XSS reflejado (nivel apprentice).',
              ],
              resources: [
                { label: 'PortSwigger Web Security Academy', url: 'https://portswigger.net/web-security/all-labs' },
              ],
            },
          ],
        },
        {
          id: 'f3-m4',
          title: 'Explotación',
          objective: 'Aprovechar una vulnerabilidad para obtener acceso, en entorno controlado.',
          tasks: [
            {
              id: 'f3-m4-t1', type: 'lectura', minutes: 45,
              title: 'Vulnerabilidades, exploits y payloads',
              summary: 'CVE, bases de datos de exploits y qué es Metasploit.',
              steps: [
                'Entiende qué es un CVE y cómo buscar en Exploit-DB.',
                'Aprende la diferencia entre vulnerabilidad, exploit y payload.',
                'Conoce la estructura de Metasploit (módulos, options, payloads).',
              ],
              resources: [
                { label: 'Exploit Database', url: 'https://www.exploit-db.com/' },
              ],
            },
            {
              id: 'f3-m4-t2', type: 'laboratorio', minutes: 90,
              title: 'Tu primera máquina vulnerable con Metasploit',
              summary: 'Explota Metasploitable/una máquina fácil de THM en tu laboratorio.',
              steps: [
                'Monta Metasploitable 2 o usa una sala fácil de TryHackMe.',
                'Escanea, identifica un servicio vulnerable y usa Metasploit para explotarlo.',
                'Documenta paso a paso cómo obtuviste acceso.',
              ],
              resources: [
                { label: 'Metasploitable 2', url: 'https://docs.rapid7.com/metasploit/metasploitable-2/' },
                { label: 'TryHackMe - salas de iniciación', url: 'https://tryhackme.com/' },
              ],
            },
          ],
        },
        {
          id: 'f3-m5',
          title: 'Post-explotación y escalada',
          objective: 'Qué hacer tras entrar: escalar privilegios y moverse.',
          tasks: [
            {
              id: 'f3-m5-t1', type: 'lectura', minutes: 50,
              title: 'Escalada de privilegios (Linux y Windows)',
              summary: 'Pasar de usuario normal a administrador/root.',
              steps: [
                'Aprende vectores comunes: SUID, cron, sudo mal configurado en Linux.',
                'Conoce vectores básicos en Windows (servicios, permisos débiles).',
                'Usa scripts de enumeración como LinPEAS en tu laboratorio.',
              ],
              resources: [
                { label: 'GTFOBins', url: 'https://gtfobins.github.io/' },
                { label: 'PEASS-ng (LinPEAS/WinPEAS)', url: 'https://github.com/peass-ng/PEASS-ng' },
              ],
            },
            {
              id: 'f3-m5-t2', type: 'proyecto', minutes: 90,
              title: 'Proyecto: primer informe de pentest',
              summary: 'Documenta una máquina resuelta de principio a fin como un profesional.',
              steps: [
                'Elige una máquina que hayas resuelto en TryHackMe/HTB.',
                'Escribe un informe: resumen ejecutivo, hallazgos, evidencias, remediación.',
                'Este documento es oro para tu portafolio y entrevistas.',
              ],
              resources: [],
            },
          ],
        },
      ],
    },

    /* =====================================================================
     * FASE 4 — DEFENSA (BLUE TEAM)
     * ===================================================================*/
    {
      id: 'f4',
      title: 'Defensa (Blue Team)',
      subtitle: 'Detectar, responder y proteger: el otro lado imprescindible.',
      icon: '🔵',
      goal: 'Entender cómo se defiende una organización de los ataques que ya sabes ejecutar.',
      modules: [
        {
          id: 'f4-m1',
          title: 'Hardening y buenas prácticas',
          objective: 'Reducir la superficie de ataque de un sistema.',
          tasks: [
            {
              id: 'f4-m1-t1', type: 'lectura', minutes: 45,
              title: 'Bastionado de sistemas',
              summary: 'Actualizaciones, mínimos privilegios, firewalls y configuración segura.',
              steps: [
                'Aprende el principio de mínimo privilegio y por qué importa.',
                'Configura un firewall básico (ufw en Linux) en tu VM.',
                'Aplica una checklist de hardening a tu máquina de laboratorio.',
              ],
              resources: [
                { label: 'CIS Benchmarks', url: 'https://www.cisecurity.org/cis-benchmarks' },
              ],
            },
          ],
        },
        {
          id: 'f4-m2',
          title: 'Logs, monitoreo y SIEM',
          objective: 'Ver lo que ocurre en un sistema y detectar lo anómalo.',
          tasks: [
            {
              id: 'f4-m2-t1', type: 'lectura', minutes: 45,
              title: 'Logs y su importancia',
              summary: 'Dónde viven los logs, qué registran y cómo leerlos.',
              steps: [
                'Aprende dónde están los logs en Linux (/var/log) y en Windows (Event Viewer).',
                'Entiende qué eventos son relevantes para seguridad (logins fallidos, etc.).',
                'Explora los logs de autenticación de tu propia VM.',
              ],
              resources: [],
            },
            {
              id: 'f4-m2-t2', type: 'laboratorio', minutes: 90,
              title: 'Introducción a un SIEM (Splunk / ELK)',
              summary: 'Centralizar y buscar en logs para detectar ataques.',
              steps: [
                'Completa una sala introductoria de SIEM en TryHackMe.',
                'Aprende a buscar patrones sospechosos en un panel de logs.',
                'Entiende qué es una alerta y una regla de detección.',
              ],
              resources: [
                { label: 'TryHackMe - SOC Level 1 path', url: 'https://tryhackme.com/' },
                { label: 'Splunk Free', url: 'https://www.splunk.com/en_us/download.html' },
              ],
            },
          ],
        },
        {
          id: 'f4-m3',
          title: 'Respuesta a incidentes',
          objective: 'Saber qué hacer cuando ocurre una brecha.',
          tasks: [
            {
              id: 'f4-m3-t1', type: 'lectura', minutes: 50,
              title: 'Ciclo de respuesta a incidentes',
              summary: 'Preparación, detección, contención, erradicación, recuperación y lecciones.',
              steps: [
                'Aprende las fases del ciclo de respuesta a incidentes (NIST).',
                'Entiende la cadena de ataque (Cyber Kill Chain) y MITRE ATT&CK.',
                'Explora la matriz ATT&CK para ver tácticas y técnicas reales.',
              ],
              resources: [
                { label: 'MITRE ATT&CK', url: 'https://attack.mitre.org/' },
              ],
            },
          ],
        },
        {
          id: 'f4-m4',
          title: 'Análisis de malware (introducción)',
          objective: 'Entender cómo se estudia software malicioso de forma segura.',
          tasks: [
            {
              id: 'f4-m4-t1', type: 'lectura', minutes: 45,
              title: 'Tipos de malware y análisis básico',
              summary: 'Virus, gusanos, troyanos, ransomware; análisis estático vs dinámico.',
              steps: [
                'Conoce los tipos de malware y cómo se propagan.',
                'Diferencia análisis estático (sin ejecutar) y dinámico (en sandbox).',
                'NUNCA ejecutes malware fuera de un entorno aislado dedicado.',
              ],
              resources: [
                { label: 'VirusTotal (análisis online)', url: 'https://www.virustotal.com/' },
                { label: 'Any.Run (sandbox)', url: 'https://any.run/' },
              ],
            },
          ],
        },
      ],
    },

    /* =====================================================================
     * FASE 5 — ESPECIALIZACIÓN, PRÁCTICA Y CERTIFICACIONES
     * ===================================================================*/
    {
      id: 'f5',
      title: 'Especialización, práctica y certificaciones',
      subtitle: 'Consolida, elige tu camino y prepara tu entrada al mercado laboral.',
      icon: '🚀',
      goal: 'Practicar de forma continua, especializarte y validar tu perfil.',
      modules: [
        {
          id: 'f5-m1',
          title: 'Práctica continua',
          objective: 'Mantener y crecer tus habilidades con retos reales cada semana.',
          tasks: [
            {
              id: 'f5-m1-t1', type: 'practica', minutes: 120,
              title: 'Rutas guiadas en TryHackMe',
              summary: 'Sigue una ruta completa según tu interés (ofensivo o defensivo).',
              steps: [
                'Elige la ruta "Complete Beginner" o "SOC Level 1" según tu meta.',
                'Fija un ritmo sostenible (p. ej. 2-3 salas por semana).',
                'Documenta cada sala resuelta en tu portafolio.',
              ],
              resources: [
                { label: 'TryHackMe', url: 'https://tryhackme.com/' },
              ],
            },
            {
              id: 'f5-m1-t2', type: 'practica', minutes: 120,
              title: 'Máquinas de Hack The Box',
              summary: 'Da el salto a un entorno menos guiado y más realista.',
              steps: [
                'Crea cuenta en Hack The Box y empieza por máquinas "Easy".',
                'Usa los write-ups solo cuando estés realmente atascado.',
                'Compara tu enfoque con el de la comunidad para aprender técnicas nuevas.',
              ],
              resources: [
                { label: 'Hack The Box', url: 'https://www.hackthebox.com/' },
              ],
            },
          ],
        },
        {
          id: 'f5-m2',
          title: 'Elige tu especialización',
          objective: 'Decidir el rumbo: pentest, blue team, cloud, forense, appsec...',
          tasks: [
            {
              id: 'f5-m2-t1', type: 'lectura', minutes: 40,
              title: 'Mapa de carreras en ciberseguridad',
              summary: 'Roles reales, qué hacen y qué habilidades piden.',
              steps: [
                'Estudia los roles: pentester, analista SOC, ingeniero de seguridad, forense, GRC, cloud security.',
                'Marca 2 que te atraigan y busca ofertas de empleo reales para ver requisitos.',
                'Ajusta tus próximos módulos según ese objetivo.',
              ],
              resources: [
                { label: 'Cyberseguridad - roadmap', url: 'https://roadmap.sh/cyber-security' },
              ],
            },
          ],
        },
        {
          id: 'f5-m3',
          title: 'Certificaciones',
          objective: 'Validar tu perfil con certificaciones reconocidas.',
          tasks: [
            {
              id: 'f5-m3-t1', type: 'lectura', minutes: 40,
              title: 'Ruta de certificaciones',
              summary: 'Cuál sacar primero según tu meta y presupuesto.',
              steps: [
                'Base: CompTIA Security+ (muy valorada para empezar).',
                'Ofensivo práctico: eJPT (accesible) → luego OSCP (exigente).',
                'Defensivo: BTL1 o CompTIA CySA+. Elige una y ponle fecha.',
              ],
              resources: [
                { label: 'CompTIA Security+', url: 'https://www.comptia.org/certifications/security' },
                { label: 'eLearnSecurity eJPT (INE)', url: 'https://security.ine.com/certifications/ejpt-certification/' },
                { label: 'OffSec OSCP', url: 'https://www.offsec.com/courses/pen-200/' },
              ],
            },
          ],
        },
        {
          id: 'f5-m4',
          title: 'Portafolio, CTFs y comunidad',
          objective: 'Hacerte visible y conectar con el sector.',
          tasks: [
            {
              id: 'f5-m4-t1', type: 'proyecto', minutes: 90,
              title: 'Construye tu portafolio',
              summary: 'GitHub con tus scripts, write-ups de máquinas y notas.',
              steps: [
                'Crea un repositorio o blog con tus proyectos y write-ups.',
                'Publica al menos 3 write-ups de máquinas resueltas.',
                'Redacta un README que resuma tus habilidades.',
              ],
              resources: [
                { label: 'GitHub', url: 'https://github.com/' },
              ],
            },
            {
              id: 'f5-m4-t2', type: 'practica', minutes: 120,
              title: 'Participa en CTFs y en la comunidad',
              summary: 'Los CTF aceleran el aprendizaje y amplían tu red de contactos.',
              steps: [
                'Apúntate a un CTF de nivel principiante en CTFtime.',
                'Únete a una comunidad (Discord/foro) para aprender en grupo.',
                'Comparte lo que aprendes: enseñar consolida tu conocimiento.',
              ],
              resources: [
                { label: 'CTFtime (calendario de CTFs)', url: 'https://ctftime.org/' },
                { label: 'picoCTF (ideal para empezar)', url: 'https://picoctf.org/' },
              ],
            },
          ],
        },
      ],
    },
  ],
};

/* Metadatos de los tipos de tarea (icono + etiqueta) */
const TASK_TYPES = {
  lectura:     { label: 'Lectura',     icon: '📖' },
  video:       { label: 'Video',       icon: '🎥' },
  laboratorio: { label: 'Laboratorio', icon: '🧪' },
  practica:    { label: 'Práctica',    icon: '🎯' },
  proyecto:    { label: 'Proyecto',    icon: '🛠️' },
  quiz:        { label: 'Repaso',      icon: '✅' },
};

/* Exponer en el ámbito global para los scripts clásicos */
window.CURRICULUM = CURRICULUM;
window.TASK_TYPES = TASK_TYPES;
