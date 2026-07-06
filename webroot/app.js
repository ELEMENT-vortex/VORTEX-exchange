const MODULE_ID = 'vortex_exchange';
const MODULE_PATH = `/data/adb/modules/${MODULE_ID}`;
const pages = [...document.querySelectorAll('.page')];
const navItems = [...document.querySelectorAll('.nav-item')];
const pageTitle = document.getElementById('pageTitle');
const resultBox = document.getElementById('resultBox');
const detailsBox = document.getElementById('detailsBox');

let currentLang = localStorage.getItem('vortexLang') || 'es';
let currentTheme = localStorage.getItem('vortexThemeV6') || 'darkblue';

const I18N = {
  es: {
    kernelControlCenter: 'Centro de control del kernel',
    topSubtitle: 'API v2.2 • ABI 2.2 • KernelSU',
    heroDesc: 'Kernel detectado por Vortex API v2.2 / ABI 2.2',
    online: 'En línea',
    summary: 'Resumen',
    systemStatus: 'Estado del sistema',
    apiState: 'Estado',
    logKicker: 'Registro',
    kernel: 'Kernel',
    device: 'Dispositivo',
    notDetected: 'No detectada',
    currentProfile: 'Perfil actual',
    selected: 'Seleccionado',
    profiles: 'Perfiles',
    vortexModes: 'Modos VORTEX',
    safe: 'Seguro',
    profileDesc: 'Ajusta Diario, Gaming y Sueño a tu gusto.',
    dailyMode: 'Modo diario',
    gamingMode: 'Modo gaming',
    sleepMode: 'Modo sueño',
    dailyModeShort: 'Diario',
    gamingModeShort: 'Gaming',
    sleepModeShort: 'Sueño',
    dailyDesc: 'Uso diario. Prioriza estabilidad y temperatura.',
    ecoDesc: 'Más ahorro',
    recommended: 'Recomendado',
    cooler: 'Más fresco',
    smartDesc: 'Adapta temperatura/uso',
    gamingDesc: 'Rendimiento seguro con control CPU y lectura API v2.2.',
    lowerTemp: 'Menos temperatura',
    stable: 'Estable',
    betterResponse: 'Mejor respuesta',
    safeAggressive: 'Más agresivo seguro',
    sleepDesc: 'Para pantalla apagada. Adaptive es recomendado.',
    fastNotifications: 'Notificaciones rápidas',
    moreSaving: 'Más ahorro',
    deeper: 'Más profundo',
    toolsKicker: 'Herramientas',
    diagnosticLog: 'Diagnóstico y registro',
    diagnosticDesc: 'Herramientas de prueba y registro de acciones. No aplican cambios peligrosos.',
    refreshState: 'Actualizar estado',
    updateStatus: 'Actualizar estado',
    selfTest: 'Autoprueba',
    apiRoutes: 'API y rutas',
    exportReport: 'Exportar reporte',
    saveReport: 'Guardar reporte',
    resetDefaults: 'Restaurar valores',
    restoreModes: 'Restaurar modos',
    lastAction: 'Última acción',
    viewLog: 'Ver registro',
    hide: 'Ocultar',
    clear: 'Limpiar',
    readyText: 'Listo.',
    statusKicker: 'Estado',
    apiControlCenter: 'Centro de control de API',
    statusDesc: 'Estado resumido del módulo y del kernel.',
    apiPath: 'Ruta de API',
    thermal: 'Temperatura',
    technicalDetails: 'Detalles técnicos',
    viewDetails: 'Ver detalles',
    language: 'Idioma',
    theme: 'Tema',
    about: 'Acerca de',
    aboutDesc: 'Vortex API v2.2 • Edición NEON',
    mainNavigation: 'Navegación principal',
    home: 'Inicio',
    profilesNav: 'Perfiles',
    tools: 'Herramientas',
    statusNav: 'Estado',
    settings: 'Ajustes',
    listOpen: 'Abrir lista',
    listClose: 'Cerrar lista',
    titles: {
      home: 'VORTEX-exchange',
      profiles: 'Perfiles',
      tools: 'Herramientas',
      status: 'Estado',
      settings: 'Ajustes'
    },
    langLabel: 'Español'
  },
  en: {
    kernelControlCenter: 'Kernel Control Center',
    topSubtitle: 'API v2.2 • ABI 2.2 • KernelSU',
    heroDesc: 'Kernel detected by Vortex API v2.2 / ABI 2.2',
    online: 'Online',
    summary: 'Summary',
    systemStatus: 'System status',
    apiState: 'State',
    logKicker: 'Log',
    kernel: 'Kernel',
    device: 'Device',
    notDetected: 'Not detected',
    currentProfile: 'Current profile',
    selected: 'Selected',
    profiles: 'Profiles',
    vortexModes: 'VORTEX Modes',
    safe: 'Safe',
    profileDesc: 'Adjust Daily, Gaming and Sleep your way.',
    dailyMode: 'Daily Mode',
    gamingMode: 'Gaming Mode',
    sleepMode: 'Sleep Mode',
    dailyModeShort: 'Daily',
    gamingModeShort: 'Gaming',
    sleepModeShort: 'Sleep',
    dailyDesc: 'Daily use. Prioritizes stability and temperature.',
    ecoDesc: 'More saving',
    recommended: 'Recommended',
    cooler: 'Cooler',
    smartDesc: 'Adapts temperature/use',
    gamingDesc: 'Safe performance with CPU control and API v2.2 status reading.',
    lowerTemp: 'Lower temperature',
    stable: 'Stable',
    betterResponse: 'Better response',
    safeAggressive: 'More aggressive, safe',
    sleepDesc: 'For screen off. Adaptive is recommended.',
    fastNotifications: 'Fast notifications',
    moreSaving: 'More saving',
    deeper: 'Deeper',
    toolsKicker: 'Tools',
    diagnosticLog: 'Diagnostics and log',
    diagnosticDesc: 'Testing tools and action log. They do not apply dangerous changes.',
    refreshState: 'Refresh state',
    updateStatus: 'Update status',
    selfTest: 'Self test',
    apiRoutes: 'API and paths',
    exportReport: 'Export report',
    saveReport: 'Save report',
    resetDefaults: 'Reset defaults',
    restoreModes: 'Restore modes',
    lastAction: 'Last action',
    viewLog: 'View log',
    hide: 'Hide',
    clear: 'Clear',
    readyText: 'Ready.',
    statusKicker: 'Status',
    apiControlCenter: 'API Control Center',
    statusDesc: 'Short module and kernel status.',
    apiPath: 'API path',
    thermal: 'Thermal',
    technicalDetails: 'Technical details',
    viewDetails: 'View details',
    language: 'Language',
    theme: 'Theme',
    about: 'About',
    aboutDesc: 'Vortex API v2.2 • NEON Edition',
    mainNavigation: 'Main navigation',
    home: 'Home',
    profilesNav: 'Profiles',
    tools: 'Tools',
    statusNav: 'Status',
    settings: 'Settings',
    listOpen: 'Open list',
    listClose: 'Close list',
    titles: {
      home: 'VORTEX-exchange',
      profiles: 'Profiles',
      tools: 'Tools',
      status: 'Status',
      settings: 'Settings'
    },
    langLabel: 'English'
  },
  id: {
    kernelControlCenter: 'Pusat Kontrol Kernel',
    topSubtitle: 'API v2.2 • ABI 2.2 • KernelSU',
    heroDesc: 'Kernel terdeteksi oleh Vortex API v2.2 / ABI 2.2',
    online: 'Online',
    summary: 'Ringkasan',
    systemStatus: 'Status sistem',
    apiState: 'Status',
    logKicker: 'Log',
    kernel: 'Kernel',
    device: 'Perangkat',
    notDetected: 'Tidak terdeteksi',
    currentProfile: 'Profil aktif',
    selected: 'Dipilih',
    profiles: 'Profil',
    vortexModes: 'Mode VORTEX',
    safe: 'Aman',
    profileDesc: 'Atur Harian, Gaming, dan Tidur sesuai kebutuhanmu.',
    dailyMode: 'Mode Harian',
    gamingMode: 'Mode Gaming',
    sleepMode: 'Mode Tidur',
    dailyModeShort: 'Harian',
    gamingModeShort: 'Gaming',
    sleepModeShort: 'Tidur',
    dailyDesc: 'Pemakaian harian. Mengutamakan stabilitas dan suhu.',
    ecoDesc: 'Lebih hemat',
    recommended: 'Direkomendasikan',
    cooler: 'Lebih dingin',
    smartDesc: 'Menyesuaikan suhu/pemakaian',
    gamingDesc: 'Performa aman dengan kontrol CPU dan pembacaan status API v2.2.',
    lowerTemp: 'Suhu lebih rendah',
    stable: 'Stabil',
    betterResponse: 'Respons lebih baik',
    safeAggressive: 'Lebih agresif, tetap aman',
    sleepDesc: 'Untuk layar mati. Adaptive direkomendasikan.',
    fastNotifications: 'Notifikasi cepat',
    moreSaving: 'Lebih hemat',
    deeper: 'Lebih dalam',
    toolsKicker: 'Alat',
    diagnosticLog: 'Diagnostik dan log',
    diagnosticDesc: 'Alat pengujian dan catatan aksi. Tidak menerapkan perubahan berbahaya.',
    refreshState: 'Segarkan status',
    updateStatus: 'Perbarui status',
    selfTest: 'Uji mandiri',
    apiRoutes: 'API dan jalur',
    exportReport: 'Ekspor laporan',
    saveReport: 'Simpan laporan',
    resetDefaults: 'Pulihkan bawaan',
    restoreModes: 'Pulihkan mode',
    lastAction: 'Aksi terakhir',
    viewLog: 'Lihat log',
    hide: 'Sembunyikan',
    clear: 'Bersihkan',
    readyText: 'Siap.',
    statusKicker: 'Status',
    apiControlCenter: 'Pusat Kontrol API',
    statusDesc: 'Ringkasan status modul dan kernel.',
    apiPath: 'Jalur API',
    thermal: 'Termal',
    technicalDetails: 'Detail teknis',
    viewDetails: 'Lihat detail',
    language: 'Bahasa',
    theme: 'Tema',
    about: 'Tentang',
    aboutDesc: 'Vortex API v2.2 • Edisi NEON',
    mainNavigation: 'Navigasi utama',
    home: 'Beranda',
    profilesNav: 'Profil',
    tools: 'Alat',
    statusNav: 'Status',
    settings: 'Pengaturan',
    listOpen: 'Buka daftar',
    listClose: 'Tutup daftar',
    titles: {
      home: 'VORTEX-exchange',
      profiles: 'Profil',
      tools: 'Alat',
      status: 'Status',
      settings: 'Pengaturan'
    },
    langLabel: 'Indonesia'
  }
};

