import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// Represents a single path drawn by the user.
class DrawingPath {
  final Paint paint;
  final Path path;

  DrawingPath({required this.paint, required this.path});
}

// Enum for different brush styles
enum BrushType { pen, marker }

// Controller to manage the state of the drawing canvas.
class DrawingController extends ChangeNotifier {
  final List<DrawingPath> _paths = [];
  final List<DrawingPath> _undoStack = [];
  ui.Image? backgroundImage;
  BrushType _brushType = BrushType.pen;

  Paint _currentPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 3.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  List<DrawingPath> get paths => _paths;
  Paint get currentPaint => _currentPaint;
  BrushType get brushType => _brushType;
  bool get canUndo => _paths.isNotEmpty;
  bool get canRedo => _undoStack.isNotEmpty;

  void startPath(Offset startPoint) {
    final path = Path()..moveTo(startPoint.dx, startPoint.dy);
    _paths.add(DrawingPath(paint: _currentPaint, path: path));
    _undoStack.clear();
    notifyListeners();
  }

  void appendPoint(Offset point) {
    if (_paths.isEmpty) return;
    _paths.last.path.lineTo(point.dx, point.dy);
    notifyListeners();
  }

  void endPath() {
    // No action needed for now, but can be used for path optimization later.
  }

  void undo() {
    if (!canUndo) return;
    _undoStack.add(_paths.removeLast());
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _paths.add(_undoStack.removeLast());
    notifyListeners();
  }

  void clear() {
    _paths.clear();
    _undoStack.clear();
    notifyListeners();
  }

  Future<void> setBackgroundImage(File imageFile) async {
    final data = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    backgroundImage = frame.image;
    // Also clear existing paths when a new background is set
    clear();
    notifyListeners();
  }

  void setPaint(Paint newPaint) {
    _currentPaint = newPaint;
  }

  void setColor(Color color) {
    _currentPaint = Paint()
      ..color = color
      ..strokeWidth = _currentPaint.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = _currentPaint.strokeCap;
    _updatePaintForBrush(); // Re-apply brush settings with new color
    notifyListeners();
  }

  void setBrushType(BrushType type) {
    _brushType = type;
    _updatePaintForBrush();
    notifyListeners();
  }

  void _updatePaintForBrush() {
    _currentPaint.strokeWidth = _brushType == BrushType.pen ? 3.0 : 12.0;
  }
}

// The main canvas widget where drawing happens.
class DrawingCanvas extends StatelessWidget {
  final DrawingController controller;

  const DrawingCanvas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => controller.startPath(details.localPosition),
      onPanUpdate: (details) => controller.appendPoint(details.localPosition),
      onPanEnd: (details) => controller.endPath(),
      child: CustomPaint(
        painter: _CanvasPainter(controller: controller),
        size: Size.infinite,
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final DrawingController controller;

  _CanvasPainter({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background image if it exists
    if (controller.backgroundImage != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: controller.backgroundImage!,
        fit: BoxFit.cover,
      );
    }

    // Draw paths
    for (final drawingPath in controller.paths) {
      canvas.drawPath(drawingPath.path, drawingPath.paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return true;
  }
}

// A toolbar for drawing actions and options.
class DrawingToolbar extends AnimatedWidget {
  final DrawingController controller;

  const DrawingToolbar({super.key, required this.controller}) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: controller.canUndo ? controller.undo : null,
          tooltip: 'Undo',
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: controller.canRedo ? controller.redo : null,
          tooltip: 'Redo',
        ),
        // Add color pickers and stroke width selectors here
      ],
    );
  }
}
