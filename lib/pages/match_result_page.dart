import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:visibility_detector/visibility_detector.dart';

import '../models/match_profile.dart';
import '../physics/metaball_simulation.dart';
import 'chat_page.dart';

class MatchResultPage extends StatefulWidget {
  const MatchResultPage({super.key});

  @override
  State<MatchResultPage> createState() => _MatchResultPageState();
}

class _MatchResultPageState extends State<MatchResultPage> {
  final List<MatchProfile> _profiles = const [
    MatchProfile(id: 'yori', name: 'Yori', tagline: '感性插画师', accent: Color(0xFFCB5151)),
    MatchProfile(id: 'miko', name: 'Miko', tagline: '午夜电台主持', accent: Color(0xFFE4B974)),
    MatchProfile(id: 'noa', name: 'Noa', tagline: '剧本杀写手', accent: Color(0xFF6C8D8E)),
    MatchProfile(id: 'leon', name: 'Leon', tagline: '旅行摄影师', accent: Color(0xFF9E7F66)),
    MatchProfile(id: 'sara', name: 'Sara', tagline: '声音收藏者', accent: Color(0xFF55616A)),
    MatchProfile(id: 'ryu', name: 'Ryu', tagline: '城市观察员', accent: Color(0xFFB7B0AA)),
  ];

  String? _selectedProfileId;

  void _handleSelect(MatchProfile profile) {
    setState(() => _selectedProfileId = profile.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage(profile: profile)),
    ).then((_) {
      if (!mounted) return;
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
            final maxWidth = math.min(constraints.maxWidth, 620).toDouble();
            final gutter = math.min(32, maxWidth * 0.06).toDouble();
            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: math.min(28, maxWidth * 0.08).toDouble(),
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
  final List<MatchProfile> profiles;
  final String? selectedProfileId;
  final ValueChanged<MatchProfile> onProfileTap;

  const _SelectionColumn({
    required this.profiles,
    required this.selectedProfileId,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.8);
    final subtitleStyle = theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 22);

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
            child: ClipRect( // Prevents bubbles from drawing outside their bounds
              child: BubbleCluster(
                profiles: profiles,
                selectedProfileId: selectedProfileId,
                onProfileTap: onProfileTap,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BubbleCluster extends StatefulWidget {
  final List<MatchProfile> profiles;
  final String? selectedProfileId;
  final ValueChanged<MatchProfile> onProfileTap;

  const BubbleCluster({
    super.key,
    required this.profiles,
    this.selectedProfileId,
    required this.onProfileTap,
  });

  @override
  State<BubbleCluster> createState() => _BubbleClusterState();
}

class _BubbleClusterState extends State<BubbleCluster> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final MetaballSimulation _simulation;
  late final List<Metaball> _metaballs;
  Size _clusterSize = const Size(300, 300); // Default size

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(() {
        if (mounted) {
          _simulation.update();
          setState(() {});
        }
      });

    final random = math.Random();
    _metaballs = widget.profiles.map((p) {
      final radius = 35 + random.nextDouble() * 25;
      return Metaball(p, radius: radius);
    }).toList();

    _simulation = MetaballSimulation(metaballs: _metaballs, size: _clusterSize);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetSimulation() {
    if (!mounted) return;
    final random = math.Random();

    for (final ball in _metaballs) {
      // Random position within the bounds
      ball.position = vector.Vector2(
        random.nextDouble() * _clusterSize.width,
        random.nextDouble() * _clusterSize.height,
      );
      // Random velocity (momentum)
      ball.velocity = vector.Vector2(
        (random.nextDouble() - 0.5) * 2, // Random value between -1 and 1
        (random.nextDouble() - 0.5) * 2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('bubble-cluster-detector'),
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;
        final isVisible = visibilityInfo.visibleFraction > 0.9;
        if (isVisible) {
          if (!_controller.isAnimating) {
            _resetSimulation();
            _controller.repeat();
          }
        } else {
          if (_controller.isAnimating) {
            _controller.stop();
          }
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
        _clusterSize = constraints.biggest;
        _simulation.size = constraints.biggest;
        return GestureDetector(
          onTapDown: (details) {
            final tapPosition = vector.Vector2(details.localPosition.dx, details.localPosition.dy);
            Metaball? tappedBall;
            for (final ball in _metaballs.reversed) {
              if (ball.position.distanceTo(tapPosition) < ball.radius) {
                tappedBall = ball;
                break;
              }
            }
            if (tappedBall != null) widget.onProfileTap(tappedBall.profile);
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: _BubblePainter(
              metaballs: _metaballs,
              selectedProfileId: widget.selectedProfileId,
              textTheme: Theme.of(context).textTheme,
            ),
          ),
        );
      }),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final List<Metaball> metaballs;
  final String? selectedProfileId;
  final TextTheme textTheme;

  _BubblePainter({
    required this.metaballs,
    this.selectedProfileId,
    required this.textTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final ball in metaballs) {
      final isSelected = ball.profile.id == selectedProfileId;
      final center = Offset(ball.position.x, ball.position.y);

      // Draw the main bubble with a blur effect
      final paint = Paint()
        ..color = isSelected ? ball.profile.accent : ball.profile.accent.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawCircle(center, ball.radius, paint);

      // Draw the text content
      final nameStyle = textTheme.titleLarge?.copyWith(
          fontSize: ball.radius * 0.3,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.9));
      final taglineStyle = textTheme.bodyMedium?.copyWith(
          fontSize: ball.radius * 0.15,
          color: isSelected
              ? Colors.white.withOpacity(0.85)
              : Colors.white.withOpacity(0.7));

      final textSpan = TextSpan(
        children: [
          TextSpan(text: '${ball.profile.name}\n', style: nameStyle),
          TextSpan(text: ball.profile.tagline, style: taglineStyle),
        ],
      );

      final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: ball.radius * 1.6);

      final textOffset = Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2);
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}
