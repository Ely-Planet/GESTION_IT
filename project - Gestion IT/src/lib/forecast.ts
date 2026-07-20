import type {
  HardwareItem,
  License,
  LicenseType,
  Movement,
} from './supabase';

export type CategoryStock = {
  categoryId: string;
  inStock: number;
  assigned: number;
  beingReinstalled: number;
  retired: number;
  defective: number;
  available: number;
};

export type LicenseStock = {
  licenseTypeId: string;
  total: number;
  available: number;
  assigned: number;
  reserved: number;
  resiliated: number;
};

export type ForecastAlert = {
  id: string;
  severity: 'critical' | 'warning';
  message: string;
  category?: string;
  date?: string;
};

export type HardwareCategoryLite = {
  id: string;
  code: string;
  label: string;
  tracked_for_person: boolean;
};

export function computeStockByCategory(
  hardware: HardwareItem[],
): Map<string, CategoryStock> {
  const map = new Map<string, CategoryStock>();
  for (const h of hardware) {
    let entry = map.get(h.category_id);
    if (!entry) {
      entry = {
        categoryId: h.category_id,
        inStock: 0,
        assigned: 0,
        beingReinstalled: 0,
        retired: 0,
        defective: 0,
        available: 0,
      };
      map.set(h.category_id, entry);
    }
    switch (h.status) {
      case 'in_stock':
        entry.inStock++;
        entry.available++;
        break;
      case 'assigned':
        entry.assigned++;
        break;
      case 'being_reinstalled':
        entry.beingReinstalled++;
        entry.available++;
        break;
      case 'retired':
        entry.retired++;
        break;
      case 'defective':
        entry.defective++;
        break;
    }
  }
  return map;
}

export function computeLicenseStock(
  licenses: License[],
  licenseTypes: LicenseType[],
): Map<string, LicenseStock> {
  const map = new Map<string, LicenseStock>();
  for (const lt of licenseTypes) {
    map.set(lt.id, {
      licenseTypeId: lt.id,
      total: lt.total_seats,
      available: lt.total_seats,
      assigned: 0,
      reserved: 0,
      resiliated: 0,
    });
  }
  for (const lic of licenses) {
    const entry = map.get(lic.license_type_id);
    if (!entry) continue;
    if (lic.status === 'assigned') {
      entry.assigned++;
      entry.available = Math.max(0, entry.available - 1);
    } else if (lic.status === 'reserved') {
      entry.reserved++;
      entry.available = Math.max(0, entry.available - 1);
    } else if (lic.status === 'resiliated') {
      entry.resiliated++;
      entry.available = Math.max(0, entry.available - 1);
    }
  }
  return map;
}

const TRACKED_FOR_ONBOARDING = ['PC', 'PHONE', 'HEADSET'];

export function computeForecast(
  hardware: HardwareItem[],
  licenses: License[],
  licenseTypes: LicenseType[],
  movements: Movement[],
  hardwareCategories: HardwareCategoryLite[],
  asOf: string,
): ForecastAlert[] {
  const alerts = computeForecastV2(hardware, licenses, licenseTypes, movements, hardwareCategories, asOf);
  const timeSeries = computeStockTimeSeries(hardware, movements, hardwareCategories, asOf);
  return [...alerts, ...timeSeries];
}

