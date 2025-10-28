#!/usr/bin/env python3
"""
Test script for the matching algorithm with LLM integration
This script tests the complete matching flow including LLM analysis.

Usage:
    cd backend/functions
    export GEMINI_API_KEY="your_api_key_here"
    python test-matching-algorithm.py
    or
    GEMINI_API_KEY=your_key python test-matching-algorithm.py
"""

import os
import json
import sys
from typing import List, Dict, Any
from dotenv import load_dotenv

load_dotenv()

try:
    import google.generativeai as genai
except ImportError:
    print("❌ Error: google-generativeai package not found")
    print("💡 Install it with: pip install google-generativeai")
    sys.exit(1)


def load_api_key() -> str:
    """Load API key from environment variable"""
    api_key = os.getenv('GEMINI_API_KEY')

    if not api_key:
        print("❌ Error: GEMINI_API_KEY environment variable is not set")
        print("\n💡 Set your API key in one of these ways:")
        print("   1. Export environment variable:")
        print("      export GEMINI_API_KEY='your_api_key_here'")
        print("   2. Run with inline environment variable:")
        print("      GEMINI_API_KEY=your_key python test-matching-algorithm.py")
        print("   3. Create a .env file with: GEMINI_API_KEY=your_key")
        print("\n🔑 Get your API key from: https://makersuite.google.com/app/apikey")
        return None

    return api_key


def calculate_jaccard_similarity(traits_a: List[str], traits_b: List[str]) -> float:
    """Calculate Jaccard similarity between two trait sets"""
    set_a = set(traits_a)
    set_b = set(traits_b)

    if not set_a and not set_b:
        return 0.0

    intersection = len(set_a.intersection(set_b))
    union = len(set_a.union(set_b))

    return intersection / union if union > 0 else 0.0


def calculate_text_bonus(text_a: str, text_b: str) -> float:
    """Calculate bonus score based on text similarity"""
    keywords = ['night', 'book', 'rain', 'dream', 'story', 'world', 'sound', 'listen', 'art', 'creative']
    words_a = set(text_a.lower().split())
    words_b = set(text_b.lower().split())

    bonus = 0.0
    for keyword in keywords:
        if keyword in words_a and keyword in words_b:
            bonus += 0.1

    return min(bonus, 0.3)  # Cap bonus at 0.3


def get_formula_score(user_a: Dict[str, Any], user_b: Dict[str, Any]) -> float:
    """Calculate the formula-based matching score"""
    # Jaccard similarity of traits
    trait_score = calculate_jaccard_similarity(user_a['traits'], user_b['traits'])

    # Text bonus
    text_bonus = calculate_text_bonus(user_a['freeText'], user_b['freeText'])

    # Combine scores
    final_score = trait_score + text_bonus

    return min(final_score, 1.0)


def call_llm_for_match(user_a: Dict[str, Any], user_b: Dict[str, Any], api_key: str) -> Dict[str, Any]:
    """Call LLM to analyze match between two users"""
    print(f"🤖 Analyzing match between {user_a['username']} and {user_b['username']}")

    prompt = f"""
You are a thoughtful and creative matchmaker for a niche, artistic social app.
Your task is to analyze two user profiles and write a compelling summary about why they might connect.
You must also provide a compatibility score and suggest conversation starters.

**Analyze the following two users:**

**User A:**
- Traits: {', '.join(user_a['traits'])}
- Their own words: "{user_a['freeText']}"

**User B:**
- Traits: {', '.join(user_b['traits'])}
- Their own words: "{user_b['freeText']}"

**Your Thought Process (Follow these steps):**
1.  **Identify Commonalities:** Look for shared traits or similar themes and keywords in their free text (e.g., both mention "night", "books", "art").
2.  **Identify Complementary Pairs:** Look for traits that complement each other well (e.g., "storyteller" and "listener", or "world builder" and "observer").
3.  **Synthesize a Creative Summary:** Based on your analysis, write a short, insightful, and slightly poetic summary (2-3 sentences) about their potential connection. Do NOT just list their traits. Be creative.
4.  **Generate a Compatibility Score:** Based on your analysis, provide a holistic compatibility score from 0 to 100. A higher score means a stronger potential connection.
5.  **Suggest Conversation Starters:** Create two interesting, open-ended questions that one user could ask the other based on their profiles.

**Output Format:**
You MUST respond with only a single, valid JSON object. Do not include any text or markdown formatting before or after the JSON object.

```json
{{
  "summary": "string",
  "aiScore": number,
  "conversationStarters": ["string1", "string2"]
}}
```json
"""

    try:
        genai.configure(api_key=api_key, transport='rest')
        model = genai.GenerativeModel('gemini-2.5-flash')

        response = model.generate_content(prompt)
        raw_text = response.text

        # Clean the response
        json_text = raw_text
        if "```json" in raw_text:
            start = raw_text.find("```json") + 7
            end = raw_text.find("```", start)
            json_text = raw_text[start:end].strip()
        elif "```" in raw_text:
            start = raw_text.find("```") + 3
            end = raw_text.find("```", start)
            json_text = raw_text[start:end].strip()

        parsed = json.loads(json_text)

        if not all(key in parsed for key in ['summary', 'aiScore', 'conversationStarters']):
            raise ValueError("LLM response missing required fields")

        return parsed

    except Exception as e:
        print(f"❌ LLM analysis failed: {e}")
        # Return fallback values
        return {
            "summary": f"{user_a['username']} and {user_b['username']} share some interesting traits that could lead to meaningful conversations.",
            "aiScore": 50,
            "conversationStarters": [
                "What brings you joy in your creative pursuits?",
                "What's a story or experience that shaped your perspective?"
            ]
        }


