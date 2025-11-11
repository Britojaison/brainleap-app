import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import 'answer_canvas_view.dart';
import 'topic_selection_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? _lastQuestionId;
  String? _lastTopicName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentSession();
  }

  Future<void> _loadRecentSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastQuestionId = prefs.getString(StorageKeys.lastQuestionId);
      _lastTopicName = prefs.getString('last_topic_name');
      _isLoading = false;
    });
  }

  Future<void> _navigateToCanvas(String questionId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnswerCanvasView(questionId: questionId),
      ),
    );
    // Reload recent session after returning
    await _loadRecentSession();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_lastQuestionId != null)
          Card(
            elevation: 2,
            child: ListTile(
              title: const Text('Continue where you left off'),
              subtitle: Text(_lastTopicName ?? 'Resume last question'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _navigateToCanvas(_lastQuestionId!),
            ),
          ),
        if (_lastQuestionId != null) const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.view_module),
            title: const Text('Select Topic'),
            subtitle: const Text('Browse available modules'),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TopicSelectionView()),
              );
              await _loadRecentSession();
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.history_edu),
            title: const Text('Open Practice Whiteboard'),
            subtitle: const Text('Draw answers, get real-time AI help'),
            onTap: () => _navigateToCanvas('practice-${DateTime.now().millisecondsSinceEpoch}'),
          ),
        ),
      ],
    );
  }
}
