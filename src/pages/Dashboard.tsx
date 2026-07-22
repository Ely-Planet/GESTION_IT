import { useMemo, useState } from 'react';
import {
  Laptop,
  Smartphone,
  Headphones,
  KeyRound,
  ArrowDownToLine,
  ArrowUpFromLine,
  AlertTriangle,
  ShieldAlert,
  CalendarClock,
  TrendingUp,
  Settings2,
  X,
  CheckCircle2,
  Clock,
  RefreshCw,
  GripVertical,
} from 'lucide-react';
import { useData } from '../hooks/useData';
import { useAuth } from '../context/AuthContext';
import { logAudit } from '../lib/audit';
import {
  computeForecast,
  computeOnboardingNeedsForecast,
  computeLicenseStock,
  computeStockByCategory,
  type ForecastAlert,
} from '../lib/forecast';


import { formatFrDate, statusLabel, MOVEMENT_STATUS } from '../lib/format';

const ALL_WIDGETS: { key: string; label: string; defaultVisible: boolean }[] = [
  { key: 'pc_stock', label: 'Stock PC / Téléphones / Casques', defaultVisible: true },
  { key: 'upcoming_onboardings', label: 'Arrivées à venir', defaultVisible: true },
  { key: 'upcoming_offboardings', label: 'Départs à venir', defaultVisible: true },
  { key: 'active_alerts', label: 'Alertes prévisionnelles', defaultVisible: true },
  { key: 'renewal_alerts', label: 'Renouvellements de licences', defaultVisible: true },
  { key: 'license_summary', label: 'Licences', defaultVisible: true },
  { key: 'peripheral_matrix', label: 'Périphériques par service', defaultVisible: true },
  { key: 'upcoming_movements', label: 'Prochains mouvements', defaultVisible: true },
  { key: 'action_reminders', label: "Rappels d'actions", defaultVisible: true },
];

type Widget = { key: string; label: string; visible: boolean; sort_order: number };

