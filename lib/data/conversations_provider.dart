import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/conversation.dart';
import 'package:flutter_app/models/match_profile.dart';

/// A global provider to manage the state of all conversations in the app.
///
/// It uses the ChangeNotifier mixin to notify listening widgets of any changes.
class ConversationsProvider with ChangeNotifier {
  final Map<String, Conversation> _conversations = {};

  /// Returns a list of all conversations, sorted by the most recent message.
  List<Conversation> get allConversations {
    final sortedList = _conversations.values.toList();
    sortedList.sort((a, b) {
      if (a.messages.isEmpty || b.messages.isEmpty) return 0;
      return b.messages.last.timestamp.compareTo(a.messages.last.timestamp);
    });
    return sortedList;
  }

  /// Returns a filtered list of only favorited conversations.
  List<Conversation> get favoritedConversations => allConversations.where((c) => c.isFavorited).toList();

  /// Adds a new message to a conversation.
  ///
  /// If the conversation doesn't exist, it creates a new one.
  void addMessage(MatchProfile partner, ChatMessage message) {
    if (!_conversations.containsKey(partner.id)) {
      _conversations[partner.id] = Conversation(id: partner.id, partner: partner);
    }
    _conversations[partner.id]!.messages.add(message);
    notifyListeners();
  }

  /// Toggles the favorite status of a conversation.
  void toggleFavorite(String conversationId) {
    if (_conversations.containsKey(conversationId)) {
      _conversations[conversationId]!.isFavorited = !_conversations[conversationId]!.isFavorited;
      notifyListeners();
    }
  }
}

// A global singleton instance of the provider.
final conversationsProvider = ConversationsProvider();
