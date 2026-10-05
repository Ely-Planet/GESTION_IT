export type ModuleRole = 'manager' | 'dev' | 'directeur' | 'client';

export type Account = {
  id: string;
  email: string;
  display_name: string;
  is_it: boolean;
  is_it_manager: boolean;
  is_rh: boolean;
  is_manager: boolean;
  is_director: boolean;
  weekly_capacity_hours: number;
};

export type ProjectListItem = {
  project_state?: 'new' | 'in_progress' | 'maintenance' | 'closed';
  closed_at?: string | null;
  id: string;
  name: string;
  description: string | null;
  type: 'dev' | 'infra';
  status: 'en_attente' | 'en_cours' | 'termine' | 'archive';
  due_date: string | null;
  tauxCompletude: number;
  client_name?: string;
  github_repo_url?: string | null;
  chargeEstimeeH?: number;
  chargePasseeH?: number;
};

export type Task = {
  id: string;
  project_id: string;
  title: string;
  description: string | null;
  status: 'backlog' | 'ready' | 'in_progress' | 'in_review' | 'done';
  assignee_account_id: string | null;
  assignee_name?: string | null;
  estimated_hours: string | number;
  spent_hours: string | number;
  origin: 'manuelle' | 'demande_client';
  github_issue_url: string | null;
  completed_at?: string | null;
  comment_count?: number;
  files?: ProjectFile[] | null;
};

export type TaskComment = {
  id: string;
  author_account_id: string | null;
  author_name: string;
  body: string;
  github_comment_url: string | null;
  created_at: string;
};

export type AppNotification = {
  id: string;
  type: string;
  title: string;
  body: string | null;
  project_id: string | null;
  task_id: string | null;
  project_name: string | null;
  read_at: string | null;
  created_at: string;
};

export type Assignment = {
  id: string;
  project_role: 'chef_de_projet' | 'contributeur';
  account_id: string;
  display_name: string;
  email: string;
  is_it: boolean;
  is_it_manager: boolean;
};

export type ClientRequest = {
  id: string;
  project_id: string;
  client_account_id: string;
  title: string;
  description: string | null;
  status: 'en_attente' | 'validee' | 'rejetee';
  task_id: string | null;
  task_status?: Task['status'] | null;
  original_title?: string | null;
  original_description?: string | null;
  rejection_reason?: string | null;
  files?: ProjectFile[] | null;
  created_at?: string;
  client_name?: string;
};

export type ProjectFile = {
  id: string;
  filename: string;
};

export type ProjectMessage = {
  id: string;
  author_account_id: string;
  author_name: string;
  recipient_type: 'equipe' | 'client';
  content: string;
  email_sent: boolean;
  created_at: string;
  files?: ProjectFile[] | null;
};

export type ProjectDetailData = ProjectListItem & {
  project_state?: 'new' | 'in_progress' | 'maintenance' | 'closed';
  closed_at?: string | null;
  tasks?: Task[];
  assignments?: Assignment[];
  clientRequests?: ClientRequest[];
  estChefDeProjet?: boolean;
  client_account_id?: string | null;
  client_email?: string | null;
  github_project_url?: string | null;
};

export type DashboardData = {
  nombreTotalProjets: number;
  nbParStatut: Record<string, number>;
  chargeParProjet: { projetId: string; nom: string; tauxCompletude: number; chargeEstimeeH: number; chargePasseeH: number }[];
  chargeParTechnicien: {
    userId: string;
    nom: string;
    chargeEstimeeH: number;
    nbProjets: number;
    chargeParProjet: { projetId: string; nom: string; chargeEstimeeH: number; chargePasseeH: number; nbTaches: number }[];
    disponibilite: number;
    enSurcharge: boolean;
  }[];
  chargeGlobaleEquipeH: number;
  demandesEnAttente: number;
  tempsParMois: TimeByMonthRow[];
};

export type TimeByMonthRow = {
  mois: string; // AAAA-MM
  userId: string | null;
  nom: string;
  projetId: string;
  projet: string;
  heures: number;
};

export type ReportingRow = {
  id: string;
  nom: string;
  client: string | null;
  statut: string;
  tauxCompletude: number;
  chargeHoraireH: number;
  dateEcheance: string | null;
  enRetard: boolean;
};

export const STATUS_LABELS: Record<string, string> = {
  done: 'Done',
  in_review: 'In review',
  in_progress: 'In progress',
  ready: 'Ready',
  backlog: 'Backlog',
  open: 'Ouverte',
  closed: 'Fermée',
  en_attente: 'En attente',
  en_cours: 'En cours',
  termine: 'Terminé',
  archive: 'Archivé',
  validee: 'Validée',
  rejetee: 'Rejetée',
};

export const STATUS_BADGE_CLASSES: Record<string, string> = {
  backlog: 'bg-slate-100 text-slate-700',
  ready: 'bg-blue-100 text-blue-700',
  in_progress: 'bg-amber-100 text-amber-700',
  in_review: 'bg-purple-100 text-purple-700',
  done: 'bg-orange-100 text-orange-700',

  open: 'bg-emerald-100 text-emerald-700',
  closed: 'bg-purple-100 text-purple-700',
  en_attente: 'bg-ink-100 text-ink-700',
  en_cours: 'bg-amber-100 text-amber-700',
  termine: 'bg-emerald-100 text-emerald-700',
  validee: 'bg-emerald-100 text-emerald-700',
  rejetee: 'bg-red-100 text-red-700',
  archive: 'bg-ink-100 text-ink-500',
};
