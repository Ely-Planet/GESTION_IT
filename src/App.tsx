import { useEffect, useState } from 'react';
import MyRequests from './pages/MyRequests';
import NotificationsPanel from './components/NotificationsPanel';
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
import { Building2 } from 'lucide-react';

// Lien reçu par e-mail (?projet=<id>) : mémorisé pour la durée de l'onglet,
// afin de survivre à l'aller-retour de connexion Microsoft.
const PENDING_PROJECT_KEY = 'gestionit.pendingProject';

function rememberProjectFromUrl() {
  const params = new URLSearchParams(window.location.search);
  const projectId = params.get('projet');
  if (!projectId) return;
  try {
    sessionStorage.setItem(PENDING_PROJECT_KEY, projectId);
  } catch {
    // stockage indisponible : le lien ouvrira simplement l'accueil
  }
  params.delete('projet');
  const query = params.toString();
  window.history.replaceState(null, '', `${window.location.pathname}${query ? `?${query}` : ''}${window.location.hash}`);
}

function takePendingProject(): string | null {
  try {
    const projectId = sessionStorage.getItem(PENDING_PROJECT_KEY);
    sessionStorage.removeItem(PENDING_PROJECT_KEY);
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
    ? 'projects'
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

  useEffect(() => {
    if (!user) return;
    const projectId = takePendingProject();
    if (projectId) openProject(projectId);
  }, [user]);

if (
  user?.projectsOnly &&
  page !== 'projects'
) {
  setPage('projects');
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
  page !== 'projects'
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
<NotificationsPanel onOpenProject={openProject} />
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

    </Layout>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <Shell />
    </AuthProvider>
  );
}
