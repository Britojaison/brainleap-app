import 'package:flutter/material.dart';

/// Drawing canvas with dotted grid background
class DottedGridCanvas extends StatefulWidget {
  const DottedGridCanvas({
    super.key,
    required this.controller,
  });

  final DrawingController controller;

  @override
  State<DottedGridCanvas> createState() => _DottedGridCanvasState();
}

class _DottedGridCanvasState extends State<DottedGridCanvas> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        final offset =
            box?.globalToLocal(details.globalPosition) ?? Offset.zero;
        widget.controller.startStroke(offset);
      },
      onPanUpdate: (details) {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        final offset =
            box?.globalToLocal(details.globalPosition) ?? Offset.zero;
        widget.controller.addPoint(offset);
      },
      onPanEnd: (_) => widget.controller.endStroke(),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _DottedCanvasPainter(
            strokes: widget.controller.strokes,
          ),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for dotted grid and drawing strokes
class _DottedCanvasPainter extends CustomPainter {
  _DottedCanvasPainter({required this.strokes});

  final List<DrawingStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dotted grid background
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, gridPaint);
      }
    }

    // Draw all strokes
    final penPaint = Paint()
      ..color = Colors.black87
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final eraserPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    for (final stroke in strokes) {
      final paint = stroke.isEraser ? eraserPaint : penPaint;
      final path = Path();

      bool started = false;
      for (int i = 0; i < stroke.points.length; i++) {
        final point = stroke.points[i];
        if (point == Offset.infinite) {
          started = false;
          continue;
        }

        if (!started) {
          path.moveTo(point.dx, point.dy);
          started = true;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedCanvasPainter oldDelegate) {
    return true; // Always repaint for smooth drawing
  }
}

/// Controller for managing drawing state
class DrawingController extends ChangeNotifier {
  final List<DrawingStroke> _strokes = [];
  final List<DrawingStroke> _redoStack = [];
  DrawingTool _currentTool = DrawingTool.pen;
  bool _isDrawing = false;

  List<DrawingStroke> get strokes => _strokes;
  DrawingTool get currentTool => _currentTool;
  bool get isDrawing => _isDrawing;
  bool get hasContent => _strokes.isNotEmpty;

  void setTool(DrawingTool tool) {
    _currentTool = tool;
    notifyListeners();
  }

  void startStroke(Offset point) {
    _isDrawing = true;
    _strokes.add(DrawingStroke(
      points: [point],
      isEraser: _currentTool == DrawingTool.eraser,
    ));
    _redoStack.clear();
    notifyListeners();
  }

  void addPoint(Offset point) {
    if (_isDrawing && _strokes.isNotEmpty) {
      _strokes.last.points.add(point);
      notifyListeners();
    }
  }

  void endStroke() {
    if (_isDrawing && _strokes.isNotEmpty) {
      _strokes.last.points.add(Offset.infinite);
      _isDrawing = false;
      notifyListeners();
    }
  }

  void undo() {
    if (_strokes.isNotEmpty) {
      _redoStack.add(_strokes.removeLast());
      notifyListeners();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      _strokes.add(_redoStack.removeLast());
      notifyListeners();
    }
  }

  void clear() {
    _strokes.clear();
    _redoStack.clear();
    notifyListeners();
  }
}

/// Drawing stroke data model
class DrawingStroke {
  final List<Offset> points;
  final bool isEraser;

  DrawingStroke({required this.points, required this.isEraser});
}

/// Available drawing tools
enum DrawingTool {
  pen,
  eraser,
  text,
  rectangle,
  arrow,
  camera,
  magicWand,
}

