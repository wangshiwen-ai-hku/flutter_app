import 'package:flutter_app/models/match_profile.dart';

// A simple, local-only message model for the prototype.
class ChatMessage {
  final String author;
  final String text;
  final DateTime timestamp;

  ChatMessage({required this.author, required this.text, required this.timestamp});
}

/// Represents a full conversation with a matched profile.
class Conversation {
  final String id; // Unique ID, can be the profile's ID
  final MatchProfile partner;
  final List<ChatMessage> messages;
  bool isFavorited;

  Conversation({
    required this.id,
    required this.partner,
    this.messages = const [],
    this.isFavorited = false,
  });
}
