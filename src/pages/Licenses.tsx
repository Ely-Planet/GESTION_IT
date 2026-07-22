import { useMemo, useState, type FormEvent } from 'react';
import {
  KeyRound,
  Plus,
  X,
  Trash2,
  UserPlus,
  UserMinus,
  ShoppingCart,
  Ban,
  RefreshCw,
  CalendarClock,
  AlertTriangle,
} from 'lucide-react';
import { useData } from '../hooks/useData';

import { logAudit } from '../lib/audit';
import { useAuth } from '../context/AuthContext';
import { LICENSE_STATUS, statusLabel, formatFrDate } from '../lib/format';
import type { License, LicenseType } from '../lib/supabase';

export default function Licenses() {
  const data = useData();
  const { profile } = useAuth();
  const [showTypeForm, setShowTypeForm] = useState(false);
  const [showSeatForm, setShowSeatForm] = useState(false);
  const [syncing, setSyncing] = useState(false);

  const grouped = useMemo(() => {
    const map = new Map<string, { type: LicenseType; seats: License[] }>();
    for (const lt of data.licenseTypes) map.set(lt.id, { type: lt, seats: [] });
    for (const l of data.licenses) {
      const g = map.get(l.license_type_id);
      if (g) g.seats.push(l);
    }
    return Array.from(map.values());
  }, [data.licenseTypes, data.licenses]);

async function setTotalSeats(lt: LicenseType, total: number) {
  const res = await fetch(`/api/license-types/${lt.id}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ total_seats: total }),
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: 'Erreur mise à jour du total' }));
    alert(err.error ?? 'Erreur mise à jour du total');
    return;
  }

  await logAudit(
    'update',
    'license_type',
    lt.id,
    { total_seats: total, from: lt.total_seats },
    profile?.display_name
  ).catch(console.error);

  data.reload();
}


async function assignSeat(lic: License, employeeId: string) {
  const res = await fetch(`/api/licenses/${lic.id}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      status: 'assigned',
      assigned_employee_id: employeeId,
      assigned_at: new Date().toISOString().slice(0, 10),
    }),
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: 'Erreur attribution licence' }));
    alert(err.error ?? 'Erreur attribution licence');
    return;
  }

  await logAudit(
    'assign',
    'license',
    lic.id,
    { employee_id: employeeId },
    profile?.display_name
  ).catch(console.error);

  data.reload();
}


async function releaseSeat(lic: License) {
  const res = await fetch(`/api/licenses/${lic.id}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      status: 'available',
      assigned_employee_id: null,
      assigned_at: null,
    }),
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: 'Erreur libération licence' }));
    alert(err.error ?? 'Erreur libération licence');
    return;
  }

  await logAudit(
    'release',
    'license',
    lic.id,
    {},
    profile?.display_name
  ).catch(console.error);

  data.reload();
}


async function resiliateSeat(lic: License) {
  if (!confirm('Résilier cette licence ?')) return;

  const res = await fetch(`/api/licenses/${lic.id}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      status: 'resiliated',
      assigned_employee_id: null,
      assigned_at: null,
    }),
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: 'Erreur résiliation licence' }));
    alert(err.error ?? 'Erreur résiliation licence');
    return;
  }

  await logAudit(
    'resiliate',
    'license',
    lic.id,
    {},
    profile?.display_name
  ).catch(console.error);

  data.reload();
}


