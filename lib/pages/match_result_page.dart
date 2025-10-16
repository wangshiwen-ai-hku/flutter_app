import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MatchResultPage extends StatefulWidget {
  const MatchResultPage({super.key});

  @override
  State<MatchResultPage> createState() => _MatchResultPageState();
}

class _MatchResultPageState extends State<MatchResultPage> {
  final List<_MatchProfile> _profiles = const [
    _MatchProfile(
      id: 'yori',
      name: 'Yori',
      tagline: '感性插画师',
      accent: Color(0xFFCB5151),
    ),
    _MatchProfile(
      id: 'miko',
      name: 'Miko',
      tagline: '午夜电台主持',
      accent: Color(0xFFE4B974),
    ),
    _MatchProfile(
      id: 'noa',
      name: 'Noa',
      tagline: '剧本杀写手',
      accent: Color(0xFF6C8D8E),
    ),
    _MatchProfile(
      id: 'leon',
      name: 'Leon',
      tagline: '旅行摄影师',
      accent: Color(0xFF9E7F66),
    ),
    _MatchProfile(
      id: 'sara',
      name: 'Sara',
      tagline: '声音收藏者',
      accent: Color(0xFF55616A),
    ),
    _MatchProfile(
      id: 'ryu',
      name: 'Ryu',
      tagline: '城市观察员',
      accent: Color(0xFFB7B0AA),
    ),
  ];

  String? _selectedProfileId;

