import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/practice_theme.dart';
import '../../models/practice_flow/topic_data.dart';
import '../../providers/practice_flow_provider.dart';
import '../../widgets/practice_flow/pill_button.dart';
import '../../widgets/practice_flow/practice_flow_header.dart';
import '../../widgets/practice_flow/step_progress_indicator.dart';
import 'curriculum_selection_view.dart';

/// Step 2/6: Subject selection screen
class SubjectSelectionView extends StatefulWidget {
  const SubjectSelectionView({super.key});

  @override
  State<SubjectSelectionView> createState() => _SubjectSelectionViewState();
}

class _SubjectSelectionViewState extends State<SubjectSelectionView> {
  String? _selectedSubject;

  void _handleSubjectSelection(String subject) {
    setState(() {
      _selectedSubject = subject;
    });

    // Update provider
    context.read<PracticeFlowProvider>().updateSubject(subject);
  }

  void _handleNext() {
    if (_selectedSubject == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CurriculumSelectionView(),
      ),
    );
  }

  void _handleCancel() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PracticeFlowHeader(
        title: 'Choose Subject',
        onCancel: _handleCancel,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PracticeTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepProgressIndicator(currentStep: 2),
              const SizedBox(height: 32),
              const Text(
                'Select Your Subject',
                style: PracticeTextStyles.heading,
              ),
              const SizedBox(height: 8),
              const Text(
                'Which subject would you like to practice?',
                style: PracticeTextStyles.subtext,
              ),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: TopicData.subjects.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: PracticeTheme.pillSpacing),
                itemBuilder: (context, index) {
                  final subject = TopicData.subjects[index];
                  return PillButton(
                    label: subject,
                    isSelected: _selectedSubject == subject,
                    onTap: () => _handleSubjectSelection(subject),
                  );
                },
              ),
              const Spacer(),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final isEnabled = _selectedSubject != null;

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

