import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { AlertTriangle, History, Pencil, Plus, RotateCw, Trash2, X } from 'lucide-react';

// Suivi des contrats informatiques (groupe 🔐 Manager Informatique).
// Dates de fin, de renouvellement et limite de résiliation calculées à partir
// du début, de la durée, du mode de reconduction et du préavis (comme le serveur).

type RenewalMode = 'none' | 'same' | 'no_commitment' | 'custom';
type Billing = 'annual' | 'quarterly' | 'monthly';

type Contract = {
  id: string;
  label: string;
  supplier_id: string | null;
  supplier: string | null;
  category: string | null;
  start_date: string | null;
  commitment_months: number | null;
  notice_months: number | null;
  renewal_mode: RenewalMode;
  renewal_months: number | null;
  billing_frequency: Billing;
  billing_amount: number | null;
  stored_end_date: string | null;
  status: string;
  notes: string | null;
  renewals: { previous_start: string | null; previous_end: string | null; new_start: string; new_months: number; renewed_by: string | null; renewed_at: string }[];
  end_date: string | null;
  renewal_date: string | null;
  termination_deadline: string | null;
  cancellable_from: string | null;
  decision_date: string | null;
  decision: 'renew' | 'terminate' | null;
  days_to_decision: number | null;
  annual_cost: number | null;
  fiscal_cost: number;
  supplier_spent_fy: number | null;
  decided: boolean;
  decision_for: string | null;
  decision_type: 'keep' | 'terminate' | 'renew_planned' | 'end' | null;
  decision_note: string | null;
  decision_by: string | null;
  decision_at: string | null;
  termination_effective: string | null;
};

const DECISION_LABELS = {
  keep: 'Laissé en reconduction',
  terminate: 'Résiliation envoyée',
  renew_planned: 'Renouvellement prévu',
  end: 'Non renouvelé',
} as const;
type Supplier = { id: string; name: string };
type Category = { id: string; label: string };

const STATUSES = ['Actif', 'En cours de résiliation', 'Résilié', 'Terminé'];
const RENEWAL_LABELS: Record<RenewalMode, string> = {
  none: 'Sans tacite reconduction',
  same: 'Tacite reconduction, même durée',
  no_commitment: 'Tacite reconduction, puis sans engagement',
  custom: 'Tacite reconduction, durée personnalisée',
};
const BILLING_LABELS: Record<Billing, string> = { annual: 'Annuelle', quarterly: 'Trimestrielle', monthly: 'Mensuelle' };
const BILLING_MONTHS: Record<Billing, number> = { annual: 12, quarterly: 3, monthly: 1 };
const DURATIONS = [0, 12, 24, 36, 48, 60];
const NOTICES = [0, 1, 2, 3, 6];

const euro = (v: number | null) => (v === null ? '—' : v.toLocaleString('fr-FR', { style: 'currency', currency: 'EUR' }));
const fr = (iso: string | null) => (iso ? new Date(`${iso}T00:00:00`).toLocaleDateString('fr-FR') : '—');
const duration = (m: number | null) => (m === null ? '—' : m === 0 ? "Sans engagement" : m % 12 === 0 ? `${m / 12} an${m > 12 ? 's' : ''}` : `${m} mois`);
const noticeText = (m: number | null) => (m === null ? '—' : m === 0 ? 'sans préavis' : `préavis ${m} mois`);

function addMonths(iso: string, months: number) {
  const d = new Date(`${iso}T00:00:00Z`);
  const day = d.getUTCDate();
  d.setUTCDate(1);
  d.setUTCMonth(d.getUTCMonth() + months);
  const last = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 0)).getUTCDate();
  d.setUTCDate(Math.min(day, last));
  return d.toISOString().slice(0, 10);
}
const todayIso = () => {
  const n = new Date();
  return new Date(Date.UTC(n.getFullYear(), n.getMonth(), n.getDate())).toISOString().slice(0, 10);
};

