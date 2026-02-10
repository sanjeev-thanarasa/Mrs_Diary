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

          const dueMessage = formatCountMessage(
            'இன்று பணம் தர வேண்டியவர்கள்',
            dueCount
          );
          const expMessage = formatCountMessage(
            'இன்று ரீசார்ஜ் முடியும் வாடிக்கையாளர்கள்',
            expCount
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
