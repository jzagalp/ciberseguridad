/* ============================================================================
 *  STORE — estado persistente de la app (localStorage)
 *  ---------------------------------------------------------------------------
 *  Guarda tu configuración, el estado de cada tarea, tus notas, tus tareas
 *  personalizadas y tu registro de actividad diaria. Todo vive en tu navegador;
 *  nada sale de tu equipo. Puedes exportarlo/importarlo desde Ajustes.
 * ==========================================================================*/

const Store = (function () {
  const KEY = 'cyberpath.state.v1';

  /* ---- utilidades de fecha (siempre en local, formato YYYY-MM-DD) -------- */
  function todayStr(d) {
    d = d || new Date();
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
  }

  function defaultState() {
    return {
      version: 1,
      createdAt: new Date().toISOString(),
      settings: {
        name: '',
        startDate: todayStr(),
        minutesPerDay: 60,          // tiempo que dedicas cada día de estudio
        studyDays: [1, 2, 3, 4, 5], // 0=Dom … 6=Sáb  (por defecto, entre semana)
        theme: 'auto',              // auto | light | dark
      },
      taskState: {},                // id -> { status, completedAt, minutesLogged, notes }
      customTasks: [],              // tareas creadas por el usuario
      activityLog: {},              // 'YYYY-MM-DD' -> minutos estudiados ese día
    };
  }

  let state = load();

  function load() {
    try {
      const raw = localStorage.getItem(KEY);
      if (!raw) return defaultState();
      const parsed = JSON.parse(raw);
      // fusiona con defaults por si añadimos campos nuevos en el futuro
      const base = defaultState();
      return {
        ...base,
        ...parsed,
        settings: { ...base.settings, ...(parsed.settings || {}) },
        taskState: parsed.taskState || {},
        customTasks: parsed.customTasks || [],
        activityLog: parsed.activityLog || {},
      };
    } catch (e) {
      console.warn('No se pudo cargar el estado, empezando de cero.', e);
      return defaultState();
    }
  }

  function save() {
    try {
      localStorage.setItem(KEY, JSON.stringify(state));
    } catch (e) {
      console.error('No se pudo guardar el estado.', e);
    }
  }

  /* ---- configuración ----------------------------------------------------- */
  function getSettings() { return { ...state.settings }; }
  function updateSettings(patch) {
    state.settings = { ...state.settings, ...patch };
    save();
  }

  /* ---- estado de tareas -------------------------------------------------- */
  function getTaskState(taskId) {
    return state.taskState[taskId] || { status: 'todo', completedAt: null, minutesLogged: 0, notes: '' };
  }

  function getAllTaskStates() { return { ...state.taskState }; }

  /**
   * Cambia el estado de una tarea. Al marcar "done" registra los minutos
   * estimados en el log de actividad del día (para racha y horas).
   * Al desmarcar, resta esos minutos.
   */
  function setTaskStatus(taskId, status, estMinutes) {
    const prev = getTaskState(taskId);
    const next = { ...prev, status };
    const today = todayStr();

    if (status === 'done' && prev.status !== 'done') {
      next.completedAt = new Date().toISOString();
      const mins = prev.minutesLogged || estMinutes || 0;
      next.minutesLogged = mins;
      addActivity(today, mins);
    } else if (status !== 'done' && prev.status === 'done') {
      // se desmarca: descuenta del día en que se completó (si hay registro ese día)
      const day = prev.completedAt ? todayStr(new Date(prev.completedAt)) : today;
      addActivity(day, -(prev.minutesLogged || 0));
      next.completedAt = null;
    }

    state.taskState[taskId] = next;
    save();
    return next;
  }

  function setTaskNotes(taskId, notes) {
    const prev = getTaskState(taskId);
    state.taskState[taskId] = { ...prev, notes };
    save();
  }

  /** Ajusta manualmente los minutos dedicados a una tarea ya completada. */
  function setTaskMinutes(taskId, minutes) {
    const prev = getTaskState(taskId);
    if (prev.status === 'done') {
      const diff = minutes - (prev.minutesLogged || 0);
      const day = prev.completedAt ? todayStr(new Date(prev.completedAt)) : todayStr();
      addActivity(day, diff);
    }
    state.taskState[taskId] = { ...prev, minutesLogged: minutes };
    save();
  }

  /* ---- registro de actividad -------------------------------------------- */
  function addActivity(dateStr, minutes) {
    const cur = state.activityLog[dateStr] || 0;
    const val = Math.max(0, cur + minutes);
    if (val === 0) delete state.activityLog[dateStr];
    else state.activityLog[dateStr] = val;
  }

  /** Registra manualmente minutos de estudio en una fecha (Ajustes/Hoy). */
  function logManualMinutes(dateStr, minutes) {
    addActivity(dateStr, minutes);
    save();
  }

  function getActivityLog() { return { ...state.activityLog }; }

  /* ---- tareas personalizadas -------------------------------------------- */
  function getCustomTasks() { return [...state.customTasks]; }

  function addCustomTask(task) {
    const id = 'custom-' + Date.now().toString(36);
    const full = {
      id,
      type: task.type || 'practica',
      minutes: Number(task.minutes) || 30,
      title: task.title || 'Tarea personalizada',
      summary: task.summary || '',
      steps: task.steps || [],
      resources: task.resources || [],
      phaseId: task.phaseId || null,   // dónde insertarla; null = al final
      custom: true,
    };
    state.customTasks.push(full);
    save();
    return full;
  }

  function removeCustomTask(id) {
    state.customTasks = state.customTasks.filter(t => t.id !== id);
    delete state.taskState[id];
    save();
  }

  /* ---- import / export / reset ------------------------------------------ */
  function exportData() { return JSON.stringify(state, null, 2); }

  function importData(json) {
    const parsed = typeof json === 'string' ? JSON.parse(json) : json;
    if (!parsed || typeof parsed !== 'object') throw new Error('Datos inválidos');
    const base = defaultState();
    state = {
      ...base,
      ...parsed,
      settings: { ...base.settings, ...(parsed.settings || {}) },
      taskState: parsed.taskState || {},
      customTasks: parsed.customTasks || [],
      activityLog: parsed.activityLog || {},
    };
    save();
  }

  function resetProgress() {
    const keepSettings = { ...state.settings };
    state = defaultState();
    state.settings = keepSettings;
    save();
  }

  function resetAll() {
    state = defaultState();
    save();
  }

  return {
    todayStr,
    getSettings, updateSettings,
    getTaskState, getAllTaskStates, setTaskStatus, setTaskNotes, setTaskMinutes,
    logManualMinutes, getActivityLog,
    getCustomTasks, addCustomTask, removeCustomTask,
    exportData, importData, resetProgress, resetAll,
  };
})();

window.Store = Store;
