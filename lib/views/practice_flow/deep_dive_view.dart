import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/practice_theme.dart';
import '../../models/practice_flow/topic_data.dart';
import '../../providers/practice_flow_provider.dart';
import '../../widgets/practice_flow/practice_flow_header.dart';
import '../../widgets/practice_flow/step_progress_indicator.dart';
import '../../widgets/practice_flow/topic_accordion.dart';
import 'question_loading_view.dart';

/// Step 5/6: Deep dive screen with accordion for subtopic selection
class DeepDiveView extends StatefulWidget {
  const DeepDiveView({super.key});

  @override
  State<DeepDiveView> createState() => _DeepDiveViewState();
}

class _DeepDiveViewState extends State<DeepDiveView> {
  int? _expandedIndex;
  String? _selectedSubtopic;

  void _toggleAccordion(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  void _selectSubtopic(String subtopic) {
    setState(() {
      _selectedSubtopic = subtopic;
    });

    // Update provider
    context.read<PracticeFlowProvider>().updateSubtopic(subtopic);
  }

  void _handleNext() {
    if (_selectedSubtopic == null) return;

    // Navigate to loading screen for question generation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuestionLoadingView(),
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
    final topic = provider.selection.topic ?? 'Algebra & Functions';
    final topicStructure = TopicData.getTopicStructure(subject);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PracticeFlowHeader(
        title: 'Deep Dive',
        onCancel: _handleCancel,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PracticeTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepProgressIndicator(currentStep: 5),
              const SizedBox(height: 32),
              Text(
                'Deep Dive Into $topic',
                style: PracticeTextStyles.heading,
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a specific subtopic to focus on',
                style: PracticeTextStyles.subtext,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: topicStructure.keys.length,
                  itemBuilder: (context, index) {
                    final topicTitle = topicStructure.keys.elementAt(index);
                    final subtopics = topicStructure[topicTitle] ?? [];

                    return TopicAccordion(
                      title: topicTitle,
                      subtopics: subtopics,
                      isExpanded: _expandedIndex == index,
                      onToggle: () => _toggleAccordion(index),
                      selectedSubtopic: _selectedSubtopic,
                      onSubtopicSelected: _selectSubtopic,
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
    final isEnabled = _selectedSubtopic != null;

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

