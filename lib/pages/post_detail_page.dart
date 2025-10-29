import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/pages/post_page.dart'; // Re-using the Post model

// Mock Comment Model
class Comment {
  final String author;
  final String authorImageUrl;
  final String text;

  const Comment({
    required this.author,
    required this.authorImageUrl,
    required this.text,
  });
}

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  // --- State Variables ---
  late final List<Comment> _comments;
  late bool _isLiked;
  late bool _isFavorited;
  late int _likeCount;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize state from the widget's data
    _isLiked = false; // Assuming initial state is not liked
    _isFavorited = widget.post.isFavorited;
    _likeCount = widget.post.likes;
    _comments = [
      const Comment(author: 'Miko', authorImageUrl: 'https://i.pravatar.cc/150?u=miko', text: 'This is a beautiful thought.'),
      const Comment(author: 'Leon', authorImageUrl: 'https://i.pravatar.cc/150?u=leon', text: 'I feel the same way.'),
      const Comment(author: 'Sara', authorImageUrl: 'https://i.pravatar.cc/150?u=sara', text: 'Have you tried recording the sound of the wind through the leaves?'),
    ];
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // --- Interaction Handlers ---
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
      widget.post.isFavorited = _isFavorited; // Update the original post object
    });
  }

  void _addComment() {
    if (_commentController.text.isEmpty) return;

    final newComment = Comment(
      author: 'You', // Assuming the current user
      authorImageUrl: 'https://i.pravatar.cc/150?u=a', // Placeholder for current user
      text: _commentController.text,
    );

    setState(() {
      _comments.insert(0, newComment); // Add to the top of the list
      _commentController.clear();
    });
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.author, style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), // Add padding for bottom input bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorInfo(),
            const SizedBox(height: 24),
            _buildPostContent(),
            const SizedBox(height: 24),
            _buildLikesAndCommentsStats(),
            const Divider(height: 48),
            _buildCommentSection(),
          ],
        ),
      ),
      bottomSheet: _buildCommentInputBar(),
    );
  }

  // --- UI Builder Widgets ---
  Widget _buildAuthorInfo() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(widget.post.authorImageUrl),
          radius: 20,
        ),
        const SizedBox(width: 12),
        Text(widget.post.author, style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPostContent() {
    // TODO: Add video player support for video posts on this page.
    final bool isImagePost = widget.post.mediaUrl != null && widget.post.mediaType == MediaType.image;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isImagePost)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            // Local files are not handled here yet, assuming network for now.
            child: Image.network(widget.post.mediaUrl!),
          ),
        const SizedBox(height: 16),
        Text(widget.post.content, style: GoogleFonts.notoSerifSc(fontSize: 16, height: 1.5)),
      ],
    );
  }

  Widget _buildLikesAndCommentsStats() {
    final likedColor = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        InkWell(
          onTap: _toggleLike,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? likedColor : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text('$_likeCount likes', style: TextStyle(color: _isLiked ? likedColor : Colors.grey[600])),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: _toggleFavorite,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Icon(
                  _isFavorited ? Icons.star : Icons.star_border,
                  color: _isFavorited ? Colors.amber : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(_isFavorited ? 'Favorited' : 'Favorite', style: TextStyle(color: _isFavorited ? Colors.amber : Colors.grey[600])),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.grey[600], size: 20),
            const SizedBox(width: 4),
            Text('${_comments.length} comments', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments', style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _comments.length,
          itemBuilder: (context, index) {
            final comment = _comments[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(backgroundImage: NetworkImage(comment.authorImageUrl), radius: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comment.author, style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(comment.text, style: GoogleFonts.notoSerifSc()),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(thickness: 0.5, height: 24),
        ),
      ],
    );
  }

  Widget _buildCommentInputBar() {
    return Material(
      elevation: 8,
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8 + MediaQuery.of(context).padding.bottom),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _addComment,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}