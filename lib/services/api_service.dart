import 'package:flutter_app/models/match_analysis.dart';
import 'package:flutter_app/models/user_data.dart';
import 'package:flutter_app/pages/post_page.dart';

/// Defines the contract for all data operations in the app.
/// This abstract class can be implemented by a fake local service for debugging
/// or a real backend service (e.g., Firebase) for production.
abstract class ApiService {
  /// Retrieves a user's complete profile data.
  Future<UserData> getUser(String uid);

  /// Updates a user's profile data.
  Future<void> updateUser(UserData user);

  /// Fetches the public feed of posts from the community.
  Future<List<Post>> getPublicPosts();

  /// Fetches all posts created by a specific user.
  Future<List<Post>> getMyPosts(String uid);

  /// Generates or retrieves a list of potential matches for the user,
  /// complete with detailed AI analysis for each.
  Future<List<MatchAnalysis>> getMatches(String uid);

  /// Gets cached match results if available, otherwise returns empty list.
  /// Used for quickly viewing previous match results without recomputing.
  Future<List<MatchAnalysis>> getCachedMatches(String uid);

  /// Updates the current user's traits and free text for matching purposes.
  /// This is mainly used by the fake service to get real-time user input.
  void updateCurrentUserTraits(List<String> traits, String freeText);

  /// Creates a new post.
  Future<void> createPost(Post post);

  // Future<void> saveConversation(Conversation conversation);
  // Future<List<Conversation>> getConversations(String uid);
}
