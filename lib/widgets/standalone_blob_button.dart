import 'package:flutter/material.dart';
import 'dart:math';

/// A small, self-contained "blob-like" button that does not depend on
/// the original `flutter_blob` package. It provides a gentle idle pulse
/// and a tap press animation and exposes the same simple factory API used
/// in the example: `StandaloneBlobButton.bouncing(...)`.
class StandaloneBlobButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Icon? icon;
  final Size size;

  const StandaloneBlobButton._({
    Key? key,
    required this.onTap,
    required this.backgroundColor,
    required this.icon,
    required this.size,
  }) : super(key: key);

  /// Convenience factory that mirrors the original package's simple API.
  factory StandaloneBlobButton.bouncing({
    Key? key,
    required VoidCallback onTap,
    Icon? icon,
    Color? backgroundColor,
  }) {
    return StandaloneBlobButton._(
      key: key,
      onTap: onTap,
      backgroundColor: backgroundColor ?? Colors.red,
      icon: icon,
      size: const Size(100, 100),
    );
  }

  @override
  State<StandaloneBlobButton> createState() => _StandaloneBlobButtonState();
}

class _StandaloneBlobButtonState extends State<StandaloneBlobButton>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final Animation<double> _idleScale;

  late final AnimationController _pressController;
  late final Animation<double> _pressScale;
  bool _isMatched = false;

  @override
  void initState() {
    super.initState();
    // Faster and larger pulse amplitude
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _idleScale = Tween<double>(begin: 0.92, end: 1.12)
        .animate(CurvedAnimation(parent: _idleController, curve: Curves.easeInOut));

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.86)
        .animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _idleController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isMatched) return;
    // Stop idle pulse to simulate "finger matched" locking
    _idleController.stop(canceled: false);
    _isMatched = true;
    setState(() {});
    _pressController.forward(from: 0).then((_) => _pressController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    // Nest two AnimatedBuilders to combine idle pulse and press animation by
    // multiplying the scale factors.
    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
            final double idle = _isMatched ? 1.0 : _idleScale.value;
        return AnimatedBuilder(
          animation: _pressController,
          builder: (context, child2) {
            final double press = _pressScale.value;
            final double scale = idle * press;
            return Transform.scale(
              scale: scale,
              child: child2,
            );
          },
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: SizedBox(
          width: widget.size.width,
          height: widget.size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Finger-shaped background using radial gradient + shadow
              Container(
                width: widget.size.width,
                height: widget.size.height,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      widget.backgroundColor!.withOpacity(1.0),
                      widget.backgroundColor!.withOpacity(0.85),
                      widget.backgroundColor!.withOpacity(0.7),
                    ],
                    center: const Alignment(-0.15, -0.2),
                    radius: 1.0,
                  ),
                  // Make shape elongated (finger-like)
                  borderRadius: BorderRadius.all(Radius.elliptical(widget.size.width * 0.55, widget.size.height * 0.55)),
                  boxShadow: [
                    BoxShadow(
                      color: widget.backgroundColor!.withOpacity(0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Fingerprint drawing on top
              // SizedBox(
              //   width: widget.size.width * 0.8,
              //   height: widget.size.height * 0.8,
              //   child: CustomPaint(
              //     painter: _FingerprintPainter(active: _isMatched),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FingerprintPainter extends CustomPainter {
  final bool active;
  _FingerprintPainter({this.active = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 2.8 : 1.6
      ..color = active ? Colors.white.withOpacity(0.95) : Colors.white70;

    // Simple concentric arcs to simulate fingerprint ridges
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = min(size.width, size.height) / 2;
    for (double r = maxR; r > maxR * 0.18; r -= maxR * 0.12) {
      final rect = Rect.fromCircle(center: center, radius: r);
      canvas.drawArc(rect, -pi / 1.8, pi * 1.2, false, paint);
    }

    // small inner loops
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 2.2 : 1.2
      ..color = active ? Colors.white.withOpacity(0.95) : Colors.white60;
    for (double r = maxR * 0.25; r > maxR * 0.07; r -= maxR * 0.06) {
      final rect = Rect.fromCircle(center: center.translate(-maxR * 0.06, 0), radius: r);
      canvas.drawArc(rect, -pi / 1.5, pi * 1.0, false, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FingerprintPainter oldDelegate) {
    return oldDelegate.active != active;
  }
}


