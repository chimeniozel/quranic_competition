class QuizModel {
  String? id; // Firestore document ID
  String question;
  List<String> options;
  String correctAnswer;
  String level;

  QuizModel({
    this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.level,
  });

  // Convert QuizModel to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'level': level,
    };
  }

  // Create QuizModel from Firebase data
  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id'] as String?,
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? '',
      level: map['level'] ?? '',
    );
  }
}
