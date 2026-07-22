import { useState } from 'react';
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
import Audit from './pages/Audit';
import { Building2 } from 'lucide-react';

function Shell() {
  const { user, loading } = useAuth();
  const [page, setPage] = useState<PageKey>('dashboard');

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
{page === 'dashboard' && <Dashboard />}
{page === 'movements' && <Movements />}
{page === 'inventory' && <Inventory />}
{page === 'licenses' && <Licenses />}
{page === 'microsoftlicenses' && <MicrosoftLicenses />}
{page === 'settings' && <Settings />}
{page === 'onboardingrequest' && <OnboardingRequest />}
{page === 'audit' && <Audit />}

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
