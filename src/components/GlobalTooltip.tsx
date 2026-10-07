import { useEffect, useState } from 'react';

type Tip = { text: string; left: number; top: number; above: boolean; align: 'left' | 'center' | 'right' };

const SELECTOR = '[title], [data-tip-text], button[aria-label], a[aria-label]';

// Infobulle de l'application : remplace l'infobulle native (lente et peu
// visible) pour tout élément portant un title, et pour les boutons-icônes
// décrits par aria-label. Un seul composant, monté une fois dans App.
export default function GlobalTooltip() {
  const [tip, setTip] = useState<Tip | null>(null);

  useEffect(() => {
    let current: HTMLElement | null = null;
    let timer: number | undefined;

    function restoreTitle(el: HTMLElement | null) {
      if (el?.dataset.tipText !== undefined) {
        el.setAttribute('title', el.dataset.tipText);
        delete el.dataset.tipText;
      }
    }

    function hide() {
      window.clearTimeout(timer);
      restoreTitle(current);
      current = null;
      setTip(null);
    }

    function onOver(event: MouseEvent) {
      const el = (event.target as HTMLElement | null)?.closest<HTMLElement>(SELECTOR) ?? null;
      if (el === current) return;
      hide();
      if (!el) return;

      let text = el.getAttribute('title');
      if (text) {
        // Le title est retiré le temps du survol pour éviter la double infobulle.
        el.dataset.tipText = text;
        el.removeAttribute('title');
      } else {
        // aria-label seul : uniquement pour les boutons sans texte visible (icône).
        if (el.textContent?.trim()) return;
        text = el.getAttribute('aria-label');
      }
      if (!text?.trim()) return;

      current = el;
      timer = window.setTimeout(() => {
        if (current !== el || !el.isConnected) return;
        const rect = el.getBoundingClientRect();
        const above = rect.bottom + 48 > window.innerHeight;
        const center = rect.left + rect.width / 2;
        // Près d'un bord : bulle alignée sur l'élément plutôt que centrée.
        const align = center < 170 ? 'left' : center > window.innerWidth - 170 ? 'right' : 'center';
        setTip({
          text,
          left: align === 'left' ? rect.left : align === 'right' ? rect.right : center,
          top: above ? rect.top - 6 : rect.bottom + 6,
          above,
          align,
        });
      }, 200);
    }

    document.addEventListener('mouseover', onOver);
    document.addEventListener('mousedown', hide);
    document.addEventListener('keydown', hide);
    window.addEventListener('scroll', hide, true);
    window.addEventListener('blur', hide);
    return () => {
      hide();
      document.removeEventListener('mouseover', onOver);
      document.removeEventListener('mousedown', hide);
      document.removeEventListener('keydown', hide);
      window.removeEventListener('scroll', hide, true);
      window.removeEventListener('blur', hide);
    };
  }, []);

  if (!tip) return null;
  return (
    <div
      role="tooltip"
      className="fixed z-[100] pointer-events-none max-w-xs rounded-md bg-ink-900/95 px-2 py-1 text-xs leading-snug text-white shadow-lg whitespace-pre-line"
      style={{
        left: tip.left,
        top: tip.top,
        transform: `translate(${tip.align === 'left' ? '0' : tip.align === 'right' ? '-100%' : '-50%'}, ${tip.above ? '-100%' : '0'})`,
      }}
    >
      {tip.text}
    </div>
  );
}