// Même calcul que le serveur (server/contracts.mjs, contractTerms).
function computeTerms(start: string, months: number, notice: number, mode: RenewalMode, renewalMonths: number) {
  const today = todayIso();
  const initialEnd = start && months > 0 ? addMonths(start, months) : null;
  if (mode === 'none') return { end: initialEnd, renewal: null, deadline: null, cancellable: null };
  if (mode === 'no_commitment' || (mode === 'same' && months === 0)) {
    if (initialEnd && initialEnd > today) return { end: null, renewal: initialEnd, deadline: addMonths(initialEnd, -notice), cancellable: null };
    return { end: null, renewal: null, deadline: null, cancellable: addMonths(today, notice) };
  }
  if (!initialEnd) return { end: null, renewal: null, deadline: null, cancellable: null };
  const period = mode === 'custom' ? renewalMonths || 12 : months || 12;
  let end = initialEnd;
  for (let i = 0; end <= today && i < 500; i++) end = addMonths(end, period);
  return { end: null, renewal: end, deadline: addMonths(end, -notice), cancellable: null };
}

async function api<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, { ...init, headers: { 'Content-Type': 'application/json' } });
  if (res.status === 204) return undefined as T;
  const json = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(json.error || 'Erreur');
  return json as T;
}

function DecisionBadge({ days }: { days: number | null }) {
  if (days === null) return null;
  if (days < 0) return <span className="badge bg-ink-100 text-ink-600">dépassée</span>;
  const cls = days <= 30 ? 'bg-red-50 text-red-700 border border-red-200' : days <= 90 ? 'bg-amber-50 text-amber-800 border border-amber-200' : 'bg-ink-50 text-ink-600';
  return <span className={`badge ${cls}`}>dans {days} j</span>;
}

// ---------------------------------------------------------------------------
// Formulaire
// ---------------------------------------------------------------------------
type FormState = {
  id?: string;
  label: string;
  supplier_id: string;
  category: string;
  start_date: string;
  commitment_months: string;
  notice_months: string;
  renewal_mode: RenewalMode;
  renewal_months: string;
  billing_frequency: Billing;
  billing_amount: string;
  status: string;
  notes: string;
};

