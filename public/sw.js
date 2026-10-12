// Service worker de l'application installée (PWA).
// Volontairement minimal : aucune donnée n'est mise en cache (l'application
// et ses données restent toujours à jour, la connexion Microsoft n'est pas
// perturbée). Sans réseau, une page « Hors connexion » remplace l'erreur du
// navigateur.

const OFFLINE_HTML = `<!doctype html>
<html lang="fr">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Hors connexion — Gestion IT</title>
<style>
  body { margin: 0; min-height: 100vh; display: flex; align-items: center; justify-content: center;
         background: #f6f7f9; color: #32373c; font-family: Inter, 'Segoe UI', system-ui, sans-serif; }
  .card { background: #fff; border: 1px solid #eceef1; border-radius: 12px; padding: 32px; max-width: 360px; text-align: center; }
  .logo { width: 48px; height: 48px; border-radius: 11px; background: #ca0088; color: #fff; font-weight: 700;
          font-size: 26px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; }
  h1 { font-size: 18px; margin: 0 0 8px; }
  p { font-size: 14px; color: #677082; margin: 0 0 20px; }
  button { background: #ca0088; color: #fff; border: 0; border-radius: 8px; padding: 10px 20px; font-weight: 600; cursor: pointer; }
</style>
</head>
<body>
  <div class="card">
    <div class="logo">E</div>
    <h1>Pas de connexion</h1>
    <p>Gestion IT a besoin d'une connexion au réseau. Vérifiez votre connexion puis réessayez.</p>
    <button onclick="location.reload()">Réessayer</button>
  </div>
</body>
</html>`;

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));

self.addEventListener('fetch', (event) => {
  const request = event.request;
  // Seules les pages (navigation) sont prises en charge ; API, connexion
  // Microsoft (/auth) et fichiers passent directement par le réseau.
  if (request.mode !== 'navigate') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin || url.pathname.startsWith('/auth') || url.pathname.startsWith('/api')) return;

  event.respondWith(
    fetch(request).catch(
      () => new Response(OFFLINE_HTML, { headers: { 'Content-Type': 'text/html; charset=utf-8' } })
    )
  );
});
