import { useState } from 'react';
import { ChevronLeft, ChevronRight, Plus, Trash2 } from 'lucide-react';
import { groupApi } from './groupApi';
import type { GroupProjectDetail, KanbanColumn } from './types';

// Colonnes du Kanban d'un projet (responsables) : renommer, ajouter, supprimer, déplacer.
// La colonne de fin (« done ») ne peut pas être supprimée : elle compte pour l'avancement.
export default function KanbanColumnsEditor({
  project,
  onSaved,
  onClose,
}: {
  project: GroupProjectDetail;
  onSaved: () => void;
  onClose: () => void;
}) {
  const [columns, setColumns] = useState<KanbanColumn[]>(project.columns.map((c) => ({ ...c })));
  const [newTitle, setNewTitle] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const taskCount = (key: string) => project.tasks.filter((t) => t.status === key).length;

  function rename(index: number, title: string) {
    setColumns((current) => current.map((c, i) => (i === index ? { ...c, title } : c)));
  }

  function move(index: number, delta: number) {
    setColumns((current) => {
      const next = [...current];
      const [column] = next.splice(index, 1);
      next.splice(index + delta, 0, column);
      return next;
    });
  }

  function remove(index: number) {
    setColumns((current) => current.filter((_, i) => i !== index));
  }

  function add() {
    const title = newTitle.trim();
    if (!title) return;
    // Nouvelle colonne insérée avant la colonne de fin.
    setColumns((current) => {
      const doneIndex = current.findIndex((c) => c.key === 'done');
      const next = [...current];
      next.splice(doneIndex === -1 ? next.length : doneIndex, 0, { key: '', title });
      return next;
    });
    setNewTitle('');
  }

  async function save() {
    setError(null);
    if (columns.some((c) => !c.title.trim())) {
      setError('Chaque colonne doit avoir un nom.');
      return;
    }
    const removed = project.columns.filter((c) => !columns.some((k) => k.key === c.key));
    const moved = removed.reduce((sum, c) => sum + taskCount(c.key), 0);
    if (moved > 0) {
      const target = columns[0]?.title || 'la première colonne';
      if (!confirm(`${moved} tâche${moved > 1 ? 's' : ''} des colonnes supprimées ser${moved > 1 ? 'ont' : 'a'} déplacée${moved > 1 ? 's' : ''} dans « ${target} ». Continuer ?`)) return;
    }
    setSaving(true);
    try {
      await groupApi.setColumns(project.id, columns.map((c) => ({ key: c.key || undefined, title: c.title.trim() })));
      onSaved();
      onClose();
    } catch (err: any) {
      setError(err.message || 'Enregistrement impossible');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="card p-4 mb-4">
      <div className="flex items-start justify-between gap-3 mb-3">
        <div>
          <h4 className="font-semibold text-ink-900">Colonnes du tableau</h4>
          <p className="text-xs text-ink-500">
            Renommez, ajoutez, supprimez ou déplacez les colonnes. La colonne de fin compte pour l'avancement du projet et ne peut pas être supprimée.
          </p>
        </div>
      </div>

      <div className="space-y-2">
        {columns.map((column, index) => (
          <div key={column.key || `new-${index}`} className="flex items-center gap-2">
            <input
              className="input py-1.5 text-sm flex-1"
              value={column.title}
              maxLength={40}
              onChange={(e) => rename(index, e.target.value)}
            />
            {column.key === 'done' && <span className="badge bg-emerald-50 text-emerald-700">Fin</span>}
            {column.key && taskCount(column.key) > 0 && (
              <span className="text-xs text-ink-400 whitespace-nowrap">{taskCount(column.key)} tâche{taskCount(column.key) > 1 ? 's' : ''}</span>
            )}
            <button type="button" className="btn-ghost p-1.5" title="Vers la gauche" disabled={index === 0} onClick={() => move(index, -1)}>
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button type="button" className="btn-ghost p-1.5" title="Vers la droite" disabled={index === columns.length - 1} onClick={() => move(index, 1)}>
              <ChevronRight className="w-4 h-4" />
            </button>
            <button
              type="button"
              className="btn-ghost p-1.5 text-ink-400 hover:text-red-600 disabled:opacity-30"
              title={column.key === 'done' ? 'La colonne de fin ne peut pas être supprimée' : 'Supprimer la colonne'}
              disabled={column.key === 'done' || columns.length <= 2}
              onClick={() => remove(index)}
            >
              <Trash2 className="w-4 h-4" />
            </button>
          </div>
        ))}
      </div>

      <div className="flex items-center gap-2 mt-3">
        <input
          className="input py-1.5 text-sm flex-1"
          placeholder="Nom de la nouvelle colonne"
          maxLength={40}
          value={newTitle}
          onChange={(e) => setNewTitle(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              e.preventDefault();
              add();
            }
          }}
        />
        <button type="button" className="btn-secondary text-sm" disabled={!newTitle.trim() || columns.length >= 12} onClick={add}>
          <Plus className="w-4 h-4" /> Ajouter
        </button>
      </div>

      {error && <p className="text-sm text-red-600 mt-2">{error}</p>}

      <div className="flex gap-2 mt-4">
        <button type="button" className="btn-primary text-sm" disabled={saving} onClick={() => void save()}>
          {saving ? 'Enregistrement…' : 'Enregistrer'}
        </button>
        <button type="button" className="btn-ghost text-sm" onClick={onClose}>
          Annuler
        </button>
      </div>
    </div>
  );
}