const langLabelsSimple = { es: 'Español', en: 'English', id: 'Indonesia' };

const themeLabels = {
  es: {
    darkblue: '🌙 Azul oscuro',
    darkpurple: '🔮 Morado oscuro',
    darkgreen: '🌿 Verde oscuro',
    darkorange: '🔥 Naranja oscuro',
    darkred: '❤️ Rojo oscuro',
  },
  en: {
    darkblue: '🌙 Dark Blue',
    darkpurple: '🔮 Dark Purple',
    darkgreen: '🌿 Dark Green',
    darkorange: '🔥 Dark Orange',
    darkred: '❤️ Dark Red',
  },
  id: {
    darkblue: '🌙 Biru gelap',
    darkpurple: '🔮 Ungu gelap',
    darkgreen: '🌿 Hijau gelap',
    darkorange: '🔥 Oranye gelap',
    darkred: '❤️ Merah gelap',
  }
};
function themeLabel(theme) {
  return (themeLabels[currentLang] && themeLabels[currentLang][theme]) || themeLabels.en[theme] || theme;
}

let currentData = {
  PerfilBase: localStorage.getItem('profileBase') || 'daily',
  DailyMode: localStorage.getItem('dailyMode') || 'balanced',
  GamingMode: localStorage.getItem('gamingMode') || 'balanced',
  SleepMode: localStorage.getItem('sleepMode') || 'adaptive',
  Kernel: '',
  KernelName: '',
  KernelVersion: '',
  V2APIVersion: '',
  VortexAPI: '',
  APIPath: '/sys/kernel/vortex/v2',
  APIState: '',
  ABI: '',
  ThermalState: '',
  Android: '',
  SDK: '',
  Device: '',
  ROM: '',
  ROMName: '',
  ROMCode: '',
  Familia: ''
};

