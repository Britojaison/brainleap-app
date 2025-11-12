/// Static data for topics and subtopics used in the practice flow
class TopicData {
  /// Available class levels
  static const List<String> classLevels = [
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
  ];

  /// Available subjects
  static const List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
  ];

  /// Available curriculums
  static const List<String> curriculums = [
    'CBSE',
    'ICSE',
    'Cambridge IGCSE',
    'IB',
    'SAT',
    'GRE',
    'GMAT',
    'JEE',
    'NEET',
  ];

  /// Main topics for Mathematics
  static const List<String> mathematicsTopics = [
    'Algebra & Functions',
    'Probability & Statistics',
    'Geometry & Trigonometry',
    'Coordinate Geometry',
    'Calculus',
    'Vectors',
  ];

  /// Main topics for Physics
  static const List<String> physicsTopics = [
    'Mechanics',
    'Electricity & Magnetism',
    'Thermodynamics',
    'Optics',
    'Modern Physics',
    'Waves & Oscillations',
  ];

  /// Main topics for Chemistry
  static const List<String> chemistryTopics = [
    'Atomic Structure',
    'Chemical Bonding',
    'Thermodynamics',
    'Organic Chemistry',
    'Inorganic Chemistry',
    'Physical Chemistry',
  ];

  /// Get topics based on subject
  static List<String> getTopicsForSubject(String subject) {
    switch (subject) {
      case 'Mathematics':
        return mathematicsTopics;
      case 'Physics':
        return physicsTopics;
      case 'Chemistry':
        return chemistryTopics;
      default:
        return mathematicsTopics;
    }
  }

  /// Subtopics for each main topic (expandable accordion data)
  static const Map<String, List<String>> subtopicsMap = {
    // Mathematics subtopics
    'Algebra & Functions': [
      'Simplifying Expressions',
      'Using Standard Identities',
      'Factorisation',
    ],
    'Probability & Statistics': [
      'Mean, Median, Mode',
      'Probability Distributions',
      'Data Analysis',
    ],
    'Geometry & Trigonometry': [
      'Properties of Triangles',
      'Trigonometric Ratios',
      'Circle Theorems',
    ],
    'Coordinate Geometry': [
      'Distance Formula',
      'Equation of Lines',
      'Circles and Conic Sections',
    ],
    'Calculus': [
      'Limits and Continuity',
      'Differentiation',
      'Integration',
    ],
    'Vectors': [
      'Vector Addition',
      'Dot and Cross Product',
      'Vector Projections',
    ],

    // Physics subtopics
    'Mechanics': [
      "Newton's Laws of Motion",
      'Work, Energy and Power',
      'Circular Motion',
    ],
    'Electricity & Magnetism': [
      "Ohm's Law",
      'Magnetic Fields',
      'Electromagnetic Induction',
    ],
    'Thermodynamics': [
      'Laws of Thermodynamics',
      'Heat Transfer',
      'Entropy',
    ],
    'Optics': [
      'Reflection and Refraction',
      'Lens Formula',
      'Wave Optics',
    ],
    'Modern Physics': [
      'Photoelectric Effect',
      'Atomic Models',
      'Radioactivity',
    ],
    'Waves & Oscillations': [
      'Simple Harmonic Motion',
      'Wave Equation',
      'Doppler Effect',
    ],

    // Chemistry subtopics
    'Atomic Structure': [
      'Electronic Configuration',
      'Quantum Numbers',
      'Periodic Table',
    ],
    'Chemical Bonding': [
      'Ionic Bonding',
      'Covalent Bonding',
      'Molecular Orbital Theory',
    ],
    'Organic Chemistry': [
      'Nomenclature',
      'Reaction Mechanisms',
      'Isomerism',
    ],
    'Inorganic Chemistry': [
      'Coordination Compounds',
      'Transition Elements',
      'Metallurgy',
    ],
    'Physical Chemistry': [
      'Chemical Kinetics',
      'Equilibrium',
      'Electrochemistry',
    ],
  };

  /// Get subtopics for a given topic
  static List<String> getSubtopics(String topic) {
    return subtopicsMap[topic] ?? [];
  }

  /// Get all topics with their subtopics as a structured map
  static Map<String, List<String>> getTopicStructure(String subject) {
    final topics = getTopicsForSubject(subject);
    final Map<String, List<String>> structure = {};

    for (final topic in topics) {
      structure[topic] = getSubtopics(topic);
    }

    return structure;
  }
}

