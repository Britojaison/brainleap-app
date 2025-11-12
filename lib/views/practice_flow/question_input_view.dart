import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/practice_theme.dart';
import '../../providers/practice_flow_provider.dart';
import '../../widgets/practice_flow/canvas_toolbar.dart';
import '../../widgets/practice_flow/dotted_grid_canvas.dart';
import '../../widgets/practice_flow/practice_flow_header.dart';
import '../../widgets/practice_flow/step_progress_indicator.dart';

/// Step 6/6: Question input screen with drawing canvas
class QuestionInputView extends StatefulWidget {
  const QuestionInputView({super.key});

  @override
  State<QuestionInputView> createState() => _QuestionInputViewState();
}

class _QuestionInputViewState extends State<QuestionInputView> {
  late final DrawingController _drawingController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _drawingController = DrawingController();
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_drawingController.hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw or write your question first'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<PracticeFlowProvider>();
      final selection = provider.selection;

      // TODO: Implement image export from canvas
      // final imageData = await _drawingController.exportAsImage();
      // provider.updateQuestionImage(imageData);

      // TODO: Submit to backend
      debugPrint('Submitting question with:');
      debugPrint('Class: ${selection.classLevel}');
      debugPrint('Subject: ${selection.subject}');
      debugPrint('Curriculum: ${selection.curriculum}');
      debugPrint('Topic: ${selection.topic}');
      debugPrint('Subtopic: ${selection.subtopic}');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Success - return to home
      Navigator.popUntil(context, (route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset provider
      provider.reset();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleCancel() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Question Input?'),
        content: const Text(
          'Your drawing will be lost. Are you sure you want to cancel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Drawing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PracticeFlowHeader(
        title: 'Question Input',
        onCancel: _handleCancel,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PracticeTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepProgressIndicator(currentStep: 6),
              const SizedBox(height: 32),
              const Text(
                'Draw or Write Your Question',
                style: PracticeTextStyles.heading,
              ),
              const SizedBox(height: 8),
              const Text(
                'Use the tools below to input your question',
                style: PracticeTextStyles.subtext,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: PracticeTheme.accentBlue,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        DottedGridCanvas(
                          controller: _drawingController,
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 16,
                          child: Center(
                            child: CanvasToolbar(
                              selectedTool: _drawingController.currentTool,
                              onToolSelected: (tool) {
                                _drawingController.setTool(tool);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F1F1F),
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Submit Question',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

