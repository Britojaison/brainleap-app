/// Model for AI-generated practice question
class GeneratedQuestion {
  final String questionId;
  final String question;
  final String? questionImageUrl;
  final String difficulty;
  final String topic;
  final String subtopic;
  final List<String> hints;
  final DateTime generatedAt;

  GeneratedQuestion({
    required this.questionId,
    required this.question,
    this.questionImageUrl,
    required this.difficulty,
    required this.topic,
    required this.subtopic,
    this.hints = const [],
    required this.generatedAt,
  });

  /// Create from API JSON response
  factory GeneratedQuestion.fromJson(Map<String, dynamic> json) {
    return GeneratedQuestion(
      questionId: json['questionId'] as String,
      question: json['question'] as String,
      questionImageUrl: json['questionImageUrl'] as String?,
      difficulty: json['difficulty'] as String? ?? 'medium',
      topic: json['topic'] as String? ?? '',
      subtopic: json['subtopic'] as String? ?? '',
      hints: (json['hints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'question': question,
      'questionImageUrl': questionImageUrl,
      'difficulty': difficulty,
      'topic': topic,
      'subtopic': subtopic,
      'hints': hints,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'GeneratedQuestion(id: $questionId, question: "$question", difficulty: $difficulty)';
  }
}

