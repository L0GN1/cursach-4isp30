import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../services/quiz_api_service.dart';

class QuizProvider with ChangeNotifier {
  List<Question> _questions = [];
  List<Question> _allQuestions = []; // Все вопросы по сложностям
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  String? _error;
  String? _selectedAnswer;
  bool _answerSubmitted = false;
  List<String> _currentShuffledAnswers = [];
  String _currentDifficulty = 'легкий'; // По умолчанию легкий

  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedAnswer => _selectedAnswer;
  bool get answerSubmitted => _answerSubmitted;
  List<String> get currentShuffledAnswers => _currentShuffledAnswers;
  String get currentDifficulty => _currentDifficulty;

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

  // Загружаем все вопросы при инициализации
  Future<void> initializeQuestions() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final QuizService quizService = QuizService();
      _allQuestions = quizService.getQuestions();
      _error = null;
    } catch (e) {
      _error = 'Ошибка инициализации вопросов: $e';
      // Если сервис не работает, используем локальные вопросы
      _allQuestions = _getLocalQuestions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Устанавливаем сложность и фильтруем вопросы
  void setDifficulty(String difficulty) {
    _currentDifficulty = difficulty;
    _questions = _allQuestions.where((q) => q.difficulty == difficulty).toList();

    // Если вопросы не найдены для выбранной сложности, используем локальные
    if (_questions.isEmpty) {
      _questions = _getLocalQuestions().where((q) => q.difficulty == difficulty).toList();
    }

    _questions.shuffle(); // Перемешиваем вопросы

    // Ограничиваем количество вопросов для каждой сложности
    int maxQuestions = _getMaxQuestionsForDifficulty(difficulty);
    if (_questions.length > maxQuestions) {
      _questions = _questions.sublist(0, maxQuestions);
    }

    _currentQuestionIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answerSubmitted = false;
    if (_questions.isNotEmpty) {
      _currentShuffledAnswers = _questions[0].shuffledAnswers;
    }
    notifyListeners();
  }

  Future<void> loadQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // Используем уже установленную сложность
      if (_questions.isEmpty) {
        setDifficulty(_currentDifficulty);
      }
    } catch (e) {
      _error = 'Ошибка загрузки вопросов: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Локальные вопросы на случай если сервис не работает
  List<Question> _getLocalQuestions() {
    return [
      // Легкие вопросы
      Question(
        category: 'География',
        question: 'Какая страна является самой большой по площади в мире?',
        correctAnswer: 'Россия',
        incorrectAnswers: ['Канада', 'Китай', 'США'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Наука',
        question: 'Какая планета Солнечной системы самая большая?',
        correctAnswer: 'Юпитер',
        incorrectAnswers: ['Сатурн', 'Нептун', 'Земля'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Спорт',
        question: 'Сколько игроков в футбольной команде?',
        correctAnswer: '11',
        incorrectAnswers: ['10', '12', '9'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Музыка',
        question: 'Сколько клавиш у стандартного фортепиано?',
        correctAnswer: '88',
        incorrectAnswers: ['76', '92', '64'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Кино',
        question: 'Кто сыграл главную роль в фильме "Железный человек"?',
        correctAnswer: 'Роберт Дауни мл.',
        incorrectAnswers: ['Крис Эванс', 'Крис Хемсворт', 'Марк Руффало'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Общие знания',
        question: 'Сколько дней в високосном году?',
        correctAnswer: '366',
        incorrectAnswers: ['365', '367', '364'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Природа',
        question: 'Какое животное является самым быстрым на суше?',
        correctAnswer: 'Гепард',
        incorrectAnswers: ['Лев', 'Антилопа', 'Волк'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Кулинария',
        question: 'Какой суп считается традиционным русским блюдом?',
        correctAnswer: 'Щи',
        incorrectAnswers: ['Гаспачо', 'Минестроне', 'Том-ям'],
        difficulty: 'легкий',
      ),

      // Средние вопросы
      Question(
        category: 'История',
        question: 'В каком году произошла Октябрьская революция?',
        correctAnswer: '1917',
        incorrectAnswers: ['1905', '1914', '1922'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Литература',
        question: 'Кто написал роман "Война и мир"?',
        correctAnswer: 'Лев Толстой',
        incorrectAnswers: ['Фёдор Достоевский', 'Антон Чехов', 'Иван Тургенев'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Кино',
        question: 'Какой актер сыграл роль Джеймса Бонда в фильме "Казино Рояль"?',
        correctAnswer: 'Дэниел Крэйг',
        incorrectAnswers: ['Шон Коннери', 'Пирс Броснан', 'Тимоти Далтон'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Спорт',
        question: 'В каком году Москва принимала летние Олимпийские игры?',
        correctAnswer: '1980',
        incorrectAnswers: ['1972', '1988', '1996'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Искусство',
        question: 'Кто написал картину "Черный квадрат"?',
        correctAnswer: 'Казимир Малевич',
        incorrectAnswers: ['Василий Кандинский', 'Пабло Пикассо', 'Винсент Ван Гог'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Музыка',
        question: 'Какая группа исполнила песню "Брось"?',
        correctAnswer: 'Ленинград',
        incorrectAnswers: ['ДДТ', 'Кино', 'Алиса'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Наука',
        question: 'Какой газ преобладает в атмосфере Земли?',
        correctAnswer: 'Азот',
        incorrectAnswers: ['Кислород', 'Углекислый газ', 'Аргон'],
        difficulty: 'средний',
      ),
      Question(
        category: 'География',
        question: 'Какая река самая длинная в мире?',
        correctAnswer: 'Нил',
        incorrectAnswers: ['Амазонка', 'Янцзы', 'Миссисипи'],
        difficulty: 'средний',
      ),

      // Сложные вопросы
      Question(
        category: 'История',
        question: 'Кто был первым императором Священной Римской империи?',
        correctAnswer: 'Оттон I',
        incorrectAnswers: ['Карл Великий', 'Фридрих I', 'Генрих IV'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Наука',
        question: 'Какой химический элемент имеет атомный номер 79?',
        correctAnswer: 'Золото',
        incorrectAnswers: ['Серебро', 'Платина', 'Ртуть'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Литература',
        question: 'Кто автор философского трактата "Так говорил Заратустра"?',
        correctAnswer: 'Фридрих Ницше',
        incorrectAnswers: ['Артур Шопенгауэр', 'Иммануил Кант', 'Сёрен Кьеркегор'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Музыка',
        question: 'Кто написал оперу "Кольцо Нибелунга"?',
        correctAnswer: 'Рихард Вагнер',
        incorrectAnswers: ['Людвиг ван Бетховен', 'Вольфганг Амадей Моцарт', 'Иоганн Себастьян Бах'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'География',
        question: 'Какая страна имеет самую длинную береговую линию в мире?',
        correctAnswer: 'Канада',
        incorrectAnswers: ['Россия', 'Индонезия', 'Гренландия'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Кулинария',
        question: 'Из какой страны происходит соевый соус?',
        correctAnswer: 'Китай',
        incorrectAnswers: ['Япония', 'Корея', 'Вьетнам'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Искусство',
        question: 'В каком веке жил Леонардо да Винчи?',
        correctAnswer: 'XV век',
        incorrectAnswers: ['XIV век', 'XVI век', 'XVII век'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Философия',
        question: 'Кто является автором "Государства"?',
        correctAnswer: 'Платон',
        incorrectAnswers: ['Аристотель', 'Сократ', 'Эпикур'],
        difficulty: 'сложный',
      ),
    ];
  }

  int _getMaxQuestionsForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'легкий':
        return 8;
      case 'средний':
        return 8;
      case 'сложный':
        return 8;
      default:
        return 5;
    }
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