async function deleteSeat(lic: License) {
  if (!confirm('Supprimer ce siège de licence ?')) return;

  const res = await fetch(`/api/licenses/${lic.id}`, {
    method: 'DELETE',
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: 'Erreur suppression licence' }));
    alert(err.error ?? 'Erreur suppression licence');
    return;
  }

  await logAudit(
    'delete',
    'license',
    lic.id,
    { seat_key: lic.seat_key },
    profile?.display_name
  ).catch(console.error);

  data.reload();
}



  async function syncMicrosoft() {
    setSyncing(true);
    try {


const res = await fetch('/api/sync-microsoft-licenses', {
  method: 'POST',
});


      const json = await res.json();
      if (!res.ok) {
        alert(`Erreur de synchronisation: ${json.error ?? res.status}`);
      } else {
        await logAudit('sync', 'subscribed_skus', null, { count: json.synced }, profile?.display_name);
        data.reload();
      }
    } catch (e) {
      alert(e instanceof Error ? e.message : 'Erreur');
    } finally {
      setSyncing(false);
    }
  }

  const today = new Date().toISOString().slice(0, 10);

  return (
    <div className="p-6 lg:p-8 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <h1 className="text-2xl font-bold text-ink-900">Licences</h1>
          <p className="text-sm text-ink-500 mt-1">Seiitra, Office 365, et autres abonnements — avec renouvellements</p>
        </div>
        <div className="flex gap-2">
          <button onClick={syncMicrosoft} className="btn-secondary" disabled={syncing}>
            <RefreshCw className={`w-4 h-4 ${syncing ? 'animate-spin' : ''}`} />
            {syncing ? 'Sync…' : 'Sync Microsoft'}
          </button>
          <button onClick={() => setShowTypeForm(true)} className="btn-secondary">
            <Plus className="w-4 h-4" /> Type
          </button>
          <button onClick={() => setShowSeatForm(true)} className="btn-primary">
            <ShoppingCart className="w-4 h-4" /> Sièges
          </button>
        </div>
      </div>







      <div className="space-y-6">
        {grouped.length === 0 && !data.loading && (
          <div className="card p-8 text-center text-ink-500">Aucun type de licence. Créez-en un pour commencer.</div>
        )}
        {grouped.map(({ type, seats }) => {
          const assigned = seats.filter((s) => s.status === 'assigned').length;
          const available = Math.max(0, type.total_seats - assigned);
          const pct = type.total_seats > 0 ? Math.round((assigned / type.total_seats) * 100) : 0;
          const expiringSoon = seats.filter((s) => {
            if (!s.expiration_date) return false;
            const notice = s.renewal_notice_days ?? type.default_renewal_notice_days;
            const daysLeft = Math.ceil((new Date(s.expiration_date).getTime() - new Date(today).getTime()) / 86400000);
            return daysLeft <= notice;
          });
          return (
            <section key={type.id} className="card p-5">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-4">
                <div className="flex items-center gap-3">
                  <span className="w-10 h-10 rounded-lg bg-elyade-50 text-elyade-700 flex items-center justify-center">
                    <KeyRound className="w-5 h-5" />
                  </span>
                  <div>
                    <h2 className="text-base font-semibold text-ink-900">{type.label}</h2>
                    <p className="text-xs text-ink-500">
                      {type.code}
                      {type.has_expiration && ` · expiration activée · préavis ${type.default_renewal_notice_days}j`}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <div className="text-right">
                    <p className="text-sm font-semibold text-ink-900">{assigned}/{type.total_seats} attribuées</p>
                    <p className={`text-xs ${available === 0 ? 'text-red-600' : 'text-ink-500'}`}>{available} disponible(s)</p>
                  </div>
                  <div className="w-32 h-2 bg-ink-100 rounded-full overflow-hidden">
                    <div className={`h-full ${pct >= 90 ? 'bg-red-500' : pct >= 70 ? 'bg-amber-500' : 'bg-elyade-500'}`} style={{ width: `${pct}%` }} />
                  </div>
                  <SeatCountEditor type={type} current={type.total_seats} onSave={setTotalSeats} />
                </div>
              </div>

              {expiringSoon.length > 0 && (
                <div className="mb-3 p-3 rounded-lg bg-amber-50 border border-amber-200 flex items-start gap-2">
                  <AlertTriangle className="w-4 h-4 text-amber-600 mt-0.5 shrink-0" />
                  <p className="text-xs text-amber-800">
                    {expiringSoon.length} licence(s) à renouveler prochainement. Voir les dates d'expiration ci-dessous.
                  </p>
                </div>
              )}

              {seats.length === 0 ? (
                <p className="text-sm text-ink-400 py-3">Aucun siège enregistré. Ajustez le total ou ajoutez des sièges.</p>
              ) : (
                <div className="overflow-x-auto">
                  <table className="table-base">
                    <thead>
                      <tr>
                        <th>Clé / Siège</th>
                        <th>Statut</th>
                        <th>Attribuée à</th>
                        <th>Depuis</th>
                        <th>Expiration</th>
                        <th className="text-right">Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {seats.map((s) => {
                        const emp = data.employees.find((e) => e.id === s.assigned_employee_id);
                        const lt = type;
                        const notice = s.renewal_notice_days ?? lt.default_renewal_notice_days;
                        const daysLeft = s.expiration_date ? Math.ceil((new Date(s.expiration_date).getTime() - new Date(today).getTime()) / 86400000) : null;
                        const expired = daysLeft !== null && daysLeft < 0;
                        const expiringSoon = daysLeft !== null && daysLeft >= 0 && daysLeft <= notice;
                        return (
                          <tr key={s.id}>
                            <td className="font-mono text-xs">{s.seat_key ?? '—'}</td>
                            <td><LicStatusBadge status={s.status} /></td>
                            <td>{emp ? `${emp.first_name} ${emp.last_name}` : '—'}</td>
                            <td>{formatFrDate(s.assigned_at)}</td>
                            <td>
                              {s.expiration_date ? (
                                <span className={`badge ${expired ? 'bg-red-50 text-red-700' : expiringSoon ? 'bg-amber-50 text-amber-700' : 'bg-ink-100 text-ink-600'}`}>
                                  <CalendarClock className="w-3 h-3" />
                                  {formatFrDate(s.expiration_date)}
                                  {daysLeft !== null && ` · ${daysLeft < 0 ? `expirée` : `${daysLeft}j`}`}
                                </span>
                              ) : '—'}
                            </td>
                            <td>
                              <div className="flex justify-end gap-1">
                                {s.status === 'available' && (
                                  <AssignPicker license={s} employees={data.employees} onAssign={assignSeat} />
                                )}
                                {s.status === 'assigned' && (
                                  <button title="Libérer" onClick={() => releaseSeat(s)} className="btn-ghost p-1.5 text-amber-600">
                                    <UserMinus className="w-4 h-4" />
                                  </button>
                                )}
                                {s.status !== 'resiliated' && (
                                  <button title="Résilier" onClick={() => resiliateSeat(s)} className="btn-ghost p-1.5 text-red-500">
                                    <Ban className="w-4 h-4" />
                                  </button>
                                )}
                                <button title="Supprimer" onClick={() => deleteSeat(s)} className="btn-ghost p-1.5 text-ink-400">
                                  <Trash2 className="w-4 h-4" />
                                </button>
                              </div>
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              )}
            </section>
          );
        })}
      </div>

      {showTypeForm && (
        <LicenseTypeForm onClose={() => setShowTypeForm(false)} onSaved={() => { setShowTypeForm(false); data.reload(); }} />
      )}
      {showSeatForm && (
        <SeatForm types={data.licenseTypes} onClose={() => setShowSeatForm(false)} onSaved={() => { setShowSeatForm(false); data.reload(); }} />
      )}
    </div>
  );
}

function LicStatusBadge({ status }: { status: string }) {
  const tones: Record<string, string> = {
    available: 'bg-green-50 text-green-700',
    assigned: 'bg-elyade-50 text-elyade-700',
    reserved: 'bg-amber-50 text-amber-700',
    resiliated: 'bg-ink-100 text-ink-500',
  };
  return <span className={`badge ${tones[status] ?? 'bg-ink-100'}`}>{statusLabel(status, LICENSE_STATUS)}</span>;
}

function SeatCountEditor({ type, current, onSave }: { type: LicenseType; current: number; onSave: (t: LicenseType, n: number) => void }) {
  const [editing, setEditing] = useState(false);
  const [val, setVal] = useState(current);
  if (!editing) {
    return <button onClick={() => { setVal(current); setEditing(true); }} className="btn-ghost text-xs px-2 py-1">Ajuster</button>;
  }
  return (
    <div className="flex items-center gap-1">
      <input type="number" min={0} className="input w-20 py-1" value={val} onChange={(e) => setVal(Number(e.target.value))} />
      <button onClick={() => { onSave(type, val); setEditing(false); }} className="btn-primary text-xs px-2 py-1">OK</button>
      <button onClick={() => setEditing(false)} className="btn-ghost text-xs px-2 py-1">X</button>
    </div>
  );
}

function AssignPicker({ license, employees, onAssign }: { license: License; employees: { id: string; first_name: string; last_name: string }[]; onAssign: (l: License, empId: string) => void }) {
  const [open, setOpen] = useState(false);
  const [q, setQ] = useState('');
  const list = employees.filter((e) => `${e.first_name} ${e.last_name}`.toLowerCase().includes(q.toLowerCase())).slice(0, 8);
  return (
    <div className="relative">
      <button title="Attribuer" onClick={() => setOpen((v) => !v)} className="btn-ghost p-1.5 text-elyade-600">
        <UserPlus className="w-4 h-4" />
      </button>
      {open && (
        <div className="absolute right-0 mt-1 w-56 bg-white border border-ink-200 rounded-lg shadow-elevated z-20 p-2">
          <input className="input mb-2" placeholder="Rechercher…" value={q} onChange={(e) => setQ(e.target.value)} autoFocus />
          <div className="max-h-48 overflow-auto">
            {list.map((e) => (
              <button key={e.id} onClick={() => { onAssign(license, e.id); setOpen(false); }} className="w-full text-left px-2 py-1.5 text-sm rounded hover:bg-ink-50">
                {e.first_name} {e.last_name}
              </button>
            ))}
            {list.length === 0 && <p className="text-xs text-ink-400 px-2 py-1">Aucun résultat</p>}
          </div>
        </div>
      )}
    </div>
  );
}

function LicenseTypeForm({ onClose, onSaved }: { onClose: () => void; onSaved: () => void }) {
  const { profile } = useAuth();
  const [code, setCode] = useState('');
  const [label, setLabel] = useState('');
  const [total, setTotal] = useState(0);
  const [hasExpiration, setHasExpiration] = useState(true);
  const [noticeDays, setNoticeDays] = useState(30);
  const [notes, setNotes] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const payload = {
        code: code.toUpperCase(),
        label,
        total_seats: total,
        has_expiration: hasExpiration,
        default_renewal_notice_days: noticeDays,
        notes: notes || null,
      };

const res = await fetch('/api/license-types', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(payload),
});

if (!res.ok) {
  const err = await res.json().catch(() => ({ error: 'Erreur création type de licence' }));
  throw new Error(err.error ?? 'Erreur création type de licence');
}

const created = await res.json();

await logAudit(
  'create',
  'license_type',
  created.id,
  payload,
  profile?.display_name
).catch(console.error);

onSaved();

    } catch (e) {
      setError(e instanceof Error ? e.message : 'Erreur');
    } finally {
      setBusy(false);
    }
  }

  return (
    <Modal title="Nouveau type de licence" onClose={onClose}>
      <form onSubmit={onSubmit} className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="label">Code</label>
            <input className="input" value={code} onChange={(e) => setCode(e.target.value)} placeholder="SEIITRA" required />
          </div>
          <div>
            <label className="label">Libellé</label>
            <input className="input" value={label} onChange={(e) => setLabel(e.target.value)} placeholder="Seiitra" required />
          </div>
        </div>
        <div>
          <label className="label">Nombre de sièges achetés</label>
          <input type="number" min={0} className="input" value={total} onChange={(e) => setTotal(Number(e.target.value))} />
        </div>
        <div className="flex items-center gap-3 p-3 rounded-lg bg-ink-50">
          <label className="flex items-center gap-2 cursor-pointer">
            <input type="checkbox" checked={hasExpiration} onChange={(e) => setHasExpiration(e.target.checked)} className="w-4 h-4 accent-elyade-600" />
            <span className="text-sm font-medium text-ink-700">Licence avec expiration</span>
          </label>
          {hasExpiration && (
            <div className="flex items-center gap-2 ml-auto">
              <label className="text-sm text-ink-600">Préavis de renouvellement</label>
              <input type="number" min={1} max={365} className="input w-24 py-1" value={noticeDays} onChange={(e) => setNoticeDays(Number(e.target.value))} />
              <span className="text-sm text-ink-500">jours</span>
            </div>
          )}
        </div>
        <div>
          <label className="label">Notes</label>
          <textarea className="input min-h-[70px]" value={notes} onChange={(e) => setNotes(e.target.value)} />
        </div>
        {error && <div className="rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-sm text-red-700">{error}</div>}
        <div className="flex justify-end gap-2 pt-2">
          <button type="button" onClick={onClose} className="btn-secondary">Annuler</button>
          <button type="submit" className="btn-primary" disabled={busy}>{busy ? 'Création…' : 'Créer'}</button>
        </div>
      </form>
    </Modal>
  );
}

