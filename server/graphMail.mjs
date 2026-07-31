export async function getGraphAppToken() {
  const tenantId = process.env.MICROSOFT_TENANT_ID;
  const clientId = process.env.MICROSOFT_CLIENT_ID;
  const clientSecret = process.env.MICROSOFT_CLIENT_SECRET;

  const tokenRes = await fetch(
    `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`,
    {
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
    }
  );

  if (!tokenRes.ok) {
    const detail = await tokenRes.text();
    throw new Error(
      `Erreur token Microsoft Graph : ${detail}`
    );
  }

  const tokenJson = await tokenRes.json();

  return tokenJson.access_token;
}

export async function sendMailWithAttachments({
  to,
  subject,
  html,
  attachments = []
}) {
  const token = await getGraphAppToken();

  const graphRes = await fetch(
    'https://graph.microsoft.com/v1.0/users/informatique@elyade.com/sendMail',
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        message: {
          subject,
          body: {
            contentType: 'HTML',
            content: html
          },
          toRecipients: [
            {
              emailAddress: {
                address: to
              }
            }
          ],
          attachments
        },
        saveToSentItems: true
      })
    }
  );

  if (!graphRes.ok) {
    const detail = await graphRes.text();

    throw new Error(
      `Erreur envoi mail Microsoft Graph : ${detail}`
    );
  }

  return true;
}
