import 'dart:math' as math;
import 'dart:ui' as ui;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_app/pages/create_post_page.dart';
import 'package:flutter_app/pages/post_detail_page.dart';
import 'package:flutter_app/widgets/bottom_nav_bar_visibility_notification.dart';
import 'package:video_player/video_player.dart';

enum MediaType { image, video }

// Data model for a post
class Post {
  final String author;
  final String authorImageUrl;
  final String content;
  final String? mediaUrl;
  final MediaType? mediaType;
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
    this.isPublic = true, // Default to public
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        author: json["author"],
        authorImageUrl: json["authorImageUrl"],
        content: json["content"],
        mediaUrl: json["mediaUrl"],
        mediaType: mediaTypeFromJson(json["mediaType"]),
        likes: json["likes"],
        comments: json["comments"],
        crossAxisCellCount: json["crossAxisCellCount"],
        mainAxisCellCount: json["mainAxisCellCount"].toDouble(),
        isFavorited: json["isFavorited"],
        isPublic: json["isPublic"],
      );

  Map<String, dynamic> toJson() => {
        "author": author,
        "authorImageUrl": authorImageUrl,
        "content": content,
        "mediaUrl": mediaUrl,
        "mediaType": mediaTypeToJson(mediaType),
        "likes": likes,
        "comments": comments,
        "crossAxisCellCount": crossAxisCellCount,
        "mainAxisCellCount": mainAxisCellCount,
        "isFavorited": isFavorited,
        "isPublic": isPublic,
      };
}

MediaType? mediaTypeFromJson(String? type) {
  if (type == 'image') {
    return MediaType.image;
  } else if (type == 'video') {
    return MediaType.video;
  }
  return null;
}

