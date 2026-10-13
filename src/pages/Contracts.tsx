import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { AlertTriangle, Pencil, Plus, RefreshCw, Trash2, X } from 'lucide-react';

// Suivi des contrats informatiques (groupe 🔐 Manager Informatique).

type Contract = {
  id: string;
  label: string;
  supplier_id: string | null;
  supplier: string | null;
  category: string | null;
  start_date: string | null;
  commitment_months: number | null;
  tacit_renewal: boolean;
  notice_months: number | null;
  renewal_date: string | null;
  termination_deadline: string | null;
  end_date: string | null;
  status: string;
  annual_cost: number | null;
  notes: string | null;
  supplier_spent_fy: number;
  next_end_date: string | null;
  next_deadline: string | null;
  days_to_deadline: number | null;
  rolled: boolean;
  inconsistent: boolean;
};
type Supplier = { id: string; name: string };

const STATUSES = ['Actif', 'À renouveler', 'En cours de résiliation', 'Résilié'];
const COMMITMENTS = [0, 12, 24, 36, 48, 60];
const NOTICES = [0, 1, 2, 3, 6];

const euro = (v: number | null) => (v === null ? '—' : v.toLocaleString('fr-FR', { style: 'currency', currency: 'EUR' }));
const fr = (iso: string | null) => (iso ? new Date(`${iso}T00:00:00`).toLocaleDateString('fr-FR') : '—');
const duration = (months: number | null) =>
  months === null ? '—' : months === 0 ? "Pas d'engagement" : months % 12 === 0 ? `${months / 12} an${months > 12 ? 's' : ''}` : `${months} mois`;
const notice = (months: number | null) => (months === null ? '—' : months === 0 ? 'Pas de préavis' : `${months} mois`);

function addMonths(iso: string, months: number) {
  const d = new Date(`${iso}T00:00:00Z`);
  const day = d.getUTCDate();
  d.setUTCDate(1);
  d.setUTCMonth(d.getUTCMonth() + months);
  const last = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 0)).getUTCDate();
  d.setUTCDate(Math.min(day, last));
  return d.toISOString().slice(0, 10);
}

async function api<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, { ...init, headers: { 'Content-Type': 'application/json' } });
  if (res.status === 204) return undefined as T;
  const json = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(json.error || 'Erreur');
  return json as T;
}

// Urgence de la date limite de résiliation (libellé + couleur, jamais la couleur seule).
function DeadlineBadge({ days }: { days: number | null }) {
  if (days === null) return null;
  if (days < 0) return <span className="badge bg-ink-100 text-ink-600">dépassée</span>;
  const cls = days <= 30 ? 'bg-red-50 text-red-700 border border-red-200' : days <= 90 ? 'bg-amber-50 text-amber-800 border border-amber-200' : 'bg-ink-50 text-ink-600';
  return <span className={`badge ${cls}`}>dans {days} j</span>;
}

type FormState = {
  id?: string;
  label: string;
  supplier_id: string;
  category: string;
  start_date: string;
  commitment_months: string;
  tacit_renewal: boolean;
  notice_months: string;
  renewal_date: string;
  termination_deadline: string;
  end_date: string;
  status: string;
  annual_cost: string;
  notes: string;
};

const toForm = (c?: Contract): FormState => ({
  id: c?.id,
  label: c?.label || '',
  supplier_id: c?.supplier_id || '',
  category: c?.category || '',
  start_date: c?.start_date || '',
  commitment_months: c?.commitment_months === null || c?.commitment_months === undefined ? '' : String(c.commitment_months),
  tacit_renewal: c ? c.tacit_renewal : true,
  notice_months: c?.notice_months === null || c?.notice_months === undefined ? '' : String(c.notice_months),
  renewal_date: c?.renewal_date || '',
  termination_deadline: c?.termination_deadline || '',
  end_date: c?.end_date || '',
  status: c?.status || 'Actif',
  annual_cost: c?.annual_cost === null || c?.annual_cost === undefined ? '' : String(c.annual_cost).replace('.', ','),
  notes: c?.notes || '',
});

