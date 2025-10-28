import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/models/match_profile.dart';
import 'package:flutter_app/widgets/bottom_nav_bar_visibility_notification.dart';

import 'package:flutter_app/data/conversations_provider.dart';
import 'package:flutter_app/models/conversation.dart';

class ChatPage extends StatefulWidget {
  final MatchProfile profile;

  const ChatPage({super.key, required this.profile});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const List<String> _replyPool = [
    '听上去像是会成为一个节奏样本。',
    '我想把它写进下一段独白，可以吗？',
    '这感觉像是凌晨四点的巷子味道。',
    '换我来分享一段旧磁带里的沙沙声。',
    '如果有空，一起边走边录城市的呼吸吧。',
  ];

  final List<ChatMessage> _messages = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late final ScrollController _scrollController;
  late final TextEditingController _inputController;
  late final FocusNode _inputFocusNode;
  bool _canSend = false;
  bool _isNavBarVisible = true;
  bool _isFavorited = false; // Local state for the favorite button

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _inputController = TextEditingController();
    _inputController.addListener(_handleInputChanged);
    _inputFocusNode = FocusNode();

    // Set initial favorite state from the provider
    final existingConversation = conversationsProvider.allConversations.firstWhere((c) => c.id == widget.profile.id, orElse: () => Conversation(id: '', partner: widget.profile));
    _isFavorited = existingConversation.isFavorited;

    _loadInitialMessages();
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

  void _loadInitialMessages() {
    // This can be adapted to load messages from the provider if they should persist
    final initialMessages = [
      ChatMessage(author: widget.profile.name, text: '嗨，我刚看了你的梦境日志，太奇妙了！', timestamp: DateTime.now()),
      ChatMessage(author: '你', text: '谢谢～最近试着用声音记录情绪，你也会吗？', timestamp: DateTime.now()),
      ChatMessage(author: widget.profile.name, text: '会的，我喜欢用黑胶噪点铺底。', timestamp: DateTime.now()),
      ChatMessage(author: '你', text: '那我们下次交换一段声音日记吧！', timestamp: DateTime.now()),
    ];

    Future.delayed(const Duration(milliseconds: 100), () {
      for (var i = 0; i < initialMessages.length; i++) {
        _addMessage(initialMessages[i], scheduleReply: false, notifyProvider: false);
        Future.delayed(Duration(milliseconds: 150 * (i + 1)));
      }
    });
  }

  void _handleInputChanged() {
    final hasContent = _inputController.text.trim().isNotEmpty;
    if (hasContent != _canSend) {
      setState(() => _canSend = hasContent);
    }
  }

  void _sendMessage() {
    final raw = _inputController.text.trim();
    if (raw.isEmpty) return;

    final message = ChatMessage(author: '你', text: raw, timestamp: DateTime.now());
    _addMessage(message);
    _inputController.clear();
    _inputFocusNode.requestFocus();
  }

  void _addMessage(ChatMessage message, {bool scheduleReply = true, bool notifyProvider = true}) {
    _messages.add(message);
    _listKey.currentState?.insertItem(_messages.length - 1, duration: const Duration(milliseconds: 400));
    _scrollToBottom();

    // Notify the provider that a new message has been added
    if (notifyProvider) {
      conversationsProvider.addMessage(widget.profile, message);
    }

    if (message.author == '你' && scheduleReply) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        final replyText = _replyPool[math.Random().nextInt(_replyPool.length)];
        final replyMessage = ChatMessage(author: widget.profile.name, text: replyText, timestamp: DateTime.now());
        _addMessage(replyMessage, scheduleReply: false);
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _inputController.removeListener(_handleInputChanged);
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile.name),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.star : Icons.star_border,
              color: _isFavorited ? Colors.amber : null,
            ),
            onPressed: () {
              // Update the provider and the local state
              conversationsProvider.toggleFavorite(widget.profile.id);
              setState(() {
                _isFavorited = !_isFavorited;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorited ? 'Conversation favorited.' : 'Conversation unfavorited.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Favorite Chat',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  controller: _scrollController,
                  initialItemCount: _messages.length,
                  itemBuilder: (context, index, animation) {
                    final message = _messages[index];
                    return AnimatedMessage(animation: animation, message: message, accent: widget.profile.accent);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _ChatInputBar(
                accent: widget.profile.accent,
                controller: _inputController,
                focusNode: _inputFocusNode,
                canSend: _canSend,
                onSend: _sendMessage,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedMessage extends StatelessWidget {
  final Animation<double> animation;
  final ChatMessage message;
  final Color accent;

  const AnimatedMessage({super.key, required this.animation, required this.message, required this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.author == '你';
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: isMe ? const Offset(0.2, 0) : const Offset(-0.2, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: CustomPaint(
              painter: ChatBubblePainter(isMe: isMe, color: isMe ? accent.withOpacity(0.9) : Colors.white),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: Text(
                  message.text,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, color: isMe ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatBubblePainter extends CustomPainter {
  final bool isMe;
  final Color color;

  ChatBubblePainter({required this.isMe, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // A squircle-like shape
    final r = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(18));
    path.addRRect(r);

    // Tail
    final tailSize = 8.0;
    if (isMe) {
      path.moveTo(size.width - 18, size.height - tailSize);
      path.quadraticBezierTo(size.width, size.height, size.width - tailSize, size.height - tailSize);
    } else {
      path.moveTo(18, size.height - tailSize);
      path.quadraticBezierTo(0, size.height, tailSize, size.height - tailSize);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ChatBubblePainter oldDelegate) {
    return oldDelegate.isMe != isMe || oldDelegate.color != color;
  }
}

class _ChatInputBar extends StatelessWidget {
  final Color accent;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSend;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.accent,
    required this.controller,
    required this.focusNode,
    required this.canSend,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
              onSubmitted: (_) => onSend(),
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: InputBorder.none,
                hintText: 'Share a thought...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 14, color: const Color(0xFF3E2A2A).withOpacity(0.5)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: canSend ? onSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: canSend ? accent : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(
                  Icons.arrow_upward,
                  key: ValueKey<bool>(canSend),
                  size: 20,
                  color: canSend ? Colors.white : Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


