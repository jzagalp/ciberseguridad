/* ============================================================================
 *  SCHEDULER — convierte el temario + tu configuración en un plan
 *  ---------------------------------------------------------------------------
 *  Es el "manager": decide qué te toca HOY según tu tiempo diario, proyecta
 *  cuándo terminarás y calcula todas las estadísticas de progreso.
 * ==========================================================================*/

const Scheduler = (function () {

  /* ---- lista plana y ordenada de todas las tareas ------------------------ */
  function allTasks() {
    const flat = [];
    // Las tareas personalizadas van primero: "lo que quiero hacer ahora".
    Store.getCustomTasks().forEach(t => {
      flat.push({ task: t, phaseId: 'mis-tareas', phaseTitle: 'Mis tareas',
                  moduleTitle: 'Personalizadas', custom: true });
    });
    CURRICULUM.phases.forEach(phase => {
      phase.modules.forEach(module => {
        module.tasks.forEach(task => {
          flat.push({ task, phase, module, phaseId: phase.id,
                      phaseTitle: phase.title, moduleTitle: module.title });
        });
      });
    });
    return flat;
  }

  function statusOf(taskId) { return Store.getTaskState(taskId).status; }

  /* ---- días de estudio --------------------------------------------------- */
  function isStudyDay(date) {
    const days = Store.getSettings().studyDays;
    if (!days || days.length === 0) return true;
    return days.includes(date.getDay());
  }
  function nextStudyDay(date) {
    const d = new Date(date);
    let guard = 0;
    while (!isStudyDay(d) && guard < 14) { d.setDate(d.getDate() + 1); guard++; }
    return d;
  }

  /* ---- plan de HOY ------------------------------------------------------- */
  function todayPlan() {
    const s = Store.getSettings();
    const budget = s.minutesPerDay || 60;
    const today = Store.todayStr();
    const log = Store.getActivityLog();
    const minutesDoneToday = log[today] || 0;

    const flat = allTasks();

    // tareas completadas HOY (para mostrarlas hechas arriba)
    const doneToday = flat.filter(it => {
      const st = Store.getTaskState(it.task.id);
      return st.status === 'done' && st.completedAt &&
             Store.todayStr(new Date(st.completedAt)) === today;
    });

    // cola de tareas pendientes (ni hechas ni saltadas), en orden
    const todoQueue = flat.filter(it => statusOf(it.task.id) === 'todo');

    // rellena el presupuesto restante de hoy
    const remaining = Math.max(0, budget - minutesDoneToday);
    const todayTodo = [];
    let used = 0;
    for (const it of todoQueue) {
      if (todayTodo.length > 0 && used + it.task.minutes > remaining) break;
      todayTodo.push(it);
      used += it.task.minutes;
      if (used >= remaining) break;
    }
    const upcoming = todoQueue.slice(todayTodo.length);

    return {
      budget,
      minutesDoneToday,
      remaining,
      doneToday,
      todayTodo,
      upcoming,
      restDay: !isStudyDay(new Date()),
      allDone: todoQueue.length === 0,
      dayComplete: todayTodo.length === 0 && todoQueue.length > 0,
    };
  }

  /* ---- proyección de fechas (cuándo terminarás) -------------------------- */
  function projection() {
    const s = Store.getSettings();
    const budget = s.minutesPerDay || 60;
    const today = Store.todayStr();
    const log = Store.getActivityLog();
    const minutesDoneToday = log[today] || 0;

    const todoQueue = allTasks().filter(it => statusOf(it.task.id) === 'todo');

    const dates = {};             // taskId -> 'YYYY-MM-DD' estimado
    let cursor = nextStudyDay(new Date());
    let remaining = budget - minutesDoneToday;
    if (remaining <= 0) { // hoy ya cumplido: empieza el siguiente día de estudio
      cursor = nextStudyDay(new Date(cursor.getTime() + 86400000));
      remaining = budget;
    }

    for (const it of todoQueue) {
      dates[it.task.id] = Store.todayStr(cursor);
      remaining -= it.task.minutes;
      if (remaining <= 0) {
        cursor = nextStudyDay(new Date(cursor.getTime() + 86400000));
        remaining = budget;
      }
    }

    const completionDate = todoQueue.length
      ? dates[todoQueue[todoQueue.length - 1].task.id]
      : today;

    return { dates, completionDate, remainingTasks: todoQueue.length };
  }

  /* ---- estadísticas globales -------------------------------------------- */
  function stats() {
    const flat = allTasks();
    let done = 0, skipped = 0;
    flat.forEach(it => {
      const st = statusOf(it.task.id);
      if (st === 'done') done++;
      else if (st === 'skipped') skipped++;
    });
    const counted = flat.length - skipped;
    const pct = counted > 0 ? Math.round((done / counted) * 100) : 0;

    // progreso por fase
    const phases = CURRICULUM.phases.map(phase => {
      let pDone = 0, pTotal = 0;
      phase.modules.forEach(m => m.tasks.forEach(t => {
        const st = statusOf(t.id);
        if (st !== 'skipped') pTotal++;
        if (st === 'done') pDone++;
      }));
      return {
        id: phase.id, title: phase.title, icon: phase.icon,
        done: pDone, total: pTotal,
        pct: pTotal > 0 ? Math.round((pDone / pTotal) * 100) : 0,
      };
    });

    // módulos completados (todos sus no-saltados están hechos)
    let modulesDone = 0, modulesTotal = 0;
    CURRICULUM.phases.forEach(p => p.modules.forEach(m => {
      modulesTotal++;
      const relevant = m.tasks.filter(t => statusOf(t.id) !== 'skipped');
      if (relevant.length > 0 && relevant.every(t => statusOf(t.id) === 'done')) modulesDone++;
    }));

    // horas totales (según registro de actividad)
    const log = Store.getActivityLog();
    const totalMinutes = Object.values(log).reduce((a, b) => a + b, 0);

    return {
      totalTasks: flat.length,
      done, skipped, counted, pct,
      phases,
      modulesDone, modulesTotal,
      totalMinutes,
      totalHours: +(totalMinutes / 60).toFixed(1),
      streak: streak(),
      currentPhase: phases.find(p => p.pct < 100) || phases[phases.length - 1],
    };
  }

  /* ---- racha de días seguidos estudiando -------------------------------- */
  function streak() {
    const log = Store.getActivityLog();
    let count = 0;
    const d = new Date();
    // si hoy todavía no has estudiado, no rompas la racha: cuenta desde ayer
    if (!log[Store.todayStr(d)]) d.setDate(d.getDate() - 1);
    let guard = 0;
    while (log[Store.todayStr(d)] && guard < 3650) {
      count++; d.setDate(d.getDate() - 1); guard++;
    }
    return count;
  }

  /* ---- series para las gráficas ----------------------------------------- */
  function activitySeries(days) {
    days = days || 14;
    const log = Store.getActivityLog();
    const out = [];
    const d = new Date();
    d.setDate(d.getDate() - (days - 1));
    for (let i = 0; i < days; i++) {
      const key = Store.todayStr(d);
      out.push({ date: key, minutes: log[key] || 0 });
      d.setDate(d.getDate() + 1);
    }
    return out;
  }

  function cumulativeHours(days) {
    days = days || 30;
    const series = activitySeries(days);
    let acc = 0;
    return series.map(pt => {
      acc += pt.minutes;
      return { date: pt.date, hours: +(acc / 60).toFixed(2) };
    });
  }

  return {
    allTasks, todayPlan, projection, stats, streak,
    activitySeries, cumulativeHours, isStudyDay,
  };
})();

window.Scheduler = Scheduler;
