class Question {
  final String category;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  Question({
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });
//change 1
  List<String> get shuffledAnswers {
    final allAnswers = [...incorrectAnswers, correctAnswer];
    allAnswers.shuffle();
    return allAnswers;
  }
}