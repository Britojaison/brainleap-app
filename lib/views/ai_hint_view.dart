import 'package:flutter/material.dart';

import '../providers/ai_assistant_provider.dart';
import '../widgets/ai_hint_button.dart';

class AiHintView extends StatefulWidget {
  const AiHintView({super.key, required this.questionId, required this.canvasState});

  final String questionId;
  final String canvasState;

  @override
  State<AiHintView> createState() => _AiHintViewState();
}

class _AiHintViewState extends State<AiHintView> {
  late final AiAssistantProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AiAssistantProvider();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Hint')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'AI-guided Hint',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ValueListenableBuilder<AiAssistantState>(
                    valueListenable: _provider.state,
                    builder: (context, value, _) {
                      if (value.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (value.errorMessage != null) {
                        return Center(child: Text(value.errorMessage!));
                      }
                      if (value.hint == null) {
                        return const Center(
                          child: Text('Press the button below to ask for help.'),
                        );
                      }
                      return ListView(
                        children: [
                          Text(value.hint!.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(value.hint!.explanation),
                          if (value.hint!.nextSteps.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text('Try next:', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...value.hint!.nextSteps.map((step) => ListTile(
                                  leading: const Icon(Icons.bolt_outlined),
                                  title: Text(step),
                                )),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            AiHintButton(
              onPressed: () => _provider.fetchHint(
                questionId: widget.questionId,
                canvasState: widget.canvasState,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

