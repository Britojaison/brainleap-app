import 'package:flutter/material.dart';

import 'answer_canvas_view.dart';
import 'topic_selection_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text('Continue where you left off'),
            subtitle: const Text('Algebra: Linear Equations'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AnswerCanvasView(questionId: 'algebra-linear-1'),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.view_module),
            title: const Text('Select Topic'),
            subtitle: const Text('Browse available modules'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TopicSelectionView()),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history_edu),
            title: const Text('Open Practice Whiteboard'),
            subtitle: const Text('Draw answers, get real-time AI help'),
            onTap: () {
              // TODO: Navigate to drawing canvas with AI assistance overlay.
            },
          ),
        ),
      ],
    );
  }
}
