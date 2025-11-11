class Topic {
  const Topic({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.iconName,
    this.questionsCount = 0,
    this.completedCount = 0,
  });

  final String id;
  final String name;
  final String category;
  final String? description;
  final String? iconName;
  final int questionsCount;
  final int completedCount;

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      iconName: json['iconName'] as String?,
      questionsCount: json['questionsCount'] as int? ?? 0,
      completedCount: json['completedCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'iconName': iconName,
      'questionsCount': questionsCount,
      'completedCount': completedCount,
    };
  }

  double get progressPercentage {
    if (questionsCount == 0) return 0.0;
    return (completedCount / questionsCount) * 100;
  }
}

