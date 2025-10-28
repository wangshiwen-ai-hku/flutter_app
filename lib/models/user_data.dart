import 'dart:typed_data';
import 'package:flutter_app/pages/post_page.dart';
import 'base_user_data.dart';

/// A comprehensive data model for a user's profile and activities within the app.
/// Extends BaseUserData to inherit common fields that are shared with scripts.
class UserData extends BaseUserData {
  final Uint8List? portrait; // The user's hand-drawn portrait
  final List<Post> userPosts; // Posts created by the user

  UserData({
    required super.uid,
    required super.username,
    this.portrait,
    super.traits,
    super.freeText,
    super.followedBloggerIds,
    super.favoritedPostIds,
    this.userPosts = const [],
    super.favoritedConversationIds,
  });

  // Method to create a copy with updated values, useful for state management.
  UserData copyWith({
    String? username,
    Uint8List? portrait,
    List<String>? traits,
    String? freeText,
    List<String>? followedBloggerIds,
    List<String>? favoritedPostIds,
    List<Post>? userPosts,
    List<String>? favoritedConversationIds,
  }) {
    return UserData(
      uid: uid,
      username: username ?? this.username,
      portrait: portrait ?? this.portrait,
      traits: traits ?? this.traits,
      freeText: freeText ?? this.freeText,
      followedBloggerIds: followedBloggerIds ?? this.followedBloggerIds,
      favoritedPostIds: favoritedPostIds ?? this.favoritedPostIds,
      userPosts: userPosts ?? this.userPosts,
      favoritedConversationIds: favoritedConversationIds ?? this.favoritedConversationIds,
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        uid: json["uid"],
        username: json["username"],
        portrait: json["portrait"],
        traits: List<String>.from(json["traits"].map((x) => x)),
        freeText: json["freeText"],
        followedBloggerIds: List<String>.from(json["followedBloggerIds"].map((x) => x)),
        favoritedPostIds: List<String>.from(json["favoritedPostIds"].map((x) => x)),
        userPosts: json["userPosts"] != null ? List<Post>.from(json["userPosts"].map((x) => Post.fromJson(x))) : [],
        favoritedConversationIds: List<String>.from(json["favoritedConversationIds"].map((x) => x)),
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        "portrait": portrait,
        "userPosts": List<dynamic>.from(userPosts.map((x) => x.toJson())),
      };
}
