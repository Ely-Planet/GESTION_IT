import { useEffect, useState } from 'react';
import MyRequests from './pages/MyRequests';
import NotificationsPanel from './components/NotificationsPanel';
import GlobalTooltip from './components/GlobalTooltip';
import { AuthProvider, useAuth } from './context/AuthContext';
import Login from './pages/Login';
import Layout, { type PageKey } from './components/Layout';
import Dashboard from './pages/Dashboard';
import Movements from './pages/Movements';
import Inventory from './pages/Inventory';
import Licenses from './pages/Licenses';
import MicrosoftLicenses from './pages/MicrosoftLicenses';
import Settings from './pages/Settings';
import OnboardingRequest from './pages/OnboardingRequest';
import SignedDocuments from './pages/SignedDocuments';
import Audit from './pages/Audit';
import Projects from './pages/projects/Projects';
import GroupProjects from './pages/group/GroupProjects';
import { canSeeGroupProjects } from './components/Layout';
import { Building2 } from 'lucide-react';

// Lien reçu par e-mail (?projet=<id>) : mémorisé pour la durée de l'onglet,
// afin de survivre à l'aller-retour de connexion Microsoft.
const PENDING_PROJECT_KEY = 'gestionit.pendingProject';
const PENDING_GROUP_PROJECT_KEY = 'gestionit.pendingGroupProject';

function rememberProjectFromUrl() {
  const params = new URLSearchParams(window.location.search);
  const projectId = params.get('projet');
  const groupProjectId = params.get('projetGroupe');
  if (!projectId && !groupProjectId) return;
  try {
    if (projectId) sessionStorage.setItem(PENDING_PROJECT_KEY, projectId);
    if (groupProjectId) sessionStorage.setItem(PENDING_GROUP_PROJECT_KEY, groupProjectId);
  } catch {
    // stockage indisponible : le lien ouvrira simplement l'accueil
  }
  params.delete('projet');
  params.delete('projetGroupe');
  const query = params.toString();
  window.history.replaceState(null, '', `${window.location.pathname}${query ? `?${query}` : ''}${window.location.hash}`);
}

function takePending(key: string): string | null {
  try {
    const projectId = sessionStorage.getItem(key);
    sessionStorage.removeItem(key);
    return projectId;
  } catch {
    return null;
  }
}

rememberProjectFromUrl();

function Shell() {
  const { user, loading } = useAuth();
const [page, setPage] = useState<PageKey>(
  user?.projectsOnly
    ? (user.hasProjectAccess ? 'projects' : 'groupprojects')
    : (user?.isIT || user?.isITManager)
      ? 'dashboard'
      : 'onboardingrequest'
);
  // nonce : rouvre le projet même si c'est le même que la dernière fois
  const [openRequest, setOpenRequest] = useState<{ projectId: string | null; nonce: number }>({ projectId: null, nonce: 0 });

  function openProject(projectId: string) {
    setOpenRequest((current) => ({ projectId, nonce: current.nonce + 1 }));
    setPage('projects');
  }

  const [openGroupRequest, setOpenGroupRequest] = useState<{ projectId: string | null; nonce: number }>({ projectId: null, nonce: 0 });

  function openGroupProject(projectId: string) {
    setOpenGroupRequest((current) => ({ projectId, nonce: current.nonce + 1 }));
    setPage('groupprojects');
  }

  useEffect(() => {
    if (!user) return;
    const projectId = takePending(PENDING_PROJECT_KEY);
    if (projectId) openProject(projectId);
    const groupProjectId = takePending(PENDING_GROUP_PROJECT_KEY);
    if (groupProjectId) openGroupProject(groupProjectId);
  }, [user]);

if (
  user?.projectsOnly &&
  page !== 'projects' &&
  page !== 'groupprojects'
) {
  setPage(user.hasProjectAccess ? 'projects' : 'groupprojects');
} else if (
  page === 'groupprojects' &&
  user &&
  !canSeeGroupProjects(user)
) {
  setPage(user.isIT || user.isITManager ? 'dashboard' : 'onboardingrequest');
} else if (
  user &&
  !user.projectsOnly &&
  !user.isIT &&
  !user.isITManager &&
  !user.isRH &&
  !user.isManager &&
  !user.isDirector &&
  page !== 'onboardingrequest' &&
  page !== 'myrequests' &&
  page !== 'projects' &&
  page !== 'groupprojects'
) {
  setPage('onboardingrequest');
}


  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-ink-50">
        <div className="flex flex-col items-center gap-3">
          <div className="w-12 h-12 rounded-xl bg-elyade-600 flex items-center justify-center animate-pulse">
            <Building2 className="w-6 h-6 text-white" />
          </div>
          <p className="text-sm text-ink-500">Chargement…</p>
        </div>
      </div>
    );
  }

  if (!user) return <Login />;

  return (
    <Layout current={page} onNavigate={setPage}>
<NotificationsPanel onOpenProject={openProject} onOpenGroupProject={openGroupProject} />
{page === 'dashboard' && <Dashboard />}
{page === 'movements' && <Movements />}
{page === 'inventory' && <Inventory />}
{page === 'licenses' && <Licenses />}
{page === 'microsoftlicenses' && <MicrosoftLicenses />}
{page === 'settings' && <Settings />}
{page === 'onboardingrequest' && <OnboardingRequest />}
{page === 'myrequests' && ( <MyRequests /> )}
{page === 'documents' && <SignedDocuments />}
{page === 'audit' && <Audit />}
{page === 'projects' && <Projects key={openRequest.nonce} initialProjectId={openRequest.projectId} />}
{page === 'groupprojects' && <GroupProjects key={openGroupRequest.nonce} initialProjectId={openGroupRequest.projectId} onOpenItProject={openProject} />}

    </Layout>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <Shell />
      <GlobalTooltip />
    </AuthProvider>
  );
}
