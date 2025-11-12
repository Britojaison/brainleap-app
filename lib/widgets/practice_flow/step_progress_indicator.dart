import 'package:flutter/material.dart';

import '../../config/practice_theme.dart';

/// Progress indicator showing current step in the flow (e.g., 3 out of 6)
class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
  }) : assert(currentStep > 0 && currentStep <= totalSteps,
            'currentStep must be between 1 and totalSteps');

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        final isLast = index == totalSteps - 1;

        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: isLast ? 0 : 4),
            decoration: BoxDecoration(
              color: isActive
                  ? PracticeTheme.primaryBlack
                  : PracticeTheme.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

