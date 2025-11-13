import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/practice_theme.dart';
import '../../models/practice_flow/topic_data.dart';
import '../../providers/practice_flow_provider.dart';
import '../../widgets/practice_flow/pill_button.dart';
import '../../widgets/practice_flow/practice_flow_header.dart';
import '../../widgets/practice_flow/step_progress_indicator.dart';
import 'deep_dive_view.dart';

/// Step 4/6: Topic selection screen
class TopicSelectionView extends StatefulWidget {
  const TopicSelectionView({super.key});

  @override
  State<TopicSelectionView> createState() => _TopicSelectionViewState();
}

class _TopicSelectionViewState extends State<TopicSelectionView> {
  String? _selectedTopic;

  @override
  void initState() {
    super.initState();
    // Get subject from provider to show relevant topics
    _selectedTopic = context.read<PracticeFlowProvider>().selection.topic;
  }

  void _handleTopicSelection(String topic) {
    setState(() {
      _selectedTopic = topic;
    });

    // Update provider
    context.read<PracticeFlowProvider>().updateTopic(topic);
  }

  void _handleNext() {
    if (_selectedTopic == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeepDiveView(),
      ),
    );
  }

  void _handleCancel() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeFlowProvider>();
    final subject = provider.selection.subject ?? 'Mathematics';
    final topics = TopicData.getTopicsForSubject(subject);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PracticeFlowHeader(
        title: 'Choose Topic',
        onCancel: _handleCancel,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PracticeTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepProgressIndicator(currentStep: 4),
              const SizedBox(height: 32),
              const Text(
                'Select Topic',
                style: PracticeTextStyles.heading,
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick the main topic you want to practice',
                style: PracticeTextStyles.subtext,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: topics.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: PracticeTheme.pillSpacing),
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    return PillButton(
                      label: topic,
                      isSelected: _selectedTopic == topic,
                      onTap: () => _handleTopicSelection(topic),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final isEnabled = _selectedTopic != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F1F1F),
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          'Next',
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.grey.shade600,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