const num = (v: number | null | undefined) => (v === null || v === undefined ? '' : String(v));
const toForm = (c?: Contract): FormState => ({
  id: c?.id,
  label: c?.label || '',
  supplier_id: c?.supplier_id || '',
  category: c?.category || '',
  start_date: c?.start_date || '',
  commitment_months: c ? num(c.commitment_months) : '12',
  notice_months: c ? num(c.notice_months) : '3',
  renewal_mode: c?.renewal_mode || 'same',
  renewal_months: num(c?.renewal_months),
  billing_frequency: c?.billing_frequency || 'annual',
  billing_amount: c?.billing_amount === null || c?.billing_amount === undefined ? '' : String(c.billing_amount).replace('.', ','),
  status: c?.status || 'Actif',
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
  categories: Category[];
  onClose: () => void;
  onSaved: () => void;
}) {
  const [form, setForm] = useState(initial);
  const [customDuration, setCustomDuration] = useState(initial.commitment_months !== '' && !DURATIONS.includes(Number(initial.commitment_months)));
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const set = (key: keyof FormState) => (e: { target: { value: string } }) => setForm({ ...form, [key]: e.target.value });

  const months = Number(form.commitment_months) || 0;
  const notice = Number(form.notice_months) || 0;
  const terms = computeTerms(form.start_date, months, notice, form.renewal_mode, Number(form.renewal_months) || 0);
  const amount = Number(form.billing_amount.replace(/\s/g, '').replace(',', '.'));
  const annual = Number.isFinite(amount) && form.billing_amount ? amount * (12 / BILLING_MONTHS[form.billing_frequency]) : null;

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
          </label>
          <label className="text-sm">
            <span className="label">Catégorie</span>
            <select className="input" value={form.category} onChange={set('category')}>
              <option value="">—</option>
              {categories.map((c) => (
                <option key={c.id} value={c.label}>{c.label}</option>
              ))}
              {form.category && !categories.some((c) => c.label === form.category) && <option value={form.category}>{form.category}</option>}
            </select>
            <span className="text-xs text-ink-400">Liste gérée dans Paramètres → Catégories de contrats</span>
          </label>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-2 border-t border-ink-100">
          <label className="text-sm">
            <span className="label">Date de début</span>
            <input className="input" type="date" required value={form.start_date} onChange={set('start_date')} />
          </label>
          <label className="text-sm">
            <span className="label">Durée d'engagement</span>
            {customDuration ? (
              <div className="flex gap-1">
                <input className="input" type="number" min={1} value={form.commitment_months} onChange={set('commitment_months')} placeholder="mois" />
                <button type="button" className="btn-ghost text-xs" onClick={() => setCustomDuration(false)}>Liste</button>
              </div>
            ) : (
              <select
                className="input"
                value={form.commitment_months}
                onChange={(e) => {
                  if (e.target.value === 'custom') {
                    setCustomDuration(true);
                    setForm({ ...form, commitment_months: '' });
                  } else setForm({ ...form, commitment_months: e.target.value });
                }}
              >
                {DURATIONS.map((m) => (
                  <option key={m} value={m}>{duration(m)}</option>
                ))}
                <option value="custom">Durée personnalisée…</option>
              </select>
            )}
          </label>
          <label className="text-sm">
            <span className="label">Préavis</span>
            <select className="input" value={form.notice_months} onChange={set('notice_months')}>
              {NOTICES.map((m) => (
                <option key={m} value={m}>{m === 0 ? 'Pas de préavis' : `${m} mois`}</option>
              ))}
            </select>
          </label>
          <label className="text-sm sm:col-span-2">
            <span className="label">Reconduction</span>
            <select className="input" value={form.renewal_mode} onChange={(e) => setForm({ ...form, renewal_mode: e.target.value as RenewalMode })}>
              {(Object.keys(RENEWAL_LABELS) as RenewalMode[]).map((m) => (
                <option key={m} value={m}>{RENEWAL_LABELS[m]}</option>
              ))}
            </select>
          </label>
          {form.renewal_mode === 'custom' && (
            <label className="text-sm">
              <span className="label">Durée de chaque renouvellement (mois)</span>
              <input className="input" type="number" min={1} required value={form.renewal_months} onChange={set('renewal_months')} />
            </label>
          )}
        </div>

        <div className="text-sm p-3 rounded-lg bg-elyade-50/60 border border-elyade-200 grid grid-cols-1 sm:grid-cols-3 gap-2">
          {form.renewal_mode === 'none' ? (
            <div>
              <p className="text-xs text-ink-500">Date de fin de contrat</p>
              <p className="font-medium">{fr(terms.end)}</p>
            </div>
          ) : terms.cancellable ? (
            <div className="sm:col-span-2">
              <p className="text-xs text-ink-500">Sans engagement</p>
              <p className="font-medium">Résiliable à tout moment, fin au plus tôt le {fr(terms.cancellable)}</p>
            </div>
          ) : (
            <>
              <div>
                <p className="text-xs text-ink-500">Date de renouvellement</p>
                <p className="font-medium">{fr(terms.renewal)}</p>
              </div>
              <div>
                <p className="text-xs text-ink-500">Date limite de résiliation</p>
                <p className="font-medium">{fr(terms.deadline)}</p>
              </div>
            </>
          )}
          <div>
            <p className="text-xs text-ink-500">Coût annuel</p>
            <p className="font-medium">{euro(annual)}</p>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <label className="text-sm">
            <span className="label">Facturation</span>
            <select className="input" value={form.billing_frequency} onChange={(e) => setForm({ ...form, billing_frequency: e.target.value as Billing })}>
              {(Object.keys(BILLING_LABELS) as Billing[]).map((b) => (
                <option key={b} value={b}>{BILLING_LABELS[b]}</option>
              ))}
            </select>
          </label>
          <label className="text-sm">
            <span className="label">Montant par facture (€)</span>
            <input className="input text-right" inputMode="decimal" value={form.billing_amount} onChange={set('billing_amount')} placeholder="0,00" />
          </label>
          <label className="text-sm">
            <span className="label">Statut</span>
            <select className="input" value={form.status} onChange={set('status')}>
              {STATUSES.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
          </label>
          <label className="text-sm sm:col-span-3">
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

// ---------------------------------------------------------------------------
// Renouvellement manuel (sans tacite reconduction)
// ---------------------------------------------------------------------------
function RenewForm({ contract, onClose, onSaved }: { contract: Contract; onClose: () => void; onSaved: () => void }) {
  const [start, setStart] = useState(contract.end_date || todayIso());
  const [months, setMonths] = useState(String(contract.commitment_months || 12));
  const [amount, setAmount] = useState(contract.billing_amount === null ? '' : String(contract.billing_amount).replace('.', ','));
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const newEnd = start && Number(months) > 0 ? addMonths(start, Number(months)) : null;

  async function submit(e: FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError(null);
    try {
      await api(`/api/contracts/${contract.id}/renew`, { method: 'POST', body: JSON.stringify({ start_date: start, months: Number(months), billing_amount: amount }) });
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
      <form className="card w-full max-w-lg my-8 p-5 space-y-4" onClick={(e) => e.stopPropagation()} onSubmit={submit}>
        <div className="flex items-center justify-between">
          <h3 className="font-semibold text-ink-900">Renouveler « {contract.label} »</h3>
          <button type="button" className="btn-ghost p-1.5" onClick={onClose} aria-label="Fermer"><X className="w-4 h-4" /></button>
        </div>
        <p className="text-sm text-ink-600">Période actuelle : du {fr(contract.start_date)} au {fr(contract.end_date)}. Elle est conservée dans l'historique.</p>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <label className="text-sm">
            <span className="label">Nouveau début</span>
            <input className="input" type="date" required value={start} onChange={(e) => setStart(e.target.value)} />
          </label>
          <label className="text-sm">
            <span className="label">Durée (mois)</span>
            <input className="input" type="number" min={1} required value={months} onChange={(e) => setMonths(e.target.value)} />
          </label>
          <label className="text-sm">
            <span className="label">Montant par facture</span>
            <input className="input text-right" inputMode="decimal" value={amount} onChange={(e) => setAmount(e.target.value)} />
          </label>
        </div>
        <p className="text-sm">Nouvelle fin de contrat : <strong>{fr(newEnd)}</strong></p>
        {error && <p className="text-sm text-red-600">{error}</p>}
        <div className="flex justify-end gap-2">
          <button type="button" className="btn-ghost text-sm" onClick={onClose}>Annuler</button>
          <button className="btn-primary text-sm" disabled={saving}>{saving ? 'Renouvellement…' : 'Renouveler'}</button>
        </div>
      </form>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Décision pour l'échéance en cours (arrête les alertes de cette échéance)
// ---------------------------------------------------------------------------
function DecisionForm({ contract, onClose, onSaved }: { contract: Contract; onClose: () => void; onSaved: () => void }) {
  const tacit = contract.renewal_mode !== 'none';
  const [type, setType] = useState<'keep' | 'terminate' | 'renew_planned' | 'end'>(tacit ? 'keep' : 'renew_planned');
  const [effective, setEffective] = useState(contract.renewal_date || contract.cancellable_from || '');
  const [note, setNote] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  const options: { value: typeof type; title: string; text: string }[] = tacit
    ? [
        { value: 'keep', title: 'Laisser reconduire', text: `Le contrat sera reconduit le ${fr(contract.renewal_date)}. Les alertes s'arrêtent jusqu'à l'échéance suivante.` },
        { value: 'terminate', title: 'Résiliation envoyée', text: "Le contrat passe « En cours de résiliation », puis « Résilié » à la date d'effet. Plus d'alerte." },
      ]
    : [
        { value: 'renew_planned', title: 'Renouvellement prévu', text: 'Les alertes s’arrêtent. Utilisez ensuite « Renouveler » pour enregistrer la nouvelle période.' },
        { value: 'end', title: 'Ne pas renouveler', text: `Le contrat passera « Terminé » le ${fr(contract.end_date)}. Plus d'alerte.` },
      ];

  async function submit(e: FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError(null);
    try {
      await api(`/api/contracts/${contract.id}/decision`, {
        method: 'POST',
        body: JSON.stringify({ type, note, effective_date: type === 'terminate' ? effective : undefined }),
      });
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
      <form className="card w-full max-w-lg my-8 p-5 space-y-4" onClick={(e) => e.stopPropagation()} onSubmit={submit}>
        <div className="flex items-center justify-between">
          <h3 className="font-semibold text-ink-900">Décision : {contract.label}</h3>
          <button type="button" className="btn-ghost p-1.5" onClick={onClose} aria-label="Fermer"><X className="w-4 h-4" /></button>
        </div>
        <div className="space-y-2">
          {options.map((o) => (
            <label key={o.value} className={`flex gap-3 p-3 rounded-lg border cursor-pointer ${type === o.value ? 'border-elyade-400 bg-elyade-50/50' : 'border-ink-200'}`}>
              <input type="radio" className="mt-1" checked={type === o.value} onChange={() => setType(o.value)} />
              <span>
                <span className="font-medium text-sm">{o.title}</span>
                <span className="block text-xs text-ink-500">{o.text}</span>
              </span>
            </label>
          ))}
        </div>
        {type === 'terminate' && (
          <label className="text-sm block">
            <span className="label">Date d'effet de la résiliation</span>
            <input className="input" type="date" required value={effective} onChange={(e) => setEffective(e.target.value)} />
          </label>
        )}
        <label className="text-sm block">
          <span className="label">Commentaire (facultatif)</span>
          <input className="input" value={note} onChange={(e) => setNote(e.target.value)} placeholder="Ex. courrier recommandé envoyé le 14/10" />
        </label>
        {error && <p className="text-sm text-red-600">{error}</p>}
        <div className="flex justify-end gap-2">
          <button type="button" className="btn-ghost text-sm" onClick={onClose}>Annuler</button>
          <button className="btn-primary text-sm" disabled={saving}>{saving ? 'Enregistrement…' : 'Enregistrer la décision'}</button>
        </div>
      </form>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
export default function Contracts() {
  const [data, setData] = useState<{ fiscalYear: string; currentFiscalYear: string; contracts: Contract[] } | null>(null);
  const [fy, setFy] = useState<string | null>(null);
  const [suppliers, setSuppliers] = useState<Supplier[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [category, setCategory] = useState('');
  const [status, setStatus] = useState('en_cours');
  const [search, setSearch] = useState('');
  const [editing, setEditing] = useState<FormState | null>(null);
  const [renewing, setRenewing] = useState<Contract | null>(null);
  const [history, setHistory] = useState<Contract | null>(null);
  const [deciding, setDeciding] = useState<Contract | null>(null);

  async function load(year = fy) {
    try {
      const [list, supplierList, categoryList] = await Promise.all([
        api<{ fiscalYear: string; currentFiscalYear: string; contracts: Contract[] }>(`/api/contracts${year ? `?fy=${year}` : ''}`),
        api<Supplier[]>('/api/expense-suppliers'),
        api<Category[]>('/api/contract-categories'),
      ]);
      setData(list);
      setFy(list.fiscalYear);
      setSuppliers(supplierList);
      setCategories(categoryList);
      setError(null);
    } catch (err: any) {
      setError(err.message);
    }
  }

  useEffect(() => {
    void load(null);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const contracts = data?.contracts || [];
  const years = useMemo(() => {
    if (!data) return [];
    const current = Number(data.currentFiscalYear.slice(0, 4));
    return Array.from({ length: 6 }, (_, i) => current + 1 - i).map((y) => `${y}-${y + 1}`);
  }, [data]);
  const ongoing = (c: Contract) => c.status === 'Actif' || c.status === 'En cours de résiliation';
  const active = contracts.filter(ongoing);
  // Décisions restant à prendre (une décision enregistrée arrête les alertes de l'échéance).
  const soon = active
    .filter((c) => !c.decided && c.days_to_decision !== null && c.days_to_decision >= 0 && c.days_to_decision <= 90)
    .sort((a, b) => a.days_to_decision! - b.days_to_decision!);
  const fiscalTotal = contracts.reduce((s, c) => s + c.fiscal_cost, 0);
  const annualRunRate = active.reduce((s, c) => s + (c.annual_cost || 0), 0);
  const byCategory = useMemo(() => {
    const map = new Map<string, number>();
    for (const c of contracts) if (c.fiscal_cost) map.set(c.category || '—', (map.get(c.category || '—') || 0) + c.fiscal_cost);
    return [...map.entries()].map(([label, value]) => ({ label, value })).sort((a, b) => b.value - a.value);
  }, [contracts]);
  const maxCategory = Math.max(1, ...byCategory.map((c) => c.value));
  const categoryNames = [...new Set(contracts.map((c) => c.category).filter(Boolean) as string[])].sort((a, b) => a.localeCompare(b, 'fr'));

  const listed = contracts
    .filter((c) => (status === 'en_cours' ? ongoing(c) : !status || c.status === status))
    .filter((c) => !category || c.category === category)
    .filter((c) => {
      const q = search.trim().toLowerCase();
      return !q || [c.label, c.supplier, c.category, c.notes].some((v) => v?.toLowerCase().includes(q));
    })
    .sort((a, b) => (a.decision_date || '9999').localeCompare(b.decision_date || '9999'));

  async function remove(c: Contract) {
    if (!confirm(`Supprimer le contrat « ${c.label} » ?`)) return;
    try {
      await api(`/api/contracts/${c.id}`, { method: 'DELETE' });
      await load();
    } catch (err: any) {
      alert(err.message);
    }
  }

  if (!data && !error) return <div className="p-6 text-ink-500">Chargement…</div>;

  return (
    <div className="p-6 w-full max-w-[1600px] mx-auto space-y-5">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-xl font-semibold text-ink-900">Suivi des contrats</h1>
          <p className="text-sm text-ink-500">Échéances, préavis et coûts sur l'exercice (1er avril - 31 mars). Accès réservé au groupe Manager Informatique.</p>
        </div>
        <div className="flex items-center gap-2">
          <label className="text-sm flex items-center gap-2">
            Exercice
            <select className="input py-1.5 w-36" value={fy || ''} onChange={(e) => { setFy(e.target.value); void load(e.target.value); }}>
              {years.map((y) => (
                <option key={y} value={y}>{y}</option>
              ))}
            </select>
          </label>
          <button type="button" className="btn-primary text-sm" onClick={() => setEditing(toForm())}><Plus className="w-4 h-4" /> Nouveau contrat</button>
        </div>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="card p-4">
          <p className="text-xs uppercase tracking-wide text-ink-500">Coût sur l'exercice {fy}</p>
          <p className="text-2xl font-semibold text-ink-900 mt-1 tabular-nums">{euro(fiscalTotal)}</p>
          <p className="text-xs text-ink-500 mt-1">Échéances de facturation tombant dans l'exercice</p>
        </div>
        <div className="card p-4">
          <p className="text-xs uppercase tracking-wide text-ink-500">Coût annuel des contrats en cours</p>
          <p className="text-2xl font-semibold text-ink-900 mt-1 tabular-nums">{euro(annualRunRate)}</p>
          <p className="text-xs text-ink-500 mt-1">{active.length} contrat{active.length > 1 ? 's' : ''} en cours</p>
        </div>
        <div className="card p-4">
          <p className="text-xs uppercase tracking-wide text-ink-500">Décisions à prendre sous 90 jours</p>
          <p className="text-2xl font-semibold text-ink-900 mt-1">{soon.length}</p>
          <p className="text-xs text-ink-500 mt-1 truncate">{soon[0] ? `Prochaine : ${soon[0].label}, le ${fr(soon[0].decision_date)}` : 'Aucune'}</p>
        </div>
      </div>

      {soon.length > 0 && (
        <div className="card p-4">
          <h2 className="font-semibold text-ink-900 mb-2 flex items-center gap-2"><AlertTriangle className="w-4 h-4 text-amber-600" /> À décider bientôt</h2>
          <div className="space-y-1.5">
            {soon.map((c) => (
              <div key={c.id} className="flex flex-wrap items-center gap-2 text-sm">
                <DecisionBadge days={c.days_to_decision} />
                <span className="font-medium">{c.label}</span>
                <span className="text-ink-500">
                  {c.decision === 'renew' ? `fin le ${fr(c.end_date)} : à renouveler` : `à résilier avant le ${fr(c.termination_deadline)}, sinon reconduit le ${fr(c.renewal_date)}`} · {euro(c.annual_cost)} / an
                </span>
                <button type="button" className="btn-secondary text-xs" onClick={() => setDeciding(c)}>Décision…</button>
                {c.decision === 'renew' && (
                  <button type="button" className="btn-ghost text-xs" onClick={() => setRenewing(c)}><RotateCw className="w-3.5 h-3.5" /> Renouveler</button>
                )}
              </div>
            ))}
          </div>
          <p className="text-xs text-ink-500 mt-2">Un mail de rappel est envoyé à 90, 30 puis 7 jours de la date de décision.</p>
        </div>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-4 gap-4">
        <div className="card p-4">
          <h2 className="font-semibold text-ink-900 mb-3">Coût {fy} par catégorie</h2>
          <div className="space-y-2.5">
            {byCategory.length === 0 && <p className="text-sm text-ink-400">Aucun coût sur cet exercice.</p>}
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
            <select className="input py-1.5 w-52" value={status} onChange={(e) => setStatus(e.target.value)}>
              <option value="en_cours">En cours</option>
              <option value="">Tous les statuts</option>
              {STATUSES.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
            <select className="input py-1.5 w-48" value={category} onChange={(e) => setCategory(e.target.value)}>
              <option value="">Toutes catégories</option>
              {categoryNames.map((c) => (
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
                  <th className="text-left py-2 px-3 font-semibold">Décision</th>
                  <th className="text-right py-2 px-3 font-semibold">Facturation</th>
                  <th className="text-right py-2 px-3 font-semibold">Coût {fy}</th>
                  <th className="text-right py-2 px-3 font-semibold" title="Dépenses du fournisseur sur l'exercice (suivi des dépenses)">Dépensé</th>
                  <th className="py-2 px-3"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-ink-100">
                {listed.map((c) => (
                  <tr key={c.id} className="hover:bg-ink-50/60 align-top">
                    <td className="py-2 px-3">
                      <span className="font-medium text-ink-900">{c.label}</span>
                      <span className="block text-xs text-ink-500">{[c.supplier, c.category, c.status !== 'Actif' ? c.status : null].filter(Boolean).join(' · ')}</span>
                    </td>
                    <td className="py-2 px-3 text-xs">
                      {duration(c.commitment_months)} depuis le {fr(c.start_date)}
                      <span className="block text-ink-500">{RENEWAL_LABELS[c.renewal_mode]}{c.renewal_mode === 'custom' ? ` (${duration(c.renewal_months)})` : ''}</span>
                      <span className="block text-ink-500">{noticeText(c.notice_months)}</span>
                    </td>
                    <td className="py-2 px-3 text-xs whitespace-nowrap">
                      {c.renewal_mode === 'none' ? (
                        <>fin {fr(c.end_date)}</>
                      ) : c.cancellable_from ? (
                        <span className="text-ink-600">sans engagement</span>
                      ) : (
                        <>renouvellement {fr(c.renewal_date)}</>
                      )}
                    </td>
                    <td className="py-2 px-3 text-xs whitespace-nowrap">
                      {c.decision === 'terminate' && <>résilier avant le {fr(c.termination_deadline)} </>}
                      {c.decision === 'renew' && <>renouveler avant le {fr(c.end_date)} </>}
                      {c.cancellable_from && <>résiliable, fin au plus tôt {fr(c.cancellable_from)}</>}
                      {c.decided && c.decision_type ? (
                        <span className="block mt-1">
                          <span className="badge bg-emerald-50 text-emerald-800 border border-emerald-200">
                            ✓ {DECISION_LABELS[c.decision_type]}
                            {c.termination_effective ? `, effet le ${fr(c.termination_effective)}` : ''}
                          </span>
                          <span className="block text-ink-500" title={c.decision_note || undefined}>
                            {c.decision_by ? `${c.decision_by}, ` : ''}{c.decision_at ? new Date(c.decision_at).toLocaleDateString('fr-FR') : ''}
                            {c.decision_note ? ` · ${c.decision_note}` : ''}
                          </span>
                          <button
                            type="button"
                            className="text-ink-400 hover:text-red-600 underline"
                            onClick={async () => {
                              if (!confirm('Annuler cette décision ? Les alertes reprendront.')) return;
                              try {
                                await api(`/api/contracts/${c.id}/decision`, { method: 'DELETE' });
                                await load();
                              } catch (err: any) {
                                alert(err.message);
                              }
                            }}
                          >
                            annuler la décision
                          </button>
                        </span>
                      ) : (
                        <>
                          <DecisionBadge days={c.days_to_decision} />
                          {(c.decision_date || c.cancellable_from) && c.status === 'Actif' && (
                            <button type="button" className="block text-elyade-700 hover:underline mt-1" onClick={() => setDeciding(c)}>
                              Décision…
                            </button>
                          )}
                        </>
                      )}
                    </td>
                    <td className="py-2 px-3 text-right text-xs whitespace-nowrap">
                      {euro(c.billing_amount)}
                      <span className="block text-ink-500">{BILLING_LABELS[c.billing_frequency]}</span>
                    </td>
                    <td className="py-2 px-3 text-right tabular-nums">{euro(c.fiscal_cost)}</td>
                    <td className="py-2 px-3 text-right tabular-nums text-ink-600">{c.supplier_spent_fy === null ? '—' : euro(c.supplier_spent_fy)}</td>
                    <td className="py-2 px-3 whitespace-nowrap text-right">
                      {c.renewal_mode === 'none' && (
                        <button type="button" className="btn-ghost p-1.5" title="Renouveler" onClick={() => setRenewing(c)}><RotateCw className="w-4 h-4" /></button>
                      )}
                      {c.renewals.length > 0 && (
                        <button type="button" className="btn-ghost p-1.5" title="Historique des renouvellements" onClick={() => setHistory(c)}><History className="w-4 h-4" /></button>
                      )}
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
      {deciding && <DecisionForm contract={deciding} onClose={() => setDeciding(null)} onSaved={() => void load()} />}
      {renewing && <RenewForm contract={renewing} onClose={() => setRenewing(null)} onSaved={() => void load()} />}
      {history && (
        <div className="fixed inset-0 z-50 bg-ink-950/40 flex items-start justify-center p-4" onClick={() => setHistory(null)}>
          <div className="card w-full max-w-lg my-8 p-5" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-semibold text-ink-900">Renouvellements : {history.label}</h3>
              <button type="button" className="btn-ghost p-1.5" onClick={() => setHistory(null)} aria-label="Fermer"><X className="w-4 h-4" /></button>
            </div>
            <ul className="space-y-2 text-sm">
              {history.renewals.map((r, i) => (
                <li key={i} className="p-2 rounded border border-ink-100">
                  Période du {fr(r.previous_start)} au {fr(r.previous_end)} renouvelée à partir du {fr(r.new_start)} pour {duration(r.new_months)}
                  <span className="block text-xs text-ink-500">
                    le {new Date(r.renewed_at).toLocaleDateString('fr-FR')}{r.renewed_by ? ` par ${r.renewed_by}` : ''}
                  </span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      )}
    </div>
  );
}
