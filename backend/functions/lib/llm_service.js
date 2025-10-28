"use strict";
/**
 * @file A reusable service for interacting with the Google Generative AI API.
 * It handles API initialization, prompt execution, response parsing, and logging.
 */
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
exports.callAgent = callAgent;
const generative_ai_1 = require("@google/generative-ai");
const functions = __importStar(require("firebase-functions"));
let model;
/**
 * Initializes the Generative AI model client.
 * It's configured to only generate text and uses the Gemini Pro model.
 */
function initializeLLM() {
    // Try to get API key from environment variable first, then fallback to Firebase config
    const apiKey = process.env.GEMINI_API_KEY || functions.config().gemini?.key;
    if (!apiKey) {
        throw new functions.https.HttpsError("failed-precondition", "The Gemini API key is not configured. Please set GEMINI_API_KEY environment variable or run 'firebase functions:config:set gemini.key=\"YOUR_API_KEY\"'");
    }
    const genAI = new generative_ai_1.GoogleGenerativeAI(apiKey);
    return genAI.getGenerativeModel({ model: "gemini-pro" });
}
/**
 * A generic function to call the LLM with a given prompt.
 * It logs the prompt and the raw response for debugging purposes.
 * It also handles parsing the expected JSON output from the LLM.
 *
 * @param prompt The complete prompt to send to the LLM.
 * @returns A promise that resolves to the parsed JSON object.
 */
async function callAgent(prompt) {
    // Ensure the model is initialized, but only once.
    if (!model) {
        model = initializeLLM();
    }
    functions.logger.info("Calling LLM with prompt...", { prompt });
    try {
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const rawText = response.text();
        functions.logger.info("Received LLM response", { rawText });
        // Clean the response to extract only the JSON part.
        const jsonText = rawText.match(/```json([\s\S]*?)```/)?.[1] ?? rawText;
        const parsedResponse = JSON.parse(jsonText);
        // Basic validation
        if (!parsedResponse.summary ||
            !parsedResponse.aiScore ||
            !parsedResponse.conversationStarters) {
            throw new Error("LLM response is missing required fields.");
        }
        return parsedResponse;
    }
    catch (error) {
        functions.logger.error("Error calling LLM or parsing response", { error });
        // If the LLM fails, throw an HttpsError to be caught by the client.
        throw new functions.https.HttpsError("internal", "An error occurred while analyzing the match with the LLM.");
    }
}
//# sourceMappingURL=llm_service.js.map