export default function Dashboard() {
  const data = useData();
  const { profile, user } = useAuth();
  const [asOf, setAsOf] = useState(() => new Date().toISOString().slice(0, 10));
  const [showSettings, setShowSettings] = useState(false);
  const [dragKey, setDragKey] = useState<string | null>(null);

  const widgets = useMemo<Widget[]>(() => {
    if (data.widgets.length === 0) {
      return ALL_WIDGETS.map((w, i) => ({ key: w.key, label: w.label, visible: w.defaultVisible, sort_order: i + 1 }));
    }
    const known = new Map(data.widgets.map((w) => [w.widget_key, w]));
    return ALL_WIDGETS.map((w, i) => {
      const saved = known.get(w.key);
      return saved
        ? { key: saved.widget_key, label: saved.label, visible: saved.visible, sort_order: saved.sort_order }
        : { key: w.key, label: w.label, visible: w.defaultVisible, sort_order: i + 1 };
    }).sort((a, b) => a.sort_order - b.sort_order);
  }, [data.widgets]);

  const visibleWidgets = widgets.filter((w) => w.visible);

  const stockByCat = useMemo(() => computeStockByCategory(data.hardware), [data.hardware]);
  const licStock = useMemo(
    () => computeLicenseStock(data.licenses, data.licenseTypes),
    [data.licenses, data.licenseTypes],
  );

const alerts = useMemo<ForecastAlert[]>(() => {
  const legacyAlerts = computeForecast(
    data.hardware,
    data.licenses,
    data.licenseTypes,
    data.movements,
    data.hardwareCategories,
    asOf,
  );

  const onboardingAlerts = computeOnboardingNeedsForecast(
    data.hardware,
    data.licenses,
    data.licenseTypes,
    data.movements,
    data.movementItems,
    data.movementLicenses,
    data.hardwareCategories,
    asOf,
  );

  return [
    ...legacyAlerts,
    ...onboardingAlerts,
  ];
}, [data, asOf]);

  const renewalAlerts = alerts.filter((a) => a.id.startsWith('renew-'));
  const forecastAlerts = alerts.filter((a) => !a.id.startsWith('renew-'));

  const trackedCats = data.hardwareCategories.filter((c) => c.tracked_for_person);
  const serviceCats = data.hardwareCategories.filter((c) => !c.tracked_for_person);

  const upcomingOnboardings = data.movements
    .filter((m) => m.type === 'onboarding' && m.status !== 'done' && m.status !== 'cancelled')
    .sort((a, b) => a.effective_date.localeCompare(b.effective_date));

  const upcomingOffboardings = data.movements
    .filter((m) => m.type === 'offboarding' && m.status !== 'done' && m.status !== 'cancelled')
    .sort((a, b) => a.effective_date.localeCompare(b.effective_date));

  const upcomingMovements = [...upcomingOnboardings, ...upcomingOffboardings]
    .sort((a, b) => a.effective_date.localeCompare(b.effective_date))
    .slice(0, 8);

  const stockFor = (code: string) => {
    const cat = data.hardwareCategories.find((c) => c.code === code);
    if (!cat) return 0;
    return stockByCat.get(cat.id)?.available ?? 0;
  };

  const actionReminders = useMemo(() => {
    const today = new Date().toISOString().slice(0, 10);
    return data.movementActions
      .filter((a) => !a.done_at && a.due_date && a.due_date <= today)
      .map((a) => {
        const mov = data.movements.find((m) => m.id === a.movement_id);
        const emp = data.employees.find((e) => e.id === mov?.employee_id);
        return { action: a, movement: mov, employee: emp };
      })
      .sort((a, b) => (a.action.due_date ?? '').localeCompare(b.action.due_date ?? ''))
      .slice(0, 12);
  }, [data.movementActions, data.movements, data.employees]);

async function toggleWidget(key: string, visible: boolean) {
  if (!user) return;

  const existing = data.widgets.find((w) => w.widget_key === key);

  if (existing) {
    const res = await fetch(`/api/dashboard-widgets/${existing.id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ visible }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: 'Erreur mise à jour widget' }));
      alert(err.error ?? 'Erreur mise à jour widget');
      return;
    }
  } else {
    const def = ALL_WIDGETS.find((w) => w.key === key);

    const res = await fetch('/api/dashboard-widgets', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        user_id: user.id,
        widget_key: key,
        label: def?.label ?? key,
        visible,
        sort_order: ALL_WIDGETS.findIndex((w) => w.key === key) + 1,
      }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: 'Erreur création widget' }));
      alert(err.error ?? 'Erreur création widget');
      return;
    }
  }

  await logAudit('update', 'dashboard_widget', null, { key, visible }, profile?.display_name).catch(console.error);

  data.reload();
}


async function saveOrder(orderedKeys: string[]) {
  if (!user) return;

  for (let i = 0; i < orderedKeys.length; i++) {
    const key = orderedKeys[i];
    const existing = data.widgets.find((w) => w.widget_key === key);
    const def = ALL_WIDGETS.find((w) => w.key === key);

    if (existing) {
      const res = await fetch(`/api/dashboard-widgets/${existing.id}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          sort_order: i + 1,
        }),
      });

      if (!res.ok) {
        const err = await res.json().catch(() => ({ error: 'Erreur mise à jour ordre widget' }));
        alert(err.error ?? 'Erreur mise à jour ordre widget');
        return;
      }
    } else {
      const res = await fetch('/api/dashboard-widgets', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_id: user.id,
          widget_key: key,
          label: def?.label ?? key,
          visible: true,
          sort_order: i + 1,
        }),
      });

      if (!res.ok) {
        const err = await res.json().catch(() => ({ error: 'Erreur création widget' }));
        alert(err.error ?? 'Erreur création widget');
        return;
      }
    }
  }

  await logAudit(
    'update',
    'dashboard_widgets',
    null,
    { orderedKeys },
    profile?.display_name
  ).catch(console.error);

  data.reload();
}




  function onDragStart(key: string) {
    setDragKey(key);
  }

  function onDropOnto(targetKey: string) {
    if (!dragKey || dragKey === targetKey) { setDragKey(null); return; }
    const ordered = widgets.map((w) => w.key);
    const fromIdx = ordered.indexOf(dragKey);
    const toIdx = ordered.indexOf(targetKey);
    ordered.splice(toIdx, 0, ordered.splice(fromIdx, 1)[0]);
    setDragKey(null);
    saveOrder(ordered);
  }

  return (
    <div className="p-6 lg:p-8 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8">
        <div>
          <h1 className="text-2xl font-bold text-ink-900">Tableau de bord</h1>
          <p className="text-sm text-ink-500 mt-1">
            Vue d'ensemble du parc IT et anticipation des besoins — glissez les indicateurs pour réordonner
          </p>
        </div>
        <div className="flex items-center gap-2">
          <label htmlFor="asof" className="text-sm font-medium text-ink-700 flex items-center gap-1.5">
            <CalendarClock className="w-4 h-4 text-elyade-600" />
            Prévision au
          </label>
          <input id="asof" type="date" className="input w-auto" value={asOf} onChange={(e) => setAsOf(e.target.value)} />
          <button onClick={() => setShowSettings(true)} className="btn-secondary" title="Configurer les indicateurs">
            <Settings2 className="w-4 h-4" />
            Indicateurs
          </button>
        </div>
      </div>

      <div className="space-y-6">
        {visibleWidgets.map((w) => {
          const dragProps = {
            draggable: true,
            onDragStart: () => onDragStart(w.key),
            onDragOver: (e: React.DragEvent) => e.preventDefault(),
            onDrop: () => onDropOnto(w.key),
          };
          switch (w.key) {
            case 'pc_stock':
              return (
                <div key={w.key} {...dragProps} className={`group ${dragKey === w.key ? 'opacity-40' : ''}`}>
                  <div className="flex items-center gap-2 mb-3 cursor-grab">
                    <GripVertical className="w-4 h-4 text-ink-300 group-hover:text-ink-400" />
                    <h2 className="text-sm font-semibold text-ink-500 uppercase tracking-wide">Stock matériel</h2>
                  </div>
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                    <KpiCard icon={Laptop} label="PC en stock" value={stockFor('PC')} hint="disponibles" tone="elyade" />
                    <KpiCard icon={Smartphone} label="Téléphones en stock" value={stockFor('PHONE')} hint="disponibles" tone="green" />
                    <KpiCard icon={Headphones} label="Casques en stock" value={stockFor('HEADSET')} hint="disponibles" tone="amber" />
                    <KpiCard icon={AlertTriangle} label="Alertes actives" value={alerts.length} hint={`${alerts.filter((a) => a.severity === 'critical').length} critiques`} tone={alerts.some((a) => a.severity === 'critical') ? 'red' : 'ink'} />
                  </div>
                </div>
              );
            case 'upcoming_onboardings':
              return (
                <div key={w.key} {...dragProps} className={`group ${dragKey === w.key ? 'opacity-40' : ''}`}>
                  <MovementList title="Arrivées à venir" icon={ArrowDownToLine} tone="green" movements={upcomingOnboardings.slice(0, 8)} data={data} />
                </div>
              );
            case 'upcoming_offboardings':
              return (
                <div key={w.key} {...dragProps} className={`group ${dragKey === w.key ? 'opacity-40' : ''}`}>
                  <MovementList title="Départs à venir" icon={ArrowUpFromLine} tone="amber" movements={upcomingOffboardings.slice(0, 8)} data={data} />
                </div>
              );
            case 'active_alerts':
              return (
                <div key={w.key} {...dragProps} className={`group ${dragKey === w.key ? 'opacity-40' : ''}`}>
                  <h2 className="text-lg font-semibold text-ink-900 mb-3 flex items-center gap-2">
                    <ShieldAlert className="w-5 h-5 text-elyade-600" />
                    Alertes prévisionnelles
                  </h2>
                  {forecastAlerts.length === 0 ? (
                    <div className="card p-6 text-center">
                      <TrendingUp className="w-8 h-8 text-green-500 mx-auto mb-2" />
                      <p className="text-sm text-ink-600">Aucune alerte — le matériel et les licences couvrent les besoins au {formatFrDate(asOf)}.</p>
                    </div>
                  ) : (
                    <div className="space-y-2">
                      {forecastAlerts.map((a) => <AlertRow key={a.id} alert={a} />)}
                    </div>
                  )}
                </div>
              );
            case 'renewal_alerts':
              return (
                <div key={w.key} {...dragProps} className={`group ${dragKey === w.key ? 'opacity-40' : ''}`}>
                  <h2 className="text-lg font-semibold text-ink-900 mb-3 flex items-center gap-2">
                    <RefreshCw className="w-5 h-5 text-elyade-600" />
                    Renouvellements de licences
                  </h2>
                  {renewalAlerts.length === 0 ? (
                    <div className="card p-6 text-center">
                      <CheckCircle2 className="w-8 h-8 text-green-500 mx-auto mb-2" />
                      <p className="text-sm text-ink-600">Aucun renouvellement imminent.</p>
                    </div>
                  ) : (
                    <div className="space-y-2">
                      {renewalAlerts.map((a) => <AlertRow key={a.id} alert={a} />)}
                    </div>
                  )}
                </div>
              );
            case 'license_summary':
              return (
                <div key={w.key} {...dragProps} className={`group ${dragKey === w.key ? 'opacity-40' : ''}`}>
                  <section className="card p-5">
                    <h2 className="text-base font-semibold text-ink-900 mb-4 flex items-center gap-2">
                      <KeyRound className="w-4.5 h-4.5 text-elyade-600" />
                      Licences
                    </h2>
                    <div className="space-y-2">
                      {data.licenseTypes.map((lt) => {
                        const s = licStock.get(lt.id);
                        return (
                          <div key={lt.id} className="flex items-center justify-between py-2 border-b border-ink-100 last:border-0">
                            <span className="text-sm text-ink-700">{lt.label}</span>
                            <div className="flex items-center gap-3 text-xs">
                              <StockPill label="Total" value={s?.total ?? 0} />
                              <StockPill label="Attribuées" value={s?.assigned ?? 0} tone="elyade" />
                              <StockPill label="Dispo." value={s?.available ?? 0} tone={s?.available === 0 ? 'red' : 'green'} />
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </section>
                </div>
              );
            case 'peripheral_matrix':
              return (
                <div key={w.key} {...dragProps} className={`group ${dragKey === w.key ? 'opacity-40' : ''}`}>
                  <section className="card p-5">
                    <h2 className="text-base font-semibold text-ink-900 mb-4">Périphériques attribués aux services</h2>
                    <div className="overflow-x-auto">
                      <table className="table-base">
                        <thead>
                          <tr>
                            <th>Service</th>
                            {serviceCats.map((c) => <th key={c.id} className="text-center">{c.label}</th>)}
                          </tr>
                        </thead>
                        <tbody>
                          {data.services.map((svc) => (
                            <tr key={svc.id}>
                              <td className="font-medium">{svc.name}</td>
                              {serviceCats.map((c) => {
                                const qty = data.servicePeripherals.find((p) => p.service_id === svc.id && p.category_id === c.id)?.quantity ?? 0;
                                return (
                                  <td key={c.id} className="text-center">
                                    <span className={`badge ${qty > 0 ? 'bg-elyade-50 text-elyade-700' : 'bg-ink-100 text-ink-500'}`}>{qty}</span>
                                  </td>
                                );
                              })}
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </section>
                </div>
              );
            case 'upcoming_movements':
              return (
                <div key={w.key} {...dragProps} className={`group ${dragKey === w.key ? 'opacity-40' : ''}`}>
                  <section className="card p-5">
                    <h2 className="text-base font-semibold text-ink-900 mb-4">Prochains mouvements</h2>
                    {upcomingMovements.length === 0 ? (
                      <p className="text-sm text-ink-500 py-4 text-center">Aucun mouvement à venir.</p>
                    ) : (
                      <div className="space-y-2">
                        {upcomingMovements.map((m) => {
                          const emp = data.employees.find((e) => e.id === m.employee_id);
                          const svc = data.services.find((s) => s.id === m.service_id);
                          return (
                            <div key={m.id} className="flex items-center gap-3 py-2 border-b border-ink-100 last:border-0">
                              <div className={`w-2 h-2 rounded-full ${m.type === 'onboarding' ? 'bg-green-500' : 'bg-amber-500'}`} />
                              <div className="flex-1 min-w-0">
                                <p className="text-sm font-medium text-ink-900 truncate">
                                  {emp ? `${emp.first_name} ${emp.last_name}` : '—'} · {svc?.name ?? '—'}
                                </p>
                                <p className="text-xs text-ink-500">
                                  {m.type === 'onboarding' ? 'Arrivée' : 'Départ'} · {formatFrDate(m.effective_date)} · {statusLabel(m.status, MOVEMENT_STATUS)}
                                </p>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    )}
                  </section>
                </div>
              );
            case 'action_reminders':
              return (
                <div key={w.key} {...dragProps} className={`group ${dragKey === w.key ? 'opacity-40' : ''}`}>
                  <section className="card p-5">
                    <h2 className="text-base font-semibold text-ink-900 mb-4 flex items-center gap-2">
                      <Clock className="w-4.5 h-4.5 text-elyade-600" />
                      Rappels d'actions
                    </h2>
                    {actionReminders.length === 0 ? (
                      <p className="text-sm text-ink-500 py-4 text-center">Aucune action en retard.</p>
                    ) : (
                      <div className="space-y-2">
                        {actionReminders.map(({ action, movement, employee }) => {
                          const overdue = action.due_date && action.due_date < new Date().toISOString().slice(0, 10);
                          return (
                            <div key={action.id} className="flex items-center gap-3 py-2 border-b border-ink-100 last:border-0">
                              <Clock className={`w-4 h-4 shrink-0 ${overdue ? 'text-red-500' : 'text-amber-500'}`} />
                              <div className="flex-1 min-w-0">
                                <p className="text-sm font-medium text-ink-900 truncate">{action.label}</p>
                                <p className="text-xs text-ink-500">
                                  {employee ? `${employee.first_name} ${employee.last_name}` : '—'} · échéance {formatFrDate(action.due_date)}
                                  {overdue && <span className="text-red-600 ml-1">· en retard</span>}
                                </p>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    )}
                  </section>
                </div>
              );
            default:
              return null;
          }
        })}
      </div>

      {showSettings && (
        <WidgetSettings widgets={widgets} onToggle={toggleWidget} onClose={() => setShowSettings(false)} />
      )}
    </div>
  );
}

function KpiCard({
  icon: Icon, label, value, hint, tone,
}: {
  icon: typeof Laptop; label: string; value: number; hint: string;
  tone: 'elyade' | 'green' | 'amber' | 'red' | 'ink';
}) {
  const tones: Record<string, string> = {
    elyade: 'bg-elyade-50 text-elyade-700',
    green: 'bg-green-50 text-green-700',
    amber: 'bg-amber-50 text-amber-700',
    red: 'bg-red-50 text-red-700',
    ink: 'bg-ink-100 text-ink-700',
  };
  return (
    <div className="card p-5">
      <span className={`w-10 h-10 rounded-lg flex items-center justify-center ${tones[tone]}`}>
        <Icon className="w-5 h-5" />
      </span>
      <p className="text-3xl font-bold text-ink-900 mt-3">{value}</p>
      <p className="text-sm font-medium text-ink-700 mt-1">{label}</p>
      <p className="text-xs text-ink-400 mt-0.5">{hint}</p>
    </div>
  );
}

function StockPill({ label, value, tone = 'default' }: { label: string; value: number; tone?: 'default' | 'elyade' | 'green' | 'red' | 'muted' }) {
  const tones: Record<string, string> = {
    default: 'bg-ink-100 text-ink-700',
    elyade: 'bg-elyade-50 text-elyade-700',
    green: 'bg-green-50 text-green-700',
    red: 'bg-red-50 text-red-700',
    muted: 'bg-ink-50 text-ink-400',
  };
  return <span className={`badge ${tones[tone]}`}>{label}: {value}</span>;
}

function AlertRow({ alert }: { alert: ForecastAlert }) {
  return (
    <div className={`card p-4 flex items-start gap-3 border-l-4 ${alert.severity === 'critical' ? 'border-l-red-500 bg-red-50/40' : 'border-l-amber-400 bg-amber-50/40'}`}>
      <AlertTriangle className={`w-5 h-5 mt-0.5 shrink-0 ${alert.severity === 'critical' ? 'text-red-500' : 'text-amber-500'}`} />
      <div>
        <p className="text-sm font-medium text-ink-900">{alert.message}</p>
        {alert.date && <p className="text-xs text-ink-500 mt-0.5">Prévision calculée au {formatFrDate(alert.date)}</p>}
      </div>
    </div>
  );
}

function MovementList({
  title, icon: Icon, tone, movements, data,
}: {
  title: string;
  icon: typeof ArrowDownToLine;
  tone: 'green' | 'amber';
  movements: import('../lib/supabase').Movement[];
  data: ReturnType<typeof useData>;
}) {
  return (
    <section className="card p-5">
      <h2 className="text-base font-semibold text-ink-900 mb-4 flex items-center gap-2">
        <Icon className={`w-4.5 h-4.5 ${tone === 'green' ? 'text-green-600' : 'text-amber-600'}`} />
        {title}
      </h2>
      {movements.length === 0 ? (
        <p className="text-sm text-ink-500 py-4 text-center">Aucun mouvement.</p>
      ) : (
        <div className="space-y-2">
          {movements.map((m) => {
            const emp = data.employees.find((e) => e.id === m.employee_id);
            const svc = data.services.find((s) => s.id === m.service_id);
            const ct = data.contractTypes.find((c) => c.id === m.contract_type_id);
            const actions = data.movementActions.filter((a) => a.movement_id === m.id);
            const done = actions.filter((a) => a.done_at).length;
            return (
              <div key={m.id} className="flex items-center gap-3 py-2 border-b border-ink-100 last:border-0">
                <div className={`w-2 h-2 rounded-full ${tone === 'green' ? 'bg-green-500' : 'bg-amber-500'}`} />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-ink-900 truncate">
                    {emp ? `${emp.first_name} ${emp.last_name}` : '—'}
                    {m.job_title && <span className="text-xs text-ink-400 ml-1">· {m.job_title}</span>}
                  </p>
                  <p className="text-xs text-ink-500">
                    {svc?.name ?? '—'}{ct ? ` · ${ct.label}` : ''} · {formatFrDate(m.effective_date)} · {statusLabel(m.status, MOVEMENT_STATUS)}
                  </p>
                </div>
                {actions.length > 0 && (
                  <span className="badge bg-ink-100 text-ink-600 shrink-0">{done}/{actions.length}</span>
                )}
              </div>
            );
          })}
        </div>
      )}
    </section>
  );
}

function WidgetSettings({
  widgets, onToggle, onClose,
}: {
  widgets: Widget[];
  onToggle: (key: string, visible: boolean) => void;
  onClose: () => void;
}) {
  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center z-50 p-4" onClick={onClose}>
      <div className="card w-full max-w-lg max-h-[80vh] overflow-auto" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-5 py-4 border-b border-ink-100 sticky top-0 bg-white rounded-t-xl">
          <h2 className="text-lg font-semibold text-ink-900 flex items-center gap-2">
            <Settings2 className="w-5 h-5 text-elyade-600" /> Configurer les indicateurs
          </h2>
          <button onClick={onClose} className="btn-ghost p-1.5"><X className="w-5 h-5" /></button>
        </div>
        <div className="p-5 space-y-2">
          {widgets.map((w) => (
            <label key={w.key} className="flex items-center justify-between p-3 rounded-lg hover:bg-ink-50 cursor-pointer">
              <span className="text-sm font-medium text-ink-800">{w.label}</span>
              <button
                onClick={() => onToggle(w.key, !w.visible)}
                className={`relative w-10 h-5 rounded-full transition ${w.visible ? 'bg-elyade-600' : 'bg-ink-200'}`}
              >
                <span className={`absolute top-0.5 w-4 h-4 bg-white rounded-full transition ${w.visible ? 'left-5' : 'left-0.5'}`} />
              </button>
            </label>
          ))}
        </div>
        <div className="px-5 py-3 border-t border-ink-100 text-xs text-ink-500">
          Glissez-déposez les indicateurs sur le tableau de bord pour les réordonner.
        </div>
      </div>
    </div>
  );
}
