import { useEffect, useState } from 'react';
import { Trash2 } from 'lucide-react';
import { groupApi } from '../groupApi';
import ClientPicker from '../../projects/ClientPicker';
import type { Account } from '../../projects/types';
import type { DirectoryAccount, GroupProjectDetail, GroupRole } from '../types';

// Membres du projet : les responsables ajoutent, retirent et nomment les responsables.
export default function MembersTab({ project, onChanged }: { project: GroupProjectDetail; onChanged: () => void }) {
  const [accounts, setAccounts] = useState<DirectoryAccount[]>([]);
  const [busy, setBusy] = useState(false);
  const canManage = project.estResponsable;

  useEffect(() => {
    if (canManage) groupApi.accounts().then(setAccounts).catch(() => setAccounts([]));
  }, [canManage]);

  async function run(action: () => Promise<unknown>) {
    setBusy(true);
    try {
      await action();
    } catch (err: any) {
      alert(err.message || 'Erreur');
    } finally {
      setBusy(false);
      onChanged();
    }
  }

  const available = accounts.filter((a) => !project.members.some((m) => m.account_id === a.id));

  return (
    <div className="card p-5 max-w-3xl">
      <h3 className="font-semibold text-ink-900 mb-1">Membres ({project.members.length})</h3>
      <p className="text-xs text-ink-500 mb-4">
        Les responsables gèrent le projet et ses membres. Tous les membres gèrent les tâches, réunions, comptes rendus et mails.
      </p>

      {canManage && (
        <div className="mb-4">
          <ClientPicker
            className="max-w-md"
            clients={available as unknown as Account[]}
            value=""
            onChange={(id) => id && void run(() => groupApi.addMember(project.id, id))}
          />
        </div>
      )}

      <ul className={`divide-y divide-ink-100 ${busy ? 'opacity-60 pointer-events-none' : ''}`}>
        {project.members.map((member) => (
          <li key={member.account_id} className="flex items-center justify-between gap-3 py-2.5">
            <div className="min-w-0">
              <p className="text-sm font-medium text-ink-900 truncate">{member.display_name}</p>
              <p className="text-xs text-ink-500 truncate">{member.email}</p>
            </div>
            <div className="flex items-center gap-2 shrink-0">
              {canManage ? (
                <select
                  className="input py-1 text-xs w-36"
                  value={member.role}
                  onChange={(e) => void run(() => groupApi.setMemberRole(project.id, member.account_id, e.target.value as GroupRole))}
                >
                  <option value="responsable">Responsable</option>
                  <option value="membre">Membre</option>
                </select>
              ) : (
                <span className={`badge ${member.role === 'responsable' ? 'bg-elyade-50 text-elyade-700' : 'bg-ink-100 text-ink-600'}`}>
                  {member.role === 'responsable' ? 'Responsable' : 'Membre'}
                </span>
              )}
              {canManage && (
                <button
                  type="button"
                  className="btn-ghost p-1.5 text-ink-400 hover:text-red-600"
                  title="Retirer du projet"
                  onClick={() => {
                    if (confirm(`Retirer ${member.display_name} du projet ?`)) {
                      void run(() => groupApi.removeMember(project.id, member.account_id));
                    }
                  }}
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              )}
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