function tr(key) {
  return (I18N[currentLang] && I18N[currentLang][key]) || I18N.es[key] || key;
}

function mockStatus() {
  return `PerfilBase=${currentData.PerfilBase || 'daily'}
DailyMode=${currentData.DailyMode || 'balanced'}
GamingMode=${currentData.GamingMode || 'balanced'}
SleepMode=${currentData.SleepMode || 'adaptive'}
Kernel=VortexAGNI-1.4-APIv2.2-KSU
KernelName=VortexAGNI-1.4
KernelVersion=dynamic
VortexAPI=v2.2
RootAPIVersion=2
APIPath=/sys/kernel/vortex/v2
V2APIVersion=2
ABI=2.2
APIState=preview
CheckCompatibility=1
CompatibilityReason=PREVIEW
ROMType=3
ROMSource=preview
API=PREVIEW
ROM=Preview Browser
ROMName=Preview Browser
ROMCode=Preview
Familia=Preview
Android=--
SDK=--
Device=sweet/sweetin
Failsafe=1
ThermalState=preview
LastError=none`;
}

function hasKsuBridge() {
  return !!(window.ksu && (typeof window.ksu.exec === 'function' || typeof window.ksu.execShell === 'function'));
}

function switchPage(id) {
  pages.forEach(p => p.classList.toggle('active', p.id === id));
  navItems.forEach(n => n.classList.toggle('active', n.dataset.page === id));
  pageTitle.textContent = tr('titles')[id] || 'VORTEX-exchange';
  window.scrollTo({ top: 0, behavior: 'smooth' });
}
navItems.forEach(item => item.addEventListener('click', () => switchPage(item.dataset.page)));

