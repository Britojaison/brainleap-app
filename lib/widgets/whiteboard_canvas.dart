import 'package:flutter/material.dart';

class WhiteboardController extends ChangeNotifier {
  final List<Offset> _points = <Offset>[];

  List<Offset> get points => List.unmodifiable(_points);

  void addPoint(Offset point) {
    _points.add(point);
    notifyListeners();
  }

  void clear() {
    _points.clear();
    notifyListeners();
  }

  String serialize() {
    return points.map((point) => '${point.dx},${point.dy}').join(';');
  }

  @override
  void dispose() {
    _points.clear();
    super.dispose();
  }
}

class WhiteboardCanvas extends StatefulWidget {
  const WhiteboardCanvas({super.key, required this.controller});

  final WhiteboardController controller;

  @override
  State<WhiteboardCanvas> createState() => _WhiteboardCanvasState();
}

class _WhiteboardCanvasState extends State<WhiteboardCanvas> {
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
      onPanUpdate: (details) {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        final offset = box?.globalToLocal(details.globalPosition) ?? Offset.zero;
        widget.controller.addPoint(offset);
      },
      onPanEnd: (_) => widget.controller.addPoint(Offset.infinite),
      child: CustomPaint(
        painter: _WhiteboardPainter(widget.controller.points),
        child: Container(
          color: Colors.grey.shade200,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: widget.controller.clear,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Clear'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WhiteboardPainter extends CustomPainter {
  _WhiteboardPainter(this.points);

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

