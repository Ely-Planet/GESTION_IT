import { useEffect, useState } from 'react';
import { Check, GitMerge, Pencil, Plus, Trash2, X } from 'lucide-react';

// Fournisseurs (liste unique : inventaire et suivi des dépenses).
// Ajout, renommage, suppression, fusion et détection automatique des doublons.

type Supplier = { id: string; label: string; hardware_count: number; expense_count: number };
type DuplicateGroup = { confidence: 'sure' | 'probable'; targetId: string; members: Supplier[] };

async function api<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, { ...init, headers: { 'Content-Type': 'application/json' } });
  if (res.status === 204) return undefined as T;
  const json = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(json.error || 'Erreur');
  return json as T;
}

const usage = (s: Supplier) =>
  [s.hardware_count ? `${s.hardware_count} matériel${s.hardware_count > 1 ? 's' : ''}` : '', s.expense_count ? `${s.expense_count} dépense${s.expense_count > 1 ? 's' : ''}` : '']
    .filter(Boolean)
    .join(' · ') || 'non utilisé';

function DuplicateCard({ group, onMerge }: { group: DuplicateGroup; onMerge: (targetId: string, sourceIds: string[]) => Promise<void> }) {
  const [targetId, setTargetId] = useState(group.targetId);
  const [busy, setBusy] = useState(false);
  return (
    <div className="p-3 rounded-lg border border-ink-200 bg-white">
      <div className="flex items-center justify-between mb-2">
        <span className={`badge ${group.confidence === 'sure' ? 'bg-amber-100 text-amber-800' : 'bg-ink-100 text-ink-600'}`}>
          {group.confidence === 'sure' ? 'Doublon certain' : 'Doublon probable'}
        </span>
        <button
          type="button"
          className="btn-primary text-xs"
          disabled={busy}
          onClick={async () => {
            setBusy(true);
            await onMerge(
              targetId,
              group.members.map((m) => m.id).filter((id) => id !== targetId)
            );
            setBusy(false);
          }}
        >
          <GitMerge className="w-3.5 h-3.5" /> {busy ? 'Fusion…' : 'Fusionner'}
        </button>
      </div>
      <p className="text-xs text-ink-500 mb-1">Nom à conserver :</p>
      <div className="space-y-1">
        {group.members.map((m) => (
          <label key={m.id} className="flex items-center gap-2 text-sm">
            <input type="radio" checked={targetId === m.id} onChange={() => setTargetId(m.id)} />
            <span className={targetId === m.id ? 'font-medium' : ''}>{m.label}</span>
            <span className="text-xs text-ink-400">{usage(m)}</span>
          </label>
        ))}
      </div>
    </div>
  );
}

