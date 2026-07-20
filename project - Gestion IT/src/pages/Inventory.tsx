import { useMemo, useRef, useState, type FormEvent } from 'react';
import { Laptop, Plus, X, Filter, RotateCcw, RefreshCw, Trash2, Upload, FileSpreadsheet, CheckCircle2 } from 'lucide-react';
import { useData } from '../hooks/useData';
import { supabase } from '../lib/supabase';
import { logAudit } from '../lib/audit';
import { useAuth } from '../context/AuthContext';
import { formatFrDate, HARDWARE_STATUS, statusLabel } from '../lib/format';
import type { HardwareItem } from '../lib/supabase';

export default function Inventory() {
  const data = useData();
  const { profile } = useAuth();
  const [catFilter, setCatFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [showForm, setShowForm] = useState(false);
  const [showImport, setShowImport] = useState(false);

  const filtered = useMemo(
    () =>
      data.hardware.filter(
        (h) =>
          (catFilter === 'all' || h.category_id === catFilter) &&
          (statusFilter === 'all' || h.status === statusFilter),
      ),
    [data.hardware, catFilter, statusFilter],
  );

  const catLabel = useMemo(() => {
    const m = new Map<string, string>();
    for (const c of data.hardwareCategories) m.set(c.id, c.label);
    return m;
  }, [data.hardwareCategories]);

  async function changeStatus(h: HardwareItem, status: HardwareItem['status']) {
    const { error } = await supabase.from('hardware_items').update({ status }).eq('id', h.id);
    if (error) { alert(error.message); return; }
    await logAudit('update', 'hardware', h.id, { status, from: h.status }, profile?.display_name);
    data.reload();
  }

  async function removeItem(h: HardwareItem) {
    if (!confirm(`Supprimer définitivement cet équipement (${h.serial_number || h.reference || h.id}) ?`)) return;
    const { error } = await supabase.from('hardware_items').delete().eq('id', h.id);
    if (error) { alert(error.message); return; }
    await logAudit('delete', 'hardware', h.id, { serial: h.serial_number }, profile?.display_name);
    data.reload();
  }

  return (
    <div className="p-6 lg:p-8 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <h1 className="text-2xl font-bold text-ink-900">Inventaire matériel</h1>
          <p className="text-sm text-ink-500 mt-1">
            PC, téléphones, casques, tablettes… gérés via Intune et Atera
          </p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => setShowImport(true)} className="btn-secondary">
            <Upload className="w-4 h-4" />
            Importer (CSV/Excel)
          </button>
          <button onClick={() => setShowForm(true)} className="btn-primary">
            <Plus className="w-4 h-4" />
            Ajouter du matériel
          </button>
        </div>
      </div>

      <div className="flex flex-wrap items-center gap-2 mb-4">
        <Filter className="w-4 h-4 text-ink-400" />
        <select className="input w-auto" value={catFilter} onChange={(e) => setCatFilter(e.target.value)}>
          <option value="all">Toutes catégories</option>
          {data.hardwareCategories.map((c) => <option key={c.id} value={c.id}>{c.label}</option>)}
        </select>
        <select className="input w-auto" value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
          <option value="all">Tous statuts</option>
          {Object.entries(HARDWARE_STATUS).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
        </select>
        <span className="text-sm text-ink-500 ml-2">{filtered.length} équipement(s)</span>
      </div>

      <div className="card overflow-hidden">
        {data.loading ? (
          <p className="p-8 text-center text-ink-500">Chargement…</p>
        ) : filtered.length === 0 ? (
          <p className="p-8 text-center text-ink-500">Aucun équipement. Ajoutez-en ou ajustez les filtres.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="table-base">
              <thead>
                <tr>
                  <th>Catégorie</th>
                  <th>Référence</th>
                  <th>Numéro de série</th>
                  <th>Marque / Modèle</th>
                  <th>Gestion</th>
                  <th>Statut</th>
                  <th>Achat</th>
                  <th className="text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((h) => {
                  const cat = data.hardwareCategories.find((c) => c.id === h.category_id);
                  return (
                    <tr key={h.id}>
                      <td className="font-medium">{catLabel.get(h.category_id) ?? '—'}</td>
                      <td>{h.reference ?? '—'}</td>
                      <td className="font-mono text-xs">{h.serial_number ?? '—'}</td>
                      <td>{[h.brand, h.model].filter(Boolean).join(' ') || '—'}</td>
                      <td>
                        {cat?.managed_by ? (
                          <span className="badge bg-blue-50 text-blue-700">{cat.managed_by}</span>
                        ) : '—'}
                      </td>
                      <td><HwStatusBadge status={h.status} /></td>
                      <td>{formatFrDate(h.purchase_date)}</td>
                      <td>
                        <div className="flex justify-end gap-1">
                          {h.status === 'assigned' && (
                            <button title="Lancer réinstallation" onClick={() => changeStatus(h, 'being_reinstalled')} className="btn-ghost p-1.5 text-amber-600">
                              <RefreshCw className="w-4 h-4" />
                            </button>
                          )}
                          {h.status === 'being_reinstalled' && (
                            <button title="Remettre en stock" onClick={() => changeStatus(h, 'in_stock')} className="btn-ghost p-1.5 text-green-600">
                              <RotateCcw className="w-4 h-4" />
                            </button>
                          )}
                          {h.status !== 'retired' && h.status !== 'defective' && (
                            <button title="Réformer" onClick={() => changeStatus(h, 'retired')} className="btn-ghost p-1.5 text-ink-500">
                              <Trash2 className="w-4 h-4" />
                            </button>
                          )}
                          <button title="Supprimer" onClick={() => removeItem(h)} className="btn-ghost p-1.5 text-red-500">
                            <X className="w-4 h-4" />
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
      </div>

      {showForm && (
        <HardwareForm onClose={() => setShowForm(false)} onSaved={() => { setShowForm(false); data.reload(); }} />
      )}
      {showImport && (
        <ImportModal onClose={() => setShowImport(false)} onSaved={() => { setShowImport(false); data.reload(); }} />
      )}
    </div>
  );
}

function parseCSV(text: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [];
  let field = '';
  let inQuotes = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (inQuotes) {
      if (ch === '"') {
        if (text[i + 1] === '"') { field += '"'; i++; }
        else inQuotes = false;
      } else field += ch;
    } else {
      if (ch === '"') inQuotes = true;
      else if (ch === ',' || ch === ';' || ch === '\t') { row.push(field); field = ''; }
      else if (ch === '\n' || ch === '\r') {
        row.push(field); field = '';
        if (row.some((c) => c.trim())) rows.push(row);
        row = [];
        if (ch === '\r' && text[i + 1] === '\n') i++;
      } else field += ch;
    }
  }
  if (field || row.some((c) => c.trim())) { row.push(field); rows.push(row); }
  return rows;
}

const STATUS_MAP: Record<string, HardwareItem['status']> = {
  'en stock': 'in_stock', 'stock': 'in_stock', 'in stock': 'in_stock', 'in_stock': 'in_stock', 'disponible': 'in_stock',
  'attribue': 'assigned', 'attribué': 'assigned', 'assigned': 'assigned', 'affecte': 'assigned',
  'reinstallation': 'being_reinstalled', 'réinstallation': 'being_reinstalled', 'being_reinstalled': 'being_reinstalled',
  'reforme': 'retired', 'réformé': 'retired', 'retired': 'retired',
  'defectueux': 'defective', 'défectueux': 'defective', 'defective': 'defective',
};

function ImportModal({ onClose, onSaved }: { onClose: () => void; onSaved: () => void }) {
  const data = useData();
  const { profile } = useAuth();
  const fileRef = useRef<HTMLInputElement>(null);
  const [rows, setRows] = useState<Record<string, string>[]>([]);
  const [headers, setHeaders] = useState<string[]>([]);
  const [mapping, setMapping] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const [result, setResult] = useState<{ ok: number; skipped: number } | null>(null);
  const [error, setError] = useState<string | null>(null);

  const catByLabel = useMemo(() => {
    const m = new Map<string, string>();
    for (const c of data.hardwareCategories) {
      m.set(c.label.toLowerCase(), c.id);
      m.set(c.code.toLowerCase(), c.id);
    }
    return m;
  }, [data.hardwareCategories]);

  const FIELDS = ['category', 'reference', 'serial_number', 'brand', 'model', 'status', 'intune_device_id', 'atera_ticket_id', 'purchase_date', 'notes'];

  function handleFile(file: File) {
    setError(null);
    setResult(null);
    const reader = new FileReader();
    reader.onload = () => {
      const text = String(reader.result ?? '');
      const parsed = parseCSV(text);
      if (parsed.length < 2) { setError('Fichier vide ou en-tête manquant.'); return; }
      const hdrs = parsed[0].map((h) => h.trim());
      const dataRows = parsed.slice(1).map((r) => {
        const obj: Record<string, string> = {};
        hdrs.forEach((h, i) => { obj[h] = (r[i] ?? '').trim(); });
        return obj;
      });
      setHeaders(hdrs);
      setRows(dataRows);
      // auto-map headers
      const auto: Record<string, string> = {};
      for (const f of FIELDS) {
        const match = hdrs.find((h) => h.toLowerCase().includes(f) || (f === 'category' && (h.toLowerCase().includes('categorie') || h.toLowerCase().includes('catégorie'))));
        if (match) auto[f] = match;
      }
      setMapping(auto);
    };
    reader.onerror = () => setError('Lecture du fichier échouée.');
    reader.readAsText(file);
  }

  async function doImport() {
    setBusy(true);
    setError(null);
    let ok = 0, skipped = 0;
    try {
      const batchSize = 100;
      const batch: Record<string, unknown>[] = [];
      for (const r of rows) {
        const catRaw = (mapping.category ? r[mapping.category] : '') ?? '';
        const categoryId = catByLabel.get(catRaw.toLowerCase());
        if (!categoryId) { skipped++; continue; }
        const statusRaw = (mapping.status ? r[mapping.status] : 'in_stock') ?? 'in stock';
        const status = STATUS_MAP[statusRaw.toLowerCase()] ?? 'in_stock';
        batch.push({
          category_id: categoryId,
          reference: mapping.reference ? r[mapping.reference] || null : null,
          serial_number: mapping.serial_number ? r[mapping.serial_number] || null : null,
          brand: mapping.brand ? r[mapping.brand] || null : null,
          model: mapping.model ? r[mapping.model] || null : null,
          status,
          intune_device_id: mapping.intune_device_id ? r[mapping.intune_device_id] || null : null,
          atera_ticket_id: mapping.atera_ticket_id ? r[mapping.atera_ticket_id] || null : null,
          purchase_date: mapping.purchase_date ? r[mapping.purchase_date] || null : null,
          notes: mapping.notes ? r[mapping.notes] || null : null,
        });
        if (batch.length >= batchSize) {
          const { error } = await supabase.from('hardware_items').insert(batch);
          if (error) throw error;
          ok += batch.length;
          batch.length = 0;
        }
      }
      if (batch.length > 0) {
        const { error } = await supabase.from('hardware_items').insert(batch);
        if (error) throw error;
        ok += batch.length;
      }
      await logAudit('import', 'hardware', null, { ok, skipped }, profile?.display_name);
      setResult({ ok, skipped });
      if (ok > 0) setTimeout(() => onSaved(), 1200);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Erreur');
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center z-50 p-4" onClick={onClose}>
      <div className="card w-full max-w-2xl max-h-[90vh] overflow-auto" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-5 py-4 border-b border-ink-100 sticky top-0 bg-white rounded-t-xl">
          <h2 className="text-lg font-semibold text-ink-900 flex items-center gap-2">
            <FileSpreadsheet className="w-5 h-5 text-elyade-600" /> Importer un inventaire
          </h2>
          <button onClick={onClose} className="btn-ghost p-1.5"><X className="w-5 h-5" /></button>
        </div>
        <div className="p-5 space-y-4">
          {rows.length === 0 ? (
            <>
              <div
                onClick={() => fileRef.current?.click()}
                className="border-2 border-dashed border-ink-200 rounded-xl p-8 text-center cursor-pointer hover:border-elyade-400 hover:bg-elyade-50/30 transition"
              >
                <Upload className="w-8 h-8 text-ink-400 mx-auto mb-2" />
                <p className="text-sm font-medium text-ink-700">Cliquez pour sélectionner un fichier CSV</p>
                <p className="text-xs text-ink-400 mt-1">Colonnes attendues : catégorie, référence, numéro de série, marque, modèle, statut, date d'achat…</p>
              </div>
              <input ref={fileRef} type="file" accept=".csv,.txt" className="hidden" onChange={(e) => { const f = e.target.files?.[0]; if (f) handleFile(f); }} />
              <div className="text-xs text-ink-500 bg-ink-50 rounded-lg p-3">
                <p className="font-medium mb-1">Format attendu (CSV) :</p>
                <code className="block">catégorie,référence,numéro de série,marque,modèle,statut,date d'achat</code>
                <code className="block mt-1">PC,ELY-PC-001,SN12345,Dell,Latitude 5440,En stock,2024-03-15</code>
              </div>
            </>
          ) : result ? (
            <div className="text-center py-6">
              <CheckCircle2 className="w-12 h-12 text-green-500 mx-auto mb-3" />
              <p className="text-sm font-medium text-ink-900">Import terminé</p>
              <p className="text-sm text-ink-600 mt-1">{result.ok} équipement(s) ajouté(s), {result.skipped} ignoré(s)</p>
            </div>
          ) : (
            <>
              <div className="flex items-center justify-between">
                <p className="text-sm text-ink-700">{rows.length} ligne(s) détectée(s)</p>
                <button onClick={() => fileRef.current?.click()} className="btn-ghost text-xs">Changer de fichier</button>
                <input ref={fileRef} type="file" accept=".csv,.txt" className="hidden" onChange={(e) => { const f = e.target.files?.[0]; if (f) handleFile(f); }} />
              </div>
              <div>
                <p className="label">Correspondance des colonnes</p>
                <div className="space-y-2">
                  {FIELDS.map((f) => (
                    <div key={f} className="flex items-center gap-3">
                      <span className="text-xs font-medium text-ink-600 w-32 capitalize">{f.replace(/_/g, ' ')}</span>
                      <select className="input py-1" value={mapping[f] ?? ''} onChange={(e) => setMapping((m) => ({ ...m, [f]: e.target.value }))}>
                        <option value="">— ignorer —</option>
                        {headers.map((h) => <option key={h} value={h}>{h}</option>)}
                      </select>
                    </div>
                  ))}
                </div>
              </div>
              <div className="overflow-x-auto max-h-48 border border-ink-100 rounded-lg">
                <table className="table-base">
                  <thead><tr>{headers.map((h) => <th key={h}>{h}</th>)}</tr></thead>
                  <tbody>
                    {rows.slice(0, 5).map((r, i) => (
                      <tr key={i}>{headers.map((h) => <td key={h} className="text-xs">{r[h]}</td>)}</tr>
                    ))}
                  </tbody>
                </table>
              </div>
              {error && <div className="rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-sm text-red-700">{error}</div>}
              <div className="flex justify-end gap-2">
                <button onClick={onClose} className="btn-secondary">Annuler</button>
                <button onClick={doImport} className="btn-primary" disabled={busy}>{busy ? 'Import…' : `Importer ${rows.length} ligne(s)`}</button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

function HwStatusBadge({ status }: { status: string }) {
  const tones: Record<string, string> = {
    in_stock: 'bg-green-50 text-green-700',
    assigned: 'bg-elyade-50 text-elyade-700',
    being_reinstalled: 'bg-amber-50 text-amber-700',
    retired: 'bg-ink-100 text-ink-500',
    defective: 'bg-red-50 text-red-700',
  };
  return <span className={`badge ${tones[status] ?? 'bg-ink-100 text-ink-600'}`}>{statusLabel(status, HARDWARE_STATUS)}</span>;
}

function HardwareForm({ onClose, onSaved }: { onClose: () => void; onSaved: () => void }) {
  const data = useData();
  const { profile } = useAuth();
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [categoryId, setCategoryId] = useState('');
  const [reference, setReference] = useState('');
  const [serial, setSerial] = useState('');
  const [brand, setBrand] = useState('');
  const [model, setModel] = useState('');
  const [status, setStatus] = useState<HardwareItem['status']>('in_stock');
  const [intuneId, setIntuneId] = useState('');
  const [ateraId, setAteraId] = useState('');
  const [purchaseDate, setPurchaseDate] = useState('');
  const [notes, setNotes] = useState('');
  const [quantity, setQuantity] = useState(1);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const rows = Array.from({ length: Math.max(1, quantity) }).map((_, i) => ({
        category_id: categoryId,
        reference: reference || null,
        serial_number: quantity > 1 && serial ? `${serial}-${String(i + 1).padStart(2, '0')}` : serial || null,
        brand: brand || null,
        model: model || null,
        status,
        intune_device_id: intuneId || null,
        atera_ticket_id: ateraId || null,
        purchase_date: purchaseDate || null,
        notes: notes || null,
      }));
      const { data: inserted, error: insErr } = await supabase.from('hardware_items').insert(rows).select('id');
      if (insErr) throw insErr;
      for (const r of inserted ?? []) {
        await logAudit('create', 'hardware', r.id, { category_id: categoryId, quantity }, profile?.display_name);
      }
      onSaved();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Erreur');
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center z-50 p-4" onClick={onClose}>
      <div className="card w-full max-w-2xl max-h-[90vh] overflow-auto" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-5 py-4 border-b border-ink-100 sticky top-0 bg-white rounded-t-xl">
          <h2 className="text-lg font-semibold text-ink-900 flex items-center gap-2">
            <Laptop className="w-5 h-5 text-elyade-600" /> Ajouter du matériel
          </h2>
          <button onClick={onClose} className="btn-ghost p-1.5"><X className="w-5 h-5" /></button>
        </div>
        <form onSubmit={onSubmit} className="p-5 space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Catégorie</label>
              <select className="input" value={categoryId} onChange={(e) => setCategoryId(e.target.value)} required>
                <option value="">—</option>
                {data.hardwareCategories.map((c) => <option key={c.id} value={c.id}>{c.label}</option>)}
              </select>
            </div>
            <div>
              <label className="label">Quantité (lot)</label>
              <input type="number" min={1} max={500} className="input" value={quantity} onChange={(e) => setQuantity(Number(e.target.value))} />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Référence</label>
              <input className="input" value={reference} onChange={(e) => setReference(e.target.value)} placeholder="ex: ELY-PC-2026-001" />
            </div>
            <div>
              <label className="label">Numéro de série</label>
              <input className="input" value={serial} onChange={(e) => setSerial(e.target.value)} placeholder="ex: SN-XXXX" />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Marque</label>
              <input className="input" value={brand} onChange={(e) => setBrand(e.target.value)} placeholder="ex: Dell, HP" />
            </div>
            <div>
              <label className="label">Modèle</label>
              <input className="input" value={model} onChange={(e) => setModel(e.target.value)} placeholder="ex: Latitude 5440" />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Statut initial</label>
              <select className="input" value={status} onChange={(e) => setStatus(e.target.value as HardwareItem['status'])}>
                {Object.entries(HARDWARE_STATUS).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
              </select>
            </div>
            <div>
              <label className="label">Date d'achat</label>
              <input type="date" className="input" value={purchaseDate} onChange={(e) => setPurchaseDate(e.target.value)} />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">ID Intune (PC)</label>
              <input className="input" value={intuneId} onChange={(e) => setIntuneId(e.target.value)} placeholder="Device ID Intune" />
            </div>
            <div>
              <label className="label">Ticket Atera</label>
              <input className="input" value={ateraId} onChange={(e) => setAteraId(e.target.value)} placeholder="Ticket RMM" />
            </div>
          </div>
          <div>
            <label className="label">Notes</label>
            <textarea className="input min-h-[70px]" value={notes} onChange={(e) => setNotes(e.target.value)} />
          </div>
          {error && <div className="rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-sm text-red-700">{error}</div>}
          <div className="flex justify-end gap-2 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Annuler</button>
            <button type="submit" className="btn-primary" disabled={busy}>{busy ? 'Ajout…' : 'Ajouter'}</button>
          </div>
        </form>
      </div>
    </div>
  );
}
