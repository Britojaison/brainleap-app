import 'package:flutter/material.dart';

import '../../config/practice_theme.dart';

/// Expandable accordion widget for topic/subtopic selection
class TopicAccordion extends StatelessWidget {
  const TopicAccordion({
    super.key,
    required this.title,
    required this.subtopics,
    required this.isExpanded,
    required this.onToggle,
    this.selectedSubtopic,
    required this.onSubtopicSelected,
  });

  final String title;
  final List<String> subtopics;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? selectedSubtopic;
  final Function(String) onSubtopicSelected;

  @override
  Widget build(BuildContext context) {
    final hasSubtopics = subtopics.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PracticeTheme.cardRadius),
        border: Border.all(color: PracticeTheme.grey100),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: hasSubtopics ? onToggle : null,
            borderRadius: BorderRadius.circular(PracticeTheme.cardRadius),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: PracticeTextStyles.accordionTitle,
                    ),
                  ),
                  if (hasSubtopics)
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: PracticeTheme.animationDuration,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Expandable content (subtopics)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: subtopics.map((subtopic) {
                final isSelected = selectedSubtopic == subtopic;
                return InkWell(
                  onTap: () => onSubtopicSelected(subtopic),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? PracticeTheme.grey50
                          : Colors.transparent,
                      border: const Border(
                        top: BorderSide(color: PracticeTheme.grey100),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 20,
                          color: isSelected
                              ? PracticeTheme.primaryBlack
                              : PracticeTheme.grey600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            subtopic,
                            style: isSelected
                                ? PracticeTextStyles.accordionSubtitleSelected
                                : PracticeTextStyles.accordionSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: PracticeTheme.animationDuration,
          ),
        ],
      ),
    );
  }
}

