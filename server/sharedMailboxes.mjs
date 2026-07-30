export async function getSharedMailboxes(req, res) {
  try {
    const tenantId = process.env.MICROSOFT_TENANT_ID;
    const clientId = process.env.MICROSOFT_CLIENT_ID;
    const clientSecret = process.env.MICROSOFT_CLIENT_SECRET;

    const tokenUrl =
      `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`;

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

    const tokenJson = await tokenRes.json();

    let nextUrl =
      'https://graph.microsoft.com/v1.0/users?$select=id,displayName,mail,userPrincipalName,accountEnabled&$top=999';

    const mailboxes = [];

    while (nextUrl) {
      const graphRes = await fetch(nextUrl, {
        headers: {
          Authorization: `Bearer ${tokenJson.access_token}`
        }
      });

      const graphJson = await graphRes.json();

      for (const user of graphJson.value ?? []) {
        if (
          user.mail &&
          user.accountEnabled === false &&
          user.userPrincipalName?.toLowerCase().endsWith('@elyade.com')
        ) {
          mailboxes.push({
            id: user.id,
            displayName: user.displayName,
            mail: user.mail,
            userPrincipalName: user.userPrincipalName
          });
        }
      }

      nextUrl = graphJson['@odata.nextLink'] ?? null;
    }

    mailboxes.sort((a, b) =>
      a.displayName.localeCompare(b.displayName, 'fr')
    );

    return res.json(mailboxes);

  } catch (error) {
    console.error(error);

    return res.status(500).json({
      error: error.message
    });
  }
}
