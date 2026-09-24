import { useState } from 'react';
import { projectsApi } from '../api';
import type { Account, ProjectDetailData } from '../types';

export default function TeamTab({
  project,
  allAccounts,
  canManage,
  onChanged,
}: {
  project: ProjectDetailData;
  allAccounts: Account[];
  canManage: boolean;
  onChanged: () => void;
}) {
  const [selected, setSelected] = useState('');
  const [projectRole, setProjectRole] = useState('contributeur');

  const assignedIds = new Set((project.assignments || []).map((a) => a.account_id));
  const available = allAccounts.filter((a) => (a.is_it || a.is_it_manager) && !assignedIds.has(a.id));

  async function assign(e: React.FormEvent) {
    e.preventDefault();
    if (!selected) return;
    await projectsApi.assign(project.id, selected, projectRole);
    setSelected('');
    onChanged();
  }

  async function unassign(accountId: string) {
    await projectsApi.unassign(project.id, accountId);
    onChanged();
  }

  return (
    <div>
      <h3 className="font-semibold text-ink-900 mb-3">Équipe affectée</h3>
      <div className="space-y-2 mb-4">
        {(project.assignments || []).map((a) => (
          <div key={a.account_id} className="card p-3 flex justify-between items-center">
            <div className="flex items-center gap-2">
              <span className="font-medium text-ink-900">{a.display_name}</span>
              {a.project_role === 'chef_de_projet' && <span className="badge bg-amber-100 text-amber-700">Chef de projet</span>}
            </div>
            {canManage && (
              <button className="text-sm text-red-600" onClick={() => unassign(a.account_id)}>
                Retirer
              </button>
            )}
          </div>
        ))}
        {(!project.assignments || project.assignments.length === 0) && (
          <p className="text-sm text-ink-500">Aucun développeur/technicien affecté.</p>
        )}
      </div>

      {canManage && (
        <form onSubmit={assign} className="card p-3 flex flex-wrap items-center gap-2">
          <select className="input flex-1" value={selected} onChange={(e) => setSelected(e.target.value)}>
            <option value="">Ajouter un membre...</option>
            {available.map((a) => (
              <option key={a.id} value={a.id}>
                {a.display_name}
              </option>
            ))}
          </select>
          <select className="input w-44" value={projectRole} onChange={(e) => setProjectRole(e.target.value)}>
            <option value="contributeur">Contributeur</option>
            <option value="chef_de_projet">Chef de projet</option>
          </select>
          <button className="btn-primary text-sm">Affecter</button>
        </form>
      )}
    </div>
  );
}
