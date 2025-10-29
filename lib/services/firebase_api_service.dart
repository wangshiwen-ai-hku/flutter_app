import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/models/match_analysis.dart';
import 'package:flutter_app/models/user_data.dart';
import 'package:flutter_app/pages/post_page.dart';
import 'package:flutter_app/services/api_service.dart';

/// Production implementation of [ApiService] that communicates with Firebase backend.
/// This service calls Firebase Cloud Functions for AI-powered operations.
class FirebaseApiService implements ApiService {
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseApiService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _functions = functions ?? FirebaseFunctions.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserData> getUser(String uid) async {
    // For now, return mock data - you'll need to implement Firestore integration
    throw UnimplementedError('Firestore user fetching not yet implemented');
  }

  @override
  Future<void> updateUser(UserData user) async {
    // For now, do nothing - you'll need to implement Firestore integration
    throw UnimplementedError('Firestore user updating not yet implemented');
  }

  @override
  void updateCurrentUserTraits(List<String> traits, String freeText) {
    // For Firebase service, this method doesn't need to do anything since
    // the user's traits are stored in Firestore and retrieved by the backend
    // when getMatches is called. The backend should use the latest user data.
    print('FirebaseApiService: updateCurrentUserTraits called - traits will be used by backend');
  }

  @override
  Future<List<Post>> getPublicPosts() async {
    // For now, return mock data - you'll need to implement Firestore integration
    return [];
  }

  @override
  Future<List<Post>> getMyPosts(String uid) async {
    // For now, return mock data - you'll need to implement Firestore integration
    return [];
  }

  @override
  Future<List<MatchAnalysis>> getMatches(String uid) async {
    try {
      // Ensure user is authenticated
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('🔥 Calling Firebase Cloud Function getMatches for user: $uid');

      // Call the Cloud Function to generate matches with LLM analysis
      final callable = _functions.httpsCallable('getMatches');
      final result = await callable.call();

      print('Cloud Function result: $result');

      // Fetch the generated matches from Firestore
      final matchesRef = _firestore.collection('matches').doc(uid).collection('candidates');
      final snapshot = await matchesRef.get();

      final matches = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Processing match data: ${doc.id}');
        try {
          final match = MatchAnalysis.fromJson(data);
          print('Successfully parsed match: ${match.id}, totalScore: ${match.totalScore}');
          return match;
        } catch (e) {
          print('Error parsing match data for ${doc.id}: $e');
          print('Raw data: $data');
          rethrow;
        }
      }).toList();

      // Sort matches by final score (highest first)
      matches.sort((a, b) => b.totalScore.compareTo(a.totalScore));

      print('🎯 Retrieved ${matches.length} matches from Firestore with LLM analysis');
      return matches;

    } catch (e) {
      print('❌ Error in getMatches: $e');
      // In production, you might want to fallback to a simpler matching algorithm
      // For now, rethrow the error
      rethrow;
    }
  }

  @override
  Future<List<MatchAnalysis>> getCachedMatches(String uid) async {
    // For Firebase service, caching is handled by the backend
    // For now, just return empty list as this feature is mainly for development
    print('FirebaseApiService: getCachedMatches not implemented yet');
    return [];
  }

  @override
  Future<void> createPost(Post post) async {
    // For now, do nothing - you'll need to implement Firestore integration
    throw UnimplementedError('Firestore post creation not yet implemented');
  }
}
