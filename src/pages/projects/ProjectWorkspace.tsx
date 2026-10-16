import { useEffect, useState } from 'react';
import { request } from './api';
import { groupApi } from '../group/groupApi';
import MeetingsTab from '../group/tabs/MeetingsTab';
import MinutesTab from '../group/tabs/MinutesTab';
import CommunicationsTab from '../group/tabs/CommunicationsTab';
import type { GroupProjectDetail } from '../group/types';

// Réunions, comptes rendus et communications d'un projet IT : mêmes onglets
// que les Projets Groupe, sur l'espace d'échange du projet (membres = équipe
// et clients du projet, destinataires des invitations et des mails).
export type WorkspaceTab = 'meetings' | 'minutes' | 'communications';

export default function ProjectWorkspace({
  projectId,
  tab,
  onTabChange,
}: {
  projectId: string;
  tab: WorkspaceTab;
  onTabChange: (tab: WorkspaceTab) => void;
}) {
  const [workspace, setWorkspace] = useState<GroupProjectDetail | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [minuteForMeeting, setMinuteForMeeting] = useState<{ id: string; title: string; date: string; minuteId: string | null } | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        // L'espace est créé au besoin et ses membres sont resynchronisés avec l'équipe et les clients.
        const { workspaceId } = await request(`/api/projects/${projectId}/workspace`);
        const detail = await groupApi.getProject(workspaceId);
        if (!cancelled) {
          setWorkspace(detail);
          setError(null);
        }
      } catch (err: any) {
        if (!cancelled) setError(err.message || 'Espace du projet indisponible');
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [projectId]);

  if (error) return <p className="text-sm text-red-600">{error}</p>;
  if (!workspace) return <p className="text-sm text-ink-500">Chargement…</p>;

  return (
    <div>
      <p className="text-xs text-ink-500 mb-3">
        Participants et destinataires : l'équipe du projet et ses clients ({workspace.members.map((m) => m.display_name).join(', ')}).
      </p>
      {tab === 'meetings' && (
        <MeetingsTab
          project={workspace}
          onWriteMinutes={(meeting) => {
            setMinuteForMeeting({ id: meeting.id, title: meeting.title, date: meeting.start_at.slice(0, 10), minuteId: meeting.minute_id });
            onTabChange('minutes');
          }}
        />
      )}
      {tab === 'minutes' && <MinutesTab project={workspace} prefillMeeting={minuteForMeeting} onPrefillUsed={() => setMinuteForMeeting(null)} />}
      {tab === 'communications' && <CommunicationsTab project={workspace} />}
    </div>
  );
}
