import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CanvasDrawingPage extends StatefulWidget {
  const CanvasDrawingPage({super.key});

  @override
  State<CanvasDrawingPage> createState() => _CanvasDrawingPageState();
}

class _CanvasDrawingPageState extends State<CanvasDrawingPage> {
  final List<_Stroke> _strokes = [];
  _Stroke? _currentStroke;
  final GlobalKey _paintKey = GlobalKey();

  void _startStroke(Offset position) {
    setState(() {
      _currentStroke = _Stroke(points: [position]);
      _strokes.add(_currentStroke!);
    });
  }

  void _appendPoint(Offset position) {
    setState(() {
      _currentStroke?.points.add(position);
    });
  }

  void _endStroke() {
    setState(() {
      _currentStroke = null;
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
    });
  }

  Future<void> _finishDrawing() async {
    try {
      final boundary = _paintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) Navigator.pop(context, null);
        return;
      }
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (mounted) Navigator.pop(context, null);
        return;
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      if (mounted) {
        Navigator.pop(context, pngBytes);
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手绘自画像'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '清空',
            onPressed: _clearCanvas,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: '完成',
            onPressed: _finishDrawing,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFDF7F2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF5F4040), width: 1.6),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: GestureDetector(
              onPanStart: (details) =>
                  _startStroke(_clampToBounds(details.localPosition)),
              onPanUpdate: (details) =>
                  _appendPoint(_clampToBounds(details.localPosition)),
              onPanEnd: (_) => _endStroke(),
              child: RepaintBoundary(
                key: _paintKey,
                child: CustomPaint(
                  painter: _CanvasPainter(strokes: _strokes),
                  isComplex: true,
                  willChange: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Offset _clampToBounds(Offset raw) {
    return Offset(
      raw.dx.clamp(0.0, double.infinity),
      raw.dy.clamp(0.0, double.infinity),
    );
  }
}

class _Stroke {
  _Stroke({required this.points});

  final List<Offset> points;
}

class _CanvasPainter extends CustomPainter {
  const _CanvasPainter({required this.strokes});

  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB82020)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      final points = stroke.points;
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
      if (points.length == 1) {
        canvas.drawPoints(ui.PointMode.points, points, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}