function applyI18n() {
  document.documentElement.lang = currentLang;
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.dataset.i18n;
    el.textContent = tr(key);
  });
  document.querySelectorAll('[data-i18n-aria]').forEach(el => {
    const key = el.dataset.i18nAria;
    el.setAttribute('aria-label', tr(key));
  });
  document.getElementById('currentLanguage').textContent = langLabelsSimple[currentLang] || tr('langLabel');
  document.getElementById('currentTheme').textContent = themeLabel(currentTheme);
  document.querySelectorAll('[data-theme-select]').forEach(btn => {
    btn.textContent = themeLabel(btn.dataset.themeSelect);
  });
  document.querySelectorAll('[data-lang-select]').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.langSelect === currentLang);
  });
  const activePage = document.querySelector('.page.active')?.id || 'home';
  pageTitle.textContent = tr('titles')[activePage] || 'VORTEX-exchange';
}

function parseKV(text) {
  const data = {};
  String(text || '').split(/\r?\n/).forEach(line => {
    const idx = line.indexOf('=');
    if (idx > 0) data[line.slice(0, idx).trim()] = line.slice(idx + 1).trim();
  });
  return data;
}

function titleCase(value) {
  return String(value || '--').replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
}

function apiLabel(data = currentData) {
  if ((data.APIState && data.APIState !== 'ready' && data.APIState !== 'preview') && !data.V2APIVersion && !data.VortexAPI) return 'NO API';
  const abi = String(data.ABI || data.ABIVersion || '').trim();
  const explicit = String(data.VortexAPI || '').trim();
  if (/2\.2/.test(explicit) || /^2\.2/.test(abi)) return 'API v2.2';
  const raw = explicit || data.V2APIVersion || '';
  if (!raw) return 'NO API';
  return 'API v' + String(raw).replace(/^v/i, '');
}

function isRealRom(value) {
  const v = String(value || '').toLowerCase().trim();
  if (!v) return false;
  if (v.includes('no detectada')) return false;
  if (v.includes('unknown')) return false;
  if (v.includes('detectando')) return false;
  return true;
}

function romLabel(data = currentData) {
  const rom = data.ROMName || data.PortName || data.ROM || '';
  if (isRealRom(rom)) return rom;
  const code = data.ROMCode || '';
  return isRealRom(code) ? code : tr('notDetected');
}

function selectedProfile(data = currentData) {
  const p = String(data.PerfilBase || 'daily').toLowerCase();
  if (p === 'gaming') return { name: 'Gaming', option: titleCase(data.GamingMode) };
  return { name: 'Daily', option: titleCase(data.DailyMode) };
}