  void _handleSelect(_MatchProfile profile) {
    setState(() => _selectedProfileId = profile.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChatConversationPage(profile: profile),
      ),
    ).then((_) {
      if (!mounted) {
        return;
      }
      setState(() => _selectedProfileId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E0DE),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = math.min(constraints.maxWidth, 620);
            final double gutter = math.min(32, maxWidth * 0.06);

            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: math.min(28, maxWidth * 0.08),
                  vertical: 28,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: gutter),
                        child: _SelectionColumn(
                          profiles: _profiles,
                          selectedProfileId: _selectedProfileId,
                          onProfileTap: _handleSelect,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SelectionColumn extends StatelessWidget {
  final List<_MatchProfile> profiles;
  final String? selectedProfileId;
  final ValueChanged<_MatchProfile> onProfileTap;

  const _SelectionColumn({
    required this.profiles,
    required this.selectedProfileId,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.cormorantGaramond(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    );
    final subtitleStyle = GoogleFonts.cormorantGaramond(
      fontSize: 22,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Match With People!', style: titleStyle),
        const SizedBox(height: 4),
        Text('And select to chat!', style: subtitleStyle),
        const SizedBox(height: 32),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _BubbleCluster(
              profiles: profiles,
              selectedProfileId: selectedProfileId,
              onProfileTap: onProfileTap,
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleCluster extends StatelessWidget {
  final List<_MatchProfile> profiles;
  final String? selectedProfileId;
  final ValueChanged<_MatchProfile> onProfileTap;

  const _BubbleCluster({
    required this.profiles,
    required this.selectedProfileId,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleConfigs = <_BubbleConfig>[
      _BubbleConfig(
        profile: profiles[0],
        position: const Offset(42, 10),
        size: 96,
      ),
      _BubbleConfig(
        profile: profiles[1],
        position: const Offset(218, 42),
        size: 68,
      ),
      _BubbleConfig(
        profile: profiles[2],
        position: const Offset(14, 124),
        size: 58,
      ),
      _BubbleConfig(
        profile: profiles[3],
        position: const Offset(120, 88),
        size: 118,
      ),
      _BubbleConfig(
        profile: profiles[4],
        position: const Offset(246, 176),
        size: 54,
      ),
      _BubbleConfig(
        profile: profiles[5],
        position: const Offset(32, 200),
        size: 72,
      ),
    ];

    const baseSize = Size(320, 290);
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: baseSize.width,
        height: baseSize.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final config in bubbleConfigs)
              Positioned(
                left: config.position.dx,
                top: config.position.dy,
                child: _OrganicBubble(
                  profile: config.profile,
                  diameter: config.size,
                  isSelected: config.profile.id == selectedProfileId,
                  onTap: () => onProfileTap(config.profile),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrganicBubble extends StatefulWidget {
  final _MatchProfile profile;
  final double diameter;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrganicBubble({
    required this.profile,
    required this.diameter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_OrganicBubble> createState() => _OrganicBubbleState();
}

class _OrganicBubbleState extends State<_OrganicBubble>
    with SingleTickerProviderStateMixin {
  static const int _pointCount = 10;
  late final AnimationController _controller;
  late final List<double> _phaseOffsets;
  late final List<double> _radiusFactors;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    final seed = widget.profile.id.hashCode;
    final rand = math.Random(seed);
    _phaseOffsets = List<double>.generate(
      _pointCount,
      (_) => rand.nextDouble() * math.pi * 2,
    );
    _radiusFactors = List<double>.generate(
      _pointCount,
      (_) => 0.9 + rand.nextDouble() * 0.2,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.diameter, widget.diameter),
            painter: _OrganicBubblePainter(
              profile: widget.profile,
              isSelected: widget.isSelected,
              progress: _controller.value,
              phaseOffsets: _phaseOffsets,
              radiusFactors: _radiusFactors,
            ),
          );
        },
      ),
    );
  }
}

class _OrganicBubblePainter extends CustomPainter {
  final _MatchProfile profile;
  final bool isSelected;
  final double progress;
  final List<double> phaseOffsets;
  final List<double> radiusFactors;

  _OrganicBubblePainter({
    required this.profile,
    required this.isSelected,
    required this.progress,
    required this.phaseOffsets,
    required this.radiusFactors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shortestSide = math.min(size.width, size.height);
    final amplitudeBase = (shortestSide / 2) * (isSelected ? 0.14 : 0.1);
    final amplitude = amplitudeBase.clamp(2.5, shortestSide / 5.5);
    final maxRadiusFactor = radiusFactors.reduce(math.max);
    final baseRadius = math.max(
      shortestSide / 2 - amplitude * maxRadiusFactor,
      shortestSide * 0.22,
    );

    final points = <Offset>[];
    final totalPoints = phaseOffsets.length;
    for (int i = 0; i < totalPoints; i++) {
      final angle = (i / totalPoints) * 2 * math.pi;
      final phase = phaseOffsets[i] + progress * 2 * math.pi;
      final factor = radiusFactors[i % radiusFactors.length];
      final radius = baseRadius + math.sin(phase) * amplitude * factor;
      final dx = center.dx + math.cos(angle) * radius;
      final dy = center.dy + math.sin(angle) * radius;
      points.add(Offset(dx, dy));
    }

    if (points.isEmpty) {
      return;
    }

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];
      final midPoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      if (i == 0) {
        path.moveTo(midPoint.dx, midPoint.dy);
      }
      path.quadraticBezierTo(current.dx, current.dy, midPoint.dx, midPoint.dy);
    }
    path.close();

    final shadowDepth = isSelected ? 16.0 : 9.0;
    canvas.drawShadow(
      path,
      Colors.black.withOpacity(isSelected ? 0.25 : 0.16),
      shadowDepth,
      true,
    );

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isSelected
          ? profile.accent.withOpacity(0.92)
          : profile.accent.withOpacity(0.32);
    canvas.drawPath(path, fillPaint);

    if (isSelected) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = Colors.white.withOpacity(0.75);
      canvas.drawPath(path, strokePaint);
    }

    final nameStyle = GoogleFonts.cormorantGaramond(
      fontSize: shortestSide * 0.22,
      fontWeight: FontWeight.w600,
      color: isSelected ? Colors.white : const Color(0xFF3E2A2A),
    );
    final taglineStyle = GoogleFonts.notoSerifSc(
      fontSize: shortestSide * 0.12,
      color: (isSelected ? Colors.white : const Color(0xFF3E2A2A))
          .withOpacity(isSelected ? 0.85 : 0.7),
    );

    final textSpan = TextSpan(
      children: [
        TextSpan(text: '${profile.name}\n', style: nameStyle),
        TextSpan(text: profile.tagline, style: taglineStyle),
      ],
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: shortestSide * 0.78);

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _OrganicBubblePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.profile != profile;
  }
}

class _MatchProfile {
  final String id;
  final String name;
  final String tagline;
  final Color accent;

  const _MatchProfile({
    required this.id,
    required this.name,
    required this.tagline,
    required this.accent,
  });
}

class _BubbleConfig {
  final _MatchProfile profile;
  final Offset position;
  final double size;

  const _BubbleConfig({
    required this.profile,
    required this.position,
    required this.size,
  });
}

class _ChatConversationPage extends StatefulWidget {
  final _MatchProfile profile;

  const _ChatConversationPage({required this.profile});

  @override
  State<_ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<_ChatConversationPage> {
  static const List<String> _replyPool = [
    '听上去像是会成为一个节奏样本。',
    '我想把它写进下一段独白，可以吗？',
    '这感觉像是凌晨四点的巷子味道。',
    '换我来分享一段旧磁带里的沙沙声。',
    '如果有空，一起边走边录城市的呼吸吧。',
  ];

  final List<_ChatMessage> _messages = [];
  late final ScrollController _scrollController;
  late final TextEditingController _inputController;
  late final FocusNode _inputFocusNode;
  bool _canSend = false;
  bool _replyScheduled = false;
  int _replyIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _inputController = TextEditingController();
    _inputController.addListener(_handleInputChanged);
    _inputFocusNode = FocusNode();

    _messages.addAll([
      _ChatMessage(
        author: widget.profile.name,
        text: '嗨，我刚看了你的梦境日志，太奇妙了！',
      ),
      const _ChatMessage(author: '你', text: '谢谢～最近试着用声音记录情绪，你也会吗？'),
      _ChatMessage(
        author: widget.profile.name,
        text: '会的，我喜欢用黑胶噪点铺底。',
      ),
      const _ChatMessage(author: '你', text: '那我们下次交换一段声音日记吧！'),
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _handleInputChanged() {
    final hasContent = _inputController.text.trim().isNotEmpty;
    if (hasContent != _canSend) {
      setState(() => _canSend = hasContent);
    }
  }

  void _sendMessage() {
    final raw = _inputController.text.trim();
    if (raw.isEmpty) {
      return;
    }
    setState(() {
      _messages.add(_ChatMessage(author: '你', text: raw));
      _canSend = false;
    });
    _inputController.clear();
    _scrollToBottom();
    _inputFocusNode.requestFocus();
    _scheduleReply();
  }

  void _scheduleReply() {
    if (_replyScheduled) {
      return;
    }
    _replyScheduled = true;
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      final replyText = _replyPool[_replyIndex % _replyPool.length];
      _replyIndex++;
      setState(() {
        _messages.add(
          _ChatMessage(author: widget.profile.name, text: replyText),
        );
        _replyScheduled = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      final position = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        position + 48,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.removeListener(_handleInputChanged);
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E0DE),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = math.min(constraints.maxWidth, 620);
            final double gutter = math.min(32, maxWidth * 0.06);

            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: math.min(28, maxWidth * 0.08),
                  vertical: 28,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: gutter),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chatting with ${widget.profile.name}',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.profile.tagline,
                              style: GoogleFonts.notoSerifSc(
                                fontSize: 14,
                                color: const Color(0xFF3E2A2A).withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _ChatTimeline(
                              messages: _messages,
                              accent: widget.profile.accent,
                              controller: _scrollController,
                            ),
                            const SizedBox(height: 16),
                            _ChatInputBar(
                              accent: widget.profile.accent,
                              controller: _inputController,
                              focusNode: _inputFocusNode,
                              canSend: _canSend,
                              onSend: _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChatTimeline extends StatelessWidget {
  final List<_ChatMessage> messages;
  final Color accent;
  final ScrollController controller;

  const _ChatTimeline({
    required this.messages,
    required this.accent,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF403433), width: 1.2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: ListView.separated(
          controller: controller,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.author == '你';
            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isMe ? accent.withOpacity(0.18) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isMe
                        ? accent.withOpacity(0.36)
                        : const Color(0xFF403433).withOpacity(0.5),
                    width: 1.05,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Text(
                    message.text,
                    style: GoogleFonts.notoSerifSc(fontSize: 14),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
        ),
      ),
    );
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF403433), width: 1.2),
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
              style: GoogleFonts.notoSerifSc(fontSize: 13.5),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '分享一段声音、故事或是心情...',
                hintStyle: GoogleFonts.notoSerifSc(
                  fontSize: 13,
                  color: const Color(0xFF3E2A2A).withOpacity(0.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: canSend ? onSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: canSend
                    ? accent.withOpacity(0.82)
                    : accent.withOpacity(0.28),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    size: 16,
                    color:
                        canSend ? Colors.white : Colors.white.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Send',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 17,
                      color: canSend
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String author;
  final String text;

  const _ChatMessage({required this.author, required this.text});
}
