import { X } from 'lucide-react';
import ClientPicker from './ClientPicker';
import type { Account } from './types';

export type SelectedClient = { id: string; label: string; email?: string | null };

// Clients d'un projet : un badge par client et une recherche pour en ajouter.
// Les identifiants sont ceux des comptes Microsoft (= app_accounts.id).
export default function ClientsEditor({ clients, selected, onAdd, onRemove, disabled = false }: {
  clients: Account[];
  selected: SelectedClient[];
  onAdd: (clientAccountId: string) => void;
  onRemove: (clientAccountId: string) => void;
  disabled?: boolean;
}) {
  const available = clients.filter((client) => !selected.some((item) => item.id === client.id));
  return (
    <div className="flex flex-wrap items-center gap-2">
      {selected.map((item) => (
        <span key={item.id} className="badge bg-elyade-50 text-elyade-800 gap-1.5" title={item.email || undefined}>
          {item.label}
          <button
            type="button"
            disabled={disabled}
            className="text-elyade-400 hover:text-red-600"
            aria-label={`Retirer ${item.label}`}
            onClick={() => onRemove(item.id)}
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </span>
      ))}
      <ClientPicker
        className="w-80"
        clients={available}
        value=""
        onChange={(clientAccountId) => {
          if (clientAccountId) onAdd(clientAccountId);
        }}
      />
    </div>
  );
}
