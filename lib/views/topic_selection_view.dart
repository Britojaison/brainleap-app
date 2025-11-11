import 'package:flutter/material.dart';

class TopicSelectionView extends StatelessWidget {
  const TopicSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      'Algebra - Linear Equations',
      'Geometry - Triangles',
      'Calculus - Derivatives',
      'Physics - Motion',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Topic')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final topic = topics[index];
          return Card(
            child: ListTile(
              title: Text(topic),
              subtitle: const Text('Open practice set and whiteboard'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navigate to AnswerCanvasView with selected topic context.
              },
            ),
          );
        },
      ),
    );
  }
}