function SeatForm({ types, onClose, onSaved }: { types: LicenseType[]; onClose: () => void; onSaved: () => void }) {
  const { profile } = useAuth();
  const [typeId, setTypeId] = useState(types[0]?.id ?? '');
  const [count, setCount] = useState(1);
  const [prefix, setPrefix] = useState('');
  const [hasExpiration, setHasExpiration] = useState(true);
  const [expirationDate, setExpirationDate] = useState('');
  const [noticeDays, setNoticeDays] = useState<number | ''>('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const selectedType = types.find((t) => t.id === typeId);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const rows = Array.from({ length: Math.max(1, count) }).map((_, i) => ({
        license_type_id: typeId,
        seat_key: prefix ? `${prefix}-${String(i + 1).padStart(3, '0')}` : null,
        status: 'available' as const,
        expiration_date: hasExpiration ? (expirationDate || null) : null,
        renewal_notice_days: noticeDays === '' ? null : noticeDays,
      }));

const res = await fetch('/api/licenses', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(rows),
});

if (!res.ok) {
  const err = await res.json().catch(() => ({ error: 'Erreur création sièges de licence' }));
  throw new Error(err.error ?? 'Erreur création sièges de licence');
}

const inserted = await res.json();

for (const r of inserted ?? []) {
  await logAudit(
    'create',
    'license',
    r.id,
    { license_type_id: typeId, count },
    profile?.display_name
  ).catch(console.error);
}

