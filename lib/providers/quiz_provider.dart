import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../services/quiz_api_service.dart';

class QuizProvider with ChangeNotifier {
  List<Question> _questions = [];
  List<Question> _allQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  String? _error;
  String? _selectedAnswer;
  bool _answerSubmitted = false;
  List<String> _currentShuffledAnswers = [];
  String _currentDifficulty = 'легкий';
  bool _usingLocalQuestions = false;

  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedAnswer => _selectedAnswer;
  bool get answerSubmitted => _answerSubmitted;
  List<String> get currentShuffledAnswers => _currentShuffledAnswers;
  String get currentDifficulty => _currentDifficulty;
  bool get usingLocalQuestions => _usingLocalQuestions;

  Question get currentQuestion {
    if (_questions.isEmpty) {
      return Question(
        category: '',
        question: '',
        correctAnswer: '',
        incorrectAnswers: [],
        difficulty: '',
      );
    }
    return _questions[_currentQuestionIndex];
  }

  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
  int get totalQuestions => _questions.length;
  double get progress => totalQuestions > 0 ? (currentQuestionIndex + 1) / totalQuestions : 0;

  // Загружаем вопросы из API с fallback на локальные
  Future<void> initializeQuestions() async {
    _isLoading = true;
    _error = null;
    _usingLocalQuestions = false;
    notifyListeners();

    try {
      final QuizService quizService = QuizService();

      // Пробуем загрузить из API
      final easyQuestions = await quizService.getQuestionsByDifficulty('легкий');
      final mediumQuestions = await quizService.getQuestionsByDifficulty('средний');
      final hardQuestions = await quizService.getQuestionsByDifficulty('сложный');

      _allQuestions = [...easyQuestions, ...mediumQuestions, ...hardQuestions];

      // Проверяем, используем ли мы локальные вопросы (по количеству вопросов)
      _usingLocalQuestions = _allQuestions.length <= 24;

      _error = null;
    } catch (e) {
      _error = 'Ошибка загрузки вопросов: $e';
      _usingLocalQuestions = true;
      // Используем только локальные вопросы
      final QuizService quizService = QuizService();
      _allQuestions = quizService.getLocalQuestions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Метод loadQuestions для использования в QuizScreen
  Future<void> loadQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // Используем уже установленную сложность
      if (_questions.isEmpty) {
        await setDifficulty(_currentDifficulty);
      }
    } catch (e) {
      _error = 'Ошибка загрузки вопросов: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Устанавливаем сложность и фильтруем вопросы
  Future<void> setDifficulty(String difficulty) async {
    _isLoading = true;
    notifyListeners();

    _currentDifficulty = difficulty;

    try {
      final QuizService quizService = QuizService();

      // Пробуем получить вопросы для выбранной сложности
      _questions = await quizService.getQuestionsByDifficulty(difficulty);

      // Если вопросов мало, добавляем из локальных
      if (_questions.length < 5) {
        final localQuestions = quizService.getLocalQuestions()
            .where((q) => q.difficulty == difficulty)
            .toList();
        _questions.addAll(localQuestions);
        _usingLocalQuestions = true;
      }

    } catch (e) {
      // Полный fallback на локальные вопросы
      final QuizService quizService = QuizService();
      _questions = quizService.getLocalQuestions()
          .where((q) => q.difficulty == difficulty)
          .toList();
      _usingLocalQuestions = true;
    }

    _questions.shuffle();

    // Ограничиваем количество вопросов
    int maxQuestions = _getMaxQuestionsForDifficulty(difficulty);
    if (_questions.length > maxQuestions) {
      _questions = _questions.sublist(0, maxQuestions);
    }

    _currentQuestionIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answerSubmitted = false;
    _isLoading = false;

    if (_questions.isNotEmpty) {
      _currentShuffledAnswers = _questions[0].shuffledAnswers;
    }

    notifyListeners();
  }

  int _getMaxQuestionsForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'легкий': return 8;
      case 'средний': return 8;
      case 'сложный': return 8;
      default: return 5;
    }
  }

  // Остальные методы остаются без изменений
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

  void resetToMenu() {
    _questions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answerSubmitted = false;
    _error = null;
    _currentShuffledAnswers = [];
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

  bool isSelectedAnswer(String answer) {
    return answer == _selectedAnswer;
  }

  Map<String, int> getQuestionsCountByDifficulty() {
    return {
      'легкий': _allQuestions.where((q) => q.difficulty == 'легкий').length,
      'средний': _allQuestions.where((q) => q.difficulty == 'средний').length,
      'сложный': _allQuestions.where((q) => q.difficulty == 'сложный').length,
    };
  }

  bool hasQuestionsForDifficulty(String difficulty) {
    return _allQuestions.where((q) => q.difficulty == difficulty).length >= 3;
  }
}