async function ksuExec(command) {
  const timeoutMs = 30000;

  if (window.ksu && typeof window.ksu.exec === 'function') {
    return await new Promise(resolve => {
      let finished = false;
      const cbName = `vortex_cb_${Date.now()}_${Math.floor(Math.random() * 100000)}`;
      const finish = (text) => {
        if (finished) return;
        finished = true;
        try { delete window[cbName]; } catch (_) {}
        resolve(String(text || '').trim());
      };

      window[cbName] = (errno, stdout, stderr) => {
        const out = [stdout || '', stderr || ''].filter(Boolean).join('\n');
        finish(out || (errno ? `ERROR errno=${errno}` : ''));
      };

      try {
        const ret = window.ksu.exec(command, '{}', cbName);
        if (ret && typeof ret.then === 'function') {
          ret.then(v => {
            if (typeof v === 'string') finish(v);
            else if (v && typeof v.stdout === 'string') finish(v.stdout + (v.stderr ? `\n${v.stderr}` : ''));
          }).catch(err => finish(`ERROR: ${err.message || err}`));
        } else if (typeof ret === 'string' && ret.length) {
          finish(ret);
        }
      } catch (err) {
        try {
          const ret = window.ksu.exec(command);
          if (ret && typeof ret.then === 'function') {
            ret.then(v => finish(typeof v === 'string' ? v : JSON.stringify(v, null, 2)))
              .catch(e => finish(`ERROR: ${e.message || e}`));
          } else if (typeof ret === 'string') {
            finish(ret);
          } else {
            finish(`ERROR: ${err.message || err}`);
          }
        } catch (err2) {
          finish(`ERROR: ${err2.message || err2}`);
        }
      }

      setTimeout(() => finish('ERROR: timeout ejecutando comando'), timeoutMs);
    });
  }

  if (window.ksu && typeof window.ksu.execShell === 'function') {
    try {
      const out = await window.ksu.execShell(command);
      if (typeof out === 'string') return out;
      if (out && typeof out.stdout === 'string') return out.stdout + (out.stderr ? `\n${out.stderr}` : '');
      return JSON.stringify(out, null, 2);
    } catch (err) {
      return `ERROR: ${err.message || err}`;
    }
  }

  await new Promise(r => setTimeout(r, 120));
  if (command.includes('status_lite.sh')) return mockStatus();
  if (command.includes('set_daily_mode.sh')) {
    const mode = command.trim().split(/\s+/).pop();
    currentData.DailyMode = mode;
    currentData.PerfilBase = 'daily';
    persistModes();
    return `OK PREVIEW: Daily Mode cambiado a ${mode}`;
  }
  if (command.includes('set_gaming_mode.sh')) {
    const mode = command.trim().split(/\s+/).pop();
    currentData.GamingMode = mode;
    currentData.PerfilBase = 'gaming';
    persistModes();
    return `OK PREVIEW: Gaming Mode cambiado a ${mode}`;
  }
  if (command.includes('set_sleep_mode.sh')) {
    const mode = command.trim().split(/\s+/).pop();
    currentData.SleepMode = mode;
    persistModes();
    return `OK PREVIEW: Sleep Mode cambiado a ${mode}`;
  }
  if (command.includes('self_test.sh')) return 'Self Test: PREVIEW\nKernelSU WebUI: no disponible en navegador\nVortex API v2.2: preview';
  if (command.includes('report.sh')) return 'OK PREVIEW: reporte simulado creado';
  if (command.includes('reset_defaults.sh')) {
    currentData.PerfilBase = 'daily';
    currentData.DailyMode = 'balanced';
    currentData.GamingMode = 'balanced';
    currentData.SleepMode = 'adaptive';
    persistModes();
    return 'OK PREVIEW: valores por defecto restaurados';
  }
  return 'OK PREVIEW';
}
function persistModes() {
  localStorage.setItem('profileBase', currentData.PerfilBase || 'daily');
  localStorage.setItem('dailyMode', currentData.DailyMode || 'balanced');
  localStorage.setItem('gamingMode', currentData.GamingMode || 'balanced');
  localStorage.setItem('sleepMode', currentData.SleepMode || 'adaptive');
}

