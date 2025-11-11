import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_assistant_provider.dart';
import '../widgets/ai_hint_button.dart';

class AiHintView extends StatelessWidget {
  const AiHintView({super.key, required this.questionId, required this.canvasState});

  final String questionId;
  final String canvasState;

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
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer<AiAssistantProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                provider.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      }
                      if (provider.hint == null) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.smart_toy_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Press the button below to ask for help.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView(
                        children: [
                          Text(
                            provider.hint!.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(provider.hint!.explanation),
                          if (provider.hint!.nextSteps.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text('Try next:', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...provider.hint!.nextSteps.map((step) => ListTile(
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
            const SizedBox(height: 16),
            AiHintButton(
              onPressed: () {
                context.read<AiAssistantProvider>().fetchHint(
                      questionId: questionId,
                      canvasState: canvasState,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

