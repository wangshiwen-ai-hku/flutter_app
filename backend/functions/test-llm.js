#!/usr/bin/env node

/**
 * Test script for Gemini AI integration
 * This script tests if the LLM service can successfully load the API key and make calls.
 *
 * Usage:
 *   cd backend/functions
 *   export GEMINI_API_KEY="your_api_key_here"
 *   node test-llm.js
 */

require('dotenv').config(); // Load environment variables from .env file

const { GoogleGenerativeAI } = require('@google/generative-ai');

async function testLLMSearch() {
  console.log('🤖 Testing Gemini AI Integration...\n');

  // Check if API key is available
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    console.error('❌ Error: GEMINI_API_KEY environment variable is not set');
    console.log('💡 Please set your API key:');
    console.log('   export GEMINI_API_KEY="your_api_key_here"');
    console.log('   Or create a .env file with: GEMINI_API_KEY=your_api_key_here');
    process.exit(1);
  }

  console.log('✅ API Key found');

  try {
    // Initialize the Gemini AI client
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

    console.log('✅ Gemini AI client initialized');

    // Test prompt - simple personality matching scenario
    const testPrompt = `
You are a thoughtful matchmaker for an artistic social app. Analyze these two users and provide a compatibility score.

User A: Traits - storyteller, night owl. Description: "Loves rainy nights and old books."

User B: Traits - listener, dreamer. Description: "Finds magic in quiet moments and whispered stories."

Provide a compatibility score from 0-100 and a brief reason why.
Respond in JSON format: {"score": number, "reason": "string"}
`;

    console.log('📤 Sending test prompt to Gemini AI...');

    const result = await model.generateContent(testPrompt);
    const response = await result.response;
    const rawText = response.text();

    console.log('📥 Raw response from Gemini:', rawText);

    // Try to parse JSON response
    try {
      const jsonResponse = JSON.parse(rawText.match(/```json([\s\S]*?)```/)?.[1] || rawText);
      console.log('\n🎉 Test successful!');
      console.log('📊 Compatibility Score:', jsonResponse.score || jsonResponse.aiScore);
      console.log('💬 Reason:', jsonResponse.reason || jsonResponse.summary);
    } catch (parseError) {
      console.log('\n⚠️  Response received but not in expected JSON format');
      console.log('📝 Full response:', rawText);
    }

  } catch (error) {
    console.error('\n❌ Error testing Gemini AI:', error.message);

    if (error.message.includes('API_KEY_INVALID')) {
      console.log('💡 Check if your API key is valid and has the correct format');
    } else if (error.message.includes('PERMISSION_DENIED')) {
      console.log('💡 Check if your API key has the necessary permissions');
    } else if (error.message.includes('QUOTA_EXCEEDED')) {
      console.log('💡 You may have exceeded your API quota');
    }
  }
}

// Run the test
testLLMSearch().catch(console.error);
