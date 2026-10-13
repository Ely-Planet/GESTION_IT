import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { ChevronDown, ChevronRight, Download, Pencil, Plus, Trash2, X } from 'lucide-react';

// Suivi des dépenses informatiques (groupe 🔐 Manager Informatique).
// Exercice d'avril à mars ; Trim 1 = avril-juin … Trim 4 = janvier-mars.

type Expense = {
  id: string;
  fiscal_year: string;
  month: number;
  supplier: string;
  family: string;
  category: string | null;
  subcategory: string | null;
  invoice_number: string | null;
  invoice_date: string | null;
  amount: number;
  structure: string | null;
  notes: string | null;
};

const MONTHS = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
const FISCAL_MONTHS = [4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3];
const STRUCTURES = ['ELYADE', 'ELYADE SERVICES IMMOBILIERS'];
const quarterOf = (month: number) => (month >= 4 && month <= 6 ? 1 : month >= 7 && month <= 9 ? 2 : month >= 10 ? 3 : 4);
const fiscalIndex = (month: number) => (month + 8) % 12; // avril = 0 … mars = 11
const QUARTER_MONTHS = ['avr.-juin', 'juil.-sept.', 'oct.-déc.', 'janv.-mars'];

function currentFiscalYear(date = new Date()) {
  const y = date.getFullYear();
  return date.getMonth() + 1 >= 4 ? `${y}-${y + 1}` : `${y - 1}-${y}`;
}
const previousFiscalYear = (fy: string) => {
  const start = Number(fy.slice(0, 4));
  return `${start - 1}-${start}`;
};

const euro = (value: number) => value.toLocaleString('fr-FR', { style: 'currency', currency: 'EUR' });
const euroShort = (value: number) =>
  Math.abs(value) >= 1000 ? `${(value / 1000).toLocaleString('fr-FR', { maximumFractionDigits: 1 })} k€` : euro(value);
const sum = (rows: Expense[]) => rows.reduce((total, row) => total + row.amount, 0);

async function api<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, { ...init, headers: { 'Content-Type': 'application/json' } });
  if (res.status === 204) return undefined as T;
  const json = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(json.error || 'Erreur');
  return json as T;
}

