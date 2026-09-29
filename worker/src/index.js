// Function to convert PEM to ArrayBuffer
function pemToArrayBuffer(pem) {
  const b64Lines = pem.replace(/-----[A-Z ]+-----/g, '').replace(/\n/g, '');
  const byteStr = atob(b64Lines);
  const buf = new ArrayBuffer(byteStr.length);
  const bufView = new Uint8Array(buf);
  for (let i = 0, strLen = byteStr.length; i < strLen; i++) {
    bufView[i] = byteStr.charCodeAt(i);
  }
  return buf;
}

// Function to sign JWT using Web Crypto API
async function createSignedJWT(clientEmail, privateKeyPEM) {
  const header = { alg: 'RS256', typ: 'JWT' };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: clientEmail,
    scope: 'https://www.googleapis.com/auth/datastore https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  };

  const encode = (obj) => btoa(JSON.stringify(obj)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
  const unsignedToken = `${encode(header)}.${encode(payload)}`;

  const keyBuffer = pemToArrayBuffer(privateKeyPEM);
  const key = await crypto.subtle.importKey(
    'pkcs8',
    keyBuffer,
    { name: 'RSASSA-PKCS1-v1_5', hash: { name: 'SHA-256' } },
    false,
    ['sign']
  );

  const signatureBuffer = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, new TextEncoder().encode(unsignedToken));
  const signature = btoa(String.fromCharCode(...new Uint8Array(signatureBuffer))).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');

  return `${unsignedToken}.${signature}`;
}

async function getAccessToken(clientEmail, privateKeyPEM) {
  const jwt = await createSignedJWT(clientEmail, privateKeyPEM);
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`
  });
  const data = await res.json();
  if (!data.access_token) {
    throw new Error('Failed to fetch access token: ' + JSON.stringify(data));
  }
  return data.access_token;
}

async function checkPlantsAndNotify(env) {
  const projectId = 'window-garden-82313';
  if (!env.FIREBASE_CLIENT_EMAIL || !env.FIREBASE_PRIVATE_KEY) {
    console.error("Missing FIREBASE_CLIENT_EMAIL or FIREBASE_PRIVATE_KEY secret bindings.");
    return;
  }
  
  // Format private key (replace literal \n with actual newlines if necessary)
  const privateKey = env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n');
  const token = await getAccessToken(env.FIREBASE_CLIENT_EMAIL, privateKey);
  
  // 1. Fetch Firestore Documents (Saves Collection) using runQuery to only fetch expired timers
  const nowIso = new Date().toISOString();
  const firestoreUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents:runQuery`;
  
  const queryBody = {
    structuredQuery: {
      from: [{ collectionId: "saves" }],
      where: {
        fieldFilter: {
          field: { fieldPath: "next_notification_time" },
          op: "LESS_THAN_OR_EQUAL",
          value: { timestampValue: nowIso }
        }
      }
    }
  };

  const firestoreRes = await fetch(firestoreUrl, {
    method: 'POST',
    headers: { 
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(queryBody)
  });
  
  if (!firestoreRes.ok) {
     console.error("Failed to fetch firestore:", await firestoreRes.text());
     return;
  }
  
  const queryResults = await firestoreRes.json();
  if (!queryResults || queryResults.length === 0 || !queryResults[0].document) return; // No documents matched

  let notificationsSent = 0;

  for (const result of queryResults) {
    if (!result.document) continue;
    const doc = result.document;
    const docName = doc.name; // Full path e.g. projects/window-garden-82313/databases/(default)/documents/saves/UID
    const fields = doc.fields;
    if (!fields || !fields.fcmToken) continue;
    
    const fcmToken = fields.fcmToken.stringValue;
    
    // The app schedules next_notification_time for the moment a plant is *predicted* to
    // dry out or finish growing, and records which in next_notification_kind. The stored
    // plant values are from the last sync (before that moment), so re-checking them here
    // (water < 20, stage === 5) almost never matched and reminders were not sent.
    const kind = fields.next_notification_kind?.stringValue;

    try {
      const sendPush = async (title, body) => {
        const payload = {
          message: {
            token: fcmToken,
            notification: { title, body },
            webpush: { fcm_options: { link: "https://window-garden-82313.web.app" } }
          }
        };
        const res = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(payload)
        });
        if (res.ok) notificationsSent++;
        else console.error("FCM Send failed:", await res.text());
      };
      
      if (kind === 'grown') {
        await sendPush("A new leaf has blossomed ✨", "Your plant is fully grown. It's the perfect time to press a memory into your Botanist Journal.");
      } else if (kind === 'water') {
        await sendPush("A gentle reminder 💧", "Your little green friend is feeling parched. A gentle splash of water would make its day.");
      } else {
        // Saves written by older app versions have no kind.
        await sendPush("Your garden misses you 🌿", "Your plants may need some attention. Come take a look at your window garden.");
      }
      
      // 2. Push the next check far into the future until the app re-syncs. This also
      // applies when nothing was sent; otherwise the document matched on every run.
      {
        const patchUrl = `https://firestore.googleapis.com/v1/${docName}?updateMask.fieldPaths=next_notification_time`;
        await fetch(patchUrl, {
          method: 'PATCH',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            fields: {
              next_notification_time: { timestampValue: "3000-01-01T00:00:00Z" }
            }
          })
        });
      }
      
    } catch (e) {
      console.error("Error parsing document or sending push:", e);
    }
  }
  
  console.log(`Sent ${notificationsSent} notifications.`);
}

export default {
  async scheduled(controller, env, ctx) {
    ctx.waitUntil(
      checkPlantsAndNotify(env).catch(e => {
        console.error("Scheduled task failed:", e.message, e.stack);
      })
    );
  },
  
  // Manual trigger for testing. It sends real notifications to every due user, so it is
  // disabled unless MANUAL_TRIGGER_TOKEN is set and the request presents it.
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    if (request.method !== 'POST' || url.pathname !== '/run') {
      return new Response('Not found', { status: 404 });
    }
    const expected = env.MANUAL_TRIGGER_TOKEN;
    const auth = request.headers.get('Authorization') || '';
    if (!expected || !(await timingSafeEqual(auth, `Bearer ${expected}`))) {
      return new Response('Unauthorized', { status: 401 });
    }
    try {
      await checkPlantsAndNotify(env);
      return new Response('Window Garden notification run completed.', { status: 200 });
    } catch (e) {
      console.error('Manual run failed:', e.message, e.stack);
      return new Response('Run failed; see worker logs.', { status: 500 });
    }
  }
};

async function timingSafeEqual(a, b) {
  const enc = new TextEncoder();
  const [ha, hb] = await Promise.all([
    crypto.subtle.digest('SHA-256', enc.encode(a)),
    crypto.subtle.digest('SHA-256', enc.encode(b)),
  ]);
  const va = new Uint8Array(ha), vb = new Uint8Array(hb);
  let diff = 0;
  for (let i = 0; i < va.length; i++) diff |= va[i] ^ vb[i];
  return diff === 0;
}
