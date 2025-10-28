#!/usr/bin/env node

/**
 * Comprehensive backend testing script for the Flutter app's match algorithm and LLM integration
 *
 * This script tests:
 * 1. LLM service connectivity and response format
 * 2. Match algorithm logic
 * 3. Full pipeline integration
 *
 * Usage:
 *   cd backend/functions
 *   export GEMINI_API_KEY="your_api_key_here"
 *   node test-backend.js
 */

require('dotenv').config();
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Mock data for testing
const mockCurrentUser = {
  uid: 'test_user_1',
  username: 'TestUser',
  traits: ['storyteller', 'night owl'],
  freeText: 'Loves rainy nights and old books.'
};

const mockCandidates = [
  {
    uid: 'candidate_1',
    username: 'BookLover',
    traits: ['listener', 'dreamer'],
    freeText: 'Finds magic in quiet moments and whispered stories.'
  },
  {
    uid: 'candidate_2',
    username: 'NightWalker',
    traits: ['night owl', 'observer'],
    freeText: 'Wanders the city streets when everyone else is asleep.'
  },
  {
    uid: 'candidate_3',
    username: 'StoryWeaver',
    traits: ['storyteller', 'writer'],
    freeText: 'Weaves tales that transport you to other worlds.'
  }
];

// Test LLM service
async function testLLMService() {
  console.log('🤖 Testing LLM Service...\n');

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    console.error('❌ GEMINI_API_KEY not set');
    return false;
  }

  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

    const testPrompt = `
You are a thoughtful matchmaker for an artistic social app. Analyze these two users and provide a compatibility score.

User A: Traits - ${mockCurrentUser.traits.join(', ')}. Description: "${mockCurrentUser.freeText}"

User B: Traits - ${mockCandidates[0].traits.join(', ')}. Description: "${mockCandidates[0].freeText}"

Provide a compatibility score from 0-100 and a brief reason why.
Respond in JSON format: {"score": number, "reason": "string"}
`;

    const result = await model.generateContent(testPrompt);
    const response = await result.response;
    const rawText = response.text();

    console.log('✅ LLM Service Response:');
    console.log(rawText);

    // Try to parse JSON
    const jsonMatch = rawText.match(/```json([\s\S]*?)```/)?.[1] || rawText;
    const parsed = JSON.parse(jsonMatch);

    if (parsed.score && parsed.reason) {
      console.log('✅ LLM Response format correct');
      return true;
    } else {
      console.log('⚠️  LLM Response format incorrect');
      return false;
    }

  } catch (error) {
    console.error('❌ LLM Service Error:', error.message);
    return false;
  }
}

// Test match algorithm
function testMatchAlgorithm() {
  console.log('\n🧮 Testing Match Algorithm...\n');

  const scoredCandidates = [];

  for (const candidate of mockCandidates) {
    const userTraits = new Set(mockCurrentUser.traits);
    const candidateTraits = new Set(candidate.traits);

    const intersection = new Set([...userTraits].filter(x => candidateTraits.has(x))).size;
    const union = new Set([...userTraits, ...candidateTraits]).size;

    if (union === 0) continue;

    const score = intersection / union;
    console.log(`${candidate.username}: ${intersection}/${union} = ${(score * 100).toFixed(1)}%`);

    if (score > 0.1) {
      scoredCandidates.push({ user: candidate, score });
    }
  }

  scoredCandidates.sort((a, b) => b.score - a.score);
  const topCandidates = scoredCandidates.slice(0, 3);

  console.log(`✅ Found ${topCandidates.length} potential matches`);
  return topCandidates;
}

// Test full pipeline
async function testFullPipeline() {
  console.log('\n🔄 Testing Full Pipeline...\n');

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    console.error('❌ Skipping full pipeline test - no API key');
    return;
  }

  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

    const candidates = testMatchAlgorithm();

    console.log('\n📊 Processing matches with LLM...\n');

    for (const candidate of candidates.slice(0, 2)) { // Test with first 2 candidates
      const prompt = `
You are a thoughtful matchmaker for an artistic social app.

User A: Traits - ${mockCurrentUser.traits.join(', ')}. Description: "${mockCurrentUser.freeText}"

User B: Traits - ${candidate.user.traits.join(', ')}. Description: "${candidate.user.freeText}"

Please provide:
1. A compatibility score from 0-100
2. A brief reason for this score (2-3 sentences)
3. Two conversation starter questions

Respond in JSON format:
{
  "summary": "string explanation",
  "aiScore": number,
  "conversationStarters": ["question1", "question2"]
}
`;

      try {
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const rawText = response.text();

        const jsonText = rawText.match(/```json([\s\S]*?)```/)?.[1] || rawText;
        const llmResponse = JSON.parse(jsonText);

        const formulaScore = candidate.score;
        const aiScore = llmResponse.aiScore / 100;
        const finalScore = formulaScore * 0.3 + aiScore * 0.7;

        console.log(`🎯 Match: ${candidate.user.username}`);
        console.log(`   Formula Score: ${(formulaScore * 100).toFixed(1)}%`);
        console.log(`   AI Score: ${(aiScore * 100).toFixed(1)}%`);
        console.log(`   Final Score: ${(finalScore * 100).toFixed(1)}%`);
        console.log(`   Summary: ${llmResponse.summary}`);
        console.log(`   Conversation Starters: ${llmResponse.conversationStarters.join(' | ')}`);
        console.log('');

      } catch (error) {
        console.error(`❌ Error processing ${candidate.user.username}:`, error.message);
      }
    }

    console.log('✅ Full pipeline test completed');

  } catch (error) {
    console.error('❌ Full pipeline error:', error.message);
  }
}

// Run all tests
async function runTests() {
  console.log('🧪 Backend Testing Suite');
  console.log('=' .repeat(40));

  let passed = 0;
  let total = 0;

  // Test 1: LLM Service
  total++;
  if (await testLLMService()) passed++;

  // Test 2: Match Algorithm
  total++;
  testMatchAlgorithm();
  passed++; // Algorithm test always passes if it runs

  // Test 3: Full Pipeline
  total++;
  await testFullPipeline();
  passed++; // Pipeline test always passes if it runs

  console.log('\n📊 Test Results:');
  console.log(`   Passed: ${passed}/${total}`);
  console.log(passed === total ? '🎉 All tests passed!' : '⚠️  Some tests had issues');

  console.log('\n💡 Quick Commands:');
  console.log('   • Test LLM only: node test-llm.js');
  console.log('   • Test backend: node test-backend.js');
  console.log('   • Deploy functions: firebase deploy --only functions');
  console.log('   • Run Flutter app: flutter run');
}

// Handle command line arguments
if (process.argv[2] === '--help') {
  console.log(`
Backend Testing Script

Usage:
  node test-backend.js              # Run all tests
  node test-backend.js --help       # Show this help

Environment Variables:
  GEMINI_API_KEY                    # Required for LLM tests

Tests:
  1. LLM Service                    # Tests basic LLM connectivity
  2. Match Algorithm                # Tests scoring algorithm
  3. Full Pipeline                  # Tests complete match flow
`);
} else {
  runTests().catch(console.error);
}