function applyStatus(text) {
  const data = parseKV(text);
  currentData = { ...currentData, ...data };

  currentData.DailyMode = currentData.DailyMode || localStorage.getItem('dailyMode') || 'balanced';
  currentData.GamingMode = currentData.GamingMode || localStorage.getItem('gamingMode') || 'balanced';
  currentData.SleepMode = currentData.SleepMode || localStorage.getItem('sleepMode') || 'adaptive';

  // Si un módulo viejo dejó PerfilBase=sleep, lo normalizamos porque Sleep es subperfil.
  if (String(currentData.PerfilBase || '').toLowerCase() === 'sleep') {
    currentData.PerfilBase = localStorage.getItem('profileBase');
    if (!currentData.PerfilBase || currentData.PerfilBase === 'sleep') currentData.PerfilBase = 'daily';
  }

  currentData.PerfilBase = currentData.PerfilBase || localStorage.getItem('profileBase') || 'daily';
  persistModes();

  const selected = selectedProfile(currentData);
  const api = apiLabel(currentData);
  const rom = romLabel(currentData);

  document.getElementById('apiMetricValue').textContent = api;
  document.getElementById('apiBadgeSmall').textContent = api;
  document.getElementById('heroApiBadge').textContent = api === 'NO API' ? 'NO API' : `${api} Ready`;

  document.getElementById('kernelHome').textContent = currentData.Kernel || currentData.KernelName || 'VortexAGNI-1.4-APIv2.2-KSU';
  const abiValue = currentData.ABI || currentData.ABIVersion || (api.includes('2.2') ? '2.2' : '—');
  const apiStateValue = titleCase(currentData.APIState || currentData.API || '—');
  const abiHome = document.getElementById('abiHome');
  const apiStateHome = document.getElementById('apiStateHome');
  if (abiHome) abiHome.textContent = abiValue;
  if (apiStateHome) apiStateHome.textContent = apiStateValue;
  document.getElementById('androidValue').textContent = currentData.Android || '—';
  document.getElementById('sdkValue').textContent = currentData.SDK || '—';
  document.getElementById('romValue').textContent = rom;
  document.getElementById('deviceValue').textContent = currentData.Device || '—';

  document.getElementById('currentProfileHome').textContent = selected.name;
  document.getElementById('currentProfileOption').textContent = `${tr('selected')}: ${selected.option}`;
  document.getElementById('sleepAnchorOption').textContent = `${tr('selected')}: ${titleCase(currentData.SleepMode)}`;

  document.getElementById('kernelStatus').textContent = currentData.Kernel || currentData.KernelName || 'VortexAGNI-1.4-APIv2.2-KSU';
  document.getElementById('apiStatus').textContent = api;
  const abiStatus = document.getElementById('abiStatus');
  const thermalStatus = document.getElementById('thermalStatus');
  if (abiStatus) abiStatus.textContent = abiValue;
  document.getElementById('apiPathStatus').textContent = currentData.APIPath || '/sys/kernel/vortex/v2';
  if (thermalStatus) thermalStatus.textContent = titleCase(currentData.ThermalState || '--');
  document.getElementById('dailyStatus').textContent = titleCase(currentData.DailyMode);
  document.getElementById('gamingStatus').textContent = titleCase(currentData.GamingMode);
  document.getElementById('sleepStatus').textContent = titleCase(currentData.SleepMode);

  updateActiveButtons();
  detailsBox.textContent = text;
}

function updateActiveButtons() {
  document.querySelectorAll('[data-command]').forEach(btn => {
    const type = btn.dataset.command;
    const mode = String(btn.dataset.mode || '').toLowerCase();
    let active = false;
    if (type === 'daily') active = String(currentData.PerfilBase || '').toLowerCase() === 'daily' && String(currentData.DailyMode || '').toLowerCase() === mode;
    if (type === 'gaming') active = String(currentData.PerfilBase || '').toLowerCase() === 'gaming' && String(currentData.GamingMode || '').toLowerCase() === mode;
    if (type === 'sleep') active = String(currentData.SleepMode || '').toLowerCase() === mode;
    btn.classList.toggle('active', active);
  });
}

async function refreshStatus(showResult = false) {
  const out = await ksuExec(`sh ${MODULE_PATH}/common/status_lite.sh`);
  applyStatus(out);
  if (showResult) resultBox.textContent = 'Estado actualizado.\n' + out;
}

