import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../models/practice_flow/practice_selection.dart';
import '../models/practice_flow/generated_question.dart';

/// Provider to manage state throughout the practice flow
class PracticeFlowProvider extends ChangeNotifier {
  PracticeSelection _selection = PracticeSelection();
  GeneratedQuestion? _currentQuestion;

  PracticeSelection get selection => _selection;
  GeneratedQuestion? get currentQuestion => _currentQuestion;

  /// Update class level selection
  void updateClass(String classLevel) {
    _selection.classLevel = classLevel;
    notifyListeners();
  }

  /// Update subject selection
  void updateSubject(String subject) {
    _selection.subject = subject;
    notifyListeners();
  }

  /// Update curriculum selection
  void updateCurriculum(String curriculum) {
    _selection.curriculum = curriculum;
    notifyListeners();
  }

  /// Update topic selection
  void updateTopic(String topic) {
    _selection.topic = topic;
    notifyListeners();
  }

  /// Update subtopic selection
  void updateSubtopic(String subtopic) {
    _selection.subtopic = subtopic;
    notifyListeners();
  }

  /// Update question image
  void updateQuestionImage(Uint8List image) {
    _selection.questionImage = image;
    notifyListeners();
  }

  /// Check if selection is complete
  bool get isComplete => _selection.isComplete;

  /// Get JSON representation (for API submission)
  Map<String, dynamic> toJson() => _selection.toJson();

  /// Set the current generated question
  void setCurrentQuestion(GeneratedQuestion question) {
    _currentQuestion = question;
    notifyListeners();
  }

  /// Clear the current question
  void clearCurrentQuestion() {
    _currentQuestion = null;
    notifyListeners();
  }

  /// Reset all selections and clear question
  void reset() {
    _selection = PracticeSelection();
    _currentQuestion = null;
    notifyListeners();
  }

  /// Debug info
  @override
  String toString() => _selection.toString();
}

