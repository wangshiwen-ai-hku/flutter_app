// Standalone script to generate fake user data
// To run this script, use the command: dart run scripts/generate_fake_data.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';

// Import the shared base model from the Flutter app
import '../lib/models/base_user_data.dart' as models;

class Post {
  final String author;
  final String authorImageUrl;
  final String content;
  final String? mediaUrl;
  final String? mediaType;
  final int likes;
  final int comments;
  final int crossAxisCellCount;
  final double mainAxisCellCount;
  bool isFavorited;
  final bool isPublic;

  Post({
    required this.author,
    required this.authorImageUrl,
    required this.content,
    this.mediaUrl,
    this.mediaType,
    required this.likes,
    required this.comments,
    this.crossAxisCellCount = 1,
    required this.mainAxisCellCount,
    this.isFavorited = false,
    this.isPublic = true,
  });

  Map<String, dynamic> toJson() => {
        "author": author,
        "authorImageUrl": authorImageUrl,
        "content": content,
        "mediaUrl": mediaUrl,
        "mediaType": mediaType,
        "likes": likes,
        "comments": comments,
        "crossAxisCellCount": crossAxisCellCount,
        "mainAxisCellCount": mainAxisCellCount,
        "isFavorited": isFavorited,
        "isPublic": isPublic,
      };
}

void main() async {
  final scriptDir = Directory.current;
  final assetsDir = Directory('${scriptDir.path}/assets/data');
  if (!await assetsDir.exists()) {
    await assetsDir.create(recursive: true);
  }

  final traitsFile = File('${assetsDir.path}/traits.json');
  final usersFile = File('${assetsDir.path}/fake_users.json');

  // --- Pre-defined content for user generation ---
  final List<String> _freeTextSamples = [
    'Seeking beauty in forgotten corners.',
    'The world is made of frequencies. I just listen.',
    'Every person is a story waiting to be written.',
    'Loves rainy nights and old books.',
    'Chasing sunsets and dreams.',
    'Aspiring to live a life less ordinary.',
    'My thoughts are a collection of untold stories.',
    'Finding poetry in the mundane.',
  ];

  final random = Random();
  final List<models.BaseUserData> mockUsers = [];

  // Load the traits from the JSON file
  final String traitsJson = await traitsFile.readAsString();
  final List<String> allTraits = List<String>.from(json.decode(traitsJson));

  for (int i = 0; i < 1000; i++) {
    final uid = 'user_$i';
    final username = 'User $i';

    // Select 2 to 4 random traits
    final int traitCount = 2 + random.nextInt(3);
    final List<String> userTraits = List.from(allTraits)..shuffle(random);

    mockUsers.add(
      models.BaseUserData(
        uid: uid,
        username: username,
        traits: userTraits.sublist(0, traitCount),
        freeText: _freeTextSamples[random.nextInt(_freeTextSamples.length)],
      ),
    );
  }

  // Convert the list of users to a JSON string with indentation
  final encoder = JsonEncoder.withIndent('  ');
  final usersJson = encoder.convert(mockUsers.map((user) => user.toJson()).toList());

  // Write the JSON to the file
  await usersFile.writeAsString(usersJson);

  print('Successfully generated 1000 fake users and saved to ${usersFile.path}');
}
