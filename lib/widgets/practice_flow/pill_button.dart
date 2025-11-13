import 'package:flutter/material.dart';

import '../../config/practice_theme.dart';

/// Pill-shaped selectable button used throughout the practice flow
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: PracticeTheme.animationDuration,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PracticeTheme.pillRadius),
          border: isSelected
              ? null
              : Border.all(
                  color: PracticeTheme.grey100,
                  width: 1,
                ),
          color: isSelected
              ? PracticeTheme.primaryBlack
              : PracticeTheme.grey50,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: isSelected
              ? PracticeTextStyles.pillTextSelected
              : PracticeTextStyles.pillText,
        ),
      ),
    );
  }
}

