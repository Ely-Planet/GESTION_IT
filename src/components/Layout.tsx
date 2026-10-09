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
  FolderKanban,
  Network,
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
| 'myrequests'
  | 'documents'
  | 'audit'
  | 'projects'
  | 'groupprojects';

const GROUP_ITEM = { key: 'groupprojects' as PageKey, label: 'Projets Groupe', icon: Network };

// Projets Groupe : managers et directeurs (création), et tout membre d'un projet.
export function canSeeGroupProjects(user: { isManager?: boolean; isDirector?: boolean; isITManager?: boolean; hasGroupProjectAccess?: boolean } | null) {
  return Boolean(user && (user.isManager || user.isDirector || user.isITManager || user.hasGroupProjectAccess));
}

const NAV_IT: { key: PageKey; label: string; icon: typeof LayoutDashboard }[] = [
  { key: 'dashboard', label: 'Tableau de bord', icon: LayoutDashboard },
  { key: 'movements', label: 'Arrivées & Départs', icon: ArrowRightLeft },
  { key: 'inventory', label: 'Inventaire', icon: Laptop },
  { key: 'licenses', label: 'Licences', icon: KeyRound },
  { key: 'projects', label: 'Projets IT', icon: FolderKanban },
  { key: 'settings', label: 'Paramètres', icon: Settings2 },
  { key: 'onboardingrequest', label: "Demande d'onboarding", icon: FileSignature },
{ key: 'myrequests', label: 'Mes demandes', icon: FileSignature },
  { key: 'documents', label: 'Documents signés', icon: FileSignature },
  { key: 'audit', label: "Journal d'audit", icon: ScrollText },
];

const NAV_PROJECTS_ONLY: {
  key: PageKey;
  label: string;
  icon: typeof LayoutDashboard;
}[] = [
  { key: 'projects', label: 'Mes projets IT', icon: FolderKanban },
];

const NAV_LIMITED: { key: PageKey; label: string; icon: typeof LayoutDashboard }[] = [
  { key: 'projects', label: 'Mes projets IT', icon: FolderKanban },
  { key: 'onboardingrequest', label: "Demande d'onboarding", icon: FileSignature },
  { key: 'myrequests', label: 'Mes demandes', icon: FileSignature },
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
const { profile, user, signOut } = useAuth();

const baseNav =
  user?.projectsOnly
    ? NAV_PROJECTS_ONLY.filter((item) => item.key !== 'projects' || user.hasProjectAccess)
    : (user?.isIT || user?.isITManager)
      ? NAV_IT
      // Hors informatique : "Mes projets IT" seulement si désigné sur un projet.
      : NAV_LIMITED.filter((item) => item.key !== 'projects' || user?.hasProjectAccess);

// "Projets Groupe" juste après les projets IT (ou en tête s'il n'y en a pas).
const navItems = canSeeGroupProjects(user)
  ? (() => {
      const index = baseNav.findIndex((item) => item.key === 'projects');
      return index === -1 ? [GROUP_ITEM, ...baseNav] : [...baseNav.slice(0, index + 1), GROUP_ITEM, ...baseNav.slice(index + 1)];
    })()
  : baseNav;

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
{navItems.map(({ key, label, icon: Icon }) => {
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
