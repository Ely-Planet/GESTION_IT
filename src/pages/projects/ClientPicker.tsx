import { useEffect, useMemo, useRef, useState } from 'react';
import { Search, X } from 'lucide-react';
import type { Account } from './types';

const MAX_RESULTS = 50;

// Comparaison sans accents ni majuscules : "eloise" trouve "Éloïse".
function normalize(value: string) {
  return value.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase();
}

// Choix du client d'un projet par recherche sur le prénom, le nom ou l'e-mail.
export default function ClientPicker({
  clients,
  value,
  currentLabel,
  onChange,
  className = '',
}: {
  clients: Account[];
  value: string;
  currentLabel?: string | null;
  onChange: (clientAccountId: string) => void;
  className?: string;
}) {
  const [query, setQuery] = useState('');
  const [open, setOpen] = useState(false);
  const [highlighted, setHighlighted] = useState(0);
  const container = useRef<HTMLDivElement>(null);

  const selected = clients.find((client) => client.id === value);
  const selectedLabel = selected ? `${selected.display_name} (${selected.email})` : currentLabel || '';

  const results = useMemo(() => {
    // Chaque mot tapé doit se retrouver dans le nom ou l'e-mail, dans n'importe quel ordre.
    const words = normalize(query).split(/\s+/).filter(Boolean);
    const matches = words.length
      ? clients.filter((client) => {
          const haystack = normalize(`${client.display_name} ${client.email}`);
          return words.every((word) => haystack.includes(word));
        })
      : clients;
    return matches.slice(0, MAX_RESULTS);
  }, [clients, query]);

  useEffect(() => {
    function onClickOutside(event: MouseEvent) {
      if (container.current && !container.current.contains(event.target as Node)) setOpen(false);
    }
    document.addEventListener('mousedown', onClickOutside);
    return () => document.removeEventListener('mousedown', onClickOutside);
  }, []);

  function choose(clientAccountId: string) {
    onChange(clientAccountId);
    setQuery('');
    setOpen(false);
  }

  function onKeyDown(event: React.KeyboardEvent<HTMLInputElement>) {
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      setOpen(true);
      setHighlighted((index) => Math.min(index + 1, results.length - 1));
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      setHighlighted((index) => Math.max(index - 1, 0));
    } else if (event.key === 'Enter') {
      event.preventDefault();
      if (open && results[highlighted]) choose(results[highlighted].id);
    } else if (event.key === 'Escape') {
      setOpen(false);
      setQuery('');
    }
  }

  return (
    <div ref={container} className={`relative ${className}`}>
      <div className="relative">
        <Search className="w-4 h-4 text-ink-400 absolute left-2.5 top-1/2 -translate-y-1/2 pointer-events-none" />
        <input
          className="input text-sm py-1.5 pl-8 pr-8"
          placeholder={selectedLabel || 'Rechercher un client (nom, prénom, e-mail)…'}
          value={open ? query : selectedLabel}
          onFocus={() => {
            setOpen(true);
            setQuery('');
            setHighlighted(0);
          }}
          onChange={(e) => {
            setQuery(e.target.value);
            setOpen(true);
            setHighlighted(0);
          }}
          onKeyDown={onKeyDown}
        />
        {value && (
          <button
            type="button"
            className="absolute right-2 top-1/2 -translate-y-1/2 text-ink-400 hover:text-red-600"
            aria-label="Retirer le client"
            title="Retirer le client"
            onClick={() => choose('')}
          >
            <X className="w-4 h-4" />
          </button>
        )}
      </div>

      {open && (
        <ul className="absolute z-40 mt-1 w-full max-h-72 overflow-y-auto rounded-lg border border-ink-200 bg-white shadow-elevated py-1">
          {results.length === 0 && <li className="px-3 py-2 text-sm text-ink-400">Aucun résultat pour « {query} »</li>}
          {results.map((client, index) => (
            <li key={client.id}>
              <button
                type="button"
                className={`w-full text-left px-3 py-1.5 text-sm ${index === highlighted ? 'bg-elyade-50' : ''} ${client.id === value ? 'font-medium text-elyade-700' : 'text-ink-800'}`}
                onMouseEnter={() => setHighlighted(index)}
                onMouseDown={(e) => e.preventDefault()}
                onClick={() => choose(client.id)}
              >
                {client.display_name}
                <span className="text-ink-400"> — {client.email}</span>
              </button>
            </li>
          ))}
          {results.length === MAX_RESULTS && (
            <li className="px-3 py-1.5 text-xs text-ink-400">Affinez la recherche pour voir plus de résultats.</li>
          )}
        </ul>
      )}
    </div>
  );
}
