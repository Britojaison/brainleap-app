class AiHint {
  const AiHint({
    required this.title,
    required this.explanation,
    this.nextSteps = const [],
  });

  final String title;
  final String explanation;
  final List<String> nextSteps;

  factory AiHint.fromJson(Map<String, dynamic> json) {
    final steps = (json['nextSteps'] as List<dynamic>?)
            ?.whereType<String>()
            .toList(growable: false) ??
        const <String>[];
    return AiHint(
      title: json['title'] as String? ?? 'Hint',
      explanation: json['explanation'] as String? ?? 'No explanation provided.',
      nextSteps: steps,
    );
  }
}