String? mediaTypeToJson(MediaType? type) {
  if (type == MediaType.image) {
    return 'image';
  } else if (type == MediaType.video) {
    return 'video';
  }
  return null;
}

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool _isMember = false; // Simulate membership status
  late final ScrollController _scrollController;
  bool _isNavBarVisible = true;

  // Mock data - now a mutable list
  final List<Post> posts = [
    Post(author: 'Yori', authorImageUrl: 'https://i.pravatar.cc/150?u=yori', content: 'Found a hidden alleyway that hums a forgotten tune. Recorded it for my next soundscape.', likes: 12, comments: 3, mainAxisCellCount: 1.2),
    Post(author: 'Miko', authorImageUrl: 'https://i.pravatar.cc/150?u=miko', content: 'Tonight\'s broadcast is about the spaces between words. What do you hear in the silence?', mediaUrl: 'https://images.unsplash.com/photo-1518644245841-64a4423c1b27?q=80&w=2070&auto=format&fit=crop', mediaType: MediaType.image, likes: 34, comments: 8, mainAxisCellCount: 1.5, isFavorited: true),
    Post(author: 'Noa', authorImageUrl: 'https://i.pravatar.cc/150?u=noa', content: 'My new script involves a character who only speaks in questions. It\'s a fun challenge!', likes: 21, comments: 5, mainAxisCellCount: 1.3),
    Post(author: 'Leon', authorImageUrl: 'https://i.pravatar.cc/150?u=leon', content: 'The city at dawn, from a perspective only the lonely know.', mediaUrl: 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?q=80&w=2070&auto=format&fit=crop', mediaType: MediaType.image, likes: 58, comments: 12, mainAxisCellCount: 1.5),
    Post(author: 'Sara', authorImageUrl: 'https://i.pravatar.cc/150?u=sara', content: 'Collected the sound of rain on a tin roof. It tells a story.', likes: 45, comments: 7, mainAxisCellCount: 1.2, isFavorited: true),
    Post(author: 'Ryu', authorImageUrl: 'https://i.pravatar.cc/150?u=ryu', content: 'I followed a cat for 3 blocks. It showed me a world I never knew existed.', mediaUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=2043&auto=format&fit=crop', mediaType: MediaType.image, likes: 102, comments: 23, mainAxisCellCount: 1.6),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = false;
          BottomNavBarVisibilityNotification(false).dispatch(context);
        });
      }
    }
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = true;
          BottomNavBarVisibilityNotification(true).dispatch(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Text('会员解锁', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 4),
                const Icon(Icons.workspace_premium_outlined, size: 18, color: Colors.amber),
                Switch(
                  value: _isMember,
                  onChanged: (value) => setState(() => _isMember = value),
                  activeColor: const Color(0xFF992121),
                ),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: posts.map((post) {
            return StaggeredGridTile.count(
              crossAxisCellCount: post.crossAxisCellCount,
              mainAxisCellCount: post.mainAxisCellCount,
              child: PostCard(post: post, isMember: _isMember),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPost = await Navigator.of(context).push<Post>(MaterialPageRoute(
            builder: (context) => CreatePostPage(),
            fullscreenDialog: true,
          ));

          if (newPost != null && newPost.isPublic) {
            setState(() {
              posts.insert(0, newPost);
            });
          }
        },
        backgroundColor: const Color(0xFF992121),
        child: const Icon(Icons.add, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  final bool isMember;

  const PostCard({super.key, required this.post, required this.isMember});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likeCount;
  late bool _isFavorited;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = widget.post.likes;
    _isFavorited = widget.post.isFavorited;

    if (widget.post.mediaType == MediaType.video && widget.post.mediaUrl != null) {
      _initializeVideoPlayer();
    }
  }

  void _initializeVideoPlayer() {
    final mediaUrl = widget.post.mediaUrl!;
    // Check if it's a local file path or a network URL
    if (mediaUrl.startsWith('http')) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(mediaUrl));
    } else {
      _videoController = VideoPlayerController.file(File(mediaUrl));
    }
    
    _videoController!
      ..initialize().then((_) {
        if (mounted) {
          setState(() {}); // Update UI when video is initialized
        }
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
      widget.post.isFavorited = _isFavorited;
    });
  }

  void _navigateToDetail() {
    // Pause video when navigating away
    _videoController?.pause();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PostDetailPage(post: widget.post),
    ));
  }

  void _toggleVideoPlayback() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
  }

  Widget _buildMediaWidget() {
    if (widget.post.mediaUrl == null) {
      return const SizedBox.shrink();
    }

    switch (widget.post.mediaType) {
      case MediaType.image:
        final isFile = !widget.post.mediaUrl!.startsWith('http');
        return isFile
            ? Image.file(File(widget.post.mediaUrl!), fit: BoxFit.cover, width: double.infinity, height: double.infinity)
            : Image.network(widget.post.mediaUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
      case MediaType.video:
        if (_videoController != null && _videoController!.value.isInitialized) {
          return Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _buildMediaWidget(),
            // Add a play/pause button overlay for videos
            if (widget.post.mediaType == MediaType.video)
              Center(
                child: IconButton(
                  icon: Icon(
                    _videoController?.value.isPlaying ?? false ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.white.withOpacity(0.7),
                    size: 40,
                  ),
                  onPressed: _toggleVideoPlayback,
                ),
              ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(widget.post.mediaUrl != null ? 0.6 : 0.2),
                      Colors.transparent,
                      Colors.black.withOpacity(0.8)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _navigateToDetail,
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.post.content, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: Colors.white, height: 1.4), maxLines: 5, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(backgroundImage: NetworkImage(widget.post.authorImageUrl), radius: 12),
                      const SizedBox(width: 8),
                      Expanded(child: Text(widget.post.author, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.white, overflow: TextOverflow.ellipsis))),
                      IconButton(icon: Icon(_isFavorited ? Icons.star : Icons.star_border, color: _isFavorited ? Colors.amber : Colors.white), onPressed: _toggleFavorite, iconSize: 20, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      IconButton(icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? Colors.red : Colors.white), onPressed: _toggleLike, iconSize: 20, padding: const EdgeInsets.only(left: 4), constraints: const BoxConstraints()),
                      Text(_likeCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: widget.isMember ? 0.0 : 1.0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.5)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.4, 1.0],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.lock_outline, color: Colors.white, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            'Join to see more',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
