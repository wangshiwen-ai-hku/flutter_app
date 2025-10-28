
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Sends a chat message and stores it in Firestore.
 */
export const sendMessage = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { conversationId, message } = data;
  const uid = context.auth.uid;

  const conversationRef = db.collection("conversations").doc(conversationId);
  const messageRef = conversationRef.collection("messages").doc();

  await messageRef.set({
    ...message,
    senderId: uid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});

/**
 * Gets all conversations for the current user.
 */
export const getConversations = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const uid = context.auth.uid;
  const conversationsSnapshot = await db.collection("conversations").where("participants", "array-contains", uid).get();

  const conversations = conversationsSnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));

  return { conversations };
});
