import { useRef } from 'react';
import { Paperclip, X } from 'lucide-react';

// Limites alignées sur le serveur (multer : 25 Mo par fichier, 10 fichiers).
export const MAX_FILE_SIZE = 25 * 1024 * 1024;
export const MAX_FILES = 10;

// Sélection de pièces jointes avant envoi : liste des fichiers choisis,
// avec contrôle de taille et de nombre.
export default function FilePicker({ files, onChange, label = 'Ajouter des pièces jointes' }: {
  files: File[];
  onChange: (files: File[]) => void;
  label?: string;
}) {
  const input = useRef<HTMLInputElement>(null);

  function add(selected: FileList | null) {
    if (!selected) return;
    const tooBig = Array.from(selected).filter((file) => file.size > MAX_FILE_SIZE);
    if (tooBig.length) alert(`Fichier(s) trop volumineux (25 Mo maximum) : ${tooBig.map((f) => f.name).join(', ')}`);
    const next = [...files, ...Array.from(selected).filter((file) => file.size <= MAX_FILE_SIZE)];
    if (next.length > MAX_FILES) alert(`${MAX_FILES} pièces jointes maximum.`);
    onChange(next.slice(0, MAX_FILES));
    if (input.current) input.current.value = '';
  }

  return (
    <div>
      <input ref={input} type="file" multiple className="hidden" onChange={(e) => add(e.target.files)} />
      <button type="button" className="btn-ghost text-sm" onClick={() => input.current?.click()}>
        <Paperclip className="w-4 h-4" /> {label}
      </button>
      {files.length > 0 && (
        <ul className="mt-2 space-y-1">
          {files.map((file, index) => (
            <li key={`${file.name}-${index}`} className="flex items-center gap-2 text-sm text-ink-700">
              <Paperclip className="w-3 h-3 text-ink-400" />
              <span className="truncate flex-1">{file.name}</span>
              <span className="text-xs text-ink-400">{(file.size / 1024 / 1024).toFixed(1)} Mo</span>
              <button
                type="button"
                className="text-ink-400 hover:text-red-600"
                aria-label={`Retirer ${file.name}`}
                onClick={() => onChange(files.filter((_, i) => i !== index))}
              >
                <X className="w-4 h-4" />
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
