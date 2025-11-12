import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/practice_service.dart';
import '../providers/practice_flow_provider.dart';
import 'ai_hint_view.dart';
import '../main.dart';
import 'practice_flow/class_selection_view.dart';

class PracticeView extends StatefulWidget {
  const PracticeView({super.key});

  @override
  State<PracticeView> createState() => _PracticeViewState();
}

class _PracticeViewState extends State<PracticeView> {
  late final TextEditingController _questionController;
  late final PracticeService _practiceService;
  late final LocalCanvasController _canvasController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _practiceService = PracticeService();
    _canvasController = LocalCanvasController();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _canvasController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      final generatedQuestion =
          context.read<PracticeFlowProvider>().currentQuestion;

      if (generatedQuestion != null) {
        // Submitting answer to generated question
        final canvasSnapshot = _canvasController.serializeToJson();
        await _practiceService.submitAnswer(
          questionId: generatedQuestion.questionId,
          answerData: canvasSnapshot,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Answer submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear question and canvas after submission
        context.read<PracticeFlowProvider>().clearCurrentQuestion();
        _canvasController.clear();
      } else {
        // Manual practice submission
        final canvasSnapshot = _canvasController.serializeToJson();
        final payload = jsonEncode({
          'question': _questionController.text.trim(),
          'canvas': jsonDecode(canvasSnapshot),
        });
        await _practiceService.submit(payload);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Practice submission sent successfully.')),
        );
      }
    } on PracticeSubmissionException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _openAiHint() async {
    final canvasState = _canvasController.serializeToJson();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiHintView(
          questionId: _questionController.text.trim().isEmpty
              ? 'practice-session'
              : _questionController.text.trim(),
          canvasState: canvasState,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for generated question
    final generatedQuestion =
        context.watch<PracticeFlowProvider>().currentQuestion;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PracticeHeader(
                onGenerateQuestions: () {
                  // Navigate to practice flow
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClassSelectionView(),
                    ),
                  );
                },
                onAddQuestion: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add your own question coming soon.'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Show generated question card if available
              if (generatedQuestion != null)
                _GeneratedQuestionCard(
                  question: generatedQuestion.question,
                  topic: generatedQuestion.topic,
                  subtopic: generatedQuestion.subtopic,
                  difficulty: generatedQuestion.difficulty,
                  onClose: () {
                    context.read<PracticeFlowProvider>().clearCurrentQuestion();
                    _canvasController.clear();
                  },
                ),

              // Show question input field only if no generated question
              if (generatedQuestion == null)
                _QuestionInputField(
                  controller: _questionController,
                  onCameraPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Image capture integration is in progress.'),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.blue, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Stack(
                      children: [
                        LocalDrawingCanvas(
                          controller: _canvasController,
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 16,
                          child: Center(
                            child: _WhiteboardToolbar(
                              onPenTap: () =>
                                  _canvasController.setTool(DrawingTool.pen),
                              onEraserTap: () =>
                                  _canvasController.setTool(DrawingTool.eraser),
                              onUndoTap: _canvasController.undo,
                              onRedoTap: _canvasController.redo,
                              onClearTap: _canvasController.clear,
                              onAiHintTap: _openAiHint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SubmitButton(
                isSubmitting: _isSubmitting,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

enum DrawingTool { pen, eraser }

class LocalCanvasController extends ChangeNotifier {
  final List<DrawingStroke> _strokes = [];
  final List<DrawingStroke> _redoStack = [];
  DrawingTool _currentTool = DrawingTool.pen;
  bool _isDrawing = false;

  List<DrawingStroke> get strokes => _strokes;
  DrawingTool get currentTool => _currentTool;
  bool get isDrawing => _isDrawing;

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

  String serializeToJson() {
    final data = _strokes.map((stroke) {
      return {
        'points': stroke.points
            .where((p) => p != Offset.infinite)
            .map((p) => {'x': p.dx, 'y': p.dy})
            .toList(),
        'isEraser': stroke.isEraser,
      };
    }).toList();
    return jsonEncode({'strokes': data});
  }
}

class DrawingStroke {
  final List<Offset> points;
  final bool isEraser;

  DrawingStroke({required this.points, required this.isEraser});
}

class LocalDrawingCanvas extends StatefulWidget {
  const LocalDrawingCanvas({super.key, required this.controller});

  final LocalCanvasController controller;

  @override
  State<LocalDrawingCanvas> createState() => _LocalDrawingCanvasState();
}

class _LocalDrawingCanvasState extends State<LocalDrawingCanvas> {
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
          painter: _CanvasPainter(
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

class _CanvasPainter extends CustomPainter {
  _CanvasPainter({required this.strokes});

  final List<DrawingStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dotted grid background
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    const dotRadius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, gridPaint);
      }
    }

    // Draw all strokes with optimized painting
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
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return true; // Always repaint for smooth drawing
  }
}

class _PracticeHeader extends StatelessWidget {
  const _PracticeHeader({
    required this.onGenerateQuestions,
    required this.onAddQuestion,
  });

  final VoidCallback onGenerateQuestions;
  final VoidCallback onAddQuestion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Practice',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(24),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onPressed: onGenerateQuestions,
            minSize: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '✨',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
                Text(
                  'Generate Questions',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.all(6),
            onPressed: onAddQuestion,
            minSize: 0,
            child: Icon(
              CupertinoIcons.add,
              color: Colors.grey.shade800,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionInputField extends StatelessWidget {
  const _QuestionInputField({
    required this.controller,
    required this.onCameraPressed,
  });

  final TextEditingController controller;
  final VoidCallback onCameraPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration.collapsed(
                hintText: '1. Type your questions',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: onCameraPressed,
              icon: const Icon(CupertinoIcons.camera_fill, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteboardToolbar extends StatelessWidget {
  const _WhiteboardToolbar({
    required this.onPenTap,
    required this.onEraserTap,
    required this.onUndoTap,
    required this.onRedoTap,
    required this.onClearTap,
    required this.onAiHintTap,
  });

  final VoidCallback onPenTap;
  final VoidCallback onEraserTap;
  final VoidCallback onUndoTap;
  final VoidCallback onRedoTap;
  final VoidCallback onClearTap;
  final Future<void> Function() onAiHintTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ToolbarIconButton(icon: CupertinoIcons.pencil, onTap: onPenTap),
          _ToolbarIconButton(
              icon: CupertinoIcons.delete_left, onTap: onEraserTap),
          _ToolbarIconButton(icon: CupertinoIcons.textformat, onTap: () {}),
          _ToolbarIconButton(icon: CupertinoIcons.rectangle, onTap: () {}),
          _ToolbarIconButton(
              icon: CupertinoIcons.arrow_right, onTap: onUndoTap),
          _ToolbarIconButton(icon: CupertinoIcons.camera, onTap: () {}),
          _ToolbarIconButton(
              icon: CupertinoIcons.sparkles, onTap: () => onAiHintTap()),
        ],
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.black87, size: 22),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F1F1F),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Widget to display generated question at top of practice view
class _GeneratedQuestionCard extends StatelessWidget {
  const _GeneratedQuestionCard({
    required this.question,
    required this.topic,
    required this.subtopic,
    required this.difficulty,
    required this.onClose,
  });

  final String question;
  final String topic;
  final String subtopic;
  final String difficulty;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with label and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'AI GENERATED QUESTION',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      difficulty.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getDifficultyColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.grey[400],
                  size: 22,
                ),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Question text
          Text(
            question,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Topic tags
          Wrap(
            spacing: 8,
            children: [
              _buildTag(topic, CupertinoIcons.book_fill),
              _buildTag(subtopic, CupertinoIcons.layers_fill),
            ],
          ),

          const SizedBox(height: 12),

          // Instruction text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.pencil_circle_fill,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Write your answer on the canvas below',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
