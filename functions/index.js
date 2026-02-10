const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { DateTime } = require('luxon');

admin.initializeApp();

const TIMEZONE = 'Asia/Kolkata';

function formatCountMessage(title, count) {
  if (count <= 0) return null;
  return {
    title,
    body: `Count: ${count}`,
  };
}

function formatNamesMessage(title, count, names) {
  if (count <= 0) return null;
  if (!names || names.length === 0) {
    return formatCountMessage(title, count);
  }
  const maxNames = 5;
  const shown = names.slice(0, maxNames);
  const remaining = count - shown.length;
  const suffix = remaining > 0 ? ` + ${remaining} more` : '';
  return {
    title,
    body: `${shown.join(', ')}${suffix}`,
  };
}

async function fetchUserNames(ownerId, userIds) {
  const uniqueIds = [...new Set(userIds)].filter(Boolean);
  if (uniqueIds.length === 0) return [];

  const nameMap = new Map();
  const chunkSize = 10;
  const collections = ['OldUser', 'NewUser'];

  for (let i = 0; i < uniqueIds.length; i += chunkSize) {
    const chunk = uniqueIds.slice(i, i + chunkSize);
    await Promise.all(
      collections.map(async (collection) => {
        const snap = await admin
          .firestore()
          .collection(collection)
          .where('ownerId', '==', ownerId)
          .where('id', 'in', chunk)
          .get();
        snap.forEach((doc) => {
          const data = doc.data() || {};
          const id = data.id;
          const name = data.name;
          if (id && name && !nameMap.has(id)) {
            nameMap.set(id, name);
          }
        });
      })
    );
  }

  return uniqueIds
    .map((id) => nameMap.get(id))
    .filter((name) => typeof name === 'string' && name.trim().length > 0);
}

async function sendToTokens(tokens, message) {
  if (!tokens || tokens.length === 0 || !message) return;
  await admin.messaging().sendEachForMulticast({
    tokens,
    notification: message,
  });
}

exports.sendDailyAlerts = functions.pubsub
  .schedule('0 6 * * *')
  .timeZone(TIMEZONE)
  .onRun(async () => {
    const now = DateTime.now().setZone(TIMEZONE);
    const start = now.startOf('day');
    const end = now.endOf('day');

    const tokensSnapshot = await admin
      .firestore()
      .collection('UserTokens')
      .get();

    const tasks = [];

    tokensSnapshot.forEach((doc) => {
      const data = doc.data() || {};
      const ownerId = data.ownerId;
      const tokens = Array.isArray(data.tokens) ? data.tokens : [];

      if (!ownerId || tokens.length === 0) return;

      const dueQuery = admin
        .firestore()
        .collection('PaymentRecords')
        .where('ownerId', '==', ownerId)
        .where('PENDING_DATE', '>=', start.toJSDate())
        .where('PENDING_DATE', '<=', end.toJSDate());

      const expiryQuery = admin
        .firestore()
        .collection('PaymentRecords')
        .where('ownerId', '==', ownerId)
        .where('EXPIRED_AT', '>=', start.toJSDate())
        .where('EXPIRED_AT', '<=', end.toJSDate());

      const task = Promise.all([dueQuery.get(), expiryQuery.get()]).then(
        async ([dueSnap, expSnap]) => {
          const dueCount = dueSnap.size;
          const expCount = expSnap.size;

          const dueIds = dueSnap.docs
            .map((doc) => (doc.data() || {}).USER_ID)
            .filter(Boolean);
          const expIds = expSnap.docs
            .map((doc) => (doc.data() || {}).USER_ID)
            .filter(Boolean);

          const [dueNames, expNames] = await Promise.all([
            fetchUserNames(ownerId, dueIds),
            fetchUserNames(ownerId, expIds),
          ]);

          const dueMessage = formatNamesMessage(
            'இன்று பணம் தர வேண்டியவர்கள்',
            dueCount,
            dueNames
          );
          const expMessage = formatNamesMessage(
            'இன்று ரீசார்ஜ் முடியும் வாடிக்கையாளர்கள்',
            expCount,
            expNames
          );

          await sendToTokens(tokens, dueMessage);
          await sendToTokens(tokens, expMessage);
        }
      );

      tasks.push(task);
    });

    await Promise.all(tasks);
    return null;
  });
