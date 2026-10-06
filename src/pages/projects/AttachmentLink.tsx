import { useEffect, useState } from 'react';
import { Download, Paperclip, X } from 'lucide-react';
import type { ProjectFile } from './types';

const IMAGE_EXT = ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'];
// Doit rester aligné sur INLINE_PREVIEW_TYPES côté serveur (server/projects.mjs).
const FRAME_EXT = ['pdf', 'txt', 'log', 'csv', 'json', 'md'];

function extensionOf(filename: string) {
  return filename.split('.').pop()?.toLowerCase() ?? '';
}

// Lien de pièce jointe : ouvre un aperçu (images, PDF, texte) au lieu de
// télécharger directement ; les autres formats proposent le téléchargement.
export default function AttachmentLink({ file, className = '' }: { file: ProjectFile; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button
        type="button"
        onClick={(e) => { e.stopPropagation(); setOpen(true); }}
        className={`flex items-center gap-1 text-elyade-700 hover:underline text-left min-w-0 ${className}`}
        title={`Aperçu de ${file.filename}`}
      >
        <Paperclip className="w-3.5 h-3.5 shrink-0" /> <span className="truncate">{file.filename}</span>
      </button>
      {open && <AttachmentPreview file={file} onClose={() => setOpen(false)} />}
    </>
  );
}

function AttachmentPreview({ file, onClose }: { file: ProjectFile; onClose: () => void }) {
  const ext = extensionOf(file.filename);
  const downloadUrl = `/api/projects/files/${file.id}/download`;
  const inlineUrl = `${downloadUrl}?inline=1`;
  const isImage = IMAGE_EXT.includes(ext);
  const isFramed = FRAME_EXT.includes(ext);

  useEffect(() => {
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        event.stopPropagation();
        onClose();
      }
    };
    // Capture : la touche Échap ferme l'aperçu sans fermer le panneau de tâche dessous.
    window.addEventListener('keydown', onKey, true);
    return () => window.removeEventListener('keydown', onKey, true);
  }, [onClose]);

  return (
    <div
      className="fixed inset-0 z-[60] flex items-center justify-center bg-black/60 p-4"
      onClick={(e) => { e.stopPropagation(); onClose(); }}
    >
      <div className="bg-white rounded-xl shadow-xl w-full max-w-5xl h-[90vh] flex flex-col" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between gap-3 px-4 py-3 border-b border-ink-100">
          <p className="font-medium text-ink-900 truncate">{file.filename}</p>
          <div className="flex items-center gap-1 shrink-0">
            <a href={downloadUrl} className="btn-ghost text-sm">
              <Download className="w-4 h-4" /> Télécharger
            </a>
            <button type="button" className="btn-ghost p-1.5" onClick={onClose} aria-label="Fermer">
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>
        <div className="flex-1 min-h-0 bg-ink-50 rounded-b-xl overflow-auto flex items-center justify-center">
          {isImage && <img src={inlineUrl} alt={file.filename} className="max-w-full max-h-full object-contain" />}
          {isFramed && <iframe src={inlineUrl} title={file.filename} className="w-full h-full bg-white rounded-b-xl" />}
          {!isImage && !isFramed && (
            <div className="text-center p-8">
              <p className="text-sm text-ink-600 mb-4">Aperçu non disponible pour ce type de fichier (.{ext || '?'}).</p>
              <a href={downloadUrl} className="btn-primary text-sm">
                <Download className="w-4 h-4" /> Télécharger le fichier
              </a>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
