import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:visibility_detector/visibility_detector.dart';

import 'package:flutter_app/models/match_analysis.dart';
import 'package:flutter_app/physics/metaball_simulation.dart';
import 'package:flutter_app/pages/chat_history_page.dart';
import 'package:flutter_app/pages/match_analysis_page.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/services/service_locator.dart';

class MatchResultPage extends StatefulWidget {
  const MatchResultPage({
    super.key,
    this.useCachedResults = false,
  });

  final bool useCachedResults;

  @override
  State<MatchResultPage> createState() => _MatchResultPageState();
}

class _MatchResultPageState extends State<MatchResultPage> {
  Future<List<MatchAnalysis>>? _matchesFuture;
  String? _selectedAnalysisId;

  @override
  void initState() {
    super.initState();
    final apiService = locator<ApiService>();
    if (widget.useCachedResults) {
      _matchesFuture = apiService.getCachedMatches('current_user_id');
    } else {
      _matchesFuture = apiService.getMatches('current_user_id');
    }
  }

  void _handleSelect(MatchAnalysis analysis) {
    setState(() => _selectedAnalysisId = analysis.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MatchAnalysisPage(analysis: analysis)),
    ).then((_) {
      if (!mounted) return;
      setState(() => _selectedAnalysisId = null);
    });
  }

  void _navigateToChatHistory() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ChatHistoryPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E0DE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToChatHistory,
            tooltip: 'Chat History',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<MatchAnalysis>>(
          future: _matchesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No matches found.'));
            }

            final matches = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = math.min(constraints.maxWidth, 620).toDouble();
                return Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    padding: EdgeInsets.symmetric(
                      horizontal: math.min(28, maxWidth * 0.08).toDouble(),
                      vertical: 28,
                    ),
                    child: _SelectionColumn(
                      matches: matches,
                      selectedAnalysisId: _selectedAnalysisId,
                      onAnalysisTap: _handleSelect,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SelectionColumn extends StatelessWidget {
  final List<MatchAnalysis> matches;
  final String? selectedAnalysisId;
  final ValueChanged<MatchAnalysis> onAnalysisTap;

  const _SelectionColumn({
    required this.matches,
    required this.selectedAnalysisId,
    required this.onAnalysisTap,
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
        Text('And see your analysis!', style: subtitleStyle),
        const SizedBox(height: 32),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ClipRect(
              child: BubbleCluster(
                matches: matches,
                selectedAnalysisId: selectedAnalysisId,
                onAnalysisTap: onAnalysisTap,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BubbleCluster extends StatefulWidget {
  final List<MatchAnalysis> matches;
  final String? selectedAnalysisId;
  final ValueChanged<MatchAnalysis> onAnalysisTap;

  const BubbleCluster({
    super.key,
    required this.matches,
    this.selectedAnalysisId,
    required this.onAnalysisTap,
  });

  @override
  State<BubbleCluster> createState() => _BubbleClusterState();
}

class _BubbleClusterState extends State<BubbleCluster> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final MetaballSimulation _simulation;
  late final List<Metaball> _metaballs;
  late final Map<String, double> _opacityMap;
  Size _clusterSize = const Size(300, 300);
  Metaball? _draggedBall;

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

    // 计算归一化透明度映射
    _opacityMap = {};
    final scores = widget.matches.map((analysis) => analysis.totalScore).toList();
    if (scores.isEmpty) {
      return;
    }

    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final scoreRange = maxScore - minScore;

    for (final analysis in widget.matches) {
      if (scoreRange == 0) {
        // 所有分数相同时，使用固定透明度
        _opacityMap[analysis.id] = 0.65;
      } else {
        // 归一化到0.3-1.0范围
        final normalizedScore = (analysis.totalScore - minScore) / scoreRange;
        _opacityMap[analysis.id] = 0.3 + (normalizedScore * 0.7);
      }
    }

    _metaballs = widget.matches.map((analysis) {
      const minRadius = 30.0;
      const maxRadius = 60.0;
      final radius = minRadius + (maxRadius - minRadius) * (analysis.totalScore - minScore) / scoreRange;
      return Metaball(analysis, radius: radius);
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
      ball.position = vector.Vector2(
        random.nextDouble() * _clusterSize.width,
        random.nextDouble() * _clusterSize.height,
      );
      ball.velocity = vector.Vector2(
        (random.nextDouble() - 0.5) * 2,
        (random.nextDouble() - 0.5) * 2,
      );
    }
  }

  Metaball? _findTappedBall(Offset localPosition) {
    final tapPosition = vector.Vector2(localPosition.dx, localPosition.dy);
    for (final ball in _metaballs.reversed) {
      if (ball.position.distanceTo(tapPosition) < ball.radius * ball.scale) {
        return ball;
      }
    }
    return null;
  }

  void _onPanStart(DragStartDetails details) {
    final tappedBall = _findTappedBall(details.localPosition);
    if (tappedBall != null) {
      setState(() {
        _draggedBall = tappedBall;
        _draggedBall!.isBeingDragged = true;
        _draggedBall!.scale = 1.2;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggedBall != null) {
      setState(() {
        _draggedBall!.position = vector.Vector2(details.localPosition.dx, details.localPosition.dy);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_draggedBall != null) {
      setState(() {
        _draggedBall!.isBeingDragged = false;
        _draggedBall!.velocity = vector.Vector2(
          details.velocity.pixelsPerSecond.dx * 0.01,
          details.velocity.pixelsPerSecond.dy * 0.01,
        );
        _draggedBall!.scale = 1.0;
        _draggedBall = null;
      });
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
            final tappedBall = _findTappedBall(details.localPosition);
            if (tappedBall != null) widget.onAnalysisTap(tappedBall.analysis);
          },
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            size: Size.infinite,
            painter: _BubblePainter(
              metaballs: _metaballs,
              opacityMap: _opacityMap,
              selectedAnalysisId: widget.selectedAnalysisId,
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
  final Map<String, double> opacityMap;
  final String? selectedAnalysisId;
  final TextTheme textTheme;

  _BubblePainter({
    required this.metaballs,
    required this.opacityMap,
    this.selectedAnalysisId,
    required this.textTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    int colorIndex = 0;

    for (final ball in metaballs) {
      final isSelected = ball.analysis.id == selectedAnalysisId;
      final center = Offset(ball.position.x, ball.position.y);
      final scaledRadius = ball.radius * ball.scale;

      // Assign a color based on the user ID to keep it consistent
      final color = colors[ball.analysis.userB.uid.hashCode % colors.length];

      // 使用预计算的归一化透明度
      final opacity = isSelected ? 1.0 : (opacityMap[ball.analysis.id] ?? 0.65);

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawCircle(center, scaledRadius, paint);

      final nameStyle = textTheme.titleLarge?.copyWith(
          fontSize: scaledRadius * 0.3,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.9));
      final taglineStyle = textTheme.bodyMedium?.copyWith(
          fontSize: scaledRadius * 0.15,
          color: isSelected
              ? Colors.white.withOpacity(0.85)
              : Colors.white.withOpacity(0.7));

      final textSpan = TextSpan(
        children: [
          TextSpan(text: '${ball.analysis.userB.username}\n', style: nameStyle),
          TextSpan(text: ball.analysis.userB.freeText, style: taglineStyle, ),
        ],
      );

      final         textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          maxLines: 2,
        )..layout(maxWidth: scaledRadius * 1.6);

      final textOffset = Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2);
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      metaballs != oldDelegate.metaballs ||
      opacityMap != oldDelegate.opacityMap ||
      selectedAnalysisId != oldDelegate.selectedAnalysisId ||
      textTheme != oldDelegate.textTheme;
}