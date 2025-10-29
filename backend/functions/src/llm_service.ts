/**
 * @file A reusable service for interacting with the Google Generative AI API.
 * It handles API initialization, prompt execution, response parsing, and logging.
 */

import { GoogleGenerativeAI, GenerativeModel } from "@google/generative-ai";
import * as functions from "firebase-functions";
import { MatchmakerAgentResponse } from "./agents";

let model: GenerativeModel;

/**
 * Initializes the Generative AI model client.
 * It's configured to only generate text and uses the Gemini Pro model.
 */
function initializeLLM(): GenerativeModel {
  // Try to get API key from environment variable first, then fallback to Firebase config
  const apiKey = process.env.GEMINI_API_KEY || functions.config().gemini?.key;

  if (!apiKey) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The Gemini API key is not configured. Please set GEMINI_API_KEY environment variable or run 'firebase functions:config:set gemini.key=\"YOUR_API_KEY\"'"
    );
  }

  const genAI = new GoogleGenerativeAI(apiKey);
  return genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
}

/**
 * A generic function to call the LLM with a given prompt.
 * It logs the prompt and the raw response for debugging purposes.
 * It also handles parsing the expected JSON output from the LLM.
 *
 * @param prompt The complete prompt to send to the LLM.
 * @returns A promise that resolves to the parsed JSON object.
 */
export async function callAgent(
  prompt: string
): Promise<MatchmakerAgentResponse> {
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
    const parsedResponse = JSON.parse(jsonText) as MatchmakerAgentResponse;

    // Basic validation
    if (
      !parsedResponse.summary ||
      parsedResponse.totalScore === undefined ||
      !parsedResponse.similarFeatures ||
      // Check if similarFeatures is an object and has at least one key
      Object.keys(parsedResponse.similarFeatures).length === 0 ||
      // Check the structure of the first feature
      parsedResponse.similarFeatures[Object.keys(parsedResponse.similarFeatures)[0]].score === undefined ||
      !parsedResponse.similarFeatures[Object.keys(parsedResponse.similarFeatures)[0]].explanation
    ) {
      throw new Error("LLM response is missing or has invalid structure for required fields.");
    }

    return parsedResponse;
  } catch (error) {
    functions.logger.error("Error calling LLM or parsing response", { error });
    // If the LLM fails, throw an HttpsError to be caught by the client.
    throw new functions.https.HttpsError(
      "internal",
      "An error occurred while analyzing the match with the LLM."
    );
  }
}
