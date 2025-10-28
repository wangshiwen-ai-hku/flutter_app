"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.getMatches = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const llm_service_1 = require("./llm_service");
const agents_1 = require("./agents");
// Initialize the Firebase Admin SDK.
admin.initializeApp();
exports.getMatches = functions.https.onCall(async (data, context) => {
    // 1. Authenticate the user.
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const uid = context.auth.uid;
    // 2. Fetch the current user and all other users from Firestore.
    const db = admin.firestore();
    const usersCollection = db.collection("users");
    const currentUserDoc = await usersCollection.doc(uid).get();
    if (!currentUserDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Current user not found.");
    }
    const currentUser = currentUserDoc.data();
    const allUsersSnapshot = await usersCollection.get();
    const allUsers = allUsersSnapshot.docs.map((doc) => doc.data());
    // 3. Run the initial deterministic matching algorithm.
    const scoredUsers = [];
    for (const otherUser of allUsers) {
        if (otherUser.uid === uid)
            continue;
        const userTraits = new Set(currentUser.traits);
        const otherUserTraits = new Set(otherUser.traits);
        const intersection = new Set([...userTraits].filter((x) => otherUserTraits.has(x))).size;
        const union = new Set([...userTraits, ...otherUserTraits]).size;
        if (union === 0)
            continue;
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
        const prompt = (0, agents_1.matchmakerAgentPrompt)(currentUser, candidate.user);
        try {
            const llmResponse = await (0, llm_service_1.callAgent)(prompt);
            return {
                ...llmResponse,
                userA: currentUser,
                userB: candidate.user,
                id: `match_${uid}_${candidate.user.uid}` // Create a unique ID
            };
        }
        catch (error) {
            functions.logger.error(`LLM analysis failed for match ${uid} - ${candidate.user.uid}`, { error });
            return null; // Return null if a single LLM call fails
        }
    });
    const llmResults = (await Promise.all(llmPromises)).filter((result) => result !== null);
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
//# sourceMappingURL=index.js.map