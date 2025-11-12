import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/practice_flow/generated_question.dart';
import '../../providers/practice_flow_provider.dart';
import '../../services/practice_service.dart';

/// Loading screen while AI generates question
class QuestionLoadingView extends StatefulWidget {
  const QuestionLoadingView({super.key});

  @override
  State<QuestionLoadingView> createState() => _QuestionLoadingViewState();
}

class _QuestionLoadingViewState extends State<QuestionLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final PracticeService _practiceService;

  @override
  void initState() {
    super.initState();
    _practiceService = PracticeService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Start generating question
    _generateQuestion();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateQuestion() async {
    try {
      final provider = context.read<PracticeFlowProvider>();
      final selection = provider.selection;

      debugPrint('🔄 Generating question with selections:');
      debugPrint('   Class: ${selection.classLevel}');
      debugPrint('   Subject: ${selection.subject}');
      debugPrint('   Curriculum: ${selection.curriculum}');
      debugPrint('   Topic: ${selection.topic}');
      debugPrint('   Subtopic: ${selection.subtopic}');

      // Call API to generate question
      final response = await _practiceService.generateQuestion(
        classLevel: selection.classLevel!,
        subject: selection.subject!,
        curriculum: selection.curriculum!,
        topic: selection.topic!,
        subtopic: selection.subtopic!,
      );

      debugPrint('✅ Question generated successfully');

      if (!mounted) return;

      // Parse response and store in provider
      final questionData = response['data'] as Map<String, dynamic>;
      final question = GeneratedQuestion.fromJson(questionData);
      
      provider.setCurrentQuestion(question);

      debugPrint('📝 Question stored: ${question.question}');

      // Navigate back to home screen
      Navigator.popUntil(context, (route) => route.isFirst);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question generated! Write your answer below.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('❌ Question generation failed: $e');

      if (!mounted) return;

      // Show error and return to previous screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate question: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              _generateQuestion();
            },
          ),
        ),
      );

      // Go back to previous screen after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated loading spinner
                SizedBox(
                  width: 60,
                  height: 60,
                  child: RotationTransition(
                    turns: _animationController,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 3,
                        ),
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Generating Questions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle with animated dots
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final progress = _animationController.value;
                    final dots = '.' * ((progress * 3).floor() + 1);
                    return Text(
                      'Creating a personalized question for you$dots',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Optional: Selection summary
                _buildSelectionSummary(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionSummary() {
    final provider = context.watch<PracticeFlowProvider>();
    final selection = provider.selection;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Class', selection.classLevel ?? ''),
          const SizedBox(height: 8),
          _buildSummaryRow('Subject', selection.subject ?? ''),
          const SizedBox(height: 8),
          _buildSummaryRow('Topic', selection.topic ?? ''),
          const SizedBox(height: 8),
          _buildSummaryRow('Subtopic', selection.subtopic ?? ''),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

