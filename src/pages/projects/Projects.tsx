import { useState } from 'react';
import { LayoutGrid, LayoutDashboard } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import ProjectsList from './ProjectsList';
import ProjectDetail from './ProjectDetail';
import DashboardView from './DashboardView';

export default function Projects({ initialProjectId = null }: { initialProjectId?: string | null }) {
  const { user } = useAuth();
  // initialProjectId : projet ouvert depuis une notification ou le lien reçu par e-mail.
  const [selectedId, setSelectedId] = useState<string | null>(initialProjectId);
  const [view, setView] = useState<'list' | 'dashboard'>('list');

  const isManager = Boolean(user?.isITManager);

  if (selectedId) {
    return <ProjectDetail projectId={selectedId} onBack={() => setSelectedId(null)} />;
  }

  return (
    <div>
      {isManager && (
        <div className="px-6 pt-6 w-full max-w-[1800px] mx-auto flex gap-2">
          <button
            onClick={() => setView('list')}
            className={`btn-ghost text-sm ${view === 'list' ? 'bg-ink-100' : ''}`}
          >
            <LayoutGrid className="w-4 h-4" /> Projets
          </button>
          <button
            onClick={() => setView('dashboard')}
            className={`btn-ghost text-sm ${view === 'dashboard' ? 'bg-ink-100' : ''}`}
          >
            <LayoutDashboard className="w-4 h-4" /> Dashboard
          </button>
        </div>
      )}

      {view === 'dashboard' && isManager ? (
        <DashboardView />
      ) : (
        <ProjectsList onOpen={setSelectedId} />
      )}
    </div>
  );
}
