import type { Account, Task } from '../projects/types';

export type GroupRole = 'responsable' | 'membre';

export type GroupMember = {
  account_id: string;
  display_name: string;
  email: string | null;
  role: GroupRole;
};

export type GroupProjectListItem = {
  id: string;
  ref: string; // PG-0001
  name: string;
  description: string | null;
  status: 'active' | 'closed';
  start_date: string | null;
  due_date: string | null;
  my_role: GroupRole;
  nb_membres: number;
  nb_taches: number;
  tauxCompletude: number;
  prochaine_reunion: string | null; // AAAA-MM-JJTHH:MM (heure de Paris)
};

export type GroupProjectDetail = {
  id: string;
  ref: string;
  name: string;
  description: string | null;
  status: 'active' | 'closed';
  start_date: string | null;
  due_date: string | null;
  myRole: GroupRole;
  estResponsable: boolean;
  estChefDeProjet: boolean;
  members: GroupMember[];
  tasks: Task[];
  tauxCompletude: number;
};

export type DirectoryAccount = { id: string; display_name: string; email: string };

export type GroupMinute = {
  id: string;
  meeting_id: string | null;
  title: string;
  meeting_date: string;
  content: string;
  is_draft: boolean;
  author_account_id: string | null;
  author_name: string | null;
  updated_by_name: string | null;
  created_at: string;
  updated_at: string;
};

export type GroupMessage = {
  id: string;
  direction: 'sent' | 'reply';
  conversation_id: string;
  from_name: string | null;
  from_email: string | null;
  recipients: { name: string | null; email: string | null }[];
  subject: string | null;
  body: string | null;
  has_attachments: boolean;
  attachments_fetched: boolean;
  attachments_note: string | null;
  files: { id: string; filename: string }[];
  sent_at: string;
  mailbox_name: string | null;
};

export type GroupMeeting = {
  id: string;
  project_id: string;
  title: string;
  agenda: string | null;
  location: string | null;
  room_email: string | null;
  room_name: string | null;
  online: boolean;
  status: 'planned' | 'cancelled';
  start_at: string; // AAAA-MM-JJTHH:MM (heure de Paris)
  end_at: string;
  organizer_account_id: string;
  organizer_name: string | null;
  attendee_ids: string[];
  online_meeting_url: string | null;
  attendee_responses: Record<string, string> | null; // adresse -> réponse Outlook
  outlook_error: string | null;
  in_outlook: boolean;
  minute_id: string | null;
  minute_is_draft: boolean | null;
  past: boolean;
};

export type MeetingRoom = { email: string; name: string; capacity: number | null; building: string | null; floor: string | null };

export type BusyItem = { status: string; start: string; end: string }; // AAAA-MM-JJTHH:MM, heure de Paris

export type Availability = {
  weekStart: string;
  people: { account_id: string; display_name: string; email: string }[];
  schedules: { email: string; error: string | null; items: BusyItem[] }[];
};

// Projet IT de l'utilisateur, affiché de façon simplifiée dans Projets Groupe.
export type ItProjectSummary = {
  id: string;
  name: string;
  project_state: 'new' | 'in_progress' | 'maintenance' | 'closed' | null;
  start_date: string | null;
  due_date: string | null;
  nb_taches: number;
  mes_taches: number;
  tauxCompletude: number;
  mon_role: 'chef_de_projet' | 'equipe' | 'client';
};

// Les onglets partagés attendent des "Account" (équipe affectable).
export function membersAsTeam(members: GroupMember[]): Account[] {
  return members.map((m) => ({
    id: m.account_id,
    email: m.email || '',
    display_name: m.display_name,
    is_it: false,
    is_it_manager: false,
    is_rh: false,
    is_manager: false,
    is_director: false,
    weekly_capacity_hours: 35,
  }));
}

// "2026-10-08T14:30" -> "08/10/2026 14:30"
export function formatDateTime(value: string | null | undefined) {
  if (!value) return '';
  const [date, time] = value.split('T');
  const [y, m, d] = date.split('-');
  return `${d}/${m}/${y}${time ? ` ${time.slice(0, 5)}` : ''}`;
}
