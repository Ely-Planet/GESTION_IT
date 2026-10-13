import { useEffect, useState } from 'react';
import { Check, Pencil, Plus, Trash2, X } from 'lucide-react';

// Catégories des contrats (Paramètres, groupe Manager Informatique).
// Un renommage met à jour les contrats ; une catégorie utilisée ne peut pas être supprimée.

type Category = { id: string; label: string; usage: number };

async function api<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, { ...init, headers: { 'Content-Type': 'application/json' } });
  if (res.status === 204) return undefined as T;
  const json = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(json.error || 'Erreur');
  return json as T;
}

export default function ContractCategoriesSettings({ onBack }: { onBack: () => void }) {
  const [rows, setRows] = useState<Category[]>([]);
  const [label, setLabel] = useState('');
  const [editing, setEditing] = useState<{ id: string; label: string } | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function load() {
    try {
      setRows(await api<Category[]>('/api/contract-categories'));
    } catch (err: any) {
      setError(err.message);
    }
  }

  useEffect(() => {
    void load();
  }, []);

  async function run(action: () => Promise<unknown>) {
    setError(null);
    try {
      await action();
      await load();
      return true;
    } catch (err: any) {
      setError(err.message);
      return false;
    }
  }

  const add = async () => {
    if (label.trim() && (await run(() => api('/api/contract-categories', { method: 'POST', body: JSON.stringify({ label }) })))) setLabel('');
  };

  return (
    <div className="p-6 lg:p-8 max-w-3xl">
      <button onClick={onBack} className="btn-secondary mb-6">← Retour</button>
      <h1 className="text-2xl font-bold text-ink-900">Catégories de contrats</h1>
      <p className="mt-2 text-ink-500">Liste proposée dans le suivi des contrats. Un renommage met à jour les contrats concernés.</p>

      <div className="card p-4 mt-6">
        <div className="flex gap-2 mb-3">
          <input
            className="input flex-1"
            placeholder="Nouvelle catégorie"
            value={label}
            onChange={(e) => setLabel(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter') {
                e.preventDefault();
                void add();
              }
            }}
          />
          <button type="button" className="btn-primary text-sm" disabled={!label.trim()} onClick={() => void add()}>
            <Plus className="w-4 h-4" /> Ajouter
          </button>
        </div>
        {error && <p className="text-sm text-red-600 mb-2">{error}</p>}
        <div className="divide-y divide-ink-100 border border-ink-100 rounded-lg">
          {rows.map((row) => (
            <div key={row.id} className="flex items-center gap-2 px-3 py-2">
              {editing?.id === row.id ? (
                <>
                  <input className="input py-1 flex-1" autoFocus value={editing.label} onChange={(e) => setEditing({ ...editing, label: e.target.value })} />
                  <button
                    type="button"
                    className="btn-ghost p-1.5 text-green-700"
                    title="Enregistrer"
                    onClick={async () => {
                      if (await run(() => api(`/api/contract-categories/${row.id}`, { method: 'PATCH', body: JSON.stringify({ label: editing.label }) }))) setEditing(null);
                    }}
                  >
                    <Check className="w-4 h-4" />
                  </button>
                  <button type="button" className="btn-ghost p-1.5" title="Annuler" onClick={() => setEditing(null)}><X className="w-4 h-4" /></button>
                </>
              ) : (
                <>
                  <span className="flex-1 text-sm">{row.label}</span>
                  <span className="text-xs text-ink-400">{row.usage ? `${row.usage} contrat${row.usage > 1 ? 's' : ''}` : 'non utilisée'}</span>
                  <button type="button" className="btn-ghost p-1.5" title="Renommer" onClick={() => setEditing({ id: row.id, label: row.label })}><Pencil className="w-4 h-4" /></button>
                  <button
                    type="button"
                    className="btn-ghost p-1.5 text-ink-400 hover:text-red-600 disabled:opacity-30"
                    title={row.usage ? 'Utilisée : changez d’abord la catégorie des contrats' : 'Supprimer'}
                    disabled={row.usage > 0}
                    onClick={() => {
                      if (confirm(`Supprimer la catégorie « ${row.label} » ?`)) void run(() => api(`/api/contract-categories/${row.id}`, { method: 'DELETE' }));
                    }}
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </>
              )}
            </div>
          ))}
          {rows.length === 0 && <p className="text-sm text-ink-400 p-3">Aucune catégorie.</p>}
        </div>
      </div>
    </div>
  );
}