function computeForecastV2(
  hardware: HardwareItem[],
  licenses: License[],
  licenseTypes: LicenseType[],
  movements: Movement[],
  hardwareCategories: HardwareCategoryLite[],
  asOf: string,
): ForecastAlert[] {
  const alerts: ForecastAlert[] = [];
  const asOfDate = new Date(asOf);

  const catIdByCode = new Map<string, string>();
  const catLabelById = new Map<string, string>();
  for (const c of hardwareCategories) {
    catIdByCode.set(c.code, c.id);
    catLabelById.set(c.id, c.label);
  }

  const stockByCat = new Map<string, number>();
  for (const h of hardware) {
    if (h.status === 'in_stock' || h.status === 'being_reinstalled') {
      stockByCat.set(h.category_id, (stockByCat.get(h.category_id) ?? 0) + 1);
    }
  }

  const upcomingOnboardings = movements.filter(
    (m) =>
      m.type === 'onboarding' &&
      m.status !== 'done' &&
      m.status !== 'cancelled' &&
      new Date(m.effective_date) <= asOfDate,
  );

  const upcomingOffboardings = movements.filter(
    (m) =>
      m.type === 'offboarding' &&
      m.status !== 'done' &&
      m.status !== 'cancelled' &&
      new Date(m.effective_date) <= asOfDate,
  );

  const neededByCatCode = new Map<string, number>();
  for (const _ of upcomingOnboardings) {
    for (const code of TRACKED_FOR_ONBOARDING) {
      neededByCatCode.set(code, (neededByCatCode.get(code) ?? 0) + 1);
    }
  }

  const recoveredByCatCode = new Map<string, number>();
  for (const _ of upcomingOffboardings) {
    for (const code of TRACKED_FOR_ONBOARDING) {
      recoveredByCatCode.set(code, (recoveredByCatCode.get(code) ?? 0) + 1);
    }
  }

  for (const [code, needed] of neededByCatCode) {
    const catId = catIdByCode.get(code);
    if (!catId) continue;
    const available = stockByCat.get(catId) ?? 0;
    const recovered = recoveredByCatCode.get(code) ?? 0;
    const net = available + recovered - needed;
    const label = catLabelById.get(catId) ?? code;
    if (net < 0) {
      alerts.push({
        id: `hw-${code}`,
        severity: 'critical',
        message: `Manque ${Math.abs(net)} ${label} pour les arrivées à venir`,
        category: code,
        date: asOf,
      });
    } else if (net === 0) {
      alerts.push({
        id: `hw-${code}`,
        severity: 'warning',
        message: `Stock de ${label} juste pour les arrivées (0 marge)`,
        category: code,
        date: asOf,
      });
    } else if (net <= 1) {
      alerts.push({
        id: `hw-${code}`,
        severity: 'warning',
        message: `Stock de ${label} faible (${net} disponible après prévisions)`,
        category: code,
        date: asOf,
      });
    }
  }

  const licTypeByCode = new Map<string, LicenseType>();
  for (const lt of licenseTypes) licTypeByCode.set(lt.code, lt);

  const neededLicByCode = new Map<string, number>();
  for (const _ of upcomingOnboardings) {
    neededLicByCode.set('OFFICE365', (neededLicByCode.get('OFFICE365') ?? 0) + 1);
  }
  const recoveredLicByCode = new Map<string, number>();
  for (const _ of upcomingOffboardings) {
    recoveredLicByCode.set('OFFICE365', (recoveredLicByCode.get('OFFICE365') ?? 0) + 1);
  }

  for (const [code, needed] of neededLicByCode) {
    const lt = licTypeByCode.get(code);
    if (!lt) continue;
    const assignedCount = licenses.filter(
      (l) => l.license_type_id === lt.id && l.status === 'assigned',
    ).length;
    const available = Math.max(0, lt.total_seats - assignedCount);
    const recovered = recoveredLicByCode.get(code) ?? 0;
    const net = available + recovered - needed;
    if (net < 0) {
      alerts.push({
        id: `lic-${code}`,
        severity: 'critical',
        message: `Manque ${Math.abs(net)} licence(s) ${lt.label} pour les arrivées à venir`,
        category: code,
        date: asOf,
      });
    } else if (net === 0) {
      alerts.push({
        id: `lic-${code}`,
        severity: 'warning',
        message: `Licences ${lt.label} : 0 marge pour les arrivées`,
        category: code,
        date: asOf,
      });
    } else if (net <= 2) {
      alerts.push({
        id: `lic-${code}`,
        severity: 'warning',
        message: `Licences ${lt.label} : ${net} disponible(s) après prévisions`,
        category: code,
        date: asOf,
      });
    }
  }

  for (const lt of licenseTypes) {
    const assignedCount = licenses.filter(
      (l) => l.license_type_id === lt.id && l.status === 'assigned',
    ).length;
    const available = Math.max(0, lt.total_seats - assignedCount);
    if (available === 0 && !neededLicByCode.has(lt.code)) {
      alerts.push({
        id: `lic-${lt.code}-empty`,
        severity: 'warning',
        message: `Aucune licence ${lt.label} disponible (toutes attribuées)`,
        category: lt.code,
      });
    }
  }

  // Renewal alerts for licenses with expiration dates
  const today = new Date();
  for (const lic of licenses) {
    if (!lic.expiration_date) continue;
    const lt = licenseTypes.find((t) => t.id === lic.license_type_id);
    if (!lt) continue;
    const noticeDays = lic.renewal_notice_days ?? lt.default_renewal_notice_days;
    const expDate = new Date(lic.expiration_date);
    const daysLeft = Math.ceil((expDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
    if (daysLeft < 0) {
      alerts.push({
        id: `renew-${lic.id}`,
        severity: 'critical',
        message: `Licence ${lt.label} ${lic.seat_key ?? ''} expirée depuis ${Math.abs(daysLeft)} jour(s)`,
        category: lt.code,
        date: lic.expiration_date,
      });
    } else if (daysLeft <= noticeDays) {
      alerts.push({
        id: `renew-${lic.id}`,
        severity: daysLeft <= 7 ? 'critical' : 'warning',
        message: `Licence ${lt.label} ${lic.seat_key ?? ''} à renouveler dans ${daysLeft} jour(s) (échéance ${lic.expiration_date})`,
        category: lt.code,
        date: lic.expiration_date,
      });
    }
  }

  return alerts;
}

/**
 * Time-series stock projection: simulates stock evolution day by day from today
 * to asOf, applying onboardings (-1 per tracked category) and offboardings (+1 for PC
 * after reinstallation delay). Returns alerts when any category hits 0 at any date.
 */
export function computeStockTimeSeries(
  hardware: HardwareItem[],
  movements: Movement[],
  hardwareCategories: HardwareCategoryLite[],
  asOf: string,
): ForecastAlert[] {
  const alerts: ForecastAlert[] = [];
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const endDate = new Date(asOf);
  endDate.setHours(0, 0, 0, 0);
  if (endDate < today) return alerts;

  const catIdByCode = new Map<string, string>();
  const catLabelById = new Map<string, string>();
  for (const c of hardwareCategories) {
    catIdByCode.set(c.code, c.id);
    catLabelById.set(c.id, c.label);
  }

  // Initial stock per tracked category
  const stock = new Map<string, number>();
  for (const code of TRACKED_FOR_ONBOARDING) {
    const catId = catIdByCode.get(code);
    if (!catId) continue;
    const count = hardware.filter(
      (h) => h.category_id === catId && (h.status === 'in_stock' || h.status === 'being_reinstalled'),
    ).length;
    stock.set(code, count);
  }

  // Build events sorted by date
  type Event = { date: Date; delta: Map<string, number> };
  const events: Event[] = [];

  for (const m of movements) {
    if (m.status === 'done' || m.status === 'cancelled') continue;
    const d = new Date(m.effective_date);
    d.setHours(0, 0, 0, 0);
    if (d < today || d > endDate) continue;
    const delta = new Map<string, number>();
    if (m.type === 'onboarding') {
      for (const code of TRACKED_FOR_ONBOARDING) {
        delta.set(code, (delta.get(code) ?? 0) - 1);
      }
    } else {
      // Offboarding: PC goes to reinstallation, then back to stock after 3 days
      // For simplicity in the projection, PC +1 immediately (will be reinstalled)
      // Other items +1 immediately
      for (const code of TRACKED_FOR_ONBOARDING) {
        delta.set(code, (delta.get(code) ?? 0) + 1);
      }
    }
    events.push({ date: d, delta });
  }

  events.sort((a, b) => a.date.getTime() - b.date.getTime());

  // Simulate day by day
  const seenZero = new Set<string>();
  for (const ev of events) {
    for (const [code, d] of ev.delta) {
      const cur = stock.get(code) ?? 0;
      const next = cur + d;
      stock.set(code, next);
      if (next <= 0 && !seenZero.has(code)) {
        seenZero.add(code);
        const label = catLabelById.get(catIdByCode.get(code) ?? '') ?? code;
        const dateStr = ev.date.toISOString().slice(0, 10);
        alerts.push({
          id: `ts-${code}-${dateStr}`,
          severity: next < 0 ? 'critical' : 'warning',
          message: next < 0
            ? `Stock de ${label} négatif (${next}) le ${dateStr} — manque de matériel`
            : `Stock de ${label} à 0 le ${dateStr} — plus aucune marge`,
          category: code,
          date: dateStr,
        });
      }
    }
  }

  return alerts;
}
