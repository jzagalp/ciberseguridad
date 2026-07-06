/* ============================================================================
 *  APP — interfaz y navegación.
 *  Une temario + planificador + progreso en una UI gráfica de 5 vistas:
 *  Inicio · Hoy · Ruta · Progreso · Ajustes.
 * ==========================================================================*/

const App = (function () {

  const NAV = [
    { id: 'inicio',   label: 'Inicio',   icon: '🏠' },
    { id: 'hoy',      label: 'Hoy',      icon: '🎯' },
    { id: 'ruta',     label: 'Ruta',     icon: '🗺️' },
    { id: 'progreso', label: 'Progreso', icon: '📈' },
    { id: 'ajustes',  label: 'Ajustes',  icon: '⚙️' },
  ];

  const WEEK = [
    { n: 1, l: 'L' }, { n: 2, l: 'M' }, { n: 3, l: 'X' }, { n: 4, l: 'J' },
    { n: 5, l: 'V' }, { n: 6, l: 'S' }, { n: 0, l: 'D' },
  ];

  let view = 'inicio';
  const expandedTasks = new Set();
  const expandedModules = new Set();

  /* ---- utilidades -------------------------------------------------------- */
  const $ = sel => document.querySelector(sel);
  function esc(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }
  function fmtDate(str) {
    if (!str) return '';
    const d = new Date(str + 'T00:00:00');
    return d.toLocaleDateString('es', { weekday: 'short', day: 'numeric', month: 'short' });
  }
  function fmtLong(str) {
    if (!str) return '';
    const d = new Date(str + 'T00:00:00');
    return d.toLocaleDateString('es', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
  }
  function fmtMinutes(m) {
    if (m < 60) return m + ' min';
    const h = Math.floor(m / 60), r = m % 60;
    return r ? `${h} h ${r} min` : `${h} h`;
  }

  /* ---- tema -------------------------------------------------------------- */
  function applyTheme() {
    const t = Store.getSettings().theme || 'auto';
    const root = document.documentElement;
    if (t === 'auto') root.removeAttribute('data-theme');
    else root.setAttribute('data-theme', t);
  }
  function cycleTheme() {
    const order = ['auto', 'light', 'dark'];
    const cur = Store.getSettings().theme || 'auto';
    const next = order[(order.indexOf(cur) + 1) % order.length];
    Store.updateSettings({ theme: next });
    applyTheme();
    toast('Tema: ' + ({ auto: 'automático', light: 'claro', dark: 'oscuro' }[next]));
  }

  /* ---- avisos (toast) ---------------------------------------------------- */
  let toastTimer;
  function toast(msg) {
    let t = $('#toast');
    if (!t) { t = document.createElement('div'); t.id = 'toast'; t.className = 'toast'; document.body.appendChild(t); }
    t.textContent = msg; t.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => t.classList.remove('show'), 2200);
  }

  /* ---- navegación -------------------------------------------------------- */
  function buildNav() {
    const tabs = $('#tabs'), mobile = $('#mobilebar');
    const html = NAV.map(n =>
      `<button class="tab" data-nav="${n.id}"><span class="tab-ico">${n.icon}</span><span class="tab-lbl">${n.label}</span></button>`
    ).join('');
    tabs.innerHTML = html;
    mobile.innerHTML = html;
  }
  function setActiveNav() {
    document.querySelectorAll('[data-nav]').forEach(b =>
      b.classList.toggle('active', b.dataset.nav === view));
  }
  function go(v) { view = v; render(); window.scrollTo({ top: 0, behavior: 'smooth' }); }

  /* ---- tarjeta de tarea (compartida) ------------------------------------- */
  function taskCard(item, opts) {
    opts = opts || {};
    const t = item.task;
    const st = Store.getTaskState(t.id);
    const meta = TASK_TYPES[t.type] || { label: t.type, icon: '•' };
    const open = expandedTasks.has(t.id);
    const dateStr = opts.date ? `<span class="task-date">📅 ${fmtDate(opts.date)}</span>` : '';

    const steps = (t.steps || []).map(s => `<li>${esc(s)}</li>`).join('');
    const res = (t.resources || []).map(r =>
      `<li><a href="${esc(r.url)}" target="_blank" rel="noopener noreferrer">${esc(r.label)} ↗</a></li>`
    ).join('') || '<li class="muted">Sin recursos añadidos.</li>';

    return `
      <article class="task-card st-${st.status} ${open ? 'open' : ''}" data-card="${t.id}">
        <div class="task-head">
          <button class="task-check" data-toggle-task="${t.id}" title="Marcar como completada"
                  aria-label="Completar tarea">${st.status === 'done' ? '✓' : ''}</button>
          <div class="task-main" data-expand-task="${t.id}">
            <div class="task-meta">
              <span class="chip type-${t.type}">${meta.icon} ${meta.label}</span>
              <span class="task-min">⏱ ${fmtMinutes(t.minutes)}</span>
              ${dateStr}
              ${st.status === 'skipped' ? '<span class="chip chip-skip">saltada</span>' : ''}
              ${t.custom ? '<span class="chip chip-custom">mía</span>' : ''}
            </div>
            <h4 class="task-title">${esc(t.title)}</h4>
            <p class="task-summary">${esc(t.summary)}</p>
          </div>
          <button class="task-caret" data-expand-task="${t.id}" aria-label="Expandir">${open ? '▴' : '▾'}</button>
        </div>
        <div class="task-body" ${open ? '' : 'hidden'}>
          ${steps ? `<h5>🧭 Cómo hacerlo</h5><ol class="steps">${steps}</ol>` : ''}
          <h5>🔗 Recursos</h5>
          <ul class="reslist">${res}</ul>
          <label class="notes-label">📝 Mis notas
            <textarea class="notes" data-notes="${t.id}" rows="2"
              placeholder="Apunta comandos, dudas o lo aprendido…">${esc(st.notes)}</textarea>
          </label>
          <div class="task-actions">
            ${st.status !== 'done'
              ? `<button class="btn btn-primary" data-action="done" data-task="${t.id}">✓ Completar</button>`
              : `<button class="btn" data-action="reset" data-task="${t.id}">↺ Marcar pendiente</button>`}
            ${st.status !== 'skipped'
              ? `<button class="btn btn-ghost" data-action="skip" data-task="${t.id}">Saltar</button>`
              : `<button class="btn btn-ghost" data-action="reset" data-task="${t.id}">Recuperar</button>`}
            ${t.custom ? `<button class="btn btn-danger-ghost" data-action="delcustom" data-task="${t.id}">🗑 Eliminar</button>` : ''}
          </div>
        </div>
      </article>`;
  }

  /* =======================================================================
   *  VISTA: INICIO (dashboard)
   * =====================================================================*/
  function renderDashboard() {
    const s = Store.getSettings();
    const stat = Scheduler.stats();
    const plan = Scheduler.todayPlan();
    const proj = Scheduler.projection();
    const name = s.name ? `, ${esc(s.name)}` : '';

    const todoCount = plan.todayTodo.length;
    const todoMin = plan.todayTodo.reduce((a, it) => a + it.task.minutes, 0);

    let missionHtml;
    if (plan.allDone) {
      missionHtml = `<p class="mission-done">🎉 ¡Has completado toda la ruta! Sigue practicando en la Fase 5.</p>`;
    } else if (plan.dayComplete) {
      missionHtml = `<p class="mission-done">✅ Objetivo de hoy cumplido. Vuelve mañana o pulsa “Hacer más”.</p>`;
    } else {
      missionHtml = `
        <p class="mission-line"><b>${todoCount}</b> ${todoCount === 1 ? 'tarea' : 'tareas'} · <b>${fmtMinutes(todoMin)}</b> para hoy</p>
        <p class="mission-next">Siguiente: <b>${esc(plan.todayTodo[0].task.title)}</b></p>`;
    }

    $('#view').innerHTML = `
      <section class="hello">
        <div>
          <h1>Hola${name} 👋</h1>
          <p class="sub">${greeting(stat, plan)}</p>
        </div>
        <button class="btn btn-primary big" data-nav="hoy">Ir a lo de hoy →</button>
      </section>

      <section class="grid-hero">
        <div class="card ring-card">
          <div id="ring"></div>
          <div class="ring-side">
            <div class="ring-phase">${esc(stat.currentPhase.icon || '')} Fase actual</div>
            <div class="ring-phase-name">${esc(stat.currentPhase.title)}</div>
            <div class="ring-phase-pct">${stat.currentPhase.pct}% de esta fase</div>
          </div>
        </div>

        <div class="kpis">
          ${kpi('🔥', stat.streak, stat.streak === 1 ? 'día de racha' : 'días de racha')}
          ${kpi('⏱', stat.totalHours, 'horas de estudio')}
          ${kpi('✅', `${stat.done}/${stat.counted}`, 'tareas hechas')}
          ${kpi('📦', `${stat.modulesDone}/${stat.modulesTotal}`, 'módulos completados')}
        </div>
      </section>

      <section class="card mission-card">
        <div class="card-head"><h3>🎯 Tu misión de hoy</h3>
          <button class="btn btn-sm" data-nav="hoy">Abrir</button></div>
        ${missionHtml}
        ${!plan.allDone ? `<p class="eta muted">A tu ritmo (${fmtMinutes(s.minutesPerDay)}/día) terminarás la ruta el <b>${fmtLong(proj.completionDate)}</b>.</p>` : ''}
      </section>

      <section class="grid-2">
        <div class="card">
          <div class="card-head"><h3>📊 Progreso por fase</h3></div>
          <div id="phaseBars"></div>
        </div>
        <div class="card">
          <div class="card-head"><h3>⏱ Estudio (últimos 14 días)</h3></div>
          <div id="activity"></div>
        </div>
      </section>

      <section class="card">
        <div class="card-head"><h3>📈 Horas acumuladas</h3></div>
        <div id="cumulative"></div>
      </section>
    `;

    Charts.progressRing($('#ring'), stat.pct);
    Charts.phaseBars($('#phaseBars'), stat.phases);
    Charts.activityBars($('#activity'), Scheduler.activitySeries(14));
    Charts.cumulativeArea($('#cumulative'), Scheduler.cumulativeHours(30));
  }

  function greeting(stat, plan) {
    if (stat.done === 0) return 'Empecemos tu camino en ciberseguridad. Cada día te diré exactamente qué hacer.';
    if (plan.allDone) return '¡Ruta completada! Ahora toca practicar y especializarte.';
    if (stat.streak >= 3) return `Llevas ${stat.streak} días seguidos. La constancia es tu superpoder. 💪`;
    return 'Sigamos sumando. Un paso cada día te lleva lejos.';
  }
  function kpi(icon, value, label) {
    return `<div class="kpi"><div class="kpi-ico">${icon}</div>
      <div class="kpi-val">${value}</div><div class="kpi-lbl">${label}</div></div>`;
  }

  /* =======================================================================
   *  VISTA: HOY
   * =====================================================================*/
  function renderToday() {
    const plan = Scheduler.todayPlan();
    const proj = Scheduler.projection();
    const s = Store.getSettings();

    let body = '';

    if (plan.restDay) {
      body += `<div class="banner banner-soft">🌙 Hoy es un día de descanso según tu configuración. Puedes descansar… o adelantar tareas abajo.</div>`;
    }

    // completadas hoy
    if (plan.doneToday.length) {
      body += `<h3 class="sec-title">✅ Completadas hoy (${plan.doneToday.length})</h3>`;
      body += `<div class="task-list">${plan.doneToday.map(it => taskCard(it)).join('')}</div>`;
    }

    // por hacer hoy
    if (plan.allDone) {
      body += `<div class="card empty-state"><div class="empty-emoji">🏁</div>
        <h3>¡Ruta completa!</h3><p>Has terminado todas las tareas del temario. Sigue con práctica continua en la Fase 5.</p>
        <button class="btn btn-primary" data-nav="ruta">Ver la ruta</button></div>`;
    } else if (plan.todayTodo.length) {
      body += `<h3 class="sec-title">🎯 Para hoy${plan.doneToday.length ? ' (te queda)' : ''}</h3>`;
      body += `<div class="task-list">${plan.todayTodo.map(it =>
        taskCard(it, { date: proj.dates[it.task.id] })).join('')}</div>`;
    } else if (plan.dayComplete) {
      body += `<div class="card empty-state"><div class="empty-emoji">🎉</div>
        <h3>¡Objetivo de hoy cumplido!</h3>
        <p>Alcanzaste tus ${fmtMinutes(s.minutesPerDay)} de estudio. Descansa o pulsa “Hacer más”.</p>
        <button class="btn btn-primary" data-action="domore">➕ Hacer más</button></div>`;
    }

    // próximamente
    if (plan.upcoming.length) {
      const list = plan.upcoming.slice(0, 6);
      body += `<details class="upcoming"><summary>📅 Próximamente (${plan.upcoming.length} tareas)</summary>
        <div class="up-list">${list.map(it => `
          <div class="up-row">
            <span class="up-date">${fmtDate(proj.dates[it.task.id])}</span>
            <span class="up-type">${(TASK_TYPES[it.task.type] || {}).icon || ''}</span>
            <span class="up-title">${esc(it.task.title)}</span>
            <span class="up-min">${fmtMinutes(it.task.minutes)}</span>
          </div>`).join('')}</div></details>`;
    }

    $('#view').innerHTML = `
      <section class="page-head">
        <div>
          <h1>🎯 Hoy</h1>
          <p class="sub">${fmtLong(Store.todayStr())}</p>
        </div>
        <div class="today-budget">
          <div class="budget-ring" style="--p:${Math.min(100, Math.round(plan.minutesDoneToday / plan.budget * 100)) || 0}">
            <span>${plan.minutesDoneToday}<small>/${plan.budget} min</small></span>
          </div>
        </div>
      </section>

      <section class="log-strip card">
        <span>¿Estudiaste por tu cuenta? Regístralo:</span>
        <div class="log-controls">
          <input type="number" id="logMin" min="5" max="600" step="5" value="30" />
          <span>min</span>
          <button class="btn btn-sm btn-primary" data-action="logmin">Añadir a hoy</button>
        </div>
      </section>

      ${body}
    `;
  }

  /* =======================================================================
   *  VISTA: RUTA (roadmap)
   * =====================================================================*/
  function renderRoadmap() {
    const proj = Scheduler.projection();
    const custom = Store.getCustomTasks();

    let html = `<section class="page-head"><div>
      <h1>🗺️ Tu ruta completa</h1>
      <p class="sub">${CURRICULUM.phases.length} fases · de cero a nivel junior. Marca, salta o expande cualquier tarea.</p>
    </div></section>`;

    // Mis tareas (si hay)
    if (custom.length) {
      html += `<section class="phase-block"><div class="phase-banner">
        <span class="phase-ico">⭐</span>
        <div><h2>Mis tareas</h2><p>Tareas que has añadido tú. Se hacen primero.</p></div></div>`;
      html += `<div class="task-list">${custom.map(t =>
        taskCard({ task: t }, { date: proj.dates[t.id] })).join('')}</div></section>`;
    }

    CURRICULUM.phases.forEach(phase => {
      const st = Scheduler.stats().phases.find(p => p.id === phase.id);
      html += `<section class="phase-block">
        <div class="phase-banner">
          <span class="phase-ico">${phase.icon}</span>
          <div class="phase-info">
            <h2>${esc(phase.title)}</h2>
            <p>${esc(phase.subtitle)}</p>
          </div>
          <div class="phase-progress">
            <div class="mini-track"><div class="mini-fill" style="width:${st.pct}%"></div></div>
            <span>${st.done}/${st.total}</span>
          </div>
        </div>`;

      phase.modules.forEach(module => {
        const open = expandedModules.has(module.id);
        const mDone = module.tasks.filter(t => Store.getTaskState(t.id).status === 'done').length;
        html += `<div class="module ${open ? 'open' : ''}">
          <button class="module-head" data-expand-module="${module.id}">
            <span class="mod-caret">${open ? '▾' : '▸'}</span>
            <div class="mod-titles">
              <h3>${esc(module.title)}</h3>
              <span class="mod-obj">${esc(module.objective)}</span>
            </div>
            <span class="mod-count ${mDone === module.tasks.length ? 'done' : ''}">${mDone}/${module.tasks.length}</span>
          </button>
          ${open ? `<div class="task-list module-tasks">${module.tasks.map(t =>
            taskCard({ task: t }, { date: proj.dates[t.id] })).join('')}</div>` : ''}
        </div>`;
      });

      html += `</section>`;
    });

    $('#view').innerHTML = html;
  }

  /* =======================================================================
   *  VISTA: PROGRESO
   * =====================================================================*/
  function renderProgress() {
    const stat = Scheduler.stats();
    const proj = Scheduler.projection();
    const s = Store.getSettings();

    $('#view').innerHTML = `
      <section class="page-head"><div>
        <h1>📈 Tu progreso</h1>
        <p class="sub">Todo lo que llevas construido, de un vistazo.</p>
      </div></section>

      <section class="grid-hero">
        <div class="card ring-card">
          <div id="ring2"></div>
          <div class="ring-side">
            <div class="ring-phase">Progreso global</div>
            <div class="ring-phase-name">${stat.done} de ${stat.counted} tareas</div>
            <div class="ring-phase-pct">${proj.remainingTasks} tareas restantes</div>
          </div>
        </div>
        <div class="kpis">
          ${kpi('🔥', stat.streak, 'días de racha')}
          ${kpi('⏱', stat.totalHours, 'horas totales')}
          ${kpi('📦', `${stat.modulesDone}/${stat.modulesTotal}`, 'módulos')}
          ${kpi('🏁', fmtDate(proj.completionDate), 'fin estimado')}
        </div>
      </section>

      <section class="grid-2">
        <div class="card">
          <div class="card-head"><h3>📊 Avance por fase</h3></div>
          <div id="phaseBars2"></div>
        </div>
        <div class="card">
          <div class="card-head"><h3>⏱ Minutos por día (14 días)</h3></div>
          <div id="activity2"></div>
        </div>
      </section>

      <section class="card">
        <div class="card-head"><h3>📈 Horas acumuladas (30 días)</h3></div>
        <div id="cumulative2"></div>
      </section>

      <section class="card">
        <div class="card-head"><h3>🧮 Resumen</h3></div>
        <div class="summary-grid">
          <div><span class="s-lbl">Empezaste</span><span class="s-val">${fmtLong(s.startDate)}</span></div>
          <div><span class="s-lbl">Ritmo</span><span class="s-val">${fmtMinutes(s.minutesPerDay)}/día</span></div>
          <div><span class="s-lbl">Días de estudio</span><span class="s-val">${studyDaysLabel(s.studyDays)}</span></div>
          <div><span class="s-lbl">Fin estimado</span><span class="s-val">${fmtLong(proj.completionDate)}</span></div>
        </div>
      </section>
    `;

    Charts.progressRing($('#ring2'), stat.pct);
    Charts.phaseBars($('#phaseBars2'), stat.phases);
    Charts.activityBars($('#activity2'), Scheduler.activitySeries(14));
    Charts.cumulativeArea($('#cumulative2'), Scheduler.cumulativeHours(30));
  }

  function studyDaysLabel(days) {
    if (!days || !days.length) return 'todos';
    return WEEK.filter(w => days.includes(w.n)).map(w => w.l).join(' ');
  }

  /* =======================================================================
   *  VISTA: AJUSTES
   * =====================================================================*/
  function renderSettings() {
    const s = Store.getSettings();
    $('#view').innerHTML = `
      <section class="page-head"><div>
        <h1>⚙️ Ajustes</h1>
        <p class="sub">Personaliza tu plan. El manager se reorganiza solo.</p>
      </div></section>

      <section class="card">
        <div class="card-head"><h3>👤 Tu plan</h3></div>
        <div class="form">
          <label class="field">Tu nombre
            <input type="text" id="setName" value="${esc(s.name)}" placeholder="¿Cómo te llamas?" />
          </label>
          <label class="field">Fecha de inicio
            <input type="date" id="setStart" value="${esc(s.startDate)}" />
          </label>
          <label class="field">Minutos de estudio al día
            <input type="range" id="setMinutes" min="15" max="240" step="15" value="${s.minutesPerDay}" />
            <output id="minOut">${fmtMinutes(s.minutesPerDay)}</output>
          </label>
          <div class="field">
            <span class="field-lbl">Días de estudio</span>
            <div class="daypick" id="dayPick">
              ${WEEK.map(w => `<button class="day ${s.studyDays.includes(w.n) ? 'on' : ''}" data-day="${w.n}">${w.l}</button>`).join('')}
            </div>
          </div>
        </div>
      </section>

      <section class="card">
        <div class="card-head"><h3>➕ Añadir tarea propia</h3></div>
        <p class="muted small">Tus tareas se colocan al principio de la cola: son lo próximo que harás.</p>
        <div class="form">
          <label class="field">Título
            <input type="text" id="ctTitle" placeholder="Ej: Repasar comandos de nmap" />
          </label>
          <label class="field">Descripción
            <input type="text" id="ctSummary" placeholder="Breve descripción (opcional)" />
          </label>
          <div class="form-row">
            <label class="field">Tipo
              <select id="ctType">
                ${Object.entries(TASK_TYPES).map(([k, v]) => `<option value="${k}">${v.icon} ${v.label}</option>`).join('')}
              </select>
            </label>
            <label class="field">Minutos
              <input type="number" id="ctMin" min="5" max="600" step="5" value="30" />
            </label>
          </div>
          <button class="btn btn-primary" data-action="addcustom">➕ Añadir tarea</button>
        </div>
      </section>

      <section class="card">
        <div class="card-head"><h3>🎨 Apariencia</h3></div>
        <div class="theme-row">
          ${['auto', 'light', 'dark'].map(t =>
            `<button class="btn theme-opt ${(s.theme || 'auto') === t ? 'active' : ''}" data-theme-set="${t}">
              ${{ auto: '🌗 Automático', light: '☀️ Claro', dark: '🌙 Oscuro' }[t]}</button>`).join('')}
        </div>
      </section>

      <section class="card">
        <div class="card-head"><h3>💾 Copia de seguridad</h3></div>
        <p class="muted small">Tu progreso se guarda en este navegador. Expórtalo para no perderlo o llevarlo a otro equipo.</p>
        <div class="btn-row">
          <button class="btn" data-action="export">⬇️ Exportar datos</button>
          <button class="btn" data-action="import">⬆️ Importar datos</button>
        </div>
      </section>

      <section class="card danger-zone">
        <div class="card-head"><h3>⚠️ Zona de riesgo</h3></div>
        <div class="btn-row">
          <button class="btn btn-danger-ghost" data-action="resetprogress">Reiniciar progreso</button>
          <button class="btn btn-danger-ghost" data-action="resetall">Borrar todo</button>
        </div>
      </section>

      <footer class="app-foot">CyberPath · tu manager de aprendizaje en ciberseguridad · v${CURRICULUM.meta.version}</footer>
    `;
  }

  /* =======================================================================
   *  MODALES
   * =====================================================================*/
  function modal(html) {
    const root = $('#modalRoot');
    root.innerHTML = `<div class="modal-back" data-modal-close>
      <div class="modal" role="dialog" aria-modal="true">${html}</div></div>`;
  }
  function closeModal() { $('#modalRoot').innerHTML = ''; }

  function onboarding() {
    modal(`
      <h2>👋 Bienvenido a CyberPath</h2>
      <p class="muted">Voy a ser tu manager: te organizo la ruta y te digo qué hacer cada día. Solo necesito 3 datos.</p>
      <div class="form">
        <label class="field">¿Cómo te llamas?
          <input type="text" id="obName" placeholder="Tu nombre" />
        </label>
        <label class="field">¿Cuántos minutos puedes estudiar al día?
          <input type="range" id="obMinutes" min="15" max="240" step="15" value="60" />
          <output id="obMinOut">1 h</output>
        </label>
        <div class="field">
          <span class="field-lbl">¿Qué días estudiarás?</span>
          <div class="daypick" id="obDayPick">
            ${WEEK.map(w => `<button class="day ${[1,2,3,4,5].includes(w.n) ? 'on' : ''}" data-obday="${w.n}">${w.l}</button>`).join('')}
          </div>
        </div>
      </div>
      <div class="modal-actions">
        <button class="btn btn-ghost" data-action="ob-skip">Ahora no</button>
        <button class="btn btn-primary" data-action="ob-start">🚀 Empezar</button>
      </div>
    `);
  }

  /* =======================================================================
   *  EVENTOS (delegación)
   * =====================================================================*/
  function bindEvents() {
    // navegación
    document.addEventListener('click', (e) => {
      const nav = e.target.closest('[data-nav]');
      if (nav) { go(nav.dataset.nav); return; }

      // tema (botón superior)
      if (e.target.closest('#themeBtn')) { cycleTheme(); return; }

      // expandir/colapsar tarea
      const et = e.target.closest('[data-expand-task]');
      if (et) {
        const id = et.dataset.expandTask;
        expandedTasks.has(id) ? expandedTasks.delete(id) : expandedTasks.add(id);
        render(); return;
      }
      // marcar completada (check)
      const tt = e.target.closest('[data-toggle-task]');
      if (tt) { toggleDone(tt.dataset.toggleTask); return; }

      // expandir módulo
      const em = e.target.closest('[data-expand-module]');
      if (em) {
        const id = em.dataset.expandModule;
        expandedModules.has(id) ? expandedModules.delete(id) : expandedModules.add(id);
        render(); return;
      }

      // acciones con data-action
      const act = e.target.closest('[data-action]');
      if (act) { handleAction(act.dataset.action, act.dataset.task, act); return; }

      // tema en ajustes
      const ts = e.target.closest('[data-theme-set]');
      if (ts) { Store.updateSettings({ theme: ts.dataset.themeSet }); applyTheme(); render(); return; }

      // días de estudio (ajustes)
      const day = e.target.closest('[data-day]');
      if (day) { toggleStudyDay(parseInt(day.dataset.day, 10)); return; }

      // días onboarding
      const obd = e.target.closest('[data-obday]');
      if (obd) { obd.classList.toggle('on'); return; }

      // cerrar modal al pulsar fondo
      if (e.target.matches('[data-modal-close]')) closeModal();
    });

    // notas y campos
    document.addEventListener('change', (e) => {
      if (e.target.matches('[data-notes]')) {
        Store.setTaskNotes(e.target.dataset.notes, e.target.value);
        toast('Nota guardada');
      }
      if (e.target.id === 'setName') Store.updateSettings({ name: e.target.value.trim() });
      if (e.target.id === 'setStart') Store.updateSettings({ startDate: e.target.value });
      if (e.target.id === 'setMinutes') { Store.updateSettings({ minutesPerDay: parseInt(e.target.value, 10) }); }
    });
    document.addEventListener('input', (e) => {
      if (e.target.id === 'setMinutes') $('#minOut').textContent = fmtMinutes(parseInt(e.target.value, 10));
      if (e.target.id === 'obMinutes') $('#obMinOut').textContent = fmtMinutes(parseInt(e.target.value, 10));
    });
  }

  function toggleDone(id) {
    const st = Store.getTaskState(id);
    const task = findTask(id);
    const mins = task ? task.minutes : 0;
    Store.setTaskStatus(id, st.status === 'done' ? 'todo' : 'done', mins);
    if (st.status !== 'done') toast('¡Tarea completada! 🎉');
    render();
  }

  function handleAction(action, taskId, elBtn) {
    switch (action) {
      case 'done': {
        const task = findTask(taskId);
        Store.setTaskStatus(taskId, 'done', task ? task.minutes : 0);
        expandedTasks.delete(taskId);
        toast('¡Tarea completada! 🎉'); render(); break;
      }
      case 'skip': Store.setTaskStatus(taskId, 'skipped'); render(); break;
      case 'reset': Store.setTaskStatus(taskId, 'todo'); render(); break;
      case 'delcustom': Store.removeCustomTask(taskId); toast('Tarea eliminada'); render(); break;
      case 'domore': {
        // revela la siguiente tarea aunque el presupuesto esté cumplido
        const plan = Scheduler.todayPlan();
        const next = plan.upcoming[0];
        if (next) { expandedTasks.add(next.task.id); toast('Aquí tienes más 💪'); }
        renderTodayExtra(); break;
      }
      case 'logmin': {
        const v = parseInt($('#logMin').value, 10) || 0;
        if (v > 0) { Store.logManualMinutes(Store.todayStr(), v); toast(`+${v} min registrados`); render(); }
        break;
      }
      case 'addcustom': addCustom(); break;
      case 'export': doExport(); break;
      case 'import': doImport(); break;
      case 'resetprogress':
        confirmModal('¿Reiniciar tu progreso?', 'Se borrarán tareas completadas, notas y actividad. Tu configuración se conserva.',
          () => { Store.resetProgress(); toast('Progreso reiniciado'); render(); });
        break;
      case 'resetall':
        confirmModal('¿Borrar TODO?', 'Se borrará absolutamente todo, incluida tu configuración. No se puede deshacer.',
          () => { Store.resetAll(); expandedTasks.clear(); expandedModules.clear(); toast('Todo borrado'); render(); });
        break;
      case 'ob-skip': closeModal(); break;
      case 'ob-start': saveOnboarding(); break;
    }
  }

  // muestra la siguiente tarea "hacer más" sin recomputar el estado de hoy
  function renderTodayExtra() {
    const plan = Scheduler.todayPlan();
    const proj = Scheduler.projection();
    const next = plan.upcoming[0];
    if (!next) { render(); return; }
    const host = document.querySelector('.empty-state');
    if (host) {
      const div = document.createElement('div');
      div.className = 'task-list';
      div.style.marginTop = '16px';
      div.innerHTML = taskCard(next, { date: proj.dates[next.task.id] });
      host.replaceWith(div);
    } else { render(); }
  }

  function toggleStudyDay(n) {
    const s = Store.getSettings();
    const days = new Set(s.studyDays);
    days.has(n) ? days.delete(n) : days.add(n);
    Store.updateSettings({ studyDays: Array.from(days).sort() });
    render();
  }

  function addCustom() {
    const title = $('#ctTitle').value.trim();
    if (!title) { toast('Escribe un título'); return; }
    Store.addCustomTask({
      title,
      summary: $('#ctSummary').value.trim(),
      type: $('#ctType').value,
      minutes: parseInt($('#ctMin').value, 10) || 30,
      steps: [],
    });
    toast('Tarea añadida a tu ruta ⭐');
    render();
  }

  function saveOnboarding() {
    const name = ($('#obName').value || '').trim();
    const minutes = parseInt($('#obMinutes').value, 10) || 60;
    const days = Array.from(document.querySelectorAll('#obDayPick .day.on')).map(b => parseInt(b.dataset.obday, 10));
    Store.updateSettings({ name, minutesPerDay: minutes, studyDays: days.length ? days.sort() : [1,2,3,4,5] });
    closeModal();
    localStorage.setItem('cyberpath.onboarded', '1');
    go('hoy');
  }

  function confirmModal(title, msg, onYes) {
    modal(`<h2>${esc(title)}</h2><p class="muted">${esc(msg)}</p>
      <div class="modal-actions">
        <button class="btn btn-ghost" data-modal-close>Cancelar</button>
        <button class="btn btn-danger" id="confirmYes">Sí, continuar</button>
      </div>`);
    $('#confirmYes').addEventListener('click', () => { closeModal(); onYes(); });
  }

  function doExport() {
    const data = Store.exportData();
    const blob = new Blob([data], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url; a.download = `cyberpath-backup-${Store.todayStr()}.json`;
    document.body.appendChild(a); a.click(); a.remove();
    URL.revokeObjectURL(url);
    toast('Datos exportados');
  }

  function doImport() {
    const input = document.createElement('input');
    input.type = 'file'; input.accept = 'application/json';
    input.addEventListener('change', () => {
      const file = input.files[0]; if (!file) return;
      const reader = new FileReader();
      reader.onload = () => {
        try { Store.importData(reader.result); toast('Datos importados ✅'); render(); }
        catch (e) { toast('Archivo inválido'); }
      };
      reader.readAsText(file);
    });
    input.click();
  }

  /* buscar una tarea (temario o personalizada) por id */
  function findTask(id) {
    const c = Store.getCustomTasks().find(t => t.id === id);
    if (c) return c;
    for (const p of CURRICULUM.phases)
      for (const m of p.modules)
        for (const t of m.tasks) if (t.id === id) return t;
    return null;
  }

  /* ---- render maestro ---------------------------------------------------- */
  function render() {
    setActiveNav();
    if (view === 'inicio') renderDashboard();
    else if (view === 'hoy') renderToday();
    else if (view === 'ruta') renderRoadmap();
    else if (view === 'progreso') renderProgress();
    else if (view === 'ajustes') renderSettings();
  }

  /* ---- init -------------------------------------------------------------- */
  function init() {
    buildNav();
    applyTheme();
    bindEvents();
    render();
    if (!localStorage.getItem('cyberpath.onboarded') && !Store.getSettings().name) {
      setTimeout(onboarding, 400);
    }
    // reacciona a cambios del tema del sistema si está en "auto"
    if (window.matchMedia) {
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
        if ((Store.getSettings().theme || 'auto') === 'auto') applyTheme();
      });
    }
  }

  return { init, go };
})();

document.addEventListener('DOMContentLoaded', App.init);
