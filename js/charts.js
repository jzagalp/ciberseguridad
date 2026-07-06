/* ============================================================================
 *  CHARTS — gráficas en SVG, ligeras, accesibles y con modo claro/oscuro.
 *  Siguen la guía de visualización: una sola tónica (azul) para magnitud,
 *  marcas finas, extremos redondeados, ejes discretos y capa de hover.
 * ==========================================================================*/

const Charts = (function () {

  /* tooltip compartido */
  let tip;
  function tooltip() {
    if (!tip) {
      tip = document.createElement('div');
      tip.className = 'chart-tip';
      tip.setAttribute('role', 'status');
      document.body.appendChild(tip);
    }
    return tip;
  }
  function showTip(html, x, y) {
    const t = tooltip();
    t.innerHTML = html;
    t.style.display = 'block';
    t.style.left = x + 'px';
    t.style.top = y + 'px';
  }
  function hideTip() { if (tip) tip.style.display = 'none'; }

  const NS = 'http://www.w3.org/2000/svg';
  function el(name, attrs) {
    const n = document.createElementNS(NS, name);
    for (const k in attrs) n.setAttribute(k, attrs[k]);
    return n;
  }

  /* -------------------------------------------------------------------------
   *  Anillo de progreso (hero): un número grande + aro de avance.
   * ---------------------------------------------------------------------- */
  function progressRing(container, pct) {
    container.innerHTML = '';
    const size = 168, stroke = 14, r = (size - stroke) / 2, c = 2 * Math.PI * r;
    const svg = el('svg', { viewBox: `0 0 ${size} ${size}`, width: size, height: size, class: 'ring' });

    svg.appendChild(el('circle', {
      cx: size / 2, cy: size / 2, r, fill: 'none',
      stroke: 'var(--grid)', 'stroke-width': stroke,
    }));
    const arc = el('circle', {
      cx: size / 2, cy: size / 2, r, fill: 'none',
      stroke: 'var(--series-1)', 'stroke-width': stroke, 'stroke-linecap': 'round',
      'stroke-dasharray': c, 'stroke-dashoffset': c * (1 - pct / 100),
      transform: `rotate(-90 ${size / 2} ${size / 2})`,
    });
    arc.style.transition = 'stroke-dashoffset .8s cubic-bezier(.22,1,.36,1)';
    svg.appendChild(arc);

    const num = el('text', {
      x: size / 2, y: size / 2 - 2, 'text-anchor': 'middle',
      'dominant-baseline': 'middle', class: 'ring-num',
    });
    num.textContent = pct + '%';
    const lbl = el('text', {
      x: size / 2, y: size / 2 + 26, 'text-anchor': 'middle',
      'dominant-baseline': 'middle', class: 'ring-lbl',
    });
    lbl.textContent = 'completado';
    svg.appendChild(num); svg.appendChild(lbl);
    container.appendChild(svg);
  }

  /* -------------------------------------------------------------------------
   *  Barras horizontales de progreso por fase (magnitud → una sola tónica).
   * ---------------------------------------------------------------------- */
  function phaseBars(container, phases) {
    container.innerHTML = '';
    const wrap = document.createElement('div');
    wrap.className = 'hbar-list';
    phases.forEach(p => {
      const row = document.createElement('div');
      row.className = 'hbar-row';
      row.innerHTML = `
        <div class="hbar-label"><span class="hbar-ico">${p.icon || ''}</span>${p.title}</div>
        <div class="hbar-track" title="${p.done}/${p.total} tareas">
          <div class="hbar-fill" style="width:${p.pct}%"></div>
        </div>
        <div class="hbar-val">${p.pct}%</div>`;
      wrap.appendChild(row);
    });
    container.appendChild(wrap);
  }

  /* -------------------------------------------------------------------------
   *  Barras verticales: minutos de estudio por día (últimos N días).
   * ---------------------------------------------------------------------- */
  function activityBars(container, series) {
    container.innerHTML = '';
    const W = 620, H = 200, padL = 34, padR = 12, padT = 14, padB = 26;
    const iw = W - padL - padR, ih = H - padT - padB;
    const max = Math.max(60, ...series.map(d => d.minutes));
    const n = series.length;
    const gap = 4;
    const bw = (iw / n) - gap;

    const svg = el('svg', { viewBox: `0 0 ${W} ${H}`, class: 'chart', preserveAspectRatio: 'xMidYMid meet' });

    // rejilla y etiquetas del eje Y (en horas)
    [0, 0.5, 1].forEach(f => {
      const y = padT + ih - ih * f;
      svg.appendChild(el('line', { x1: padL, y1: y, x2: W - padR, y2: y, stroke: 'var(--grid)', 'stroke-width': 1 }));
      const t = el('text', { x: padL - 6, y: y + 3, 'text-anchor': 'end', class: 'axis' });
      t.textContent = Math.round((max * f) / 60 * 10) / 10 + 'h';
      svg.appendChild(t);
    });

    series.forEach((d, i) => {
      const x = padL + i * (bw + gap);
      const h = max > 0 ? (d.minutes / max) * ih : 0;
      const y = padT + ih - h;
      const rect = el('rect', {
        x, y: d.minutes > 0 ? y : padT + ih - 2,
        width: bw, height: d.minutes > 0 ? h : 2,
        rx: 4, fill: d.minutes > 0 ? 'var(--series-1)' : 'var(--grid)',
      });
      rect.style.cursor = 'default';
      rect.addEventListener('mousemove', (ev) => {
        const dd = new Date(d.date + 'T00:00:00');
        const label = dd.toLocaleDateString('es', { weekday: 'short', day: 'numeric', month: 'short' });
        showTip(`<b>${label}</b><br>${d.minutes} min de estudio`, ev.clientX + 12, ev.clientY + 12);
      });
      rect.addEventListener('mouseleave', hideTip);
      svg.appendChild(rect);

      // etiqueta de día (solo algunos para no saturar)
      if (i % Math.ceil(n / 7) === 0 || i === n - 1) {
        const dd = new Date(d.date + 'T00:00:00');
        const t = el('text', { x: x + bw / 2, y: H - 8, 'text-anchor': 'middle', class: 'axis' });
        t.textContent = dd.getDate();
        svg.appendChild(t);
      }
    });

    container.appendChild(svg);
  }

  /* -------------------------------------------------------------------------
   *  Área: horas acumuladas de estudio (una serie, con crosshair).
   * ---------------------------------------------------------------------- */
  function cumulativeArea(container, series) {
    container.innerHTML = '';
    const W = 620, H = 200, padL = 34, padR = 12, padT = 14, padB = 26;
    const iw = W - padL - padR, ih = H - padT - padB;
    const n = series.length;
    const max = Math.max(1, ...series.map(d => d.hours));
    const xAt = i => padL + (n <= 1 ? 0 : (i / (n - 1)) * iw);
    const yAt = v => padT + ih - (v / max) * ih;

    const svg = el('svg', { viewBox: `0 0 ${W} ${H}`, class: 'chart', preserveAspectRatio: 'xMidYMid meet' });

    [0, 0.5, 1].forEach(f => {
      const y = padT + ih - ih * f;
      svg.appendChild(el('line', { x1: padL, y1: y, x2: W - padR, y2: y, stroke: 'var(--grid)', 'stroke-width': 1 }));
      const t = el('text', { x: padL - 6, y: y + 3, 'text-anchor': 'end', class: 'axis' });
      t.textContent = (Math.round(max * f * 10) / 10) + 'h';
      svg.appendChild(t);
    });

    let line = '', area = '';
    series.forEach((d, i) => {
      const x = xAt(i), y = yAt(d.hours);
      line += (i === 0 ? 'M' : 'L') + x + ' ' + y + ' ';
    });
    area = line + `L ${xAt(n - 1)} ${padT + ih} L ${xAt(0)} ${padT + ih} Z`;

    // degradado del área
    const defs = el('defs', {});
    defs.innerHTML =
      `<linearGradient id="areaGrad" x1="0" y1="0" x2="0" y2="1">
         <stop offset="0%" stop-color="var(--series-1)" stop-opacity="0.28"/>
         <stop offset="100%" stop-color="var(--series-1)" stop-opacity="0.02"/>
       </linearGradient>`;
    svg.appendChild(defs);
    svg.appendChild(el('path', { d: area, fill: 'url(#areaGrad)', stroke: 'none' }));
    svg.appendChild(el('path', { d: line, fill: 'none', stroke: 'var(--series-1)', 'stroke-width': 2, 'stroke-linejoin': 'round', 'stroke-linecap': 'round' }));

    // capa de crosshair
    const cross = el('line', { x1: 0, y1: padT, x2: 0, y2: padT + ih, stroke: 'var(--baseline)', 'stroke-width': 1, opacity: 0 });
    const dot = el('circle', { r: 4.5, fill: 'var(--series-1)', stroke: 'var(--surface-1)', 'stroke-width': 2, opacity: 0 });
    svg.appendChild(cross); svg.appendChild(dot);

    const hit = el('rect', { x: padL, y: padT, width: iw, height: ih, fill: 'transparent' });
    hit.addEventListener('mousemove', (ev) => {
      const rect = svg.getBoundingClientRect();
      const rx = (ev.clientX - rect.left) / rect.width * W;
      let i = Math.round(((rx - padL) / iw) * (n - 1));
      i = Math.max(0, Math.min(n - 1, i));
      const d = series[i];
      const x = xAt(i), y = yAt(d.hours);
      cross.setAttribute('x1', x); cross.setAttribute('x2', x); cross.setAttribute('opacity', 1);
      dot.setAttribute('cx', x); dot.setAttribute('cy', y); dot.setAttribute('opacity', 1);
      const dd = new Date(d.date + 'T00:00:00');
      const label = dd.toLocaleDateString('es', { day: 'numeric', month: 'short' });
      showTip(`<b>${label}</b><br>${d.hours} h acumuladas`, ev.clientX + 12, ev.clientY + 12);
    });
    hit.addEventListener('mouseleave', () => { cross.setAttribute('opacity', 0); dot.setAttribute('opacity', 0); hideTip(); });
    svg.appendChild(hit);

    container.appendChild(svg);
  }

  return { progressRing, phaseBars, activityBars, cumulativeArea };
})();

window.Charts = Charts;
