import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/models/match_analysis.dart';
import 'package:flutter_app/models/user_data.dart';
import 'package:flutter_app/pages/post_page.dart';
import 'package:flutter_app/services/api_service.dart';

/// A fake implementation of [ApiService] that loads a pre-generated set of mock data
/// for local development and testing.
///
/// This service simulates network latency and provides a rich user base from a JSON file,
/// allowing for rapid UI testing without a real backend.
/// When useLLM is enabled, it calls real LLM APIs for authentic match analysis.
class FakeApiService implements ApiService {
  final _latency = const Duration(milliseconds: 50);
  final Random _random = Random();
  final bool useLLM;
  final String? geminiApiKey;

  // --- Fake Data Store ---
  late final UserData _currentUser;
  List<UserData> _mockUsers = [];
  final List<Post> _publicPosts = [];

  /// Private constructor to be called by the async factory.
  FakeApiService._({
    required this.useLLM,
    this.geminiApiKey,
  });

  /// Async factory to create and initialize the service.
  static Future<FakeApiService> create({
    bool useLLM = false,
    String? geminiApiKey,
  }) async {
    final service = FakeApiService._(
      useLLM: useLLM,
      geminiApiKey: geminiApiKey,
    );
    await service._initialize();
    return service;
  }

  Future<void> _initialize() async {
    // The current user is static for now
    _currentUser = UserData(
      uid: 'current_user_id',
      username: 'You',
      portrait: null,
      traits: ['storyteller', 'night owl'],
      freeText: 'Loves rainy nights and old books.',
      userPosts: [],
    );

    // Load the pre-generated mock users from the JSON file
    try {
      final String usersJsonString = await rootBundle.loadString('assets/data/fake_users.json');
      final List<dynamic> usersJson = json.decode(usersJsonString);
      _mockUsers = usersJson.map((json) => UserData.fromJson(json)).toList();
      // Debug: Uncomment to confirm users loaded
      // print('Loaded ${_mockUsers.length} mock users successfully');
    } catch (e) {
      print('Error loading fake_users.json: $e');
      print('Did you forget to run `dart run scripts/generate_fake_data.dart`?');
      // If loading fails, continue with an empty list of users.
      _mockUsers = [];
    }

    // Create some initial public posts from the loaded users
    if (_mockUsers.isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        final author = _mockUsers[_random.nextInt(_mockUsers.length)];
        _publicPosts.add(
          Post(
            author: author.username,
            authorImageUrl: 'https://i.pravatar.cc/150?u=${author.uid}',
            content: author.freeText,
            likes: _random.nextInt(100),
            comments: _random.nextInt(20),
            mainAxisCellCount: 1.2 + _random.nextDouble() * 0.4,
          ),
        );
      }
    }
  }

  @override
  Future<UserData> getUser(String uid) async {
    await Future.delayed(_latency);
    if (uid == _currentUser.uid) {
      return _currentUser;
    }
    return _mockUsers.firstWhere((user) => user.uid == uid, orElse: () => _mockUsers.first);
  }

  @override
  Future<void> updateUser(UserData user) async {
    await Future.delayed(_latency);
    print('FakeApiService: Updating user ${user.uid}');
  }

  @override
  Future<List<Post>> getPublicPosts() async {
    await Future.delayed(_latency);
    return _publicPosts;
  }

  @override
  Future<List<Post>> getMyPosts(String uid) async {
    await Future.delayed(_latency);
    return _currentUser.userPosts;
  }

  @override
  Future<void> createPost(Post post) async {
    await Future.delayed(_latency);
    _currentUser.userPosts.insert(0, post);
    if (post.isPublic) {
      _publicPosts.insert(0, post);
    }
  }

  @override
  Future<List<MatchAnalysis>> getMatches(String uid) async {
    await Future.delayed(const Duration(milliseconds: 400));

    print('🧪 FakeApiService.getMatches called for uid: $uid');
    print('   LLM enabled: $useLLM, API key present: ${geminiApiKey != null}');
    print('   Current user traits: ${_currentUser.traits}');
    print('   Number of mock users: ${_mockUsers.length}');

    if (_mockUsers.isEmpty) {
      print('No mock users available');
      return [];
    }

    if (useLLM && geminiApiKey != null) {
      // Use LLM-powered matching
      return await _getMatchesWithLLM();
    } else {
      // Use traditional algorithm
      return await _getMatchesTraditional();
    }
  }

  Future<List<MatchAnalysis>> _getMatchesTraditional() async {
    print('🎭 Using traditional matching algorithm');

    final List<MapEntry<UserData, double>> scoredUsers = [];

    for (final mockUser in _mockUsers) {
      if (mockUser.uid == _currentUser.uid) continue;

      final userTraits = _currentUser.traits.toSet();
      final mockUserTraits = mockUser.traits.toSet();

      final intersection = userTraits.intersection(mockUserTraits).length;
      final union = userTraits.union(mockUserTraits).length;

      if (union == 0) continue;

      // Base score from traits
      double score = intersection / union;

      // Bonus score from free text analysis
      final textBonus = _calculateTextBonus(_currentUser.freeText, mockUser.freeText);
      score += textBonus;

      // Ensure score doesn't exceed 1.0
      score = score.clamp(0.0, 1.0);

      if (score > 0.15) { // Lowered threshold to get more diverse results
        scoredUsers.add(MapEntry(mockUser, score));
      }
    }

    scoredUsers.sort((a, b) => b.value.compareTo(a.value));

    final topMatches = scoredUsers.take(20);

    final matches = topMatches.map((entry) {
      final mockUser = entry.key;
      final score = entry.value;

      return MatchAnalysis(
        id: 'match_${mockUser.uid}',
        userA: _currentUser,
        userB: mockUser,
        aiScore: score,
        matchSummary: _generateMatchSummary(_currentUser, mockUser),
        traitCompatibility: {
          for (var trait in (_currentUser.traits.toSet()..addAll(mockUser.traits)).toList())
            trait: _random.nextDouble()
        },
        compatibilityChart: null,
        finalScore: score, // Use the calculated score as final score
        conversationStarters: _generateConversationStarters(_currentUser, mockUser),
        formulaScore: score, // Use the same score for formula score for now
      );
    }).toList();

    return matches;
  }

  Future<List<MatchAnalysis>> _getMatchesWithLLM() async {
    print('🤖 Using LLM-powered matching algorithm');

    // Step 1: Pre-filter candidates using traditional algorithm
    final List<MapEntry<UserData, double>> preFilteredCandidates = [];

    for (final mockUser in _mockUsers) {
      if (mockUser.uid == _currentUser.uid) continue;

      final userTraits = _currentUser.traits.toSet();
      final mockUserTraits = mockUser.traits.toSet();

      final intersection = userTraits.intersection(mockUserTraits).length;
      final union = userTraits.union(mockUserTraits).length;

      if (union == 0) continue;

      // Base score from traits
      double formulaScore = intersection / union;

      // Bonus score from free text analysis
      final textBonus = _calculateTextBonus(_currentUser.freeText, mockUser.freeText);
      formulaScore += textBonus;

      // Ensure score doesn't exceed 1.0
      formulaScore = formulaScore.clamp(0.0, 1.0);

      // Lower threshold for LLM analysis to get more diverse candidates
      if (formulaScore > 0.05) {
        preFilteredCandidates.add(MapEntry(mockUser, formulaScore));
      }
    }

    // Sort by formula score and take top 10 for LLM analysis
    preFilteredCandidates.sort((a, b) => b.value.compareTo(a.value));
    final topCandidates = preFilteredCandidates.take(10);

    print('📊 Pre-filtered ${topCandidates.length} candidates for LLM analysis');

    // Step 2: Call LLM for each candidate concurrently
    print('🤖 Starting concurrent LLM analysis for ${topCandidates.length} candidates...');

    // Show waiting messages with jokes
    _showWaitingMessages(topCandidates.length);

    final List<Future<MatchAnalysis>> matchFutures = topCandidates.map((candidateEntry) {
      final candidate = candidateEntry.key;
      final formulaScore = candidateEntry.value;

      return _analyzeMatchWithLLM(candidate, formulaScore);
    }).toList();

    // Wait for all LLM calls to complete
    final matches = await Future.wait(matchFutures);

    print('✅ All LLM analyses completed (${matches.length} matches)');

    // Sort by final score (highest first)
    matches.sort((a, b) => b.finalScore.compareTo(a.finalScore));

    print('🎯 Generated ${matches.length} matches with LLM analysis');
    return matches;
  }

  double _calculateTextBonus(String text1, String text2) {
    final keywords = ['night', 'book', 'rain', 'dream', 'story', 'world', 'sound', 'listen'];
    final words1 = text1.toLowerCase().split(' ');
    final words2 = text2.toLowerCase().split(' ');

    double bonus = 0;
    for (final keyword in keywords) {
      if (words1.contains(keyword) && words2.contains(keyword)) {
        bonus += 0.1;
      }
    }
    return bonus;
  }

  String _generateMatchSummary(UserData userA, UserData userB) {
    final sharedTraits = userA.traits.toSet().intersection(userB.traits.toSet());
    final complementaryPairs = [
      {'storyteller', 'listener'},
      {'world builder', 'observer'},
      {'writer', 'dream log'},
    ];
    final complementaryMatches = complementaryPairs.where((pair) {
      return (userA.traits.contains(pair.first) && userB.traits.contains(pair.last)) ||
             (userA.traits.contains(pair.last) && userB.traits.contains(pair.first));
    }).toList();

    if (sharedTraits.isNotEmpty) {
      return 'You and ${userB.username} both identify as a ${sharedTraits.first}. This shared perspective could be a great starting point for a deep conversation.';
    } else if (complementaryMatches.isNotEmpty) {
      final pair = complementaryMatches.first;
      return 'Your \'${pair.first}\' nature seems to be a perfect complement to ${userB.username}\'s \'${pair.last}\' side. You might find a fascinating dynamic between you.';
    } else {
      return 'You and ${userB.username} have different traits, which could lead to discovering new perspectives from each other.';
    }
  }

  List<String> _generateConversationStarters(UserData userA, UserData userB) {
    final starters = <String>[];

    // Generate conversation starters based on traits and descriptions
    final allTraits = {...userA.traits, ...userB.traits};

    if (allTraits.contains('storyteller') || allTraits.contains('writer')) {
      starters.add('What\'s the most interesting story you\'ve heard or told recently?');
    }
    if (allTraits.contains('dreamer') || allTraits.contains('dream log')) {
      starters.add('What do your dreams usually tell you about your waking life?');
    }
    if (allTraits.contains('night owl')) {
      starters.add('What do you love most about the quiet hours of the night?');
    }
    if (allTraits.contains('listener')) {
      starters.add('What\'s something you\'ve learned from really listening to someone?');
    }
    if (allTraits.contains('world builder')) {
      starters.add('If you could build any world, what would be the first thing you create?');
    }
    if (allTraits.contains('observer')) {
      starters.add('What details do you notice that others usually miss?');
    }

    // If we don't have enough trait-based starters, add some generic ones
    final genericStarters = [
      'What brings you the most joy in your creative pursuits?',
      'What\'s a book, movie, or experience that changed your perspective?',
      'If you could have dinner with any historical figure, who would it be?',
      'What\'s something you\'re passionate about that you wish more people understood?',
    ];

    // Fill up to 2 starters
    while (starters.length < 2 && genericStarters.isNotEmpty) {
      final starter = genericStarters[_random.nextInt(genericStarters.length)];
      if (!starters.contains(starter)) {
        starters.add(starter);
      }
    }

    return starters.take(2).toList();
  }

  /// Shows waiting messages with random jokes while LLM analysis is running
  void _showWaitingMessages(int candidateCount) {
    final jokes = [
      "💭 正在分析你们的灵魂契合度...",
      "😄 为什么程序员喜欢黑暗模式？因为光会引起bug！",
      "🔮 正在咨询AI占卜师...",
      "😂 为什么AI不会迷路？因为它总是有地图（map）！",
      "💫 正在计算你们的宇宙连接...",
      "🤖 AI正在思考：这个问题值得用一个神经网络吗？",
      "🌟 寻找你们的星座匹配...",
      "📚 正在翻阅命运之书...",
      "🎭 正在排练你们的相遇剧本...",
      "🎪 欢迎来到匹配马戏团！",
    ];

    print('⏳ 请稍等，我们正在为 $candidateCount 位候选人进行AI深度分析...');

    // Show a random joke
    final randomJoke = jokes[_random.nextInt(jokes.length)];
    print('🎭 $randomJoke');

    print('💡 提示：这可能需要几秒到几十秒，取决于网络和AI响应速度');
  }

  /// Analyzes a single match with LLM
  Future<MatchAnalysis> _analyzeMatchWithLLM(UserData candidate, double formulaScore) async {
    print('🔄 Analyzing match with ${candidate.username}...');

    // Call LLM API
    final llmResponse = await _callLLMForMatch(_currentUser, candidate);

    if (llmResponse != null) {
      // Convert AI score from 0-100 to 0.0-1.0
      final aiScore = (llmResponse['aiScore'] as num).toDouble() / 100.0;

      // Calculate final score (weighted combination)
      final finalScore = formulaScore * 0.3 + aiScore * 0.7;

      final match = MatchAnalysis(
        id: 'llm_match_${candidate.uid}',
        userA: _currentUser,
        userB: candidate,
        aiScore: aiScore.clamp(0.0, 1.0),
        matchSummary: llmResponse['summary'] ?? _generateMatchSummary(_currentUser, candidate),
        traitCompatibility: {
          for (var trait in (_currentUser.traits.toSet()..addAll(candidate.traits)).toList())
            trait: _random.nextDouble()
        },
        compatibilityChart: null,
        finalScore: finalScore.clamp(0.0, 1.0),
        conversationStarters: List<String>.from(llmResponse['conversationStarters'] ?? _generateConversationStarters(_currentUser, candidate)),
        formulaScore: formulaScore,
      );

      print('✅ LLM analysis completed for ${candidate.username}: AI=${aiScore.toStringAsFixed(2)}, Final=${finalScore.toStringAsFixed(2)}');
      return match;
    } else {
      print('⚠️ LLM analysis failed for ${candidate.username}, using fallback');
      // Fallback to traditional algorithm
      final match = MatchAnalysis(
        id: 'fallback_match_${candidate.uid}',
        userA: _currentUser,
        userB: candidate,
        aiScore: formulaScore,
        matchSummary: _generateMatchSummary(_currentUser, candidate),
        traitCompatibility: {
          for (var trait in (_currentUser.traits.toSet()..addAll(candidate.traits)).toList())
            trait: _random.nextDouble()
        },
        compatibilityChart: null,
        finalScore: formulaScore,
        conversationStarters: _generateConversationStarters(_currentUser, candidate),
        formulaScore: formulaScore,
      );
      return match;
    }
  }

  /// Calls the Gemini AI API to analyze a match between two users
  Future<Map<String, dynamic>?> _callLLMForMatch(UserData userA, UserData userB) async {
    if (!useLLM || geminiApiKey == null) {
      print('❌ LLM not enabled or API key missing');
      return null;
    }

    print('🔄 Calling LLM API for match: ${userA.username} ↔ ${userB.username}');
    print('   API Key length: ${geminiApiKey!.length}');
    print('   User A traits: ${userA.traits}');
    print('   User B traits: ${userB.traits}');

    try {
      final prompt = '''
You are a thoughtful and creative matchmaker for a niche, artistic social app.
Your task is to analyze two user profiles and write a compelling summary about why they might connect.
You must also provide a compatibility score and suggest conversation starters.

**Analyze the following two users:**

**User A:**
- Traits: ${userA.traits.join(", ")}
- Their own words: "${userA.freeText}"

**User B:**
- Traits: ${userB.traits.join(", ")}
- Their own words: "${userB.freeText}"

**Your Thought Process (Follow these steps):**
1.  **Identify Commonalities:** Look for shared traits or similar themes and keywords in their free text (e.g., both mention "night", "books", "art").
2.  **Identify Complementary Pairs:** Look for traits that complement each other well (e.g., "storyteller" and "listener", or "world builder" and "observer").
3.  **Synthesize a Creative Summary:** Based on your analysis, write a short, insightful, and slightly poetic summary (2-3 sentences) about their potential connection. Do NOT just list their traits. Be creative.
4.  **Generate a Compatibility Score:** Based on your analysis, provide a holistic compatibility score from 0 to 100. A higher score means a stronger potential connection.
5.  **Suggest Conversation Starters:** Create two interesting, open-ended questions that one user could ask the other based on their profiles.

**Output Format:**
You MUST respond with only a single, valid JSON object. Do not include any text or markdown formatting before or after the JSON object.

```json
{
  "summary": "string",
  "aiScore": number,
  "conversationStarters": ["string1", "string2"]
}
```
''';

      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiApiKey';
      print('🌐 API URL: $url');

      final requestBody = {
        'contents': [{
          'parts': [{
            'text': prompt
          }]
        }]
      };

      print('📤 Request body length: ${json.encode(requestBody).length} characters');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response headers: ${response.headers}');
      print('📥 Response body length: ${response.body.length} characters');

      if (response.statusCode == 200) {
        print('✅ API call successful, parsing response...');

        try {
          final data = json.decode(response.body);
          print('📋 Parsed JSON keys: ${data.keys.toList()}');

          if (data.containsKey('candidates') && data['candidates'].isNotEmpty) {
            final candidate = data['candidates'][0];
            print('👤 Candidate keys: ${candidate.keys.toList()}');

            if (candidate.containsKey('content') && candidate['content'].containsKey('parts')) {
              final parts = candidate['content']['parts'];
              if (parts.isNotEmpty) {
                final rawText = parts[0]['text'];
                print('📝 Raw LLM response: $rawText');

                // Clean the response
                final jsonText = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
                print('🧹 Cleaned JSON text: $jsonText');

                final parsed = json.decode(jsonText);
                print('🎯 Parsed response keys: ${parsed.keys.toList()}');

                if (parsed.containsKey('summary') && parsed.containsKey('aiScore') && parsed.containsKey('conversationStarters')) {
                  print('✅ LLM response validation passed');
                  return parsed;
                } else {
                  print('❌ LLM response missing required fields: summary, aiScore, conversationStarters');
                  print('   Available fields: ${parsed.keys.toList()}');
                }
              } else {
                print('❌ No parts in content');
              }
            } else {
              print('❌ Missing content or parts in candidate');
            }
          } else {
            print('❌ No candidates in response or candidates is empty');
          }
        } catch (parseError) {
          print('❌ Error parsing LLM response: $parseError');
          print('   Raw response body: ${response.body}');
        }
      } else {
        print('❌ API call failed with status ${response.statusCode}');

        // Try to parse error response
        try {
          final errorData = json.decode(response.body);
          print('❌ Error response: $errorData');

          if (errorData.containsKey('error')) {
            final error = errorData['error'];
            print('❌ Error code: ${error['code']}');
            print('❌ Error message: ${error['message']}');
            print('❌ Error status: ${error['status']}');
          }
        } catch (errorParseError) {
          print('❌ Could not parse error response: $errorParseError');
          print('   Raw error response: ${response.body}');
        }

        // Check for common issues
        if (response.statusCode == 400) {
          print('💡 Status 400: Check request format or API key validity');
        } else if (response.statusCode == 401) {
          print('💡 Status 401: API key is invalid or expired');
        } else if (response.statusCode == 403) {
          print('💡 Status 403: API key does not have required permissions');
        } else if (response.statusCode == 404) {
          print('💡 Status 404: Model endpoint not found - check model name');
        } else if (response.statusCode == 429) {
          print('💡 Status 429: Rate limit exceeded');
        } else if (response.statusCode == 500) {
          print('💡 Status 500: Server error - try again later');
        }
      }

      print('🚫 LLM API call failed, returning null');
      return null;
    } catch (e, stackTrace) {
      print('💥 Exception calling LLM API: $e');
      print('   Stack trace: $stackTrace');

      if (e.toString().contains('SocketException')) {
        print('💡 Network error - check internet connection');
      } else if (e.toString().contains('TimeoutException')) {
        print('💡 Request timeout - API may be slow or unreachable');
      }

      return null;
    }
  }
}