export async function getMicrosoftOnboardingServices(req, res) {
  try {
    const tenantId = process.env.MICROSOFT_TENANT_ID;
    const clientId = process.env.MICROSOFT_CLIENT_ID;
    const clientSecret = process.env.MICROSOFT_CLIENT_SECRET;

    if (!tenantId || !clientId || !clientSecret) {
      return res.status(500).json({
        error: 'Variables Microsoft manquantes'
      });
    }

    const tokenUrl =
      'https://' +
      'login.microsoftonline.com/' +
      tenantId +
      '/oauth2/v2.0/token';

    const tokenRes = await fetch(tokenUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        client_id: clientId,
        client_secret: clientSecret,
        scope: 'https://graph.microsoft.com/.default',
        grant_type: 'client_credentials'
      })
    });

    if (!tokenRes.ok) {
      const detail = await tokenRes.text();

      return res.status(500).json({
        error: 'Impossible d’obtenir le token Microsoft',
        detail
      });
    }

    const tokenJson = await tokenRes.json();

    const graphBase =
      'https://' +
      'graph.microsoft.com' +
      '/v1.0';

    let nextUrl =
      graphBase +
      '/groups?$select=id,displayName,mail&$top=999';

    const groups = [];

    while (nextUrl) {
      const graphRes = await fetch(nextUrl, {
        headers: {
          Authorization: `Bearer ${tokenJson.access_token}`
        }
      });

      if (!graphRes.ok) {
        const detail = await graphRes.text();

        return res.status(500).json({
          error: 'Erreur Graph lors de la récupération des groupes',
          detail
        });
      }

      const graphJson = await graphRes.json();

      for (const group of graphJson.value ?? []) {
        if (group.displayName?.startsWith('🏢')) {
          groups.push({
            id: group.id,
            displayName: group.displayName,
            mail: group.mail ?? null
          });
        }
      }

      nextUrl = graphJson['@odata.nextLink'] ?? null;
    }

    groups.sort((a, b) =>
      a.displayName.localeCompare(b.displayName, 'fr')
    );

    return res.json(groups);
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      error: error.message
    });
  }
}
