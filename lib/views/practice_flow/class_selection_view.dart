import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/practice_theme.dart';
import '../../models/practice_flow/topic_data.dart';
import '../../providers/practice_flow_provider.dart';
import '../../widgets/practice_flow/pill_button.dart';
import '../../widgets/practice_flow/practice_flow_header.dart';
import '../../widgets/practice_flow/step_progress_indicator.dart';
import 'subject_selection_view.dart';

/// Step 1/6: Class selection screen
class ClassSelectionView extends StatefulWidget {
  const ClassSelectionView({super.key});

  @override
  State<ClassSelectionView> createState() => _ClassSelectionViewState();
}

class _ClassSelectionViewState extends State<ClassSelectionView> {
  String? _selectedClass;

  void _handleClassSelection(String className) {
    setState(() {
      _selectedClass = className;
    });

    // Update provider
    context.read<PracticeFlowProvider>().updateClass(className);
  }

  void _handleNext() {
    if (_selectedClass == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SubjectSelectionView(),
      ),
    );
  }

  void _handleCancel() {
    // Return to home (pop all practice flow screens)
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PracticeFlowHeader(
        title: 'Choose Class',
        onCancel: _handleCancel,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PracticeTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepProgressIndicator(currentStep: 1),
              const SizedBox(height: 32),
              const Text(
                'Select Your Class',
                style: PracticeTextStyles.heading,
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose the class you're currently studying in",
                style: PracticeTextStyles.subtext,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: PracticeTheme.pillSpacing,
                runSpacing: PracticeTheme.pillSpacing,
                children: TopicData.classLevels.map((className) {
                  return PillButton(
                    label: className,
                    isSelected: _selectedClass == className,
                    onTap: () => _handleClassSelection(className),
                  );
                }).toList(),
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
    final isEnabled = _selectedClass != null;

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

