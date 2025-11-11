import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/ai_assistant_provider.dart';
import '../utils/constants.dart';
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

  @override
  void initState() {
    super.initState();
    _saveQuestionId();
  }

  Future<void> _saveQuestionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.lastQuestionId, widget.questionId);
  }

  @override
  void dispose() {
    _whiteboardController.dispose();
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
            onPressed: () {
              context.read<AiAssistantProvider>().evaluateAnswer(
                    questionId: widget.questionId,
                    canvasState: _whiteboardController.serialize(),
                  );
            },
            tooltip: 'Evaluate Answer',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: WhiteboardCanvas(controller: _whiteboardController),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<AiAssistantProvider>(
                builder: (context, provider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (provider.isLoading) ...[
                        const LinearProgressIndicator(),
                        const SizedBox(height: 12),
                      ],
                      if (provider.hint != null) ...[
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.smart_toy, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        provider.hint!.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: provider.clearHint,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(provider.hint!.explanation),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (provider.errorMessage != null) ...[
                        Card(
                          color: Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    provider.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: provider.clearHint,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      AiHintButton(
                        onPressed: () {
                          provider.fetchHint(
                            questionId: widget.questionId,
                            canvasState: _whiteboardController.serialize(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

