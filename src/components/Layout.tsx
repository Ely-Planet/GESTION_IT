import { type ReactNode } from 'react';
import {
  LayoutDashboard,
  ArrowRightLeft,
  Laptop,
  KeyRound,
  FileSignature,
  ScrollText,
  Building2,
  LogOut,
  Settings2,
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export type PageKey =
  | 'dashboard'
  | 'movements'
  | 'inventory'
  | 'licenses'
  | 'microsoftlicenses'
  | 'settings'
  | 'onboardingrequest'
  | 'audit';

const NAV: { key: PageKey; label: string; icon: typeof LayoutDashboard }[] = [
  { key: 'dashboard', label: 'Tableau de bord', icon: LayoutDashboard },
  { key: 'movements', label: 'Arrivées & Départs', icon: ArrowRightLeft },
  { key: 'inventory', label: 'Inventaire', icon: Laptop },
  { key: 'licenses', label: 'Licences', icon: KeyRound },
{ key: 'microsoftlicenses', label: 'Licences Microsoft', icon: KeyRound },
{ key: 'settings', label: 'Paramètres', icon: Settings2 },
{ key: 'onboardingrequest', label: "Demande d'onboarding", icon: FileSignature },  
{ key: 'audit', label: "Journal d'audit", icon: ScrollText },
];

export default function Layout({
  current,
  onNavigate,
  children,
}: {
  current: PageKey;
  onNavigate: (p: PageKey) => void;
  children: ReactNode;
}) {
  const { profile, signOut } = useAuth();

  return (
    <div className="min-h-screen flex bg-ink-50">
      <aside className="w-64 bg-white border-r border-ink-100 flex flex-col shrink-0">
        <div className="px-5 py-5 flex items-center gap-3 border-b border-ink-100">
          <div className="w-10 h-10 rounded-xl bg-elyade-600 flex items-center justify-center shadow-sm">
            <Building2 className="w-5 h-5 text-white" />
          </div>
          <div>
            <p className="text-sm font-bold text-ink-900 leading-tight">ELYADE</p>
            <p className="text-xs text-ink-500">IT Manager</p>
          </div>
        </div>

        <nav className="flex-1 px-3 py-4 space-y-1">
          {NAV.map(({ key, label, icon: Icon }) => {
            const active = current === key;
            return (
              <button
                key={key}
                onClick={() => onNavigate(key)}
                className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all ${
                  active
                    ? 'bg-elyade-50 text-elyade-700'
                    : 'text-ink-600 hover:bg-ink-50 hover:text-ink-900'
                }`}
              >
                <Icon className={`w-4.5 h-4.5 ${active ? 'text-elyade-600' : 'text-ink-400'}`} />
                {label}
              </button>
            );
          })}
        </nav>

        <div className="p-3 border-t border-ink-100">
          <div className="px-3 py-2 mb-2">
            <p className="text-sm font-medium text-ink-900 truncate">{profile?.display_name ?? '—'}</p>
            <p className="text-xs text-ink-500 truncate">{profile?.email ?? ''}</p>
          </div>
          <button onClick={signOut} className="btn-ghost w-full justify-start text-sm">
            <LogOut className="w-4 h-4" />
            Déconnexion
          </button>
        </div>
      </aside>

      <main className="flex-1 overflow-auto">{children}</main>
    </div>
  );
}
