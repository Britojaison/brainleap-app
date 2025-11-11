import 'package:flutter/material.dart';

import '../providers/ai_assistant_provider.dart';
import '../widgets/ai_hint_button.dart';
import '../widgets/whiteboard_canvas.dart';

class AnswerCanvasView extends StatefulWidget {
  const AnswerCanvasView({super.key, required this.questionId});

  final String questionId;

  @override
  State<AnswerCanvasView> createState() => _AnswerCanvasViewState();
}

class _AnswerCanvasViewState extends State<AnswerCanvasView> {
  final WhiteboardController _whiteboardController = WhiteboardController();
  late final AiAssistantProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AiAssistantProvider();
  }

  @override
  void dispose() {
    _whiteboardController.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Answer Canvas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () => _provider.evaluateAnswer(
              questionId: widget.questionId,
              canvasState: _whiteboardController.serialize(),
            ),
            tooltip: 'Evaluate Answer',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: WhiteboardCanvas(controller: _whiteboardController),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<AiAssistantState>(
              valueListenable: _provider.state,
              builder: (context, value, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (value.isLoading) const LinearProgressIndicator(),
                    if (value.hint != null) ...[
                      Text(value.hint!.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(value.hint!.explanation),
                    ],
                    if (value.errorMessage != null) ...[
                      Text(value.errorMessage!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 12),
                    AiHintButton(
                      onPressed: () => _provider.fetchHint(
                        questionId: widget.questionId,
                        canvasState: _whiteboardController.serialize(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