export default function SuppliersSettings() {
  const [suppliers, setSuppliers] = useState<Supplier[]>([]);
  const [duplicates, setDuplicates] = useState<DuplicateGroup[]>([]);
  const [newLabel, setNewLabel] = useState('');
  const [editing, setEditing] = useState<{ id: string; label: string } | null>(null);
  const [mergeFrom, setMergeFrom] = useState<Supplier | null>(null);
  const [mergeInto, setMergeInto] = useState('');
  const [search, setSearch] = useState('');
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function load() {
    try {
      const data = await api<{ suppliers: Supplier[]; duplicates: DuplicateGroup[] }>('/api/suppliers-admin');
      setSuppliers(data.suppliers);
      setDuplicates(data.duplicates);
    } catch (err: any) {
      setError(err.message);
    }
  }

  useEffect(() => {
    void load();
  }, []);

  async function run(action: () => Promise<unknown>, done?: string) {
    setError(null);
    setMessage(null);
    try {
      await action();
      if (done) setMessage(done);
      await load();
    } catch (err: any) {
      setError(err.message);
    }
  }

  const merge = (targetId: string, sourceIds: string[]) =>
    run(() => api('/api/suppliers-admin/merge', { method: 'POST', body: JSON.stringify({ targetId, sourceIds }) }), 'Fusion effectuée.');

  const sureGroups = duplicates.filter((g) => g.confidence === 'sure');
  const shown = suppliers.filter((s) => s.label.toLowerCase().includes(search.trim().toLowerCase()));

  return (
    <div className="card p-4 md:col-span-2">
      <div className="flex flex-wrap items-start justify-between gap-2 mb-3">
        <div>
          <h3 className="font-semibold text-ink-900">Fournisseurs</h3>
          <p className="text-xs text-ink-500">Liste commune à l'inventaire et au suivi des dépenses. Un renommage ou une fusion met à jour les matériels et les dépenses.</p>
        </div>
      </div>

      {message && <p className="text-sm text-green-700 mb-2">{message}</p>}
      {error && <p className="text-sm text-red-600 mb-2">{error}</p>}

      {duplicates.length > 0 && (
        <div className="mb-4 p-3 rounded-lg bg-amber-50/60 border border-amber-200">
          <div className="flex flex-wrap items-center justify-between gap-2 mb-2">
            <p className="text-sm font-medium text-amber-900">
              {duplicates.length} groupe{duplicates.length > 1 ? 's' : ''} de doublons détecté{duplicates.length > 1 ? 's' : ''} automatiquement
            </p>
            {sureGroups.length > 0 && (
              <button
                type="button"
                className="btn-secondary text-xs"
                onClick={() => {
                  if (!confirm(`Fusionner les ${sureGroups.length} doublons certains (même nom aux accents, majuscules ou forme juridique près) ?`)) return;
                  void run(
                    () =>
                      api('/api/suppliers-admin/merge', {
                        method: 'POST',
                        body: JSON.stringify({
                          merges: sureGroups.map((g) => ({ targetId: g.targetId, sourceIds: g.members.map((m) => m.id).filter((id) => id !== g.targetId) })),
                        }),
                      }),
                    `${sureGroups.length} fusion(s) effectuée(s).`
                  );
                }}
              >
                <GitMerge className="w-3.5 h-3.5" /> Fusionner les {sureGroups.length} doublons certains
              </button>
            )}
          </div>
          <p className="text-xs text-amber-800 mb-3">
            « Certain » : même nom aux accents, majuscules ou forme juridique près. « Probable » : noms très proches, à vérifier avant de fusionner.
          </p>
          <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-2">
            {duplicates.map((group) => (
              <DuplicateCard key={group.members.map((m) => m.id).join('|')} group={group} onMerge={merge} />
            ))}
          </div>
        </div>
      )}

      <div className="flex flex-wrap gap-2 mb-3">
        <input
          className="input flex-1 min-w-[200px]"
          placeholder="Nouveau fournisseur"
          value={newLabel}
          onChange={(e) => setNewLabel(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter' && newLabel.trim()) {
              e.preventDefault();
              void run(() => api('/api/suppliers-admin', { method: 'POST', body: JSON.stringify({ label: newLabel }) }), 'Fournisseur ajouté.').then(() => setNewLabel(''));
            }
          }}
        />
        <button
          type="button"
          className="btn-primary text-sm"
          disabled={!newLabel.trim()}
          onClick={() =>
            void run(() => api('/api/suppliers-admin', { method: 'POST', body: JSON.stringify({ label: newLabel }) }), 'Fournisseur ajouté.').then(() => setNewLabel(''))
          }
        >
          <Plus className="w-4 h-4" /> Ajouter
        </button>
        <input className="input w-56" placeholder="Rechercher…" value={search} onChange={(e) => setSearch(e.target.value)} />
      </div>

      {mergeFrom && (
        <div className="mb-3 p-3 rounded-lg border border-elyade-200 bg-elyade-50/50 flex flex-wrap items-center gap-2 text-sm">
          Fusionner <strong>{mergeFrom.label}</strong> dans
          <select className="input py-1.5 w-64" value={mergeInto} onChange={(e) => setMergeInto(e.target.value)}>
            <option value="">Choisir le fournisseur à conserver…</option>
            {suppliers
              .filter((s) => s.id !== mergeFrom.id)
              .map((s) => (
                <option key={s.id} value={s.id}>{s.label}</option>
              ))}
          </select>
          <button
            type="button"
            className="btn-primary text-xs"
            disabled={!mergeInto}
            onClick={() => void merge(mergeInto, [mergeFrom.id]).then(() => setMergeFrom(null))}
          >
            Fusionner
          </button>
          <button type="button" className="btn-ghost text-xs" onClick={() => setMergeFrom(null)}>Annuler</button>
        </div>
      )}

      <div className="max-h-[420px] overflow-auto divide-y divide-ink-100 border border-ink-100 rounded-lg">
        {shown.map((s) => (
          <div key={s.id} className="flex items-center gap-2 px-3 py-2">
            {editing?.id === s.id ? (
              <>
                <input className="input py-1 flex-1" value={editing.label} autoFocus onChange={(e) => setEditing({ ...editing, label: e.target.value })} />
                <button
                  type="button"
                  className="btn-ghost p-1.5 text-green-700"
                  title="Enregistrer"
                  onClick={() =>
                    void run(() => api(`/api/suppliers-admin/${s.id}`, { method: 'PATCH', body: JSON.stringify({ label: editing.label }) }), 'Fournisseur renommé.').then(() =>
                      setEditing(null)
                    )
                  }
                >
                  <Check className="w-4 h-4" />
                </button>
                <button type="button" className="btn-ghost p-1.5" title="Annuler" onClick={() => setEditing(null)}>
                  <X className="w-4 h-4" />
                </button>
              </>
            ) : (
              <>
                <span className="flex-1 text-sm">{s.label}</span>
                <span className="text-xs text-ink-400">{usage(s)}</span>
                <button type="button" className="btn-ghost p-1.5" title="Renommer" onClick={() => setEditing({ id: s.id, label: s.label })}>
                  <Pencil className="w-4 h-4" />
                </button>
                <button
                  type="button"
                  className="btn-ghost p-1.5"
                  title="Fusionner dans un autre fournisseur"
                  onClick={() => {
                    setMergeFrom(s);
                    setMergeInto('');
                  }}
                >
                  <GitMerge className="w-4 h-4" />
                </button>
                <button
                  type="button"
                  className="btn-ghost p-1.5 text-ink-400 hover:text-red-600 disabled:opacity-30"
                  title={s.hardware_count || s.expense_count ? 'Utilisé : fusionnez-le plutôt dans un autre fournisseur' : 'Supprimer'}
                  disabled={Boolean(s.hardware_count || s.expense_count)}
                  onClick={() => {
                    if (confirm(`Supprimer le fournisseur « ${s.label} » ?`)) void run(() => api(`/api/suppliers-admin/${s.id}`, { method: 'DELETE' }), 'Fournisseur supprimé.');
                  }}
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </>
            )}
          </div>
        ))}
        {shown.length === 0 && <p className="text-sm text-ink-400 p-3">Aucun fournisseur.</p>}
      </div>
      <p className="text-xs text-ink-500 mt-2">{suppliers.length} fournisseur{suppliers.length > 1 ? 's' : ''}.</p>
    </div>
  );
}
