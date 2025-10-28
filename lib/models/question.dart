class Question {
  final String category; //категория вопроса
  final String question; //текст самого вопроса
  final String correctAnswer; //правильный ответ
  final List<String> incorrectAnswers; //список неправильных вариантов ответа
  final String difficulty; //уровень сложности

  Question({
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.difficulty,
  });

  List<String> get shuffledAnswers {
    final allAnswers = [...incorrectAnswers, correctAnswer];
    allAnswers.shuffle();
    return allAnswers;
  }
}
