import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/practice_theme.dart';
import '../../models/practice_flow/topic_data.dart';
import '../../providers/practice_flow_provider.dart';
import '../../widgets/practice_flow/pill_button.dart';
import '../../widgets/practice_flow/practice_flow_header.dart';
import '../../widgets/practice_flow/step_progress_indicator.dart';
import 'topic_selection_view.dart';

/// Step 3/6: Curriculum selection screen
class CurriculumSelectionView extends StatefulWidget {
  const CurriculumSelectionView({super.key});

  @override
  State<CurriculumSelectionView> createState() =>
      _CurriculumSelectionViewState();
}

class _CurriculumSelectionViewState extends State<CurriculumSelectionView> {
  String? _selectedCurriculum;

  void _handleCurriculumSelection(String curriculum) {
    setState(() {
      _selectedCurriculum = curriculum;
    });

    // Update provider
    context.read<PracticeFlowProvider>().updateCurriculum(curriculum);
  }

  void _handleNext() {
    if (_selectedCurriculum == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TopicSelectionView(),
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
        title: 'Choose Curriculum',
        onCancel: _handleCancel,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PracticeTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepProgressIndicator(currentStep: 3),
              const SizedBox(height: 32),
              const Text(
                'Select Your Curriculum',
                style: PracticeTextStyles.heading,
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose your educational board or examination',
                style: PracticeTextStyles.subtext,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: TopicData.curriculums.length,
                  itemBuilder: (context, index) {
                    final curriculum = TopicData.curriculums[index];
                    return PillButton(
                      label: curriculum,
                      isSelected: _selectedCurriculum == curriculum,
                      onTap: () => _handleCurriculumSelection(curriculum),
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
    final isEnabled = _selectedCurriculum != null;

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

