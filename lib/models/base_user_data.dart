import 'dart:typed_data';

/// Base user data model with only pure Dart compatible fields
/// This can be shared between Flutter app and standalone scripts
class BaseUserData {
  final String uid;
  final String username;
  final List<String> traits;
  final String freeText;
  final List<String> followedBloggerIds;
  final List<String> favoritedPostIds;
  final List<String> favoritedConversationIds;

  BaseUserData({
    required this.uid,
    required this.username,
    this.traits = const [],
    this.freeText = '',
    this.followedBloggerIds = const [],
    this.favoritedPostIds = const [],
    this.favoritedConversationIds = const [],
  });

  factory BaseUserData.fromJson(Map<String, dynamic> json) => BaseUserData(
        uid: json["uid"],
        username: json["username"],
        traits: List<String>.from(json["traits"].map((x) => x)),
        freeText: json["freeText"],
        followedBloggerIds: List<String>.from(json["followedBloggerIds"].map((x) => x)),
        favoritedPostIds: List<String>.from(json["favoritedPostIds"].map((x) => x)),
        favoritedConversationIds: List<String>.from(json["favoritedConversationIds"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "username": username,
        "traits": List<dynamic>.from(traits.map((x) => x)),
        "freeText": freeText,
        "followedBloggerIds": List<dynamic>.from(followedBloggerIds.map((x) => x)),
        "favoritedPostIds": List<dynamic>.from(favoritedPostIds.map((x) => x)),
        "favoritedConversationIds": List<dynamic>.from(favoritedConversationIds.map((x) => x)),
      };
}
