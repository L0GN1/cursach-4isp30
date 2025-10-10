import 'package:flutter/foundation.dart';

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

  List<String> get shuffledAnswers {
    final allAnswers = [...incorrectAnswers, correctAnswer];
    allAnswers.shuffle();
    return allAnswers;
  }
}

class QuizProvider with ChangeNotifier {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  String? _error;
  String? _selectedAnswer;
  bool _answerSubmitted = false;
  List<String> _currentShuffledAnswers = []; // Храним перемешанные ответы для текущего вопроса

  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedAnswer => _selectedAnswer;
  bool get answerSubmitted => _answerSubmitted;
  List<String> get currentShuffledAnswers => _currentShuffledAnswers;

  Question get currentQuestion {
    if (_questions.isEmpty) {
      return Question(
        category: '',
        question: '',
        correctAnswer: '',
        incorrectAnswers: [],
      );
    }
    return _questions[_currentQuestionIndex];
  }

  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
  int get totalQuestions => _questions.length;
  double get progress => totalQuestions > 0 ? (currentQuestionIndex + 1) / totalQuestions : 0;

  Future<void> loadQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _questions = _getQuestions();
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _answerSubmitted = false;
      // Генерируем перемешанные ответы для первого вопроса
      if (_questions.isNotEmpty) {
        _currentShuffledAnswers = _questions[0].shuffledAnswers;
      }
    } catch (e) {
      _error = 'Ошибка загрузки вопросов: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Question> _getQuestions() {
    return [
      Question(
        category: 'География',
        question: 'Какая страна является самой большой по площади в мире?',
        correctAnswer: 'Россия',
        incorrectAnswers: ['Канада', 'Китай', 'США'],
      ),
      Question(
        category: 'История',
        question: 'В каком году произошла Октябрьская революция?',
        correctAnswer: '1917',
        incorrectAnswers: ['1905', '1914', '1922'],
      ),
      Question(
        category: 'Литература',
        question: 'Кто написал роман "Война и мир"?',
        correctAnswer: 'Лев Толстой',
        incorrectAnswers: ['Фёдор Достоевский', 'Антон Чехов', 'Иван Тургенев'],
      ),
      Question(
        category: 'Наука',
        question: 'Какая планета Солнечной системы самая большая?',
        correctAnswer: 'Юпитер',
        incorrectAnswers: ['Сатурн', 'Нептун', 'Земля'],
      ),
      Question(
        category: 'Кино',
        question: 'Какой актер сыграл роль Джеймса Бонда в фильме "Казино Рояль"?',
        correctAnswer: 'Дэниел Крэйг',
        incorrectAnswers: ['Шон Коннери', 'Пирс Броснан', 'Тимоти Далтон'],
      ),
      Question(
        category: 'Спорт',
        question: 'В каком году Москва принимала летние Олимпийские игры?',
        correctAnswer: '1980',
        incorrectAnswers: ['1972', '1988', '1996'],
      ),
      Question(
        category: 'Музыка',
        question: 'Какая группа исполнила песню "Брось"?',
        correctAnswer: 'Ленинград',
        incorrectAnswers: ['ДДТ', 'Кино', 'Алиса'],
      ),
      Question(
        category: 'Кулинария',
        question: 'Какой суп считается традиционным русским блюдом?',
        correctAnswer: 'Щи',
        incorrectAnswers: ['Гаспачо', 'Минестроне', 'Том-ям'],
      ),
      Question(
        category: 'Искусство',
        question: 'Кто написал картину "Черный квадрат"?',
        correctAnswer: 'Казимир Малевич',
        incorrectAnswers: ['Василий Кандинский', 'Пабло Пикассо', 'Винсент Ван Гог'],
      ),
      Question(
        category: 'Природа',
        question: 'Какое животное является самым быстрым на суше?',
        correctAnswer: 'Гепард',
        incorrectAnswers: ['Лев', 'Антилопа', 'Волк'],
      ),
    ];
  }

  void selectAnswer(String answer) {
    if (!_answerSubmitted) {
      _selectedAnswer = answer;
      notifyListeners();
    }
  }

  void submitAnswer() {
    if (_selectedAnswer != null && !_answerSubmitted) {
      _answerSubmitted = true;

      if (_selectedAnswer == currentQuestion.correctAnswer) {
        _score += 10;
      }

      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _selectedAnswer = null;
      _answerSubmitted = false;
      // Генерируем новые перемешанные ответы для следующего вопроса
      _currentShuffledAnswers = currentQuestion.shuffledAnswers;
      notifyListeners();
    }
  }

  void restartQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answerSubmitted = false;
    _error = null;
    if (_questions.isNotEmpty) {
      _currentShuffledAnswers = _questions[0].shuffledAnswers;
    }
    notifyListeners();
  }

  bool isCorrectAnswer(String answer) {
    return answer == currentQuestion.correctAnswer;
  }

  bool isWrongAnswer(String answer) {
    return _answerSubmitted &&
        answer == _selectedAnswer &&
        answer != currentQuestion.correctAnswer;
  }

  // Проверяем, выбран ли этот ответ (для подсветки)
  bool isSelectedAnswer(String answer) {
    return answer == _selectedAnswer;
  }
}