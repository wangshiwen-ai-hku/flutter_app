import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_app/data/my_posts.dart';
import 'package:flutter_app/pages/post_page.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _textController = TextEditingController();
  File? _mediaFile;
  MediaType? _mediaType;
  bool _isPublic = true;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _textController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await _disposeVideoController();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _mediaType = MediaType.image;
      });
    }
  }

  Future<void> _pickVideo() async {
    await _disposeVideoController();
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _mediaFile = File(pickedFile.path);
      _mediaType = MediaType.video;
      _videoController = VideoPlayerController.file(_mediaFile!)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
          _videoController!.setLooping(true);
        });
    }
  }

  Future<void> _disposeVideoController() async {
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }
  }

  void _publishPost() {
    if (_textController.text.isEmpty && _mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must add some content or media to publish.')),
      );
      return;
    }

    final newPost = Post(
      author: 'You', // Placeholder
      authorImageUrl: 'https://i.pravatar.cc/150?u=a', // Placeholder
      content: _textController.text,
      mediaUrl: _mediaFile?.path,
      mediaType: _mediaType,
      likes: 0,
      comments: 0,
      mainAxisCellCount: _mediaFile != null ? 1.5 : 1.2,
      isPublic: _isPublic,
    );

    MyPosts.posts.insert(0, newPost);
    Navigator.pop(context, newPost);
  }

  Widget _buildMediaPreview() {
    if (_mediaFile == null) {
      return const SizedBox.shrink();
    }

    Widget preview;
    if (_mediaType == MediaType.image) {
      preview = Image.file(_mediaFile!, fit: BoxFit.cover, width: double.infinity);
    } else if (_mediaType == MediaType.video && _videoController != null && _videoController!.value.isInitialized) {
      preview = AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    } else {
      preview = const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: preview,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _publishPost,
              child: Text(
                'Publish',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF992121),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMediaPreview(),
                    if (_mediaFile != null) const SizedBox(height: 16),
                    TextField(
                      controller: _textController,
                      maxLines: 10,
                      autofocus: true,
                      style: GoogleFonts.notoSerifSc(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts, dreams, or a piece of your world...',
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.notoSerifSc(color: Colors.grey[400]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: Text('Make post public', style: GoogleFonts.cormorantGaramond(fontSize: 16)),
              subtitle: Text(
                _isPublic
                    ? 'Visible to everyone in the community.'
                    : 'Only visible to you in your sanctuary.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              value: _isPublic,
              onChanged: (bool value) {
                setState(() {
                  _isPublic = value;
                });
              },
              activeColor: const Color(0xFF992121),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Image'),
                    onPressed: _pickImage,
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF992121)),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text('Video'),
                    onPressed: _pickVideo,
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF992121)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