onSaved();

    } catch (e) {
      setError(e instanceof Error ? e.message : 'Erreur');
    } finally {
      setBusy(false);
    }
  }

  return (
    <Modal title="Ajouter des sièges de licence" onClose={onClose}>
      <form onSubmit={onSubmit} className="space-y-4">
        <div>
          <label className="label">Type de licence</label>
          <select className="input" value={typeId} onChange={(e) => setTypeId(e.target.value)} required>
            {types.map((t) => <option key={t.id} value={t.id}>{t.label}</option>)}
          </select>
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="label">Nombre de sièges</label>
            <input type="number" min={1} max={1000} className="input" value={count} onChange={(e) => setCount(Number(e.target.value))} />
          </div>
          <div>
            <label className="label">Préfixe clé (optionnel)</label>
            <input className="input" value={prefix} onChange={(e) => setPrefix(e.target.value)} placeholder="OFFICE-ELY" />
          </div>
        </div>
        {selectedType && (
          <div className="p-3 rounded-lg bg-amber-50/50 border border-amber-200">
            <label className="flex items-center gap-2 cursor-pointer mb-3">
              <input type="checkbox" checked={hasExpiration} onChange={(e) => setHasExpiration(e.target.checked)} className="w-4 h-4 accent-elyade-600" />
              <span className="text-sm font-medium text-ink-700">Ces sièges ont une date d'expiration</span>
            </label>
            {hasExpiration && (
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Date d'expiration</label>
                  <input type="date" className="input" value={expirationDate} onChange={(e) => setExpirationDate(e.target.value)} />
                </div>
                <div>
                  <label className="label">Préavis (surcharge, optionnel)</label>
                  <input type="number" min={1} max={365} className="input" value={noticeDays} onChange={(e) => setNoticeDays(e.target.value === '' ? '' : Number(e.target.value))} placeholder={`défaut: ${selectedType.default_renewal_notice_days}j`} />
                </div>
              </div>
            )}
          </div>
        )}
        {error && <div className="rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-sm text-red-700">{error}</div>}
        <div className="flex justify-end gap-2 pt-2">
          <button type="button" onClick={onClose} className="btn-secondary">Annuler</button>
          <button type="submit" className="btn-primary" disabled={busy}>{busy ? 'Ajout…' : 'Ajouter'}</button>
        </div>
      </form>
    </Modal>
  );
}

function Modal({ title, onClose, children }: { title: string; onClose: () => void; children: React.ReactNode }) {
  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center z-50 p-4" onClick={onClose}>
      <div className="card w-full max-w-lg max-h-[90vh] overflow-auto" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-5 py-4 border-b border-ink-100 sticky top-0 bg-white rounded-t-xl">
          <h2 className="text-lg font-semibold text-ink-900">{title}</h2>
          <button onClick={onClose} className="btn-ghost p-1.5"><X className="w-5 h-5" /></button>
        </div>
        <div className="p-5">{children}</div>
      </div>
    </div>
  );
}