// ---------------------------------------------------------------------------
// Graphiques (SVG / HTML, une seule série : couleur ELYADE)
// ---------------------------------------------------------------------------
function QuarterChart({ values, previous }: { values: number[]; previous: number[] }) {
  const [hover, setHover] = useState<number | null>(null);
  const width = 480;
  const height = 220;
  const pad = { top: 16, right: 12, bottom: 34, left: 56 };
  const plotW = width - pad.left - pad.right;
  const plotH = height - pad.top - pad.bottom;
  const max = Math.max(1, ...values, ...previous);
  const min = Math.min(0, ...values);
  const y = (v: number) => pad.top + plotH - ((v - min) / (max - min)) * plotH;
  const band = plotW / 4;
  const barW = Math.min(44, band * 0.45);
  const ticks = [0, 0.5, 1].map((t) => min + (max - min) * t);

  return (
    <div className="relative">
      <svg viewBox={`0 0 ${width} ${height}`} className="w-full h-auto" role="img" aria-label="Dépenses par trimestre de l'exercice">
        {ticks.map((t) => (
          <g key={t}>
            <line x1={pad.left} x2={width - pad.right} y1={y(t)} y2={y(t)} stroke="#eceef1" />
            <text x={pad.left - 8} y={y(t) + 4} textAnchor="end" fontSize="11" fill="#8590a0">
              {euroShort(t)}
            </text>
          </g>
        ))}
        {values.map((value, i) => {
          const cx = pad.left + band * i + band / 2;
          const top = y(Math.max(value, 0));
          const h = Math.max(Math.abs(y(value) - y(0)), value === 0 ? 0 : 1);
          const prevY = y(Math.max(previous[i], 0));
          return (
            <g key={i}>
              {/* Zone de survol plus large que la barre. */}
              <rect x={cx - band / 2} y={pad.top} width={band} height={plotH} fill="transparent" onMouseEnter={() => setHover(i)} onMouseLeave={() => setHover(null)} />
              <rect
                x={cx - barW / 2}
                y={value >= 0 ? top : y(0)}
                width={barW}
                height={h}
                rx={4}
                fill="#ca0088"
                opacity={hover === null || hover === i ? 1 : 0.55}
                pointerEvents="none"
              />
              {/* Repère de l'exercice précédent. */}
              {previous[i] > 0 && (
                <line x1={cx - barW / 2 - 6} x2={cx + barW / 2 + 6} y1={prevY} y2={prevY} stroke="#525a6b" strokeWidth={2} strokeDasharray="4 3" pointerEvents="none" />
              )}
              <text x={cx} y={height - pad.bottom + 16} textAnchor="middle" fontSize="12" fill="#32373c">
                Trim {i + 1}
              </text>
              <text x={cx} y={height - pad.bottom + 29} textAnchor="middle" fontSize="10" fill="#8590a0">
                {QUARTER_MONTHS[i]}
              </text>
            </g>
          );
        })}
        <line x1={pad.left} x2={width - pad.right} y1={y(0)} y2={y(0)} stroke="#b0b8c2" />
      </svg>
      {hover !== null && (
        <div
          className="absolute z-10 pointer-events-none bg-white border border-ink-200 rounded-lg shadow-elevated px-3 py-2 text-xs"
          style={{ left: `${((pad.left + band * hover + band / 2) / width) * 100}%`, top: 0, transform: 'translateX(-50%)' }}
        >
          <p className="font-semibold text-ink-900">Trim {hover + 1} ({QUARTER_MONTHS[hover]})</p>
          <p className="text-ink-700">{euro(values[hover])}</p>
          <p className="text-ink-500">Exercice précédent : {euro(previous[hover])}</p>
        </div>
      )}
      <div className="flex items-center gap-4 text-xs text-ink-500 mt-1">
        <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm bg-elyade-600" /> Exercice sélectionné</span>
        <span className="flex items-center gap-1.5"><span className="w-4 border-t-2 border-dashed border-ink-600" /> Exercice précédent</span>
      </div>
    </div>
  );
}

