import 'dart:typed_data';

/// Data model to store user selections throughout the practice flow
class PracticeSelection {
  String? classLevel;
  String? subject;
  String? curriculum;
  String? topic;
  String? subtopic;
  Uint8List? questionImage;

  PracticeSelection({
    this.classLevel,
    this.subject,
    this.curriculum,
    this.topic,
    this.subtopic,
    this.questionImage,
  });

  /// Check if all required fields are filled
  bool get isComplete {
    return classLevel != null &&
        subject != null &&
        curriculum != null &&
        topic != null &&
        subtopic != null &&
        questionImage != null;
  }

  /// Convert to JSON (without image data)
  Map<String, dynamic> toJson() {
    return {
      'classLevel': classLevel,
      'subject': subject,
      'curriculum': curriculum,
      'topic': topic,
      'subtopic': subtopic,
    };
  }

  /// Create from JSON
  factory PracticeSelection.fromJson(Map<String, dynamic> json) {
    return PracticeSelection(
      classLevel: json['classLevel'] as String?,
      subject: json['subject'] as String?,
      curriculum: json['curriculum'] as String?,
      topic: json['topic'] as String?,
      subtopic: json['subtopic'] as String?,
    );
  }

  /// Reset all selections
  void reset() {
    classLevel = null;
    subject = null;
    curriculum = null;
    topic = null;
    subtopic = null;
    questionImage = null;
  }

  @override
  String toString() {
    return 'PracticeSelection(class: $classLevel, subject: $subject, '
        'curriculum: $curriculum, topic: $topic, subtopic: $subtopic)';
  }
}

