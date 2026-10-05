import type {
  Employee,
  HardwareItem,
  License,
  LicenseType,
  Movement,
  MovementItem,
  MovementLicense,
  SubscribedSku,
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

// Licences libérées par chaque départ à venir, lues dans Microsoft 365
// (identifiant du mouvement -> types de licence de la personne).
export type OffboardingLicenses = Record<string, string[]>;

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

function findMicrosoftSku(licenseType: LicenseType, subscribedSkus: SubscribedSku[]) {
  // Les types de licence Microsoft ont pour code le SKU, stocké en display_name.
  return subscribedSkus.find((sku) => sku.display_name === licenseType.code);
}

// Même calcul que la page Licences : pour une licence Microsoft, le nombre
// utilisé est celui de Microsoft 365 (consumed_units) ; la table licenses
// ne contient pas les attributions Microsoft.
export function computeLicenseStock(
  licenses: License[],
  licenseTypes: LicenseType[],
  subscribedSkus: SubscribedSku[] = [],
): Map<string, LicenseStock> {
  const map = new Map<string, LicenseStock>();
  for (const lt of licenseTypes) {
    const seats = licenses.filter((l) => l.license_type_id === lt.id);
    const reserved = seats.filter((l) => l.status === 'reserved').length;
    const resiliated = seats.filter((l) => l.status === 'resiliated').length;
    const sku = findMicrosoftSku(lt, subscribedSkus);
    const total = sku ? sku.enabled_units ?? lt.total_seats : Math.max(lt.total_seats, seats.length);
    const assigned = sku ? sku.consumed_units ?? 0 : seats.filter((l) => l.status === 'assigned').length;
    map.set(lt.id, {
      licenseTypeId: lt.id,
      total,
      assigned,
      reserved,
      resiliated,
      available: Math.max(0, total - assigned),
    });
  }
  return map;
}

export type SupplyForecastInput = {
  hardware: HardwareItem[];
  licenses: License[];
  licenseTypes: LicenseType[];
  subscribedSkus: SubscribedSku[];
  movements: Movement[];
  movementItems: MovementItem[];
  movementLicenses: MovementLicense[];
  hardwareCategories: HardwareCategoryLite[];
  employees: Employee[];
  offboardingLicenses: OffboardingLicenses | null;
  asOf: string;
};

type Resource = { key: string; label: string; code?: string; level: number; kind: 'hw' | 'lic' };

/**
 * Projection chronologique du matériel et des licences :
 * stock disponible aujourd'hui, + ce que rendent les départs à leur date,
 * − ce que demandent les arrivées à leur date. Une alerte par ressource,
 * à la première date où le stock devient nul ou négatif.
 * Les mouvements en retard (date passée, non terminés) comptent dès aujourd'hui.
 */
export function computeSupplyForecast(input: SupplyForecastInput): ForecastAlert[] {
  const today = new Date().toISOString().slice(0, 10);
  const hardwareById = new Map(input.hardware.map((h) => [h.id, h]));
  const licenseById = new Map(input.licenses.map((l) => [l.id, l]));
  const categoryById = new Map(input.hardwareCategories.map((c) => [c.id, c]));
  const licenseTypeById = new Map(input.licenseTypes.map((lt) => [lt.id, lt]));
  const employeeById = new Map(input.employees.map((e) => [e.id, e]));
  const licenseStock = computeLicenseStock(input.licenses, input.licenseTypes, input.subscribedSkus);

  const resources = new Map<string, Resource>();
  const hwResource = (categoryId: string) => {
    const key = `hw-${categoryId}`;
    let resource = resources.get(key);
    if (!resource) {
      const category = categoryById.get(categoryId);
      const level = input.hardware.filter(
        (h) => h.category_id === categoryId && (h.status === 'in_stock' || h.status === 'being_reinstalled'),
      ).length;
      resource = { key, label: category?.label ?? 'matériel', code: category?.code, level, kind: 'hw' };
      resources.set(key, resource);
    }
    return resource;
  };
  const licResource = (licenseTypeId: string) => {
    const key = `lic-${licenseTypeId}`;
    let resource = resources.get(key);
    if (!resource) {
      const licenseType = licenseTypeById.get(licenseTypeId);
      resource = {
        key,
        label: licenseType ? `licence(s) ${licenseType.label}` : 'licence(s)',
        code: licenseType?.code,
        level: licenseStock.get(licenseTypeId)?.available ?? 0,
        kind: 'lic',
      };
      resources.set(key, resource);
    }
    return resource;
  };
  const isMicrosoft = (licenseTypeId: string) => {
    const licenseType = licenseTypeById.get(licenseTypeId);
    return Boolean(licenseType && findMicrosoftSku(licenseType, input.subscribedSkus));
  };

  const pending = input.movements
    .filter((m) => m.status !== 'done' && m.status !== 'cancelled' && m.effective_date <= input.asOf)
    .map((m) => ({ movement: m, date: m.effective_date < today ? today : m.effective_date }))
    // Le même jour, les départs passent avant les arrivées.
    .sort((a, b) => a.date.localeCompare(b.date) || (a.movement.type === 'offboarding' ? -1 : 1));

  const itemsByMovement = new Map<string, MovementItem[]>();
  for (const item of input.movementItems) {
    const list = itemsByMovement.get(item.movement_id) ?? [];
    list.push(item);
    itemsByMovement.set(item.movement_id, list);
  }
  const licensesByMovement = new Map<string, MovementLicense[]>();
  for (const item of input.movementLicenses) {
    const list = licensesByMovement.get(item.movement_id) ?? [];
    list.push(item);
    licensesByMovement.set(item.movement_id, list);
  }

  // worst < 0 : manque ; worst = 0 : plus aucune marge.
  type Shortfall = { date: string; worst: number; firstPerson: string };
  const shortfalls = new Map<string, Shortfall>();
  const onboardingsWithoutNeeds: string[] = [];

  for (const { movement, date } of pending) {
    const items = itemsByMovement.get(movement.id) ?? [];
    const movementLicenses = licensesByMovement.get(movement.id) ?? [];
    const employee = movement.employee_id ? employeeById.get(movement.employee_id) : undefined;
    const person = employee ? `${employee.first_name} ${employee.last_name}` : 'arrivée';

    if (movement.type === 'offboarding') {
      // Matériel rendu : celui encore attribué à la personne.
      for (const item of items) {
        const hardware = item.hardware_item_id ? hardwareById.get(item.hardware_item_id) : undefined;
        if (hardware?.status === 'assigned') hwResource(hardware.category_id).level += 1;
      }
      // Licences libérées : Microsoft 365 fait foi pour les licences Microsoft.
      const microsoftTypes = input.offboardingLicenses?.[movement.id];
      for (const item of movementLicenses) {
        if (!item.license_type_id) continue;
        if (microsoftTypes && isMicrosoft(item.license_type_id)) continue;
        licResource(item.license_type_id).level += 1;
      }
      for (const licenseTypeId of microsoftTypes ?? []) {
        if (licenseTypeById.has(licenseTypeId)) licResource(licenseTypeId).level += 1;
      }
      continue;
    }

    if (items.length === 0 && movementLicenses.length === 0) {
      onboardingsWithoutNeeds.push(person);
      continue;
    }

    const touched = new Set<Resource>();
    for (const item of items) {
      if (!item.category_id) continue;
      // Matériel déjà sorti du stock pour cette arrivée : rien à prévoir.
      const hardware = item.hardware_item_id ? hardwareById.get(item.hardware_item_id) : undefined;
      if (hardware && hardware.status !== 'in_stock' && hardware.status !== 'being_reinstalled') continue;
      const resource = hwResource(item.category_id);
      resource.level -= 1;
      touched.add(resource);
    }
    for (const item of movementLicenses) {
      if (!item.license_type_id) continue;
      // Une licence non Microsoft déjà attribuée ne compte plus comme besoin.
      const license = item.license_id ? licenseById.get(item.license_id) : undefined;
      if (!isMicrosoft(item.license_type_id) && license?.status === 'assigned') continue;
      const resource = licResource(item.license_type_id);
      resource.level -= 1;
      touched.add(resource);
    }

    for (const resource of touched) {
      const current = shortfalls.get(resource.key);
      if (resource.level < 0) {
        if (!current || current.worst >= 0) {
          shortfalls.set(resource.key, { date, worst: resource.level, firstPerson: person });
        } else {
          current.worst = Math.min(current.worst, resource.level);
        }
      } else if (resource.level === 0 && !current) {
        shortfalls.set(resource.key, { date, worst: 0, firstPerson: person });
      }
    }
  }

  const alerts: ForecastAlert[] = [];
  for (const [key, shortfall] of shortfalls) {
    const resource = resources.get(key);
    if (!resource) continue;
    if (shortfall.worst < 0) {
      alerts.push({
        id: `forecast-${key}`,
        severity: 'critical',
        message:
          `${formatForecastDate(shortfall.date)} : il manquera ${Math.abs(shortfall.worst)} ${resource.label}` +
          ` (dès l'arrivée de ${shortfall.firstPerson}), départs prévus d'ici là compris`,
        category: resource.code,
        date: shortfall.date,
      });
    } else {
      alerts.push({
        id: `forecast-${key}`,
        severity: 'warning',
        message:
          `${formatForecastDate(shortfall.date)} : plus aucun stock de ${resource.label} après l'arrivée de ${shortfall.firstPerson}` +
          ', départs prévus d\'ici là compris',
        category: resource.code,
        date: shortfall.date,
      });
    }
  }
  alerts.sort((a, b) => (a.severity === b.severity ? (a.date ?? '').localeCompare(b.date ?? '') : a.severity === 'critical' ? -1 : 1));

  if (onboardingsWithoutNeeds.length) {
    alerts.push({
      id: 'forecast-no-needs',
      severity: 'warning',
      message:
        `${onboardingsWithoutNeeds.length} arrivée(s) sans matériel ni licence renseignés, non prises en compte : ` +
        onboardingsWithoutNeeds.slice(0, 5).join(', ') +
        (onboardingsWithoutNeeds.length > 5 ? '…' : ''),
    });
  }

  return alerts;
}

// Licences arrivant à échéance (date d'expiration renseignée).
export function computeRenewalAlerts(licenses: License[], licenseTypes: LicenseType[]): ForecastAlert[] {
  const alerts: ForecastAlert[] = [];
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

function formatForecastDate(date: string) {
  const [year, month, day] = date.split('-');

  if (!year || !month || !day) {
    return date;
  }

  return `${day}/${month}/${year}`;
}