function ContractForm({
  initial,
  suppliers,
  categories,
  onClose,
  onSaved,
}: {
  initial: FormState;
  suppliers: Supplier[];
  categories: string[];
  onClose: () => void;
  onSaved: () => void;
}) {
  const [form, setForm] = useState(initial);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const set = (key: keyof FormState) => (e: { target: { value: string } }) => setForm({ ...form, [key]: e.target.value });

  // Fin de contrat = 1er engagement + durée ; date limite = fin - préavis.
  const commitment = form.commitment_months === '' ? null : Number(form.commitment_months);
  const computedEnd = form.start_date && commitment ? addMonths(form.start_date, commitment) : null;
  const endForDeadline = form.end_date || computedEnd;
  const computedDeadline = endForDeadline && form.notice_months !== '' ? addMonths(endForDeadline, -Number(form.notice_months)) : null;
  const canApply = (computedEnd && computedEnd !== form.end_date) || (computedDeadline && computedDeadline !== form.termination_deadline);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError(null);
    try {
      await api(form.id ? `/api/contracts/${form.id}` : '/api/contracts', { method: form.id ? 'PUT' : 'POST', body: JSON.stringify(form) });
      onSaved();
      onClose();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 bg-ink-950/40 flex items-start justify-center overflow-y-auto p-4" onClick={onClose}>
      <form className="card w-full max-w-2xl my-8 p-5 space-y-4" onClick={(e) => e.stopPropagation()} onSubmit={submit}>
        <div className="flex items-center justify-between">
          <h3 className="font-semibold text-ink-900">{form.id ? 'Modifier le contrat' : 'Nouveau contrat'}</h3>
          <button type="button" className="btn-ghost p-1.5" onClick={onClose} aria-label="Fermer"><X className="w-4 h-4" /></button>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <label className="text-sm sm:col-span-2">
            <span className="label">Contrat (prestataire et objet)</span>
            <input className="input" required value={form.label} onChange={set('label')} placeholder="Ex. XEFI - Hébergement DataCenter" />
          </label>
          <label className="text-sm">
            <span className="label">Fournisseur</span>
            <select className="input" value={form.supplier_id} onChange={set('supplier_id')}>
              <option value="">—</option>
              {suppliers.map((s) => (
                <option key={s.id} value={s.id}>{s.name}</option>
              ))}
            </select>
            <span className="text-xs text-ink-400">Liste commune (Paramètres → Inventaire → Fournisseurs)</span>
          </label>
          <label className="text-sm">
            <span className="label">Catégorie</span>
            <input className="input" list="contract-categories" value={form.category} onChange={set('category')} />
            <datalist id="contract-categories">
              {categories.map((c) => (
                <option key={c} value={c} />
              ))}
            </datalist>
          </label>
          <label className="text-sm">
            <span className="label">1er engagement</span>
            <input className="input" type="date" value={form.start_date} onChange={set('start_date')} />
          </label>
          <label className="text-sm">
            <span className="label">Durée d'engagement</span>
            <select className="input" value={form.commitment_months} onChange={set('commitment_months')}>
              <option value="">—</option>
              {COMMITMENTS.map((m) => (
                <option key={m} value={m}>{duration(m)}</option>
              ))}
              {form.commitment_months && !COMMITMENTS.includes(Number(form.commitment_months)) && (
                <option value={form.commitment_months}>{duration(Number(form.commitment_months))}</option>
              )}
            </select>
          </label>
          <label className="text-sm">
            <span className="label">Préavis</span>
            <select className="input" value={form.notice_months} onChange={set('notice_months')}>
              <option value="">—</option>
              {NOTICES.map((m) => (
                <option key={m} value={m}>{notice(m)}</option>
              ))}
            </select>
          </label>
          <label className="text-sm flex items-center gap-2 pt-6">
            <input type="checkbox" checked={form.tacit_renewal} onChange={(e) => setForm({ ...form, tacit_renewal: e.target.checked })} />
            Tacite reconduction
          </label>
          <label className="text-sm">
            <span className="label">Date de fin de contrat</span>
            <input className="input" type="date" value={form.end_date} onChange={set('end_date')} />
          </label>
          <label className="text-sm">
            <span className="label">Date limite de résiliation</span>
            <input className="input" type="date" value={form.termination_deadline} onChange={set('termination_deadline')} />
          </label>
          {canApply && (
            <div className="sm:col-span-2 text-xs p-2 rounded-lg bg-elyade-50 border border-elyade-200 flex flex-wrap items-center gap-2">
              Calcul : fin {fr(computedEnd || form.end_date || null)}, résiliation avant le {fr(computedDeadline)}
              <button
                type="button"
                className="btn-ghost text-xs"
                onClick={() => setForm({ ...form, end_date: computedEnd || form.end_date, termination_deadline: computedDeadline || form.termination_deadline })}
              >
                Appliquer
              </button>
            </div>
          )}
          <label className="text-sm">
            <span className="label">Date de renouvellement</span>
            <input className="input" type="date" value={form.renewal_date} onChange={set('renewal_date')} />
          </label>
          <label className="text-sm">
            <span className="label">Coût annuel (€)</span>
            <input className="input text-right" inputMode="decimal" value={form.annual_cost} onChange={set('annual_cost')} placeholder="0,00" />
          </label>
          <label className="text-sm">
            <span className="label">Statut</span>
            <select className="input" value={form.status} onChange={set('status')}>
              {STATUSES.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
          </label>
          <label className="text-sm sm:col-span-2">
            <span className="label">Notes</span>
            <textarea className="input" rows={2} value={form.notes} onChange={set('notes')} />
          </label>
        </div>
        {error && <p className="text-sm text-red-600">{error}</p>}
        <div className="flex justify-end gap-2">
          <button type="button" className="btn-ghost text-sm" onClick={onClose}>Annuler</button>
          <button className="btn-primary text-sm" disabled={saving}>{saving ? 'Enregistrement…' : 'Enregistrer'}</button>
        </div>
      </form>
    </div>
  );
}

export default function Contracts() {
  const [contracts, setContracts] = useState<Contract[]>([]);
  const [suppliers, setSuppliers] = useState<Supplier[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [category, setCategory] = useState('');
  const [status, setStatus] = useState('actifs');
  const [search, setSearch] = useState('');
  const [editing, setEditing] = useState<FormState | null>(null);

  async function load() {
    try {
      const [list, supplierList] = await Promise.all([api<Contract[]>('/api/contracts'), api<Supplier[]>('/api/expense-suppliers')]);
      setContracts(list);
      setSuppliers(supplierList);
      setError(null);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load();
  }, []);

  const categories = useMemo(() => [...new Set(contracts.map((c) => c.category).filter(Boolean) as string[])].sort((a, b) => a.localeCompare(b, 'fr')), [contracts]);
  const isOpen = (c: Contract) => c.status !== 'Résilié';
  const active = contracts.filter(isOpen);
  const soon = active.filter((c) => c.days_to_deadline !== null && c.days_to_deadline >= 0 && c.days_to_deadline <= 90).sort((a, b) => a.days_to_deadline! - b.days_to_deadline!);
  const annualTotal = active.reduce((s, c) => s + (c.annual_cost || 0), 0);

  const byCategory = useMemo(() => {
    const map = new Map<string, number>();
    for (const c of active) map.set(c.category || '—', (map.get(c.category || '—') || 0) + (c.annual_cost || 0));
    return [...map.entries()].map(([label, value]) => ({ label, value })).sort((a, b) => b.value - a.value);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [contracts]);
  const maxCategory = Math.max(1, ...byCategory.map((c) => c.value));

  const listed = contracts
    .filter((c) => (status === 'actifs' ? isOpen(c) : !status || c.status === status))
    .filter((c) => !category || c.category === category)
    .filter((c) => {
      const q = search.trim().toLowerCase();
      return !q || [c.label, c.supplier, c.category, c.notes].some((v) => v?.toLowerCase().includes(q));
    })
    .sort((a, b) => (a.next_deadline || '9999').localeCompare(b.next_deadline || '9999'));

  async function remove(c: Contract) {
    if (!confirm(`Supprimer le contrat « ${c.label} » ?`)) return;
    try {
      await api(`/api/contracts/${c.id}`, { method: 'DELETE' });
      await load();
    } catch (err: any) {
      alert(err.message);
    }
  }

  if (loading) return <div className="p-6 text-ink-500">Chargement…</div>;

  return (
    <div className="p-6 w-full max-w-[1600px] mx-auto space-y-5">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-xl font-semibold text-ink-900">Suivi des contrats</h1>
          <p className="text-sm text-ink-500">Échéances, préavis et coûts des contrats informatiques. Accès réservé au groupe Manager Informatique.</p>
        </div>
        <button type="button" className="btn-primary text-sm" onClick={() => setEditing(toForm())}><Plus className="w-4 h-4" /> Nouveau contrat</button>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="card p-4">
          <p className="text-xs uppercase tracking-wide text-ink-500">Coût annuel des contrats en cours</p>
          <p className="text-2xl font-semibold text-ink-900 mt-1 tabular-nums">{euro(annualTotal)}</p>
          <p className="text-xs text-ink-500 mt-1">{active.length} contrat{active.length > 1 ? 's' : ''}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs uppercase tracking-wide text-ink-500">Résiliations à décider sous 90 jours</p>
          <p className="text-2xl font-semibold text-ink-900 mt-1">{soon.length}</p>
          <p className="text-xs text-ink-500 mt-1">dont {soon.filter((c) => c.days_to_deadline! <= 30).length} sous 30 jours</p>
        </div>
        <div className="card p-4">
          <p className="text-xs uppercase tracking-wide text-ink-500">Prochaine date limite</p>
          <p className="text-lg font-semibold text-ink-900 mt-1 truncate">{soon[0] ? fr(soon[0].next_deadline) : '—'}</p>
          <p className="text-xs text-ink-500 mt-1 truncate">{soon[0]?.label || 'Rien dans les 90 jours'}</p>
        </div>
      </div>

      {soon.length > 0 && (
        <div className="card p-4 border-amber-200">
          <h2 className="font-semibold text-ink-900 mb-2 flex items-center gap-2"><AlertTriangle className="w-4 h-4 text-amber-600" /> À décider bientôt</h2>
          <div className="space-y-1.5">
            {soon.map((c) => (
              <div key={c.id} className="flex flex-wrap items-center gap-2 text-sm">
                <DeadlineBadge days={c.days_to_deadline} />
                <span className="font-medium">{c.label}</span>
                <span className="text-ink-500">
                  résilier avant le {fr(c.next_deadline)} · échéance {fr(c.next_end_date)}{c.tacit_renewal ? ' (tacite reconduction)' : ''} · {euro(c.annual_cost)} / an
                </span>
              </div>
            ))}
          </div>
          <p className="text-xs text-ink-500 mt-2">Un mail de rappel est envoyé à 90, 30 puis 7 jours de la date limite.</p>
        </div>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-4 gap-4">
        <div className="card p-4">
          <h2 className="font-semibold text-ink-900 mb-3">Coût annuel par catégorie</h2>
          <div className="space-y-2.5">
            {byCategory.map((row) => (
              <div key={row.label}>
                <div className="flex justify-between text-xs mb-1">
                  <span className="text-ink-700">{row.label}</span>
                  <span className="text-ink-900 font-medium tabular-nums">{euro(row.value)}</span>
                </div>
                <div className="h-2.5 rounded-full bg-ink-100">
                  <div className="h-2.5 rounded-full bg-elyade-600" style={{ width: `${(row.value / maxCategory) * 100}%` }} />
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="card p-4 xl:col-span-3">
          <div className="flex flex-wrap items-center gap-2 mb-3">
            <select className="input py-1.5 w-48" value={status} onChange={(e) => setStatus(e.target.value)}>
              <option value="actifs">En cours (hors résiliés)</option>
              <option value="">Tous les statuts</option>
              {STATUSES.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
            <select className="input py-1.5 w-48" value={category} onChange={(e) => setCategory(e.target.value)}>
              <option value="">Toutes catégories</option>
              {categories.map((c) => (
                <option key={c} value={c}>{c}</option>
              ))}
            </select>
            <input className="input py-1.5 flex-1 min-w-[180px]" placeholder="Rechercher…" value={search} onChange={(e) => setSearch(e.target.value)} />
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-xs uppercase tracking-wide text-ink-500 bg-ink-50 border-b border-ink-100">
                  <th className="text-left py-2 px-3 font-semibold">Contrat</th>
                  <th className="text-left py-2 px-3 font-semibold">Engagement</th>
                  <th className="text-left py-2 px-3 font-semibold">Échéance</th>
                  <th className="text-left py-2 px-3 font-semibold">Résilier avant</th>
                  <th className="text-right py-2 px-3 font-semibold">Coût annuel</th>
                  <th className="text-right py-2 px-3 font-semibold" title="Dépenses du fournisseur sur l'exercice en cours">Dépensé (exercice)</th>
                  <th className="text-left py-2 px-3 font-semibold">Statut</th>
                  <th className="py-2 px-3"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-ink-100">
                {listed.map((c) => (
                  <tr key={c.id} className="hover:bg-ink-50/60 align-top">
                    <td className="py-2 px-3">
                      <span className="font-medium text-ink-900">{c.label}</span>
                      <span className="block text-xs text-ink-500">{[c.supplier, c.category].filter(Boolean).join(' · ')}</span>
                    </td>
                    <td className="py-2 px-3 text-xs">
                      {duration(c.commitment_months)}
                      <span className="block text-ink-500">préavis {notice(c.notice_months)}</span>
                      {c.tacit_renewal && <span className="block text-ink-500">tacite reconduction</span>}
                    </td>
                    <td className="py-2 px-3 text-xs whitespace-nowrap">
                      {fr(c.next_end_date)}
                      {c.rolled && (
                        <span className="flex items-center gap-1 text-ink-500" title={`Fin initiale : ${fr(c.end_date)}`}>
                          <RefreshCw className="w-3 h-3" /> reconduit
                        </span>
                      )}
                    </td>
                    <td className="py-2 px-3 text-xs whitespace-nowrap">
                      {fr(c.next_deadline)} <DeadlineBadge days={c.days_to_deadline} />
                      {c.inconsistent && (
                        <span className="flex items-center gap-1 text-amber-700 mt-0.5" title="La date limite de résiliation est après la date de fin : à vérifier">
                          <AlertTriangle className="w-3 h-3" /> dates à vérifier
                        </span>
                      )}
                    </td>
                    <td className="py-2 px-3 text-right tabular-nums">{euro(c.annual_cost)}</td>
                    <td className="py-2 px-3 text-right tabular-nums text-ink-600">{c.supplier ? euro(c.supplier_spent_fy) : '—'}</td>
                    <td className="py-2 px-3 text-xs">{c.status}</td>
                    <td className="py-2 px-3 whitespace-nowrap text-right">
                      <button type="button" className="btn-ghost p-1.5" title="Modifier" onClick={() => setEditing(toForm(c))}><Pencil className="w-4 h-4" /></button>
                      <button type="button" className="btn-ghost p-1.5 text-ink-400 hover:text-red-600" title="Supprimer" onClick={() => void remove(c)}><Trash2 className="w-4 h-4" /></button>
                    </td>
                  </tr>
                ))}
                {listed.length === 0 && (
                  <tr>
                    <td colSpan={8} className="py-6 text-center text-ink-400">Aucun contrat.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {editing && <ContractForm initial={editing} suppliers={suppliers} categories={categories} onClose={() => setEditing(null)} onSaved={() => void load()} />}
    </div>
  );
}
