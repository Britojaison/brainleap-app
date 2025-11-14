import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/practice_service.dart';
import 'ai_hint_view.dart';
import 'camera_overlay_screen.dart';

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
    _questionController.addListener(_onQuestionChanged);
    _practiceService = PracticeService();
    _canvasController = LocalCanvasController();
  }

  @override
  void dispose() {
    _questionController.removeListener(_onQuestionChanged);
    _questionController.dispose();
    _canvasController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final questionText = _questionController.text.trim();
    if (questionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or scan a question before submitting.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final canvasSnapshot = _canvasController.serializeToJson();
      final canvasState = jsonDecode(canvasSnapshot) as Map<String, dynamic>;
      final auth = context.read<AuthProvider>();

      await _practiceService.submit(
        question: questionText,
        canvas: canvasState,
        userId: auth.user?.id,
        authToken: auth.token,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Practice submission sent successfully.')),
      );
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

  Future<void> _openCameraOverlay() async {
    final extractedText = await CameraOverlayScreen.show(context);
    if (!mounted || extractedText == null) return;

    final trimmed = extractedText.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _questionController
        ..text = trimmed
        ..selection = TextSelection.collapsed(offset: trimmed.length);
    });
  }

  void _onQuestionChanged() {
    setState(() {});
  }

  void _clearQuestion() {
    setState(() {
      _questionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasQuestionText = _questionController.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PracticeHeader(
                onGenerateQuestions: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generating personalized questions...'),
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
              const SizedBox(height: 4),
              _QuestionInputField(
                controller: _questionController,
                onCameraPressed: _openCameraOverlay,
                onClearPressed: _clearQuestion,
                showClearButton: hasQuestionText,
              ),
              const SizedBox(height: 4),
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

// Helper functions for mathematical equation rendering
bool _containsMathNotation(String text) {
  // Comprehensive LaTeX/math patterns for all mathematical expressions
  final mathPatterns = [
    r'\$.*?\$',                      // Inline math: $...$
    r'\$\$.*?\$\$',                  // Display math: $$...$$
    r'\\[a-zA-Z]+\{.*?\}',          // LaTeX commands: \frac{...}
    r'\\[a-zA-Z]+\[.*?\]',          // LaTeX commands with brackets

    // Fractions and roots
    r'\\frac',                      // Fractions
    r'\\dfrac',                     // Display fractions
    r'\\sqrt',                      // Square root

    // Calculus operators
    r'\\int',                       // Integrals
    r'\\oint',                      // Contour integrals
    r'\\sum',                       // Summation
    r'\\prod',                      // Product
    r'\\coprod',                    // Coproduct
    r'\\bigcup',                    // Union
    r'\\bigcap',                    // Intersection
    r'\\lim',                       // Limits
    r'\\partial',                   // Partial derivatives
    r'\\nabla',                     // Nabla/del operator

    // Greek letters
    r'\\alpha', r'\\beta', r'\\gamma', r'\\delta', r'\\epsilon', r'\\varepsilon',
    r'\\zeta', r'\\eta', r'\\theta', r'\\vartheta', r'\\iota', r'\\kappa',
    r'\\lambda', r'\\mu', r'\\nu', r'\\xi', r'\\pi', r'\\varpi', r'\\rho',
    r'\\varrho', r'\\sigma', r'\\varsigma', r'\\tau', r'\\upsilon', r'\\phi',
    r'\\varphi', r'\\chi', r'\\psi', r'\\omega',
    r'\\Gamma', r'\\Delta', r'\\Theta', r'\\Lambda', r'\\Xi', r'\\Pi',
    r'\\Sigma', r'\\Upsilon', r'\\Phi', r'\\Psi', r'\\Omega',

    // Mathematical constants and symbols
    r'\\infty', r'\\emptyset', r'\\forall', r'\\exists', r'\\hbar', r'\\ell',
    r'\\Re', r'\\Im', r'\\wp', r'\\aleph', r'\\beth', r'\\gimel', r'\\daleth',

    // Operators
    r'\\pm', r'\\times', r'\\div', r'\\cdot', r'\\leq', r'\\geq', r'\\neq',
    r'\\approx', r'\\equiv', r'\\cong', r'\\sim', r'\\propto', r'\\to',
    r'\\rightarrow', r'\\leftarrow', r'\\uparrow', r'\\downarrow', r'\\leftrightarrow',
    r'\\Rightarrow', r'\\Leftarrow', r'\\iff', r'\\land', r'\\lor', r'\\neg',
    r'\\implies', r'\\in', r'\\notin', r'\\subset', r'\\subseteq', r'\\supset',
    r'\\supseteq', r'\\cup', r'\\cap', r'\\setminus',

    // Functions
    r'\\sin', r'\\cos', r'\\tan', r'\\cot', r'\\sec', r'\\csc',
    r'\\arcsin', r'\\arccos', r'\\arctan', r'\\sinh', r'\\cosh', r'\\tanh',
    r'\\log', r'\\ln', r'\\lg', r'\\exp', r'\\e',

    // Superscripts and subscripts
    r'_',                           // Subscripts
    r'\^',                          // Superscripts

    // Text formatting
    r'\\mathrm\{.*?\}',             // Roman text
    r'\\mathbf\{.*?\}',             // Bold text
    r'\\mathit\{.*?\}',             // Italic text
    r'\\mathsf\{.*?\}',             // Sans-serif text
    r'\\mathtt\{.*?\}',             // Typewriter text
    r'\\mathcal\{.*?\}',            // Calligraphic text
    r'\\mathbb\{.*?\}',             // Blackboard bold text
    r'\\mathfrak\{.*?\}',           // Fraktur text
  ];

  return mathPatterns.any((pattern) => RegExp(pattern).hasMatch(text));
}


class _MathText extends StatelessWidget {
  const _MathText(this.text, {this.style, this.maxLines});

  final String text;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    if (_containsMathNotation(text)) {
      // Clean up LaTeX text for readable display
      String cleanedText = _cleanLatexText(text);
      return Text(
        cleanedText,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    } else {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }
  }

  String _cleanLatexText(String text) {
    // Remove LaTeX delimiters
    String cleaned = text.replaceAllMapped(RegExp(r'\$(.*?)\$'), (match) => match.group(1)!);
    cleaned = cleaned.replaceAllMapped(RegExp(r'\$\$(.*?)\$\$'), (match) => match.group(1)!);

    // Replace common LaTeX commands with readable equivalents
    final replacements = {
      // Fractions
      r'\frac{': '(',     // Start fraction
      r'}{': ')/(',       // Division in fraction
      r'}': ')',          // End fraction

      // Greek letters
      r'\infty': '∞',
      r'\pi': 'π',
      r'\theta': 'θ',
      r'\alpha': 'α',
      r'\beta': 'β',
      r'\gamma': 'γ',
      r'\delta': 'δ',
      r'\Delta': 'Δ',
      r'\sigma': 'σ',
      r'\lambda': 'λ',
      r'\mu': 'μ',
      r'\nu': 'ν',
      r'\xi': 'ξ',
      r'\rho': 'ρ',
      r'\tau': 'τ',
      r'\phi': 'φ',
      r'\Phi': 'Φ',
      r'\chi': 'χ',
      r'\psi': 'ψ',
      r'\Psi': 'Ψ',
      r'\omega': 'ω',
      r'\Omega': 'Ω',
      r'\epsilon': 'ε',
      r'\varepsilon': 'ε',

      // Mathematical operators
      r'\pm': '±',
      r'\times': '×',
      r'\div': '÷',
      r'\cdot': '·',
      r'\leq': '≤',
      r'\geq': '≥',
      r'\neq': '≠',
      r'\approx': '≈',
      r'\equiv': '≡',
      r'\cong': '≅',
      r'\sim': '∼',
      r'\propto': '∝',
      r'\to': '→',
      r'\rightarrow': '→',
      r'\leftarrow': '←',
      r'\uparrow': '↑',
      r'\downarrow': '↓',
      r'\leftrightarrow': '↔',
      r'\Rightarrow': '⇒',
      r'\Leftarrow': '⇐',
      r'\iff': '⇔',

      // Calculus operators
      r'\nabla': '∇',
      r'\partial': '∂',
      r'\int': '∫',
      r'\oint': '∮',
      r'\sum': '∑',
      r'\prod': '∏',
      r'\coprod': '∐',
      r'\bigcup': '⋃',
      r'\bigcap': '⋂',
      r'\lim': 'lim',
      r'\sup': 'sup',
      r'\inf': 'inf',
      r'\max': 'max',
      r'\min': 'min',

      // Roots and exponents
      r'\sqrt': '√',
      r'\sqrt{': '√(',   // Handle sqrt{expression}

      // Trigonometric functions
      r'\sin': 'sin',
      r'\cos': 'cos',
      r'\tan': 'tan',
      r'\cot': 'cot',
      r'\sec': 'sec',
      r'\csc': 'csc',
      r'\arcsin': 'arcsin',
      r'\arccos': 'arccos',
      r'\arctan': 'arctan',

      // Logarithmic functions
      r'\log': 'log',
      r'\ln': 'ln',
      r'\lg': 'lg',

      // Exponential functions
      r'\exp': 'exp',
      r'\e': 'e',

      // Set theory
      r'\in': '∈',
      r'\notin': '∉',
      r'\subset': '⊂',
      r'\subseteq': '⊆',
      r'\supset': '⊃',
      r'\supseteq': '⊇',
      r'\cup': '∪',
      r'\cap': '∩',
      r'\setminus': '∖',
      r'\emptyset': '∅',
      r'\forall': '∀',
      r'\exists': '∃',

      // Logic
      r'\land': '∧',
      r'\lor': '∨',
      r'\neg': '¬',
      r'\implies': '⇒',

      // Arrows and symbols
      r'\nearrow': '↗',
      r'\searrow': '↘',
      r'\swarrow': '↙',
      r'\nwarrow': '↖',

      // Miscellaneous
      r'\hbar': 'ℏ',
      r'\ell': 'ℓ',
      r'\Re': 'ℜ',
      r'\Im': 'ℑ',
      r'\wp': '℘',
      r'\aleph': 'ℵ',
      r'\beth': 'ℶ',
      r'\gimel': 'ℷ',
      r'\daleth': 'ℸ',
    };

    replacements.forEach((String latex, String readable) {
      cleaned = cleaned.replaceAll(latex, readable);
    });

    // Handle square root with content: \sqrt{x} -> √x
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'√\{([^}]+)\}'),
      (match) => '√${match.group(1)}',
    );

    // Clean up any remaining LaTeX artifacts but be more selective
    // Only remove unknown commands that start with backslash
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\\[a-zA-Z]+(?![a-zA-Z])'), // Remove \command but not \command{
      (match) => '',
    );

    // Clean up braces that are left over
    cleaned = cleaned.replaceAllMapped(RegExp(r'\{([^}]*)\}'), (match) => match.group(1) ?? '');

    // Clean up multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }
}

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
              fontSize: 22,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  'Generate',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.all(4),
            onPressed: onAddQuestion,
            minSize: 0,
            child: Icon(
              CupertinoIcons.add,
              color: Colors.grey.shade800,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatefulWidget {
  const _QuestionCard({
    required this.controller,
    required this.onCameraPressed,
    required this.onClearPressed,
    required this.hasText,
  });

  final TextEditingController controller;
  final VoidCallback onCameraPressed;
  final VoidCallback onClearPressed;
  final bool hasText;

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _isExpanded = false;
  bool _isEditing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_focusNode.hasFocus && !_isExpanded) {
        setState(() => _isExpanded = true);
      } else if (!_focusNode.hasFocus && _isExpanded) {
        setState(() => _isExpanded = false);
      }
    });
  }

  void _toggleExpanded({bool shouldFocus = false}) {
    final wasExpanded = _isExpanded;
    setState(() {
      _isExpanded = !_isExpanded;
      if (!wasExpanded && !_isExpanded) {
        // If collapsing, also exit editing mode
        _isEditing = false;
      }
    });
    if (!wasExpanded && _isExpanded && shouldFocus) {
      // Just expanded and should focus - focus for editing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    } else if (wasExpanded && !_isExpanded) {
      // Just collapsed - unfocus
      _focusNode.unfocus();
    }
  }

  String _getSnippet(String text) {
    if (text.length <= 80) return text;
    return text.substring(0, 77) + '...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = widget.controller.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Question',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            if (widget.hasText) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'Ready',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.hasText && _isExpanded ? () => _focusNode.requestFocus() : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.hasText ? Colors.blue.shade200 : Colors.grey.shade300,
                width: widget.hasText ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with actions
                    Row(
                      children: [
                        if (widget.hasText)
                          GestureDetector(
                            onTap: () => _toggleExpanded(shouldFocus: false),
                            child: Icon(
                              _isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          )
                        else
                          Icon(
                            CupertinoIcons.question_circle,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                        const Spacer(),
                        if (widget.hasText)
                          _QuestionActionButton(
                            icon: CupertinoIcons.xmark,
                            tooltip: 'Clear question',
                            onTap: widget.onClearPressed,
                            size: 32,
                          ),
                        _QuestionActionButton(
                          icon: CupertinoIcons.camera_fill,
                          tooltip: 'Scan question',
                          onTap: widget.onCameraPressed,
                          size: 32,
                          margin: const EdgeInsets.only(left: 8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Question content
                    if (widget.hasText) ...[
                      if (!_isExpanded) ...[
                        // Collapsed view - show snippet
                        GestureDetector(
                          onTap: () => _toggleExpanded(shouldFocus: true),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MathText(
                                _getSnippet(text),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap text to expand',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Expanded view - show readable math or editing field
                        if (_isEditing) ...[
                          // Show editing TextField
                          TextField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            minLines: 1,
                            maxLines: 6,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() => _isEditing = false);
                                  _focusNode.unfocus();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.checkmark,
                                        size: 14,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Done',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Show readable math
                          _MathText(
                            text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => setState(() => _isEditing = true),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.pencil,
                                    size: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Tap here to edit',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Tap chevron ↑ to collapse',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ] else ...[
                      // Empty state - allow direct typing
                      TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Type or scan your question',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ],
                ),
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
    required this.onClearPressed,
    required this.showClearButton,
  });

  final TextEditingController controller;
  final VoidCallback onCameraPressed;
  final VoidCallback onClearPressed;
  final bool showClearButton;

  @override
  Widget build(BuildContext context) {
    return _QuestionCard(
      controller: controller,
      onCameraPressed: onCameraPressed,
      onClearPressed: onClearPressed,
      hasText: showClearButton,
    );
  }
}

class _QuestionActionButton extends StatelessWidget {
  const _QuestionActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.margin = EdgeInsets.zero,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final EdgeInsets margin;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          icon: Icon(icon, size: size * 0.5, color: Colors.grey.shade800),
        ),
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