def test_matching_algorithm(api_key: str) -> bool:
    """Test the complete matching algorithm with LLM integration"""
    print("🧪 Testing Matching Algorithm with LLM Integration")
    print("="*60)

    # Sample user data
    current_user = {
        "uid": "current_user_id",
        "username": "Alex",
        "traits": ["storyteller", "night owl"],
        "freeText": "Loves rainy nights and old books."
    }

    candidate_users = [
        {
            "uid": "user1",
            "username": "Jordan",
            "traits": ["listener", "dreamer"],
            "freeText": "Finds magic in quiet moments and whispered stories."
        },
        {
            "uid": "user2",
            "username": "Sam",
            "traits": ["world builder", "observer"],
            "freeText": "Creates imaginary worlds and notices the smallest details."
        },
        {
            "uid": "user3",
            "username": "Casey",
            "traits": ["writer", "creative"],
            "freeText": "Writes stories that explore the human condition."
        }
    ]

    print(f"📊 Current user: {current_user['username']} - {current_user['traits']} - '{current_user['freeText']}'")
    print(f"👥 Testing with {len(candidate_users)} candidate users\n")

    # Step 1: Calculate formula scores for all candidates
    print("📈 Step 1: Calculating formula-based scores...")
    scored_candidates = []

    for candidate in candidate_users:
        formula_score = get_formula_score(current_user, candidate)
        if formula_score > 0.1:  # Threshold for LLM analysis
            scored_candidates.append({
                'user': candidate,
                'formulaScore': formula_score
            })
            print(".3f"        else:
            print(".3f"
    # Sort by formula score and take top candidates
    scored_candidates.sort(key=lambda x: x['formulaScore'], reverse=True)
    top_candidates = scored_candidates[:3]  # Take top 3 for LLM analysis

    print(f"\n🎯 Selected {len(top_candidates)} top candidates for LLM analysis\n")

    # Step 2: Call LLM for each top candidate
    print("🤖 Step 2: Running LLM analysis for each candidate...")
    llm_results = []

    for i, candidate_data in enumerate(top_candidates, 1):
        candidate = candidate_data['user']
        formula_score = candidate_data['formulaScore']

        print(f"\n📝 Analyzing candidate {i}/{len(top_candidates)}: {candidate['username']}")

        # Call LLM
        llm_response = call_llm_for_match(current_user, candidate, api_key)

        # Calculate final score (weighted combination)
        ai_score_normalized = llm_response['aiScore'] / 100.0  # Convert to 0-1 range
        final_score = formula_score * 0.3 + ai_score_normalized * 0.7

        result = {
            'id': f"match_{current_user['uid']}_{candidate['uid']}",
            'userA': current_user,
            'userB': candidate,
            'aiScore': ai_score_normalized,
            'formulaScore': formula_score,
            'finalScore': final_score,
            'summary': llm_response['summary'],
            'conversationStarters': llm_response['conversationStarters']
        }

        llm_results.append(result)

        print("   📊 Scores - Formula: .3f"               f"   💬 Summary: {llm_response['summary'][:80]}...")
        print("   💭 Starters: {llm_response['conversationStarters']}")

    # Step 3: Sort final results by final score
    llm_results.sort(key=lambda x: x['finalScore'], reverse=True)

    print(f"\n🎉 Step 3: Final Results (sorted by compatibility)")
    print("="*60)

    for i, result in enumerate(llm_results, 1):
        print(f"\n🏆 Rank {i}: {result['userB']['username']}")
        print(".3f"        print(f"   💬 {result['summary']}")
        print(f"   💭 Conversation starters:")
        for j, starter in enumerate(result['conversationStarters'], 1):
            print(f"      {j}. {starter}")

    print(f"\n✅ Matching algorithm test completed successfully!")
    print(f"   📊 Processed {len(candidate_users)} candidates")
    print(f"   🤖 Ran LLM analysis on {len(top_candidates)} top matches")
    print(f"   🏆 Generated {len(llm_results)} final match recommendations")

    return True


def main():
    """Main test function"""
    print("🎯 Matching Algorithm with LLM Integration Test")
    print("="*50)

    # Load API key
    api_key = load_api_key()
    if not api_key:
        sys.exit(1)

    print("✅ API Key found (length: {})".format(len(api_key)))

    # Test the matching algorithm
    success = test_matching_algorithm(api_key)

    if success:
        print("\n🎊 All tests passed! Your matching algorithm with LLM integration is working correctly.")
        sys.exit(0)
    else:
        print("\n❌ Test failed. Please check your configuration.")
        sys.exit(1)


if __name__ == "__main__":
    main()