document.querySelectorAll('[data-command]').forEach(btn => {
  btn.addEventListener('click', async () => {
    const type = btn.dataset.command;
    const mode = btn.dataset.mode;
    const map = { daily: 'set_daily_mode.sh', gaming: 'set_gaming_mode.sh', sleep: 'set_sleep_mode.sh' };
    btn.disabled = true;
    const out = await ksuExec(`sh ${MODULE_PATH}/common/${map[type]} ${mode}`);
    resultBox.textContent = out;
    await refreshStatus(false);
    btn.disabled = false;
  });
});

document.querySelectorAll('[data-tool]').forEach(btn => {
  btn.addEventListener('click', async () => {
    const tool = btn.dataset.tool;
    const map = { refresh: 'status_lite.sh', selftest: 'self_test.sh', report: 'report.sh', reset: 'reset_defaults.sh' };
    btn.disabled = true;
    const out = await ksuExec(`sh ${MODULE_PATH}/common/${map[tool]}`);
    resultBox.textContent = out;
    if (tool === 'refresh' || tool === 'reset') await refreshStatus(false);
    btn.disabled = false;
  });
});

document.getElementById('refreshTop').addEventListener('click', () => refreshStatus(true));
document.getElementById('clearResult').addEventListener('click', () => { resultBox.textContent = tr('readyText'); });

document.getElementById('toggleResult').addEventListener('click', () => {
  resultBox.classList.toggle('expanded');
  document.getElementById('toggleResult').textContent = resultBox.classList.contains('expanded') ? tr('hide') : tr('viewLog');
});
document.getElementById('toggleDetails').addEventListener('click', () => {
  const expanded = detailsBox.classList.toggle('expanded');
  detailsBox.classList.toggle('collapsed', !expanded);
  document.getElementById('toggleDetails').textContent = expanded ? tr('hide') : tr('viewDetails');
});

function setTheme(theme) {
  currentTheme = theme;
  document.body.dataset.theme = theme;
  localStorage.setItem('vortexThemeV6', theme);
  document.querySelectorAll('[data-theme-select]').forEach(b => b.classList.toggle('active', b.dataset.themeSelect === theme));
  document.getElementById('currentTheme').textContent = themeLabel(theme);
}

function toggleOptions(id) {
  const box = document.getElementById(id);
  const isOpen = box.classList.contains('open');
  document.querySelectorAll('.option-list').forEach(o => {
    o.classList.remove('open');
    o.classList.add('collapsed');
  });
  document.querySelectorAll('.select-pill').forEach(btn => btn.classList.remove('is-open'));

  if (!isOpen) {
    box.classList.remove('collapsed');
    box.classList.add('open');
    const toggle = id === 'themeOptions' ? document.getElementById('themeToggle') : document.getElementById('languageToggle');
    toggle.classList.add('is-open');
    toggle.setAttribute('aria-label', tr('listClose'));
  }
}

document.getElementById('themeToggle').addEventListener('click', () => toggleOptions('themeOptions'));
document.getElementById('languageToggle').addEventListener('click', () => toggleOptions('languageOptions'));

document.querySelectorAll('[data-theme-select]').forEach(btn => {
  btn.addEventListener('click', () => {
    setTheme(btn.dataset.themeSelect);
    toggleOptions('themeOptions');
  });
});

document.querySelectorAll('[data-lang-select]').forEach(btn => {
  btn.addEventListener('click', () => {
    currentLang = btn.dataset.langSelect;
    localStorage.setItem('vortexLang', currentLang);
    applyI18n();
    refreshSelectorA11y();
    applyStatus(hasKsuBridge() ? detailsBox.textContent : mockStatus());
    toggleOptions('languageOptions');
  });
});

function refreshSelectorA11y() {
  const themeToggle = document.getElementById('themeToggle');
  const languageToggle = document.getElementById('languageToggle');
  if (themeToggle) themeToggle.setAttribute('aria-label', tr('listOpen'));
  if (languageToggle) languageToggle.setAttribute('aria-label', tr('listOpen'));
}

function init() {
  setTheme(currentTheme);
  applyI18n();
  refreshSelectorA11y();
  if (!hasKsuBridge()) applyStatus(mockStatus());
  refreshStatus(false);
}
init();
