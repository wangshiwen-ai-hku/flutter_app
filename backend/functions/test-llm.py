#!/usr/bin/env python3
"""
Test script for Gemini AI integration using Python
This script tests if the LLM service can successfully load the API key and make calls.

Usage:
    cd backend/functions
    export GEMINI_API_KEY="your_api_key_here"
    python test-llm.py
    or
    GEMINI_API_KEY=your_key python test-llm.py
"""

import os
import json
import sys
from typing import Optional
from dotenv import load_dotenv

load_dotenv()

try:
    import google.generativeai as genai
except ImportError:
    print("❌ Error: google-generativeai package not found")
    print("💡 Install it with: pip install google-generativeai")
    sys.exit(1)


def load_api_key() -> Optional[str]:
    """Load API key from environment variable"""
    api_key = os.getenv('GEMINI_API_KEY')

    if not api_key:
        print("❌ Error: GEMINI_API_KEY environment variable is not set")
        print("\n💡 Set your API key in one of these ways:")
        print("   1. Export environment variable:")
        print("      export GEMINI_API_KEY='your_api_key_here'")
        print("   2. Run with inline environment variable:")
        print("      GEMINI_API_KEY=your_key python test-llm.py")
        print("   3. Create a .env file with: GEMINI_API_KEY=your_key")
        print("\n🔑 Get your API key from: https://makersuite.google.com/app/apikey")
        return None

    return api_key


def test_llm_call(api_key: str) -> bool:
    """Test LLM call with a simple personality matching scenario"""
    print("🤖 Testing Gemini AI Integration...\n")

    try:
        # Configure the API, trying 'rest' transport which may help with some network/region issues.
        genai.configure(api_key=api_key, transport='rest')

        # Initialize the model
        model = genai.GenerativeModel('gemini-2.5-flash')
        print("✅ Gemini AI client initialized")

        # Test prompt - personality matching scenario
        test_prompt = """
You are a thoughtful matchmaker for an artistic social app. Analyze these two users and provide a compatibility score.

User A:
- Traits: storyteller, night owl
- Description: "Loves rainy nights and old books."

User B:
- Traits: listener, dreamer
- Description: "Finds magic in quiet moments and whispered stories."

Please provide:
1. A compatibility score from 0-100
2. A brief reason for this score (2-3 sentences)
3. Two conversation starter questions

Respond in JSON format:
{
  "score": number,
  "reason": "string explanation",
  "conversationStarters": ["question1", "question2"]
}
"""

        print("📤 Sending test prompt to Gemini AI...")

        # Make the API call
        response = model.generate_content(test_prompt)

        # Get the response text
        raw_text = response.text
        print("📥 Raw response from Gemini:")
        print(raw_text)
        print("\n" + "="*50 + "\n")

        # Try to parse JSON response
        try:
            # Clean the response - remove markdown code blocks if present
            json_text = raw_text
            if "```json" in raw_text:
                # Extract JSON from markdown code block
                start = raw_text.find("```json") + 7
                end = raw_text.find("```", start)
                json_text = raw_text[start:end].strip()
            elif "```" in raw_text:
                # Handle generic code blocks
                start = raw_text.find("```") + 3
                end = raw_text.find("```", start)
                json_text = raw_text[start:end].strip()

            parsed_response = json.loads(json_text)

            print("🎉 Test successful!")
            print(f"📊 Compatibility Score: {parsed_response.get('score', 'N/A')}")
            print(f"💬 Reason: {parsed_response.get('reason', 'N/A')}")

            if 'conversationStarters' in parsed_response:
                print("💭 Conversation Starters:")
                for i, question in enumerate(parsed_response['conversationStarters'], 1):
                    print(f"   {i}. {question}")

            return True

        except json.JSONDecodeError as e:
            print("⚠️  Response received but not in expected JSON format")
            print(f"JSON Parse Error: {e}")
            print("📝 Full response:")
            print(raw_text)
            return False

    except Exception as error:
        print(f"\n❌ Error testing Gemini AI: {error}")

        if "API_KEY_INVALID" in str(error):
            print("💡 Check if your API key is valid and has the correct format")
        elif "User location is not supported" in str(error):
            print("💡 Your current region may not be supported by the Gemini API via Google AI Studio.")
            print("   Check supported regions at: https://ai.google.dev/available-regions")
            print("   If you are using a VPN, ensure it's set to a supported location.")
            print("   As an alternative, consider using Google Cloud Vertex AI, which supports more regions.")
        elif "PERMISSION_DENIED" in str(error):
            print("💡 Check if your API key has the necessary permissions")
        elif "QUOTA_EXCEEDED" in str(error):
            print("💡 You may have exceeded your API quota")
        elif "INVALID_ARGUMENT" in str(error):
            print("💡 Check your request format and parameters")

        return False


def main():
    """Main test function"""
    print("🧪 Gemini AI LLM Test Script")
    print("="*40)

    # Load API key
    api_key = load_api_key()
    if not api_key:
        sys.exit(1)

    print("✅ API Key found (length: {})".format(len(api_key)))

    # Test the LLM call
    success = test_llm_call(api_key)

    if success:
        print("\n🎊 All tests passed! Your Gemini AI integration is working correctly.")
        sys.exit(0)
    else:
        print("\n❌ Test failed. Please check your configuration.")
        sys.exit(1)


if __name__ == "__main__":
    main()
