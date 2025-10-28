import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { callAgent } from "./llm_service";
import { matchmakerAgentPrompt } from "./agents";

export * from "./chat_service";

// Initialize the Firebase Admin SDK.
admin.initializeApp();

interface UserData {
  uid: string;
  username: string;
  traits: string[];
  freeText: string;
  // Add other fields from your Firestore document as needed
}

export const getMatches = functions.https.onCall(async (data, context) => {
  // 1. Authenticate the user.
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }
  const uid = context.auth.uid;

  // 2. Fetch the current user and all other users from Firestore.
  const db = admin.firestore();
  const usersCollection = db.collection("users");

  const currentUserDoc = await usersCollection.doc(uid).get();
  if (!currentUserDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Current user not found.");
  }
  const currentUser = currentUserDoc.data() as UserData;

  const allUsersSnapshot = await usersCollection.get();
  const allUsers = allUsersSnapshot.docs.map((doc) => doc.data() as UserData);

  // 3. Run the initial deterministic matching algorithm.
  const scoredUsers: { user: UserData; score: number }[] = [];
  for (const otherUser of allUsers) {
    if (otherUser.uid === uid) continue;

    const userTraits = new Set(currentUser.traits);
    const otherUserTraits = new Set(otherUser.traits);
    const intersection = new Set([...userTraits].filter((x) => otherUserTraits.has(x))).size;
    const union = new Set([...userTraits, ...otherUserTraits]).size;

    if (union === 0) continue;

    const score = intersection / union;
    if (score > 0.1) { // A low threshold to get a decent pool for the LLM
      scoredUsers.push({ user: otherUser, score });
    }
  }

  // Sort by score and take the top 20 for LLM analysis.
  scoredUsers.sort((a, b) => b.score - a.score);
  const topCandidates = scoredUsers.slice(0, 20);

  // 4. Concurrently call the LLM Agent for each candidate.
  const llmPromises = topCandidates.map(async (candidate) => {
    const prompt = matchmakerAgentPrompt(currentUser, candidate.user);
    try {
      const llmResponse = await callAgent(prompt);
      const formulaScore = candidate.score;
      const aiScore = llmResponse.aiScore / 100; // Normalize AI score to 0-1

      // Calculate a weighted final score
      const finalScore = formulaScore * 0.3 + aiScore * 0.7;

      return {
        ...llmResponse,
        formulaScore,
        finalScore,
        userA: currentUser,
        userB: candidate.user,
        id: `match_${uid}_${candidate.user.uid}` // Create a unique ID
      };
    } catch (error) {
      functions.logger.error(
        `LLM analysis failed for match ${uid} - ${candidate.user.uid}`,
        { error }
      );
      return null; // Return null if a single LLM call fails
    }
  });

  const llmResults = (await Promise.all(llmPromises)).filter(
    (result) => result !== null
  ) as any[];

  // 5. Save the rich analysis results back to Firestore.
  const batch = db.batch();
  const matchesCollection = db.collection("matches").doc(uid).collection("candidates");

  llmResults.forEach((result) => {
    const docRef = matchesCollection.doc(result.userB.uid);
    batch.set(docRef, result);
  });

  await batch.commit();

  functions.logger.info(`Successfully generated and saved ${llmResults.length} matches for user ${uid}.`);

  return { success: true, matchesFound: llmResults.length };
});