function FamilyBars({ rows }: { rows: { label: string; value: number }[] }) {
  const max = Math.max(1, ...rows.map((r) => r.value));
  if (!rows.length) return <p className="text-sm text-ink-400">Aucune dépense.</p>;
  return (
    <div className="space-y-2.5">
      {rows.map((row) => (
        <div key={row.label} title={`${row.label} : ${euro(row.value)}`}>
          <div className="flex justify-between text-xs mb-1">
            <span className="text-ink-700 truncate pr-2">{row.label}</span>
            <span className="text-ink-900 font-medium tabular-nums">{euro(row.value)}</span>
          </div>
          <div className="h-2.5 rounded-full bg-ink-100">
            <div className="h-2.5 rounded-full bg-elyade-600" style={{ width: `${Math.max(0, (row.value / max) * 100)}%` }} />
          </div>
        </div>
      ))}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Tableau croisé Famille > Catégorie > Sous-catégorie × trimestre
// ---------------------------------------------------------------------------
type PivotNode = { key: string; label: string; q: number[]; total: number; children: PivotNode[] };

function buildPivot(rows: Expense[]): PivotNode[] {
  const levels: ((r: Expense) => string)[] = [(r) => r.family, (r) => r.category || '—', (r) => r.subcategory || '—'];
  const build = (items: Expense[], depth: number, prefix: string): PivotNode[] => {
    const groups = new Map<string, Expense[]>();
    for (const item of items) {
      const k = levels[depth](item);
      groups.set(k, [...(groups.get(k) || []), item]);
    }
    return [...groups.entries()]
      .map(([label, group]) => {
        const q = [1, 2, 3, 4].map((n) => sum(group.filter((r) => quarterOf(r.month) === n)));
        return {
          key: `${prefix}/${label}`,
          label,
          q,
          total: sum(group),
          children: depth < levels.length - 1 ? build(group, depth + 1, `${prefix}/${label}`) : [],
        };
      })
      .sort((a, b) => b.total - a.total);
  };
  return build(rows, 0, '');
}

function PivotTable({ rows }: { rows: Expense[] }) {
  const [open, setOpen] = useState<Set<string>>(new Set());
  const pivot = useMemo(() => buildPivot(rows), [rows]);
  const totals = [1, 2, 3, 4].map((n) => sum(rows.filter((r) => quarterOf(r.month) === n)));
  const toggle = (key: string) => {
    const next = new Set(open);
    if (next.has(key)) next.delete(key);
    else next.add(key);
    setOpen(next);
  };
  const cell = (v: number) => (v ? euro(v) : '');
  const render = (nodes: PivotNode[], depth: number): JSX.Element[] =>
    nodes.flatMap((node) => [
      <tr key={node.key} className={depth === 0 ? 'bg-white font-medium' : 'bg-ink-50/40'}>
        <td style={{ paddingLeft: 12 + depth * 20 }} className="py-2 pr-3">
          {node.children.length ? (
            <button type="button" className="inline-flex items-center gap-1 text-left" onClick={() => toggle(node.key)}>
              {open.has(node.key) ? <ChevronDown className="w-3.5 h-3.5" /> : <ChevronRight className="w-3.5 h-3.5" />}
              {node.label}
            </button>
          ) : (
            <span className="pl-[18px]">{node.label}</span>
          )}
        </td>
        {node.q.map((v, i) => (
          <td key={i} className="py-2 px-3 text-right tabular-nums">{cell(v)}</td>
        ))}
        <td className="py-2 px-3 text-right tabular-nums font-semibold">{euro(node.total)}</td>
      </tr>,
      ...(open.has(node.key) ? render(node.children, depth + 1) : []),
    ]);

  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="text-xs uppercase tracking-wide text-ink-500 bg-ink-50 border-b border-ink-100">
            <th className="text-left py-2 px-3 font-semibold">Famille / catégorie / sous-catégorie</th>
            {[1, 2, 3, 4].map((n) => (
              <th key={n} className="text-right py-2 px-3 font-semibold">Trim {n}</th>
            ))}
            <th className="text-right py-2 px-3 font-semibold">Total</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-ink-100">
          {render(pivot, 0)}
          <tr className="font-semibold border-t-2 border-ink-200">
            <td className="py-2 px-3">Total</td>
            {totals.map((v, i) => (
              <td key={i} className="py-2 px-3 text-right tabular-nums">{cell(v)}</td>
            ))}
            <td className="py-2 px-3 text-right tabular-nums">{euro(sum(rows))}</td>
          </tr>
        </tbody>
      </table>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Formulaire d'une dépense
// ---------------------------------------------------------------------------
type FormState = Omit<Expense, 'id' | 'amount'> & { id?: string; amount: string };

function ExpenseForm({
  initial,
  years,
  suggestions,
  onClose,
  onSaved,
}: {
  initial: FormState;
  years: string[];
  suggestions: Record<'supplier' | 'family' | 'category' | 'subcategory', string[]>;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [form, setForm] = useState<FormState>(initial);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const set = (key: keyof FormState) => (e: { target: { value: string } }) => setForm({ ...form, [key]: e.target.value });

  async function submit(e: FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError(null);
    try {
      await api(form.id ? `/api/expenses/${form.id}` : '/api/expenses', { method: form.id ? 'PUT' : 'POST', body: JSON.stringify(form) });
      onSaved();
      onClose();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  }

  const list = (id: string, values: string[]) => (
    <datalist id={id}>
      {values.map((v) => (
        <option key={v} value={v} />
      ))}
    </datalist>
  );

  return (
    <div className="fixed inset-0 z-50 bg-ink-950/40 flex items-start justify-center overflow-y-auto p-4" onClick={onClose}>
      <form className="card w-full max-w-2xl my-8 p-5 space-y-3" onClick={(e) => e.stopPropagation()} onSubmit={submit}>
        <div className="flex items-center justify-between">
          <h3 className="font-semibold text-ink-900">{form.id ? 'Modifier la dépense' : 'Nouvelle dépense'}</h3>
          <button type="button" className="btn-ghost p-1.5" onClick={onClose} aria-label="Fermer"><X className="w-4 h-4" /></button>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <label className="text-sm">
            <span className="label">Exercice</span>
            <input className="input" list="exp-years" required value={form.fiscal_year} onChange={set('fiscal_year')} placeholder="2025-2026" />
            {list('exp-years', years)}
          </label>
          <label className="text-sm">
            <span className="label">Mois</span>
            <select className="input" value={form.month} onChange={(e) => setForm({ ...form, month: Number(e.target.value) })}>
              {FISCAL_MONTHS.map((m) => (
                <option key={m} value={m}>{MONTHS[m - 1]} (Trim {quarterOf(m)})</option>
              ))}
            </select>
          </label>
          <label className="text-sm">
            <span className="label">Montant (€ TTC, négatif pour un avoir)</span>
            <input className="input text-right" required inputMode="decimal" value={form.amount} onChange={set('amount')} placeholder="0,00" />
          </label>
          <label className="text-sm sm:col-span-2">
            <span className="label">Fournisseur</span>
            <input className="input" list="exp-suppliers" required value={form.supplier} onChange={set('supplier')} />
            {list('exp-suppliers', suggestions.supplier)}
          </label>
          <label className="text-sm">
            <span className="label">Structure</span>
            <select className="input" value={form.structure || ''} onChange={set('structure')}>
              {STRUCTURES.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
          </label>
          <label className="text-sm">
            <span className="label">Famille</span>
            <input className="input" list="exp-families" required value={form.family} onChange={set('family')} />
            {list('exp-families', suggestions.family)}
          </label>
          <label className="text-sm">
            <span className="label">Catégorie</span>
            <input className="input" list="exp-categories" value={form.category || ''} onChange={set('category')} />
            {list('exp-categories', suggestions.category)}
          </label>
          <label className="text-sm">
            <span className="label">Sous-catégorie</span>
            <input className="input" list="exp-subcategories" value={form.subcategory || ''} onChange={set('subcategory')} />
            {list('exp-subcategories', suggestions.subcategory)}
          </label>
          <label className="text-sm">
            <span className="label">N° de facture</span>
            <input className="input" value={form.invoice_number || ''} onChange={set('invoice_number')} />
          </label>
          <label className="text-sm">
            <span className="label">Date de facture</span>
            <input className="input" type="date" value={form.invoice_date || ''} onChange={set('invoice_date')} />
          </label>
          <label className="text-sm sm:col-span-3">
            <span className="label">Commentaire</span>
            <input className="input" value={form.notes || ''} onChange={set('notes')} />
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
// Page
// ---------------------------------------------------------------------------
export default function Expenses() {
  const [all, setAll] = useState<Expense[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [year, setYear] = useState(currentFiscalYear());
  const [structure, setStructure] = useState('');
  const [family, setFamily] = useState('');
  const [search, setSearch] = useState('');
  const [editing, setEditing] = useState<FormState | null>(null);

  async function load() {
    try {
      setAll(await api<Expense[]>('/api/expenses'));
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

  const years = useMemo(() => {
    const set = new Set(all.map((e) => e.fiscal_year));
    set.add(currentFiscalYear());
    return [...set].sort().reverse();
  }, [all]);
  const families = useMemo(() => [...new Set(all.map((e) => e.family))].sort((a, b) => a.localeCompare(b, 'fr')), [all]);
  const suggestions = useMemo(() => {
    const distinct = (pick: (e: Expense) => string | null) =>
      [...new Set(all.map(pick).filter(Boolean) as string[])].sort((a, b) => a.localeCompare(b, 'fr'));
    return { supplier: distinct((e) => e.supplier), family: distinct((e) => e.family), category: distinct((e) => e.category), subcategory: distinct((e) => e.subcategory) };
  }, [all]);

  const matchesFilters = (e: Expense) => (!structure || e.structure === structure) && (!family || e.family === family);
  const rows = useMemo(() => all.filter((e) => e.fiscal_year === year && matchesFilters(e)), [all, year, structure, family]);
  const previousRows = useMemo(() => all.filter((e) => e.fiscal_year === previousFiscalYear(year) && matchesFilters(e)), [all, year, structure, family]);
  const quarterTotals = [1, 2, 3, 4].map((n) => sum(rows.filter((r) => quarterOf(r.month) === n)));
  const previousQuarterTotals = [1, 2, 3, 4].map((n) => sum(previousRows.filter((r) => quarterOf(r.month) === n)));

  // Comparaison à période égale : mêmes mois écoulés de l'exercice précédent.
  const isCurrent = year === currentFiscalYear();
  const elapsed = isCurrent ? fiscalIndex(new Date().getMonth() + 1) : 11;
  const previousSamePeriod = sum(previousRows.filter((r) => fiscalIndex(r.month) <= elapsed));
  const total = sum(rows);
  const delta = previousSamePeriod ? ((total - previousSamePeriod) / Math.abs(previousSamePeriod)) * 100 : null;

  const byFamily = useMemo(() => {
    const map = new Map<string, number>();
    for (const r of rows) map.set(r.family, (map.get(r.family) || 0) + r.amount);
    return [...map.entries()].map(([label, value]) => ({ label, value })).sort((a, b) => b.value - a.value);
  }, [rows]);
  const bySupplier = useMemo(() => {
    const map = new Map<string, { value: number; count: number }>();
    for (const r of rows) {
      const current = map.get(r.supplier) || { value: 0, count: 0 };
      map.set(r.supplier, { value: current.value + r.amount, count: current.count + 1 });
    }
    return [...map.entries()].map(([label, v]) => ({ label, ...v })).sort((a, b) => b.value - a.value);
  }, [rows]);

  const listed = useMemo(() => {
    const q = search.trim().toLowerCase();
    return rows
      .filter((r) => !q || [r.supplier, r.family, r.category, r.subcategory, r.invoice_number, r.notes].some((v) => v?.toLowerCase().includes(q)))
      .sort((a, b) => fiscalIndex(b.month) - fiscalIndex(a.month) || a.supplier.localeCompare(b.supplier, 'fr'));
  }, [rows, search]);

  function newExpense() {
    const month = new Date().getMonth() + 1;
    setEditing({
      fiscal_year: year,
      month: year === currentFiscalYear() ? month : 4,
      supplier: '',
      family: family || '',
      category: '',
      subcategory: '',
      invoice_number: '',
      invoice_date: '',
      amount: '',
      structure: structure || 'ELYADE',
      notes: '',
    });
  }

  async function remove(expense: Expense) {
    if (!confirm(`Supprimer la dépense ${expense.supplier} de ${euro(expense.amount)} ?`)) return;
    try {
      await api(`/api/expenses/${expense.id}`, { method: 'DELETE' });
      await load();
    } catch (err: any) {
      alert(err.message);
    }
  }

  // Export CSV (séparateur « ; », lisible directement par Excel).
  function exportCsv() {
    const head = ['Année', 'Trim', 'Mois', 'Fournisseur', 'Famille', 'Catégorie', 'Sous-Catégorie', 'N° Facture', 'Date facture', 'Prix', 'Structure', 'Commentaire'];
    const esc = (v: unknown) => `"${String(v ?? '').replace(/"/g, '""')}"`;
    const lines = listed.map((r) =>
      [r.fiscal_year, `Trim ${quarterOf(r.month)}`, `${String(r.month).padStart(2, '0')}-${MONTHS[r.month - 1]}`, r.supplier, r.family, r.category, r.subcategory,
        r.invoice_number, r.invoice_date, r.amount.toFixed(2).replace('.', ','), r.structure, r.notes].map(esc).join(';')
    );
    const blob = new Blob(['﻿' + [head.map(esc).join(';'), ...lines].join('\r\n')], { type: 'text/csv;charset=utf-8' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `Suivi des dépenses ${year}.csv`;
    link.click();
    URL.revokeObjectURL(link.href);
  }

  if (loading) return <div className="p-6 text-ink-500">Chargement…</div>;

  return (
    <div className="p-6 w-full max-w-[1600px] mx-auto space-y-5">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-xl font-semibold text-ink-900">Suivi des dépenses</h1>
          <p className="text-sm text-ink-500">Dépenses informatiques par exercice (avril à mars). Accès réservé au groupe Manager Informatique.</p>
        </div>
        <div className="flex gap-2">
          <button type="button" className="btn-secondary text-sm" onClick={exportCsv}><Download className="w-4 h-4" /> Exporter (Excel)</button>
          <button type="button" className="btn-primary text-sm" onClick={newExpense}><Plus className="w-4 h-4" /> Nouvelle dépense</button>
        </div>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}

      {/* Filtres : une seule ligne au-dessus des graphiques. */}
      <div className="card p-3 flex flex-wrap items-center gap-3">
        <label className="text-sm flex items-center gap-2">
          Exercice
          <select className="input py-1.5 w-36" value={year} onChange={(e) => setYear(e.target.value)}>
            {years.map((y) => (
              <option key={y} value={y}>{y}</option>
            ))}
          </select>
        </label>
        <label className="text-sm flex items-center gap-2">
          Structure
          <select className="input py-1.5 w-64" value={structure} onChange={(e) => setStructure(e.target.value)}>
            <option value="">Toutes</option>
            {STRUCTURES.map((s) => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
        </label>
        <label className="text-sm flex items-center gap-2">
          Famille
          <select className="input py-1.5 w-64" value={family} onChange={(e) => setFamily(e.target.value)}>
            <option value="">Toutes</option>
            {families.map((f) => (
              <option key={f} value={f}>{f}</option>
            ))}
          </select>
        </label>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="card p-4">
          <p className="text-xs uppercase tracking-wide text-ink-500">Total {year}</p>
          <p className="text-2xl font-semibold text-ink-900 mt-1 tabular-nums">{euro(total)}</p>
          <p className="text-xs text-ink-500 mt-1">{rows.length} ligne{rows.length > 1 ? 's' : ''}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs uppercase tracking-wide text-ink-500">{isCurrent ? 'Même période, exercice précédent' : `Exercice ${previousFiscalYear(year)}`}</p>
          <p className="text-2xl font-semibold text-ink-900 mt-1 tabular-nums">{euro(previousSamePeriod)}</p>
          {delta !== null && (
            <p className="text-xs text-ink-600 mt-1">
              {delta >= 0 ? '▲' : '▼'} {Math.abs(delta).toLocaleString('fr-FR', { maximumFractionDigits: 1 })} % {delta >= 0 ? 'de plus' : 'de moins'} cette année
            </p>
          )}
        </div>
        <div className="card p-4">
          <p className="text-xs uppercase tracking-wide text-ink-500">Premier poste</p>
          <p className="text-lg font-semibold text-ink-900 mt-1 truncate">{byFamily[0]?.label || '—'}</p>
          <p className="text-xs text-ink-500 mt-1">
            {byFamily[0] ? `${euro(byFamily[0].value)}${total ? ` · ${Math.round((byFamily[0].value / total) * 100)} % du total` : ''}` : ''}
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-5 gap-4">
        <div className="card p-4 lg:col-span-3">
          <h2 className="font-semibold text-ink-900 mb-3">Dépenses par trimestre</h2>
          <QuarterChart values={quarterTotals} previous={previousQuarterTotals} />
        </div>
        <div className="card p-4 lg:col-span-2">
          <h2 className="font-semibold text-ink-900 mb-3">Par famille</h2>
          <FamilyBars rows={byFamily} />
        </div>
      </div>

      <div className="card p-4">
        <h2 className="font-semibold text-ink-900 mb-3">Tableau de bord {year}</h2>
        <PivotTable rows={rows} />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-4">
        <div className="card p-4">
          <h2 className="font-semibold text-ink-900 mb-3">Fournisseurs</h2>
          <div className="max-h-[480px] overflow-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-xs uppercase tracking-wide text-ink-500 bg-ink-50 border-b border-ink-100">
                  <th className="text-left py-2 px-3 font-semibold">Fournisseur</th>
                  <th className="text-right py-2 px-3 font-semibold">Lignes</th>
                  <th className="text-right py-2 px-3 font-semibold">Total</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-ink-100">
                {bySupplier.map((s) => (
                  <tr key={s.label}>
                    <td className="py-2 px-3">
                      <button type="button" className="text-left hover:text-elyade-700" onClick={() => setSearch(s.label)}>{s.label}</button>
                    </td>
                    <td className="py-2 px-3 text-right tabular-nums text-ink-500">{s.count}</td>
                    <td className="py-2 px-3 text-right tabular-nums">{euro(s.value)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div className="card p-4 xl:col-span-2">
          <div className="flex flex-wrap items-center justify-between gap-2 mb-3">
            <h2 className="font-semibold text-ink-900">Dépenses ({listed.length})</h2>
            <div className="flex items-center gap-2">
              <input className="input py-1.5 w-64" placeholder="Rechercher (fournisseur, facture…)" value={search} onChange={(e) => setSearch(e.target.value)} />
              {search && <button type="button" className="btn-ghost text-xs" onClick={() => setSearch('')}>Effacer</button>}
            </div>
          </div>
          <div className="max-h-[480px] overflow-auto">
            <table className="w-full text-sm">
              <thead className="sticky top-0">
                <tr className="text-xs uppercase tracking-wide text-ink-500 bg-ink-50 border-b border-ink-100">
                  <th className="text-left py-2 px-3 font-semibold">Mois</th>
                  <th className="text-left py-2 px-3 font-semibold">Fournisseur</th>
                  <th className="text-left py-2 px-3 font-semibold">Famille / catégorie</th>
                  <th className="text-left py-2 px-3 font-semibold">Facture</th>
                  <th className="text-left py-2 px-3 font-semibold">Structure</th>
                  <th className="text-right py-2 px-3 font-semibold">Montant</th>
                  <th className="py-2 px-3"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-ink-100">
                {listed.map((r) => (
                  <tr key={r.id} className="hover:bg-ink-50/60">
                    <td className="py-2 px-3 whitespace-nowrap">{MONTHS[r.month - 1]} <span className="text-xs text-ink-400">T{quarterOf(r.month)}</span></td>
                    <td className="py-2 px-3">{r.supplier}</td>
                    <td className="py-2 px-3">
                      {r.family}
                      <span className="block text-xs text-ink-500">{[r.category, r.subcategory].filter(Boolean).join(' · ')}</span>
                    </td>
                    <td className="py-2 px-3 text-xs">
                      {r.invoice_number || '—'}
                      {r.invoice_date && <span className="block text-ink-500">{new Date(r.invoice_date).toLocaleDateString('fr-FR')}</span>}
                    </td>
                    <td className="py-2 px-3 text-xs text-ink-600">{r.structure === 'ELYADE SERVICES IMMOBILIERS' ? 'ESI' : r.structure}</td>
                    <td className={`py-2 px-3 text-right tabular-nums ${r.amount < 0 ? 'text-ink-500' : ''}`}>{euro(r.amount)}</td>
                    <td className="py-2 px-3 whitespace-nowrap text-right">
                      <button
                        type="button"
                        className="btn-ghost p-1.5"
                        title="Modifier"
                        onClick={() => setEditing({ ...r, amount: String(r.amount).replace('.', ',') })}
                      >
                        <Pencil className="w-4 h-4" />
                      </button>
                      <button type="button" className="btn-ghost p-1.5 text-ink-400 hover:text-red-600" title="Supprimer" onClick={() => void remove(r)}>
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
                {listed.length === 0 && (
                  <tr>
                    <td colSpan={7} className="py-6 text-center text-ink-400">Aucune dépense.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {editing && (
        <ExpenseForm initial={editing} years={years} suggestions={suggestions} onClose={() => setEditing(null)} onSaved={() => void load()} />
      )}
    </div>
  );
}
